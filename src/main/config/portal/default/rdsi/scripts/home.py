from com.googlecode.fascinator.api.indexer import SearchRequest
from com.googlecode.fascinator.common import FascinatorHome, JsonSimple
from com.googlecode.fascinator.common.solr import SolrResult
from java.io import ByteArrayInputStream, ByteArrayOutputStream
from java.text import SimpleDateFormat
from java.util import ArrayList

class HomeData:
    def __init__(self):
        pass

    def __activate__(self, context):
        auth = context["page"].authentication
        if auth.is_logged_in():
            dashboard = "user"
            if auth.has_role("admin"):
                dashboard = "admin"
                print "User has admin role"
            elif auth.has_role("reviewer"):
                dashboard = "reviewer"
                print "User has reviewer role"
            
            context["response"].sendRedirect("dashboards/" + dashboard)
