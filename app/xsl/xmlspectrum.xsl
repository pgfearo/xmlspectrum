<?xml version="1.0" encoding="utf-8"?>
<!--
XMLSpectrum by Phil Fearon Qutoric Limited 2012 (c)
http://qutoric.com
License: Apache 2.0 http://www.apache.org/licenses/LICENSE-2.0.html

Purpose: Syntax highlighter for XPath (text), XML, XSLT and XSD 1.1 file formats

Interface Functions:
====================
f:render(xml-content, is-xml, root-prefix)
loc:showXPath(text-content)
f:get-css(color-theme)
f:indent(spans, char-width)
f:link(spans, paths, location)

Interface Templates:
====================
<xsl:template match="span" mode="markup">

Global Variables (for overriding)
=================================
w3c-xpath-functions-uri: location of resource proxy
font-name:               abbreviated font name [std|scp] default
                         is std for standard monospace - override
                         with 'scp' for 'Souce Code Pro'
                         font-family

-->

<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:loc="com.qutoric.sketchpath.functions"
xmlns:css="css-defs.com"
xmlns:dt="http://qutoric.com.xmlspectrum.document-types"
exclude-result-prefixes="loc f xs css c qf dt"
xmlns:c="http://xmlspectrum.colors.org"
xmlns="http://www.w3.org/1999/xhtml"
xpath-default-namespace="http://www.w3.org/1999/xhtml"
xmlns:qf="urn:xq.internal-function"
xmlns:f="internal">

<xsl:include href="doctype-functions.xsl"/>
<xsl:include href="xq-spectrum.xsl"/>
<xsl:include href="xslt-formatting-functions.xsl"/>

<xsl:param name="color-theme" select="'dark'"/>
<xsl:param name="force-newline" select="'no'"/>
<xsl:param name="format-mixed-content" select="'no'"/>
<xsl:variable name="ignore-mc" as="xs:boolean" select="$format-mixed-content eq 'yes'"/>
<xsl:variable name="insert-newlines" select="$force-newline eq 'yes'" as="xs:boolean"/>
<xsl:variable name="max-newline-length" as="xs:integer" select="80"/>
<xsl:variable name="resolved-theme" as="xs:string"
select="if ($color-theme eq 'light') then 'solarized-light'
else if ($color-theme eq 'dark') then 'solarized-dark'
else $color-theme"/>
<!-- override these variables -->
<xsl:variable name="w3c-xpath-functions-uri"
select="'http://www.w3.org/TR/xpath-functions/'"/>
<xsl:variable name="font-name" select="'std'"/>
<xsl:variable name="theme-doc-uri" select="'data/color-themes.xml'"/>
<xsl:variable name="css-inline" select="'no'"/>
<xsl:variable name="css-doc" select="doc(resolve-uri($theme-doc-uri, static-base-uri()))"/>
<xsl:variable name="color-theme-data" as="element(c:theme)"
select="$css-doc/c:themes/c:theme[@name eq f:get-theme($resolved-theme)]"/>
<xsl:variable name="color-modes" as="element(colors)*"
select="f:get-inline-colors($color-theme-data)"/>
<xsl:variable name="document-type" select="''"/>


<!--
signature:
    f:render(xml-content, is-xml, root-prefix)

description:
    Converts the xml content string to a sequence of span elements. with each
    containing a class attribute used for coloring with CSS. 

params:
    xml-content: string containing well-balanced XML extract - namespace and prefix
                 declarations not required
    is-xsl:      boolean specifying whether coloring is for XSLT, if this is false
                 then XSD 1.1 coloring scheme is used instead
    root-prefix: string prefix used for elements requiring special coloring for XSLT
                 or XSD 1.1 - often 'xsl' and 'xs' respectively
-->

<xsl:function name="f:render">
<xsl:param name="xmlText" as="xs:string"/>
<xsl:param name="doctype" as="xs:string"/>
<xsl:param name="root-prefix-a" as="xs:string"/>

<xsl:variable name="root-prefix" as="xs:string"
select="if ($root-prefix-a eq '') 
then ''
else concat($root-prefix-a, ':')"/>

