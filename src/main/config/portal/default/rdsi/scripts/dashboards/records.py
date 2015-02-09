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
        It returns results of predefined types of search:
        submitted, shared and etc. Default: requestor
    """

    def __init__(self):
        pass

    def __activate__(self, context):
        self.activate(context, context["page"].getPortal().recordsPerPage)
        # variables associate with searches.
        # If there is no map found, it will be default to "requestor" which is possibly not wanted
        searches = {'requestor':'arms-draft',
                    'redraft':'arms-redraft',
                    'submitted': 'arms-review,arms-approved,arms-rejected',
                    'reviewer':[],
                    'reviewer-assessing':['1'],
                    'reviewer-assessed':['1','2'],
                    'reviewer-provisioned':['4'],
                    'assessor':'assessor',
                    'assessor-assessed':'assessor-assessed',
                    'approved':0,
                    'approved-provisioned':1,
                    'rejected':'arms-rejected',
                    'adminProvisions':'arms-review,arms-approved',
                    'adminHoldings':'arms-approved,arms-rejected',
                    'shared':''}

        formData = context["formData"]
        packageType = formData.get("packageType")
        # Default packageType used in search is arms
        if not packageType:
            packageType = "arms"
        self.setPackageType(packageType)
        searchType = formData.get("searchType")
        # Default searchType is for requestor's drafts
        if searchType not in searches.keys():
             searchType = "requestor"
        pageNum = formData.get("pageNum")
        if pageNum:
            pageNum = int(pageNum)
        else:
            pageNum = 1

        if searchType == "shared":
            results = self.getShared(packageType, pageNum)
        elif searchType == "submitted":
            results = self.getLatestState(packageType, searches[searchType], pageNum)
        elif searchType.startswith("reviewer"):
            results = self.checkRequests(searches[searchType],'reviewer',True, pageNum)
        elif searchType.startswith("assessor"):
            results = self.checkRequests(['1'], searches[searchType], False, pageNum)
        elif searchType.startswith('approved'):
            results = self.checkAprovedRequests(packageType, searches[searchType], pageNum)
        else:
            results = self.getAllStates(packageType, searches[searchType], pageNum)

        writer = context["response"].getPrintWriter("application/json; charset=UTF-8")
        writer.println(results)
        writer.close()
