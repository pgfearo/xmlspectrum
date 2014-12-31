<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xsl xs f"
                xmlns:f="internal">

<xsl:variable name="globals" select="/*"/>
<xsl:variable name="xmlns" select="/*"/>
<xsl:variable name="ancestor-path" select="''"/>

  <xsl:template match="/*">
    <result>
      <xsl:for-each-group select="*" group-starting-with=".[@class = ('es')]">
        <group current-key="{current-grouping-key()}">
          <xsl:for-each select="current-group()">
            <cg><xsl:sequence select="."/></cg>
          </xsl:for-each>
        </group>
      </xsl:for-each-group>
    </result>                  
  </xsl:template>

</xsl:stylesheet>