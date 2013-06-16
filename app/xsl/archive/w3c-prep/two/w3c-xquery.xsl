<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" 
                xmlns:xqf="urn:xq.internal-function"
                xmlns:f="internal"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 exclude-result-prefixes="f xqf"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">

<xsl:import href="xmlspectrum.xsl"/>
<xsl:import href="xq-spectrum.xsl"/>
<xsl:output method="xml" indent="no"/>

<xsl:template match="/">
<wrap5>
 <xsl:apply-templates select="*" mode="high"/> 
</wrap5>  
</xsl:template>

<xsl:template match="@* | node()" mode="high">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()" mode="high"/>
  </xsl:copy>
</xsl:template>

<xsl:template match="div[@class eq 'exampleInner']/pre" mode="high">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:variable name="xptokens" as="element()*" select="xqf:show-xquery(.)"/>
    <xsl:sequence select="f:style-spans($xptokens)"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>