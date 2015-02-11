<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
        
    <xsl:character-map name="html-entity-map">
        <xsl:output-character character="&#160;" string="&amp;nbsp;"/>
        <xsl:output-character character="&#161;" string="&amp;iexcl;"/>
        <xsl:output-character character="&#162;" string="&amp;cent;"/>
        <xsl:output-character character="&#163;" string="&amp;pound;"/>
        <xsl:output-character character="&#164;" string="&amp;curren;"/>
        <xsl:output-character character="&#165;" string="&amp;yen;"/>
        <xsl:output-character character="&#166;" string="&amp;brvbar;"/>
        <xsl:output-character character="&#167;" string="&amp;sect;"/>
        <xsl:output-character character="&#168;" string="&amp;uml;"/>
        <xsl:output-character character="&#169;" string="&amp;copy;"/>
        <xsl:output-character character="&#170;" string="&amp;ordf;"/>
        <xsl:output-character character="&#171;" string="&amp;laquo;"/>
        <xsl:output-character character="&#172;" string="&amp;not;"/>
        <xsl:output-character character="&#173;" string="&amp;shy;"/>
        <xsl:output-character character="&#174;" string="&amp;reg;"/>
        <xsl:output-character character="&#175;" string="&amp;macr;"/>
        <xsl:output-character character="&#176;" string="&amp;deg;"/>
        <xsl:output-character character="&#177;" string="&amp;plusmn;"/>
        <xsl:output-character character="&#178;" string="&amp;sup2;"/>
        <xsl:output-character character="&#179;" string="&amp;sup3;"/>
        <xsl:output-character character="&#180;" string="&amp;acute;"/>
        <xsl:output-character character="&#181;" string="&amp;micro;"/>
        <xsl:output-character character="&#182;" string="&amp;para;"/>
        <xsl:output-character character="&#183;" string="&amp;middot;"/>
        <xsl:output-character character="&#184;" string="&amp;cedil;"/>
        <xsl:output-character character="&#185;" string="&amp;sup1;"/>
        <xsl:output-character character="&#186;" string="&amp;ordm;"/>
        <xsl:output-character character="&#187;" string="&amp;raquo;"/>
        <xsl:output-character character="&#188;" string="&amp;frac14;"/>
        <xsl:output-character character="&#189;" string="&amp;frac12;"/>
        <xsl:output-character character="&#190;" string="&amp;frac34;"/>
        <xsl:output-character character="&#191;" string="&amp;iquest;"/>
        <xsl:output-character character="&#192;" string="&amp;Agrave;"/>
        <xsl:output-character character="&#193;" string="&amp;Aacute;"/>
        <xsl:output-character character="&#194;" string="&amp;Acirc;"/>
        <xsl:output-character character="&#195;" string="&amp;Atilde;"/>
        <xsl:output-character character="&#196;" string="&amp;Auml;"/>
        <xsl:output-character character="&#197;" string="&amp;Aring;"/>
        <xsl:output-character character="&#198;" string="&amp;AElig;"/>
        <xsl:output-character character="&#199;" string="&amp;Ccedil;"/>
        <xsl:output-character character="&#200;" string="&amp;Egrave;"/>
        <xsl:output-character character="&#201;" string="&amp;Eacute;"/>
        <xsl:output-character character="&#202;" string="&amp;Ecirc;"/>
        <xsl:output-character character="&#203;" string="&amp;Euml;"/>
        <xsl:output-character character="&#204;" string="&amp;Igrave;"/>
        <xsl:output-character character="&#205;" string="&amp;Iacute;"/>
        <xsl:output-character character="&#206;" string="&amp;Icirc;"/>
        <xsl:output-character character="&#207;" string="&amp;Iuml;"/>
        <xsl:output-character character="&#208;" string="&amp;ETH;"/>
        <xsl:output-character character="&#209;" string="&amp;Ntilde;"/>
        <xsl:output-character character="&#210;" string="&amp;Ograve;"/>
        <xsl:output-character character="&#211;" string="&amp;Oacute;"/>
        <xsl:output-character character="&#212;" string="&amp;Ocirc;"/>
        <xsl:output-character character="&#213;" string="&amp;Otilde;"/>
        <xsl:output-character character="&#214;" string="&amp;Ouml;"/>
        <xsl:output-character character="&#215;" string="&amp;times;"/>
        <xsl:output-character character="&#216;" string="&amp;Oslash;"/>
        <xsl:output-character character="&#217;" string="&amp;Ugrave;"/>
        <xsl:output-character character="&#218;" string="&amp;Uacute;"/>
        <xsl:output-character character="&#219;" string="&amp;Ucirc;"/>
        <xsl:output-character character="&#220;" string="&amp;Uuml;"/>
        <xsl:output-character character="&#221;" string="&amp;Yacute;"/>
        <xsl:output-character character="&#222;" string="&amp;THORN;"/>
        <xsl:output-character character="&#223;" string="&amp;szlig;"/>
        <xsl:output-character character="&#224;" string="&amp;agrave;"/>
        <xsl:output-character character="&#225;" string="&amp;aacute;"/>
        <xsl:output-character character="&#226;" string="&amp;acirc;"/>
        <xsl:output-character character="&#227;" string="&amp;atilde;"/>
        <xsl:output-character character="&#228;" string="&amp;auml;"/>
        <xsl:output-character character="&#229;" string="&amp;aring;"/>
        <xsl:output-character character="&#230;" string="&amp;aelig;"/>
        <xsl:output-character character="&#231;" string="&amp;ccedil;"/>
        <xsl:output-character character="&#232;" string="&amp;egrave;"/>
        <xsl:output-character character="&#233;" string="&amp;eacute;"/>
        <xsl:output-character character="&#234;" string="&amp;ecirc;"/>
        <xsl:output-character character="&#235;" string="&amp;euml;"/>
        <xsl:output-character character="&#236;" string="&amp;igrave;"/>
        <xsl:output-character character="&#237;" string="&amp;iacute;"/>
        <xsl:output-character character="&#238;" string="&amp;icirc;"/>
        <xsl:output-character character="&#239;" string="&amp;iuml;"/>
        <xsl:output-character character="&#240;" string="&amp;eth;"/>
        <xsl:output-character character="&#241;" string="&amp;ntilde;"/>
        <xsl:output-character character="&#242;" string="&amp;ograve;"/>
        <xsl:output-character character="&#243;" string="&amp;oacute;"/>
        <xsl:output-character character="&#244;" string="&amp;ocirc;"/>
        <xsl:output-character character="&#245;" string="&amp;otilde;"/>
        <xsl:output-character character="&#246;" string="&amp;ouml;"/>
        <xsl:output-character character="&#247;" string="&amp;divide;"/>
        <xsl:output-character character="&#248;" string="&amp;oslash;"/>
        <xsl:output-character character="&#249;" string="&amp;ugrave;"/>
        <xsl:output-character character="&#250;" string="&amp;uacute;"/>
        <xsl:output-character character="&#251;" string="&amp;ucirc;"/>
        <xsl:output-character character="&#252;" string="&amp;uuml;"/>
        <xsl:output-character character="&#253;" string="&amp;yacute;"/>
        <xsl:output-character character="&#254;" string="&amp;thorn;"/>
        <xsl:output-character character="&#255;" string="&amp;yuml;"/>
        <xsl:output-character character="&#338;" string="&amp;OElig;"/>
        <xsl:output-character character="&#339;" string="&amp;oelig;"/>
        <xsl:output-character character="&#352;" string="&amp;Scaron;"/>
        <xsl:output-character character="&#353;" string="&amp;scaron;"/>
        <xsl:output-character character="&#376;" string="&amp;Yuml;"/>
        <xsl:output-character character="&#402;" string="&amp;fnof;"/>
        <xsl:output-character character="&#710;" string="&amp;circ;"/>
        <xsl:output-character character="&#732;" string="&amp;tilde;"/>
        <xsl:output-character character="&#913;" string="&amp;Alpha;"/>
        <xsl:output-character character="&#914;" string="&amp;Beta;"/>
        <xsl:output-character character="&#915;" string="&amp;Gamma;"/>
        <xsl:output-character character="&#916;" string="&amp;Delta;"/>
        <xsl:output-character character="&#917;" string="&amp;Epsilon;"/>
        <xsl:output-character character="&#918;" string="&amp;Zeta;"/>
        <xsl:output-character character="&#919;" string="&amp;Eta;"/>
        <xsl:output-character character="&#920;" string="&amp;Theta;"/>
        <xsl:output-character character="&#921;" string="&amp;Iota;"/>
        <xsl:output-character character="&#922;" string="&amp;Kappa;"/>
        <xsl:output-character character="&#923;" string="&amp;Lambda;"/>
        <xsl:output-character character="&#924;" string="&amp;Mu;"/>
        <xsl:output-character character="&#925;" string="&amp;Nu;"/>
        <xsl:output-character character="&#926;" string="&amp;Xi;"/>
        <xsl:output-character character="&#927;" string="&amp;Omicron;"/>
        <xsl:output-character character="&#928;" string="&amp;Pi;"/>
        <xsl:output-character character="&#929;" string="&amp;Rho;"/>
        <xsl:output-character character="&#931;" string="&amp;Sigma;"/>
        <xsl:output-character character="&#932;" string="&amp;Tau;"/>
        <xsl:output-character character="&#933;" string="&amp;Upsilon;"/>
        <xsl:output-character character="&#934;" string="&amp;Phi;"/>
        <xsl:output-character character="&#935;" string="&amp;Chi;"/>
        <xsl:output-character character="&#936;" string="&amp;Psi;"/>
        <xsl:output-character character="&#937;" string="&amp;Omega;"/>
        <xsl:output-character character="&#945;" string="&amp;alpha;"/>
        <xsl:output-character character="&#946;" string="&amp;beta;"/>
        <xsl:output-character character="&#947;" string="&amp;gamma;"/>
        <xsl:output-character character="&#948;" string="&amp;delta;"/>
        <xsl:output-character character="&#949;" string="&amp;epsilon;"/>
        <xsl:output-character character="&#950;" string="&amp;zeta;"/>
        <xsl:output-character character="&#951;" string="&amp;eta;"/>
        <xsl:output-character character="&#952;" string="&amp;theta;"/>
        <xsl:output-character character="&#953;" string="&amp;iota;"/>
        <xsl:output-character character="&#954;" string="&amp;kappa;"/>
        <xsl:output-character character="&#955;" string="&amp;lambda;"/>
        <xsl:output-character character="&#956;" string="&amp;mu;"/>
        <xsl:output-character character="&#957;" string="&amp;nu;"/>
        <xsl:output-character character="&#958;" string="&amp;xi;"/>
        <xsl:output-character character="&#959;" string="&amp;omicron;"/>
        <xsl:output-character character="&#960;" string="&amp;pi;"/>
        <xsl:output-character character="&#961;" string="&amp;rho;"/>
        <xsl:output-character character="&#962;" string="&amp;sigmaf;"/>
        <xsl:output-character character="&#963;" string="&amp;sigma;"/>
        <xsl:output-character character="&#964;" string="&amp;tau;"/>
        <xsl:output-character character="&#965;" string="&amp;upsilon;"/>
        <xsl:output-character character="&#966;" string="&amp;phi;"/>
        <xsl:output-character character="&#967;" string="&amp;chi;"/>
        <xsl:output-character character="&#968;" string="&amp;psi;"/>
        <xsl:output-character character="&#969;" string="&amp;omega;"/>
        <xsl:output-character character="&#977;" string="&amp;thetasym;"/>
        <xsl:output-character character="&#978;" string="&amp;upsih;"/>
        <xsl:output-character character="&#982;" string="&amp;piv;"/>
        <xsl:output-character character="&#8194;" string="&amp;ensp;"/>
        <xsl:output-character character="&#8195;" string="&amp;emsp;"/>
        <xsl:output-character character="&#8201;" string="&amp;thinsp;"/>
        <xsl:output-character character="&#8204;" string="&amp;zwnj;"/>
        <xsl:output-character character="&#8205;" string="&amp;zwj;"/>
        <xsl:output-character character="&#8206;" string="&amp;lrm;"/>
        <xsl:output-character character="&#8207;" string="&amp;rlm;"/>
        <xsl:output-character character="&#8211;" string="&amp;ndash;"/>
        <xsl:output-character character="&#8212;" string="&amp;mdash;"/>
        <xsl:output-character character="&#8216;" string="&amp;lsquo;"/>
        <xsl:output-character character="&#8217;" string="&amp;rsquo;"/>
        <xsl:output-character character="&#8218;" string="&amp;sbquo;"/>
        <xsl:output-character character="&#8220;" string="&amp;ldquo;"/>
        <xsl:output-character character="&#8221;" string="&amp;rdquo;"/>
        <xsl:output-character character="&#8222;" string="&amp;bdquo;"/>
        <xsl:output-character character="&#8224;" string="&amp;dagger;"/>
        <xsl:output-character character="&#8225;" string="&amp;Dagger;"/>
        <xsl:output-character character="&#8226;" string="&amp;bull;"/>
        <xsl:output-character character="&#8230;" string="&amp;hellip;"/>
        <xsl:output-character character="&#8240;" string="&amp;permil;"/>
        <xsl:output-character character="&#8242;" string="&amp;prime;"/>
        <xsl:output-character character="&#8243;" string="&amp;Prime;"/>
        <xsl:output-character character="&#8249;" string="&amp;lsaquo;"/>
        <xsl:output-character character="&#8250;" string="&amp;rsaquo;"/>
        <xsl:output-character character="&#8254;" string="&amp;oline;"/>
        <xsl:output-character character="&#8260;" string="&amp;frasl;"/>
        <xsl:output-character character="&#8364;" string="&amp;euro;"/>
        <xsl:output-character character="&#8465;" string="&amp;image;"/>
        <xsl:output-character character="&#8472;" string="&amp;weierp;"/>
        <xsl:output-character character="&#8476;" string="&amp;real;"/>
        <xsl:output-character character="&#8482;" string="&amp;trade;"/>
        <xsl:output-character character="&#8501;" string="&amp;alefsym;"/>
        <xsl:output-character character="&#8592;" string="&amp;larr;"/>
        <xsl:output-character character="&#8593;" string="&amp;uarr;"/>
        <xsl:output-character character="&#8594;" string="&amp;rarr;"/>
        <xsl:output-character character="&#8595;" string="&amp;darr;"/>
        <xsl:output-character character="&#8596;" string="&amp;harr;"/>
        <xsl:output-character character="&#8629;" string="&amp;crarr;"/>
        <xsl:output-character character="&#8656;" string="&amp;lArr;"/>
        <xsl:output-character character="&#8657;" string="&amp;uArr;"/>
        <xsl:output-character character="&#8658;" string="&amp;rArr;"/>
        <xsl:output-character character="&#8659;" string="&amp;dArr;"/>
        <xsl:output-character character="&#8660;" string="&amp;hArr;"/>
        <xsl:output-character character="&#8704;" string="&amp;forall;"/>
        <xsl:output-character character="&#8706;" string="&amp;part;"/>
        <xsl:output-character character="&#8707;" string="&amp;exist;"/>
        <xsl:output-character character="&#8709;" string="&amp;empty;"/>
        <xsl:output-character character="&#8711;" string="&amp;nabla;"/>
        <xsl:output-character character="&#8712;" string="&amp;isin;"/>
        <xsl:output-character character="&#8713;" string="&amp;notin;"/>
        <xsl:output-character character="&#8715;" string="&amp;ni;"/>
        <xsl:output-character character="&#8719;" string="&amp;prod;"/>
        <xsl:output-character character="&#8721;" string="&amp;sum;"/>
        <xsl:output-character character="&#8722;" string="&amp;minus;"/>
        <xsl:output-character character="&#8727;" string="&amp;lowast;"/>
        <xsl:output-character character="&#8730;" string="&amp;radic;"/>
        <xsl:output-character character="&#8733;" string="&amp;prop;"/>
        <xsl:output-character character="&#8734;" string="&amp;infin;"/>
        <xsl:output-character character="&#8736;" string="&amp;ang;"/>
        <xsl:output-character character="&#8743;" string="&amp;and;"/>
        <xsl:output-character character="&#8744;" string="&amp;or;"/>
        <xsl:output-character character="&#8745;" string="&amp;cap;"/>
        <xsl:output-character character="&#8746;" string="&amp;cup;"/>
        <xsl:output-character character="&#8747;" string="&amp;int;"/>
        <xsl:output-character character="&#8756;" string="&amp;there4;"/>
        <xsl:output-character character="&#8764;" string="&amp;sim;"/>
        <xsl:output-character character="&#8773;" string="&amp;cong;"/>
        <xsl:output-character character="&#8776;" string="&amp;asymp;"/>
        <xsl:output-character character="&#8800;" string="&amp;ne;"/>
        <xsl:output-character character="&#8801;" string="&amp;equiv;"/>
        <xsl:output-character character="&#8804;" string="&amp;le;"/>
        <xsl:output-character character="&#8805;" string="&amp;ge;"/>
        <xsl:output-character character="&#8834;" string="&amp;sub;"/>
        <xsl:output-character character="&#8835;" string="&amp;sup;"/>
        <xsl:output-character character="&#8836;" string="&amp;nsub;"/>
        <xsl:output-character character="&#8838;" string="&amp;sube;"/>
        <xsl:output-character character="&#8839;" string="&amp;supe;"/>
        <xsl:output-character character="&#8853;" string="&amp;oplus;"/>
        <xsl:output-character character="&#8855;" string="&amp;otimes;"/>
        <xsl:output-character character="&#8869;" string="&amp;perp;"/>
        <xsl:output-character character="&#8901;" string="&amp;sdot;"/>
        <xsl:output-character character="&#8968;" string="&amp;lceil;"/>
        <xsl:output-character character="&#8969;" string="&amp;rceil;"/>
        <xsl:output-character character="&#8970;" string="&amp;lfloor;"/>
        <xsl:output-character character="&#8971;" string="&amp;rfloor;"/>
        <xsl:output-character character="&#9001;" string="&amp;lang;"/>
        <xsl:output-character character="&#9002;" string="&amp;rang;"/>
        <xsl:output-character character="&#9674;" string="&amp;loz;"/>
        <xsl:output-character character="&#9824;" string="&amp;spades;"/>
        <xsl:output-character character="&#9827;" string="&amp;clubs;"/>
        <xsl:output-character character="&#9829;" string="&amp;hearts;"/>
        <xsl:output-character character="&#9830;" string="&amp;diams;"/>
    </xsl:character-map>
    
    <!-- 
        private use area mappings from 
            private static object ConvertEntities(string text)
        
        Note the 'loz' entity range here, and the '-' fallback:
            if (c == 0xf0b7 ||
                c == 0xf0a7 ||
                c == 0xf076 ||
                c == 0xf0d8 ||
                c == 0xf0a8 ||
                c == 0xf0fc ||
                c == 0xf0e0 ||
                c == 0xf0b2)
                return "bull";
            if (c >= 0xf000)
                return "loz";
            if (c >= 128)
            {
                string entity;
                if (EntityMap.TryGetValue(c, out entity))
                    return entity;
            }
            return "-";
    -->
    <xsl:character-map name="private-entity-map">
        <xsl:output-character character="&#xf0b7;" string="&amp;bull;"/>
        <xsl:output-character character="&#xf0a7;" string="&amp;bull;"/>
        <xsl:output-character character="&#xf076;" string="&amp;bull;"/>
        <xsl:output-character character="&#xf0d8;" string="&amp;bull;"/>
        <xsl:output-character character="&#xf0a8;" string="&amp;bull;"/>
        <xsl:output-character character="&#xf0fc;" string="&amp;bull;"/>
        <xsl:output-character character="&#xf0e0;" string="&amp;bull;"/>
        <xsl:output-character character="&#xf0b2;" string="&amp;bull;"/>
        <xsl:output-character character="&#xf000;" string="&amp;loz;"/>        
    </xsl:character-map>

</xsl:stylesheet>