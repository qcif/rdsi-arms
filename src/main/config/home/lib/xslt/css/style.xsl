<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:d2h="http://www.github.com/rnathanday/docx2html"
    exclude-result-prefixes="xs d2h" version="2.0">

    <xsl:template match="@*|node()" mode="css" priority="-1"/>

    <xsl:template match="w:style[@w:type='paragraph']" mode="css">
        <xsl:apply-templates mode="css"/>
        <!-- defaults -->
        <xsl:apply-templates
            select="$style-document/w:styles/w:docDefaults/w:pPrDefault/w:pPr"
            mode="css"/>
    </xsl:template>

    <xsl:template match="w:style[@w:type='character']" mode="css">
        <xsl:apply-templates mode="css"/>
        <!-- defaults -->
        <xsl:apply-templates
            select="$style-document/w:styles/w:docDefaults/w:rPrDefault/w:rPr"
            mode="css"/>
    </xsl:template>

    <xsl:template match="w:style[@w:type='table']" mode="css">
        <xsl:apply-templates mode="css"/>
        <!-- defaults -->
        <xsl:apply-templates
            select="$style-document/w:styles/w:style[@w:type='table'][@w:default='1']/*"
            mode="css"/>
    </xsl:template>

    <xsl:template match="w:style/w:pPr | w:pPrDefault/w:pPr | w:style/w:tblPr" mode="css">
        <xsl:apply-templates mode="css"/>
    </xsl:template>

    <xsl:function name="d2h:make-style-props" as="element(style)?">
        <xsl:param name="elt" as="element()?"/>
        <xsl:if test="not(empty($elt))">
            <xsl:variable name="id" select="string($elt/@w:styleId)"/>
            <xsl:variable name="props" as="xs:string*">
                <xsl:apply-templates select="$elt" mode="css"/>
            </xsl:variable>
            <style id="{$id}">
                <xsl:if test="count($props) &gt; 0">
                    <xsl:for-each select="0 to xs:integer(count($props) div 2) - 1">
                        <xsl:variable name="i" select="2 * xs:integer(.) + 1" as="xs:integer"/>
                        <prop name="{$props[$i]}" val="{$props[$i+1]}"/>
                    </xsl:for-each>
                </xsl:if>
            </style>
        </xsl:if>
    </xsl:function>

</xsl:stylesheet>
