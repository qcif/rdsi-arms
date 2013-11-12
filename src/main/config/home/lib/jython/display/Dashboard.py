from com.googlecode.fascinator.api.indexer import SearchRequest
from com.googlecode.fascinator.common import FascinatorHome, JsonSimple
from com.googlecode.fascinator.common.solr import SolrResult
from java.io import ByteArrayInputStream, ByteArrayOutputStream
from java.text import SimpleDateFormat
from java.util import ArrayList

from com.googlecode.fascinator.api.indexer import SearchRequest
from com.googlecode.fascinator.common import FascinatorHome, JsonSimple
from com.googlecode.fascinator.common.solr import SolrResult
from java.io import ByteArrayInputStream, ByteArrayOutputStream
from java.text import SimpleDateFormat
from java.util import ArrayList
from com.googlecode.fascinator.portal import Pagination

class Dashboard:
    def __init__(self):
        pass

    def activate(self, context, recordsPerPage = 10):
        self.velocityContext = context
        self.indexer = self.vc('Services').getIndexer()

        self.recordsPerPage = recordsPerPage

    # Get from velocity context
    def vc(self, index):
        if self.velocityContext[index] is not None:
            return self.velocityContext[index]
        else:
            self.velocityContext["log"].error("ERROR: Requested context entry '{}' doesn't exist", index)
            return None
        
    def formatDate(self, date):    
        dfSource = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss")
        dfTarget = SimpleDateFormat("dd/MM/yyyy")
        return dfTarget.format(dfSource.parse(date))
    
    def _searchStage(self, stage, startPage=1):
        req = SearchRequest("packageType:arms")
        req.setParam("rows", str(self.recordsPerPage))
        req.setParam("start", str((startPage - 1) * self.recordsPerPage))

        if ',' in stage:
            stages = stage.split(',')
            for s in stages:
                s = "workflow_step:"+s
            req.addParam("fq", " OR ".join(stages))
            # print "Searching stages %s" % " OR ".join(stages)
        else:
            req.addParam("fq", 'workflow_step:' + stage)

        req.setParam("sort", "last_modified desc, f_dc_title asc")
        out = ByteArrayOutputStream()
        self.indexer.search(req, out)
        return SolrResult(ByteArrayInputStream(out.toByteArray()))

    # if isAdmin, no security_query is needed
    def _searchSets(self, searchType, isAdmin=True, security_query='', startPage=1):
        req = SearchRequest("packageType:"+searchType)
        req.setParam("rows", str(self.recordsPerPage))
        req.setParam("start", str((startPage - 1) * self.recordsPerPage))

        req.setParam("fq", 'item_type:"object"')

        req.addParam("fq", "")
        req.setParam("sort", "last_modified desc, f_dc_title asc");
        if not isAdmin:
            req.addParam("fq", security_query)
        out = ByteArrayOutputStream()
        self.indexer.search(req, out)
        return SolrResult(ByteArrayInputStream(out.toByteArray()))

    def getUser(self):
        current_user = self.vc("page").authentication.get_username()
        return current_user
    
    def getListOfStage(self, stageName, startPage=1):
        rt = self._searchStage(stageName, startPage)
        self._setPaging(rt.getNumFound())
        return rt.getResults()

    # Used by searching shared requests to the current user
    def getShared(self, startPage=1):
        current_user = self.vc("page").authentication.get_username()
        security_roles = self.vc("page").authentication.get_roles_list()
        security_exceptions = 'security_exception:"' + current_user + '"'
        owner_query = 'owner:"' + current_user + '"'
        shared = self._searchSets( "arms", False, security_exceptions + " -"+owner_query)
        if shared:
            self._setPaging(shared.getNumFound())
            return shared.getResults()
        else:
            return ArrayList()

    # Private function to set paging for each table, it does not has state of anything, updated when a new search is executed.
    def _setPaging(self, numFound):

        # no default value could cause problems
        if numFound is not None:
            self.paging = Pagination(1,numFound, self.recordsPerPage)
