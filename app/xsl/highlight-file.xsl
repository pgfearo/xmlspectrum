<?xml version="1.0" encoding="utf-8"?>
<!--
A frontend for XMLSpectrum by Phil Fearon Qutoric Limited 2012 (c)

http://qutoric.com
License: Apache 2.0 http://www.apache.org/licenses/LICENSE-2.0.html

Purpose: Syntax highlighter for XPath (text), XML, XSLT and XSD 1.1 file formats

Description:

Takes the input file specified in the sourcepath XSLT parameter and generates an
HTML output file and a CSS file. The input file may be 1 of 4 types:

1. XSLT 1.0 or 2.0
2. XSD 1.0 or 1.1
3. Generic XML
4. Plain-text XPath

Note that this file interface is a simple wrapper for xmlspectrum.xsl. This front-end
will auto-detect whether the file is XSLT, XSD or XPath based on well-formedness and
namespaces. If you're converting XML samples that are not well-formed or contained within
other XML you can code your own interface XSLT.

Dependencies:

1. xmlspectrum.xsl

Usage:

initial-template: 'main'
source-xml: (not used)
xsl parameters:
    sourcepath:  (path or URI for source file)
    light-theme: (yes|no) [Default:'no']
    css-path:    (path for output CSS)

Sample transform using Saxon-HE/Java on command-line (unbroken line):

java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main
-xsl:xsl/highlight-file.xsl sourcepath=../samples/xpathcolorer-x.xsl

-->

<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:loc="com.qutoric.sketchpath.functions"
xmlns:css="css-defs.com"
exclude-result-prefixes="loc f xs css"
xmlns=""
xmlns:f="internal">

<xsl:import href="xmlspectrum.xsl"/>

<xsl:param name="sourcepath" as="xs:string" select="'../samples/xpathcolorer-x.xsl'"/>

<xsl:param name="light-theme" select="'no'"/>
<xsl:param name="css-path" select="''"/>

<xsl:template name="main" match="/">

<xsl:variable name="xsl-xmlns" select="'http://www.w3.org/1999/XSL/Transform'"/>
<xsl:variable name="xsd-xmlns" select="'http://www.w3.org/2001/XMLSchema'"/>

<!-- if windows OS, convert path to URI -->
<xsl:variable name="sourceuri" select="if (matches($sourcepath, '^[A-Za-z]:'))
then concat('file:/', $sourcepath)
else $sourcepath"/>
<xsl:variable name="corrected-uri" select="replace($sourceuri,'\\','/')"/>


<xsl:variable name="is-xml" select="doc-available($corrected-uri)" as="xs:boolean"/>

<xsl:variable name="input-file" select="tokenize($corrected-uri, '/|\\')[last()]"/>

<xsl:variable name="root-element" select="if ($is-xml) then doc($corrected-uri)/* else ()"/>
<xsl:variable name="root-qname" select="if ($is-xml) then node-name($root-element) else ()" as="xs:QName?"/>

<xsl:variable name="root-prefix" select="if ($is-xml) 
then prefix-from-QName($root-qname) 
else ()"/>
<xsl:variable name="root-namespace" select="if ($is-xml) then namespace-uri-from-QName($root-qname) else ()"/>

<xsl:variable name="is-xsl" as="xs:boolean" select="$root-namespace eq $xsl-xmlns"/>

<xsl:variable name="file-content" as="xs:string" select="unparsed-text($corrected-uri)"/>

<xsl:result-document href="{concat('output/', $input-file, '.html')}" method="html" indent="no">
<html>
<head>
<title><xsl:value-of select="$input-file"/></title>
<link rel="stylesheet" type="text/css" href="{if ($css-path ne '')
then $css-path else 'theme.css'}"/>
</head>
<body>
<div>
<p class="spectrum">
<!-- Call to imported functions returns sequence of span elements
     with class attribute values used to colorise with CSS
-->
<xsl:choose>
<xsl:when test="$is-xml">
<!-- for case where XPath is embedded in XML text -->
<xsl:sequence select="f:render($file-content, $is-xsl, $root-prefix)"/>
</xsl:when>
<xsl:otherwise>
<!-- for case where XPath is standalone -->
<xsl:sequence select="loc:showXPath($file-content)"/>
</xsl:otherwise>
</xsl:choose>
</p>
</div>
</body>
</html>
</xsl:result-document>

<xsl:if test="$css-path eq ''">
<xsl:result-document href="{concat('output/', 'theme.css')}" method="text" indent="no">
<xsl:sequence select="f:get-css($light-theme eq 'yes')"/>
</xsl:result-document>
</xsl:if>

</xsl:template>

</xsl:stylesheet>
