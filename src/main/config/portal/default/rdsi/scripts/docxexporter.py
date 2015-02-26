# This Python file uses the following encoding: utf-8

# The RDSI - ALLOCATION REQUEST MANAGEMENT SYSTEM
# Copyright (C) 2015 Queensland Cyber Infrastructure Foundation (http://www.qcif.edu.au/)
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

from os.path import join, exists, splitext
from os import remove
import uuid

from com.googlecode.fascinator.common import FascinatorHome
from com.googlecode.fascinator.common import JsonObject, JsonSimple

from java.io import File
from java.util.zip import ZipFile
from net.sf.saxon import TransformerFactoryImpl
from javax.xml.transform.stream import StreamSource, StreamResult
from org.apache.commons.lang import StringEscapeUtils

from HTMLParser import HTMLParser

# https://wiki.python.org/moin/EscapingHtml
def unescape(s):
    s = s.replace("&lt;", "<")
    s = s.replace("&gt;", ">")
    # this has to be last:
    s = s.replace("&amp;", "&")
    return s

def map2(s):
    """Map symbols to strings"""
    if s == "☐":
        #~ print "mapped to unchecked"
        return "unchecked"
    elif s == "☒":
        #~ print "mapped to checked"
        return "checked"
    else:
        return s

class DocxHtmlParser(HTMLParser):
    """ Parse an HTMEL transformed from a Word Docx file
    Assumptions:
     Interesting fields with their names are in table rows
     Each table row is one targeted item
     First columns have questions (filed names) individually or in a group:
        <p><span>Name: </span></p>
        <p><span>some one</span></p>
        <p><span>Unit: </span></p>
        <p><span>some dep</span></p>
        The next column has value(s)
        Depends on table, columns after either 2 or 3 contains explanations, so they are ignored
     There is no multi-choice question: ☒ means selected/checked, ☐ means not
     Only above symbols are recognised and processed. Others will be treated as string
     A map between fields and questions is known, unkowns are ignored
"""

    def init(self):
        self.jobj = {}
        self.current_tag = None
        self.current_key = None
        self.leading = False
        self.tags = ("table", "tr", "td", "p")
        self.units = {}
        self.stacks = []
        self.nexts = {"tr": False, "td": False, "p": False}
        self.td_count = 0
        self.start_push = False

        self.contacts = {"Data Provider":"dataprovider","Data Storage Applicant":"requester"}
        self.extracted = {}
        self.current_contact = ""

        # 'organization', 'state' not used
        self.contact_fields = {'Title:':'title', 'Given Name:':'givenName', \
            'Family Name:':'familyName', 'Email:':'email', 'Telephone:':'phone', \
            'Role:':'role', 'Organisation:':'organization:prefLabel', 'State:':'state:prefLabel'}

        self.simple_fields = {'Collection Name':'dc:title', 'Description': 'collection:description'}
        self.current_field = {'name': '', 'type': ''} #type: simple

    def handle_starttag(self, tag, attrs):
        if tag == "span":
            #~ print "Encountered the beginning of a tag: %s tag" % tag
            self.current_tag = tag
            self.leading = not self.leading
        elif tag in self.tags:
            #~ print "%s opened" % tag
            self.units[tag] = True
        #~ else:
            #~ print "Encountered the not important beginning of a tag: %s" % tag

        if tag == "tr":
            self.td_count = 0
            if self.nexts["tr"]:
                self.nexts["td"] = True
                self.nexts["tr"] = False
            return
        if tag == "td" and self.nexts["td"]:
            self.nexts["p"] = True
            self.nexts["td"] = False
            return
        if tag == "p" and self.nexts["p"]:
            self.start_push = True

    def handle_data(self, data):
        #~ print("Data     :", data)
        d = ' '.join(data.split())
        if d:
            #~ print ("This is real: ", d)
            if self.current_tag == 'span':
                d = map2(d)
                #~ if d in ["checked", "unchecked"]:
                    #~ print "Do yes/no, radio buttons, checkboxes stuff, how many spans?"
                if d in self.contacts:
                    #~ print "We need to process %s " % self.contacts[d]
                    # if span has interesting string, trigger recording next tr
                    self.nexts["td"] = True
                    self.current_contact = self.contacts[d]
                if d in "Select the appropriate re-use condition for this research data":
                    print "Hit: collection-details-access-level but different, skip for now"
                if d in "Indicate an anticipated number of users of this data":
                    print "Hit: exp-number-users,skip for now"
                if d in self.simple_fields:
                    #~ print "Simle field, the content of the next cell need to be packed"
                    self.current_field['name'] = self.simple_fields[d]
                    self.current_field['type'] = 'simple'
                    self.nexts["td"] = True
                ## the if-else block is not useful if field names and values are in different cells
                ## it is useful when one next to each other
                #if self.leading:
                #    self.current_key = d
                #    #~ print "create key %s" % self.current_key
                #    self.jobj[self.current_key] = ""
                #else:
                #    #~ print "save value [ %s ] to %s" % (data, self.current_key)
                #    self.jobj[self.current_key] = d
                if self.nexts["p"] and self.start_push:
                    self.stacks.append(StringEscapeUtils.escapeHtml(d))

    def handle_endtag(self, tag):
        if tag in self.tags:
            #~ print "%s closed" % tag
            self.units[tag] = False
            if tag == "td":
                self.td_count = self.td_count + 1
                #~ print "Current td count %d" % self.td_count
                if self.start_push:
                    self.start_push = False
                    #~ if self.td_count == 1:
                        #~ print "this could be field name"
                    #~ print self.stacks
                    if self.current_field['type'] == "simple":
                        #~ print self.stacks
                        if self.current_field['name'] in self.extracted:
                            #~ print "collect every thing from stacks and save to %s" % self.current_field['name']
                            self.extracted[self.current_field['name']] = "".join(self.stacks)
                            self.current_field['name'] = ''
                            self.current_field['type'] = ''
                        else:
                            #~ print "This is the closing tag of the field name"
                            self.extracted[self.current_field['name']] = ""
                    if len(self.current_contact) > 4:
                        #~ print "Save stacks to %s" % self.current_contact
                        if self.td_count == 2:
                            # field names
                            self.extracted[self.current_contact] = self.stacks # need to map
                        elif self.td_count == 3:
                            # values:
                            if len(self.stacks) > 0:
                                # this is in proper dict, but jaffa needs to be in flat
                                fields = []
                                for f in self.extracted[self.current_contact]:
                                    fields.append(self.contact_fields[f])
                                contact = dict(zip(fields, self.stacks))
                                print contact
                                for f, v in contact.iteritems():
                                    self.extracted["%s:%s" % (self.current_contact, f)] = v
                            del self.extracted[self.current_contact]
                            # we done with this contact
                            self.current_contact = ""
                    #~ print "Clean out stacks\n\n"
                    self.stacks = []
                    self.nexts["p"] = False # Done with this cell, How to get to another cell?
                    self.nexts["td"] = True
                if self.td_count >= 3:
                    #~ print "td = %d, more tds are ignored from now on: no push" % self.td_count
                    self.nexts["td"] = False
                    self.start_push = False
                    self.nexts["tr"] = True

