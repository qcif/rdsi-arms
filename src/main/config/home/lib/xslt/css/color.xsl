<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    
    
    
    
</xsl:stylesheet>

<!--
    
        private static Dictionary<string, Func<string, string, string>> ShadeMapper = new Dictionary<string,Func<string, string, string>>()
        {
            { "auto", (c, f) => c },
            { "clear", (c, f) => f },
            { "nil", (c, f) => f },
            { "solid", (c, f) => c },
            { "diagCross", (c, f) => ConvertColorFillPct(c, f, .75) },
            { "diagStripe", (c, f) => ConvertColorFillPct(c, f, .75) },
            { "horzCross", (c, f) => ConvertColorFillPct(c, f, .5) },
            { "horzStripe", (c, f) => ConvertColorFillPct(c, f, .5) },
            { "pct10", (c, f) => ConvertColorFillPct(c, f, .1) },
            { "pct12", (c, f) => ConvertColorFillPct(c, f, .125) },
            { "pct15", (c, f) => ConvertColorFillPct(c, f, .15) },
            { "pct20", (c, f) => ConvertColorFillPct(c, f, .2) },
            { "pct25", (c, f) => ConvertColorFillPct(c, f, .25) },
            { "pct30", (c, f) => ConvertColorFillPct(c, f, .3) },
            { "pct35", (c, f) => ConvertColorFillPct(c, f, .35) },
            { "pct37", (c, f) => ConvertColorFillPct(c, f, .375) },
            { "pct40", (c, f) => ConvertColorFillPct(c, f, .4) },
            { "pct45", (c, f) => ConvertColorFillPct(c, f, .45) },
            { "pct50", (c, f) => ConvertColorFillPct(c, f, .50) },
            { "pct55", (c, f) => ConvertColorFillPct(c, f, .55) },
            { "pct60", (c, f) => ConvertColorFillPct(c, f, .60) },
            { "pct62", (c, f) => ConvertColorFillPct(c, f, .625) },
            { "pct65", (c, f) => ConvertColorFillPct(c, f, .65) },
            { "pct70", (c, f) => ConvertColorFillPct(c, f, .7) },
            { "pct75", (c, f) => ConvertColorFillPct(c, f, .75) },
            { "pct80", (c, f) => ConvertColorFillPct(c, f, .8) },
            { "pct85", (c, f) => ConvertColorFillPct(c, f, .85) },
            { "pct87", (c, f) => ConvertColorFillPct(c, f, .875) },
            { "pct90", (c, f) => ConvertColorFillPct(c, f, .9) },
            { "pct95", (c, f) => ConvertColorFillPct(c, f, .95) },
            { "reverseDiagStripe", (c, f) => ConvertColorFillPct(c, f, .5) },
            { "thinDiagCross", (c, f) => ConvertColorFillPct(c, f, .5) },
            { "thinDiagStripe", (c, f) => ConvertColorFillPct(c, f, .25) },
            { "thinHorzCross", (c, f) => ConvertColorFillPct(c, f, .3) },
            { "thinHorzStripe", (c, f) => ConvertColorFillPct(c, f, .25) },
            { "thinReverseDiagStripe", (c, f) => ConvertColorFillPct(c, f, .25) },
            { "thinVertStripe", (c, f) => ConvertColorFillPct(c, f, .25) },
        };

        private static Dictionary<string, string> ShadeCache = new Dictionary<string, string>();

        // fill is the background, color is the foreground
        private static string ConvertColorFillPct(string color, string fill, double pct)
        {
            if (color == "auto")
                color = "000000";
            if (fill == "auto")
                fill = "ffffff";
            var key = color + fill + pct.ToString();
            if (ShadeCache.ContainsKey(key))
                return ShadeCache[key];
            var fillRed = Convert.ToInt32(fill.Substring(0, 2), 16);
            var fillGreen = Convert.ToInt32(fill.Substring(2, 2), 16);
            var fillBlue = Convert.ToInt32(fill.Substring(4, 2), 16);
            var colorRed = Convert.ToInt32(color.Substring(0, 2), 16);
            var colorGreen = Convert.ToInt32(color.Substring(2, 2), 16);
            var colorBlue = Convert.ToInt32(color.Substring(4, 2), 16);
            var finalRed = (int)(fillRed - (fillRed - colorRed) * pct);
            var finalGreen = (int)(fillGreen - (fillGreen - colorGreen) * pct);
            var finalBlue = (int)(fillBlue - (fillBlue - colorBlue) * pct);
            var returnValue = string.Format("{0:x2}{1:x2}{2:x2}", finalRed, finalGreen, finalBlue);
            ShadeCache.Add(key, returnValue);
            return returnValue;
        }

        private static void CreateStyleFromShd(Dictionary<string, string> style, XElement shd)
        {
            if (shd == null)
                return;
            var shadeType = (string)shd.Attribute(W.val);
            var color = (string)shd.Attribute(W.color);
            var fill = (string)shd.Attribute(W.fill);
            if (ShadeMapper.ContainsKey(shadeType))
            {
                color = ShadeMapper[shadeType](color, fill);
            }
            if (color != null)
            {
                var cvtColor = ConvertColor(color);
                if (cvtColor != null && cvtColor != "")
                    style.AddIfMissing("background", cvtColor);
            }
        }

        private static Dictionary<string, string> namedColors = new Dictionary<string, string>()
        {
            {"black", "black"},
            {"blue", "blue" },
            {"cyan", "aqua" },
            {"green", "green" },
            {"magenta", "fuchsia" },
            {"red", "red" },
            {"yellow", "yellow" },
            {"white", "white" },
            {"darkBlue", "#00008B" },
            {"darkCyan", "#008B8B" },
            {"darkGreen", "#006400" },
            {"darkMagenta", "#800080" },
            {"darkRed", "#8B0000" },
            {"darkYellow", "#808000" },
            {"darkGray", "#A9A9A9" },
            {"lightGray", "#D3D3D3" },
            {"none", "" },
        };

        private static void CreateColorProperty(string propertyName, string color, Dictionary<string, string> style)
        {
            if (color == null)
                return;
            if (namedColors.ContainsKey(color))
            {
                var lc = namedColors[color];
                if (lc == "")
                    return;
                style.AddIfMissing(propertyName, lc);
                return;
            }
            style.AddIfMissing(propertyName, "#" + color);
        }

        private static string ConvertColor(string color)
        {
            if (namedColors.ContainsKey(color))
            {
                var lc = namedColors[color];
                if (lc == "")
                    return "black";
                return lc;
            }
            return "#" + color;
        }


    
-->