<xsl:variable name="tokens-a" as="xs:string*" select="tokenize($xmlText, '&lt;')"/>
<xsl:message>
<xsl:text>doctype: </xsl:text><xsl:value-of select="$doctype"/>
<xsl:text>rendering </xsl:text>
<xsl:value-of select="concat(string(count($tokens-a)),' ')"/>
<xsl:value-of select="$doctype"/>
<xsl:text> tokens ...</xsl:text>
</xsl:message>
<xsl:variable name="tokens" select="if (normalize-space($tokens-a[1]) eq '') then subsequence($tokens-a, 2) else $tokens-a"/>
<xsl:variable name="spans" select="f:iterateTokens(0, $tokens,1,'n',0, 0, $doctype, $root-prefix, false())" as="element()*"/>

<xsl:choose>
<xsl:when test="$css-inline eq 'no'">
<xsl:sequence select="$spans"/>
</xsl:when>
<xsl:otherwise>
<xsl:sequence select="f:style-spans($spans)"/>
</xsl:otherwise>
</xsl:choose>

</xsl:function>

<!--
XSLT function signature: 
    f:get-css()

description:

    Generates a CSS file used to colorise span elements generates by the previous 2 functions
    The colors generated depend on the theme specified with the color-theme
    parameter. The color theme uses the 'Solarized' color points specified at: http://ethanschoonover.com/solarized

params:
    color-theme: xs:string - name of color theme to use 

-->
<xsl:function name="f:get-theme">
<xsl:param name="input-theme" as="xs:string"/>
<xsl:sequence select="if ($input-theme eq 'light') then 'solarized-light'
else if ($input-theme eq 'dark') then 'solarized-dark'
else $input-theme"/>
</xsl:function>

<xsl:function name="f:get-css">
<xsl:apply-templates select="$css-doc/c:themes/css:boiler-plate" mode="css"/>
</xsl:function>

<xsl:function name="f:get-css-font">
<xsl:apply-templates select="$css-doc/c:themes/css:boiler-plate/css:font" mode="css"/>
</xsl:function>

<xsl:function name="f:inline-css-main" as="xs:string">
<xsl:variable name="css-text" as="xs:string*">
<xsl:apply-templates select="$css-doc/c:themes/css:boiler-plate/css:main" mode="css"/>
</xsl:variable>
<xsl:sequence select="string-join($css-text, '')"/>
</xsl:function>

<xsl:function name="f:inline-css-toc" as="xs:string">
<xsl:variable name="css-text" as="xs:string*">
<xsl:apply-templates select="$css-doc/c:themes/css:boiler-plate/css:toc" mode="css"/>
</xsl:variable>
<xsl:sequence select="string-join($css-text, '')"/>
</xsl:function>

<xsl:template match="css:font" mode="css">
<xsl:value-of select="if ($font-name eq 'scp') then @scp else ''"/>
</xsl:template>

<xsl:template match="css:map" mode="css">
<xsl:variable name="element" select="@element"/>
<xsl:for-each select="$color-theme-data/c:color">
<xsl:variable name="color" select="@name"/>
<xsl:variable name="color-value" select="@value"/>
<xsl:variable name="color-selectors" as="element(c:color)"
select="$color-theme-data/../c:color-map/c:color[@name eq $color]"/>
<xsl:variable name="css-prop" select="($color-selectors/@property, 'color')[1]"/>
<xsl:variable name="selectors" select="normalize-space($color-selectors)"/>
<xsl:variable name="selector-tokens" select="tokenize($selectors, '\s')" as="xs:string+"/>
<xsl:variable name="qselector-tokens" select="for $s in $selector-tokens return
concat($element, '.', $s)"/>
<xsl:variable name="selector-string" select="string-join($qselector-tokens, ', ')"/>

<xsl:sequence select="concat(
$selector-string,
' {',
$css-prop,
': #',
$color-value,
'; }'
)"/>

</xsl:for-each>

</xsl:template>

<!--
Sample output:
<colors>
<color name="yellow" value="b58900" property="background-color">
<class>yellow</class>
<class>op</class>
<class>type-op</class>
</color>
...
</colors>

