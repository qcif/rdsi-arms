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
from java.util import HashMap
from com.googlecode.fascinator.spring import ApplicationContextProvider

class UserinfoData:
    """
    Get HibernateUser user information (attributes)
    Internal user has only one attribute password which always have NULL in VALSTR
    
    Attributes: # based on the attributes sets available on 19/12/2013 
    {
      "commonName": "FirstName LastName", # depends on AAF IdP
      "eduPersonAffiliation": "StaffVisitor - Internal;", # depends on AAF IdP
      "Shib-Session-ID": "token_string",
      "email": "someone@some.edu.au",
      "Shib-Identity-Provider": "urn:mace:federation.org.au:testfed:au-idp.some.edu.au"
    }
    """
    def __init__(self):
        pass
    
    def __activate__(self, context):
        self.log = context["log"]
        self.services = context["Services"]

        auth = context["page"].authentication
        username = auth.get_username() # get system username

        try:
            result = self.__constructInfoJson(username)
        except Exception, e:
             self.log.error("%s: error occured, detail = %s" % (self.__class__.__name__ , str(e)))
             result = JsonObject()
             result.put("commonName", auth.get_name()) # default value, user friendly display name
             
        self.__respond(context["response"], result)    

    def __constructInfoJson(self, username):
        """
            There are users managed by internal auth manager with no attributes
            There are users managed by external auth managers e.g. shibboleth who have attributes
            Here we assume we are dealing external auth managers providing attribute commonName which is displayed in portal from 
        """
        # print "Query username = %s" % username
        username = username.strip()

        authUserDao = ApplicationContextProvider.getApplicationContext().getBean("hibernateAuthUserDao")
        parameters = HashMap()
        parameters.put("username", username)
        userObjectList = authUserDao.query("getUser", parameters)

        # print "Returned object = %s" % str(userObjectList)
        # print "Returned size = %d" % userObjectList.size() 
        userJson = JsonObject()
        try:
            if userObjectList.size() > 0:
                # One hit will be enough to get user object
                userObj = userObjectList.get(0)
                attrbs = userObj.getAttributes()
                for attrb in attrbs.keySet():
#                     print "Attribute %s = %s) % (attrb, attrbs.get(attrb).getValStr())
                    userJson.put(attrb, attrbs.get(attrb).getValStr())
            else:
               # This should not be reached with external sourced users
                self.log.warn("Wrong username? Every user should have a record")
                userJson.put("userName", username) 
        except Exception, e:
            self.log.error("%s: error occurred, detail = %s" % (self.__class__.__name__ , str(e)))
            userJson.put("userName", username)
        return userJson

    def __respond(self, response, result):
        writer = response.getPrintWriter("application/json; charset=UTF-8")
        writer.println(result)
        writer.close()        
