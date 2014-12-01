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

from com.googlecode.fascinator.common import FascinatorHome
import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "display")) 

from Dashboard import Dashboard

class HomeData(Dashboard):
    def __init__(self):
        pass

    def __activate__(self, context):
        """
        Two roles are treated equally here: site role and node role. e.g. reviewer == reviewer-rdsi
        """
        self.activate(context, context["page"].getPortal().recordsPerPage)
        auth = context["page"].authentication
        portalId = context["portalId"]
        self.roleBoard = ""
        if auth.has_role("admin"):
            self.selected = "admin"
        elif auth.has_role("assessor") or auth.has_role("assessor-"+portalId):
            self.selected = "assessor"
            self._setSection(context["formData"])
        elif auth.has_role("requestor"):
            self.selected = "requestor"
        elif  auth.has_role("reviewer") or auth.has_role("reviewer-"+portalId):
            self.selected = "reviewer"
            self._setSection(context["formData"])
        else:
            self.selected = "guest"


    def _setSection(self, formData): 
        sub_section = formData.get("section")
        if sub_section:
            self.section = sub_section
        else:
            self.section = "active"
