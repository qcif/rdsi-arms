<?xml version="1.0" encoding="UTF-8"?>
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

    <!-- public class HtmlConverterSettings -->
    <xsl:param name="css-path"                                  as="xs:string"  select="''"/>
    <xsl:param name="page-title"                                as="xs:string"  select="''"/>
    <xsl:param name="css-class-prefix"                          as="xs:string"  select="''"/>
    <xsl:param name="fabricate-css-classes"                     as="xs:string"  select="''"/>
    <xsl:param name="restrict-to-supported-languages"           as="xs:string"  select="''"/>
    <xsl:param name="restrict-to-supported-numbering-formats"   as="xs:string"  select="''"/>
    <xsl:param name="additional-css"                            as="xs:string"  select="''"/>
    <xsl:param name="anchor-target-blank"                       as="xs:string"  select="''"/>

    <xsl:variable name="settings.page-title"                                as="xs:string"  select="$page-title"/>
    <xsl:variable name="settings.css-class-prefix"                          as="xs:string"  select="$css-class-prefix"/>
    <xsl:variable name="settings.fabricate-css-classes"                     as="xs:boolean"  select="boolean($fabricate-css-classes)"/>
    
    <xsl:variable name="settings.restrict-to-supported-languages"           as="xs:boolean" select="boolean($restrict-to-supported-languages)"/>
    <xsl:variable name="settings.restrict-to-supported-numbering-formats"   as="xs:boolean" select="boolean($restrict-to-supported-numbering-formats)"/>
    <xsl:variable name="settings.additional-css"                            as="xs:string"  select="''"/>
    
    <!-- other used settings -->
    <xsl:variable name="settings.css-path"                               as="xs:string?"  select="$css-path"/>
    <xsl:variable name="settings.suppress-trailing-whitespace"           as="xs:boolean" select="false()"/>
    <xsl:variable name="settings.generator-name"                         as="xs:string"  select="'XSLT 2.0 for (X)HTML'"/>
    <xsl:variable name="settings.anchor-target-blank"                    as="xs:boolean" select="boolean($anchor-target-blank)"/>

</xsl:stylesheet>
