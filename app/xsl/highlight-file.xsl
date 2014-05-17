<?xml version="1.0" encoding="utf-8"?>
<!--
A frontend for XMLSpectrum by Phil Fearon Qutoric Limited 2012 (c)

http://qutoric.com
License: Apache 2.0 http://www.apache.org/licenses/LICENSE-2.0.html

Purpose: Syntax highlighter for XPath (text), XML, XSLT and XSD 1.1 file formats

Description:

A sample XSLT stylesheet that exploits xmlspectrum.xsl

Takes the input file specified in the sourcepath XSLT parameter and generates an
HTML output file ( plus also include/import files if link-names=yes ) and a CSS file.

The input file may be 1 of 4 types:

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
    sourcepath:  path or URI for source file
    color-theme: name of color-theme - default is 'solarized dark'
    link-names:  (yes|no) [Default:'no']
                 processes all linked xsl files and adds hrefs
                 for variables, functions, parameters and named templates
    css-path:    (path for output CSS)
    output-path: path in which to create html files - default is 'output/'
    output-method: [html|xml] default:html - for xml, no css file is created

Sample transform using Saxon-HE/Java on command-line (unbroken line):

java -cp "C:\Program Files (x86)\Saxon\saxon9he.jar" net.sf.saxon.Transform -t -it:main
-xsl:xsl/highlight-file.xsl sourcepath=../samples/xpathcolorer-x.xsl

-->

<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:loc="com.qutoric.sketchpath.functions"
xmlns:css="css-defs.com"
xmlns:xqf="urn:xq.internal-function"
exclude-result-prefixes="loc f xs css xqf"
xpath-default-namespace="http://www.w3.org/1999/xhtml"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:f="internal">

<xsl:import href="xmlspectrum.xsl"/>
<xsl:import href="xq-spectrum.xsl"/>
<xsl:import href="make-toc.xsl"/>

<xsl:output indent="no" method="html"/>
<xsl:param name="sourcepath" as="xs:string" select="''"/>
<!--  by default - rely on original indentation -->
<xsl:param name="indent" as="xs:string" select="'-1'"/>

<xsl:param name="color-theme" select="'dark'"/>
<xsl:param name="css-path" select="''"/>
<xsl:param name="auto-trim" select="'no'"/>
<xsl:param name="link-names" select="'no'"/>
<xsl:param name="output-path" select="'output/'"/>
<xsl:param name="format-mixed-content" select="'no'"/>
<!-- set value to 'scp' for source-code-pro font -->
<xsl:param name="font-name" select="'scp'"/>
<!-- set value to 'xml' or 'xhtml' for use in XProc step -->
<xsl:param name="output-method" select="'html'"/>
<!-- set value to 'yes' to embed css inline with element -->
<xsl:param name="css-inline" select="'no'"/>
<!-- identifies xslt/schematron/xproc etc - not required if root namespace can be used -->
<xsl:param name="document-type" select="''"/>
<xsl:param name="document-type-prefix" select="''"/>
<!-- 
w3c-xpath-functions-uri is use to add hyperlinks to built-in
xpath functions when 'link-names' = 'yes'
set uri to a proxy server storing the W3C resource to avoid
excessive calls to the W3C server
 -->
<xsl:param name="w3c-xpath-functions-uri"
select="'http://www.w3.org/TR/xpath-functions/'"/>

