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
f:get-css(is-light-theme)
f:indent(spans, char-width)
f:target(spans)
f:link(spans, paths, location)

-->

<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:loc="com.qutoric.sketchpath.functions"
xmlns:css="css-defs.com"
exclude-result-prefixes="loc f xs css"
xmlns=""
xmlns:f="internal">
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


<xsl:import href="dummy.xsl"/>
<xsl:include href="sub/dummy2.xsl"/>


<xsl:function name="f:render">
<xsl:param name="xmlText" as="xs:string"/>
<xsl:param name="is-xsl" as="xs:boolean"/>
<xsl:param name="root-prefix-a" as="xs:string"/>

<xsl:variable name="root-prefix" as="xs:string"
select="if ($root-prefix-a eq '') 
then ''
else concat($root-prefix-a, ':')"/>

<xsl:variable name="tokens-a" as="xs:string*" select="tokenize($xmlText, '&lt;')"/>
<xsl:variable name="tokens" select="if (normalize-space($tokens-a[1]) eq '') then subsequence($tokens-a, 2) else $tokens-a"/>
<xsl:variable name="spans" select="f:iterateTokens(0, $tokens,1,'n',0, 0, $is-xsl, $root-prefix)" as="element()*"/>

<xsl:sequence select="$spans"/>
</xsl:function>

<!-- 
signature:
    f:indent(spans, char-width)

description
    
    Adds space characters for indentation to spans from XML-text processed with f:render. 
    XML contents is indented in the conventional way, multi-line attribute names and values
    are aligned vertically

parameters:
    spans:          Sequence of 'span' element nodes created by f:render
    char-width:     integer: Number of characters for each indent level
    auto-trim:      boolean: Trims any leading whitespace before indentation


 -->
<xsl:function name="f:indent">
<xsl:param name="spans" as="element()*"/>
<xsl:param name="char-width" as="xs:integer"/>
<xsl:param name="auto-trim" as="xs:boolean"/>
<xsl:call-template name="indentSpans">
<xsl:with-param name="spans" select="$spans" as="element()*" tunnel="yes"/>
<xsl:with-param name="index" as="xs:integer" select="1"/>
<xsl:with-param name="level" as="xs:integer" select="0"/>
<xsl:with-param name="margin" as="xs:integer" select="$char-width"/>
<xsl:with-param name="an-offset" as="xs:integer" select="0"/>
<xsl:with-param name="av-offset" as="xs:integer" select="0"/>
<xsl:with-param name="multi-line" as="xs:boolean" select="false()"/>
<xsl:with-param name="auto-trim" as="xs:boolean" select="$auto-trim"/>
</xsl:call-template>
</xsl:function>

<xsl:template name="indentSpans">
<xsl:param name="spans" as="element()*" tunnel="yes"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:param name="level" as="xs:integer"/>
<xsl:param name="margin" as="xs:integer"/>
<xsl:param name="an-offset" as="xs:integer"/>
<xsl:param name="av-offset" as="xs:integer"/>
<xsl:param name="multi-line" as="xs:boolean"/>
<xsl:param name="auto-trim" as="xs:boolean"/>

<xsl:variable name="span" select="$spans[$index]"/>
<xsl:variable name="class" select="$span/@class"/>
<xsl:variable name="nextClass" select="$spans[$index + 1]/@class" as="xs:string?"/>
<xsl:variable name="prevClass" select="$spans[$index - 1]/@class" as="xs:string?"/>

<xsl:variable name="level2" select="if ($class eq 'scx') then $level + 1
else if ($class eq 'ez') then $level - 1
else $level"/>
<xsl:variable name="outdent" as="xs:boolean"
select="if ($index lt count($spans)) then
$spans[$index + 1]/@class eq 'ez'
else false()"/>

<xsl:if test="exists($span)">

<xsl:variable name="indentOutput" select="f:indentTextSpan(
$span, $level, $margin, $an-offset, $av-offset, $outdent,
$nextClass, $prevClass, $multi-line, $auto-trim
)"/>

<xsl:sequence select="$indentOutput/span"/>
<xsl:if test="$index lt count($spans)">
<xsl:call-template name="indentSpans">
<xsl:with-param name="index" as="xs:integer" select="$index + 1"/>
<xsl:with-param name="level" as="xs:integer" select="$level2"/>
<xsl:with-param name="margin" as="xs:integer" select="$margin"/>
<xsl:with-param name="an-offset" as="xs:integer" select="$indentOutput/an-offset"/>
<xsl:with-param name="av-offset" as="xs:integer" select="$indentOutput/av-offset"/>
<xsl:with-param name="multi-line" as="xs:boolean" select="$indentOutput/multi-line"/>
<xsl:with-param name="auto-trim" as="xs:boolean" select="$auto-trim"/>
</xsl:call-template>
</xsl:if>

</xsl:if>
</xsl:template>

<!--
signature:
    f:link(spans, paths, location)

description:
    For XPath functions and variables, wraps their <span> elements with <a>
    elements and href attribute with #id values

    Calls this function after f:target() has been called on each XSLT in the
    module collection that adds the corresponding id attribute and produces
    the paths data

params:
    spans:     element sequence containing span elements output from f:render()
    paths:     element sequence with one element for each function or variable defined
               members of each element identify the function/variable name and
               its path relative to the top-level folder
    location:  the path of the current file relative to the top-level
-->

<xsl:function name="f:link">
<xsl:param name="spans" as="element()*"/>
<xsl:param name="paths" as="xs:string*"/>
</xsl:function>

<xsl:function name="f:clark-name" as="xs:string">
<xsl:param name="xmlns" as="element()"/>
<xsl:param name="name" as="xs:string"/>

<xsl:variable name="prefix" select="substring-before($name, ':')"/>
<xsl:variable name="prefix-length"
select="if ($prefix eq '') then 1
else string-length($prefix) + 2"/>

<xsl:variable name="local-name" select="substring($name, $prefix-length)" as="xs:string"/>
<xsl:sequence
select="if ($prefix eq '') then
$local-name
else
concat('{',
$xmlns/ns[@prefix eq $prefix]/@uri,
'}',
$local-name)
"/>

</xsl:function>

<xsl:function name="f:gen-id" as="xs:string">
<xsl:param name="type-prefix"/>
<xsl:param name="clark-name"/>
<xsl:variable name="char" select="substring($type-prefix,1,1)"/>
<xsl:value-of select="concat($char, '?',$clark-name)"/>

</xsl:function>


<xsl:template match="span" mode="markup">
<xsl:param name="xmlns" as="element()" tunnel="yes"/>
<xsl:param name="globals" as="element()" tunnel="yes"/>
<!--
<xsl:param name="element-qname" as="xs:QName"/>
-->
<xsl:variable name="ref-name"
select="if (@class eq 'variable') then
substring(., 2)
else ." as="xs:string"/>
<xsl:variable name="clark-name" select="f:clark-name($xmlns, $ref-name)" as="xs:string"/>
<xsl:variable name="id" select="f:gen-id(@class, $clark-name)"/>

