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
<xsl:output indent="yes"/>
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

<xsl:variable name="root-element" select="if ($is-xml) then doc($corrected-uri)/* else ()"/>
<xsl:variable name="root-qname" select="if ($is-xml) then node-name($root-element) else ()" as="xs:QName?"/>

<xsl:variable name="root-prefix" select="if ($is-xml) 
then prefix-from-QName($root-qname) 
else ()"/>
<xsl:variable name="root-namespace" select="if ($is-xml) then namespace-uri-from-QName($root-qname) else ()"/>

<xsl:variable name="is-xsl" as="xs:boolean" select="$root-namespace eq $xsl-xmlns"/>



<xsl:choose>
<xsl:when test="$is-xml and $do-link">
<!--
<span class="av">baseuri: <xsl:value-of select="base-uri($root-element)"/></span>
-->

<xsl:variable name="all-files" as="xs:string*"
select="f:get-all-files(resolve-uri($corrected-uri, static-base-uri()), () )"/>


<xsl:variable name="root-path" as="xs:string*">
<xsl:call-template name="get-common-root">
<xsl:with-param name="all-files" select="$all-files" tunnel="yes"/>
<xsl:with-param name="index" select="1"/>
<xsl:with-param name="common-path" select="()"/>
</xsl:call-template>
</xsl:variable>

<xsl:variable name="root-length" select="string-length($root-path) + 1"/>
<!--
<test>
<one>hello: <xsl:value-of select="$common-path-length"/></one>
</test>
-->

<xsl:variable name="all" as="element()">
<all>
<xsl:for-each select="$all-files">
<file path="{substring(., $root-length + 1)}">
<xsl:variable name="all-spans" as="node()*">
<xsl:call-template name="get-result-spans">
<xsl:with-param name="input-uri" select="."/>
<xsl:with-param name="is-xml" select="$is-xml" as="xs:boolean"/>
<xsl:with-param name="is-xsl" select="$is-xsl" as="xs:boolean"/>
<xsl:with-param name="indent-size" select="$indent-size" as="xs:integer"/>
<xsl:with-param name="root-prefix" select="$root-prefix"/>
</xsl:call-template>
</xsl:variable>

<xsl:variable name="xmlns" as="element()*" select="f:get-xmlns($all-spans)"/>

<global-declarations>
<xsl:sequence select="f:get-globals(., $root-length, $xmlns)"/>
</global-declarations>


<spans>
<xsl:sequence select="$all-spans"/>
</spans>

<namespaces>
<xsl:sequence select="$xmlns"/>
</namespaces>

<!--
<xsl:variable name="target-spans" as="element()*"
select="f:target($all-spans, $xmlns, $globals)"/>

<xsl:call-template name="output-html-doc">
<xsl:with-param name="result-spans" select="$target-spans"/>
<xsl:with-param name="filename" select="substring(., $root-length)"/>
<xsl:with-param name="css-path" select="$css-path"/>
</xsl:call-template>

-->
</file>
</xsl:for-each>
</all>
</xsl:variable>

<!--
<test>
<xsl:for-each select="$all/file">
<file path="{@path}">
<xsl:sequence select="globals"/>
<xsl:sequence select="xmlns"/>
</file>
</xsl:for-each>
</test>

-->

<xsl:for-each select="$all/file">

<xsl:variable name="target-spans" as="element()*"
select="f:target(spans, namespaces, global-declarations)"/>

<xsl:call-template name="output-html-doc">
<xsl:with-param name="result-spans" select="$target-spans"/>
<xsl:with-param name="filename" select="@path"/>
<xsl:with-param name="css-path" select="$css-path"/>
</xsl:call-template>

</xsl:for-each>


</xsl:when>
<xsl:otherwise>
<xsl:variable name="result-spans" as="node()*">
<xsl:call-template name="get-result-spans">
<xsl:with-param name="input-uri" select="$corrected-uri"/>
<xsl:with-param name="is-xml" select="$is-xml" as="xs:boolean"/>
<xsl:with-param name="is-xsl" select="$is-xsl" as="xs:boolean"/>
<xsl:with-param name="indent-size" select="$indent-size" as="xs:integer"/>
<xsl:with-param name="root-prefix" select="$root-prefix"/>
</xsl:call-template>
</xsl:variable>

<xsl:variable name="file-only" select="f:file-from-uri($corrected-uri)"/>

<xsl:call-template name="output-html-doc">
<xsl:with-param name="result-spans" select="$result-spans"/>
<xsl:with-param name="filename" select="$file-only"/>
<xsl:with-param name="css-path" select="$css-path"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>

<xsl:if test="$css-path eq ''">
<xsl:result-document href="{concat('output/', 'theme.css')}" method="text" indent="no">
<xsl:sequence select="f:get-css($light-theme eq 'yes')"/>
</xsl:result-document>
</xsl:if>

</xsl:template>

<xsl:template name="get-common-root" as="xs:string">
<xsl:param name="all-files" as="xs:string*" tunnel="yes" />
<xsl:param name="index" as="xs:integer"/>
<xsl:param name="common-path" as="xs:string*"/>


<xsl:variable name="current-file" select="tokenize($all-files[$index],'/')"/>