<xsl:variable name="do-trim" select="$auto-trim eq 'yes'"/>
<xsl:variable name="do-link" select="$link-names eq 'yes'"/>
<xsl:variable name="indent-size" select="xs:integer($indent)"/>
<xsl:variable name="css-name" select="'theme.css'"/>
<xsl:variable name="do-output-path"
select="for $c in f:path-to-uri($output-path) return
if (ends-with($c, '/') or ends-with($c, '\'))
then $c
else concat($c, '/')
"/>

<!-- use only if file is know to be well-formed, otherwise use 'main' template -->
<xsl:template match="/">

<xsl:variable name="root-qname" select="node-name(*)" as="xs:QName"/>
<xsl:variable name="root-prefix" select="(prefix-from-QName($root-qname), '')[1]"/>
<xsl:variable name="root-namespace" select="namespace-uri-from-QName($root-qname)"/>
<xsl:variable name="doctype" as="xs:string"
select="if ($document-type ne '') then
$document-type
else f:doctype-from-xmlns(*/namespace-uri())"/>


<xsl:variable name="all-spans" as="node()*">
<xsl:call-template name="get-result-spans">
<xsl:with-param name="input-uri" select="base-uri()"/>
<xsl:with-param name="is-xml" select="true()" as="xs:boolean"/>
<xsl:with-param name="doctype" select="$doctype" as="xs:string"/>
<xsl:with-param name="indent-size" select="$indent-size" as="xs:integer"/>
<xsl:with-param name="root-prefix" 
select="if ($document-type-prefix ne '') then $document-type-prefix
else $root-prefix"/>
</xsl:call-template>
</xsl:variable>

<xsl:message>
<xsl:value-of select="'processing', count($all-spans), 'tokens for', base-uri(), 'css-inline:', $css-inline"/>
</xsl:message>
<xsl:message>------------------------------------------------</xsl:message>
<xsl:message select="'auto-trim: ', $auto-trim, ' indent: ', $indent"/>
<xsl:message select="'output-path: ', $output-path, ' doctype: ', $doctype, ' root-prefix: ', $root-prefix"/>


<xsl:if test="$output-method eq 'html'">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
</xsl:if>
<html>
<head>
<title><xsl:value-of select="'XMLSpectrum output'"/></title>
<xsl:if test="$css-inline eq 'no'">
<style type="text/css"><xsl:sequence select="f:get-css()"/></style>
</xsl:if>
<xsl:if test="$font-name eq 'scp' and $css-inline eq 'yes'">
<style>
@import url(http://fonts.googleapis.com/css?family=Source+Code+Pro);</style>
</xsl:if>
</head>
<body>
<div>
<pre class="spectrum">
<xsl:if test="$css-inline eq 'yes'">
<xsl:attribute name="style" select="f:inline-css-main()"/>
</xsl:if>
<!-- Call to imported functions returns sequence of span elements
     with class attribute values used to colorise with CSS
-->
<xsl:sequence select="$all-spans"/>
</pre>
</div>
</body>
</html>

</xsl:template>

<xsl:template name="main">
<xsl:param name="sourceuri" select="$sourcepath"/>
<!-- if windows OS, convert path to URI -->
<xsl:variable name="corrected-uri1" select="replace($sourceuri,'\\','/')"/>
<xsl:variable name="uri-tokens" select="tokenize($corrected-uri1, '/')" as="xs:string*"/>
<xsl:variable name="filename" select="$uri-tokens[last()]"/>
<xsl:variable name="encoded-filename" select="encode-for-uri($filename)"/>
<xsl:variable name="directory" select="substring($corrected-uri1, 1, string-length($corrected-uri1) - string-length($filename))"/>
<xsl:variable name="corrected-uri" select="concat($directory, $encoded-filename)"/>


<xsl:variable name="is-xml" as="xs:boolean"
select="doc-available($corrected-uri) and not($document-type = ('xquery','xpath'))"/>

<xsl:variable name="root-element" select="if ($is-xml) then doc($corrected-uri)/* else ()"/>
<xsl:variable name="root-qname" select="if ($is-xml) then node-name($root-element) else ()" as="xs:QName?"/>

<xsl:variable name="root-prefix" 
select="if ($document-type-prefix ne '') then
$document-type-prefix
else if ($is-xml) 
then ((prefix-from-QName($root-qname), '')[1]) 
else ''"/>
<xsl:variable name="root-namespace" select="if ($is-xml) then namespace-uri-from-QName($root-qname) else ()"/>

<xsl:variable name="doctype" as="xs:string"
select="if ($document-type ne '') then
$document-type
else if ($is-xml) then
f:doctype-from-xmlns($root-namespace)
else ''"/>

<xsl:variable name="is-xsl" as="xs:boolean" select="$doctype = ('xslt','xsl')"/>
<xsl:message select="'auto-trim: ', $auto-trim, ' indent: ', $indent"/>
<xsl:message select="'output-path: ', $output-path, ' doctype: ', $doctype, ' root-prefix: ', $root-prefix"/>

<xsl:choose>
<xsl:when test="$is-xsl and $do-link">

<xsl:variable name="all-files" as="xs:string*"
select="f:get-all-files(resolve-uri($corrected-uri, static-base-uri()), () )"/>

<xsl:variable name="root-path" as="xs:string*">
<xsl:call-template name="get-common-root">
<xsl:with-param name="all-files" select="$all-files" tunnel="yes"/>
<xsl:with-param name="index" select="1"/>
<xsl:with-param name="common-path" select="()"/>
</xsl:call-template>
</xsl:variable>

<xsl:variable name="joined-path" select="string-join($root-path, '/')"/>

<xsl:variable name="root-length" select="string-length($joined-path) + 1"/>

<xsl:variable name="globals" as="element()">
<globals>
<xsl:for-each select="$all-files">
<file path="{substring(., $root-length + 1)}">
<uri><xsl:value-of select="."/></uri>
<xsl:sequence select="f:get-globals(.)"/>
</file>
</xsl:for-each>
</globals>
</xsl:variable>
<xsl:message>------------------------------------------------</xsl:message>
<xsl:for-each select="$globals/file">

<xsl:message><xsl:value-of select="'tokenizing', @path, '...'"/></xsl:message>
<xsl:variable name="full-uri" select="if (not(starts-with(uri, 'file:/'))) then
    concat('file:/', uri)
else uri"/>

<xsl:variable name="all-spans" as="node()*">
<xsl:call-template name="get-result-spans">
<xsl:with-param name="input-uri" select="$full-uri"/>
<xsl:with-param name="is-xml" select="$is-xml" as="xs:boolean"/>
<xsl:with-param name="doctype" select="$doctype" as="xs:string"/>
<xsl:with-param name="indent-size" select="$indent-size" as="xs:integer"/>
<xsl:with-param name="root-prefix" select="doc-prefix"/>
</xsl:call-template>
</xsl:variable>

<xsl:message>
<xsl:value-of select="'processing', count($all-spans), 'tokens for', @path"/>
</xsl:message>

<xsl:variable name="ancestor-length" select="count(tokenize(@path, '/')) - 1" as="xs:integer"/>
<xsl:variable name="ancestor-path" select="f:ancestor-path($ancestor-length)"/>

<xsl:variable name="xmlns" as="element()" select="f:get-xmlns($all-spans)"/>

<!-- note: removed tunel on spans param as this caused 32% performance degrade -->
<xsl:variable name="spans" as="element()*">
<xsl:call-template name="wrap-spans">
<xsl:with-param name="spans" as="node()*" select="$all-spans"/>
<xsl:with-param name="globals" select="$globals" tunnel="yes" as="element()"/>
<xsl:with-param name="xmlns" select="$xmlns" tunnel="yes" as="element()"/>
<xsl:with-param name="index" select="1" as="xs:integer"/>
<xsl:with-param name="path-length" select="$ancestor-path" as="xs:string" tunnel="yes"/>
</xsl:call-template>
</xsl:variable>

<xsl:variable name="css-link" select="f:get-css-link(@path)"/>

<xsl:call-template name="output-html-doc">
<xsl:with-param name="result-spans" select="$spans"/>
<xsl:with-param name="filename" select="@path"/>
<xsl:with-param name="css-link" select="$css-link"/>
<xsl:with-param name="html-path" select="$do-output-path"/>
</xsl:call-template>

</xsl:for-each>

<xsl:variable name="css-link" select="f:get-css-link('rootlevel')"/>

<xsl:call-template name="create-toc">
<xsl:with-param name="globals" select="$globals" as="element()" tunnel="yes"/>
<xsl:with-param name="path" select="$do-output-path"/>
<xsl:with-param name="css-link" select="$css-link"/>
<xsl:with-param name="output-method" select="$output-method"/>
<xsl:with-param name="is-css-inline" as="xs:boolean" select="$css-inline eq 'yes'"/>
</xsl:call-template>

</xsl:when>


<xsl:otherwise>
<xsl:variable name="result-spans" as="node()*">
<xsl:call-template name="get-result-spans">
<xsl:with-param name="input-uri" select="$corrected-uri"/>
<xsl:with-param name="is-xml" select="$is-xml" as="xs:boolean"/>
<xsl:with-param name="doctype" select="$doctype" as="xs:string"/>
<xsl:with-param name="indent-size" select="$indent-size" as="xs:integer"/>
<xsl:with-param name="root-prefix" select="$root-prefix"/>
</xsl:call-template>
</xsl:variable>

<xsl:variable name="spans" as="element()*">
<xsl:choose>
<xsl:when test="$do-link">
<xsl:call-template name="wrap-spans-only">
<xsl:with-param name="spans" as="node()*" select="$result-spans"/>
<xsl:with-param name="index" select="1" as="xs:integer"/>
</xsl:call-template>
</xsl:when>
<xsl:otherwise>
<xsl:sequence select="$result-spans"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>


<xsl:variable name="file-only" select="f:file-from-uri($corrected-uri)"/>

<xsl:call-template name="output-html-doc">
<xsl:with-param name="result-spans" select="$spans"/>
<xsl:with-param name="filename" select="if ($file-only ne '') then $file-only
else 'xms-output'"/>
<xsl:with-param name="css-link"
select="if ($css-path eq '') then 
$css-name
else $css-path"/>
<xsl:with-param name="html-path" select="$do-output-path"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>

<xsl:if test="$css-path eq '' and $output-method ne 'xml' and $css-inline eq 'no'">
<xsl:result-document href="{concat($do-output-path, $css-name)}" method="text" indent="no">
<xsl:sequence select="f:get-css()"/>
</xsl:result-document>
</xsl:if>

</xsl:template>

<xsl:function name="f:get-css-link">
<xsl:param name="path"/>
<xsl:value-of select="if ($css-path eq '') then
    concat(
        f:ancestor-path(count(tokenize($path,'/')) - 1),
    $css-name)
else $css-path"/>

</xsl:function>

<xsl:function name="f:ancestor-path">
<xsl:param name="levels" as="xs:integer"/>
<xsl:value-of select="if ($levels eq 0) then 
''
else
concat(
    string-join(
        for $n in 1 to $levels return
        '..'
    , '/')
, '/')"/>

</xsl:function>

<xsl:function name="f:path-to-uri">
<xsl:param name="path"/>
<xsl:choose>
<xsl:when test="matches($path, '^[A-Za-z]:.*')">
<xsl:value-of select="concat('file:/', $path)"/>
</xsl:when>
<xsl:when test="starts-with($path, '/')">
<xsl:value-of select="concat('file://', $path)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$path"/>
</xsl:otherwise>
</xsl:choose>
</xsl:function>

<xsl:template name="wrap-spans">
<xsl:param name="spans" as="node()*"/>
<xsl:param name="globals" as="element()" tunnel="yes"/>
<xsl:param name="xmlns" as="element()" tunnel="yes"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:param name="path-length" tunnel="yes" as="xs:string"/>

<xsl:variable name="span" select="$spans[$index]"/>

<xsl:if test="$index mod 1500 eq 0">
<xsl:message><xsl:value-of select="'token: ', $index"/></xsl:message>
</xsl:if>

<xsl:choose>
<xsl:when test="empty($span)"/>
<xsl:when test="$span/@class eq 'es'">
<xsl:variable name="span-children" as="node()*">
<xsl:call-template name="wrap-spans">
<xsl:with-param name="spans" select="$spans"/>
<xsl:with-param name="index" select="$index + 1"/>
</xsl:call-template>
</xsl:variable>
<span class="ww" id="w{$index}">
<xsl:sequence select="$span"/>
<xsl:sequence select="$span-children"/>
</span>

<xsl:variable name="prev-index"
select="xs:integer(substring($span-children[last()]/@id, 3
))"/>

<xsl:call-template name="wrap-spans">
<xsl:with-param name="spans" select="$spans"/>
<xsl:with-param name="index" select="$prev-index + 1"/>
</xsl:call-template>

</xsl:when>
<xsl:when test="$span/@class = ('sc', 'ec')">
<span id="wx{$index}">
<xsl:copy-of select="$span/@*|$span/node()"/>
</span>
</xsl:when>
<xsl:otherwise>

<xsl:apply-templates select="$span" mode="markup"/>
<xsl:call-template name="wrap-spans">
<xsl:with-param name="spans" select="$spans"/>
<xsl:with-param name="index" select="$index + 1"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template name="wrap-spans-only">
<xsl:param name="spans" as="node()*"/>
<xsl:param name="index" as="xs:integer"/>

<xsl:variable name="span" select="$spans[$index]"/>

<xsl:if test="$index mod 1500 eq 0">
<xsl:message><xsl:value-of select="'token: ', $index"/></xsl:message>
</xsl:if>

<xsl:choose>
<xsl:when test="empty($span)"/>
<xsl:when test="$span/@class eq 'es'">
<xsl:variable name="span-children" as="node()*">
<xsl:call-template name="wrap-spans-only">
<xsl:with-param name="spans" select="$spans"/>
<xsl:with-param name="index" select="$index + 1"/>
</xsl:call-template>
</xsl:variable>
<span class="ww" id="w{$index}">
<xsl:sequence select="$span"/>
<xsl:sequence select="$span-children"/>
</span>

<xsl:variable name="prev-index"
select="xs:integer(substring($span-children[last()]/@id, 3
))"/>

