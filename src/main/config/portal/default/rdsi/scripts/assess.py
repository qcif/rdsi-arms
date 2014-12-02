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
from com.googlecode.fascinator.common import FascinatorHome
import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "util")) 

from Assessment import Assessment

from com.googlecode.fascinator.common import JsonSimple, JsonObject
from java.net import URLDecoder

import re

class AssessData(Assessment):
    """ Processing assessment form
        Save/display stored assessor assessments in committee-responses.metadata within current digital object
        The structure of committee-responses.metadata has keys of assessor's username. 
    """
    def __init__(self):
        pass

    def __activate__(self, context):
        self.activate(context)
        
        oid = self.request.getParameter("oid")
        if oid:
            self.saveResponse(context)
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

            tfpackage = None
            for pid in payloadList:
                if pid.endswith(".tfpackage"):
                    tfpackage = pid
                    break
            if tfpackage:
                self.reviewers = self._readReviewers(storedObj, tfpackage)
            else:
                raise("No tfpakcage has been found.")
            if payloadList.contains(self.PAYLOAD):
                committeeResponses = self.getResponses(storedObj)
                self.assessment = committeeResponses.get(self.assessor) 
        else:
            self.oid = "null"

    def _readReviewers(self, storedObj, tfpackage):
        """Read from TFPACKAGE for reviewer's recommendation and map to a json with short keys:
             reviewer-recommend-for : for
             reviewer-recommended-storage : storage   
        """
        reviewersPayload = storedObj.getPayload(tfpackage)
        reviewersRecommends = JsonSimple(reviewersPayload.open()).getJsonObject()
        reviewers = JsonObject()
        reviewers.put("for", reviewersRecommends.get("reviewer-recommend-for"))
        reviewers.put("storage", reviewersRecommends.get("reviewer-recommended-storage"))
        return reviewers
