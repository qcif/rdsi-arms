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

from com.googlecode.fascinator.common import FascinatorHome, JsonSimple
from com.googlecode.fascinator.transformer.jsonVelocity import Util
import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "util")) 
import preview

class DetailData:
    def __init__(self):
        pass

    def __activate__(self, context):
        storage = context["Services"].getStorage()
        storedObj = storage.getObject(context["metadata"].getFirst("storage_id"))
        self.item = preview.loadPackage(storedObj);

    def getDisplayList(self):
        return JsonSimple(FascinatorHome.getPathFile(os.path.join("system-files", "package-arms", "preview-fields.json")))
