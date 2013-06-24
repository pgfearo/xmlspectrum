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
<xsl:with-param name="mixed-level" as="xs:integer" select="0"/>
<xsl:with-param name="preserved" as="xs:integer" select="0"/>
<xsl:with-param name="nl-attribute" as="xs:boolean" select="false()"/>

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
<xsl:param name="mixed-level" as="xs:integer"/>
<xsl:param name="preserved" as="xs:integer"/>
<xsl:param name="nl-attribute" as="xs:boolean"/>

<xsl:variable name="span" select="$spans[$index]"/>
<xsl:variable name="class" select="$span/@class"/>
<xsl:variable name="nextClass" select="$spans[$index + 1]/@class" as="xs:string?"/>
<xsl:variable name="prevClass" select="$spans[$index - 1]/@class" as="xs:string?"/>

<xsl:variable name="level2" select="if ($class eq 'scx') then $level + 1
else if ($class eq 'ez') then $level - 1
else $level"/>
<xsl:variable name="mixed-level2" select="if ($mixed-level eq 0) then 0
else if ($class eq 'scx') then $mixed-level + 1
else if ($class eq 'ez') then $mixed-level - 1
else $mixed-level"/>

<xsl:variable name="outdent" as="xs:boolean"
select="if ($index lt count($spans)) then
$spans[$index + 1]/@class eq 'ez'
else false()"/>

<xsl:if test="exists($span)">

<xsl:variable name="indentOutput" select="f:indentTextSpan(
$span, $level, $margin, $an-offset, $av-offset, $outdent,
$nextClass, $prevClass, $multi-line, $auto-trim, $mixed-level2, $preserved, $nl-attribute
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
<xsl:with-param name="mixed-level" as="xs:integer" select="xs:integer($indentOutput/mixed-level)"/>
<xsl:with-param name="preserved" as="xs:integer" select="xs:integer($indentOutput/preserved)"/>
<xsl:with-param name="nl-attribute" as="xs:boolean" select="($indentOutput/nl-attribute eq 'yes')"/>

</xsl:call-template>
</xsl:if>

</xsl:if>
</xsl:template>

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

<!-- 
description
    XSLT Template
    Adds ids and hrefs to span elements for global-variables, named-templates and functions

parameters:
    xmlns:          declared prefixes/namespaces on root-element for current document
    globals:        clark-notation names for all globally declared items that may be
                    referenced.
 -->

<xsl:template match="span" mode="markup">
<xsl:param name="xmlns" as="element()" tunnel="yes"/>
<xsl:param name="globals" as="element()" tunnel="yes"/>
<xsl:param name="path-length" as="xs:string" tunnel="yes"/>

<xsl:variable name="ref-name"
select="if (@class eq 'variable') then
substring(., 2)
else ." as="xs:string"/>
<xsl:variable name="clark-name" select="f:clark-name($xmlns, $ref-name)" as="xs:string"/>
<xsl:variable name="id" select="f:gen-id(@class, $clark-name)"/>

<xsl:choose>
<xsl:when test="@class = ('fname', 'tname', 'vname')">
<xsl:copy>
<xsl:copy-of select="@*"/>
<xsl:attribute name="id" select="$id"/>
<xsl:value-of select="$ref-name"/>
</xsl:copy>
</xsl:when>
<xsl:when test="@class = 'enxsl'
and (ends-with(., 'stylesheet')
 or  ends-with(., 'transform')
  )">
<a class="solar" href="{concat($path-length, 'index.html')}">
<xsl:copy>
<xsl:copy-of select="@*"/>
<xsl:attribute name="id" select="$id"/>
<xsl:value-of select="$ref-name"/>
</xsl:copy>
</a>
</xsl:when>
<xsl:when test="@class = ('variable', 'href','tcall','function')">

<xsl:variable name="global-refs" as="element()*"
select="if (@class eq 'variable') then
    $globals/file/variables
else if (@class eq 'tcall') then
    $globals/file/templates
else if (@class eq 'function') then
    $globals/file/functions
else ()"/>
<xsl:variable name="resolved-ref" as="xs:string?"
select="if (exists($global-refs)) then
    ($global-refs/item[string(.) eq $clark-name])[1]/../parent::file/@path
else ()"/>

<xsl:variable name="href" as="xs:string?"
select="if (@class eq 'href') then
    concat(., '.html')
else if (@class eq 'function' and not(contains(., ':'))) then
    concat($w3c-xpath-functions-uri, '#', concat('func-', .))
else if (exists($resolved-ref)) then
    concat(
    $path-length,
    $resolved-ref,
    '.html', '#', $id)
else ()"/>
<xsl:choose>
<xsl:when test="exists($href)">
<a href="{$href}" class="solar">
<xsl:if test="$css-inline ne 'no'">
<xsl:attribute name="style" select="'text-decoration:none'"/>
</xsl:if>
<xsl:copy-of select="."/>
</a>
</xsl:when>
<xsl:otherwise>
<xsl:copy-of select="."/>
</xsl:otherwise>
</xsl:choose>
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
<xsl:param name="mixed-level" as="xs:integer"/>
<xsl:param name="preserved" as="xs:integer"/>
<xsl:param name="nl-attribute" as="xs:boolean"/>