<xsl:call-template name="wrap-spans-only">
<xsl:with-param name="spans" select="$spans"/>
<xsl:with-param name="index" select="$prev-index + 1"/>
</xsl:call-template>

</xsl:when>
<xsl:when test="$span/@class = ('sc', 'ec')">
<span id="wx{$index}">
<xsl:copy-of select="$span/@*|$span/node()"/>
</span>
</xsl:when>
<xsl:otherwise>
<xsl:sequence select="$span"/>
<xsl:call-template name="wrap-spans-only">
<xsl:with-param name="spans" select="$spans"/>
<xsl:with-param name="index" select="$index + 1"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:template>


<xsl:template name="get-common-root" as="xs:string*">
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
<xsl:sequence select="$min-file"/>
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
<xsl:variable name="uri-parts" as="xs:string*" select="tokenize($new-uri[1],'/|\\')"/>
<xsl:variable name="first-uri" as="xs:string*" 
select="string-join(
(subsequence($uri-parts, 1, count($uri-parts) - 1),'')
,'/')
"/>
<xsl:sequence select="f:get-all-files($first-uri, $new-uri, $uri-list)"/>

</xsl:function>

<xsl:function name="f:get-all-files" as="xs:string*">
<xsl:param name="first-uri" as="xs:string"/>
<xsl:param name="new-uri" as="xs:string*"/>
<xsl:param name="uri-list" as="xs:string*"/>

