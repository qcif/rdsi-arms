<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:d2h="http://www.github.com/rnathanday/docx2html"
    exclude-result-prefixes="xs d2h w"
    version="2.0">
    
    <xsl:template match="w:tbl">
        <!-- TODO: these style properties are "add if missing" -->
        <table border="1" cellspacing="0" cellpadding="0">
            
            <xsl:if test="$settings.fabricate-css-classes">
                <xsl:attribute name="class">
                    <xsl:value-of select="d2h:serialized-class-name(.,$css-data)"/>
                </xsl:attribute>
            </xsl:if>
            
<!--            <xsl:if test="w:tblPr/w:bidiVisual">
                <xsl:attribute name="dir">rtl</xsl:attribute>
            </xsl:if>            -->
            <xsl:apply-templates/>
        </table>
    </xsl:template>
    
    <xsl:template match="w:tr">
        <tr>
            <xsl:if test="$settings.fabricate-css-classes">
                <xsl:attribute name="class">
                    <xsl:value-of select="d2h:serialized-class-name(.,$css-data)"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </tr>
    </xsl:template>
    
    
    <!-- 
    if (tcPr.Element(W.vMerge) != null && (string)tcPr.Elements(W.vMerge).Attributes(W.val).FirstOrDefault() != "restart")
    return null;
    -->
    <xsl:template match="w:tc[w:tcPr/w:vMerge/@w:val != 'restart']"/>
    
    <xsl:template match="w:tc">
        <td>            
            <xsl:if test="$settings.fabricate-css-classes">
                <xsl:attribute name="class">
                    <xsl:value-of select="d2h:serialized-class-name(.,$css-data)"/>
                </xsl:attribute>
            </xsl:if>
            
            <!-- @rowspan -->
            <xsl:if test="w:tcPr/w:vMerge/@w:val = 'restart'">
                <xsl:attribute name="rowspan">
                    <xsl:variable name="table" select="ancestor::w:tbl"/>
                    <xsl:variable name="current-row" select="count(parent::w:tr/preceding-sibling::w:tr)+1"/>
                    <xsl:variable name="current-cell" select="count(preceding-sibling::w:tc)"/>
                    <xsl:variable name="row-span-count" select="1"/>
                    <xsl:value-of select="string(d2h:row-span-count($table, $current-row, $current-cell, $row-span-count))"/>
                </xsl:attribute>
            </xsl:if>
            
            <!-- @colspan -->
            <xsl:if test="w:tcPr/w:gridSpan/@w:val">
                <xsl:attribute name="colspan">
                    <xsl:value-of select="string(xs:integer(w:tcPr/w:gridSpan/@w:val))"/>
                </xsl:attribute>
            </xsl:if>
            
            <xsl:apply-templates/>
        </td>
    </xsl:template>

    <xsl:function name="d2h:row-span-count" as="xs:integer">
        <xsl:param name="table" as="element()"/>
        <xsl:param name="current-row" as="xs:integer"/>
        <xsl:param name="current-cell" as="xs:integer"/>
        <xsl:param name="row-span-count" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="not($table//w:tr[$current-row])">
                <xsl:sequence select="$row-span-count"/>
            </xsl:when>
            <xsl:when test="not($table//w:tr[$current-row]/w:tc[$current-cell])">
                <xsl:sequence select="$row-span-count"/>
            </xsl:when>
            <xsl:when test="$table//w:tr[$current-row]/w:tc[$current-cell]/w:tcPr/w:vMerge/@w:val='restart'">
                <xsl:sequence select="$row-span-count"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="d2h:row-span-count($table, $current-row + 1, $current-cell, $row-span-count + 1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>