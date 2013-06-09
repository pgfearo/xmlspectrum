<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" xmlns:f="urn:internal-function">
    
    <xsl:output indent="yes"/>


    <xsl:template name="main" match="/">
<!--        <xsl:variable name="doc-text" as="xs:string" select="unparsed-text(resolve-uri('../samples/devtest.xql'))"/>-->
        <xsl:variable name="doc-text" as="xs:string" select="unparsed-text('file:///c:/test/XQDocComments.xq')"/>
        <xsl:variable name="text-points" as="xs:integer*" select="string-to-codepoints($doc-text)"/> 
        <result>
            <xsl:variable name="blocks" as="element()*">
                 <xsl:sequence select="f:createXqBlocks($text-points)"/>
            </xsl:variable>
            <xsl:sequence select="$blocks"/>
<!--          <xsl:for-each select="$blocks">
              <xsl:if test="@start">
                <text>
                    <xsl:value-of select="substring($doc-text, xs:integer(@start), xs:integer(@end))"/>
                </text>
              </xsl:if>
            </xsl:for-each>-->
        </result>
    </xsl:template>

    <xsl:variable name="cQuote" select="34" as="xs:integer"/>
    <xsl:variable name="cApos" select="39" as="xs:integer"/>
    <xsl:variable name="cColon" select="58" as="xs:integer"/>
    <xsl:variable name="cParenStart" select="91" as="xs:integer"/>
    <xsl:variable name="cParenEnd" select="93" as="xs:integer"/>
    <xsl:variable name="cBracketStart" select="40" as="xs:integer"/>
    <xsl:variable name="cBracketEnd" select="41" as="xs:integer"/>
    <xsl:variable name="cCloseComment" as="xs:integer*" select="$cColon, $cBracketEnd"/>
    <xsl:variable name="cTagStart" select="60" as="xs:integer"/>
    <xsl:variable name="cTagEnd" select="62" as="xs:integer"/>
    <xsl:variable name="cWhitespace" select="13, 32" as="xs:integer*"/>
    <xsl:variable name="cFnStart" as="xs:integer" select="123"/>
    <xsl:variable name="cFnEnd" as="xs:integer" select="125"/>
    
    <xsl:variable name="xExclam" as="xs:integer" select="33"/>
    <xsl:variable name="xPI" as="xs:integer" select="63"/>
    <xsl:variable name="xSlash" as="xs:integer" select="47"/>
    <xsl:variable name="xHyphen" as="xs:integer" select="45"/>
    <xsl:variable name="xEquals" as="xs:integer" select="61"/>
    <!-- unused codepoints when waiting for / or > chars -->
    <xsl:variable name="xxTagEnd" as="xs:integer" select="7"/>
    <xsl:variable name="xxCloseTagEnd" as="xs:integer" select="8"/>

    <xsl:function name="f:createXqBlocks" as="element()*">
        <xsl:param name="chars" as="xs:integer*"/>
        <xsl:sequence select="f:createXqBlocks($chars, false(), 1, (), 1, 0, 0, 0, 0)"/>
    </xsl:function>

    <xsl:function name="f:createXmlBlocks" as="element()*">
        <xsl:param name="chars" as="xs:integer*"/>
        <xsl:param name="index" as="xs:integer"/>
        <xsl:param name="awaiting" as="xs:integer*"/>
        <xsl:param name="start" as="xs:integer"/>
        <xsl:param name="level" as="xs:integer"/>
        <xsl:param name="xq-fnlevel" as="xs:integer"/>
        
        <xsl:variable name="char" as="xs:integer" select="$chars[$index]"/>
        <xsl:variable name="n1Char" as="xs:integer?" select="$chars[$index + 1]"/>
        <xsl:variable name="n2Char" as="xs:integer?" select="$chars[$index + 2]"/>
        
        <xsl:variable name="limit" as="xs:integer" select="count($awaiting) - 1"/>
        <xsl:variable name="compChars" as="xs:integer*" 
                      select="for $i in 0 to $limit return $chars[$index + $i]"/>
        
        <xsl:variable name="isLiteralStart" as="xs:boolean"
                      select="$awaiting = $xxTagEnd and $char = ($cApos, $cQuote)"/>
        
        <xsl:variable name="isLiteralEnd" as="xs:boolean"
              select="$awaiting = ($cApos, $cQuote) and $char = $awaiting"/>
        
        <xsl:variable name="awaiting-tag" as="item()*">
            <xsl:choose>
                <xsl:when test="empty($awaiting)">
                    <xsl:sequence select="f:getAwaitingFrom2ndChar($char, $n1Char)"/>
                </xsl:when>
                <xsl:when test="$awaiting = $cTagStart and $awaiting = $char">
                     <xsl:sequence select="f:getAwaitingFrom2ndChar($n1Char, $n2Char)"/>                   
                </xsl:when>               
            </xsl:choose>
        </xsl:variable>
        
        <xsl:choose>
            <xsl:when test="$limit gt 0 and deep-equal($compChars, $awaiting)">
                <x-tag-end pos="{$index}" length="{$limit + 1}"/>
            </xsl:when>
            <xsl:when test="$awaiting = $xxTagEnd and $char eq $cTagEnd">
                 <x-tag-end pos="{$index}" length="1"/>               
            </xsl:when>
            <xsl:when test="$awaiting = $xxCloseTagEnd and $char eq $cTagEnd">
                  <x-tag-end pos="{$index}" length="1"/>                
            </xsl:when>
            <xsl:when test="$awaiting = $xxTagEnd and $char eq $xEquals">
                  <x-equals pos="{$index}"/>                
            </xsl:when>
