<?xml version="1.0" encoding="utf-8"?>
<!--
A frontend for XMLSpectrum by Phil Fearon Qutoric Limited 2012 (c)

http://qutoric.com
License: Apache 2.0 http://www.apache.org/licenses/LICENSE-2.0.html

Purpose: Syntax highlighter for XPath (text), XML, XSLT and XSD 1.1 file formats

Description:

Transforms the source XHTML file by converting <samp> elements to para elements
with span child elements containing class attributes for color styles. Also
inserts a link to a generated CSS file. 

Note that this file interface is a simple wrapper for xmlspectrum.xsl.

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
exclude-result-prefixes="loc f xs"
xmlns="http://www.w3.org/1999/xhtml"
xpath-default-namespace="http://www.w3.org/1999/xhtml"
xmlns:f="internal">

<xsl:import href="xmlspectrum.xsl"/>

<xsl:output indent="no" method="xhtml"/>

<xsl:param name="light-theme" select="'no'" as="xs:string"/>

<xsl:template match="/">
<xsl:apply-templates/>
<xsl:call-template name="create-css"/>
</xsl:template>

<xsl:template match="head">
<xsl:apply-templates select="@*"/>
<link rel="stylesheet" type="text/css" href="theme.css"/>
<xsl:apply-templates/>
</xsl:template>


<xsl:template match="@* | node()">
<xsl:copy>
<xsl:apply-templates select="@* | node()"/>
</xsl:copy>
</xsl:template>

<xsl:template match="samp[exists(@lang) and @lang ne 'xpath']">
<xsl:variable name="is-xsl" select="@lang eq 'xslt'"/>
<xsl:variable name="prefix" select="if($is-xsl) then 'xsl' else 'xsd'"/>
<xsl:copy>
<xsl:attribute name="class" select="@lang"/>
<xsl:apply-templates select="@* except @class"/>
<xsl:sequence select="f:render(., $is-xsl, $prefix)"/>
</xsl:copy>
</xsl:template>

<xsl:template match="samp[@lang eq 'xpath']">
<xsl:copy>
<xsl:attribute name="class" select="@lang"/>
<xsl:apply-templates select="@* except @class"/>
<xsl:sequence select="loc:showXPath(.)"/>
</xsl:copy>
</xsl:template>

<xsl:template name="create-css">

<xsl:result-document href="theme.css" method="text" indent="no">
<xsl:variable name="classes" select="'samp.xslt, samp.xsd, samp.xpath, '"/>
<xsl:value-of select="concat($classes, f:get-css($light-theme eq 'yes'))"/>
</xsl:result-document>

</xsl:template>

</xsl:stylesheet>