<xsl:choose>
<xsl:when test="@class = ('fname', 'tname')">
<xsl:copy>
<xsl:copy-of select="@*"/>
<xsl:attribute name="id" select="$id"/>
<xsl:value-of select="$ref-name"/>
</xsl:copy>
</xsl:when>
<xsl:when test="@class = 
('variable', 'href','tcall')
or
(@class eq 'function' and contains(., ':'))">

<xsl:variable name="href"
select="if (@class eq 'href') then
concat(., '.html')
else
concat('#',$id)"/>
<a href="{$href}" class="solar">
<xsl:copy-of select="."/>
</a>
</xsl:when>
<xsl:otherwise>
<xsl:copy-of select="."/>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:function name="f:get-xmlns" as="element()">
<xsl:param name="spans" as="element()*"/>
<xsl:variable name="p-spans" as="element()">
<p>
<xsl:call-template name="get-root-spans">
<xsl:with-param name="spans" as="element()*"
 select="$spans" tunnel="yes"/>
<xsl:with-param name="index" as="xs:integer" select="1"/>
</xsl:call-template>
</p>
</xsl:variable>
<xmlns>
<xsl:for-each select="$p-spans/span[@class eq 'atn'][starts-with(., 'xmlns')]">
<xsl:variable name="att-value">
<xsl:call-template name="get-next-class">
<xsl:with-param name="spans" as="element()*" tunnel="yes"/>
<xsl:with-param name="index" as="xs:integer" select="count(preceding-sibling::*)"/>
<xsl:with-param name="class" as="xs:string" select="'av'" tunnel="yes"/>
</xsl:call-template> 
</xsl:variable>
<ns prefix="{substring-after(., ':')}"
uri="{./following-sibling::*[position() lt 5][@class eq 'av'][1]}"/>
</xsl:for-each>
</xmlns>
</xsl:function>

<xsl:template name="get-root-spans">
<xsl:param name="spans" tunnel="yes" as="element()*"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:variable name="span" select="$spans[$index]"/>

<xsl:if test="$index + 1 lt count($spans)
and $span/@class ne 'scx'">
<xsl:sequence select="$span"/>
<xsl:call-template name="get-root-spans">
<xsl:with-param name="index" select="$index + 1"/>
</xsl:call-template>
</xsl:if>

</xsl:template>

<xsl:template name="get-next-class" as="element()?">
<xsl:param name="spans" tunnel="yes" as="element()*"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:param name="class" as="xs:string" tunnel="yes"/>
<xsl:variable name="span" select="$spans[$index]"/>

<xsl:choose>
<xsl:when test="$span/@class eq $class">
<xsl:sequence select="$span"/>
</xsl:when>
<xsl:when test="$index + 1 lt count($spans)">
<xsl:call-template name="get-root-spans">
<xsl:with-param name="index" select="$index + 1"/>
</xsl:call-template>
</xsl:when>
</xsl:choose>

</xsl:template>



<xsl:function name="f:indentTextSpan" as="element()">
<xsl:param name="span" as="element()"/>
<xsl:param name="level" as="xs:integer"/>
<xsl:param name="margin" as="xs:integer"/>
<xsl:param name="an-offset" as="xs:integer"/>
<xsl:param name="av-offset" as="xs:integer"/>
<xsl:param name="outdent" as="xs:boolean"/>
<xsl:param name="nextClass" as="xs:string?"/>
<xsl:param name="prevClass" as="xs:string?"/>
<xsl:param name="multi-line" as="xs:boolean"/>
<xsl:param name="auto-trim" as="xs:boolean"/>

<xsl:variable name="class" select="$span/@class"/>


<xsl:variable name="line-parts" as="element()*">
<xsl:analyze-string select="$span" regex="\n.*">
<xsl:matching-substring>
<nl>
<xsl:variable name="text" select="substring(., 2)" as="xs:string"/>
<xsl:value-of select="if ($auto-trim)
then f:left-trim($text)
else $text"/>
</nl>
</xsl:matching-substring>
<xsl:non-matching-substring>
<tt>
<xsl:value-of select="."/>
</tt>
</xsl:non-matching-substring>
</xsl:analyze-string>
</xsl:variable>

<xsl:variable name="firstLine" as="element()?"
select="$line-parts[1]"/>

<xsl:variable name="indented-lines" as="xs:string*">
<xsl:sequence select="for $a in $line-parts[name(.) eq 'nl'] return
string($a)"/>
</xsl:variable>

<xsl:variable name="flat-part" as="element()?"
select="$line-parts[name(.) eq 'tt']"/>


<!-- should be max of 1 -->
<xsl:variable name="flat-line" as="xs:string"
select="if ($flat-part) then $flat-part else ''"/>



<!-- constant indent when first attribute is on a new line -->
<xsl:variable name="compact" select="4" as="xs:integer"/>


<xsl:variable name="lineOffset" as="xs:integer"
select="if (exists($firstLine))
    then string-length($firstLine)
else 0"/>

<xsl:variable name="an-outOffset" as="xs:integer"
select="if ($class = ('en','enxsl'))
    then $lineOffset + 1
else if ($prevClass = ('en','enxsl'))
    then
if (exists($indented-lines)) then 
    $compact
    else $an-offset + $lineOffset
else $an-offset"/>

<xsl:variable name="av-outOffset" as="xs:integer"
select="if ($prevClass = ('en','enxsl'))
    then 0
else if ($class eq 'atn' and $multi-line)
    then $lineOffset 
else if ($prevClass eq 'atneq' or $class = ('atneq','atn','vname','av')
    or ($class eq 'z' and $nextClass = ('atneq','atn','vname','av'))
or ($class eq 'z' and $prevClass = ('vname','av')))
    then $av-offset + $lineOffset
else $av-offset"/>

<xsl:variable name="offset" as="xs:integer"
select="if ($prevClass = ('en','enxsl'))
    then $compact
else if ($nextClass eq 'atn') 
    then $an-outOffset
else if ($nextClass = 'av' or $class eq 'whitespace')
    then $an-outOffset + $av-outOffset
else 0"/>

<xsl:variable name="indent" select="f:createIndent(($level * $margin) + $offset)"/>
<xsl:variable name="last-level" select="if ($outdent) then $level - 1 else $level" as="xs:integer"/>
<xsl:variable name="last-indent" select="f:createIndent(($last-level * $margin) + $offset)"/>


<xsl:variable name="line-count" select="count($indented-lines)" as="xs:integer"/>