<xsl:variable name="add-uri" as="xs:string*"
select="for $file in $new-uri return
if ($file = ($uri-list)) then () else f:fix-uri($first-uri, $file)"/>

<xsl:variable name="new-externals" as="xs:string*">
<xsl:for-each select="$add-uri">
<xsl:variable name="has-protocol" as="xs:boolean" select="contains(.,':')"/>
<xsl:if test="($has-protocol and not(contains(.,'plugin:'))) or not($has-protocol)">
<xsl:variable name="doc" select="doc(.)"/>
<xsl:for-each select="$doc/*/xsl:import/@href|$doc/*/xsl:include/@href">
<xsl:value-of select="resolve-uri(., base-uri($doc))"/>
</xsl:for-each>
</xsl:if>
</xsl:for-each>
</xsl:variable>

<xsl:variable name="concat-sequence" select="($uri-list, $add-uri)"/>

<xsl:choose>
<xsl:when test="exists($new-externals)">
<xsl:sequence select="f:get-all-files($first-uri, $new-externals, $concat-sequence)"/>
</xsl:when>
<xsl:otherwise>
<xsl:sequence select="$concat-sequence"/>
</xsl:otherwise>
</xsl:choose>

</xsl:function>

<xsl:function name="f:fix-uri" as="xs:string">
<xsl:param name="first-uri" as="xs:string"/>
<xsl:param name="uri"/>
<xsl:sequence select="if(contains($uri, 'plugin:'))
then concat($first-uri, substring-after($uri, '/'))
else $uri"/>
</xsl:function>

