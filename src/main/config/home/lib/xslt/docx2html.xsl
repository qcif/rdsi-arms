<?xml version="1.0" encoding="UTF-8"?>
<!--
docx2html.xsl

XSLT 2.0 stylesheet to convert a docx archive's 'word/document.xml'
file to HTML. Optionally includes CSS stylesheet data from the archive's
'word/styles.xml' file.

The development of these stylesheets has leaned heavily upon the 
C# code in the "PowerTools for Open XML" project, and may still include
snippets of that code for reference.

The license for the project containing the file HtmlConverter.cs (which
was found at http://powertools.codeplex.com/) is included in this 
repository. The copyright notice from HtmlConverter.cs is as follows:

/***************************************************************************

Copyright (c) Microsoft Corporation 2012-2014.

This code is licensed using the Microsoft Public License (Ms-PL).  The text of the license can be found here:

http://www.microsoft.com/resources/sharedsource/licensingbasics/publiclicense.mspx

Published at http://OpenXmlDeveloper.org
Resource Center and Documentation: http://openxmldeveloper.org/wiki/w/wiki/powertools-for-open-xml.aspx

Developer: Eric White
Blog: http://www.ericwhite.com
Twitter: @EricWhiteDev
Email: eric@ericwhite.com
***************************************************************************/
-->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:pr="http://schemas.openxmlformats.org/package/2006/relationships"
    xmlns:pt="http://powertools.codeplex.com/2011"
    xmlns:d2h="http://www.github.com/rnathanday/docx2html"
    xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
    extension-element-prefixes="ixsl"
    exclude-result-prefixes="xs pt w r pr d2h ixsl"
    version="2.0">

    <xsl:include href="params.xsl"/>
    <xsl:include href="variables.xsl"/>
    <xsl:include href="body/util.xsl"/>
    <xsl:include href="body/table.xsl"/>
    <xsl:include href="char/entity-map.xsl"/>
    <xsl:include href="css/serialize.xsl"/>
    <xsl:include href="css/style.xsl"/>
    <xsl:include href="css/p.xsl"/>
    <xsl:include href="css/r.xsl"/>
    <xsl:include href="css/font.xsl"/>
    <xsl:include href="css/class.xsl"/>
    <xsl:include href="css/table.xsl"/>
    <xsl:include href="graphics/image.xsl"/>
    
    <xsl:output 
        doctype-system="about:legacy-compat"
        method="html" 
        encoding="UTF-8"
        indent="yes"
        omit-xml-declaration="yes"
        use-character-maps="html-entity-map private-entity-map"
    />
    
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="w:document">
        <html>
            <head>
                <meta charset="utf-8"></meta>
                <meta name="Generator" content="{$settings.generator-name}"></meta>
                <!--
                <xsl:if test="not(empty($settings.page-title)) and ($settings.page-title != '')">
                    <title><xsl:value-of select="$settings.page-title"/></title>
                </xsl:if>
                -->
                <xsl:call-template name="output-css"/>
            </head>
            <xsl:apply-templates/>
        </html>
    </xsl:template>
    
    <!-- output <style> element or stylesheet.css for css data -->
    <xsl:template name="output-css">
        <xsl:if test="not(empty($css-data))">
            <xsl:choose>
                <xsl:when test="$settings.css-path != ''">
                    <xsl:result-document method="text" href="{$settings.css-path}">
                        <xsl:value-of select="d2h:serialize-css-data($css-data)"/>
                    </xsl:result-document>
                    <link rel="stylesheet" type="text/css" href="{$settings.css-path}"></link>
                </xsl:when>
                <xsl:otherwise>
                    <style type="text/css">
                        <xsl:value-of select="d2h:serialize-css-data($css-data)"/>
                    </style>    
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
    </xsl:template>

    <xsl:template match="w:body">
        <body>
            <xsl:call-template name="handle-body-elts">
                <xsl:with-param name="elt" select="*[1]"/>
                <xsl:with-param name="ind" select="1"/>
                <xsl:with-param name="max" select="count($outline-levels)"/>
            </xsl:call-template>
        </body>
    </xsl:template>
    
    <!-- handle child elements of w:body -->
    <xsl:template name="handle-body-elts">
        <xsl:param name="elt" as="element()*"/>
        <xsl:param name="ind" as="xs:integer"/>
        <xsl:param name="max" as="xs:integer"/>
        <xsl:variable name="outline-level" select="$outline-levels[$ind]"/>
                
        <!-- handle next $elt -->
        <xsl:choose>
            
            <!-- bottom out -->
            <xsl:when test="empty($elt) or empty($ind) or $ind &gt; $max"/>
            
            <xsl:otherwise>
                
                <!-- index for next call to this template; relative to $ind -->
                <xsl:variable name="next-ind" as="xs:integer*">
                    <xsl:choose>
                        <!-- for headings, the sibling with a lesser or equal outline level -->
                        <xsl:when test="name($elt) = 'w:p' and ($outline-level &lt; $outline-level-default)">
                            <xsl:sequence select="d2h:next-equal-below($outline-level,subsequence($outline-levels,$ind+1))"/>
                        </xsl:when>
                        <!-- for w:p and w:tbl, the following sibling -->
                        <xsl:otherwise>
                            <xsl:sequence select="1"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                
                <xsl:choose>

                    <!-- handle a heading/paragraph w:p -->
                    <xsl:when test="name($elt) = 'w:p'">
                        <xsl:choose>

                            <!-- handle a heading -->
                            <xsl:when test="$outline-level &lt; $outline-level-default">
                                <xsl:call-template name="handle-heading">
                                    <xsl:with-param name="elt" select="$elt"/>
                                    <xsl:with-param name="ind" select="$ind"/>
                                    <xsl:with-param name="max" select="$ind + $next-ind - 1"/>
                                    <xsl:with-param name="outline-level" select="$outline-level"/>
                                </xsl:call-template>
                            </xsl:when>
                            
                            <!-- handle a w:p body paragraph -->
                            <xsl:otherwise>
                                <xsl:apply-templates select="$elt"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        
                    </xsl:when>
                    
                    <!-- have w:tbl handled by its template -->
                    <xsl:otherwise>
                        <xsl:apply-templates select="$elt"/>
                    </xsl:otherwise>
                    
                </xsl:choose>

                <!-- handle succeeding element -->
                <xsl:if test="not(empty($next-ind))">
                    <xsl:call-template name="handle-body-elts">
                        <xsl:with-param name="elt" select="$elt/following-sibling::*[$next-ind]"/>
                        <xsl:with-param name="ind" select="$ind + $next-ind"/>
                        <xsl:with-param name="max" select="$max"/>
                    </xsl:call-template>
                </xsl:if>
                
            </xsl:otherwise>
            
        </xsl:choose>
    </xsl:template>
        
    <!-- handle a w:p heading paragraph -->
    <xsl:template name="handle-heading">
        <xsl:param name="elt" as="element()*"/>
        <xsl:param name="ind" as="xs:integer"/>
        <xsl:param name="max" as="xs:integer?"/>
        <xsl:param name="outline-level" as="xs:integer"/>
        
        <div>
            <xsl:apply-templates select="$elt"/>
            <xsl:if test="not(empty($max)) and $max &gt; $ind">
                <xsl:call-template name="handle-body-elts">
                    <xsl:with-param name="elt" select="$elt/following-sibling::*[1]"/>
                    <xsl:with-param name="ind" select="$ind + 1"/>                        
                    <xsl:with-param name="max" select="$max"/>
                </xsl:call-template>
            </xsl:if>
        </div>

    </xsl:template>
        
    <xsl:template match="w:p">
        <xsl:variable name="elt" select="." as="element(w:p)"/>
        <xsl:variable name="outline-level" select="$outline-levels[count($elt/preceding-sibling::*)+1]"/>

        <xsl:variable name="name" as="xs:string">
            <xsl:choose>
                <xsl:when test="$outline-level &lt; $outline-level-default">
                    <xsl:value-of select="concat('h', string($outline-level + 1))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'p'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:element name="{$name}">
        
            <xsl:if test="$settings.fabricate-css-classes">
                <xsl:attribute name="class">
                    <xsl:value-of select="d2h:serialized-class-name($elt,$css-data)"/>
                </xsl:attribute>
            </xsl:if>
            
            <xsl:choose>
                <!-- per HTMLConverter.cs, w:p wihtout any runs get an nbsp -->
                <xsl:when test="not(descendant::w:r)">
                    <xsl:text>&#x00A0;</xsl:text>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
            
        </xsl:element>
    </xsl:template>

    <xsl:template match="w:hyperlink[@r:id]">
        <!-- _rels/document.xml.rels -->
        <xsl:variable name="href" 
            select="$rels-document/pr:Relationships/pr:Relationship[@Id=current()/@r:id]/@Target"/>
        <a href="{$href}">
            <xsl:if test="$settings.anchor-target-blank">
                <xsl:attribute name="target">_blank</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="w:hyperlink[@w:anchor]">
        <a style="text-decoration:none" href="#{@w:anchor}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="w:r">
        <xsl:choose>
            <xsl:when test="w:rPr/w:webHidden"/>
            
            <xsl:when test="not(w:rPr)">
                <xsl:apply-templates select="child::*"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:variable name="default-lang" select="'en-US'"/>
                <xsl:variable name="lang">
                    <xsl:choose>
                        <xsl:when test="w:rPr/w:lang/@w:val">
                            <xsl:value-of select="w:rPr/w:lang/@w:val"/>
                        </xsl:when>
                        <xsl:when test="pt:languageType = 'western'">
                            <xsl:value-of select="w:lang/@w:val"/>
                        </xsl:when>
                        <xsl:when test="pt:languageType = 'bidi'">
                            <xsl:value-of select="w:lang/@w:bidi"/>
                        </xsl:when>
                        <xsl:when test="pt:languageType = 'eastAsia'">
                            <xsl:value-of select="w:lang/@w:eastAsia"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$default-lang"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <!--<xsl:if test="not(empty($style)) or @w:rtl or ($lang != '' and $lang != $default-lang)">-->
                    <span>
                        <xsl:if test="$lang != $default-lang">
                            <xsl:attribute name="lang">
                                <xsl:value-of select="$lang"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="w:rtl">
                            <xsl:attribute name="dir">
                                <xsl:text>rtl</xsl:text>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:if test="$settings.fabricate-css-classes">
                            <xsl:attribute name="class">
                                <xsl:value-of select="d2h:serialized-class-name(.,$css-data)"/>
                            </xsl:attribute>
                        </xsl:if>
                        <xsl:apply-templates/>
                    </span>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:template>

    <xsl:template match="w:bookmarkStart[not(@w:name) or @w:name = '']"/>
    <xsl:template match="w:bookmarkStart[@w:name != '']">
        <a id="{@w:name}" style="text-decoration:none"></a>
    </xsl:template>

    <xsl:template match="w:t">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:function name="d2h:calc-width-of-run-in-twips" as="xs:integer">
        <xsl:param name="wr" as="element(w:r)"/>
        <!-- TODO: fix -->
        <xsl:sequence select="0"/>
    </xsl:function>
        
    <xsl:function name="d2h:leader-val" as="xs:string">
        <xsl:param name="wtab" as="element(w:tab)"/>
        <xsl:param name="tab-width" as="xs:integer"/>
        <xsl:variable name="leader-char">
            <!--
            <xsl:choose>
                <xsl:when test="$wtab/pt:leader = 'hyphen'">
                    <xsl:text>-</xsl:text>
                </xsl:when>
                <xsl:when test="$wtab/pt:leader = 'dot'">
                    <xsl:text>.</xsl:text>
                </xsl:when>
                <xsl:when test="$wtab/pt:leader = 'underscore'">
                    <xsl:text>_</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>.</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
            -->
        </xsl:variable>
        <xsl:variable name="font-name">
            <!--
            <xsl:value-of select="$wtab/ancestor::w:r/pt:FontName or $wtab/ancestor::w:p/pt:FontName"/>
            -->
        </xsl:variable>
        <xsl:variable name="number-of-leader-chars" as="xs:integer">
            <xsl:variable name="width-of-leader-char" select="d2h:calc-width-of-run-in-twips($wtab/ancestor::w:r)"/>
            <xsl:choose>
                <xsl:when test="$width-of-leader-char != 0">
                    <xsl:variable name="possible-val" select="floor(($tab-width * 1440) div $width-of-leader-char)"/>
                    <xsl:choose>
                        <xsl:when test="$possible-val &lt; 0">
                            <xsl:sequence select="0"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="$possible-val"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="0"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="d2h:repeat-string('',$leader-char,$number-of-leader-chars)"/>
    </xsl:function>
    
    <!--<xsl:template match="w:tab[@pt:tabWidth][@pt:leader]">-->
    <xsl:template match="w:tab">
        <!--
            <xsl:variable name="wtab" select="." as="element(w:tab)"/>
            <xsl:variable name="tab-width" select="@pt:tabWidth"/>
        -->
        <!--
        <xsl:variable name="tab-width" select="0"/>
        <xsl:variable name="leader-val" select="d2h:leader-val($wtab, $tab-width)"/>
        <span>
            
            <xsl:choose>
                <xsl:when test="$leader-val != ''">
                    <xsl:attribute name="style">
                        <xsl:value-of select="string-join((
                            'margin: 0 0 0 0',
                            'padding: 0 0 0 0',
                            concat('width: ',$tab-width, 'in'),
                            'text-align: center'
                            ), '; ')"/>
                    </xsl:attribute>
                    <xsl:value-of select="$leader-val"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="style">
                        <xsl:value-of select="string-join((
                            concat('margin: ',$tab-width, 'in'),
                            'padding: 0 0 0 0'
                            ), '; ')"/>
                    </xsl:attribute>
                </xsl:otherwise>
            </xsl:choose>
            
        </span>
        -->
    </xsl:template>

    <!-- <xsl:template match="w:tab[@pt:tabWidth]">
    <xsl:template match="w:tab">
        <span>
            <xsl:attribute name="style">
                <!- - 
                var tabWidthAtt = element.Attribute(PtOpenXml.pt + "tabWidth");
                NOTE pt:*
                - ->
                <xsl:variable name="margin" select="concat('margin: 0 0 0 ', @tabWidth, 'in')"/>
                <xsl:variable name="padding" select="'padding: 0 0 0 0'"/>
                <xsl:value-of select="string-join(($margin, $padding), ';')"></xsl:value-of>
            </xsl:attribute>            
        </span>
    </xsl:template>
    -->

    <xsl:template match="w:br | w:cr"> 
        <br></br>
        <xsl:if test="@tabWidth">
            <span style="margin:0 0 0 {@tabWidth}in; padding:0 0 0 0">
            </span>            
        </xsl:if>
    </xsl:template>

    <xsl:template match="w:noBreakHyphen">
        <xsl:text>-</xsl:text>
    </xsl:template>

    <!--
        var relevantAncestors = element.Ancestors().TakeWhile(a => a.Name != W.txbxContent);
        var isRunLevelContentControl = relevantAncestors.Any(a => a.Name == W.p);
        if (isRunLevelContentControl)
    -->
    <xsl:template match="w:sdt[ancestor::w:p]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="w:sdt">
        <!--
            var o = CreateBorderDivs(wordDoc, settings, element.Element(W.sdtContent).Elements());
            return o;
        -->
    </xsl:template>

    <xsl:template match="w:smartTag">
        <!-- 
        var o = CreateBorderDivs(wordDoc, settings, element.Elements());
        return o;
        -->
    </xsl:template>

    <xsl:template match="w:instrText"/>


</xsl:stylesheet>
