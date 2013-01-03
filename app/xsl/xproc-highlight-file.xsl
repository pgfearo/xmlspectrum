<?xml version="1.0" encoding="utf-8"?>
<!--
A frontend for XMLSpectrum by Phil Fearon Qutoric Limited 2012 (c)

This systesheet: xproc-highlight-file.xsl imports highlight-file.xsl
                 and overrides the 'xsd' language elements with those
                 for xproc - to allow xpath colorisation of attributes
                 that contain XPathExpression

-->

<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:loc="com.qutoric.sketchpath.functions"
xmlns:css="css-defs.com"
exclude-result-prefixes="loc f xs css"
xmlns=""
xmlns:f="internal">

<xsl:import href="highlight-file.xsl"/>

<xsl:output indent="yes"/>
<xsl:param name="sourcepath" as="xs:string" select="''"/>
<!--  by default - rely on original indentation -->
<xsl:param name="indent" as="xs:string" select="'-1'"/>

<xsl:param name="light-theme" select="'no'"/>
<xsl:param name="css-path" select="''"/>
<xsl:param name="auto-trim" select="'no'"/>
<xsl:param name="link-names" select="'no'"/>
<xsl:param name="output-path" select="'output/'"/>
<!-- make source code pro the default -->
<xsl:param name="font-name" select="'std'"/>

<!-- note: set this to a proxy server storing the W3C resource to avoid
           excessive calls to the W3C server
 -->
<xsl:param name="w3c-xpath-functions-uri"
select="'http://www.w3.org/TR/xpath-functions/'"/>

<!-- Set 'xsd' settings to suit xproc spec instead -->

<!-- override 'xsd' vocabulary variables for XProc -->
<xsl:variable name="xsd-xpath-names" as="element()+">
<element name="add-attribute">
<att>match</att>
<!-- note: XProc spec states attribute-value has type xs:string
           but the value may be an XPath expression so it can
           do no harm to colorise as such -->
<att>attribute-value</att>
</element>
<element name="delete"><att>match</att></element>
<element name="hash"><att>match</att></element>
<element name="input"><att>select</att></element>
<element name="insert"><att>match</att></element>
<element name="iteration-source"><att>select</att></element>
<element name="label-elements">
<att>label</att>
<att>match</att>
</element>
<element name="make-absolute-uris"><att>match</att></element>
<element name="namespaces"><att>element</att></element>

<element name="option"><att>select</att></element>
<element name="rename"><att>match</att></element>
<element name="replace"><att>match</att></element>
<element name="set-attributes"><att>match</att></element>
<element name="string-replace">
<att>match</att>
<att>replace</att>
</element>
<element name="unwrap"><att>match</att></element>
<element name="uuid"><att>match</att></element>
<element name="variable"><att>select</att></element>
<element name="viewport"><att>match</att></element>
<element name="when"><att>test</att></element>
<element name="with-option"><att>select</att></element>
<element name="with-param"><att>select</att></element>
<element name="wrap"><att>match</att></element>
<element name="www-form-urlencode"><att>match</att></element>

</xsl:variable>

<!-- override 'xsd' vocabulary variables for XProc -->
<xsl:variable name="xsd-highlight-names" as="element()+">

<element name="option" attribute="name"/>
<element name="variable" attribute="name"/>
</xsl:variable>


</xsl:stylesheet>
