<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:d2h="http://www.github.com/rnathanday/docx2html"
    exclude-result-prefixes="xs d2h w"
    version="2.0">
    
    <xsl:template match="w:tbl" mode="css">
        <xsl:apply-templates mode="css"/>
        <!-- table style defaults: after others for lower precedence -->
        <xsl:sequence select="(
            'border-collapse', 
            'collapse'
        )"/>
        <xsl:sequence select="(
            'border', 
            'none'
        )"/>        
    </xsl:template>
    
    <xsl:template match="w:tblPr" mode="css">
        <xsl:apply-templates select="child::*[not(self::w:tblStyle)]" mode="css"/>
        <xsl:choose>
            <xsl:when test="w:tblStyle[@w:val]">
                <xsl:apply-templates select="w:tblStyle" mode="css"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates
                    select="$style-document/w:styles/w:style[@w:type='table'][@w:default='1']"
                    mode="css"/>                
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="w:tblPr/w:tblStyle" mode="css">
        <xsl:variable name="val" select="@w:val" as="xs:string"/>
        <xsl:apply-templates
            select="$style-document/w:styles/w:style[@w:styleId=$val]"
            mode="css"/>
    </xsl:template>
    
    <xsl:template match="w:tr" mode="css">
        <xsl:apply-templates mode="css"/>
    </xsl:template>
    
    <xsl:template match="w:tr/w:trPr" mode="css">
        <xsl:apply-templates mode="css"/>
    </xsl:template>

    <xsl:template match="w:tr/w:tcPr" mode="css">
        <xsl:apply-templates mode="css"/>
    </xsl:template>
    

    <xsl:template match="w:tr/w:trPr/w:trHeight" mode="css">
        <xsl:variable name="val" select="concat(string(xs:integer(@w:val) div 1440), 'in')"/>
        <xsl:sequence select="(
            'height', 
            $val
        )"/>
    </xsl:template>
    
    <xsl:template match="w:tc" mode="css">
        <xsl:apply-templates mode="css"/>
        
        <xsl:variable name="table-style" select="ancestor::w:tbl/w:tblPr/w:tblStyle/@w:val" as="xs:string?"/>
        <xsl:if test="not(empty($table-style)) and $table-style != ''">
            <xsl:apply-templates
                select="$style-document/w:styles/w:style[@w:styleId=$table-style]//w:tcPr"
                mode="css"/>
        </xsl:if>
        
    </xsl:template>
    
    <xsl:template match="w:tcPr/w:shd" mode="css">
        <!-- TODO: function for color value to hex/string/etc -->
        <xsl:sequence select="(
            'background-color',
            concat('#',string(@w:fill))
        )"/>
    </xsl:template>
        
    <xsl:template match="w:tc/w:tcPr/w:vAlign[@w:val = 'top']" mode="css">
        <xsl:sequence select="(
            'vertical-align', 
            'top'
        )"/>
    </xsl:template>
       
    <xsl:template match="w:tc/w:tcPr/w:vAlign[@w:val = 'center']" mode="css">
        <xsl:sequence select="(
            'vertical-align', 
            'middle'
        )"/>
    </xsl:template>

    <xsl:template match="w:tc/w:tcPr/w:vAlign[@w:val = 'bottom']" mode="css">
        <xsl:sequence select="(
            'vertical-align', 
            'bottom'
        )"/>
    </xsl:template>
    
    <!-- maybe add to w:tcPr-->
    <xsl:template match="w:tc/w:tcPr/w:vAlign[@w:val]" mode="css" priority="0">
        <xsl:sequence select="(
            'vertical-align', 
            'middle'
        )"/>
    </xsl:template>
    
    <xsl:template match="w:tc/w:tcPr/w:vAlign[not(@w:val)]" mode="css">
        <xsl:sequence select="(
            'vertical-align', 
            'top'
        )"/>
    </xsl:template>

    <xsl:template match="w:tc/w:tcPr/w:tcW[@w:type='pct']" mode="css">
        <xsl:variable name="val" select="concat(string(xs:integer(@w:val) div 50), '%')"/>
        <xsl:sequence select="(
            'width', 
            $val
        )"/>
    </xsl:template>

    <xsl:template match="w:tc/w:tcPr/w:tcW[@w:type='dxa']" mode="css">
        <xsl:variable name="val" select="concat(string(xs:integer(@w:val) div 20), 'pt')"/>
        <xsl:sequence select="(
            'width', 
            $val
        )"/>
    </xsl:template>
    
    <xsl:template match="w:tcPr[not(w:tcBorders)]" mode="css">
        <xsl:sequence select="
            for $side in ('top', 'bottom', 'left', 'right')
            return (
                concat('border-', $side),
                'none',
                concat('border-',$side,'-style'), 
                'none'
            )
        "/>
        <xsl:sequence select="
            for $side in ('left', 'right')
            return (
                concat('padding-',$side),
                '5.4pt'
            )
        "/>
        <xsl:apply-templates mode="css"/>
    </xsl:template>
    
    <xsl:template match="w:tcPr/w:tcBorders/w:top" mode="css">
        <xsl:sequence select="d2h:make-cell-border('top',@w:type,@w:space)"/>
    </xsl:template>
    <xsl:template match="w:tcPr/w:tcBorders/w:right" mode="css">
        <xsl:sequence select="d2h:make-cell-border('right',@w:type,@w:space)"/>
    </xsl:template>
    <xsl:template match="w:tcPr/w:tcBorders/w:bottom" mode="css">
        <xsl:sequence select="d2h:make-cell-border('bottom',@w:type,@w:space)"/>
    </xsl:template>
    <xsl:template match="w:tcPr/w:tcBorders/w:left" mode="css">
        <xsl:sequence select="d2h:make-cell-border('left',@w:type,@w:space)"/>
    </xsl:template>
    
    <xsl:function name="d2h:make-cell-border">
        <xsl:param name="side" as="xs:string"/>
        <xsl:param name="type" as="xs:string?"/>
        <xsl:param name="space" as="xs:string?"/>

        <xsl:choose>
            <xsl:when test="empty($type) or $type = 'nil' or $type='none'">
                <xsl:sequence select="(
                    concat('border-',$side,'-style'), 
                    'none'
                )"/>
                <xsl:choose>
                    <xsl:when test="empty($space)"></xsl:when>
                </xsl:choose>
                
            </xsl:when>
        </xsl:choose>
        
    </xsl:function>
    
    <!--
    var side = pBdr.Element(sideXName);
    if (side == null)
    {
    style.Add("border-" + whichSide, "none");
    if (borderType == BorderType.Cell &&
    (whichSide == "left" || whichSide == "right"))
    style.Add("padding-" + whichSide, "5.4pt");
    return;
    }
    var type = (string)side.Attribute(W.val);
    if (type == "nil" || type == "none")
    {
    style.Add("border-" + whichSide + "-style", "none");
    
    var space = (decimal?)side.Attribute(W.space);
    if (space == null)
    space = 0;
    if (borderType == BorderType.Cell &&
    (whichSide == "left" || whichSide == "right"))
    if (space < 5.4m)
    space = 5.4m;
    style.Add("padding-" + whichSide, space == 0 ? "0in" : space.ToString() + "pt");
    }
    else
    {
    var sz = (int)side.Attribute(W.sz);
    var space = (decimal?)side.Attribute(W.space);
    if (space == null)
    space = 0;
    var color = (string)side.Attribute(W.color);
    if (color == null || color == "auto")
    color = "windowtext";
    else
    color = ConvertColor(color);
    
    decimal borderWidthInPoints = Math.Max(1m, Math.Min(96m, Math.Max(2m, sz)) / 8m);
    
    var borderStyle = "solid";
    if (BorderStyleMap.ContainsKey(type))
    {
    var borderInfo = BorderStyleMap[type];
    borderStyle = borderInfo.CssName;
    if (type == "double")
    {
    if (sz <= 8)
    borderWidthInPoints = 2.5m;
    else if (sz <= 18)
    borderWidthInPoints = 6.75m;
    else
    borderWidthInPoints = sz / 3m;
    }
    else if (type == "triple")
    {
    if (sz <= 8)
    borderWidthInPoints = 8m;
    else if (sz <= 18)
    borderWidthInPoints = 11.25m;
    else
    borderWidthInPoints = 11.25m;
    }
    else if (type.ToLower().Contains("dash"))
    {
    if (sz <= 4)
    borderWidthInPoints = 1m;
    else if (sz <= 12)
    borderWidthInPoints = 1.5m;
    else
    borderWidthInPoints = 2m;
    }
    else if (type != "single")
    borderWidthInPoints = borderInfo.CssSize;
    }
    if (type == "outset" || type == "inset")
    color = "";
    var borderWidth = string.Format("{0:0.0}pt", borderWidthInPoints);
    
    style.Add("border-" + whichSide, borderStyle + " " + color + " " + borderWidth);
    if (borderType == BorderType.Cell &&
    (whichSide == "left" || whichSide == "right"))
    if (space < 5.4m)
    space = 5.4m;
    
    style.Add("padding-" + whichSide, space == 0 ? "0in" : space.ToString() + "pt");
    }
    }
    -->
    
    
    
    <xsl:function name="d2h:table-cell-shade" as="xs:string?">
        <xsl:param name="wshd" as="element(w:shd)"/>
        <!-- 
TODO: 
        CreateStyleFromShd(style, tcPr.Element(W.shd)); -->
    </xsl:function>
        
</xsl:stylesheet>