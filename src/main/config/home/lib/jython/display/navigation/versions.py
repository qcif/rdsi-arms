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
from org.json.simple import JSONArray
import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "util"))
import preview
from java.io import File

class Versions:
    """ Base class for providing functions to versions.vm
        of arms and arms-storage
    """
    def __init__(self):
        pass

    def activate(self, context):
        storage = context["Services"].getStorage()
        storedObj = storage.getObject(context["metadata"].getFirst("storage_id"))
        self.versions = self.getVersions(storedObj)
        self.oid = storedObj.getId()

    def getVersions(self, storedObj):
        indF = File(storedObj.getPath() + "/Version_Index.json")

        versions = []
        if indF.exists():
            versions = JsonSimple(indF).getJsonArray()
            # reverse to the order to from latest to oldest
            r = JSONArray()
            for s in reversed(versions):
                r.add(s)
            versions = r

        return versions

    def formatDate(self, date):
        return preview.formatDate(date, "yyyyMMddHHmmss", "yyyy-MM-dd HH:mm:ss")