class DocxexporterData:
    def __init__(self):
        pass

    def __activate__(self, context):
        self.response = context["response"]
        self.formData = context["formData"]
        config = context["systemConfig"]
        #~ print "upload-path"
        self.upload_file = self.formData.get("uploadFile")
        self.upload_path = config.getString("", "uploader", self.formData.get("upload-file-workflow"), "upload-path")
        #~ print self.upload_path
        #~ print "form data"
        #~ print self.formData
        #~ print self.formData.get("upload-file-workflow")
        #~ self.sessionState = context["sessionState"]
        self.log = context["log"]
        uf = join(self.upload_path, self.upload_file)
        r = self.__check(uf)
        if r:
            print "let's try to dump"
            processed = self.processdocx(uf)
            #~ print processed
            #~ return

            #~ writer = self.response.getPrintWriter("text/html; charset=UTF-8")
            #~ result = self.dump2HTML(writer) #not working, why? not be used anyway
            #~ writer.flush()
            try:
                remove(uf)
            except Exception, e:
                self.log.error("Failed to remove uploaded word file: %s." % uf)
                self.log.error(str(e))
            writer = self.response.getPrintWriter("text/plain; charset=UTF-8")
            result = self.__toJson({"ok": "Completed OK", "inid": processed})
            writer.println(result)
            writer.close()
        else:
            writer = self.response.getPrintWriter("text/plain; charset=UTF-8")
            result = self.__toJson({"error": "No docx was uploaded"})
            writer.println(result)
            writer.close()

    def processdocx(self, inputfilepath):
        """
        Convert a docx to html format, and calling
        """

        zipFile = ZipFile(inputfilepath)
        entry = zipFile.getEntry("word/document.xml")
        stream = zipFile.getInputStream(entry)
        text = StreamSource(stream)

        factory = TransformerFactoryImpl()
        xslt = StreamSource(File(join(FascinatorHome.getPath(), "lib", "xslt", "docx2html.xsl")))
        transformer = factory.newTransformer(xslt)
        tf = "/tmp/%s.html" % uuid.uuid4()
        transformer.transform(text, StreamResult(File(tf)))
        parser = DocxHtmlParser()
        parser.init()
        f = open(tf, 'r')
        parser.feed(unescape(f.read()))
        f.close()
        try:
            remove(tf)
        except Exception, e:
            self.log.error("Failed to remove uploaded word file: %s." % tf)
            self.log.error(str(e))
        return parser.extracted

    def __check(self, path):
        # Has it been saved correctly and is docx?"
        try:
            if exists(path):
                ext = splitext(path)
                return ext[1] == '.docx'
            else:
                return False
        except Exception, e:
            self.log.error("Cannot check if file exists: %s" % str(e))
            return False

    def __toJson(self, dataDict):
        return JsonSimple(JsonObject(dataDict))
