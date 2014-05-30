<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:loc="com.qutoric.sketchpath.functions"
xmlns:xqf="urn:xq.internal-function"
exclude-result-prefixes="loc f xs xqf"
xpath-default-namespace="http://www.w3.org/1999/xhtml"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:f="internal">

<xsl:import href="xmlspectrum.xsl"/>

<xsl:output indent="no" method="xml"/>

<!--  by default - rely on original indentation -->
<xsl:param name="source-code" as="xs:string" select="''"/>
<xsl:param name="indent" as="xs:string" select="'2'"/>
<xsl:param name="auto-trim" select="'yes'"/>
<xsl:param name="format-mixed-content" select="'no'"/>
<!-- set value to 'scp' for source-code-pro font -->
<xsl:param name="font-name" select="'scp'"/>
<xsl:param name="doctype" select="'xslt'"/>
<xsl:param name="document-type-prefix" select="'xsl'"/>
<xsl:param name="cmdline" select="'yes'"/>
<xsl:param name="nesting" select="'2'"/>

<xsl:template name="main">
<!-- for case where XPath is embedded in XML text and indentation required -->
<xsl:variable name="code1" select="if($cmdline eq 'yes') then replace($source-code, '#nl;', '&#10;') else $source-code"/>
<xsl:variable name="code" select="if($cmdline eq 'yes') then replace($code1, '#qt;', '&quot;') else $source-code"/>
<xsl:variable name="spans" select="f:render($code, $doctype, $document-type-prefix)"/>
<xsl:variable name="real-indent" select="xs:integer($indent)" as="xs:integer"/>
<xsl:sequence select="f:indent($spans, $real-indent, $auto-trim eq 'yes'), xs:integer($nesting)"/>
</xsl:template>

</xsl:stylesheet>