<xsl:variable name="min-file" as="xs:string*"
select="if ($index eq 1) then
    $current-file
else (f:min-common-item($common-path, $current-file))"/>

<xsl:choose>
<xsl:when test="$index lt count($all-files)">
<xsl:call-template name="get-common-root">
<xsl:with-param name="index" select="$index + 1"/>
<xsl:with-param name="common-path" select="$min-file"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:sequence select="string-join($min-file, '/')"/>
</xsl:otherwise>
</xsl:choose>

</xsl:template>

<xsl:function name="f:min-common-item" as="xs:string*">
<xsl:param name="min" as="xs:string*"/>
<xsl:param name="new" as="xs:string*"/>


<xsl:for-each select="1 to count($min)">
<xsl:variable name="x" select="xs:integer(.)" as="xs:integer"/>
<xsl:if test="$min[$x] eq $new[$x]">
<xsl:value-of select="$min[$x]"/>
</xsl:if>
</xsl:for-each>

</xsl:function>

<xsl:function name="f:get-all-files" as="xs:string*">
<xsl:param name="new-uri" as="xs:string*"/>
<xsl:param name="uri-list" as="xs:string*"/>

<xsl:variable name="add-uri" as="xs:string*"
select="for $file in $new-uri return
if ($file = ($uri-list)) then () else $file"/>

<xsl:variable name="new-externals" as="xs:string*">
<xsl:for-each select="$add-uri">
<xsl:variable name="doc" select="doc(.)"/>
<xsl:for-each select="$doc/*/xsl:import/@href|$doc/*/xsl:include/@href">
<xsl:value-of select="resolve-uri(., base-uri($doc))"/>
</xsl:for-each>
</xsl:for-each>
</xsl:variable>

<xsl:variable name="concat-sequence" select="($uri-list, $add-uri)"/>

<xsl:choose>
<xsl:when test="exists($new-externals)">
<xsl:sequence select="f:get-all-files($new-externals, $concat-sequence)"/>
</xsl:when>
<xsl:otherwise>
<xsl:sequence select="$concat-sequence"/>
</xsl:otherwise>
</xsl:choose>

</xsl:function>


<!--
sample globals element:
<globals>
<file path="sample/test1.xsl">
<function name="do-something" ns="internal"/>
<function name="somethin-else" ns="internal"/>
<template name="output-days" ns=""/>
<variable name="my-global" ns=""/>
</file>
<file path="sample/test21.xsl">
<function name="do-something" ns="internal"/>
<function name="somethin-else" ns="internal"/>
<template name="output-days" ns=""/>
<variable name="my-global" ns=""/>
</file>
</globals>

-->

<xsl:function name="f:get-globals" as="element()*">
<xsl:param name="file-uri" as="xs:string"/>
<xsl:param name="root-length" as="xs:integer"/>
<xsl:param name="xmlns" as="element()"/>

<xsl:variable name="doc" select="doc($file-uri)"/>
<globals path="{substring($file-uri, $root-length + 1)}">
<xsl:apply-templates select="$doc/*/xsl:template[@name]|
$doc/*/xsl:function|
$doc/*/xsl:variable" mode="globals">
<xsl:with-param name="xmlns" select="$xmlns" tunnel="yes" as="element()"/>
</xsl:apply-templates>

</globals>

</xsl:function>

<xsl:template match="xsl:template|xsl:function|xsl:variable" mode="globals">
<xsl:param name="xmlns" as="element()" tunnel="yes"/>
<xsl:variable name="after-colon" select="substring-after(@name, ':')"/>
<xsl:variable name="local" select="if ($after-colon eq '') then @name else $after-colon"/>
<xsl:variable name="prefix" select="substring-before(@name, ':')"/>
<xsl:variable name="ns-uri" select="if ($prefix eq '') then ''
else $xmlns/ns[@prefix eq $prefix]/@uri"/>

<xsl:element name="{local-name(.)}">
<xsl:attribute name="name" select="$local"/>
<xsl:attribute name="ns" select="$ns-uri"/>
</xsl:element>
</xsl:template>

<xsl:template name="output-html-doc">
<xsl:param name="result-spans" as="element()*"/>
<xsl:param name="filename"/>
<xsl:param name="css-path"/>

<xsl:variable name="file-only" select="f:file-from-uri($filename)"/>

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
<xsl:sequence select="$result-spans"/>
</p>
</div>
</body>
</html>
</xsl:result-document>

</xsl:template>

<xsl:function name="f:file-from-uri">
<xsl:param name="uri"/>
<xsl:value-of select="tokenize($uri, '/|\\')[last()]"/>
</xsl:function>



<xsl:template name="get-result-spans">
<xsl:param name="input-uri" as="xs:string"/>
<xsl:param name="is-xml" as="xs:boolean"/>
<xsl:param name="is-xsl" as="xs:boolean"/>
<xsl:param name="indent-size" as="xs:integer"/>
<xsl:param name="root-prefix"/>

<xsl:variable name="file-content" as="xs:string" select="unparsed-text($input-uri)"/>
<xsl:variable name="file-only" select="f:file-from-uri($input-uri)"/>

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
</xsl:template>

</xsl:stylesheet>
