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

#~ INPUTFILE = '/home/li/Downloads/list_form.docx'

from HTMLParser import HTMLParser

# https://wiki.python.org/moin/EscapingHtml
def unescape(s):
    s = s.replace("&lt;", "<")
    s = s.replace("&gt;", ">")
    # this has to be last:
    s = s.replace("&amp;", "&")
    return s


class DocxHtmlParser(HTMLParser):
    """ Assume spans appear in pairs no matter how far they are separted:
        <p><span>Name: </span></p>
        <p><span>some one</span></p>
        <p><span>Unit: </span></p>
        <p><span>some dep</span></p>
    """
    def init(self):
        self.jobj = {}
        self.current_tag = None
        self.current_key = None
        self.leading = False

    def handle_starttag(self, tag, attrs):
        #~ for attr in attrs:
            #~ print("     attr:", attr)
        if tag == "span":
            print "Encountered the beginning of a tag: %s tag" % tag
            self.current_tag = tag
            self.leading = not self.leading
        else:
            print "Encountered the not important beginning of a tag: %s" % tag

    def handle_data(self, data):
        #~ print("Data     :", data)
        d = data.strip()
        if d:
            print ("This is real: ", d)
            if self.current_tag == 'span':
                c = self.map2(d)
                if c in ["checked", "unchecked"]:
                    print "Do yes/no, radio buttons, checkboxes stuff, how many spans?"
                if self.leading:
                    self.current_key = d
                    #~ print "create key %s" % self.current_key
                    self.jobj[self.current_key] = ""
                else:
                    #~ print "save value [ %s ] to %s" % (data, self.current_key)
                    self.jobj[self.current_key] = d

    def map2(self, s):
        if s == "☐":
            print "mapped to unchecked, first"
            return "unchecked"
        elif s == "☒":
            print "mapped to checked, second"
            return "checked"
        else:
            return s


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
            print processed
            return

            #~ writer = self.response.getPrintWriter("text/html; charset=UTF-8")
            #~ result = self.dump2HTML(writer) #not working, why? not be used anyway
            #~ writer.flush()
            try:
                remove(uf)
            except Exception, e:
                self.log.error("Failed to remove uploaded word file: %s." % uf)
                self.log.error(str(e))
            writer = self.response.getPrintWriter("text/plain; charset=UTF-8")
            result = self.__toJson({"ok": "Completed OK","inid":processed})
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

        #~ inputfilepath = INPUTFILE
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
        return parser.jobj
        try:
            remove(tf)
        except Exception, e:
            self.log.error("Failed to remove uploaded word file: %s." % tf)
            self.log.error(str(e))
        return parser.jobj

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

    def dump2HTML(self, w):
        """
        Convert a docx to html and dump through writer, cannot dump, to be removed
        """
        try:
            inputfilepath = INPUTFILE
            zipFile = ZipFile(inputfilepath)
            entry = zipFile.getEntry("word/document.xml")
            stream = zipFile.getInputStream(entry)
            text = StreamSource(stream)

            factory = TransformerFactoryImpl()
            xslt = StreamSource(File(join(FascinatorHome.getPath(), "lib", "xslt", "docx2html.xsl")))
            transformer = factory.newTransformer(xslt)
            transformer.transform(text, StreamResult(w))
            print w.toString()
            return "OK"
        except Exception, e:
            self.log.error("Dump failed: %s" % str(e))
            return str(e)