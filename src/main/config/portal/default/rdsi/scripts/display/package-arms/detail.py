from com.googlecode.fascinator.common import FascinatorHome, JsonSimple
import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "util")) 
import preview

class DetailData:
    def __init__(self):
        pass

    def __activate__(self, context):
        self.metadata = context["metadata"]
        
    def getDisplayList(self):
        return JsonSimple(FascinatorHome.getPathFile(os.path.join("system-files", "package-arms", "preview-fields.json")))

    def getList(self, baseKey):
        return preview.getList(self.metadata, baseKey)

    # Return in a string  
    def getRepeatables(self, repeats, baseKey, subKey):
        rvalues = [] 
        for skey in repeats.keySet():
            print "skey = %s" % skey
            item = repeats.get(skey)            
            subv = item.get(subKey).strip()
            if len(subv):
                rvalues.append(subv)
        return ", ".join(rvalues)
