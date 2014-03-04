# The RDSI - ALLOCATION REQUEST MANAGEMENT SYSTEM
# Copyright (C) 2014 Queensland Cyber Infrastructure Foundation (http://www.qcif.edu.au/)
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

from com.googlecode.fascinator.common import JsonSimple, JsonObject
from com.googlecode.fascinator.common.storage import StorageUtils
from java.net import URLDecoder
from org.apache.commons.io import IOUtils

import re

class AssessData:
    """ Save/display stored assessor assessments in committee-responses.metadata within current digital object
        The structure of committee-responses.metadata has keys of assessor's username. 
    """
    PAYLOAD = "committee-responses.metadata"
    
    def __init__(self):
        pass

    def __activate__(self, context):
        self.request = context["request"]
        self.storage = context["Services"].getStorage()
        self.username = context["page"].authentication.get_name()
        
        oid = self.request.getParameter("oid")
        if oid:
            self._saveResopnse(context)
        else:
            self._loadForm()
     
    def _loadForm(self):
        """ Display the form and prepare the saved assessment from this assessor if exists
            The uri has to be http(s)://root/portal/assess/oid 
        """
        uri = URLDecoder.decode(self.request.getAttribute("RequestURI"))
        matches = re.match("^(.*?)/(.*?)/(.*?)$", uri)
        if matches and matches.group(3):
            self.oid = matches.group(3)
            storedObj = self.storage.getObject(self.oid)
            
            payloadList = storedObj.getPayloadIdList()
            self.assessment = None

            if payloadList.contains(self.PAYLOAD):
                committeeResponses = self._getResponses(storedObj)
                self.assessment = committeeResponses.get(self.username) 
        else:
            self.oid = "null"

    def _saveResopnse(self, context):
        """ Save into object storage key to username
            It has three keys: recommendation, size-agreement and comments
        """
        oid = self.request.getParameter("oid")
        recommendation = self.request.getParameter("recommendation")
        sizeAgreement = self.request.getParameter("size-agreement")
        comments = self.request.getParameter("comments")
        
        storedObj = self.storage.getObject(oid)
        payloadList = storedObj.getPayloadIdList()
        if payloadList.contains(self.PAYLOAD):
            committeeResponses = self._getResponses(storedObj)
        else:
            committeeResponses = JsonObject()
        
        assessorResponse = JsonObject()
        assessorResponse.put("recommendation",recommendation)
        assessorResponse.put("size-agreement",sizeAgreement)
        assessorResponse.put("comments",comments)
        
        committeeResponses.put(self.username,assessorResponse)

        ## print " %s: Committee %s, recommendation = %s, comments = %s"  % ( oid, self.username, recommendation, comments)
        StorageUtils.createOrUpdatePayload(storedObj,self.PAYLOAD,IOUtils.toInputStream(committeeResponses.toString(), "UTF-8"))
        context["response"].sendRedirect(context["portalPath"] +"/detail/"+oid)

    def _getResponses(self, storedObj):
        committeeResponsePayload = storedObj.getPayload(self.PAYLOAD)
        committeeResponses = JsonSimple(committeeResponsePayload.open()).getJsonObject()
        return committeeResponses

