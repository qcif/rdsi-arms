<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:d2h="http://www.github.com/rnathanday/docx2html"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:ixsl="http://saxonica.com/ns/interactiveXSLT"
    exclude-result-prefixes="xs d2h ixsl"
    version="2.0">
    
    <xsl:function name="d2h:serialize-css-data" as="xs:string">
        <xsl:param name="style-data" as="element()*"/>

        <xsl:variable name="style-string" as="xs:string*">
            <xsl:choose>
                
                <xsl:when test="empty($style-data)">
                    <xsl:value-of select="''"/>
                </xsl:when>
    
                <xsl:otherwise>
                        
                    <xsl:for-each select="$style-data">
                        <xsl:variable name="current-record" select="." as="element()"/>
                        <xsl:variable name="class-name" select="$current-record/@class" as="xs:string"/>
                        <xsl:variable name="props" select="
                                for $p in $current-record/prop
                                return concat(
                                     '&#x0009;'
                                    , $p/@name
                                    , ':'
                                    , string($p)
                                    , ';'
                                )
                        " as="xs:string*" />
                        <xsl:sequence select="concat(
                              '&#x000A;' 
                            , concat('.',$class-name)
                            , ' {'
                            , '&#x000A;'
                            , string-join($props, '&#x000A;')
                            , '&#x000A;'
                            , '}'
                        )"/>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="string-join($style-string, '')"/>
    </xsl:function>
    
    <xsl:function name="d2h:handle-styles" as="element(css)*">
        <xsl:param name="total" as="xs:integer"/>
        <xsl:param name="elts"   as="element()*"/>
        <xsl:param name="styles" as="element(css)*"/>
        
        <xsl:choose>
            <xsl:when test="empty($elts)">
                <xsl:sequence select="$styles"/>
            </xsl:when>
            
            <xsl:otherwise>
                <xsl:variable name="elt" select="$elts[1]" as="element()"/>
                <xsl:variable name="class-name" select="d2h:class-name($elt)"/>
                
                <xsl:variable name="props" as="element(prop)*">

                    <xsl:variable name="current-css" as="xs:string*">
                        <xsl:apply-templates select="$elt" mode="css"/>
                    </xsl:variable>

                    <!-- prepend css defaults, which will be applied if necessary -->
                    <xsl:sequence select="d2h:make-style-props(
                          $class-name
                        , $current-css
                    )"/>                    
                </xsl:variable>
                
                <xsl:variable name="updated-styles" as="element(css)*" 
                    select="d2h:add-style($styles, $class-name, $props)"/>
                
                <xsl:sequence select="d2h:handle-styles(
                      $total
                    , subsequence($elts, 2) 
                    , $updated-styles
                )"/>
                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
    
    <xsl:function name="d2h:make-style-props" as="element(prop)*">
        <xsl:param name="class-name" as="xs:string"/>
        <xsl:param name="current-css" as="xs:string*"/>

        <xsl:variable name="props" select="
            distinct-values(
                for $i in (1 to count($current-css))[. mod 2 = 1] 
                return $current-css[$i]
            )
        " as="xs:string*"/>

        <xsl:if test="not(empty($props))">
            <xsl:for-each select="$props">
                <xsl:variable name="prop" select="." as="xs:string"/>
                <!-- choose first occurrence, for precedence -->
                <xsl:variable name="val-ind" select="index-of($current-css,$prop)[1]" as="xs:integer"/>
                <prop name="{$prop}">
                    <xsl:value-of select="$current-css[$val-ind + 1]"/>
                </prop>
            </xsl:for-each>
        </xsl:if>
    </xsl:function>

    <xsl:function name="d2h:add-style" as="element(css)*">
        <xsl:param name="styles" as="element(css)*"/>
        <xsl:param name="class-name" as="xs:string"/>
        <xsl:param name="props" as="element(prop)*"/>
        
        <!-- find index of first style with matching properties -->
        <xsl:variable name="matched-style-ind" as="xs:integer*">
            <xsl:variable name="match" select="(
                for $i in 1 to count($styles)
                return
                    if (deep-equal($styles[$i]/prop, $props))
                    then $i
                    else ()
            )[1]" as="xs:integer?"/>
            <!--and ((self::prop except $props) = ())]-->
            <xsl:if test="not(empty($match))">
                <xsl:sequence select="$match"/>
            </xsl:if>            
        </xsl:variable>
 
        <xsl:variable name="new-style" as="element(css)">
            <xsl:choose>
                <xsl:when test="empty($matched-style-ind)">
                    <css class="{$class-name}">
                        <styles>
                            <style><xsl:value-of select="$class-name"/></style>
                        </styles>
                        <xsl:copy-of select="$props"/>
                    </css>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:variable name="style" select="$styles[$matched-style-ind]"/>
                    <css class="{$style/@class}">
                        <styles>
                            <xsl:copy-of select="$style/styles/*"/>
                            <style><xsl:value-of select="$class-name"/></style>
                        </styles>    
                        <xsl:copy-of select="$style/prop"/>
                    </css>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:sequence select="
            if (empty($matched-style-ind))
            then ($styles,$new-style)
            else (
                  subsequence($styles, 1, $matched-style-ind - 1)
                , $new-style
                , subsequence($styles, $matched-style-ind + 1)
            )
        "/>

    </xsl:function>

</xsl:stylesheet>