<!--            <xsl:otherwise>
                <otherwise pos="{$index}" char="{codepoints-to-string($char)}" awaiting="{$awaiting}"/>
            </xsl:otherwise>-->
        </xsl:choose>
        
        
                 <!-- a close tag </close> -->   
        <xsl:variable name="isCloseTag" as="xs:boolean"
            select="$awaiting = $cTagStart and $char eq $cTagStart and $n1Char eq $xSlash"/>
        
        
        <!-- last 2 items in sequence are reserved for tag markup -->
        <xsl:variable name="count-awaiting" as="xs:integer" select="count($awaiting-tag) - 2"/>
        
        <xsl:variable name="nowAwaiting" as="xs:integer*">
            <xsl:choose>
                <xsl:when test="$isCloseTag">
                     <xsl:sequence select="$xxCloseTagEnd"/>                      
                </xsl:when>
                <xsl:when test="exists($awaiting-tag)">
                    <xsl:sequence select="subsequence($awaiting-tag, 1, $count-awaiting)"/>
                </xsl:when>
                <xsl:when test="$awaiting = $xxCloseTagEnd and $char eq $cTagEnd">
                     <xsl:sequence select="$cTagStart"/>                   
                </xsl:when>
                <xsl:when test="$awaiting = $xxTagEnd and $char = ($xSlash, $cTagEnd)">
                    <xsl:sequence select="$cTagStart"/>
                </xsl:when>
                <xsl:when test="$isLiteralStart">
                    <xsl:sequence select="$char"/>
                </xsl:when>
                <xsl:when test="$isLiteralEnd">
                    <xsl:sequence select="$xxTagEnd"/>
                </xsl:when>
                <xsl:when test="deep-equal($compChars, $awaiting)">
                    <!-- must always be waiting for something in XML, so assume tag start -->
                    <xsl:sequence select="$cTagStart"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$awaiting"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <!-- probably an open tag <open> - but may be empty eg. <empty/> -->
        <xsl:variable name="isOpenTag" as="xs:boolean"
            select="(empty($awaiting) and $char gt 64) or ($awaiting = $cTagStart and $char eq $cTagStart and $n1Char gt 64)"/>

        <!-- required to correct an empty tag falsely assumed to be an open tag <empty/> -->          
        <xsl:variable name="isEmptyTag" as="xs:boolean"
            select="$awaiting = $xxTagEnd and $char eq $xSlash and $n1Char eq $cTagEnd"/>       
                
        <xsl:variable name="isEmbeddedXQuery" as="xs:boolean"
            select="$char eq $cFnStart and $awaiting = ($cApos, $cQuote, $cTagStart)"/>
        
        <xsl:variable name="newLevel" as="xs:integer"
            select="if ($isOpenTag) then $level + 1
                    else if ($isCloseTag or $isEmptyTag) then $level - 1
                    else $level"/>
        
