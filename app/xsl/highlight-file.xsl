<?xml version="1.0" encoding="utf-8"?>
<!--
A frontend for XMLSpectrum by Phil Fearon Qutoric Limited 2012 (c)

http://qutoric.com
License: Apache 2.0 http://www.apache.org/licenses/LICENSE-2.0.html

Purpose: Syntax highlighter for XPath (text), XML, XSLT and XSD 1.1 file formats

Description:

A sample XSLT stylesheet that exploits xmlspectrum.xsl

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

<xsl:param name="sourcepath" as="xs:string" select="''"/>
<!--  by default - rely on original indentation -->
<xsl:param name="indent" as="xs:string" select="'-1'"/>

<xsl:param name="light-theme" select="'no'"/>
<xsl:param name="css-path" select="''"/>
<xsl:param name="auto-trim" select="'no'"/>
<xsl:param name="link-names" select="'no'"/>


<xsl:variable name="do-trim" select="$auto-trim eq 'yes'"/>
<xsl:variable name="do-link" select="$link-names eq 'yes'"/>
<xsl:variable name="indent-size" select="xs:integer($indent)"/>

<xsl:template name="main" match="/">
<xsl:param name="sourceuri" select="$sourcepath"/>

<xsl:variable name="xsl-xmlns" select="'http://www.w3.org/1999/XSL/Transform'"/>
<xsl:variable name="xsd-xmlns" select="'http://www.w3.org/2001/XMLSchema'"/>

<!-- if windows OS, convert path to URI -->
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

<xsl:variable name="result-doc" as="node()*">
<xsl:call-template name="get-result-doc">
<xsl:with-param name="file-content" select="$file-content"/>
<xsl:with-param name="is-xml" select="$is-xml" as="xs:boolean"/>
<xsl:with-param name="is-xsl" select="$is-xsl" as="xs:boolean"/>
<xsl:with-param name="do-trim" select="$do-trim" as="xs:boolean"/>
<xsl:with-param name="indent-size" select="$indent-size" as="xs:integer"/>
<xsl:with-param name="root-element" select="$root-element" as="element()?"/>
<xsl:with-param name="root-prefix" select="$root-prefix"/>
</xsl:call-template>
</xsl:variable>

<xsl:call-template name="output-html-doc">
<xsl:with-param name="result-doc" select="$result-doc"/>
<xsl:with-param name="filename" select="$input-file"/>
<xsl:with-param name="css-path" select="$css-path"/>
</xsl:call-template>


<xsl:if test="$css-path eq ''">
<xsl:result-document href="{concat('output/', 'theme.css')}" method="text" indent="no">
<xsl:sequence select="f:get-css($light-theme eq 'yes')"/>
</xsl:result-document>
</xsl:if>

</xsl:template>

<xsl:template name="output-html-doc">
<xsl:param name="result-doc" as="element()*"/>
<xsl:param name="filename"/>
<xsl:param name="css-path"/>

<xsl:variable name="file-only"
select="for $file in substring-after($filename, '/') return
if ($file eq '') then 
    $filename 
else $file"/>

<xsl:result-document href="{concat('output/', $filename, '.html')}" method="html" indent="no">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
<html>
<head>
<title><xsl:value-of select="$file-only"/></title>
<link rel="stylesheet" type="text/css" href="{if ($css-path ne '')
then $css-path else 'theme.css'}"/>
</head>
<body>
<div>
<p class="spectrum">
<!-- Call to imported functions returns sequence of span elements
     with class attribute values used to colorise with CSS
-->
<xsl:sequence select="$result-doc"/>
</p>
</div>
</body>
</html>
</xsl:result-document>

</xsl:template>

<xsl:template name="get-result-doc">
<xsl:param name="file-content" as="xs:string"/>
<xsl:param name="is-xml" as="xs:boolean"/>
<xsl:param name="is-xsl" as="xs:boolean"/>
<xsl:param name="do-trim" as="xs:boolean"/>
<xsl:param name="indent-size" as="xs:integer"/>
<xsl:param name="root-element" as="element()?"/>
<xsl:param name="root-prefix"/>

<xsl:variable name="out-spans" as="element()*">
<xsl:choose>
<xsl:when test="$is-xml and $indent-size lt 0 and not($do-trim)">
<!-- for case where XPath is embedded in XML text -->
<xsl:sequence select="f:render($file-content, $is-xsl, $root-prefix)"/>
</xsl:when>
<xsl:when test="$is-xml">
<!-- for case where XPath is embedded in XML text and indentation required -->
<xsl:variable name="spans" select="f:render($file-content, $is-xsl, $root-prefix)"/>
<xsl:variable name="real-indent" select="if ($indent-size lt 0) then 0 else $indent-size"
as="xs:integer"/>
<xsl:sequence select="f:indent($spans, $real-indent, $do-trim)"/>
</xsl:when>
<xsl:otherwise>
<!-- for case where XPath is standalone -->
<xsl:sequence select="loc:showXPath($file-content)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:choose>
<xsl:when test="$is-xml and $do-link">
<!--
<xsl:variable name="xmlns" select="f:get-xmlns($out-spans)"/>
<xsl:for-each select="$xmlns">
<span class="av">&#10;xmlns&#10;</span>
<span class="atn">@prefix <xsl:value-of select="@prefix"/></span>
<span class="av"> @uri <xsl:value-of select="@uri"/></span>
</xsl:for-each>

-->
<span class="av">baseuri: <xsl:value-of select="base-uri($root-element)"/></span>
<xsl:variable name="target-result" select="f:target($out-spans)"/>
<!--
<span class="av">count-x: <xsl:value-of select="$target-result/xmlns/ns/@uri"/></span>
-->
<xsl:sequence select="$target-result/spans"/>
</xsl:when>
<xsl:otherwise>
<xsl:sequence select="$out-spans"/>
</xsl:otherwise>
</xsl:choose>

</xsl:template>

</xsl:stylesheet>
