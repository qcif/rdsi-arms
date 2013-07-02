from com.googlecode.fascinator.common import FascinatorHome, JsonSimple
import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "util")) 
import preview
from TFPackageReader import TFPackageReader
from java.io import File

class DetailData:
    def __init__(self):
        pass

    def __activate__(self, context):
        storage = context["Services"].getStorage()
        storedObj = storage.getObject(context["metadata"].getFirst("storage_id"))
        self.packageData = TFPackageReader(preview.loadPackage(storedObj))
        self.versions = self.getVersions(storedObj)

    def getDisplayList(self):
        return JsonSimple(FascinatorHome.getPathFile(os.path.join("system-files", "package-arms", "preview-fields.json")))
        
    def getVersions(self, storedObj):
        indF = File(storedObj.getPath() + "/Version_Index.json")
        
        versions = []
        if indF.exists():
            versions = JsonSimple(indF).getJsonArray()

        return versions
