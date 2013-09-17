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

# TODO: need to consolidate the code for dashboards as they are almost identical  
class Dashboard:
    def __init__(self):
        pass

    def activate(self, context):
        self.velocityContext = context
        
        self.indexer = self.vc('Services').getIndexer()
        
        # print "Security prep"
        self.__securityPrep()
        # print "Done security prep"
        self.__myArms = None
        #~ self.__stages = JsonSimple(FascinatorHome.getPathFile("harvest/workflows/arms.json")).getArray("stages")
        self.__stages = JsonSimple(FascinatorHome.getPathFile("harvest/workflows/arms.json")).getJsonSimpleList(["stages"])
        # print "We have a stage list here: %s " % str(self.__stages)

        for stage in self.__stages:
            # print "%s = %s" % (stage.getString("noname", ["name"]), stage.getString("no des", ["description"]))
            rt_set = self._searchStage(stage.getString("noname", ["name"])).getResults()
            # print "Stage has %s " % str(rt_set)
        self.__search()

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
    
    def _searchStage(self, stage):
        req = SearchRequest("packageType:arms")
        if ',' in stage:
            stages = stage.split(',')
            for s in stages:
                s = "workflow_step:"+s
            req.addParam("fq", " OR ".join(stages))
            # print "Searching stages %s" % " OR ".join(stages)
        else:
            req.addParam("fq", 'workflow_step:' + stage)

        req.setParam("sort", "last_modified desc, f_dc_title asc");
        out = ByteArrayOutputStream()
        self.indexer.search(req, out)
        return SolrResult(ByteArrayInputStream(out.toByteArray()))

    # if isAdmin, no security_query is needed
    def _searchSets(self, searchType, isAdmin=True, security_query=''):
        req = SearchRequest("packageType:"+searchType)
        req.setParam("fq", 'item_type:"object"')

        req.addParam("fq", "")
        req.setParam("sort", "last_modified desc, f_dc_title asc");
        if not isAdmin:
            req.addParam("fq", security_query)
        out = ByteArrayOutputStream()
        self.indexer.search(req, out)
        return SolrResult(ByteArrayInputStream(out.toByteArray()))

        # Security prep work
    def __securityPrep(self):
        current_user = self.vc("page").authentication.get_username()
        # print "Current user: " + current_user
        security_roles = self.vc("page").authentication.get_roles_list()
        # print "security_roles: ".join(current_user)
        security_filter = 'security_filter:("' + '" OR "'.join(security_roles) + '")'
        # print "security_filter: " + security_filter
        security_exceptions = 'security_exception:"' + current_user + '"'
        # print "security_exceptions: " + security_exceptions
        owner_query = 'owner:"' + current_user + '"'
        security_query = "(" + security_filter + ") OR (" + security_exceptions + ") OR (" + owner_query + ")"
        # print "security_query: " + security_query
        isAdmin = self.vc("page").authentication.is_admin()

        #~ req = SearchRequest("*:*")
        #~ req.setParam("fq", 'item_type:"object"')
        #~ if portalQuery:
            #~ req.addParam("fq", portalQuery)
        #~ if portalSearchQuery:
            #~ req.addParam("fq", portalSearchQuery)
        #~ req.addParam("fq", "")
        #~ req.setParam("rows", "0")
        #~ req.setParam("facet", "true")
        #~ req.setParam("facet.field", "workflow_step")
        #~ if not isAdmin:
            #~ req.addParam("fq", security_query)

    def __search(self):
        req = SearchRequest("packageType:arms")
        req.setParam("facet", "true")
        req.setParam("facet.field", "workflow_step")
        #~ req.setParam("fq", 'workflow_step:"arms-request"')
        req.addParam("fq", 'security_filter:"admin"')
        out = ByteArrayOutputStream()
        self.indexer.search(req, out)
        steps = SolrResult(ByteArrayInputStream(out.toByteArray()))
        # print "After all we have such a list of stages through facet: %s." % str(steps)
        # print "Facets are %s " % str(steps.getFacets().get("workflow_step").values())

        portalQuery = self.vc('Services').getPortalManager().get(self.vc("portalId")).getQuery()
        portalSearchQuery = self.vc('Services').getPortalManager().get(self.vc("portalId")).getSearchQuery()

        isAdmin = self.vc("page").authentication.is_admin()
        if isAdmin:
            self.__myArms = self._searchSets("arms")
        else:
            # Security prep work
            current_user = self.vc("page").authentication.get_username()
            security_roles = self.vc("page").authentication.get_roles_list()
            security_exceptions = 'security_exception:"' + current_user + '"'
            owner_query = 'owner:"' + current_user + '"'
            self.__myArms = self._searchSets("arms", isAdmin, owner_query)

        wfConfig = JsonSimple(FascinatorHome.getPathFile("harvest/workflows/arms.json"))
        jsonStageList = wfConfig.getJsonSimpleList(["stages"])
        # print "we have such a list of stages: %s." % str(jsonStageList)
        for jsonStage in jsonStageList:
            # print "Stage name: %s." % jsonStage.getString("noname", ["name"])
            # print "Stage label: %s." % jsonStage.getString("[No label]", ["label"])
            
            wfMetaObj = JsonSimple().getJsonObject()
            wfMetaObj.put("name", jsonStage.getString("noname", ["name"]))
            wfMetaObj.put("label", jsonStage.getString("[No label]", ["label"]))
                          
        # print "After all we have such a list of stages: %s." % str(wfMetaObj)

    def getUser(self):
        current_user = self.vc("page").authentication.get_username()
        return current_user
    
    def getListOfStage(self, stageName):
#         workflow_step == arms-request, arms-submitted, arms-allocation-commitee, arms-approved, arms-retired
        # print "Query about %s." % stageName
        return self._searchStage(stageName).getResults()

    # Used by searching shared requests to the current user
    def getShared(self):
        current_user = self.vc("page").authentication.get_username()
        security_roles = self.vc("page").authentication.get_roles_list()
        security_exceptions = 'security_exception:"' + current_user + '"'
        owner_query = 'owner:"' + current_user + '"'
        shared = self._searchSets( "arms", False, security_exceptions + " -"+owner_query)
        if shared:
            return shared.getResults()
        else:
            return ArrayList()