<xsl:variable name="span-text" as="xs:string"
select="if (exists($indented-lines))
then string-join(
($flat-line,
for $num in 1 to $line-count - 1 return
concat('&#10;', $indent, $indented-lines[$num]),
concat('&#10;', $last-indent, $indented-lines[$line-count]) 
),
'')
else if ($multi-line and $offset gt 0) then
concat($indent, string($line-parts[1]))
else string($line-parts[1])"/>
<output>
<span>
<xsl:copy-of select="$span/@*"/>
<xsl:value-of select="$span-text"/>
</span>
<!--
<span class="literal">
<xsl:text>[il: </xsl:text><xsl:value-of select="$line-count"/><xsl:text>]</xsl:text>
<xsl:for-each select="$line-parts">
<xsl:value-of select="name(.)"/>
<xsl:text> </xsl:text>
</xsl:for-each>
<xsl:text>]]</xsl:text>
</span>
-->
<an-offset>
<xsl:value-of select="$an-outOffset"/>
</an-offset>
<av-offset>
<xsl:value-of select="$av-outOffset"/>
</av-offset>
<multi-line>
<xsl:value-of select="exists($indented-lines)"/>
</multi-line>
</output>

</xsl:function>

<xsl:function name="f:left-trim" as="xs:string">
<xsl:param name="text"/>
<xsl:value-of select="replace($text, '^\s+', '')"/>
</xsl:function>

<xsl:function name="f:createIndent" as="xs:string?">
<xsl:param name="padCount" as="xs:integer"/>
<xsl:if test="$padCount ge 0">
<xsl:sequence select="string-join(for $i in 1 to $padCount 
return ' ','')"/>
</xsl:if>
</xsl:function>

<!--
signature: 
    f:get-css(is-light-theme)

description:

    Generates a CSS file used to colorise span elements generates by the previous 2 functions
    The colors generated depend on whether a light or dark them is specified with the is-light-theme
    parameter. The color theme uses the 'Solarized' color points specified at: http://ethanschoonover.com/solarized

params:
    is-light-theme: boolean indicating whether to generate colors for a light or dark background. 

-->
<xsl:function name="f:get-css">
<xsl:param name="is-light-theme" as="xs:boolean"/>
<xsl:apply-templates select="document('')/xsl:stylesheet/css:theme" mode="css">
<xsl:with-param name="is-light-theme" select="$is-light-theme" tunnel="yes"/>
</xsl:apply-templates>
</xsl:function>

<xsl:function name="f:prefixed-name" as="xs:string*">
<xsl:param name="prefix" as="xs:string"/>
<xsl:param name="name" as="xs:string+"/>
<xsl:for-each select="$name">
<xsl:sequence select="concat($prefix, .)"/>
</xsl:for-each>
</xsl:function>

<xsl:function name="f:get-xsd-names" as="xs:string*">
<xsl:param name="prefix" as="xs:string"/>
<xsl:sequence
select="for $a in ('assert') return concat($prefix, $a)"/>
</xsl:function>

<xsl:function name="f:get-xsd-fnames" as="xs:string*">
<xsl:param name="prefix" as="xs:string"/>
<xsl:sequence
select="for $a in ('element','attribute') return concat($prefix, $a)"/>
</xsl:function>

<xsl:template match="css:background" mode="css">
<xsl:param name="is-light-theme" tunnel="yes" as="xs:boolean"/>
<xsl:value-of select="if ($is-light-theme) then @light else @dark"/>
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
<xsl:param name="is-xsl" as="xs:boolean"/>
<xsl:param name="root-prefix" as="xs:string"/>

<xsl:variable name="is-xsd" select="not($is-xsl)" as="xs:boolean"/>

<xsl:variable name="token" select="$tokens[$index]" as="xs:string?"/>
<xsl:variable name="prevToken" select="$tokens[$index + 1]" as="xs:string?"/>
<xsl:variable name="nextToken" select="$tokens[$index - 1]" as="xs:string?"/>
<xsl:variable name="awaiting" select="$expected ne 'n'" as="xs:boolean"/>


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
<span class="txt">
<!--
id="{js:getStackIndex()}">
-->
<xsl:value-of select="substring($token, string-length($beforeFind) + string-length($expected) + 1)"/>
</span>
</xsl:if>
</xsl:if>
</xsl:variable>

<!-- return 2 strings if required close found - that befoe and that after (even if empty string)
 if no required close found - just return the required close-->
<xsl:variable name="parseStrings" as="element()*">
<xsl:if test="not($awaiting)">
<xsl:variable name="char1" as="xs:string?" select="substring($token,1,1)"/>
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
<xsl:when test="$char1 = ('?','!','/')">
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

<xsl:choose>
<xsl:when test="$isElementClose">
<span class="{if ($is-xsl and starts-with($tagContent, $root-prefix))
then 'clxsl'
else if ($is-xsd and $tagContent = f:get-xsd-fnames($root-prefix)) then 'clxsl'
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
<span class="txt">
<xsl:if test="$isElementClose">
<!--
<xsl:attribute name="id" select="js:getStackIndex()"/>
-->
</xsl:if>
<xsl:value-of select="substring($token, string-length($beforeClose) + string-length($requiredClose) + 1)"/>
</span>
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

<xsl:variable name="pre-text" select="substring-before($parts[1], '>')"/>

<!--
<span>[parts]<xsl:value-of select="string-join($parts,'/')"/></span>
-->

<xsl:sequence select="f:getAttributes($token, 0, $parts, 1, $is-xsl, $root-prefix, '')"/>

<!-- must be an open tag, so check for attributes -->

</xsl:otherwise>
</xsl:choose>
</xsl:if>
</xsl:variable>

<xsl:variable name="newLevel" as="xs:integer" select="0"/>

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
<xsl:sequence select="f:iterateTokens($counter + 1, $tokens, $index + 1, $newExpected, $newBeganAt, $newLevel, $is-xsl, $root-prefix)"/>
</xsl:if>
</xsl:function>

<xsl:function name="f:getAttributes" as="item()*">
<xsl:param name="attToken" as="xs:string"/>
<xsl:param name="offset" as="xs:integer"/>
<xsl:param name="parts" as="xs:string*"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:param name="is-xsl" as="xs:boolean"/>
<xsl:param name="root-prefix" as="xs:string"/>
<xsl:param name="ename" as="xs:string"/>

<xsl:variable name="is-xsd" select="not($is-xsl)" as="xs:boolean"/>

<xsl:variable name="part1" as="xs:string?"
select="$parts[$index]"/>
<xsl:variable name="part2" as="xs:string?"
select="$parts[$index + 1]"/>

<xsl:variable name="elementName" as="xs:string?"
select="if ($ename eq '') then
tokenize($part1, '>|\s+|/')[1]
else $ename"/>

