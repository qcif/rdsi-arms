from com.googlecode.fascinator.common import FascinatorHome, JsonSimple
import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "util")) 
import preview
from TFPackageReader import TFPackageReader

class DetailData:
    def __init__(self):
        pass

    def __activate__(self, context):
        sid = context["metadata"].getFirst("storage_id")
        self.packageData = TFPackageReader(preview.loadPackage(sid, context["Services"].getStorage()))

    def getDisplayList(self):
        return JsonSimple(FascinatorHome.getPathFile(os.path.join("system-files", "package-arms", "preview-fields.json")))
