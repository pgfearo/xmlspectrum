<xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xsl xs f"
                xmlns:math="http://www.w3.org/2005/xpath-functions/math"
                xmlns:map="http://www.w3.org/2005/xpath-functions/map"
                xmlns:f="internal">

<xsl:output method="xml" omit-xml-declaration="yes" indent="no"/>

<xsl:variable name="globals" select="/*"/>
<xsl:variable name="xmlns" select="/*"/>
<xsl:variable name="ancestor-path" select="''"/>

  <xsl:template match="/*">
    <xsl:variable name="seed-register" as="xs:boolean*" select="true(), true(), false(), true()"/>
    <xsl:variable name="register-length" as="xs:integer" select="count($seed-register)"/>
    <xsl:variable name="register-values" as="xs:double*"
      select="
      sum(
      for $x in 1 to $register-length return
      if($seed-register[$x]) then math:pow(2, $x - 1) else ()
      )"/>
     <one>
       <xsl:value-of select="'pow', $register-values"/>
    </one>                 
  </xsl:template>

  <xsl:function name="f:get-bit" as="xs:integer">
    <xsl:param name="bit-sequence" as="xs:boolean*"/>
    <xsl:param name="bit-pos" as="xs:integer"/>
    <xsl:sequence select="let $v := $bit-sequence[$bit-pos] return
                          if ($v) then 1 else 0"/>
  </xsl:function>


</xsl:stylesheet>