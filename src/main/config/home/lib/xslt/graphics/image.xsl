<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    xmlns:wp="http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing"
    xmlns:a="http://schemas.openxmlformats.org/drawingml/2006/main"
    xmlns:pic="http://schemas.openxmlformats.org/drawingml/2006/picture"
    xmlns:d2h="http://www.github.com/rnathanday/docx2html"
    xmlns:pr="http://schemas.openxmlformats.org/package/2006/relationships"
    xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships"
    xmlns:js="http://saxonica.com/ns/globalJS"
    exclude-result-prefixes="xs w wp a pic d2h pr r js"
    version="2.0">
    
    <!--
        public class ImageInfo
            public Bitmap Bitmap;
            public XAttribute ImgStyleAttribute;
            public string ContentType;
            public XElement DrawingElement;
            public string AltText;
    
            public static int EmusPerInch = 914400;
            public static int EmusPerCm = 360000;
    -->
    
    <!-- public class ImageInfo -->
    <xsl:variable name="imageinfo.emus-per-inch" select="914400" as="xs:integer"/>
    <xsl:variable name="imageinfo.emus-per-cm" select="360000" as="xs:integer"/>
    
    <xsl:function name="d2h:image-handler">
        <xsl:param name="image-info"/>
        <xsl:param name="element" as="element()"/>
    </xsl:function>
    
    <xsl:template match="w:drawing | w:pict | w:_object">
        <xsl:apply-templates select="(descendant::wp:inline | descendant::wp:anchor)[1]"/>
    </xsl:template>
    
    <xsl:template match="wp:anchor">
        <xsl:variable name="x" select="wp:extent/@cx div $imageinfo.emus-per-inch" as="xs:double?"/>
        <xsl:variable name="y" select="wp:extent/@cy div $imageinfo.emus-per-inch" as="xs:double?"/>
        <xsl:if test="not(empty($x)) and not(empty($y))">
            <xsl:variable name="img-data"  
                select="d2h:blip-image-data(descendant::a:blip)"
                as="xs:string"/>
            <img style="width: {$x}in; height: {$y}in">
                <xsl:if test="string-length($img-data) != 0">
                    <xsl:attribute name="src">
                        <xsl:value-of select="$img-data"/>
                    </xsl:attribute>
                </xsl:if>
            </img>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="a:graphic | a:graphicData | pic:pic | pic:blipFill">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:function name="d2h:blip-image-data" as="xs:string">
        <xsl:param name="blip" as="element(a:blip)"/>
        <xsl:variable name="embed-id" select="$blip/@r:embed" as="xs:string"/>
        <!-- handle 'word/' context better -->
        <xsl:variable name="href" 
            select="concat(
                'word/', 
                string($rels-document/pr:Relationships/pr:Relationship[@Id=$embed-id]/@Target)
            )"
            as="xs:string"/>
        <!-- todo: get this from the image data instead of the file extension -->
        <xsl:variable name="img-type" as="xs:string">
            <xsl:choose>
                <xsl:when test="matches($href,'\.[^\.]+$')">
                    <xsl:value-of select="replace($href,'.*?\.([^\.]+)$', '$1')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="''"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="img-data" select="d2h:resolve-unparsed-document($href)"/>
        <xsl:value-of select="concat(
            'data:image/'
            ,$img-type
            ,';base64,'
            ,$img-data
        )"/>
    </xsl:function>    

</xsl:stylesheet>

