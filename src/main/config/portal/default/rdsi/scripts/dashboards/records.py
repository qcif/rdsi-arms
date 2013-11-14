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

class RecordsData(Dashboard):
    """
        Used in AJAX call to get paged search results of ARMS records
        It returns results of three types of search:
        submitted, shared and default: draft 
    """
    
    def __init__(self):
        pass

    def __activate__(self, context):
        self.activate(context, context["page"].getPortal().recordsPerPage)
        
        formData = context["formData"]
        pageNum = formData.get("pageNum")
        searchType = formData.get("searchType")
        if pageNum:
            pageNum = int(pageNum)
        else:
            pageNum = 1

        if searchType == "shared":
            results = self.getShared(pageNum)
        elif searchType == "submitted":
            results = self.getListOfStage('arms-submitted,arms-allocation-committee,arms-provisioning,arms-completed',pageNum)
        elif searchType == "provisioner":
            results = self.getListOfStage('arms-submitted,arms-allocation-committee,arms-provisioning,arms-completed',pageNum)
        elif searchType == "reviewer":
            results = self.getListOfStage('arms-submitted,arms-allocation-committee',pageNum)
        elif searchType == "committee":
            results = self.getListOfStage('arms-allocation-committee',pageNum)
        elif searchType == "adminProvisions":
            results = self.getListOfStage('arms-submitted,arms-allocation-committee,arms-provisioning',pageNum)
        elif searchType == "adminHoldings":
            results = self.getListOfStage('arms-completed,arms-retired',pageNum)
        else:
            results = self.getListOfStage('arms-request',pageNum)
        
        writer = context["response"].getPrintWriter("application/json; charset=UTF-8")
        writer.println(results)
        writer.close()        