-->
<xsl:function name="f:get-inline-colors" as="element(colors)+">
<xsl:param name="theme" as="element(c:theme)"/>
<xsl:variable name="color-map" select="$theme/../c:color-map" as="element(c:color-map)"/>
<colors>
<xsl:for-each select="$theme/c:color">
<color>
<xsl:copy-of select="@*"/>
<xsl:variable name="color-key" select="@name"/>
<xsl:variable name="color" as="element(c:color)"
select="$color-map/c:color[@name eq $color-key]"/>
<xsl:if test="$color/@property">
<xsl:attribute name="property" select="$color/@property"/>
</xsl:if>
<xsl:for-each select="tokenize(normalize-space($color), '\s+')">
<class><xsl:value-of select="."/></class>
</xsl:for-each>
</color>
</xsl:for-each>
</colors>
</xsl:function>

<xsl:template match="css:color" mode="css">
<xsl:variable name="color" select="@name"/>
<xsl:value-of select="concat('#', $color-theme-data/c:color[@name eq $color]/@value)"/>
</xsl:template>

<xsl:function name="f:getTagType">
<xsl:param name="token" as="xs:string?"/>
<xsl:variable name="t" select="$token"/>
<xsl:variable name="t1" select="substring($t,1,1)"/>
<xsl:variable name="t2" select="substring($t,2,1)"/>

<xsl:choose>
<xsl:when test="$t1 eq '?'"><xsl:sequence select="'pi','?'"/></xsl:when>
<xsl:when test="$t1 eq '!' and $t2 eq '-'"><xsl:sequence select="'cm','!--'"/></xsl:when>
<xsl:when test="$t1 eq '!' and $t2 eq '['"><xsl:sequence select="'cd','![CDATA['"/></xsl:when>
<xsl:when test="$t1 eq '!'"><xsl:sequence select="'dt','!'"/></xsl:when>
<xsl:when test="$t1 eq '/'">
<xsl:sequence select="'cl','/'"/>
</xsl:when>
<!-- open tag (may be  self-closing) -->
<xsl:otherwise><xsl:sequence select="'tg',''"/></xsl:otherwise>
</xsl:choose>
</xsl:function>

<xsl:function name="f:expected-offset" as="xs:integer">
<xsl:param name="in"/>
<xsl:value-of select="if ($in eq '?&gt;') then 2
else if ($in eq '--&gt;') then 3
else if ($in eq ']]>') then 9
else 1"/>
</xsl:function>

<xsl:function name="f:iterateTokens" as="element()*">
<xsl:param name="counter" as="xs:integer"/>
<xsl:param name="tokens" as="xs:string*"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:param name="expected" as="xs:string"/>
<xsl:param name="beganAt" as="xs:integer"/>
<xsl:param name="level" as="xs:integer"/>
<xsl:param name="doctype" as="xs:string"/>
<xsl:param name="root-prefix" as="xs:string"/>
<xsl:param name="expand-text-stack" as="xs:boolean*"/>
<xsl:variable name="is-xsl" as="xs:boolean" select="$doctype eq 'xslt'"/>
<xsl:variable name="is-xsd" select="not($is-xsl)" as="xs:boolean"/>

<xsl:variable name="token" select="$tokens[$index]" as="xs:string?"/>
<xsl:variable name="prevToken" select="$tokens[$index + 1]" as="xs:string?"/>
<xsl:variable name="nextToken" select="$tokens[$index - 1]" as="xs:string?"/>
<xsl:variable name="awaiting" select="$expected ne 'n'" as="xs:boolean"/>

<xsl:variable name="expand-text" as="xs:boolean?" select="$expand-text-stack[last()]"/>

<!--
<trace>
token: <xsl:value-of select="$token"/>
expected: <xsl:value-of select="$expected"/>
index: <xsl:value-of select="$index"/>
</trace>
-->