<!--       <xsl:variable name="test-string" select="codepoints-to-string(subsequence($chars, $index + 1, 10))"/>-->
        
        <xsl:choose>
            <xsl:when test="$isOpenTag">
                <xml-open-tag pos="{$index}"/>                    
            </xsl:when>
            <xsl:when test="$isEmptyTag">
                <x-tag-end pos="{$index}" length="2"/>
            </xsl:when>
            <xsl:when test="$isCloseTag">
                <xml-close-tag pos="{$index}"/>
            </xsl:when>
            <xsl:when test="$isLiteralStart">
                 <xml-literal-start pos="{$index}"/>               
            </xsl:when>
            <xsl:when test="$isLiteralEnd">
                 <xml-literal-end pos="{$index}"/>               
            </xsl:when>
            <xsl:when test="exists($awaiting-tag)">
                <xml-tag pos="{$index}" type="{$awaiting-tag[last() - 1]}" length="{$awaiting-tag[last()]}"/>
            </xsl:when>
        </xsl:choose>        
               
        <xsl:choose>
            <xsl:when test="$index eq count($chars) or $index gt 3000">
                <terminate-xml/>
            </xsl:when>
            <xsl:when test="$level eq 0 and $char eq $cTagEnd">
                <start-xquery pos="{$index + 1}" level="top"/>      
                <xsl:sequence select="f:createXqBlocks($chars, false(), $index + 1, (), 0, 0, $xq-fnlevel, $newLevel, $nowAwaiting)"/>                 
            </xsl:when>
            <xsl:when test="$awaiting = ($cTagStart, $cApos, $cQuote) and $char eq $cFnStart">
                <start-xquery pos="{$index + 1}" level="nested"/>
                <xsl:sequence select="f:createXqBlocks($chars, false(), $index + 1, (), 0, 0, $xq-fnlevel, $newLevel, $nowAwaiting)"/>               
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="f:createXmlBlocks($chars, $index + 1, $nowAwaiting, $start, $newLevel, $xq-fnlevel)"/>                
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>

    <xsl:function name="f:createXqBlocks" as="element()*">
        <xsl:param name="chars" as="xs:integer*"/>
        <xsl:param name="skip" as="xs:boolean"/>
        <xsl:param name="index" as="xs:integer"/>
        <xsl:param name="awaiting" as="xs:integer*"/>
        <xsl:param name="start" as="xs:integer"/>
        <xsl:param name="level" as="xs:integer"/>
        <xsl:param name="fnLevel" as="xs:integer"/>
        <!-- xml nesting level -->
        <xsl:param name="xLevel" as="xs:integer"/>
        <!-- whether in attribute ' or " or element: < -->
        <xsl:param name="xAwaiting" as="xs:integer"/>

        <xsl:variable name="charCount" select="count($chars)"/>

        <xsl:variable name="char" as="xs:integer" select="$chars[$index]"/>
        <xsl:variable name="nChar" as="xs:integer?" select="$chars[$index + 1]"/>
        <xsl:variable name="pChar" as="xs:integer?" select="$chars[$index - 1]"/>

        <xsl:variable name="newLevel" as="xs:integer">
            <xsl:choose>
                <xsl:when test="$awaiting = ($cColon, $cBracketEnd)">
                    <xsl:value-of select="if($char eq $cBracketStart and $nChar eq $cColon) then $level + 1
                                          else if ($char eq $cBracketEnd and $pChar = $cColon and $level gt 0) then $level -1
                                          else $level"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$level"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="nowAwaiting" as="xs:integer*">
            <xsl:choose>
                <xsl:when test="empty($awaiting)">
                    <xsl:sequence
                        select="if($char = ($cQuote, $cApos))
                                          then $char 
                                          else if ($char = $cBracketStart and $nChar = $cColon) then ($cColon, $cBracketEnd) 
                                          else ()"/>
                </xsl:when>
                <xsl:when test="deep-equal($char, $awaiting)">
                    <xsl:sequence select="()"/>
                </xsl:when>
                <xsl:when test="$awaiting = ($cColon, $cBracketEnd) and $char = $cBracketEnd and $pChar = $cColon and $level = 0">
                    <xsl:sequence select="()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$awaiting"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:variable name="nowSkip" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="$skip">
                    <xsl:value-of select="false()"/>
                </xsl:when>
                <xsl:when test="$char = ($cApos, $cQuote) and $char = $awaiting and $nChar = $char">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