<xsl:variable name="class" select="$span/@class"/>

<xsl:variable name="all-preserved" as="xs:integer"
select="if ($nl-attribute) then
($preserved + $av-offset)
else
($preserved + $an-offset + $av-offset)"/>



<xsl:variable name="is-mixed" as="xs:boolean"
select="$mixed-level gt 0 and not($ignore-mc)
or (
    $class eq 'txt' and $nextClass = ('es','esx') and string-length($span) gt 0
)"/>

<xsl:variable name="new-mixed-level"
select="if ($mixed-level eq 0 and $is-mixed) then
1 else $mixed-level"
as="xs:integer"/>

<xsl:variable name="line-parts" as="element()*">
<xsl:choose>
<xsl:when test="$insert-newlines">
<xsl:choose>
<!-- check to see if newline must be inserted after text content (even if empty) -->
<xsl:when test="$class eq 'z' and $nextClass eq 'atn' 
and ($level eq 0 or $document-type eq 'mergexml' and $level eq 1)">
<tt/><nl/>
</xsl:when>
<xsl:when test="$class eq 'txt'">
<tt>
<xsl:value-of select="$span"/>
</tt>
<!-- must somehow avoid inserting newlines within mixed content
     but string-length($span) eq 0 will not be good test -->
<!-- ez = '</' starg of a close tag: </close> 
        ec = '>' at end of a close tag: </close>
        example <open>this day</open> -->

<xsl:choose>
<!-- if next tag is open tag (es/esx) and it is preceded by text-content
     don't add a new line, eg <p>my name<p> -->
<xsl:when test="$is-mixed">
</xsl:when>
<!-- add new line after text-content if:
     1. next tag is not a close tag
     2. next tag *is* a close tag and prev tag was a close tag also
      -->
<xsl:when test="$nextClass ne 'ez'
or $prevClass eq 'ec'">
<nl/>
</xsl:when>
</xsl:choose>
</xsl:when>
<xsl:otherwise>
<tt>
<xsl:value-of select="$span"/>
</tt>
</xsl:otherwise>
</xsl:choose>

</xsl:when>
<xsl:otherwise>
<xsl:analyze-string select="$span" regex="(\r?)\n.*">
<xsl:matching-substring>
<xsl:variable name="r-length" as="xs:integer" select="string-length(regex-group(1))"/>
<xsl:variable name="text" select="substring(., 2 + $r-length)" as="xs:string"/>
<nl>

<!-- Only trim minimum necessary from attribute values -->
<xsl:value-of select="$text"/>
</nl>
</xsl:matching-substring>
<xsl:non-matching-substring>
<tt>
<xsl:value-of select="."/>
</tt>
</xsl:non-matching-substring>
</xsl:analyze-string>
</xsl:otherwise>
</xsl:choose>
</xsl:variable>

<xsl:variable name="firstLine" as="element()?"
select="$line-parts[1]"/>

<xsl:variable name="nl-elements" as="element()*"
select="$line-parts[name(.) eq 'nl']"/>



<xsl:variable name="indented-lines" as="xs:string*">
<xsl:sequence select="if ($nl-elements and $auto-trim) then
    if ($class = ('whitespace','av')) then
        f:autotrim($nl-elements, 1, $all-preserved)
    else if ($class = ('txt','cd')) then
        f:autotrim-txt($nl-elements, 1, 0)
    else if ($class = ('cm','pi')) then
        f:autotrim-comment($nl-elements, 1, 0)
    else
        for $trim in $nl-elements return f:left-trim($trim)
else
    for $a in $nl-elements return string($a)"/>
</xsl:variable>

<xsl:variable name="trim-width" as="xs:integer?"
select="if ($nl-elements and $auto-trim) then
    string-length($nl-elements[1]) - string-length($indented-lines[1])
else
    ()
    "/>


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
else if ($class = ('whitespace', 'comment'))
    then $an-outOffset + $av-outOffset
else if ($class eq 'av')
    then $an-offset + $av-offset
else 0"/>

<xsl:variable name="indent" select="f:createIndent(($level * $margin) + $offset)"/>
<xsl:variable name="last-level" select="if ($outdent) then $level - 1 else $level" as="xs:integer"/>
<xsl:variable name="last-indent" select="f:createIndent(($last-level * $margin) + $offset)"/>


<xsl:variable name="line-count" select="count($indented-lines)" as="xs:integer"/>
<xsl:variable name="new-preserved" as="xs:integer"
select="if (exists($trim-width)
    and (
        ($class eq 'txt' and $nextClass = ('es','esx'))
        or ($class eq 'z' and $nextClass eq 'atn')
    )
) then
    $trim-width
else $preserved" />

<xsl:variable name="new-nl-attribute" as="xs:boolean"
select="if ($class eq 'txt' and $nextClass = ('es','esx')) then
false()
else if ($class eq 'z' and $nextClass eq 'atn' and $line-count gt 0) then
true()
else
$nl-attribute"/>


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