<xsl:variable name="expectedOutput" as="element()*">
<xsl:if test="$awaiting">
<!--  looking to close an open tag -->
<!-- consider: <!DOCTYPE person [<!ELEMENT ... ]> as well as reference only -->
<xsl:variable name="beforeFind" select="substring-before($token, $expected)"/>
<xsl:variable name="found"
select="if (string-length($beforeFind) gt 0)
then true() 
else starts-with($beforeFind, $expected)" as="xs:boolean"/>
<xsl:if test="$found">
<xsl:variable name="offset" select="f:expected-offset($expected)" as="xs:integer"/>
<xsl:variable name="begin-token" select="$tokens[$beganAt]"/>
<span class="z">
<xsl:value-of
select="concat('&lt;',substring($begin-token, 1, $offset))"/>
</span>
<xsl:variable name="part-token" select="substring($begin-token, $offset + 1)"/>
<span>
<xsl:attribute name="class" select="f:getTagType($tokens[$beganAt])[1]"/>
<xsl:value-of 
select="string-join(
($part-token,
for $x in $beganAt + 1 to ($index -1) return
concat('&lt;', $tokens[$x]),
'&lt;',$beforeFind)
, '')
"/>
</span>
<span class="z"><xsl:value-of select="$expected"/></span>
<xsl:variable name="textNode" as="xs:string" select="substring($token, string-length($beforeFind) + string-length($expected) + 1)"/>
<xsl:choose>
<xsl:when test="$expand-text">
<xsl:sequence select="qf:show-xsl-tvt($textNode)"/>
</xsl:when>
<xsl:otherwise>
<span class="txt">
<xsl:value-of select="$textNode"/>
</span>

</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:if>
</xsl:variable>

<xsl:variable name="char1" as="xs:string?" select="substring($token,1,1)"/>
<xsl:variable name="is-element-start" as="xs:boolean"
select="not($awaiting) and not($char1 = ('?','!','/'))"/>
<xsl:variable name="is-root-element" as="xs:boolean"
select="$counter eq 0 and $is-element-start"/>
<!-- if root-prefix not initially supplied, get this from the first element name -->
<xsl:variable name="new-root-prefix"
select="if ($is-root-element)
then if ($root-prefix eq '')
    then
        for $x in tokenize($token, '\s+')[1] return 
        for $s in substring-before($x, ':') return
            if ($s eq '') then '' else concat($s, ':')
    else $root-prefix
else $root-prefix"/>


<!-- return 2 strings if required close found - that befoe and that after (even if empty string)
 if no required close found - just return the required close-->

<xsl:variable name="parseStrings" as="element()*">
<xsl:if test="not($awaiting)">
<xsl:variable name="requiredClose" as="xs:string">
<xsl:variable name="char2" as="xs:string?" select="substring($token,2,1)"/>
<xsl:choose>
<xsl:when test="$char1 eq '?'">?&gt;</xsl:when>
<xsl:when test="$char1 eq '!' and $char2 eq '-'">--&gt;</xsl:when>
<xsl:when test="$char1 eq '!' and $char2 eq '['">]]&gt;</xsl:when> <!-- assume cdata: <![CDATA[]]> -->
<xsl:when test="$char1 eq '!'">
<xsl:value-of select="if (contains($token,'[')) then ']>' else '>'"/>
</xsl:when>
<xsl:otherwise>&gt;</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:variable name="beforeClose" select="substring-before($token, $requiredClose)" as="xs:string"/>

<xsl:choose>
<xsl:when test="string-length($token) eq 0">
<!--
<x/>
-->
</xsl:when>
<xsl:when test="not($is-element-start)">
<!-- cdata, dtd, pi, comment, or close-tag -->
<xsl:variable name="foundClose"
select="if (string-length($beforeClose) gt 0)
then true() 
else starts-with($beforeClose, $requiredClose)"
as="xs:boolean"/>
<xsl:choose>
<xsl:when test="$foundClose">
<xsl:variable name="tagType" select="f:getTagType($token)" as="xs:string+"/>
<xsl:variable name="tagStart" select="$tagType[2]"/>
<xsl:variable name="isElementClose" select="$char1 eq '/'"/>

<span class="{if ($isElementClose) then 'ez' else 'z'}">
<xsl:value-of select="concat('&lt;',$tagStart)"/></span>
<xsl:variable name="tagContent" select="substring($beforeClose, string-length($tagStart) + 1)"/>
<xsl:variable name="with-prefix" select="starts-with($tagContent, $root-prefix)" as="xs:boolean"/>
<xsl:choose>
<xsl:when test="$isElementClose">
<span class="{if ($is-xsl and $with-prefix)
then 'clxsl'
else if ($is-xsd
         and ($tagContent = f:get-xsd-fnames($root-prefix, $doctype)/@name
         or not($with-prefix))) 
