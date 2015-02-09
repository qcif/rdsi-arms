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

from java.io import File
from com.googlecode.fascinator.common import FascinatorHome, JsonSimple
import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "display"))
from Navigation import Navigation

class ARMSNavigation(Navigation):
    """
        Extends base Navigation class to read workflow_step label from workflow.meta
        used as the base class for arms and arms-storage types
    """

    def setup(self, context):
        self.activate(context)
        storage = context["Services"].getStorage()
        self.storedObj = storage.getObject(context["metadata"].getFirst("storage_id"))

    def getWorkflowStep(self):
        workflow = JsonSimple(File(os.path.join(self.storedObj.getPath(),"workflow.metadata")))
        # it always should have label field
        return workflow.getString("Check Code Please","label")