<!--
sample globals elements:
<doc-prefix>xsl</doc-prefix>
<function name="do-something" ns="internal"/>
<function name="somethin-else" ns="internal"/>
<template name="output-days" ns=""/>
<variable name="my-global" ns=""/>
-->

<xsl:function name="f:get-globals" as="element()*">
<xsl:param name="file-uri" as="xs:string"/>

<xsl:variable name="doc" select="doc($file-uri)"/>
<doc-prefix>
<xsl:value-of select="prefix-from-QName(node-name($doc/*))"/>
</doc-prefix>

<templates>
<xsl:apply-templates select="$doc/*/xsl:template[@name]" mode="globals"/>
</templates>
<functions>
<xsl:apply-templates select="$doc/*/xsl:function" mode="globals"/>
</functions>
<variables>
<xsl:apply-templates select="$doc/*/(xsl:variable)" mode="globals"/>
</variables>
<params>
<xsl:apply-templates select="$doc/*/(xsl:param)" mode="globals"/>
</params>

</xsl:function>

<xsl:template match="xsl:template|xsl:function|xsl:variable|xsl:param" mode="globals">
<xsl:variable name="after-colon" select="substring-after(@name, ':')"/>
<xsl:variable name="local" select="if ($after-colon eq '') then @name else $after-colon"/>
<xsl:variable name="prefix" select="substring-before(@name, ':')"/>

