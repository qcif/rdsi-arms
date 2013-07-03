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

class HomeData:
    def __init__(self):
        pass

    def __activate__(self, context):
        auth = context["page"].authentication
        dashboard = "user"
        if auth.has_role("admin"):
            dashboard = "admin"
            print "User has admin role"
        elif auth.has_role("reviewer"):
            dashboard = "reviewer"
            print "User has reviewer role"
        
        context["response"].sendRedirect("dashboards/" + dashboard)
