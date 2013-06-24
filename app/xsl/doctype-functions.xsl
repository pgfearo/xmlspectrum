<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:loc="com.qutoric.sketchpath.functions"
xmlns:css="css-defs.com"
xmlns:dt="http://qutoric.com.xmlspectrum.document-types"
exclude-result-prefixes="loc f xs css c"
xmlns:c="http://xmlspectrum.colors.org"
xmlns="http://www.w3.org/1999/xhtml"
xpath-default-namespace="http://www.w3.org/1999/xhtml"
xmlns:f="internal">

<xsl:variable name="doctypes-data-uri" select="'data/doctypes.xml'"/>

<xsl:variable name="xsd-names" as="element(dt:document-types)" select="doc(resolve-uri($doctypes-data-uri, static-base-uri()))/*"/>

<xsl:function name="f:doctype-from-xmlns" as="xs:string">
<xsl:param name="xmlns" as="xs:string"/>
<xsl:sequence
select="($xsd-names/dt:document-type[dt:ns = $xmlns]/@name, '')[1]"/>
</xsl:function>

<xsl:function name="f:xsd-xpath-names" as="element()*">
<xsl:param name="doctype" as="xs:string"/>
<xsl:sequence
select="$xsd-names/dt:document-type[@name eq $doctype]/dt:xpath-names"/>
</xsl:function>

<xsl:function name="f:xsd-highlight-names" as="element()*">
<xsl:param name="doctype" as="xs:string"/>
<xsl:sequence
select="$xsd-names/dt:document-type[@name eq $doctype]/dt:highlight-names/*"/>
</xsl:function>

<xsl:function name="f:prefixed-name" as="xs:string*">
<xsl:param name="prefix" as="xs:string"/>
<xsl:param name="name" as="xs:string+"/>
<xsl:for-each select="$name">
<xsl:sequence select="concat($prefix, .)"/>
</xsl:for-each>
</xsl:function>

<xsl:function name="f:get-xsd-element-names" as="element()*">
<xsl:param name="prefix" as="xs:string"/>
<xsl:param name="doctype" as="xs:string"/>
<xsl:for-each select="f:xsd-xpath-names($doctype)/dt:element">
<xsl:copy>
<xsl:attribute name="name" select="concat($prefix, @name)"/>
<xsl:copy-of select="*"/>
</xsl:copy>
</xsl:for-each>
</xsl:function>

<xsl:function name="f:get-xsd-attribute-names" as="element()*">
<xsl:param name="prefix" as="xs:string"/>
<xsl:param name="doctype" as="xs:string"/>
<xsl:for-each select="f:xsd-xpath-names($doctype)/dt:attribute">
<xsl:copy>
<xsl:attribute name="name" select="concat($prefix, @name)"/>
<xsl:copy-of select="*"/>
</xsl:copy>
</xsl:for-each>
</xsl:function>


<xsl:function name="f:get-xsd-fnames" as="element()*">
<xsl:param name="prefix" as="xs:string"/>
<xsl:param name="doctype" as="xs:string"/>
<xsl:for-each select="f:xsd-highlight-names($doctype)">
<element name="{concat($prefix, @name)}" attribute="{@attribute}"/>
</xsl:for-each>
</xsl:function>

<xsl:function name="f:is-xsd-fname" as="xs:boolean">
<xsl:param name="prefix"/>
<xsl:param name="doctype"/>
<xsl:param name="element"/>
<xsl:param name="attribute"/>
<xsl:variable name="fnames" as="element()*" select="f:get-xsd-fnames($prefix, $doctype)"/>
<xsl:value-of select="exists($fnames[@name = $element and @attribute = $attribute])"/>
</xsl:function>

</xsl:stylesheet>