<xsl:variable name="is-xsl-element" select="$is-xsl and starts-with($attToken, $root-prefix)"/>

<xsl:if test="$index eq 1">
<span class="es">&lt;</span>
<span class="{if ($is-xsl-element)
then 'enxsl'
else if ($is-xsd and $elementName = f:get-xsd-fnames($root-prefix)) then 'enxsl' 
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

<xsl:choose>
<xsl:when test="$isFinalPart">
<!--  use sc class value to mark end of self-closed element -->
<xsl:variable name="isSelfClosed" select="ends-with($pre-close,'/')" as="xs:boolean"/>
<span class="{if ($isSelfClosed) then 'sc' else 'scx'}">
<xsl:if test="$isSelfClosed">
<!--
<xsl:attribute name="id" select="js:stackPop()"/>
-->
</xsl:if>
<xsl:value-of select="if ($isSelfClosed) then '/' else ''"/>&gt;</span>
<span class="txt">
<xsl:if test="$isSelfClosed">
<!--
<xsl:attribute name="id" select="js:getStackIndex()"/>
-->
</xsl:if>
<xsl:value-of select="substring($attToken, string-length($pre-close) + $offset + 2)"/>
</span>
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

<xsl:sequence select="$attSpans"/>
<xsl:variable name="isXPath"
select="if ($is-xsl-element)
then $att-name = ('select','test', 'match')
else if ($is-xsd and f:get-xsd-names($root-prefix) = $elementName and $attSpans[@class = 'atn'] = 'test') 
then true()
else false()"/>

<!-- for coloring attribute values that are referenced from XPath -->
<xsl:variable name="metaXPathName" as="xs:string"
select="f:get-av-class($is-xsl-element, $is-xsd, 
               $elementName, $att-name, $root-prefix)"/>


<span class="atneq"><xsl:value-of select="substring($left,string-length($pre) + 1)"/></span>

<xsl:variable name="sl" select="string-length($part2)" as="xs:double"/>
<span class="z"><xsl:value-of select="substring($part2,1,1)"/></span>

<xsl:variable name="attValue" select="substring($part2, 2, $sl - 2)"/>

<xsl:if test="$att-name eq 'mode'">
<xsl:message>mode: <xsl:value-of select="$attValue, $metaXPathName, 'en', $elementName, 'pfx', $root-prefix"/></xsl:message>
</xsl:if>

<xsl:choose>
<xsl:when test="$isXPath">
<xsl:sequence select="loc:showXPath($attValue)"/>
</xsl:when>
<xsl:when test="$is-xsl">
<xsl:sequence select="f:processAVT($attValue, $metaXPathName)"/>
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

<xsl:variable name="newOffset" select="string-length($part1) + string-length($part2) + $offset"/>

<xsl:if test="not($isFinalPart)">
<xsl:sequence select="f:getAttributes($attToken, $newOffset, $parts, $index + 2, $is-xsl, $root-prefix, $elementName)"/>
</xsl:if>

</xsl:function>

<xsl:function name="f:get-av-class" as="xs:string">
<xsl:param name="is-xsl-element" as="xs:boolean"/>
<xsl:param name="is-xsd" as="xs:boolean"/>
<xsl:param name="elementName"/>
<xsl:param name="att-name"/>
<xsl:param name="root-prefix"/>
<xsl:value-of
select="if ($is-xsl-element) then
if ($elementName = f:prefixed-name($root-prefix, ('variable', 'param'))
    and $att-name eq 'name') then 'vname'
else if ($elementName = f:prefixed-name($root-prefix, ('import', 'include'))
    and $att-name eq 'href') then 'href'
else if ($elementName = f:prefixed-name($root-prefix, ('call-template'))
    and $att-name eq 'name') then 'tcall'
else if ($elementName = f:prefixed-name($root-prefix, 'function') 
    and $att-name eq 'name') then 'fname'
else if ($elementName = f:prefixed-name($root-prefix, 'template') 
    and $att-name eq 'name') then 'tname'
else 'av'
else if ($is-xsd and $elementName = f:get-xsd-fnames($root-prefix)) then 'fname' else 'av'"/>


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
<xsl:variable name="regex2" select="part" as="xs:string"/>

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

<!-- css dark-theme: background color #002b36 = base 03 
 light-theme #fdf6e3 = base 3-->

<css:theme>
p.spectrum {
    margin:0px;
    font-family: monospace;
    white-space: pre-wrap;
    display: block;
    border: none thin;
    border-color: #405075;
    background-color:<css:background dark="#002b36" light="#white"/>;
padding: 2px;
margin-bottom:5px;
}

.spectrum span {
    white-space: pre-wrap;
}
/*
chosen theme background: <css:background dark="dark" light="light"/>;

$base03:    #002b36; //background
$base02:    #073642; //highlighted-background
$base01:    #586e75;
$base00:    #657b83;
$base0:     #839496;
$base1:     #93a1a1;
$base2:     #eee8d5; //highlighted-background
$base3:     #fdf6e3; //background
$yellow:    #b58900;
$orange:    #cb4b16;
$red:       #dc322f;
$magenta:   #d33682;
$violet:    #6c71c4;
$blue:      #268bd2;
$cyan:      #2aa198;
$green:     #859900;
*/

/* solorized colors */
span.base03 {
color: #002b36;
}
span.base02 {
color: #073642;
}

/* hover-effect [start] */
span.base03, span.ww:not(:hover), span.txt:not(:hover), span.cm:not(:hover), span.pi:not(:hover)  {
background-color: <css:background dark="#002b36" light="white"/>;
}
span.ww {
background-color: <css:background dark="#00202e" light="#fdf6e3"/>;
}
/* hover-effect [end] */

span.base01, span.eq-equ, span.z, span.sc, span.scx, span.ec, span.es, span.ez, span.atneq {
color: <css:background dark="#586e75" light="#93a1a1"/>;
}
span.base00 {
color: #657b83;
}
span.base0, span.txt, span.cd {
color: #839496;
}
span.base1, span.literal, span.av {
color:<css:background dark="#93a1a1" light="#586e75"/>;
}
span.base2 {
    color: #eee8d5;
}
span.base3 {
    color: #fdf6e3;
}
span.yellow, span.op, span.type-op, span.if, span.higher, span.step {
    color: #b58900;
}
span.orange, span.type, span.node-type, span.function {
    color: #cb4b16;
}
span.red, span.fname, span.tname {
    color: #dc322f;
}
span.magenta, span.vname, span.variable, span.external {
    color: #d33682;
}
span.violet, span.qname, span.type-name, span.unclosed, span.en, span.cl, span.href, span.tcall {
    color: #6c71c4;
}
span.blue, span.enxsl, span.clxsl, span.enx, 
span.filter, span.parenthesis, span.node{
    color: #268bd2;
}
span.cyan, span.atn, span.numeric, span.pi, span.dt, span.axis, span.context {
    color: #2aa198;
}
span.green, span.cm, span.comment {
    color: #859900;
}
a.solar {
    text-decoration:none;
}
</css:theme>

