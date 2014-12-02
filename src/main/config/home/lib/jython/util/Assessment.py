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
from com.googlecode.fascinator.common import JsonSimple, JsonObject
from com.googlecode.fascinator.common.storage import StorageUtils
from org.apache.commons.io import IOUtils

import re
from datetime import date

class Assessment:
    """ Base class to read and save response, only accessible to assessor
    """
    PAYLOAD = "committee-responses.metadata"
    
    def __init__(self):
        pass

    def activate(self, context):
        self.request = context["request"]
        self.storage = context["Services"].getStorage()
        self.assessor = context["page"].authentication.get_name()
     
    def hasResponses(self, oid):
        storedObj = self.storage.getObject(oid)
        payloadList = storedObj.getPayloadIdList()
        if payloadList.contains(self.PAYLOAD):
            return (storedObj, True)
        else:
            return (storedObj, False)

    def getResponses(self, storedObj):
        committeeResponsePayload = storedObj.getPayload(self.PAYLOAD)
        committeeResponses = JsonSimple(committeeResponsePayload.open()).getJsonObject()
        return committeeResponses

    def saveResponse(self, context):
        """ Save into object storage key to assessor's name
            It has four keys: status, recommendation, size-agreement and comments
            when status == "submitted", reviewer sees it
        """
        oid = self.request.getParameter("oid")
        action = self.request.getParameter("action")
        if action and re.match("submit", action, re.I):
            status = "submitted"
        else:
            status = "draft"
        
        recommendation = self.request.getParameter("recommendation")
        sizeAgreement = self.request.getParameter("size-agreement")
        comments = self.request.getParameter("comments")
        
        storedObj, fileExisted = self.hasResponses(oid)
        if fileExisted:
            committeeResponses = self.getResponses(storedObj)
        else:
            committeeResponses = JsonObject()
        
        assessorResponse = JsonObject()
        assessorResponse.put("status", status)
        if status == 'submitted':
            assessorResponse.put("date",self._getToday())
        assessorResponse.put("recommendation",recommendation)
        assessorResponse.put("size-agreement",sizeAgreement)
        assessorResponse.put("comments",comments)
        
        committeeResponses.put(self.assessor,assessorResponse)

        StorageUtils.createOrUpdatePayload(storedObj,self.PAYLOAD,IOUtils.toInputStream(committeeResponses.toString(), "UTF-8"))
        context["response"].sendRedirect(context["portalPath"] +"/detail/"+oid)

    def queryStatus(self, oid):
        """ Query status and has to at least to return one of two default values: new or draft 
         """
        status = "new"

        if oid:
            assessment = None ## Not processed yet
            storedObj, fileExisted = self.hasResponses(oid)
            if fileExisted:
                committeeResponses = self.getResponses(storedObj)
                assessment = committeeResponses.get(self.assessor)
                if assessment:
                    savedStatus = assessment.get("status")
                    if savedStatus:
                        status = savedStatus
                    else:
                        status = "draft"
        return status

    def queryAttr(self, oid, attrName):
        """ Query an attribute value of the given attrName. Default value is None 
         """
        storedObj, fileExisted = self.hasResponses(oid)
        attrValue = None 
        if fileExisted:
            committeeResponses = self.getResponses(storedObj)
            assessment = committeeResponses.get(self.assessor)
            if assessment:
                attrValue =  assessment.get(attrName)
        return attrValue
        
    def _getToday(self):
        return date.today().strftime("%d/%m/%Y")       
