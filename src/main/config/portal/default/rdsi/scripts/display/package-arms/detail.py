from com.googlecode.fascinator.api.indexer import SearchRequest
from com.googlecode.fascinator.api.storage import StorageException
from com.googlecode.fascinator.common import JsonObject, JsonSimple
from com.googlecode.fascinator.common.solr import SolrResult
from java.io import ByteArrayInputStream, ByteArrayOutputStream, File
from java.lang import Exception, System
from java.util import TreeMap, TreeSet, ArrayList, HashMap
from com.googlecode.fascinator.portal.lookup import MintLookupHelper
from com.googlecode.fascinator.api.storage import PayloadType
from java.text import SimpleDateFormat

from org.apache.commons.lang import StringEscapeUtils, WordUtils
from org.json.simple import JSONArray

import glob, os.path, re

class DetailData:
    def __init__(self):
        pass

    def __activate__(self, context):
        self.page = context["page"]
        self.metadata = context["metadata"]
        self.Services = context["Services"]
        self.indexer = self.Services.getIndexer()
        self.log = context["log"]
        self.log.debug("We rock")