then 'clxsl'
else 'cl'}">
<xsl:value-of select="$tagContent"/>
</span>
</xsl:when>
<xsl:otherwise>
<span class="{$tagType[1]}">
<xsl:value-of select="$tagContent"/>
</span>
</xsl:otherwise>
</xsl:choose>
<span class="{if ($isElementClose) then 'ec' else 'z'}">
<xsl:if test="$isElementClose">
<!--
<xsl:attribute name="id" select="js:stackPop()"/>
-->
</xsl:if>
<xsl:value-of select="$requiredClose"/></span>

<xsl:variable name="textNode" as="xs:string" select="substring($token, string-length($beforeClose) + string-length($requiredClose) + 1)"/>
<xsl:choose>
<xsl:when test="$expand-text">
<xsl:sequence select="qf:show-xsl-tvt($textNode)"/>
</xsl:when>
<xsl:otherwise>
<span class="txt">
<xsl:value-of select="$textNode"/>
</span>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<required>
<xsl:value-of select="$requiredClose"/>
</required>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:otherwise>

<xsl:variable name="parts" as="xs:string*">
<xsl:analyze-string regex="&quot;.*?&quot;|'.*?'|[^'&quot;]+|['&quot;]" select="$token" flags="s">
<xsl:matching-substring>
<xsl:value-of select="."/>
</xsl:matching-substring>
<xsl:non-matching-substring>
<xsl:value-of select="."/>
</xsl:non-matching-substring>
</xsl:analyze-string>
</xsl:variable>

<xsl:sequence select="f:getAttributes($token, 0, $parts, 1, $doctype, $new-root-prefix, '', $expand-text-stack[last()])"/>

<!-- must be an open tag, so check for attributes -->

</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:variable>

<xsl:variable name="newLevel" as="xs:integer" select="0"/>
<xsl:variable name="newCounter" select="if ($is-element-start)
then $counter + 1 else $counter"/>

<xsl:variable name="stillAwaiting" as="xs:boolean"
select="$awaiting and empty($expectedOutput)"/>

<xsl:if test="not(name($parseStrings[1]) eq 'required')">
<xsl:sequence select="$parseStrings"/>
</xsl:if>

<xsl:sequence select="$expectedOutput"/>

<xsl:variable name="newExpected" as="xs:string"
select="if ($index eq 1) then
'n'
else if ($stillAwaiting)
then $expected
else if (count($parseStrings) eq 1)
then $parseStrings
else 'n'"/>

<xsl:variable name="newBeganAt" as="xs:integer"
select="if ($stillAwaiting) then $beganAt else $index"/>

<xsl:if test="$index le count($tokens)">
<xsl:sequence select="f:iterateTokens($newCounter, $tokens, $index + 1,
$newExpected, $newBeganAt, $newLevel, $doctype, $new-root-prefix, 
f:getNewExpandStack($parseStrings, $expand-text-stack) )"/>
</xsl:if>
</xsl:function>

<xsl:function name="f:getNewExpandStack" as="xs:boolean*">
<xsl:param name="parseStrings" as="element()*"/>
<xsl:param name="expandStack" as="xs:boolean*"/>
<!-- don't and empty tag value to stack -->
<xsl:variable name="startXslTag" as="xs:boolean" 
select="exists($parseStrings[@class eq 'enxsl']) and empty($parseStrings[@class eq 'sc'])"/>
<xsl:variable name="closeXslTag" as="xs:boolean"
select="exists($parseStrings[@class eq 'clxsl'])"/>
<xsl:variable name="expandValue" as="xs:boolean?" 
select="f:getExpandTextValue($parseStrings)"/>

<xsl:sequence select="if(exists($expandValue)) then
($expandStack, ($expandValue))
else if($startXslTag) then
($expandStack, $expandStack[last()])
else if($closeXslTag) then
subsequence($expandStack, 1, count($expandStack) - 1)
else
$expandStack"/>

</xsl:function>

<xsl:function name="f:getExpandTextValue" as="xs:boolean?">
<xsl:param name="parseStrings" as="element()*"/>

<xsl:variable name="expandValue" as="xs:string?" 
select="if($parseStrings[@class eq 'enxsl']) then
(for $i in 1 to count($parseStrings) return
    if($parseStrings[$i][@class eq 'atn' and . eq 'expand-text'])
    then $parseStrings[$i + 3]/text()
    else ()
)
else ()"/>
<xsl:sequence select="if($expandValue) then
$expandValue eq 'yes'
else ()"/>
</xsl:function>

