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

from com.googlecode.fascinator.common.storage import StorageUtils
from com.googlecode.fascinator.common import JsonSimple
from com.googlecode.fascinator.common import JsonObject
from org.apache.commons.io import IOUtils

class CommitteeData:
    def __init__(self):
        pass

    def __activate__(self, context):
        request = context["request"]
        storage = context["Services"].getStorage()
        auth = context["page"].authentication
        log = context["log"]
        
        username = auth.get_username()
        
        oid = request.getParameter("oid")
        approved = request.getParameter("approved")
        approval_comment = request.getParameter("approval_comment")
        
        storedObj = storage.getObject(oid)
        committeeResponses = None
        
        payloadList = storedObj.getPayloadIdList()
        if payloadList.contains("committee-responses.metadata"):
            committeeResponsePayload = storedObj.getPayload("committee-responses.metadata")
            committeeResponses = JsonSimple(committeeResponsePayload.open()).getJsonObject()
        else:
            committeeResponses = JsonObject()
        
        committeeResponse = JsonObject()
        committeeResponse.put("approved",approved)
        committeeResponse.put("approval_comment",approval_comment)
        
        committeeResponses.put(username,committeeResponse)

        log.debug(" %s: Committee %s, approval = %s, comment = %s"  % ( oid, username, approved, approval_comment))
        StorageUtils.createOrUpdatePayload(storedObj,"committee-responses.metadata",IOUtils.toInputStream(committeeResponses.toString(), "UTF-8"))
        context["response"].sendRedirect(context["portalPath"] +"/detail/"+oid)
