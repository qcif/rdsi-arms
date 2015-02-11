<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:d2h="http://www.github.com/rnathanday/docx2html"
    xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    exclude-result-prefixes="xs w d2h ixsl"
    version="2.0">
    
    <!-- return index of the first element with an equal or lesser value -->
    <xsl:function name="d2h:next-equal-below" as="xs:integer?">
        <xsl:param name="val" as="xs:integer"/>
        <xsl:param name="seq" as="xs:integer*"/>
        <xsl:sequence select="(
            for $i in 1 to count($seq)
            return
                if   ($seq[$i] &lt;= $val)
                then ($i)
                else ()
            )[1]
        "/>
    </xsl:function>
    
    <xsl:function name="d2h:get-bool-prop" as="xs:boolean">
        <xsl:param name="att" as="attribute()*"/>
        <xsl:variable name="val" as="xs:string*">
            <xsl:if test="not(empty($att))">
                <xsl:value-of select="string($att)"/>
            </xsl:if>
        </xsl:variable>
        <xsl:choose>
            <!-- <w:b/> is true -->
            <xsl:when test="empty($val)">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$val = ''">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:when test="$val = '0' or $val = 'false'">
                <xsl:sequence select="false()"/>
            </xsl:when>
            <xsl:when test="$val = '1' or $val = 'true'">
                <xsl:sequence select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="d2h:resolve-document" as="document-node()*">
        <xsl:param name="path"/>
        <xsl:choose>
            <xsl:when test="system-property('xsl:product-name') = 'Saxon-CE'">
                <xsl:sequence 
                    select="ixsl:call(ixsl:window(), 'getMemberFileXML', $path)" 
                    use-when="system-property('xsl:product-name') = 'Saxon-CE'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="doc-available($path)">
                        <xsl:sequence select="doc($path)"
                            use-when="system-property('xsl:product-name') != 'Saxon-CE'"/>                        
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message select="concat('Failed to resolve document at: ', $path)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="d2h:resolve-unparsed-document" as="xs:string?">
        <xsl:param name="path"/>
        <xsl:choose>
            <xsl:when test="system-property('xsl:product-name') = 'Saxon-CE'">
                <xsl:sequence 
                    select="ixsl:call(ixsl:window(), 'getMemberFileBytes', $path)" 
                    use-when="system-property('xsl:product-name') = 'Saxon-CE'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="''"/>
                <!--
                <xsl:if test="unparsed-text-available($path)">
                    <xsl:sequence select="unparsed-text($path)"/>
                </xsl:if>
                -->
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="d2h:outline-level" as="xs:integer">
        <xsl:param name="elt" as="element()"/>
        <xsl:variable name="key">
            <xsl:choose>
                <xsl:when test="$elt/w:pPr/w:outlineLvl">
                    <xsl:sequence select="xs:integer($elt/w:pPr/w:outlineLvl/@w:val)"/>
                </xsl:when>
                <xsl:when test="$elt/w:pPr/w:pStyle">
                    <xsl:variable name="id" select="$elt/w:pPr/w:pStyle/@w:val" as="xs:string"/>
                    <xsl:sequence select="
                        (xs:integer($style-document/w:styles/w:style[@w:styleId=$id]/w:pPr/w:outlineLvl/@w:val),$outline-level-default)[1]
                        "/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$outline-level-default"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="$key"/>
    </xsl:function>
 
    <xsl:function name="d2h:repeat-string" as="xs:string">
        <xsl:param name="base"/>
        <xsl:param name="repeater" as="xs:string"/>
        <xsl:param name="count" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$count = 0">
                <xsl:value-of select="''"/>
            </xsl:when>
            <xsl:when test="$count = 1">
                <xsl:value-of select="concat($base,$repeater)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="d2h:repeat-string(concat($base,$repeater), $repeater, $count - 1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
 
</xsl:stylesheet>