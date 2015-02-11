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

    <!-- TODO: update -->
    <xsl:variable name="base-dir" select="replace(document-uri(/), '/[^/]+$', '')" as="xs:string"/>
    
    <!-- assumes styles.xml is in same directory as dirname(document-uri())-->
    <xsl:variable name="style-member"   select="'word/styles.xml'"                                  as="xs:string"/>
    <xsl:variable name="style-path"     select="concat($base-dir, '/', 'styles.xml')"               as="xs:string"/>
    <xsl:variable name="rels-memeber"   select="'word/_rels/document.xml.rels'"                     as="xs:string"/>
    <xsl:variable name="rels-path"      select="concat($base-dir, '/', '_rels/document.xml.rels')"  as="xs:string"/>
    
    <xsl:variable name="outline-level-default" select="9" as="xs:integer"/>

    <xsl:variable name="css-number-format" select="'#.###'" as="xs:string"/>

    <xsl:variable name="rels-document" as="document-node()?">
        <xsl:choose>
            <xsl:when test="system-property('xsl:product-name') = 'Saxon-CE'">
                <xsl:sequence select="d2h:resolve-document($rels-memeber)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="d2h:resolve-document($rels-path)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:variable name="style-document" as="document-node()?">
        <xsl:variable name="doc">
            <xsl:choose>
                <xsl:when test="system-property('xsl:product-name') = 'Saxon-CE'">
                    <xsl:sequence select="d2h:resolve-document($style-member)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="d2h:resolve-document($style-path)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$settings.fabricate-css-classes and empty($doc)">
            <xsl:message terminate="yes">
                <xsl:text>Style document unavailable.</xsl:text>
            </xsl:message>
        </xsl:if>
        <xsl:sequence select="$doc"/>
    </xsl:variable>

     <xsl:variable name="default-character-style" as="xs:string">
        <xsl:choose>
            <xsl:when test="$settings.fabricate-css-classes">
                <xsl:value-of select="$style-document/w:styles/w:style[@w:type='character'][@w:default='1']/@w:styleId"/>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'char-style'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="default-paragraph-style" as="xs:string">
        <xsl:choose>
            <xsl:when test="$settings.fabricate-css-classes">
                <xsl:value-of select="$style-document/w:styles/w:style[@w:type='paragraph'][@w:default='1']/@w:styleId"/>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'para-style'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="default-table-style" as="xs:string">
        <xsl:choose>
            <xsl:when test="$settings.fabricate-css-classes">
                <xsl:value-of select="$style-document/w:styles/w:style[@w:type='table'][@w:default='1']/@w:styleId"/>                
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'table-style'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="css-data" as="element(css)*">
        <xsl:if test="$settings.fabricate-css-classes">
            <xsl:variable name="nodes" select="(//w:p | //w:r | //w:tbl | //w:tr | //w:tc)" as="element()*"/>
            <xsl:variable name="total" select="count($nodes)" as="xs:integer"/>
            <xsl:sequence select="d2h:handle-styles(
                    $total
                  , $nodes
                  , ()
             )"/>
        </xsl:if>        
    </xsl:variable>
            
    <xsl:variable name="outline-levels" as="xs:integer*">
        <xsl:for-each select="//w:body/*">
            <xsl:sequence select="d2h:outline-level(.)"/>
        </xsl:for-each>
    </xsl:variable>
    
</xsl:stylesheet>