<xsl:function name="f:checkExpandSpans" as="xs:boolean">
<xsl:param name="spans" as="element()*"/>
<xsl:param name="existing-expand-state" as="xs:boolean*"/>
<xsl:variable name="expandValue" as="xs:string?" 
select="for $i in 1 to count($spans) return
    if($spans[$i][@class eq 'atn' and . eq 'expand-text'])
    then $spans[$i + 3]/text()
    else ()"/>
<xsl:sequence select="if($expandValue) then
$expandValue eq 'yes'
else $existing-expand-state"/>
</xsl:function>


<xsl:function name="f:getAttributes" as="item()*">
<xsl:param name="attToken" as="xs:string"/>
<xsl:param name="offset" as="xs:integer"/>
<xsl:param name="parts" as="xs:string*"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:param name="doctype" as="xs:string"/>
<xsl:param name="root-prefix" as="xs:string"/>
<xsl:param name="ename" as="xs:string"/>
<xsl:param name="expand-text" as="xs:boolean"/>
<xsl:variable name="is-xsl" as="xs:boolean" select="$doctype eq 'xslt'"/>
<xsl:variable name="is-xsd" select="not($is-xsl)" as="xs:boolean"/>

<xsl:variable name="part1" as="xs:string?"
select="$parts[$index]"/>
<xsl:variable name="part2" as="xs:string?"
select="$parts[$index + 1]"/>

<xsl:variable name="elementName" as="xs:string?"
select="if ($ename eq '') then
tokenize($part1, '>|\s+|/')[1]
else $ename"/>

<xsl:variable name="with-prefix" select="starts-with($elementName, $root-prefix)"/>
<xsl:variable name="is-xsl-element" select="$is-xsl and $with-prefix"/>

<xsl:if test="$index eq 1">
<span class="es">&lt;</span>
<span class="{if ($is-xsl-element)
then 'enxsl'
else if ($is-xsl and not($with-prefix))
then 'en'
else if ($is-xsd and not($with-prefix))
then 'enxsl'
else if ($is-xsd and $elementName = f:get-xsd-fnames($root-prefix, $doctype)/@name) then 'enxsl' 
else 'en'}">
<!--
id="{js:stackPush($elementName)}">
-->
<xsl:value-of select="$elementName"/>
</span>
</xsl:if>

<xsl:variable name="pre-close" select="substring-before($part1, '>')"/> 

<xsl:variable name="isFinalPart" select="$index + 2 gt count($parts)
or string-length($pre-close) gt 0
or starts-with($part1,'>')"
as="xs:boolean"/>
<xsl:variable name="spans" as="element()*">

<xsl:choose>
<xsl:when test="$isFinalPart">
<!--  use sc class value to mark end of self-closed element -->
<xsl:variable name="isSelfClosed" select="ends-with($pre-close,'/')" as="xs:boolean"/>
<span class="{if ($isSelfClosed) then 'sc' else 'scx'}">
<xsl:value-of select="if ($isSelfClosed) then '/' else ''"/>&gt;</span>

<xsl:variable name="textNode" as="xs:string" select="substring($attToken, string-length($pre-close) + $offset + 2)"/>
<xsl:choose>
<xsl:when test="$expand-text">
<xsl:sequence select="qf:show-xsl-tvt($textNode)"/>
</xsl:when>
<xsl:otherwise>
<span class="txt">
<xsl:value-of select="$textNode"/>
</span>
</xsl:otherwise>
</xsl:choose>
</xsl:when>
<xsl:when test="exists($part2)">
<!-- attribute must exist and name occurs before value, so get this first -->
<xsl:variable name="left" as="xs:string"
select="if ($index eq 1)
then substring($part1, string-length($elementName) + 1)
else $part1"/>
<xsl:variable name="pre" select="substring-before($left,'=')"/>
<!--
<xsl:variable name="tokens" select="tokenize($pre, '\s+')"/>
-->
<xsl:variable name="tokens" select="f:splitAttributeName($pre)"/>

<xsl:variable name="attSpans" as="element()*">
<xsl:for-each select="$tokens">
<xsl:variable name="class"
select="if (matches(.,'\S')) 
then 'atn'
else 'z'"/>
<span class="{$class}"><xsl:value-of select="."/></span>
</xsl:for-each>
</xsl:variable>

