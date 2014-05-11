<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:loc="com.qutoric.sketchpath.functions"
  xmlns:css="css-defs.com"
  exclude-result-prefixes="loc f xs css"
  xmlns=""
  xmlns:f="internal">

  <xsl:variable name="testa" as="xs:string">
    othertest{here}
  </xsl:variable>

  <xsl:function name="f:sum" expand-text="no" as="xs:integer">
    <xsl:param name="x" as="xs:integer"/>
    <xsl:param name="y" as="xs:integer"/>
    <xsl:variable name="test" select="let $new := 'myname' return
                                      if($x lt 10) then 'ten'
                                      else if($y lt 10) then 'twenty'
                                      else $new"/>
    <xsl:variable name="id" select="'A123'"/>
    <xsl:variable name="step" select="5"/>
    <xsl:element name="abc{concat($a,$b)} - post">
      some test
    </xsl:element>
    <lre name="{$alpha}">
      this should also use xpath!
    </lre>
    <xsl:message
     expand-text="yes">
      Processing id={$id},
      step={
      let $a := function() {
      22 + 55
      } return
      $a + 89
      $step
      }
      I can have {{any arrangement}}
    </xsl:message>
    <xsl:text>my test</xsl:text>
  </xsl:function>

  <xsl:variable name="test" as="xs:string">
    othertest{here}
  </xsl:variable>

</xsl:stylesheet>

