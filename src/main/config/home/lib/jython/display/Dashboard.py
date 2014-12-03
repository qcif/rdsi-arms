# The RDSI - ALLOCATION REQUEST MANAGEMENT SYSTEM
# Copyright (C) 2013 Queensland Cyber Infrastructure Foundation (http://www.qcif.edu.au/)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

from com.googlecode.fascinator.api.indexer import SearchRequest

from com.googlecode.fascinator.common.solr import SolrResult
from java.io import ByteArrayInputStream, ByteArrayOutputStream
from java.text import SimpleDateFormat
from com.googlecode.fascinator.common import FascinatorHome, JsonSimple, JsonObject

from java.util import ArrayList
from org.json.simple import JSONArray

from com.googlecode.fascinator.portal import Pagination

import sys, os
sys.path.append(os.path.join(FascinatorHome.getPath(), "lib", "jython", "util"))

from Assessment import Assessment

class Dashboard:
    # Default number of rows returned in one query without Pagination
    MAX_ROWS = "1000"
    def __init__(self):
        pass

    def activate(self, context, recordsPerPage = 10):
        self.velocityContext = context
        self.indexer = self.vc('Services').getIndexer()

        self.recordsPerPage = recordsPerPage
        self.returnFields = "id,date_object_created,date_object_modified,dc_title,workflow_step,workflow_step_label,dataprovider:email,owner"

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

    def _searchStage(self, packageType, stage, startPage=1):
        req = SearchRequest("packageType:"+packageType)
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

        req.setParam("sort", "date_object_modified desc, f_dc_title asc")
        req.setParam("fl",self.returnFields)
        out = ByteArrayOutputStream()
        self.indexer.search(req, out)
        return SolrResult(ByteArrayInputStream(out.toByteArray()))

    # if isAdmin, no security_query is needed
    def _searchSets(self, packageType, isAdmin=True, security_query='', startPage=1):
        req = SearchRequest("packageType:"+packageType)
        req.setParam("rows", str(self.recordsPerPage))
        req.setParam("start", str((startPage - 1) * self.recordsPerPage))

        req.setParam("fq", 'item_type:"object"')

        req.addParam("fq", "")
        req.setParam("sort", "date_object_modified desc, f_dc_title asc")
        req.setParam("fl",self.returnFields)
        if not isAdmin:
            req.addParam("fq", security_query)
        out = ByteArrayOutputStream()
        self.indexer.search(req, out)
        return SolrResult(ByteArrayInputStream(out.toByteArray()))

    def getUser(self):
        current_user = self.vc("page").authentication.get_username()
        return current_user

    def getListOfStage(self, packageType, stageName, startPage=1):
        rt = self._searchStage(packageType, stageName, startPage)
        self._setPaging(rt.getNumFound())
        return rt.getResults()

    # Used by searching shared requests to the current user
    # TODO: make page control works
    def getShared(self, packageType="arms", startPage=1):
        current_user = self.vc("page").authentication.get_username()
        security_roles = self.vc("page").authentication.get_roles_list()
        security_exceptions = 'security_exception:"' + current_user + '"'
        owner_query = 'owner:"' + current_user + '"'
        shared = self._searchSets( packageType, False, security_exceptions + " -"+owner_query)
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

    def getFilteredAssessments(self, packageType, stageName, filterType, startPage=1):
        """ A customised query to use filter to get certain assessment with desired status """
        ## reference /redbox-rdsi-arms/src/main/config/home/lib/jython/util/Assessment.py for methods
        filters = {'assessment-draft': ['new','draft'], 'assessment-submitted':['submitted']}
        statusFilter = filters[filterType]

        req = SearchRequest("packageType:" + packageType)
        req.addParam("fq", 'workflow_step:' + stageName)
        req.setParam("sort", "date_object_modified desc, f_dc_title asc")
        req.setParam("fl",self.returnFields)
        out = ByteArrayOutputStream()
        self.indexer.search(req, out)
        solrResults = SolrResult(ByteArrayInputStream(out.toByteArray()))

        if solrResults:
            results = solrResults.getResults()
            returnArray = JSONArray()
            x = Assessment()
            x.activate(self.velocityContext)
            i = 0
            rows = self.recordsPerPage
            start = (startPage - 1) * self.recordsPerPage
            for r in results:
                status = x.queryStatus(r.get("id"))
                if status in statusFilter:
                    if i >= start and i - start < rows:
                        assessment_submitted_date = x.queryAttr(r.get("id"), 'date')
                        if assessment_submitted_date:
                            r.getJsonObject().put('date', assessment_submitted_date)
                        returnArray.add(r)
                    i = i + 1

            self._setPaging(returnArray.size())
            return returnArray
        else:
            return ArrayList()

    def checkRequests(self, checklist_filter=['1'], role_filter='reviewer', exclusive=True, startPage=1):
        """ A customised query for arms at arms-review
            Get a list of requests filtered by provisioning_checklist
        """
        workflowStep = "arms-review"
        req = SearchRequest("packageType:arms")
        req.addParam("fq", 'workflow_step:' + workflowStep)
        for item in ['1','2','3']:
            if item in checklist_filter:
                req.addParam("fq", '-provisioning_checklist.' + item + ':null' + ' AND provisioning_checklist.' + item + ':[* TO *]')
            else:
                if exclusive:
                    # ensure that brand new submissions (not yet saved by reviewer) are also returned
                    req.addParam("fq", 'provisioning_checklist.' + item + ':null' + ' OR (*:* -provisioning_checklist.' + item + ':[* TO *])')
        req.setParam("sort", "date_object_modified desc, f_dc_title asc")
        req.setParam("fl",self.returnFields)
        out = ByteArrayOutputStream()
        self.indexer.search(req, out)
        solrResults = SolrResult(ByteArrayInputStream(out.toByteArray()))

        if solrResults:
            results = solrResults.getResults()
            if results:
                packageResults = results
                results = self.mergeEvents(packageResults, ["arms_draft","arms_redraft","arms_review","arms_assessment","arms_approved","arms_rejected","arms_provisioned"])
            returnArray = JSONArray()
            if role_filter == 'assessor':
                x = Assessment()
                x.activate(self.velocityContext)
                i = 0
                rows = self.recordsPerPage
                # print self.recordsPerPage
                # print type(startPage)
                # print type(self.recordsPerPage
                # this has to be fixed: defaut argument is string for some reason
                #  startPage=1
                start = (startPage - 1) * self.recordsPerPage
                for r in results:
                    status = x.queryStatus(r.get("id"))
                    if i >= start and i - start < rows:
                        assessment_submitted_date = x.queryAttr(r.get("id"), 'date')
                        if assessment_submitted_date:
                            r.getJsonObject().put('date', assessment_submitted_date)
                        returnArray.add(r)
                    i = i + 1
            else:
                returnArray = results

            self._setPaging(returnArray.size())
            return returnArray
        else:
            return ArrayList()

    def _packageResults(self, req, solrLog=None):
        out = ByteArrayOutputStream()
        if solrLog:
            self.indexer.searchByIndex(req, out, solrLog)
        else:
            self.indexer.searchByIndex(req, out)
        solrResults = SolrResult(ByteArrayInputStream(out.toByteArray()))
        if solrResults:
            return solrResults.getResults()
        else:
            return ArrayList()

    def _extractOIDs(self, resultList):
        idList = []
        for result in resultList:
            idList.append('"' + result.get("id") + '"')
        return '(%s)' % " OR ".join(idList)

    def _mergeList(self, mainList, pending, defaultKeys):
        for result in mainList:
            pendingItem = pending.get(result.get("id"))
            jObj = result.getJsonObject();
            if pendingItem:
                for k in pendingItem.keySet():
                    jObj.put(k.replace('-','_'), pendingItem.get(k))
            for k in defaultKeys:
                if not jObj.containsKey(k):
                    jObj.put(k, "")
        return mainList

    def getLatest(self, oids):
        """Query the history and save the latest to the return JsonObject"""
        req = SearchRequest('context:"Workflow" AND newStep:[* TO *] AND oid:' + oids + '')
        req.setParam("fl",'eventTime,newStep,oid')
        req.setParam("rows", Dashboard.MAX_ROWS)
        req.setParam("sort", "oid asc, eventTime desc")

        events = self._packageResults(req, "eventLog")
        latest = JsonObject()
        for e in events:
            oid = e.get("oid")
            if oid not in latest:
                jObj = JsonObject()
                jObj.put("step", e.get("newStep"))
                jObj.put("eventTime", self.formatDate(e.get("eventTime")))
                latest.put(oid,jObj)
        return latest

    def getLatestState(self, packageType, stageName, startPage=1):
        results = self.getListOfStage(packageType, stageName, startPage)
        if results:
            latestSteps = self.getLatest(self._extractOIDs(results))
            return self._mergeList(results, latestSteps,["eventTime"])
        else:
            return None

    def getFullHistory(self, oids):
        """Query the history and save the latest full set of workflow steps to the return JsonObject"""
        req = SearchRequest('context:"Workflow" AND newStep:[* TO *] AND oid:' + oids + '')
        req.setParam("fl",'eventTime,newStep,oid')
        req.setParam("rows", Dashboard.MAX_ROWS)
        req.setParam("sort", "oid asc, eventTime asc")

        events = self._packageResults(req, "eventLog")
        latest = JsonObject()
        for e in events:
            oid = e.get("oid")
            if oid not in latest:
                jObj = JsonObject()
                latest.put(oid,jObj)
            else:
                jObj = latest.get(oid)
            jObj.put('%s_eventTime' % e.get("newStep"), self.formatDate(e.get("eventTime")))
        return latest

    def getAllStates(self, packageType, stageName, startPage=1):
        results = self.getListOfStage(packageType, stageName, startPage)
        ## Fixme: read from home/harvest/arms.json
        defaultEvents = ["arms_draft","arms_redraft","arms_review","arms_assessment","arms_approved","arms_rejected","arms_provisioned"]
        return self.mergeEvents(results, defaultEvents)

    def mergeEvents(self, results, eventList):
        if results:
            oids = self._extractOIDs(results)
            allSteps = self.getFullHistory(oids)
            return self._mergeList(results, allSteps,['%s_eventTime' % e for e in eventList])
        else:
            return None