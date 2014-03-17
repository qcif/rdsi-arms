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

from com.googlecode.fascinator.common import JsonObject

class AssessmentData(Assessment):
    """ Used by HTTP client to query status of an assessment
    """
    def __init__(self):
        pass

    def __activate__(self, context):
        self.activate(context)
        self.writer = context["response"].getPrintWriter("application/json; charset=UTF-8")
        
        oid = self.request.getParameter("oid")
        self._queryAssessment(oid)

    def _queryAssessment(self, oid):
        response = JsonObject()
        response.put("status", "new")

        if oid:
            assessment = None ## Not processed yet
            storedObj = self.hasResponses(oid)
            if storedObj:
                committeeResponses = self.getResponses(storedObj)
                assessment = committeeResponses.get(self.assessor)
                if assessment:
                    status = assessment.get("status")
                    if status:
                        response.put("status", status)
                    else:
                        response.put("status", "draft") # In case not "status" key

        self.writer.println(response)
        self.writer.close()       
