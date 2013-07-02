"""
Utility function library for preview page
"""
from com.googlecode.fascinator.common import JsonSimple
from java.util import TreeMap

def loadPackage(storedObj):
    """Load the tfpackage and retrun in JSON format."""
    pkgJson = None
    try:
        for pid in storedObj.getPayloadIdList():
            if pid.endswith(".tfpackage"):
                payload = storedObj.getPayload(pid)
                pkgJson = JsonSimple(payload.open())
                payload.close()
    except Exception:
        pass
            
    return pkgJson

def getList(metadata, baseKey):
    """Get all elements of a field."""
    if baseKey[-1:] != ".":
        baseKey = baseKey + "."
    valueMap = TreeMap()
    metadata = metadata.getJsonObject()
    for key in [k for k in metadata.keySet() if k.startswith(baseKey)]:
        value = metadata.get(key)
        field = key[len(baseKey):]
        index = field[:field.find(".")]
        if index == "":
            valueMapIndex = field[:key.rfind(".")]
            dataIndex = "value"
        else:
            valueMapIndex = index
            dataIndex = field[field.find(".")+1:]
        #print "%s. '%s'='%s' ('%s','%s')" % (index, key, value, valueMapIndex, dataIndex)
        data = valueMap.get(valueMapIndex)
        #print "**** ", data
        if not data:
            data = TreeMap()
            valueMap.put(valueMapIndex, data)
        if len(value) == 1:
            value = value.get(0)
        data.put(dataIndex, value)
        
    return valueMap
