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

class AssessmentData:
    """ Draft, only accessible to assessor themselves, security settings
    """
    PAYLOAD = "committee-responses.metadata"
    
    def __init__(self):
        pass

    def __activate__(self, context):
        self.request = context["request"]
        self.storage = context["Services"].getStorage()
        self.assessor = context["page"].authentication.get_name()
        self.writer = context["response"].getPrintWriter("application/json; charset=UTF-8")
        
        oid = self.request.getParameter("oid")
        self.queryAssessment(oid)
     
    def queryAssessment(self, oid):
        response = JsonObject()
        response.put("status", "new")

        if oid:
            storedObj = self.storage.getObject(oid)
            payloadList = storedObj.getPayloadIdList()
            assessment = None ## Not processed yet
            if payloadList.contains(self.PAYLOAD):
                committeeResponses = self._getResponses(storedObj)
                assessment = committeeResponses.get(self.assessor)
                if assessment:
                    status = assessment.get("status")
                    if status:
                        response.put("status", status)
                    else:
                        response.put("status", "draft") # back compatibility

        self.writer.println(response)
        self.writer.close()       

    def _getResponses(self, storedObj):
        committeeResponsePayload = storedObj.getPayload(self.PAYLOAD)
        committeeResponses = JsonSimple(committeeResponsePayload.open()).getJsonObject()
        return committeeResponses
