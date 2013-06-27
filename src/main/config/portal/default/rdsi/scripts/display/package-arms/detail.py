from com.googlecode.fascinator.common import FascinatorHome, JsonSimple
import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "util")) 
import preview

class DetailData:
    def __init__(self):
        pass

    def __activate__(self, context):
        sid = context["metadata"].getFirst("storage_id")
        self.packageData = preview.loadPackage(sid, context["Services"].getStorage())    
        self.keys = self.packageData.getJsonObject().keySet()

    def getDisplayList(self):
        return JsonSimple(FascinatorHome.getPathFile(os.path.join("system-files", "package-arms", "preview-fields.json")))

    def getValue(self, key):
        return self.packageData.getString("", key)
    
    def getValueList(self, key):
        rvalues = [] 
        for k in self.keys:
            if k.startswith(key):
                #print "We found one %s - %s" % (key, k)
                rvalues.append(self.getValue(k))
        return ", ".join(rvalues)

    # Return in a string  
    def getRepeatables(self, baseKey, subKey):
        rvalues = [] 
        for k in self.keys:
            if k.startswith(baseKey) and k.endswith(subKey):
                rvalues.append(self.getValue(k))
        return ", ".join(rvalues)
