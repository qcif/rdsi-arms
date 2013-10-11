# The RDSI - ALLOCATION REQUEST MANAGEMENT SYSTEM
# Copyright (C) 2013 Queensland Cyber Infrastructure Foundation (http://www.qcif.edu.au/)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

from java.io import ByteArrayInputStream, ByteArrayOutputStream
from org.json.simple import JSONArray
from com.googlecode.fascinator.common import JsonObject
from java.util import HashMap
from com.googlecode.fascinator.common.storage import StorageUtils
from com.googlecode.fascinator.spring import ApplicationContextProvider

class GrantAccessData:
    """Grant access/change ownership of a package"""
    def __init__(self):
        pass
    
    def __activate__(self, context):
        self.log = context["log"]
        self.services = context["Services"]
        formData = context["formData"]
        oid = formData.get("oid")
        action = formData.get("action")
        self.authUserDao = ApplicationContextProvider.getApplicationContext().getBean("hibernateAuthUserDao")
        self.log.debug("grantAccess.py: Action = " + action)
        if action == 'get':
            result = self.__getUsers(oid)
        elif action == "getUserName":
            result = self.getUserName(formData.get("user"))
        elif action == "change":
            result = self.__change(context, oid, formData.get("new_owner"))
        else:
            result = '{"status":"bad request"}'
        
        self.__respond(context["response"], result)    


    def __constructUserJson(self, username):
        """
            There are users managed by internal auth manager with no attributes
            There are users managed by external auth manages e.g. shibboleth who have attributes
            These users username is not necessarily the same as there normal display name
            This function currently solves this issue by checking commonName attribute for shibboleth users  
        """
        username = username.strip()
        userJson = JsonObject()
        userJson.put("userName", username) 
        parameters = HashMap()
#         print "Checking user info for %s" % username
        parameters.put("username", username)
        userObjectList = self.authUserDao.query("getUser", parameters)
#         print "Returned size = %d" % userObjectList.size() 
        if userObjectList.size() > 0:
            userObject = userObjectList.get(0)
            #Check if this is a user with attributes?
            attrb = userObject.getAttributes().get("commonName")
            if attrb is None:
#                 print "We cannot find so called commonName, use %s instead" % username
                userJson.put("realName", username)
            else:
#                 print "We found so called commonName, use %s instead of %s" % (attrb.getValStr(), username)
                userJson.put("realName", attrb.getValStr().strip())
        else:
            # This should not be reached
            self.log.warn("What is going on here? why ends up here?")
            userJson.put("realName", username)
            
        return userJson

    def __getUsers(self, oid):
        storage = self.services.getStorage()
        object = storage.getObject(oid)
        objectMetadata = object.getMetadata()
        owner = objectMetadata.getProperty("owner")
        ownerJson = self.__constructUserJson(owner)
            
        users = self.getViewers(oid,owner)
        
        returningViewers = []
        for user in users:
            parameters = HashMap()
#             print "Checking user= %s" % user
            parameters.put("username",user)
            userObjectList = self.authUserDao.query("getUser",parameters)
            if userObjectList is not None or userObjectList.size() > 0:
                returningViewers.append(self.__constructUserJson(user))
                
        return '{"owner":' + ownerJson.toJSONString() + ', "viewers": ' + JSONArray.toJSONString(returningViewers) + '}'

            
    def getViewers(self, oid, owner):
        accessControl = ApplicationContextProvider.getApplicationContext().getBean("fascinatorAccess")
        users = accessControl.getUsers(oid)
        if users.contains(owner):
           users.remove(owner)
        return users

    def getUserName(self, userStr):
        """ userStr could be an identifier of a user, e.g. an email address not a username, 
            this function currently only verifies it against email address attribute stored in HibernateAuthUserAttribute table
            and return a real username if found, otherwise, return original query string
            Warning: this function does not check if a user exists
        """
        parameters = HashMap()
#         print "Checking user info by %s (could be email)" % userStr
        parameters.put("key", "email")
        parameters.put("value", userStr)
        authUserAttrbDao = ApplicationContextProvider.getApplicationContext().getBean("hibernateAuthUserAttributeDao")
        userObjectList = authUserAttrbDao.query("getUserAttributeByKeyAndValue", parameters)
        if userObjectList.size() > 0:
            userObject = userObjectList.get(0) #Check if this is a user with attributes?
            realUser = userObject.getUser()
            if realUser is not None:
                userStr = realUser.getUsername()
        return '{"realName":"' + userStr + '"}'

    def __change(self, context, oid, new_owner):
        storage = self.services.getStorage()
        object = storage.getObject(oid)
        objectMetadata = object.getMetadata()
        owner = objectMetadata.getProperty("owner")
        objectMetadata.setProperty("owner", new_owner)
        self.log.debug("grantAccess.py: Changed ownership from {} to {} ", owner, new_owner)
        output = ByteArrayOutputStream()
        objectMetadata.store(output, None)
        input = ByteArrayInputStream(output.toByteArray())
        StorageUtils.createOrUpdatePayload(object, "TF-OBJ-META", input)
        
        try:
            auth = context["page"].authentication
            source = context["formData"].get("source")
            self.log.debug("grantAccess.py: authentication plugin:  = {}", source)
            auth.set_access_plugin(source)
            # special condition when setting admin as owner - revoke all viewers
            if new_owner == "admin":
                viewers = self.getViewers(oid, owner)
                self.log.debug("grantAccess.py: New owner is admin, revoking all viewers")
                self.log.debug("grantAccess.py: Viewers: " + viewers.toString())
                for viewer in viewers:
                   self.log.debug("Revoking:%s" % viewer)
                   auth.revoke_user_access(oid, viewer)
                # when there are viewers, the previous owner somehow joins the read-only list, revoke access to the previous owner as well. 
                if viewers.size() > 0:
                    auth.revoke_user_access(oid, owner)
            else:
                self.log.info("Grant previous owner {} view access by adding them to security_execption.", owner)       
                auth.grant_user_access(oid, owner)  # give previous owner read access
            
            err = auth.get_error()
            if err is None or err == 'Duplicate! That user has already been applied to this record.':
              Services.indexer.index(oid)
              Services.indexer.commit()
              return '{"status":"ok", "new_owner": "' + new_owner + '"}'
            else:    
              self.log.error("grantAccess.py: Error raised during calling authentication for changing ownership. Exception: " + err)
        except Exception, e:
             self.log.error("grantAccess.py: Unexpected error raised during changing ownership of data. Exception: " + str(e))

    def __respond(self, response, result):
        writer = response.getPrintWriter("application/json; charset=UTF-8")
        writer.println(result)
        writer.close()        
