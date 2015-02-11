<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:d2h="http://www.github.com/rnathanday/docx2html"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    exclude-result-prefixes="xs"
    version="2.0">    
    
    <xsl:function name="d2h:serialized-class-name" as="xs:string">
        <xsl:param name="elt" as="element()"/>
        <xsl:param name="css-data" as="element(css)*"/>
        <xsl:variable name="raw-name" select="d2h:class-name($elt)" as="xs:string"/>
        <xsl:value-of select="($css-data[styles/style=$raw-name]/@class, $raw-name)[1]"/>
    </xsl:function>
    
    <xsl:function name="d2h:class-name" as="xs:string">
        <xsl:param name="elt" as="element()"/>
        <xsl:variable name="style-name" as="xs:string?">
            <xsl:choose>
                <!-- css selector: class -->
                <xsl:when test="name($elt) = 'w:p'">
                    <xsl:variable name="base-class" select="string($elt/w:pPr/w:pStyle/@w:val)"/>
                    <xsl:value-of select="d2h:build-class-name(
                          $elt
                        , $base-class
                        , $default-paragraph-style
                        , count($elt/preceding::w:p[not(w:pPr/w:pStyle/@w:val)])
                        , count($elt/preceding::w:p[w:pPr/w:pStyle[@w:val=$base-class]])
                    )"/>
                </xsl:when>
                <!-- css selector: id -->
                <xsl:when test="name($elt) = 'w:r'">
                    <xsl:variable name="base-class" select="string($elt/w:rPr/w:rStyle/@w:val)"/>
                    <xsl:value-of select="d2h:build-class-name(
                          $elt 
                        , $base-class
                        , $default-character-style
                        , count($elt/preceding::w:r[not(w:rPr/w:rStyle/@w:val)])
                        , count($elt/preceding::w:r[w:rPr/w:rStyle[@w:val=$base-class]])
                    )"/>
                </xsl:when>
                <xsl:when test="name($elt) = 'w:tbl'">
                    <xsl:variable name="base-class" select="string($elt/w:tblPr/w:tblStyle/@w:val)"/>
                    <xsl:value-of select="d2h:build-class-name(
                          $elt
                        , $base-class
                        , $default-table-style
                        , count($elt/preceding::w:tbl[not(w:tblPr/w:tblStyle/@w:val)])
                        , count($elt/preceding::w:tbl[w:tblPr/w:tblStyle[@w:val=$base-class]])
                    )"/>
                </xsl:when>
                <xsl:when test="name($elt) = 'w:tr'">
                    <xsl:variable name="base-class" select="'tr'"/>
                    <xsl:value-of select="d2h:build-class-name(
                        $elt
                        , $base-class
                        , $default-table-style
                        , count($elt/preceding::w:tr)
                        , count($elt/preceding::w:tr)
                    )"/>
                </xsl:when>
                <xsl:when test="name($elt) = 'w:tc'">
                    <xsl:variable name="base-class" select="'td'"/>
                    <xsl:value-of select="d2h:build-class-name(
                        $elt
                        , $base-class
                        , $default-table-style
                        , count($elt/preceding::w:tc)
                        , count($elt/preceding::w:tc)
                    )"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:message terminate="yes" select="concat('Unsupported element in d2h:class-name(): ', name($elt))"/>
                </xsl:otherwise>                
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat(
            $settings.css-class-prefix, 
            $style-name
        )"/>
    </xsl:function>

    <xsl:function name="d2h:build-class-name" as="xs:string">
        <xsl:param name="elt"                       as="element()"/>
        <xsl:param name="base-class"                as="xs:string?"/>
        <xsl:param name="default-style"             as="xs:string"/>
        <xsl:param name="preceding-count-no-base"   as="xs:integer"/>
        <xsl:param name="preceding-count-with-base" as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="empty($base-class) or $base-class = ''">
                <xsl:choose>
                    <xsl:when test="$preceding-count-no-base = 0">
                        <xsl:value-of select="$default-style"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(
                              $default-style
                            , '-'
                            , format-number($preceding-count-no-base, '000000')
                        )"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>            
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$preceding-count-with-base = 0">
                        <xsl:value-of select="$base-class"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(
                              $base-class 
                            , '-'
                            , format-number($preceding-count-with-base, '000000')
                        )"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>        
    </xsl:function>    

</xsl:stylesheet>