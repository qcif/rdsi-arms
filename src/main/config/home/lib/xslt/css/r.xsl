<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:d2h="http://www.github.com/rnathanday/docx2html" exclude-result-prefixes="xs"
    version="2.0">

    <xsl:variable name="default-char-style-props" as="element(style)?">
        <xsl:sequence select="d2h:make-style-props($style-document/w:styles/w:style[@w:type='character'][@w:default='1'])"/>
    </xsl:variable>

    <xsl:variable name="char-style-props" as="element(styles)">
        <styles>
            <xsl:for-each select="$style-document/w:styles/w:style[@w:type='character']">
                <xsl:sequence select="d2h:make-style-props(.)"/>
            </xsl:for-each>
        </styles>
    </xsl:variable>

    <xsl:template match="w:r" mode="css">
        <xsl:apply-templates select="w:rPr" mode="css"/>
    </xsl:template>

    <xsl:template match="w:r/w:rPr" mode="css" as="xs:string*">
        <xsl:apply-templates select="child::*[not(self::w:rStyle)]" mode="css"/>
        <xsl:variable name="id" select="string(w:rStyle/@w:val)" as="xs:string"/>
        <xsl:sequence select="
            for $prop in ($char-style-props/style[@id = $id], $default-char-style-props)[1]/prop
            return (string($prop/@name), string($prop/@val))
        "/>
    </xsl:template>

    <xsl:template match="w:style/w:rPr" mode="css">
        <xsl:if test="not(w:b)">
            <xsl:sequence
                select="(
                'font-weight', 
                'normal'
            )"/>
        </xsl:if>
        <xsl:apply-templates mode="css"/>
    </xsl:template>

    <xsl:template match="w:rPr/w:b" mode="css" as="xs:string*">
        <xsl:choose>
            <xsl:when test="d2h:get-bool-prop(@w:val)">
                <xsl:sequence
                    select="(
                    'font-weight', 
                    'bold'
                )"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence
                    select="(
                    'font-weight', 
                    'normal'
                )"
            />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="w:rPr/w:i" mode="css">
        <xsl:choose>
            <xsl:when test="d2h:get-bool-prop(@w:val)">
                <xsl:sequence
                    select="(
                    'font-style', 
                    'italic'
                )"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence
                    select="(
                    'font-style', 
                    'normal'
                )"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="w:style/w:rPr/w:bdr/@w:val[. != 'none']" mode="css">
        <xsl:sequence
            select="(
            'border', 
            'solid windowtext 1.0pt'
        )"/>
        <xsl:sequence select="(
            'padding', 
            '0in'
        )"/>
    </xsl:template>

    <xsl:template match="w:style/w:rPr/w:color/@w:val" mode="css">
        <!-- 
        CreateColorProperty("color", color, style);
        -->
    </xsl:template>

    <xsl:template match="w:style/w:rPr/w:highlight/@w:val" mode="css">
        <!-- 
        CreateColorProperty("background", highlight, style);
        -->
    </xsl:template>

    <xsl:template match="w:style/w:rPr/w:shd/@w:fill" mode="css">
        <!-- 
        CreateColorProperty("background", shade, style);
        -->
    </xsl:template>

    <xsl:template match="w:caps" mode="css">
        <xsl:if test="d2h:get-bool-prop(@w:val)">
            <xsl:sequence
                select="(
                'text-transform', 
                'uppercase'
            )"
            />
        </xsl:if>
    </xsl:template>

    <xsl:template match="w:smallCaps" mode="css">
        <xsl:if test="d2h:get-bool-prop(@w:val)">
            <xsl:sequence
                select="(
                'font-variant', 
                'small-caps'
            )"
            />
        </xsl:if>
    </xsl:template>

    <xsl:template match="w:r/w:rPr/w:sz[@w:val]" mode="css">
        <xsl:variable name="val" select="@w:val div 2.0" as="xs:double"/>
        <xsl:sequence
            select="(
            'font-size', 
            concat(string($val), 'pt')
        )"/>

    </xsl:template>

    <xsl:template match="w:r/w:rPr/w:rFonts | w:style/w:rPr/w:rFonts" mode="css">
        <xsl:variable name="font" select="(
            @w:ascii|@w:asciiTheme|@w:cs|@w:cstheme|@w:eastAsia|
            @w:eastAsiaTheme|@w:hAnsi|@w:hAnsiTheme
        )[1]" as="xs:string"/>
        <xsl:variable name="fallback" select="d2h:font-fallback($font)" as="xs:string*"/>
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="not(empty($fallback))">
                    <xsl:value-of
                        select="concat(
                        d2h:apos-quote($font)
                        , ','
                        , d2h:apos-quote($fallback)
                    )"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="d2h:apos-quote($font)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="(
            'font-family', 
            $value
            )"/>
    </xsl:template>

    <xsl:function name="d2h:apos-quote" as="xs:string">
        <xsl:param name="string" as="xs:string"/>
        <xsl:value-of select="concat('''', $string, '''')"/>
    </xsl:function>

    <!--        
        // W.spacing
        decimal? spacingInTwips = (decimal?)rPr.Elements(W.spacing).Attributes(W.val).FirstOrDefault();
        if (spacingInTwips != null)
            style.AddIfMissing("letter-spacing", string.Format("{0}pt", spacingInTwips / 20));
        
        // W.position
        decimal? position = (decimal?)rPr.Elements(W.position).Attributes(W.val).FirstOrDefault();
        if (position != null)
        {
            style.AddIfMissing("position", "relative");
            style.AddIfMissing("top", string.Format("{0}pt", -(position / 2)));
        }
        
        // W.vanish
        if (getBoolProp(rPr, W.vanish))
            style.AddIfMissing("display", "none");
            
        // W.u
        if (rPr.Element(W.u) != null && (string)rPr.Elements(W.u).Attributes(W.val).FirstOrDefault() != "none")
        {
            var newContent = new XElement(Xhtml.u, content);
            if (newContent.Nodes().Any())
                content = newContent;
            style.AddIfMissing("text-decoration", "underline");
        }
        
        
        // W.strike
        if (getBoolProp(rPr, W.strike) || getBoolProp(rPr, W.dstrike))
        {
            var newContent = new XElement(Xhtml.s, content);
            if (newContent.Nodes().Any())
                content = newContent;
            style.AddIfMissing("text-decoration", "line-through");
        }
        
        // W.vertAlign
        if (rPr.Element(W.vertAlign) != null && (string)rPr.Elements(W.vertAlign).Attributes(W.val).FirstOrDefault() == "superscript")
        {
            var newContent = new XElement(Xhtml.sup, content);
            if (newContent.Nodes().Any())
                content = newContent;
        }
        
        if (rPr.Element(W.vertAlign) != null && (string)rPr.Elements(W.vertAlign).Attributes(W.val).FirstOrDefault() == "subscript")
        {
            var newContent = new XElement(Xhtml.sub, content);
            if (newContent.Nodes().Any())
                content = newContent;
        }
        // Pt.FontName
        string font = (string)run.Attributes(PtOpenXml.pt + "FontName").FirstOrDefault();
        if (font != null)
            CreateFontCssProperty(font, style);
        
        // W.sz
        var languageType = (string)run.Attribute(PtOpenXml.LanguageType);
        decimal? sz = null;
        if (languageType == "bidi")
            sz = (decimal?)rPr.Elements(W.szCs).Attributes(W.val).FirstOrDefault();
        else
            sz = (decimal?)rPr.Elements(W.sz).Attributes(W.val).FirstOrDefault();
        if (sz != null)
            style.AddIfMissing("font-size", string.Format("{0}pt", sz / 2.0m));
            
        -->
    <!--
    style.AddIfMissing("margin-top", "0pt");
    style.AddIfMissing("margin-left", "0pt");
    style.AddIfMissing("margin-right", "0pt");
    style.AddIfMissing("margin-bottom", "0pt");
-->

</xsl:stylesheet>