<xsl:variable name="att-name" select="$attSpans[@class eq 'atn']"/>
<xsl:variable name="xsd-xpath-elements" select="f:get-xsd-element-names($root-prefix, $doctype)" as="element()*"/>
<xsl:variable name="xsd-xpath-attributes" select="f:get-xsd-attribute-names($root-prefix, $doctype)" as="element()*"/>

<xsl:sequence select="$attSpans"/>
<xsl:variable name="isXPath" as="xs:boolean"
select="if ($is-xsl-element)
then $att-name = ('select','test', 'match', 'xpath','context-item','namespace-context')

else if (exists($xsd-xpath-attributes)) then

($is-xsd and exists( 
$xsd-xpath-attributes[@name = $att-name])) 

else

($is-xsd and exists( 
$xsd-xpath-elements[@name = $elementName and ./dt:att = $att-name])) 
"/>

<!-- for coloring attribute values that are referenced from XPath -->
<xsl:variable name="metaXPathName" as="xs:string"
select="f:get-av-class($is-xsl-element, $doctype, $is-xsd, 
               $elementName, $att-name, $root-prefix)"/>

<span class="atneq"><xsl:value-of select="substring($left,string-length($pre) + 1)"/></span>

<xsl:variable name="sl" select="string-length($part2)" as="xs:double"/>
<span class="z"><xsl:value-of select="substring($part2,1,1)"/></span>

<xsl:variable name="attValue" select="substring($part2, 2, $sl - 2)"/>

<xsl:choose>
<xsl:when test="$isXPath">
<xsl:sequence select="loc:showXPath($attValue)"/>
</xsl:when>
<xsl:when test="$is-xsl and $metaXPathName eq 'av'">
<!--
<xsl:sequence select="f:processAVT($attValue, $metaXPathName)"/>
-->
<xsl:variable name="att-spans" as="element()*" select="qf:show-xsl-tvt($attValue)"/>
<xsl:for-each select="$att-spans">
<xsl:copy>
<xsl:sequence select="@* except @class"/>
<xsl:attribute name="class" select="if(@class eq 'txt') then 'av' else @class"/>
<xsl:sequence select="node()"/>
</xsl:copy>
</xsl:for-each>
</xsl:when>
<xsl:otherwise>
<span class="{$metaXPathName}">
<xsl:value-of select="$attValue"/>
</span>
</xsl:otherwise>
</xsl:choose>
<span class="z"><xsl:value-of select="substring($part2, $sl)"/></span>
</xsl:when>

</xsl:choose>
</xsl:variable>

<xsl:variable name="newExpandText" as="xs:boolean" 
select="if($is-xsl-element) then
f:checkExpandSpans($spans, $expand-text)
else
$expand-text"/>

<xsl:sequence select="$spans"/>

<xsl:variable name="newOffset" select="string-length($part1) + string-length($part2) + $offset"/>

<xsl:if test="not($isFinalPart)">
<xsl:sequence select="f:getAttributes($attToken, $newOffset, $parts, $index + 2, $doctype, $root-prefix, $elementName, $newExpandText)"/>
</xsl:if>

</xsl:function>

<xsl:function name="f:get-av-class" as="xs:string">
<xsl:param name="is-xsl-element" as="xs:boolean"/>
<xsl:param name="doctype" as="xs:string"/>
<xsl:param name="is-xsd" as="xs:boolean"/>
<xsl:param name="elementName"/>
<xsl:param name="att-name"/>
<xsl:param name="root-prefix"/>
<xsl:variable name="vp-name" as="xs:string*" select="f:prefixed-name($root-prefix, ('variable', 'param'))"/>
<xsl:variable name="p-name" as="xs:string" select="$vp-name[2]"/>
<xsl:value-of
select="if ($is-xsl-element) then
if ($elementName = $vp-name
    and $att-name eq 'name') then if ($elementName eq $p-name) then 'pname' else 'vname'
else if ($elementName = f:prefixed-name($root-prefix, ('import', 'include'))
    and $att-name eq 'href') then 'href'
else if ($elementName = f:prefixed-name($root-prefix, ('call-template'))
    and $att-name eq 'name') then 'tcall'
else if ($elementName = f:prefixed-name($root-prefix, 'function') 
    and $att-name eq 'name') then 'fname'