<!-- xpath-colorer -->

<xsl:variable name="ops" select="', / = &lt; &gt; + - * ? | != &lt;= &gt;= &lt;&lt; &gt;&gt; //'"/>
<xsl:variable name="aOps" select="'or and eq ne lt le gt ge is to div idiv mod union intersect except in return satisfies then else'"/>
<xsl:variable name="hOps" select="'for some every'"/>
<xsl:variable name="nodes" select="'attribute comment document-node element node processing-instruction text'"/>
<xsl:variable name="types" select="'empty item node schema-attribute schema-element type'"/>

<xsl:variable name="ambiguousOps" select="tokenize($aOps,'\s+')" as="xs:string*"/>
<xsl:variable name="simpleOps" select="tokenize($ops,'\s+')" as="xs:string*"/>
<xsl:variable name="nodeTests" select="tokenize($nodes,'\s+')" as="xs:string*"/>
<xsl:variable name="typeTests" select="tokenize($types,'\s+')" as="xs:string*"/>
<xsl:variable name="higherOps" select="tokenize($hOps,'\s+')" as="xs:string*"/>
<xsl:variable name="bgColor" select="'black'" as="xs:string"/>


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

<xsl:variable name="chars" as="xs:string*"
select="loc:stringToCharSequence($chunk)"/>

<xsl:variable name="blocks" as="element()*">
<xsl:sequence select="loc:createBlocks($chars, false(), 1, '', 0, 0)"/>
</xsl:variable>
<xsl:variable name="pbPairs" as="element()*"
select="loc:createPairs($blocks[name() = 'block' and @type = ('[',']','(',')')])"/>

<xsl:variable name="omitPairs" as="element()*"
select="($blocks[name() = ('literal','comment')])"/>

<xsl:variable name="tokens" as="element()*">
<xsl:sequence select="loc:getTokens($chunk, $omitPairs, $pbPairs)"/>
</xsl:variable>

<xsl:call-template name="plain">
<xsl:with-param name="para" select="$tokens"/>
</xsl:call-template>


</xsl:function>


<!-- //////////////////////////////////////////////////////////////////////////////////////////////// -->

<!-- 
 Sample output:
<block position="3" type="["/>
<literal type="'" start="54" end="61"/>
<comment start="65" end="69"/>
<comment start="76"/> // if not closed
 -->

<!-- diagnostic formatting function - not used -->
<xsl:function name="loc:pad" as="xs:string">
<xsl:param name="padStringIn" as="xs:string?"/>
<xsl:param name="fixedWidth" as="xs:integer"/>
<xsl:variable name="padString" as="xs:string" select="replace($padStringIn, '\n','\\n')"/>
<xsl:variable name="stringLength" as="xs:integer" select="string-length($padString)"/>
<xsl:variable name="padChar" select="if ($fixedWidth gt 20) then '.' else ' '"/>
<xsl:variable name="padCount" as="xs:integer" select="$fixedWidth - $stringLength"/>
<xsl:if test="$padCount ge 0">
<xsl:sequence select="concat($padString, string-join(for $i in 1 to $padCount 
return $padChar,''))"/>
</xsl:if>
<xsl:if test="$padCount lt 0">
<xsl:sequence select="concat($padString, '&#10;',' ', string-join(for $i in 1 to $fixedWidth 
return $padChar,''))"/>
</xsl:if>
</xsl:function>

<xsl:template name="plain">
<xsl:param name="para" as="element()*"/>

<xsl:variable name="total" select="count($para)" as="xs:integer"/>
<xsl:for-each select="1 to $total">
<xsl:variable name="index" select="."/>
<xsl:for-each select="$para[$index]">
<xsl:variable name="isJoined" as="xs:boolean"
select="string-length(@value) gt 1 and ends-with(@value, '(')"/>
<xsl:variable name="isLiteral" as="xs:boolean" select="if (empty(@type)) then false() else @type eq 'literal'"/>
<xsl:variable name="literalQuote" select="substring(@value, 1, 1)"/>
<xsl:if test="$isLiteral">
<span class="op">
<xsl:value-of select="$literalQuote"/>
</span>
</xsl:if>
<span>

<xsl:if test="@type eq 'variable' and $index + 2 lt $total">
<xsl:if test="$para[$index + 1]/@type eq 'whitespace' and $para[$index + 2]/@value eq 'in'">
<xsl:attribute name="id" select="concat('rng-',@value)"/>
</xsl:if>
</xsl:if>

<xsl:variable name="className">
<xsl:choose>
<xsl:when test="exists(@type)">
<xsl:value-of select="if (@type eq 'literal' and
matches(@value ,'select[\n\p{Zs}]*=[\n\p{Zs}]*[&quot;&apos;&apos;]'))
then 'select'
else @type"/>
</xsl:when>
<xsl:otherwise>
<xsl:variable name="p" select="$para[$index - 1] "/>
<xsl:value-of select="if ($p/@type eq 'literal' and
matches($p/@value ,'name[\n\p{Zs}]*=[\n\p{Zs}]*[&quot;&apos;&apos;]'))
then 'external'
else 'qname'"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:attribute name="class" select="$className"/>

<xsl:if test="$className eq 'external'">
<xsl:attribute name="id" select="concat('ext-',@value)"/>
</xsl:if>

<xsl:attribute name="start" select="@start"/>

<xsl:if test="(@value = ('(','[') or @type eq 'function') and not(@pair-end)">
<xsl:attribute name="style" select="'color: pink;'"/>
</xsl:if>

<xsl:if test="@pair-end">
<xsl:attribute name="pair-end" select="@pair-end"/>
</xsl:if>

<xsl:if test="not(@type) or 
(@type = ('function','filter','parenthesis','variable','node')) and (not(@value = (')',']'))) or
(@value eq '*' and $para[$index - 1]/@class eq 'axis')">
<xsl:attribute name="select" select="'quick'"/>
</xsl:if>

<!--
<xsl:choose>
<xsl:when test="@type = ('literal','comment')">
<xsl:analyze-string 
select="if ($isLiteral) then substring(@value, 2, string-length(@value) - 2)
else @value" regex="\n">
<xsl:matching-substring>
<br></br>
</xsl:matching-substring>
<xsl:non-matching-substring>
<xsl:value-of select="."/>
</xsl:non-matching-substring>
</xsl:analyze-string>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="if ($isJoined) then substring(@value, 1, string-length(@value) - 1) else @value"/>
</xsl:otherwise>
</xsl:choose>
-->

