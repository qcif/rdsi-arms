from com.googlecode.fascinator.api.indexer import SearchRequest
from com.googlecode.fascinator.api.storage import StorageException
from com.googlecode.fascinator.common import JsonObject, JsonSimple
from com.googlecode.fascinator.common.solr import SolrResult

from java.io import ByteArrayInputStream, ByteArrayOutputStream
from java.lang import Exception
from java.util import TreeMap, TreeSet

from org.json.simple import JSONArray

class DetailData:
    def __init__(self):
        pass

    def __activate__(self, context):
        self.page = context["page"]
        self.metadata = context["metadata"]
        self.log = context["log"]
        
    def getDisplayList(self):
        jsonString = """
            {   "dataprovider:foaf:title": "foaf-title",
                "dataprovider:foaf:givenName": "foaf-givenName",
                "dataprovider:foaf:familyName": "foaf-familyName",
                "dataprovider:foaf:email": "foaf-email",
                "dataprovider:foaf:phone": "foaf-phone",
                "dataprovider:foaf:role": "foaf-role",
                "dataprovider:foaf:organization": "foaf-organization",
                "dataprovider:foaf:state:prefLabel": "foaf-state",
                "requester:foaf:title": "foaf-title",
                "requester:foaf:givenName": "foaf-givenName",
                "requester:foaf:givenName": "foaf-givenName",
                "requester:foaf:familyName": "foaf-familyName",
                "requester:foaf:email": "foaf-email",
                "requester:foaf:phone": "foaf-phone",
                "requester:foaf:role": "foaf-role",
                "requester:foaf:organization": "foaf-organization",
                "requester:foaf:state:prefLabel": "foaf-state",
                "dc_description": "description",
                "discover-metadata.":"discover-metadata",
                "dc:subject.anzsrc:for.1.skos:prefLabel": "dc-subject.anzsrc-for",
                "merit-description":"merit-description",
                "accessRestrictions":"accessRestrictions",
                "dc:rights.skos:note":"dc-rights.skos-note",
                "dc:accessRights":"dc-accessRights",
                "citation":"citation",
                "user-number":"user-number"
                "user-access-frequency":"user-access-frequency",
                "rdsi-node":"rdsi-node",
                "data-size":"data-size",
                "storage-class":"storage-class",
                "ingest-1qtr":"ingest-1qtr",
                "ingest-2qtr":"ingest-2qtr",
                "ingest-3qtr":"ingest-3qtr",
                "ingest-4qtr":"ingest-4qtr",
                "vivo-Dataset.dc.format":"vivo-Dataset.dc.format",
                "reuse-availability":"reuse-availability",
                "data-medium-migration-assistance":"data-medium-migration-assistance",
                "storage-risk-rdsi-only":"storage-risk-rdsi-only",
                "storage-risk-regenerate":"storage-risk-regenerate"
                "storage-risk-disruption":"storage-risk-disruption",
                "data-medium-migration":"data-medium-migration",
                "required-resources":"required-resources"
             }
            """
        return JsonSimple(jsonString)    

    def getList(self, baseKey):
        if baseKey[-1:] != ".":
            baseKey = baseKey + "."
        valueMap = TreeMap()
        metadata = self.metadata.getJsonObject()
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
            
        print "Will return list %s for key = %s" % (str(valueMap), baseKey)     
        return valueMap

    def getSortedKeySet(self):
        return TreeSet(self.metadata.getJsonObject().keySet())
