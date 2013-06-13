from com.googlecode.fascinator.common import FascinatorHome, JsonSimple
import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "util")) 
import preview

# from com.googlecode.fascinator.common import FascinatorHome, JsonObject, JsonSimple
# from java.util import TreeMap, TreeSet

class DetailData:
    def __init__(self):
        pass

    def __activate__(self, context):
        self.metadata = context["metadata"]
        
    def getDisplayList(self):
        return JsonSimple(FascinatorHome.getPathFile("system-files/package-arms/preview-fields.json"))

    def getList(self, baseKey):
        return preview.getList(self.metadata, baseKey)