<!--        <xsl:if test="empty($awaiting) and empty($nowAwaiting)">
            <xsl:if test="$char = ($cParenStart,$cParenEnd,$cBracketStart,$cBracketEnd)">
                <block position="{$index}" type="{codepoints-to-string($char)}"/>
            </xsl:if>
        </xsl:if>-->

        <xsl:variable name="isFound" as="xs:boolean" select="not(deep-equal($awaiting,$nowAwaiting)) and not($skip or $nowSkip)"/>
        <xsl:variable name="newStart" as="xs:integer" select="if ($isFound) then $index else $start"/>

        <xsl:if test="exists($awaiting) and $isFound">
            <xsl:element name="{if (deep-equal($awaiting, ($cColon, $cBracketEnd))) then 'comment' else 'literal'}">
                <xsl:if test="not($awaiting = ($cColon, $cBracketEnd))">
                    <xsl:attribute name="type" select="$char"/>
                </xsl:if>
                <xsl:attribute name="start" select="$start"/>
                <xsl:attribute name="end" select="$index"/>
            </xsl:element>
        </xsl:if>
        
        <xsl:variable name="newFnLevel" as="xs:integer">
            <xsl:choose>
                <xsl:when test="empty($awaiting)">
                    <xsl:value-of select="if($char eq $cFnStart) then $fnLevel + 1
                                          else if ($char eq $cFnEnd) then $fnLevel -1
                                          else $fnLevel"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$fnLevel"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        
        <xsl:variable name="xqueryEnds" as="xs:boolean" select="$newFnLevel lt 0"/>
        <xsl:variable name="xmlStarts" as="xs:boolean" select="empty($awaiting) and f:tagStart($char, $nChar)"/>
        
<!--        <xsl:variable name="test-string" select="codepoints-to-string(subsequence($chars, $index + 1, 10))"/>-->
        
        <xsl:choose>
            <xsl:when test="$index eq $charCount">
                <xsl:if test="exists($awaiting) and not($isFound)">
                    <xsl:element name="{if ($awaiting = ($cColon, $cBracketEnd)) then 'comment' else 'literal'}">
                        <xsl:if test="not($awaiting = ($cColon, $cBracketEnd))">
                            <xsl:attribute name="type" select="$awaiting"/>
                        </xsl:if>
                        <xsl:attribute name="start" select="$start"/>
                    </xsl:element>
                </xsl:if>
                <terminate-xquery>
<!--                    <xsl:value-of select="$test-string"/>-->
                </terminate-xquery>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$xqueryEnds">
                        <stop-xquery pos="{$index - 1}"/>
                        <xsl:sequence select="f:createXmlBlocks($chars, $index + 1, $xAwaiting, $index, $xLevel, 0)"/>                       
                    </xsl:when>
                    <xsl:when test="$xmlStarts">
                        <stop-xquery pos="{$index - 1}"/>
                        <xsl:sequence select="f:createXmlBlocks($chars, $index + 1, (), $index, $xLevel, $fnLevel)"/>                       
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="f:createXqBlocks($chars, $nowSkip, $index + 1, $nowAwaiting, $newStart, $newLevel, $newFnLevel, $xLevel, $xAwaiting)"/>                           
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:function>
    
    <!-- suffixed with label and length of start char sequence eg. tags: <![CDATA[ , <!$$, <?,  -->
    <xsl:function name="f:getAwaitingFrom2ndChar" as="item()+">
        <xsl:param name="char" as="xs:integer"/>
        <xsl:param name="char2" as="xs:integer?"/>
            <xsl:sequence select="if ($char eq $xExclam) then
                                       if ($char2 eq $cParenStart) then
                                            ($cParenEnd, $cParenEnd, $cTagEnd, 'x-cdata', 9)
                                       else if ($char2 eq $xHyphen) then
                                            ($xHyphen, $xHyphen, $cTagEnd, 'x-comment', 3)
                                       else
                                            ($cParenEnd, $cTagEnd, 'x-dtd', 2) (: not supported in XQuery anyway :)
                                  else if ($char eq $xPI) then
                                       ($xPI, $cTagEnd, 'x-pi', 2)
                                  else
                                        ($xxTagEnd, 'x-tag', 1)"/>
    </xsl:function>
    
    <xsl:function name="f:tagStart" as="xs:boolean">
        <xsl:param as="xs:integer" name="char1"/>
        <xsl:param as="xs:integer" name="char2"/>
        
        <xsl:sequence select="$char1 eq $cTagStart and ($char2 gt 64 or $char2 eq 33 or $char2 eq 63) 
            and not($char2 = (91,92,93,94,96,123,124,125,126,127))"/>
    </xsl:function>
</xsl:stylesheet>
