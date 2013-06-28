class TFPackageReader:
    """
    Read the content of tfpackage. 
    tfpackage is a json file. Should be read by functions like util.preview.loadPackage.
    Methods here only deal with key:string_value pairs
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