<!--
<xsl:variable name="span-text" select="if (exists($indented-lines)) then
concat($span-text-1, ' ', $an-outOffset, ' ', $av-outOffset)
else $span-text-1"/>

-->




<output>
<span>
<xsl:copy-of select="$span/@*"/>
<xsl:value-of select="$span-text"/>
</span>
<an-offset>
<xsl:value-of select="$an-outOffset"/>
</an-offset>
<av-offset>
<xsl:value-of select="$av-outOffset"/>
</av-offset>
<multi-line>
<xsl:value-of select="exists($indented-lines)"/>
</multi-line>
<mixed-level>
<xsl:value-of select="$new-mixed-level"/>
</mixed-level>
<preserved>
<xsl:value-of select="$new-preserved"/>
</preserved>
<nl-attribute>
<xsl:value-of select="if ($new-nl-attribute) then
    'yes'
else
    'no'"/>
</nl-attribute>

</output>

</xsl:function>

<xsl:function name="f:autotrim">
<xsl:param name="newline-elements" as="element()*"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:param name="preserve-size" as="xs:integer"/>
<xsl:variable name="text" select="$newline-elements[$index]" as="xs:string*"/>
<xsl:variable name="trimmed-text" select="f:left-trim($text)" as="xs:string"/>
<xsl:variable name="trim-size" as="xs:integer"
select="(string-length($text) - string-length($trimmed-text), 0)[1]"/>

<!--
<xsl:sequence select="concat('[', $preserve-size, ' ', $trim-size, ']')"/>
-->
<xsl:sequence select="if ($trim-size gt $preserve-size) then
    substring($text, $preserve-size + 1)
else
    $trimmed-text
"/>
<xsl:if test="$index lt count($newline-elements)">
<xsl:sequence select="f:autotrim($newline-elements, $index + 1, $preserve-size)"/>
</xsl:if>

</xsl:function>

<xsl:function name="f:autotrim-txt">
<xsl:param name="newline-elements" as="element()*"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:param name="preserve-size" as="xs:integer"/>
<xsl:variable name="text" select="$newline-elements[$index]" as="xs:string*"/>
<xsl:variable name="trimmed-text" select="f:left-trim($text)" as="xs:string"/>
<xsl:variable name="trim-size" as="xs:integer"
select="(string-length($text) - string-length($trimmed-text), 0)[1]"/>

<xsl:variable name="result" select="if ($trim-size gt $preserve-size and $index gt 1) then
substring($text, $preserve-size + 1)
else
$trimmed-text
"/>
<xsl:variable name="count" select="count($newline-elements)" as="xs:integer"/>
<xsl:variable name="new-trim-size" select="if ($index eq 1) then $trim-size else $preserve-size" as="xs:integer"/>
<xsl:choose>
<xsl:when test="$index eq $count">
<xsl:sequence select="f:right-trim($result)"/>
</xsl:when>
<xsl:when test="$index lt $count">
<xsl:sequence select="$result"/>
<xsl:sequence select="f:autotrim-txt($newline-elements, $index + 1, $new-trim-size)"/>
</xsl:when>
</xsl:choose>
</xsl:function>

<xsl:function name="f:autotrim-comment">
<xsl:param name="newline-elements" as="element()*"/>
<xsl:param name="index" as="xs:integer"/>
<xsl:param name="preserve-size" as="xs:integer"/>
<xsl:variable name="text" select="$newline-elements[$index]" as="xs:string*"/>
<xsl:variable name="trimmed-text" select="f:left-trim($text)" as="xs:string"/>
<xsl:variable name="trim-size" as="xs:integer"
select="(string-length($text) - string-length($trimmed-text), 0)[1]"/>

<xsl:variable name="result-a" select="if ($trim-size gt $preserve-size and $index gt 1) then
substring($text, $preserve-size + 1)
else
$trimmed-text
"/>
<xsl:variable name="result" select="concat('     ', $result-a)"/>
<xsl:variable name="count" select="count($newline-elements)" as="xs:integer"/>
<xsl:variable name="new-trim-size" select="if ($index eq 1) then $trim-size else $preserve-size" as="xs:integer"/>
<xsl:choose>

<xsl:when test="$index eq $count">
<xsl:sequence select="f:right-trim($result)"/>
</xsl:when>

<xsl:when test="$index le $count">
<xsl:sequence select="$result"/>
<xsl:sequence select="f:autotrim-comment($newline-elements, $index + 1, $new-trim-size)"/>
</xsl:when>
</xsl:choose>
</xsl:function>

<xsl:function name="f:left-trim" as="xs:string">
<xsl:param name="text"/>
<xsl:value-of select="replace($text, '^\s+', '')"/>
</xsl:function>

<xsl:function name="f:right-trim" as="xs:string">
<xsl:param name="text"/>
<xsl:value-of select="replace($text, '\s+$', '')"/>
</xsl:function>

<xsl:function name="f:createIndent" as="xs:string?">
<xsl:param name="padCount" as="xs:integer"/>
<xsl:if test="$padCount ge 0">
<xsl:sequence select="string-join(for $i in 1 to $padCount 
return ' ','')"/>
</xsl:if>
</xsl:function>

</xsl:stylesheet>
