"""
This is a simple script to demonstrate how to create user lookup hook
"""
from com.googlecode.fascinator.common import FascinatorHome, JsonObject, JsonSimple
from java.util import TreeMap, TreeSet

def getList(metadata, baseKey):
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
