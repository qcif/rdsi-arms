<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:d2h="http://www.github.com/rnathanday/docx2html"
    version="2.0">
    
    <d2h:font-map>
        <font name="Arial"                  fallback="sans-serif"/>
        <font name="Arial Narrow"           fallback="sans-serif"/>
        <font name="Arial Rounded MT Bold"  fallback="sans-serif"/>
        <font name="Arial Unicode MS"       fallback="sans-serif"/>
        <font name="Berlin Sans FB"         fallback="sans-serif"/>
        <font name="Berlin Sans FB Demi"    fallback="sans-serif"/>
        <font name="Calibri Light"          fallback="sans-serif"/>
        <font name="Gill Sans MT"           fallback="sans-serif"/>
        <font name="Gill Sans MT Condensed" fallback="sans-serif"/>
        <font name="Lucida Sans"            fallback="sans-serif"/>
        <font name="Lucida Sans Unicode"    fallback="sans-serif"/>
        <font name="Segoe UI"               fallback="sans-serif"/>
        <font name="Segoe UI Light"         fallback="sans-serif"/>
        <font name="Segoe UI Semibold"      fallback="sans-serif"/>
        <font name="Tahoma"                 fallback="sans-serif"/>
        <font name="Trebuchet MS"           fallback="sans-serif"/>
        <font name="Verdana"                fallback="sans-serif"/>
        
        <font name="Baskerville Old Face"   fallback="serif"/>
        <font name="Book Antiqua"           fallback="serif"/>
        <font name="Bookman Old Style"      fallback="serif"/>
        <font name="Californian FB"         fallback="serif"/>
        <font name="Cambria"                fallback="serif"/>
        <font name="Constantia"             fallback="serif"/>
        <font name="Garamond"               fallback="serif"/>
        <font name="Lucida Bright"          fallback="serif"/>
        <font name="Lucida Fax"             fallback="serif"/>
        <font name="Palatino Linotype"      fallback="serif"/>
        <font name="Times New Roman"        fallback="serif"/>
        <font name="Wide Latin"             fallback="serif"/>
    </d2h:font-map>
    
    <xsl:function name="d2h:font-fallback" as="xs:string*">
        <xsl:param name="font" as="xs:string"/>
        <xsl:variable 
            name="fallback" 
            select="document('')/xsl:stylesheet/d2h:font-map/font[@name=$font]/@fallback" 
            as="xs:string*"/>
        <xsl:choose>
            <xsl:when test="$fallback != ''">
                <xsl:value-of select="$fallback"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
</xsl:stylesheet>
