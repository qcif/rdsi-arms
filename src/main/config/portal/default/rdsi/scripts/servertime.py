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

"""
Return server time to client
"""

from java.text import SimpleDateFormat
from java.util import Date

class ServertimeData:
    def __init__(self):
        pass

    def __activate__(self, context):
        
        request = context["request"]
        self.response = context["response"]
        format = request.getParameter("format")
        date = self.getCurrentDate(format)
        result = '{"date":"' + date+ '"}'
        writer = self.response.getPrintWriter("application/json; charset=UTF-8")
        writer.println(result)
        writer.close()
        
    def getCurrentDate(self, format):
        curDate = SimpleDateFormat(format)
        return curDate.format(Date());
