<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" 
                xmlns:xqf="urn:xq.internal-function"
                xmlns:f="internal"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 exclude-result-prefixes="f xqf"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">

<xsl:import href="xmlspectrum.xsl"/>
<xsl:import href="xq-spectrum.xsl"/>
<xsl:output method="xhtml" indent="no"/>
<xsl:variable name="color-theme" select="'github-blue'"/>
<xsl:variable name="span-namespace-uri" select="'http://www.w3.org/1999/xhtml'"/>

<xsl:template match="/">
 <xsl:apply-templates mode="high"/>   
</xsl:template>

<xsl:template match="@* | node()" mode="high">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()" mode="high"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="div[@class eq 'exampleInner']/pre" mode="high">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:variable name="text" select="." as="xs:string"/>
    <xsl:variable name="first-char" select="substring($text, 1,1)"/>
    <xsl:variable name="trim-text" select="if ($first-char eq '&#10;') then substring($text, 2) else $text"/>
    <xsl:variable name="xptokens" as="element()*" select="xqf:show-xquery($trim-text)"/>
    <xsl:sequence select="f:style-spans($xptokens)"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
