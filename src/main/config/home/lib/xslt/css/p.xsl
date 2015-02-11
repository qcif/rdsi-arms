<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:d2h="http://www.github.com/rnathanday/docx2html"
    exclude-result-prefixes="xs d2h" version="2.0">

<!--
CreateStyleFromShd(style, pPr.Element(W.shd));
-->

    <xsl:variable name="default-para-style-props" as="element(style)?">
        <xsl:sequence select="d2h:make-style-props($style-document/w:styles/w:style[@w:type='paragraph'][@w:default='1'])"/>
    </xsl:variable>

    <xsl:variable name="para-style-props" as="element(styles)">
        <styles>
            <xsl:for-each select="$style-document/w:styles/w:style[@w:type='paragraph']">
                <xsl:sequence select="d2h:make-style-props(.)"/>
            </xsl:for-each>
        </styles>
    </xsl:variable>
    
    <xsl:template match="w:p" mode="css">
        <xsl:apply-templates select="w:pPr" mode="css"/>
        
        <!-- paragraph defaults, after w:pPr for precedence -->
        <xsl:sequence select="
             'margin-top',    '0pt'
            ,'margin-bottom', '0pt'
            ,'margin-left',   '0pt'
            ,'margin-right',  '0pt'
        "/>
    </xsl:template>

    <xsl:template match="w:pPr" mode="css" as="xs:string*">
        <xsl:apply-templates select="child::*[not(self::w:pStyle)]" mode="css"/>
        <xsl:variable name="id" select="string(w:pStyle/@w:val)" as="xs:string"/>
        <xsl:sequence select="
            for $prop in ($para-style-props/style[@id = $id], $default-para-style-props)[1]/prop
            return (string($prop/@name), string($prop/@val))
        "/>
    </xsl:template>

    <xsl:template match="w:pPr/w:pStyle" mode="css">
        <xsl:variable name="val" select="@w:val"/>
        <xsl:apply-templates
            select="$style-document/w:styles/w:style[@w:styleId=$val]"
            mode="css"/>
    </xsl:template>

    <xsl:template match="w:pPr/w:rPr" mode="css">
        <xsl:apply-templates mode="css"/>
    </xsl:template>

    <xsl:template match="w:pPr/w:spacing" mode="css">
        <xsl:choose>
            <xsl:when test="@w:lineRule='auto'">
                <xsl:if test="@w:line != 240">
                    <xsl:variable name="pct" 
                        select="format-number((@w:line div 240) * 100, $css-number-format)"/>
                    <xsl:sequence
                        select="(
                        'line-height', 
                        concat($pct, '%')
                        )"
                    />
                </xsl:if>                
            </xsl:when>
            <xsl:when test="@w:lineRule='exact' or @w:lineRule='atLeast'">
                <xsl:variable name="points" select="string(@w:line div 20)"/>
                <xsl:sequence
                    select="(
                    'line-height', 
                    concat($points, '%')
                    )"/>
            </xsl:when>
        </xsl:choose>        
        <xsl:apply-templates select="@*" mode="css"/>
    </xsl:template>

    <xsl:template match="w:spacing/@w:before" mode="css" priority="1">
        <xsl:variable name="val" select="." as="xs:integer"/>
        <xsl:sequence select="(
            'margin-top', 
            concat(string($val div 20), 'pt')
        )"/>
    </xsl:template>

    <xsl:template match="w:spacing/@w:after" mode="css" priority="1">
        <xsl:variable name="val" select="." as="xs:integer"/>
        <xsl:choose>
            <xsl:when test="$settings.suppress-trailing-whitespace">
                <xsl:sequence
                    select="(
                    'margin-bottom', 
                    '0pt'
                )"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence
                    select="(
                    'margin-bottom', 
                    concat(string($val div 20), 'pt')
                )"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="w:pPr/w:ind" mode="css">
        <xsl:apply-templates select="@*" mode="css"/>
    </xsl:template>

    <xsl:template match="w:pPr/w:ind/@w:left" mode="css">
        <!--
            currentMarginLeft
        -->
        <xsl:variable name="current-margin-left" select="0"/>
        <xsl:variable name="left" select="(. div 1440) - $current-margin-left"/>
        <xsl:sequence
            select="(
            'margin-left', 
            concat($left, 'in')
        )"/>
    </xsl:template>

    <xsl:template match="w:pPr/w:ind/@w:right" mode="css">
        <xsl:variable name="right" select=". div 1440"/>
        <xsl:sequence
            select="(
            'margin-right', 
            concat($right, 'in')
        )"/>
    </xsl:template>


    <xsl:template match="w:pPr/w:ind/@w:firstLine" mode="css">
        <xsl:variable name="first-line" select=". div 1440"/>
        <xsl:sequence
            select="(
            'text-indent', 
            concat($first-line, 'in')
        )"/>
    </xsl:template>

    <xsl:template match="w:pPr/w:ind/@w:hanging" mode="css">
        <xsl:variable name="hanging" select="-1 * (. div 1440)"/>
        <xsl:sequence
            select="(
            'text-indent', 
            concat($hanging, 'in')
        )"/>
    </xsl:template>

    <xsl:template match="w:pPr/w:jc[@w:val='right']" mode="css">
        <xsl:sequence select="(
            'text-align', 
            'right'
        )"/>
    </xsl:template>

    <xsl:template match="w:pPr/w:jc[@w:val='center']" mode="css">
        <xsl:sequence select="(
            'text-align', 
            'center'
        )"/>
    </xsl:template>

    <xsl:template match="w:pPr/w:jc[@w:val='both']" mode="css">
        <xsl:sequence select="(
            'text-align', 
            'justify'
        )"/>
    </xsl:template>

    <xsl:template match="w:sz" mode="css">
        <xsl:variable name="size" select="@w:val div 2" as="xs:double"/>
        <xsl:sequence
            select="(
            'font-size',
            concat(string($size), 'pt')
        )"/>
    </xsl:template>

    <xsl:template match="w:pPr/w:szCs" mode="css">
        <!-- 
        if (languageType == "bidi")
            sz = (decimal?)pPr.Elements(W.rPr).Elements(W.szCs).Attributes(W.val).FirstOrDefault();
            style.AddIfMissing("font-size", string.Format("{0}pt", sz / 2.0m));
        -->
    </xsl:template>

    <xsl:template match="w:pPr/w:textAlignment/@w:val[. = 'auto']" mode="css"/>
    <xsl:template match="w:pPr/w:textAlignment/@w:val[. = 'top']" mode="css">
        <xsl:sequence select="(
            'vertical-align',
            'top'
        )"/>
    </xsl:template>
    <xsl:template match="w:pPr/w:textAlignment/@w:val[. = 'center']" mode="css">
        <xsl:sequence select="(
            'vertical-align',
            'middle'
        )"/>
    </xsl:template>
    <xsl:template match="w:pPr/w:textAlignment/@w:val[. = 'baseline']" mode="css">
        <xsl:sequence select="(
            'vertical-align',
            'baseline'
        )"/>
    </xsl:template>
    <xsl:template match="w:pPr/w:textAlignment/@w:val[. = 'bottom']" mode="css">
        <xsl:sequence select="(
            'vertical-align',
            'bottom'
        )"/>
    </xsl:template>

</xsl:stylesheet>