<xsl:choose>
<xsl:when test="@type = ('literal','comment')">
<xsl:value-of select="if ($isLiteral) then substring(@value, 2, string-length(@value) - 2)
else @value"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="if ($isJoined) then substring(@value, 1, string-length(@value) - 1) else @value"/>
</xsl:otherwise>
</xsl:choose>

</span>


<xsl:if test="$isJoined">
<span class="parenthesis">
<xsl:text>(</xsl:text>
</span>
</xsl:if>

<xsl:if test="$isLiteral">
<span class="op">
<xsl:value-of select="$literalQuote"/>
</span>
</xsl:if>

</xsl:for-each>
</xsl:for-each>
</xsl:template>

<xsl:template match="token" mode="plainLine">
<span>
<xsl:attribute name="class" select="@type"/>
<xsl:attribute name="start" select="@start"/>
<xsl:variable name="revChars" select="reverse(string-to-codepoints(@value))" as="xs:integer*"/>
<xsl:variable name="lastLF" select="count($revChars) + 1 - index-of($revChars, 10)[1]"/>
<xsl:value-of select="substring(@value, $lastLF + 1)"/>
</span>
</xsl:template>

<xsl:template match="token" mode="dev">
<p><xsl:value-of select="@start"/></p>
</xsl:template>

<xsl:function name="loc:stringToCharSequence" as="xs:string*">
<xsl:param name="string"/>
<xsl:sequence select="for $i in 1 to string-length($string)
return substring($string, $i, 1)"/>
</xsl:function>

<xsl:function name="loc:createPairs" as="element()*">
<xsl:param name="brackets" as="element()*"/>
<xsl:variable name="nested" as="element()*">
<xsl:call-template name="getNesting">
<xsl:with-param name="positions" select="$brackets" tunnel="yes" as="element()*"/>
<xsl:with-param name="level" select="0" as="xs:integer"/>
<xsl:with-param name="index" select="1" as="xs:integer"/>
</xsl:call-template>
</xsl:variable>
<!--  pair up start and end elements -->
<xsl:variable name="ends" select="$nested[@end]"/>
<xsl:for-each select="$nested[@start]">
<xsl:variable name="start" select="@start" as="xs:integer"/>
<xsl:variable name="level" select="@level"/>
<xsl:variable name="pair" select="($ends[@level = $level])[number(@end) > $start][1]"
as="element()*"/>
<xsl:element name="{name(.)}">
<xsl:attribute name="start" select="$start"/>
<xsl:attribute name="level" select="$level"/>
<xsl:if test="$pair">
<xsl:attribute name="end" select="$pair/@end"/>
</xsl:if>
</xsl:element>
</xsl:for-each>
</xsl:function>

<xsl:template name="getNesting">
<xsl:param name="positions" tunnel="yes"/>
<xsl:param name="level" as="xs:integer"/>
<xsl:param name="index" as="xs:integer"/>

<xsl:variable name="pos" select="$positions[$index]"/>
<xsl:variable name="isOpen" select="$pos/@type = ('(','[', '(:')" as="xs:boolean"/>
<xsl:variable name="isBracket" select="$pos/@type = ('(',')')" as="xs:boolean"/>
<xsl:variable name="isComment" select="$pos/@type = ('(:',':)')" as="xs:boolean"/>
<xsl:variable name="blockType" select="if($isBracket) then 'bracket'
else if($isComment) then 'comment'
else 'predicate'"/>
<xsl:variable name="newLevel" select="if($isOpen) then
$level + 1 else $level - 1"/>

<xsl:choose>
<xsl:when test="empty($pos)"/>
<xsl:when test="$isOpen">
<xsl:element name="{$blockType}">
<xsl:attribute name="start" select="$pos/@position"/>
<xsl:attribute name="level" select="$newLevel"/>
</xsl:element>
</xsl:when>
<xsl:otherwise>
<xsl:element name="{$blockType}">
<xsl:attribute name="end" select="$pos/@position"/>
<xsl:attribute name="level" select="$level"/>
</xsl:element>
</xsl:otherwise>
</xsl:choose>

<xsl:choose>
<xsl:when test="$index + 1 > count($positions)"/>
<xsl:otherwise>
<xsl:call-template name="getNesting">
<xsl:with-param name="level" select="$newLevel" as="xs:integer"/>
<xsl:with-param name="index" select="$index + 1" as="xs:integer"/>
</xsl:call-template>
</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:function name="loc:createBlocks" as="element()*">
<xsl:param name="chars" as="xs:string*"/>
<xsl:param name="skip" as="xs:boolean"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:param name="awaiting" as="xs:string"/>
<xsl:param name="start" as="xs:integer"/>
<xsl:param name="level" as="xs:integer"/>

<xsl:variable name="charCount" select="count($chars)"/>

<xsl:variable name="char" select="$chars[$index]"/>
<xsl:variable name="nChar" select="$chars[$index + 1]"/>
<xsl:variable name="pChar" select="$chars[$index - 1]"/>

<xsl:variable name="newLevel" as="xs:integer">
<xsl:choose>
<xsl:when test="$awaiting = ':)'">
<xsl:value-of select="if($char = '(' and $nChar = ':') then $level + 1
else if ($char = ')' and $pChar = ':' and $level gt 0) then $level -1
else $level"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$level"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:variable name="nowAwaiting">
<xsl:choose>
<xsl:when test="$awaiting=''">
<xsl:value-of select="if($char = ('&apos;&apos;','&quot;'))
then $char 
else if ($char = '(' and $nChar = ':') then ':)' 
else ''"/>
</xsl:when>
<xsl:when test="$char = $awaiting">
<xsl:value-of select="''"/>
</xsl:when>
<xsl:when test="$awaiting = ':)' and $char = ')' and $pChar = ':' and $level = 0">
<xsl:value-of select="''"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$awaiting"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:variable name="nowSkip" as="xs:boolean">
<xsl:choose>
<xsl:when test="$skip">
<xsl:value-of select="false()"/>
</xsl:when>
<xsl:when test="$char = $awaiting and $nChar = $char">
<xsl:value-of select="true()"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="false()"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:if test="$awaiting = '' and $nowAwaiting = ''">
<xsl:if test="$char = ('[',']','(',')')">
<block position="{$index}" type="{$char}"/>
</xsl:if>
</xsl:if>

<xsl:variable name="isFound" as="xs:boolean"
select="not($awaiting = $nowAwaiting) and not($skip or $nowSkip)"/>

<xsl:variable name="newStart" as="xs:integer"
select="if ($isFound) then $index else $start"/>

<xsl:if test="$awaiting ne '' and $isFound">
<xsl:element name="{if ($awaiting = ':)') then 'comment' else 'literal'}">
<xsl:if test="$awaiting ne ':)'">
<xsl:attribute name="type" select="$char"/>
</xsl:if>
<xsl:attribute name="start" select="$start"/>
<xsl:attribute name="end" select="$index"/>
</xsl:element>
</xsl:if>

<xsl:choose>
<xsl:when test="$index eq $charCount">
<xsl:if test="$awaiting ne '' and not($isFound)">
<xsl:element name="{if ($awaiting = ':)') then 'comment' else 'literal'}">
<xsl:if test="$awaiting ne ':)'">
<xsl:attribute name="type" select="$awaiting"/>
</xsl:if>
<xsl:attribute name="start" select="$start"/>
</xsl:element>
</xsl:if>
</xsl:when>
<xsl:otherwise>
<xsl:sequence select="loc:createBlocks($chars, $nowSkip, $index + 1, $nowAwaiting, $newStart, $newLevel)"/>
</xsl:otherwise>
</xsl:choose>

</xsl:function>

<!-- top-level call - marks up tokens with their type -->
<xsl:function name="loc:getTokens">
<xsl:param name="chunk" as="xs:string"/>
<xsl:param name="omitPairs" as="element()*"/>
<xsl:param name="pbPairs" as="element()*"/>
<xsl:variable name="tokens" as="element()*"
select="loc:createTokens($chunk, $omitPairs, 1, 1)"/>

<xsl:sequence select="loc:rationalizeTokens($tokens, 1, false(), $pbPairs, false(), false())"/>

</xsl:function>


<xsl:function name="loc:rationalizeTokens">
<xsl:param name="tokens" as="element()*"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:param name="prevIsClosed" as="xs:boolean"/>
<xsl:param name="pbPairs" as="element()*"/>
<xsl:param name="typeExpected" as="xs:boolean"/>
<xsl:param name="quantifierExpected" as="xs:boolean"/>

<!-- when closed, a probable operator is a QName instead -->

<xsl:variable name="token" select="$tokens[$index]" as="element()?"/>
<xsl:variable name="isQuantifier" select="$quantifierExpected and $token/@value = ('?','*','+')"/>
<xsl:variable name="currentIsClosed" as="xs:boolean"
select="$isQuantifier or not($token/@type) or ($token/@value = (')',']') or ($token/@type = ('literal','numeric','variable', 'context')))"/>
<xsl:element name="token">
<xsl:attribute name="start" select="$token/@start"/>
<xsl:attribute name="end" select="$token/@end"/>
<xsl:attribute name="value" select="$token/@value"/>

<xsl:choose>
<xsl:when test="$token/@type = 'probableOp'">
<xsl:if test="$prevIsClosed">
<xsl:attribute name="type" select="'op'"/>
</xsl:if>
</xsl:when>
<xsl:when test="not($isQuantifier) and not($prevIsClosed) and $token/@value eq '*'">
<!--
<xsl:attribute name="type" select="'any'"/>

--></xsl:when>
<xsl:when test="$token/@type = ('function','if', 'node') or $token/@value = ('(','[')">
<xsl:variable name="pair" select="$pbPairs[@start = $token/@end]"/>
<xsl:choose>
<xsl:when test="$typeExpected and $token/@type eq 'node'">
<xsl:attribute name="type" select="'node-type'"/>
</xsl:when>
<xsl:otherwise>
<xsl:attribute name="type" select="$token/@type"/>
</xsl:otherwise>
</xsl:choose>
<xsl:if test="not(empty($pair))">
<xsl:if test="$pair/@end">
<xsl:attribute name="pair-end" select="$pair/@end"/>
</xsl:if>
<xsl:attribute name="level" select="$pair/@level"/>
</xsl:if>
</xsl:when>
<xsl:when test="$typeExpected">
<xsl:attribute name="type" select="if ($token/@type) then $token/@type else 'type-name'"/>
</xsl:when>
<xsl:when test="$isQuantifier">
<xsl:attribute name="type" select="'quantifier'"/>
</xsl:when>
<xsl:when test="$token/@type">
<xsl:attribute name="type" select="$token/@type"/>
</xsl:when>
</xsl:choose>
</xsl:element>

<xsl:variable name="ignorable" as="xs:boolean"
select="$token/@type = ('whitespace', 'comment')"/>

<xsl:variable name="isNewClosed" as="xs:boolean">
<xsl:choose>
<xsl:when test="$ignorable">
<xsl:value-of select="$prevIsClosed"/>
</xsl:when>
<xsl:when test="$token/@type = 'probableOp'">
<xsl:value-of select="not($prevIsClosed)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="$currentIsClosed"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:variable name="newTypeExpected" as="xs:boolean"
select="if ($ignorable) then $typeExpected
else $token/@type = 'type-op'"/>


<xsl:if test="$index + 1 le count($tokens)">
<xsl:variable name="qExpected" as="xs:boolean"
select="$typeExpected or $token/@value = ')'"/> 


<xsl:sequence select="loc:rationalizeTokens($tokens, $index + 1, $isNewClosed,
$pbPairs, $newTypeExpected, $qExpected)"/>
</xsl:if>