<!--
    
    private class Atnv
    {
        public string Name;
        public string Value;
    }
    
    private static XElement ProcessImage(WordprocessingDocument wordDoc,
        XElement element, Func<ImageInfo, XElement> imageHandler)
    {
        if (element.Name == W.drawing)
        {
            XElement containerElement = element.Elements()
                .Where(e => e.Name == WP.inline || e.Name == WP.anchor)
                .FirstOrDefault();
            if (containerElement != null)
            {
                int? extentCx = (int?)containerElement.Elements(WP.extent)
                    .Attributes(NoNamespace.cx).FirstOrDefault();
                int? extentCy = (int?)containerElement.Elements(WP.extent)
                    .Attributes(NoNamespace.cy).FirstOrDefault();
                string altText = (string)containerElement.Elements(WP.docPr)
                    .Attributes(NoNamespace.descr).FirstOrDefault();
                if (altText == null)
                    altText = (string)containerElement.Elements(WP.docPr)
                        .Attributes(NoNamespace.name).FirstOrDefault();
                if (altText == null)
                    altText = "";

                XElement blipFill = containerElement.Elements(A.graphic)
                    .Elements(A.graphicData)
                    .Elements(Pic._pic).Elements(Pic.blipFill).FirstOrDefault();
                if (blipFill != null)
                {
                    string imageRid = (string)blipFill.Elements(A.blip).Attributes(R.embed)
                        .FirstOrDefault();
                    if (imageRid != null)
                    {
                        var pp3 = wordDoc.MainDocumentPart.Parts.FirstOrDefault(pp => pp.RelationshipId == imageRid);
                        if (pp3 == null)
                            return null;
                        ImagePart imagePart = (ImagePart)pp3.OpenXmlPart;
                        if (imagePart == null)
                            return null;
                        // if the image markup points to a NULL image, then following will throw an ArgumentOutOfRangeException
                        try
                        {
                            imagePart = (ImagePart)wordDoc.MainDocumentPart
                                .GetPartById(imageRid);
                        }
                        catch (ArgumentOutOfRangeException)
                        {
                            return null;
                        }
                        string contentType = imagePart.ContentType;
                        if (contentType == "image/png" ||
                            contentType == "image/gif" ||
                            contentType == "image/tiff" ||
                            contentType == "image/jpeg")
                        {
                            using (Stream partStream = imagePart.GetStream())
                            using (Bitmap bitmap = new Bitmap(partStream))
                            {
                                if (extentCx != null && extentCy != null)
                                {
                                    ImageInfo imageInfo = new ImageInfo()
                                    {
                                        Bitmap = bitmap,
                                        ImgStyleAttribute = new XAttribute("style",
                                            string.Format("width: {0}in; height: {1}in",
                                                (float)extentCx / (float)ImageInfo.EmusPerInch,
                                                (float)extentCy / (float)ImageInfo.EmusPerInch)),
                                        ContentType = contentType,
                                        DrawingElement = element,
                                        AltText = altText,
                                    };
                                    return imageHandler(imageInfo);
                                }
                                ImageInfo imageInfo2 = new ImageInfo()
                                {
                                    Bitmap = bitmap,
                                    ContentType = contentType,
                                    DrawingElement = element,
                                    AltText = altText,
                                };
                                return imageHandler(imageInfo2);
                            };
                        }
                    }
                }
            }
        }
        if (element.Name == W.pict || element.Name == W._object)
        {
            string imageRid = (string)element.Elements(VML.shape)
                .Elements(VML.imagedata).Attributes(R.id).FirstOrDefault();
            string style = (string)element.Elements(VML.shape)
                .Attributes("style").FirstOrDefault();
            if (imageRid != null)
            {
                try
                {
                    var pp = wordDoc.MainDocumentPart.Parts.FirstOrDefault(pp2 => pp2.RelationshipId == imageRid);
                    if (pp == null)
                        return null;
                    ImagePart imagePart = (ImagePart)pp.OpenXmlPart;
                    if (imagePart == null)
                        return null;
                    string contentType = imagePart.ContentType;
                    if (contentType == "image/png"
                        || contentType == "image/gif"
                        || contentType == "image/tiff"
                        || contentType == "image/jpeg"
                        // don't process wmf files because GDI consumes huge amounts of memory when dealing with wmf
                        // perhaps because it loads a DLL to do the rendering?
                        // it actually works, but is not recommended
                        //  || contentType == "image/x-wmf"
                    )
                    {
                        //string style = element.
                        using (Stream partStream = imagePart.GetStream())
                            try
                            {
                                using (Bitmap bitmap = new Bitmap(partStream))
                                {
                                    ImageInfo imageInfo = new ImageInfo()
                                    {
                                        Bitmap = bitmap,
                                        ContentType = contentType,
                                        DrawingElement = element,
                                    };
                                    if (style != null)
                                    {
                                        float? widthInPoints = null;
                                        float? heightInPoints = null;
                                        string[] tokens = style.Split(';');
                                        var widthString = tokens
                                            .Select(t => new Atnv
                                            {
                                                Name = t.Split(':').First(),
                                                Value = t.Split(':').Skip(1)
                                                    .Take(1).FirstOrDefault(),
                                            })
                                            .Where(p => p.Name == "width")
                                            .Select(p => p.Value)
                                            .FirstOrDefault();
                                        if (widthString != null &&
                                            widthString.Length > 2 &&
                                            widthString.Substring(widthString.Length - 2) == "pt")
                                        {
                                            float w;
                                            if (float.TryParse(widthString.Substring(0,
                                                widthString.Length - 2), out w))
                                                widthInPoints = w;
                                        }
                                        var heightString = tokens
                                            .Select(t => new Atnv
                                            {
                                                Name = t.Split(':').First(),
                                                Value = t.Split(':').Skip(1).Take(1).FirstOrDefault(),
                                            })
                                            .Where(p => p.Name == "height")
                                            .Select(p => p.Value)
                                            .FirstOrDefault();
                                        if (heightString != null &&
                                            heightString.Substring(heightString.Length - 2) == "pt")
                                        {
                                            float h;
                                            if (float.TryParse(heightString.Substring(0,
                                                heightString.Length - 2), out h))
                                                heightInPoints = h;
                                        }
                                        if (widthInPoints != null && heightInPoints != null)
                                            imageInfo.ImgStyleAttribute = new XAttribute(
                                                "style", string.Format(
                                                    "width: {0}pt; height: {1}pt",
                                                    widthInPoints, heightInPoints));
                                    }
                                    return imageHandler(imageInfo);
                                };
                            }
                            // the Bitmap class can throw OutOfMemoryException, which means the bitmap is messed up, so punt.
                            catch (OutOfMemoryException)
                            {
                                return null;
                            }
                            catch (ArgumentException)
                            {
                                return null;
                            }
                    }
                }
                catch (ArgumentOutOfRangeException)
                {
                    return null;
                }
            }
        }
   
-->