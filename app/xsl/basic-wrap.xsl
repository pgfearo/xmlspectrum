<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xsl xs f"
                xmlns:f="internal">

<xsl:output method="xml" omit-xml-declaration="yes"/>

<xsl:variable name="globals" select="/*"/>
<xsl:variable name="xmlns" select="/*"/>
<xsl:variable name="ancestor-path" select="''"/>

  <xsl:template match="/*">
      <xsl:copy-of select="."/>                 
  </xsl:template>

</xsl:stylesheet>