</xsl:function>


<xsl:function name="loc:createTokens">
<xsl:param name="string" as="xs:string"/>
<xsl:param name="excludes" as="element()*"/>
<xsl:param name="start" as="xs:integer"/>
<xsl:param name="index" as="xs:integer"/>

<xsl:variable name="exclude" as="element()?"
select="$excludes[$index]"/>

<xsl:variable name="end" as="xs:integer?"
select="if (empty($exclude)) then ()
else if ($exclude/@end) then 
$exclude/@end cast as xs:integer + 1
else ()"/>

<xsl:variable name="exStart" as="xs:integer?"
select="if (empty($exclude)) then ()
else $exclude/@start"/>

<xsl:variable name="part">
<xsl:choose>
<xsl:when test="empty($exclude) and $index = 1">
<xsl:value-of select="$string"/>
</xsl:when>
<xsl:when test="exists($exStart) and $exStart ge $start">
<xsl:value-of select="substring($string, $start, $exStart - $start)"/>
</xsl:when>
<xsl:otherwise>
<xsl:value-of select="substring($string, $start, string-length($string) + 1 - $start)"/>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:if test="string-length($part) gt 0">
<xsl:variable name="tokens" as="xs:string*"
select="loc:rawTokens($part)"/>

<!-- The XSLT that generates the tokens -->
<xsl:sequence select="loc:processTokens($tokens, $start, 1)"/>
</xsl:if>

