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

from com.googlecode.fascinator.common import FascinatorHome, JsonSimple, JsonObject
from com.googlecode.fascinator.transformer.jsonVelocity import Util
from java.io import File

import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "util")) 
import preview

## for Attachments
from com.googlecode.fascinator.api.indexer import SearchRequest
from java.io import ByteArrayInputStream, ByteArrayOutputStream
from com.googlecode.fascinator.common.solr import SolrResult

class DetailData:
    def __init__(self):
        pass

    def __activate__(self, context):
        storage = context["Services"].getStorage()
        storedObj = storage.getObject(context["metadata"].getFirst("storage_id"))
        request = context["request"]
        version = request.getParameter("version")
        if version is not None:
            self.item = JsonSimple(File(storedObj.getPath() + "/version_" + version))
            self.version = preview.formatDate(version, "yyyyMMddHHmmss", "yyyy-MM-dd HH:mm:ss")
        else:
            self.version = None
            self.item = preview.loadPackage(storedObj)

        self.committeeResponses = None
        payloadList = storedObj.getPayloadIdList()
        if payloadList.contains("committee-responses.metadata"):
            committeeResponsePayload = storedObj.getPayload("committee-responses.metadata")
            self.committeeResponses = JsonSimple(committeeResponsePayload.open()).getJsonObject()
        else:
            self.committeeResponses = JsonObject()

        self.Services = context["Services"]
        self.oid = storedObj.getId()
        self.getAttachments()    
            

    def getComitteeResponses(self):
        return self.committeeResponses
    
    def getComitteeResponse(self, userName):
        return self.committeeResponses.get(userName)

    def getDisplayList(self):
        return JsonSimple(FascinatorHome.getPathFile(os.path.join("system-files", "package-arms", "preview-fields.json")))   

    def getAttachments(self):
        attachmentType = "review-attachments"

        req = SearchRequest("attached_to:%s AND attachment_type:%s" % (self.oid, attachmentType))
        req.setParam("rows", "1000")
        out = ByteArrayOutputStream()
        self.Services.indexer.search(req, out)
        response = SolrResult(ByteArrayInputStream(out.toByteArray()))
        return response.getResults()