<!--
<item name="{$local}" ns="{namespace-uri-for-prefix($prefix, .)}"/>
-->
<xsl:variable name="clark-name"
select="if ($prefix eq '') then
$local
else concat('{',
namespace-uri-for-prefix($prefix, .),
'}', $local)"/>
<item><xsl:value-of select="$clark-name"/></item>

</xsl:template>

<xsl:template name="output-html-doc">
<xsl:param name="result-spans" as="element()*"/>
<xsl:param name="filename"/>
<xsl:param name="css-link"/>
<xsl:param name="html-path"/>

<xsl:variable name="file-only" select="f:file-from-uri($filename)"/>
<xsl:variable name="href-1" select="concat($html-path, $filename)"/>
<xsl:variable name="href" select="if ($output-method eq 'xml')
then $href-1
else
concat($href-1,'.', $output-method)"/>
<xsl:message>writing: <xsl:value-of select="$href"/></xsl:message>
<xsl:message>file: <xsl:value-of select="$filename"/></xsl:message>
<xsl:result-document href="{$href}"
method="{$output-method}" indent="no">

<xsl:if test="$output-method eq 'html'">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
</xsl:if>
<xsl:message select="'output-method', $output-method"/>
<html>
<head>
<title><xsl:value-of select="$file-only"/></title>
<xsl:if test="$css-inline eq 'no'">
<link rel="stylesheet" type="text/css" href="{$css-link}"/>
</xsl:if>
<xsl:if test="$font-name eq 'scp' and $css-inline eq 'yes'">
<style>
@import url(http://fonts.googleapis.com/css?family=Source+Code+Pro);</style>
</xsl:if>
</head>
<body>
<div>
<pre class="spectrum">
<xsl:if test="$css-inline eq 'yes'">
<xsl:attribute name="style" select="f:inline-css-main()"/>
</xsl:if>
<!-- Call to imported functions returns sequence of span elements
     with class attribute values used to colorise with CSS
-->
<xsl:sequence select="if ($css-inline eq 'yes') then
f:add-nbsp($result-spans)
else $result-spans"/>

</pre>
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
<xsl:param name="doctype" as="xs:string"/>
<xsl:param name="indent-size" as="xs:integer"/>
<xsl:param name="root-prefix" as="xs:string"/>
<xsl:variable name="is-xml-new" as="xs:boolean" 
select="if ($is-xml) then
true()
else
if ($doctype = ('xpath', 'xquery', '')) then
false()
else true()"/>
<xsl:variable name="fixed-uri" select="f:path-to-uri($input-uri)"/>
<xsl:message><xsl:value-of select="'input-uri', $fixed-uri"/></xsl:message>
<xsl:variable name="file-content" as="xs:string" select="unparsed-text($fixed-uri)"/>
<xsl:variable name="pre-file-only" select="f:file-from-uri($input-uri)"/>
<xsl:variable name="file-only" select="if ($pre-file-only ne '') then $pre-file-only else 'xms-output'"/>
<xsl:choose>
<xsl:when test="$is-xml-new and $indent-size lt 0 and not($do-trim)">
<!-- for case where XPath is embedded in XML text -->
<xsl:sequence select="f:render($file-content, $doctype, $root-prefix)"/>
</xsl:when>
<xsl:when test="$is-xml-new">
<!-- for case where XPath is embedded in XML text and indentation required -->
<xsl:variable name="spans" select="f:render($file-content, $doctype, $root-prefix)"/>
<xsl:variable name="real-indent" select="if ($indent-size lt 0) then 0 else $indent-size"
as="xs:integer"/>
<xsl:sequence select="f:indent($spans, $real-indent, $do-trim)"/>
</xsl:when>
<xsl:otherwise>
<!-- for case where XPath is standalone -->
<!--        <xsl:sequence select="loc:showXPath($file-content)"/>-->
<xsl:variable name="xptokens" as="element()*" select="xqf:show-xquery($file-content)"/>
<xsl:sequence select="if ($css-inline ne 'no') then f:style-spans($xptokens) else $xptokens"/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

</xsl:stylesheet>