<xsl:if test="not(empty($exclude))">
<xsl:element name="token">
<xsl:attribute name="start" select="$exclude/@start"/>
<xsl:if test="$exclude/@end">
<xsl:attribute name="end" select="$exclude/@end"/>
</xsl:if>
<xsl:variable name="stringEnd">
<xsl:value-of select="if ($exclude/@end) then $exclude/@end else string-length($string)"/>
</xsl:variable>
<xsl:attribute name="value">
<xsl:value-of select="substring($string, $exclude/@start, $stringEnd + 1 - $exclude/@start)"/>
</xsl:attribute>
<xsl:attribute name="type" select="name($exclude)"/>
</xsl:element>
</xsl:if>
<!-- iterate 1 pos beyond end of excludes length -->
<xsl:if test="not(empty($excludes)) and not(empty($end)) and $index le count($excludes)">
<xsl:sequence select="loc:createTokens($string, $excludes, $end, $index + 1)"/>
</xsl:if>
</xsl:function>

<xsl:function name="loc:processTokens" as="element()*">
<xsl:param name="tokens" as="xs:string*"/>
<xsl:param name="start" as="xs:integer"/>
<xsl:param name="index" as="xs:integer"/>

<xsl:variable name="token" as="xs:string?"
select="$tokens[$index]"/>
<xsl:variable name="end" as="xs:integer"
select="$start + string-length($token)"/>
<xsl:element name="token">
<xsl:attribute name="start" select="$start"/>
<xsl:attribute name="end" select="$end - 1"/>
<xsl:attribute name="value" select="$token"/>
<xsl:variable name="isSimpleOps" select="$token = $simpleOps" as="xs:boolean"/>
<xsl:if test="$isSimpleOps">
<xsl:attribute name="type" select="if($token = ('/','//')) then 'step' else 'op'"/>
</xsl:if>
<xsl:variable name="isDoubleToken" as="xs:boolean">
<xsl:choose>
<xsl:when test="$isSimpleOps">
<xsl:value-of select="false()"/>
</xsl:when>
<xsl:otherwise>
<xsl:variable name="splitToken" as="xs:string*"
select="tokenize($token, '[\n\p{Zs}]+')"/>
<xsl:value-of
select="if (count($splitToken) ne 2) then false()
else if ($splitToken[1] eq 'instance' and $splitToken[2] eq 'of') 
then true()
else if ($splitToken[1] = ('cast','castable','treat') and $splitToken[2] eq 'as')
then true() else false()"/>

</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:if test="$isDoubleToken">
<xsl:attribute name="type" select="'type-op'"/>
</xsl:if>

<xsl:variable name="functionType" as="xs:string">
<xsl:choose>
<xsl:when test="$isSimpleOps or $isDoubleToken or string-length($token) = 1 or not(ends-with($token,'('))">
<xsl:text></xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:variable name="fnName" as="xs:string" select="tokenize($token, '[\n\p{Zs}]+|\(')[1]"/>
<xsl:choose>
<xsl:when test="$fnName = 'if'">
<xsl:text>if</xsl:text>
</xsl:when>
<xsl:when test="some $n in $nodeTests satisfies $n = $fnName">
<xsl:text>node</xsl:text>
</xsl:when>
<xsl:when test="some $x in $typeTests satisfies $x = $fnName">
<xsl:text>type</xsl:text>
</xsl:when>
<xsl:otherwise>
<xsl:text>function</xsl:text>
</xsl:otherwise>
</xsl:choose>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>
<xsl:choose>
<xsl:when test="$isSimpleOps or $isDoubleToken"></xsl:when>
<xsl:when test="$functionType ne ''">
<xsl:attribute name="type" select="$functionType"/>
</xsl:when>
<xsl:when test="ends-with($token, '::') or $token eq '@'">
<xsl:attribute name="type" select="'axis'"/>
</xsl:when>
<xsl:when test="matches($token,'[\n\p{Zs}]+')">
<xsl:attribute name="type" select="'whitespace'"/>
</xsl:when>
<xsl:when test="$token = ('.','..')">
<xsl:attribute name="type" select="'context'"/>
</xsl:when>
<xsl:when test="$token = ('(',')')">
<xsl:attribute name="type" select="'parenthesis'"/>
</xsl:when>
<xsl:when test="$token = ('[',']')">
<xsl:attribute name="type" select="'filter'"/>
</xsl:when>
<xsl:when test="number($token) = number($token)">
<xsl:attribute name="type" select="'numeric'"/>
</xsl:when>
<xsl:when test="$token = $ambiguousOps">
<xsl:attribute name="type" select="'probableOp'"/>
</xsl:when>
<xsl:when test="$token = $higherOps">
<xsl:if test="starts-with(loc:nextNonWhite($tokens, $index), '$')">
<xsl:attribute name="type" select="'higher'"/>
</xsl:if>
</xsl:when>
<xsl:when test="$token eq 'if'">
<xsl:if test="loc:nextNonWhite($tokens, $index) eq '('">
<xsl:attribute name="type" select="'if'"/>
</xsl:if>
</xsl:when>
<xsl:when test="starts-with($token, '$')">
<xsl:attribute name="type" select="'variable'"/>
</xsl:when>
</xsl:choose>
</xsl:element>

<xsl:if test="$index + 1 le count($tokens)">
<xsl:sequence select="loc:processTokens($tokens, $end, $index + 1)"/>
</xsl:if>
</xsl:function>

<xsl:function name="loc:nextNonWhite" as="xs:string?">
<xsl:param name="tokens" as="xs:string*"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:choose>
<xsl:when test="true()"><!-- test="$index + 2 lt count($tokens)">  --> 
<xsl:value-of select="if(replace($tokens[$index + 1],'[\n\p{Zs}]+','') eq '')
then $tokens[$index + 2] else $tokens[$index + 1]"/>
</xsl:when>
<xsl:otherwise></xsl:otherwise>
</xsl:choose>
</xsl:function>

<xsl:function name="loc:rawTokens" as="xs:string*">
<xsl:param name="chunk" as="xs:string"/>
<xsl:analyze-string
regex="(((-)?\d+)(\.)?(\d+([eE][\+\-]?)?\d*)?)|(\?)|(instance[\n\p{{Zs}}]+of)|(cast[\n\p{{Zs}}]+as)|(castable[\n\p{{Zs}}]+as)|(treat[\n\p{{Zs}}]+as)|((\$[\n\p{{Zs}}]*)?[\i\*][\p{{L}}\p{{Nd}}\.\-]*(:[\p{{L}}\p{{Nd}}\.\-\*]*)?(::)?:?)(\()?|(\.\.)|((-)?\d?\.\d*)|-|([&lt;&gt;!]=)|(&gt;&gt;|&lt;&lt;)|(//)|([\n\p{{Zs}}]+)|(\C)"
select="$chunk">
<xsl:matching-substring>
<xsl:value-of select="string(.)"/>
</xsl:matching-substring>
</xsl:analyze-string>
</xsl:function>


</xsl:stylesheet>