else if ($elementName = f:prefixed-name($root-prefix, 'template') 
    and $att-name eq 'name') then 'tname'
else 'av'

else if ($is-xsd 
         and f:is-xsd-fname($root-prefix, $doctype, $elementName, $att-name))
then 'fname' else 'av'"/>


</xsl:function>

<xsl:function name="f:unescape-p">
<xsl:param name="text"/>
<xsl:variable name="t1" select="replace($text, '&#x0300;', '{{')"/>
<xsl:value-of select="replace($t1, '&#x0301;', '}}')"/>
</xsl:function>

<xsl:function name="f:processAVT">
<xsl:param name="attText" as="xs:string"/>
<xsl:param name="class" as="xs:string"/>
<xsl:variable name="regex1" select="'\{.*?\}'" as="xs:string"/>

<xsl:variable name="t1" select="replace($attText, '\{\{', '&#x0300;')"/>
<xsl:variable name="t2" select="replace($t1, '\}\}', '&#x0301;')"/>

<!-- flags:s = match . to any char including \n -->
<xsl:analyze-string select="$t2" regex="{$regex1}" flags="s">

<xsl:matching-substring>
<xsl:variable name="p" select="f:unescape-p(substring(., 2, string-length(.) - 2))"/>
<span class="op">
<xsl:text>{</xsl:text>
</span>

<xsl:sequence select="loc:showXPath($p)"/>

<span class="op">
<xsl:text>}</xsl:text>
</span>

</xsl:matching-substring>

<xsl:non-matching-substring>
<xsl:variable name="p" select="f:unescape-p(.)"/>

<span class="{$class}">
<xsl:value-of select="$p"/>
</span>
</xsl:non-matching-substring>

</xsl:analyze-string>

</xsl:function>

<xsl:function name="f:splitAttributeName">
<xsl:param name="text"/>
<xsl:analyze-string regex="(\S+)|(\s+)" select="$text">
<xsl:matching-substring>
<xsl:value-of select="."/>
</xsl:matching-substring>
</xsl:analyze-string>
</xsl:function>

<!--
signature:
    loc:showXPath(text-content)

description:

    Converts the xpath content string to a sequence of span elements. with each
    containing a class attribute used for coloring with CSS. 

params:
   text-content: string containing a single XPath expression
-->
<xsl:function name="loc:showXPath">
<xsl:param name="chunk"/>

<!--
<xsl:variable name="chars" as="xs:string*"
select="loc:stringToCharSequence($chunk)"/>

<xsl:variable name="blocks" as="element()*">
<xsl:sequence select="loc:createBlocks($chars, false(), 1, '', 0, 0)"/>
</xsl:variable>
<xsl:variable name="pbPairs" as="element()*"
select="loc:createPairs($blocks[name() = 'block' and @type = ('[',']','(',')')])"/>

<xsl:variable name="omitPairs" as="element()*"
select="($blocks[name() = ('literal','comment')])"/>

-->
<xsl:variable name="tokens" as="element()*">
<xsl:sequence select="qf:show-xquery($chunk)"/>
</xsl:variable>

<xsl:choose>
<xsl:when test="$css-inline eq 'no'">
<xsl:sequence select="$tokens"/>
</xsl:when>
<xsl:otherwise>
<xsl:sequence select="f:style-spans($tokens)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:function>

<xsl:function name="f:style-spans" as="node()*">
<xsl:param name="spans" as="node()*"/>
<xsl:for-each select="$spans">
<xsl:variable name="color-key" select="@class"/>
<xsl:variable name="color-mode1" as="element(color)?"
select="$color-modes/color[class = $color-key]"/>
<!-- use the yellow color mode if none defined for class -->
<xsl:variable name="color-mode2" as="element(color)"
select="if (exists($color-mode1))
then $color-mode1
else $color-modes/color[@name = 'yellow']"/>

<xsl:variable name="property" select="if ($color-mode2/@property)
then $color-mode2/@property
else 'color'"/>
<xsl:copy>
<xsl:copy-of select="@*"/>
<xsl:attribute name="style"
select="concat($property, ': #', $color-mode2/@value)"/>
<xsl:value-of select="."/>
</xsl:copy>
</xsl:for-each>
</xsl:function>

</xsl:stylesheet>
