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

class TFPackageReader:
    """
    Read the content of tfpackage. 
    tfpackage is a json file. Should be read by functions like util.preview.loadPackage.
    Methods here only deal with key:string_value pairs
    
    Might be deprecated: See /fascinator-common/src/main/java/com/googlecode/fascinator/common/StorageDataUtil.java for replacement
    StorageDataUtil can be accessed in portal by $jsonUtil
    
    But cached self.keys might be interesting to some applications
    Also packageJson is an internal variable to save passing it back and forth  
    """
    def __init__(self, packageJson):
        """
        packageJson: JsonSimple object
        """
        self.packageData = packageJson    
        self.keys = self.packageData.getJsonObject().keySet()

    def getValue(self, key):
        return self.packageData.getString("", key)
    
    def getValueList(self, key, inString=False):
        """ If the second argument is tested true, return a string, otherwise a list """  
        rvalues = [] 
        for k in self.keys:
            if k.startswith(key):
                #print "We found one %s - %s" % (key, k)
                rvalues.append(self.getValue(k))
        if (inString):
            return ", ".join(rvalues)
        else:
            return rvalues

    def getRepeatables(self, baseKey, subKey, inString=False):
        """ If the third argument is tested true, return a string, otherwise a list """  
        rvalues = [] 
        for k in self.keys:
            if k.startswith(baseKey) and k.endswith(subKey):
                rvalues.append(self.getValue(k))
        if (inString):
            return ", ".join(rvalues)
        else:
            return rvalues
