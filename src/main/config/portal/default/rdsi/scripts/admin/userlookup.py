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

from com.googlecode.fascinator.common import JsonObject
from org.json.simple import JSONArray
from java.util import HashMap
from com.googlecode.fascinator.spring import ApplicationContextProvider

# TODO: might refactor it with other user related modules: grantAccess.py, userinfo.py which is this was based on
class UserlookupData:
    """
    Get HibernateUser information (attributes)
    Internal user has only one attribute password which always have NULL in VALSTR,
    so by default, it is filtered out
    
    The queries are supported by two Java beans: hibernateAuthUserDao and hibernateAuthUserAttributeDao 

    Search terms can be: email, username(e.g.: AAF token) and etc. One at a time
    Shibboleth authentication manager: for all available attributes see attribute-map.xml of the server's shibboleth configuration.
    Some possible attributes:   
    {
      "commonName": "FirstName LastName", # depends on AAF IdP
      "eduPersonAffiliation": "StaffVisitor - Internal;", # depends on AAF IdP
      "Shib-Session-ID": "token_string",
      "email": "someone@some.edu.au",
      "Shib-Identity-Provider": "urn:mace:federation.org.au:testfed:au-idp.some.edu.au",
      "givenName": "single free string", # Optional attribute
      "surname": "single free string" # Optional attribute
    }
    
    Two APIs:
      1. list supported attributes
        e.g.: http://localhost:9000/default/admin/userlookup.ajax
      2. query user(s) using a term
        e.g.: http://localhost:9000/default/admin/userlookup.ajax?qt=username&qv=urn%3Amace%3Afederation.org.au%3somevalue
        e.g.: http://localhost:9000/default/admin/userlookup.ajax?qt=email&qv=someemail
        
        Each of returned JSON (in array or single object) also has user's id and username       
    """
    
    # Used to filter out results no matter in which table
    ATTRIB_FILTER = ["password","Shib-Session-ID"]
    def __init__(self):
        pass
    
    def __activate__(self, context):
        self.log = context["log"]
        self.services = context["Services"]

        auth = context["page"].authentication

        if not auth.is_admin():
            result = JsonObject()
            # only in this case, returning JSON has status to get attention
            result.put("status", "403")
            result.put("message","Error: Only administrative users can access this feature")
            self.__respond(context["response"], result)
            return 

        qterm = context["formData"].get("qt")
        qvalue = context["formData"].get("qv")
        if not qterm:
            result = self.listUserAttributes()
        else:
            try:
                result = self.getUsers(qterm, qvalue)
            except Exception, e:
                 self.log.error("%s: cannot get user attributes, detail = %s" % (self.__class__.__name__ , str(e)))
                 result = JsonObject()
             
        self.__respond(context["response"], result)    

# changed from grantAccess.py::getUserName
    def listUserAttributes(self):
        """ Query HibernateUserAttribute to get the stored user attributes supported by current authentication manager 
            Return a JSONArray: can be empty if only internal manager is used
        """
        authUserAttrbDao = ApplicationContextProvider.getApplicationContext().getBean("hibernateAuthUserAttributeDao")
        attributeList = authUserAttrbDao.query("getUserAttributeList",HashMap())
        
        aList = JSONArray()
        if attributeList.size() > 0:
            filtered = [attribName for attribName in attributeList if attribName not in self.ATTRIB_FILTER]
            for a in filtered:
                aList.add(a)
        return aList

    def getUsers(self, k, v):
        """ Query HibernateUserAttribute with supported key:value pair against supported attributes 
            when query against username, it returns a JSON object as there could be only one user. 
            Otherwise returns a JSONArray of JSON which contains user's attributes but can be empty
        """
        if k == "username":
            return self.__getUserInfo(v)
        
        users = JSONArray()
        parameters = HashMap()

        parameters.put("key", k)
        parameters.put("value", v)
        authUserAttrbDao = ApplicationContextProvider.getApplicationContext().getBean("hibernateAuthUserAttributeDao")
        userObjectList = authUserAttrbDao.query("getUserAttributeByKeyAndValueDistinct", parameters)
        if userObjectList.size() > 0:
            for userObj in userObjectList:
                users.add(self.__constructUserAttribs(userObj[0], self.ATTRIB_FILTER))
        return users

    def __getUserInfo(self, username):
        """
            Query HibernateUser to get a user information
            There are users managed by internal auth manager with no attributes other than password
            There are users managed by external auth managers e.g. shibboleth who have attributes
            Each user, at the time of writing: 20140904, each user has multiple identical attribute sets,
            so, only the first one is used
            We put all available attributes of a user in to return value 
        """
        username = username.strip()

        authUserDao = ApplicationContextProvider.getApplicationContext().getBean("hibernateAuthUserDao")
        parameters = HashMap()
        parameters.put("username", username)
        userObjectList = authUserDao.query("getUser", parameters)

        userJson = JsonObject()
        userJson.put("username", username) 
        try:
            if userObjectList.size() > 0:
                # One hit will be enough to get user object
                userJson = self.__constructUserAttribs(userObjectList.get(0), self.ATTRIB_FILTER)
            else:
               # This should not be reached with external sourced users
                self.log.warn("Wrong username or internal user is queried")
        except Exception, e:
            self.log.error("%s: cannot construct user attribute JSON, detail = %s" % (self.__class__.__name__ , str(e)))
            
        return userJson

    def __constructUserAttribs(self, authUser, filter=["password"]):
        """
            Construct a JSON object to store all attributes of a user object
            Filter out do not wanted
        """
        userJson = JsonObject()
        # Get ID and username first
        userJson.put("id", authUser.getId())
        userJson.put("username", authUser.getUsername())

        attrbs = authUser.getAttributes()
        filtered = [attribName for attribName in attrbs.keySet() if attribName not in filter]
        for attribName in filtered:
            attribValue = attrbs.get(attribName).getValStr()
            userJson.put(attribName, attribValue)
        
        return userJson

    def __respond(self, response, result):
        writer = response.getPrintWriter("application/json; charset=UTF-8")
        writer.println(result)
        writer.close()        
