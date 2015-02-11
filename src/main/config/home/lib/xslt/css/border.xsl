<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
</xsl:stylesheet>

<!-- 
    
    private static object CreateBorderDivs(WordprocessingDocument wordDoc, HtmlConverterSettings settings, IEnumerable<XElement> elements) 
    {
        return elements.GroupAdjacent(e =>
            {
                if (e.Elements(W.pPr).Elements(W.pBdr).Any())
                {
                    var pBdr = e.Element(W.pPr).Element(W.pBdr);
                    var indStr = "";
                    var ind = e.Element(W.pPr).Element(W.ind);
                    if (ind != null)
                        indStr = ind.ToString(SaveOptions.DisableFormatting);
                    return pBdr.ToString(SaveOptions.DisableFormatting) + indStr;
                }
                else
                {
                    return ""; // empty string means no pBdr
                }
            })
            .Select(g =>
            {
                if (g.Key == "")
                {
                    var o = GroupAndVerticallySpaceNumberedParagraphs(wordDoc, settings, g, 0m);
                    return (object)o;
                }
                var pPr = g.First().Element(W.pPr);
                var pBdr = pPr.Element(W.pBdr);
                Dictionary<string, string> style = new Dictionary<string, string>();
                GenerateBorderStyle(pBdr, W.top, style, BorderType.Paragraph);
                GenerateBorderStyle(pBdr, W.right, style, BorderType.Paragraph);
                GenerateBorderStyle(pBdr, W.bottom, style, BorderType.Paragraph);
                GenerateBorderStyle(pBdr, W.left, style, BorderType.Paragraph);
                var ind = pPr.Element(W.ind);
                decimal currentMarginLeft = 0m;
                if (ind != null)
                {
                    decimal? left = (decimal?)ind.Attribute(W.left);
                    decimal leftInInches = 0;
                    if (left != null)
                        leftInInches = (decimal)left / 1440;
                    decimal? hanging = (decimal?)ind.Attribute(W.hanging);
                    decimal hangingInInches = 0;
                    if (hanging != null)
                        hangingInInches = -(decimal)hanging / 1440;
                    currentMarginLeft = leftInInches + hangingInInches;
                    style.AddIfMissing("margin-left", string.Format("{0:0.00}in", currentMarginLeft));
                }

                var div = new XElement(Xhtml.div,
                    GroupAndVerticallySpaceNumberedParagraphs(wordDoc, settings, g, currentMarginLeft));

                div.AddAnnotation(style);
                return div;
            })
        .ToList();
    }

    
    private enum BorderType
    {
        Paragraph,
        Cell,
    };

    
           private class BorderMappingInfo
        {
            public string CssName;
            public decimal CssSize;
        }

        private static Dictionary<string, BorderMappingInfo> BorderStyleMap = new Dictionary<string, BorderMappingInfo>()
        {
            { "single", new BorderMappingInfo() { CssName = "solid", CssSize = 1.0m }},
            { "dotted", new BorderMappingInfo() { CssName = "dotted", CssSize = 1.0m }},
            { "dashSmallGap", new BorderMappingInfo() { CssName = "dashed", CssSize = 1.0m }},
            { "dashed", new BorderMappingInfo() { CssName = "dashed", CssSize = 1.0m }},
            { "dotDash", new BorderMappingInfo() { CssName = "dashed", CssSize = 1.0m }},
            { "dotDotDash", new BorderMappingInfo() { CssName = "dashed", CssSize = 1.0m }},
            { "double", new BorderMappingInfo() { CssName = "double", CssSize = 2.5m }},
            { "triple", new BorderMappingInfo() { CssName = "double", CssSize = 2.5m }},
            { "thinThickSmallGap", new BorderMappingInfo() { CssName = "double", CssSize = 4.5m }},
            { "thickThinSmallGap", new BorderMappingInfo() { CssName = "double", CssSize = 4.5m }},
            { "thinThickThinSmallGap", new BorderMappingInfo() { CssName = "double", CssSize = 6.0m }},
            { "thickThinMediumGap", new BorderMappingInfo() { CssName = "double", CssSize = 6.0m }},
            { "thinThickMediumGap", new BorderMappingInfo() { CssName = "double", CssSize = 6.0m }},
            { "thinThickThinMediumGap", new BorderMappingInfo() { CssName = "double", CssSize = 9.0m }},
            { "thinThickLargeGap", new BorderMappingInfo() { CssName = "double", CssSize = 5.25m }},
            { "thickThinLargeGap", new BorderMappingInfo() { CssName = "double", CssSize = 5.25m }},
            { "thinThickThinLargeGap", new BorderMappingInfo() { CssName = "double", CssSize = 9.0m }},
            { "wave", new BorderMappingInfo() { CssName = "solid", CssSize = 3.0m }},
            { "doubleWave", new BorderMappingInfo() { CssName = "double", CssSize = 5.25m }},
            { "dashDotStroked", new BorderMappingInfo() { CssName = "solid", CssSize = 3.0m }},
            { "threeDEmboss", new BorderMappingInfo() { CssName = "ridge", CssSize = 6.0m }},
            { "threeDEngrave", new BorderMappingInfo() { CssName = "groove", CssSize = 6.0m }},
            { "outset", new BorderMappingInfo() { CssName = "outset", CssSize = 4.5m }},
            { "inset", new BorderMappingInfo() { CssName = "inset", CssSize = 4.5m }},

        };

        private static void GenerateBorderStyle(XElement pBdr, XName sideXName, Dictionary<string, string> style, BorderType borderType)
        {
            string whichSide;
            if (sideXName == W.top)
                whichSide = "top";
            else if (sideXName == W.right)
                whichSide = "right";
            else if (sideXName == W.bottom)
                whichSide = "bottom";
            else
                whichSide = "left";
            if (pBdr == null)
            {
                style.Add("border-" + whichSide, "none");
                if (borderType == BorderType.Cell &&
                    (whichSide == "left" || whichSide == "right"))
                    style.Add("padding-" + whichSide, "5.4pt");
                return;
            }

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


   
        private static void AdjustTableBorders(WordprocessingDocument wordDoc)
        {
            // Note: when implementing a paging version of the HTML transform, this needs to be done
            // for all content parts, not just the main document part.

            var xd = wordDoc.MainDocumentPart.GetXDocument();
            foreach (var tbl in xd.Descendants(W.tbl))
                AdjustTableBorders(tbl);
            wordDoc.MainDocumentPart.PutXDocument();
        }

        private static void AdjustTableBorders(XElement tbl)
        {
            var ta = tbl
                .Elements(W.tr)
                .Select(r => r
                    .Elements(W.tc)
                    .Select(c =>
                    {
                        int? gridSpan = (int?)c.Elements(W.tcPr).Elements(W.gridSpan).Attributes(W.val).FirstOrDefault();
                        if (gridSpan != null)
                        {
                            if (gridSpan < 1)
                                gridSpan = 1;
                            return Enumerable.Repeat(c, (int)gridSpan);
                        }
                        return new[] { c };
                    })
                    .SelectMany(m => m)
                    .ToArray())
                .ToArray();

            for (int y = 0; y < ta.Length; y++)
            {
                for (int x = 0; x < ta[y].Length; x++)
                {
                    var thisCell = ta[y][x];
                    FixTopBorder(ta, thisCell, x, y);
                    FixLeftBorder(ta, thisCell, x, y);
                    FixBottomBorder(ta, thisCell, x, y);
                    FixRightBorder(ta, thisCell, x, y);
                }
            }
        }

        private static void FixTopBorder(XElement[][] ta, XElement thisCell, int x, int y)
        {
            if (y > 0)
            {
                var rowAbove = ta[y - 1];
                if (x < rowAbove.Length - 1)
                {
                    XElement cellAbove = ta[y - 1][x];
                    if (cellAbove != null &&
                        thisCell.Elements(W.tcPr).Elements(W.tcBorders).FirstOrDefault() != null &&
                        cellAbove.Elements(W.tcPr).Elements(W.tcBorders).FirstOrDefault() != null)
                    {
                        ResolveCellBorder(thisCell.Element(W.tcPr).Element(W.tcBorders).Element(W.top), cellAbove.Element(W.tcPr).Element(W.tcBorders).Element(W.bottom));
                    }
                }
            }
        }

        private static void FixLeftBorder(XElement[][] ta, XElement thisCell, int x, int y)
        {
            if (x > 0)
            {
                XElement cellLeft = ta[y][x - 1];
                if (cellLeft != null &&
                    thisCell.Elements(W.tcPr).Elements(W.tcBorders).FirstOrDefault() != null &&
                    cellLeft.Elements(W.tcPr).Elements(W.tcBorders).FirstOrDefault() != null)
                {
                    ResolveCellBorder(thisCell.Element(W.tcPr).Element(W.tcBorders).Element(W.left), cellLeft.Element(W.tcPr).Element(W.tcBorders).Element(W.right));
                }
            }
        }

        private static void FixBottomBorder(XElement[][] ta, XElement thisCell, int x, int y)
        {
            if (y < ta.Length - 1)
            {
                var rowBelow = ta[y + 1];
                if (x < rowBelow.Length - 1)
                {
                    XElement cellBelow = ta[y + 1][x];
                    if (cellBelow != null &&
                        thisCell.Elements(W.tcPr).Elements(W.tcBorders).FirstOrDefault() != null &&
                        cellBelow.Elements(W.tcPr).Elements(W.tcBorders).FirstOrDefault() != null)
                    {
                        ResolveCellBorder(thisCell.Element(W.tcPr).Element(W.tcBorders).Element(W.bottom), cellBelow.Element(W.tcPr).Element(W.tcBorders).Element(W.top));
                    }
                }
            }
        }

        private static void FixRightBorder(XElement[][] ta, XElement thisCell, int x, int y)
        {
            if (x < ta[y].Length - 1)
            {
                XElement cellRight = ta[y][x + 1];
                if (cellRight != null &&
                    thisCell.Elements(W.tcPr).Elements(W.tcBorders).FirstOrDefault() != null &&
                    cellRight.Elements(W.tcPr).Elements(W.tcBorders).FirstOrDefault() != null)
                {
                    ResolveCellBorder(thisCell.Element(W.tcPr).Element(W.tcBorders).Element(W.right), cellRight.Element(W.tcPr).Element(W.tcBorders).Element(W.left));
                }
            }
        }

        private static Dictionary<string, int> BorderTypePriority = new Dictionary<string, int>()
        {
            { "single", 1 },
            { "thick", 2 },
            { "double", 3 },
            { "dotted", 4 },
        };

        private static Dictionary<string, int> BorderNumber = new Dictionary<string, int>()
        {
            {"single", 1 },
            {"thick", 2 },
            {"double", 3 },
            {"dotted", 4 },
            {"dashed", 5 },
            {"dotDash", 5 },
            {"dotDotDash", 5 },
            {"triple", 6 },
            {"thinThickSmallGap", 6 },
            {"thickThinSmallGap", 6 },
            {"thinThickThinSmallGap", 6 },
            {"thinThickMediumGap", 6 },
            {"thickThinMediumGap", 6 },
            {"thinThickThinMediumGap", 6 },
            {"thinThickLargeGap", 6 },
            {"thickThinLargeGap", 6 },
            {"thinThickThinLargeGap", 6 },
            {"wave", 7 },
            {"doubleWave", 7 },
            {"dashSmallGap", 5 },
            {"dashDotStroked", 5 },
            {"threeDEmboss", 7 },
            {"threeDEngrave", 7 },
            {"outset", 7 },
            {"inset", 7 },
        };

        private static void ResolveCellBorder(XElement border1, XElement border2)
        {
            if (border1 == null || border2 == null)
                return;
            if ((string)border1.Attribute(W.val) == "nil" || (string)border2.Attribute(W.val) == "nil")
                return;
            if ((string)border1.Attribute(W.sz) == "nil" || (string)border2.Attribute(W.sz) == "nil")
                return;

            var border1Val = (string)border1.Attribute(W.val);
            var border1Weight = 1;
            if (BorderNumber.ContainsKey(border1Val))
                border1Weight = BorderNumber[border1Val];

            var border2Val = (string)border2.Attribute(W.val);
            var border2Weight = 1;
            if (BorderNumber.ContainsKey(border2Val))
                border2Weight = BorderNumber[border2Val];

            if (border1Weight != border2Weight)
            {
                if (border1Weight < border2Weight)
                    BorderOverride(border2, border1);
                else
                    BorderOverride(border1, border2);
            }

            if ((decimal)border1.Attribute(W.sz) > (decimal)border2.Attribute(W.sz))
            {
                BorderOverride(border1, border2);
                return;
            }

            if ((decimal)border1.Attribute(W.sz) < (decimal)border2.Attribute(W.sz))
            {
                BorderOverride(border2, border1);
                return;
            }

            var border1Type = (string)border1.Attribute(W.val);
            var border2Type = (string)border2.Attribute(W.val);
            if (BorderTypePriority.ContainsKey(border1Type) &&
                BorderTypePriority.ContainsKey(border2Type))
            {
                var border1Pri = BorderTypePriority[border1Type];
                var border2Pri = BorderTypePriority[border2Type];
                if (border1Pri < border2Pri)
                {
                    BorderOverride(border2, border1);
                    return;
                }
                if (border2Pri < border1Pri)
                {
                    BorderOverride(border1, border2);
                    return;
                }
            }

            var color1str = (string)border1.Attribute(W.color);
            if (color1str == "auto")
                color1str = "000000";
            var color2str = (string)border2.Attribute(W.color);
            if (color2str == "auto")
                color2str = "000000";
            if (color1str != null && color2str != null && color1str != color2str)
            {
                try
                {
                    var color1 = Convert.ToInt32(color1str, 16);
                    var color2 = Convert.ToInt32(color2str, 16);
                    if (color1 < color2)
                    {
                        BorderOverride(border1, border2);
                        return;
                    }
                    if (color2 < color1)
                    {
                        BorderOverride(border2, border1);
                        return;
                    }
                }
                // if the above throws ArgumentException, FormatException, or OverflowException, then abort
                catch (Exception)
                {
                    return;
                }
            }
        }

        private static void BorderOverride(XElement fromBorder, XElement toBorder)
        {
            toBorder.Attribute(W.val).Value = fromBorder.Attribute(W.val).Value;
            if (fromBorder.Attribute(W.color) != null)
                toBorder.SetAttributeValue(W.color, fromBorder.Attribute(W.color).Value);
            if (fromBorder.Attribute(W.sz) != null)
                toBorder.SetAttributeValue(W.sz, fromBorder.Attribute(W.sz).Value);
            if (fromBorder.Attribute(W.themeColor) != null)
                toBorder.SetAttributeValue(W.themeColor, fromBorder.Attribute(W.themeColor).Value);
            if (fromBorder.Attribute(W.themeTint) != null)
                toBorder.SetAttributeValue(W.themeTint, fromBorder.Attribute(W.themeTint).Value);
        }

   
-->