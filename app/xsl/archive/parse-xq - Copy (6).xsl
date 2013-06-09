<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" version="2.0" xmlns:f="urn:internal-function">
    
    <xsl:output indent="yes"/>
    
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
    <xsl:variable name="xxInitTagEnd" as="xs:integer" select="6"/>
    <xsl:variable name="xxTagEnd" as="xs:integer" select="7"/>
    <xsl:variable name="xxAnyTagEnd" as="xs:integer*" select="6, 7"/>
    <xsl:variable name="xxCloseTagEnd" as="xs:integer" select="8"/>

    <xsl:template name="main" match="/">
        <xsl:variable name="doc-text" as="xs:string" select="unparsed-text(resolve-uri('../samples/devtest.xql'))"/>
<!--        <xsl:variable name="doc-text" as="xs:string" select="unparsed-text('file:///c:/test/XQueryML30.xq')"/>-->
        <xsl:variable name="text-points" as="xs:integer*" select="string-to-codepoints($doc-text)"/> 
        <result>
            <xsl:variable name="blocks" as="element()*">
                 <xsl:sequence select="f:createXqBlocks($text-points)"/>
            </xsl:variable>
            <xsl:sequence select="$blocks"/>
            <tokens>
                <xsl:sequence select="f:tokeniseBlocks($doc-text, $blocks)"/>
            </tokens>
        </result>
    </xsl:template>
    
   <xsl:function name="f:tokeniseBlocks">
        <xsl:param name="doc-text" as="xs:string"/>
        <xsl:param name="blocks" as="element()*"/>
        <xsl:sequence select="f:tokeniseBlocks($doc-text, $blocks, 1, 1, '', ())"/>
   </xsl:function>
    
    <xsl:function name="f:tokeniseBlocks">
        <xsl:param name="doc-text" as="xs:string"/>
        <xsl:param name="blocks" as="element()*"/>
        <xsl:param name="index" as="xs:integer"/>
        <xsl:param name="start" as="xs:integer"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:param name="result" as="element()*"/>
        
        <xsl:variable name="block" select="$blocks[$index]" as="element()"/>
        <xsl:variable name="nextBlock" select="$blocks[$index + 1]" as="element()?"/>
        
        <xsl:variable name="name" as="xs:string" select="name($block)"/>
        <xsl:variable name="start" as="xs:integer?" 
            select="if ($block/@start) then $block/@start
                    else if ($block/@pos) then $block/@pos
                    else ()"/>
        <xsl:variable name="nextStart" as="xs:integer?" 
            select="if ($nextBlock/@start) then $nextBlock/@start
                    else if ($nextBlock/@pos) then $nextBlock/@pos
                    else ()"/>
        <xsl:variable name="length" as="xs:double?" 
            select="if ($block/@end) then ($block/@end - $start) + 1
                    else if ($block/@length) then $block/@length
                    else if ($nextStart) then $nextStart - $start
                    else ()"/>
        <xsl:variable name="newType" as="xs:string?" 
            select="if ($name eq 'x-tag-end') then 
                    'x-text'
                    else if (exists($block/@type)) then 
                    $block/@type 
                    else $type"/>
        

        
        <xsl:variable name="count" as="xs:integer" select="count($blocks)"/>
        
        <xsl:variable name="newStart" as="xs:integer" select="$start"/>     
        
        <xsl:variable name="result1" as="element()*">

            <xsl:sequence select="$result"/>
            <xsl:choose>
                <xsl:when test="exists($start) and exists($length)">
                    <xsl:variable name="isClose" select="$name eq 'xml-close-tag'"/>
                    <xsl:variable name="isOpen" select="$name eq 'xml-open-tag'"/>
                    <xsl:variable name="offset" as="xs:integer"
                        select="if ($isClose) then 2 else if ($isOpen) then 1 else 0"/>
                    <xsl:if test="$isClose">
                        <span pos="{$start}" class="sc">&lt;/</span>
                    </xsl:if>
                    <xsl:if test="$isOpen">
                        <span pos="{$start}" class="es">&lt;</span>
                    </xsl:if>
                    <xsl:variable name="shiftStart" as="xs:integer" select="$start + $offset"/>
                    <xsl:variable name="text" select="substring($doc-text, $shiftStart, $length - $offset)"/>
                    <xsl:choose>
                        <xsl:when test="$name eq 'start-xquery'">
                            <xquery pos="{$shiftStart}">
                                <xsl:sequence select="f:handleXquery($text)"/>
                            </xquery>
                        </xsl:when>
                        <xsl:when test="$name = ('literal','comment')">
                            <xsl:element name="{$name}">
                                <xsl:attribute name="pos" select="$shiftStart"></xsl:attribute>
                                <xsl:sequence select="$text"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                             <span name="{$name}" pos="{$shiftStart}"
                                   nameclass="{if ($name = ('x-tag-end','xml-tag')) 
                                        then 'z' else f:getClassFromName($name)}">                                      
                                <xsl:sequence select="$text"/>
                            </span>                           
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="$name = ('comment', 'literal')">
                    <xsl:variable name="newStart" select="$start + $length"/>
                    <xsl:if test="$newStart ne $nextStart">
                         <xquery start="{$newStart}">
                            <xsl:sequence select="f:handleXquery(substring($doc-text, $newStart, $nextStart - $newStart))"/>
                        </xquery>                   
                    </xsl:if>
                </xsl:when>
                <xsl:when test="$name = ('x-tag-end', 'xml-tag')">
                    <xsl:variable name="newStart" select="$start + $length"/>
                    <xsl:if test="$newStart ne $nextStart">
                         <span pos="{$newStart}" 
                                    class="{if ($name eq 'xml-tag') then f:getClassFromType($newType) else 'txt'}">
                            <xsl:value-of select="substring($doc-text, $newStart, $nextStart - $newStart)"/>
                        </span>                   
                    </xsl:if>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        

        <xsl:choose>
            <xsl:when test="$index eq $count">
                <xsl:sequence select="$result1"></xsl:sequence>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="f:tokeniseBlocks($doc-text, $blocks, $index + 1, $newStart, $newType, $result1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:handleXquery" as="element()*">
        <xsl:param name="text"></xsl:param>
        <handled>
            <xsl:sequence select="$text"/>
        </handled>
    </xsl:function>

    <xsl:function name="f:createXqBlocks" as="element()*">
        <xsl:param name="chars" as="xs:integer*"/>
        <xsl:sequence select="f:createXqBlocks($chars, false(), 1, (), 1, 0, 0, 0, 0, ())"/>
    </xsl:function>
    
    <xsl:variable name="class-in" as="xs:string*"
        select="('x-comment','x-cdata','x-pi','x-dtd')"/>
    
    <xsl:variable name="class-out" as="xs:string*"
        select="('cm','cd','pi','dt')"/>
    
     <xsl:variable name="name-in" as="xs:string*"
        select="('nested-query','unnested-xquery', 'xml-open-tag','xml-name-end', 'x-equals',
            'xml-att-quote', 'xml-literal-start', 'xml-literal-end', 'resume-x-literal')"/>
    
    <xsl:variable name="name-out" as="xs:string*"
        select="('op','op', 'en', 'atn', 'atneq',
            'z', 'av', 'atn', 'av' )"/>
    
    <xsl:function name="f:getClassFromType">
        <xsl:param name="type"/>
        <xsl:variable name="index" as="xs:integer?"
            select="index-of($class-in, $type)"/>
        <xsl:sequence select="if (exists($index)) then $class-out[$index] else $type"/>
    </xsl:function>
    
    <xsl:function name="f:getClassFromName">
        <xsl:param name="type"/>
        <xsl:variable name="index" as="xs:integer?"
            select="index-of($name-in, $type)"/>
        <xsl:sequence select="if (exists($index)) then $name-out[$index] else $type"/>
    </xsl:function>

    <xsl:function name="f:createXmlBlocks" as="element()*">
        <xsl:param name="chars" as="xs:integer*"/>
        <xsl:param name="index" as="xs:integer"/>
        <xsl:param name="awaiting" as="xs:integer*"/>
        <xsl:param name="start" as="xs:integer"/>
        <xsl:param name="level" as="xs:integer"/>
        <xsl:param name="xq-fnlevel" as="xs:integer"/>
        <xsl:param name="result" as="element()*"/>        
        
        <xsl:variable name="char" as="xs:integer" select="$chars[$index]"/>
        <xsl:variable name="n1Char" as="xs:integer?" select="$chars[$index + 1]"/>
        <xsl:variable name="n2Char" as="xs:integer?" select="$chars[$index + 2]"/>
        
        <xsl:variable name="limit" as="xs:integer" select="count($awaiting) - 1"/>
        <xsl:variable name="compChars" as="xs:integer*" 
                      select="for $i in 0 to $limit return $chars[$index + $i]"/>
        
        <xsl:variable name="isLiteralStart" as="xs:boolean"
                      select="$awaiting = $xxAnyTagEnd and $char = ($cApos, $cQuote)"/>
        
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
        
        <xsl:variable name="result1" as="element()?">
            <xsl:choose>
                <xsl:when test="$limit gt 0 and deep-equal($compChars, $awaiting)">
                    <x-tag-end pos="{$index}" length="{$limit + 1}"/>
                </xsl:when>
                <xsl:when test="$awaiting = $xxAnyTagEnd and $char eq $cTagEnd">
                     <x-tag-end pos="{$index}" length="1"/>               
                </xsl:when>
                <xsl:when test="$awaiting = $xxCloseTagEnd and $char eq $cTagEnd">
                      <x-tag-end pos="{$index}" length="1"/>                
                </xsl:when>
                <xsl:when test="$awaiting = $xxAnyTagEnd and $char eq $xEquals">
                      <x-equals pos="{$index}"/>                
                </xsl:when>
    <!--            <xsl:otherwise>
                    <otherwise pos="{$index}" char="{codepoints-to-string($char)}" awaiting="{$awaiting}"/>
                </xsl:otherwise>-->
            </xsl:choose>
        </xsl:variable>
        
                 <!-- a close tag </close> -->   
        <xsl:variable name="isCloseTag" as="xs:boolean"
            select="$awaiting = $cTagStart and $char eq $cTagStart and $n1Char eq $xSlash"/>
        
                <!-- probably an open tag <open> - but may be empty eg. <empty/> -->
        <xsl:variable name="isOpenTag" as="xs:boolean"
            select="(empty($awaiting) and $char gt 64) or ($awaiting = $cTagStart and $char eq $cTagStart and $n1Char gt 64)"/>
        
        <xsl:variable name="isTagNameEnd" as="xs:boolean"
            select="$awaiting = $xxInitTagEnd and $char = $cWhitespace"/>        
        
        <!-- last 2 items in sequence are reserved for tag markup -->
        <xsl:variable name="count-awaiting" as="xs:integer" select="count($awaiting-tag) - 2"/>
        
        <xsl:variable name="nowAwaiting" as="xs:integer*">
            <xsl:choose>
                <xsl:when test="$isOpenTag">
                      <xsl:sequence select="$xxInitTagEnd"/>                   
                </xsl:when>
                <xsl:when test="$isTagNameEnd">
                      <xsl:sequence select="$xxTagEnd"/>                   
                </xsl:when>
                <xsl:when test="$isCloseTag">
                     <xsl:sequence select="$xxCloseTagEnd"/>                      
                </xsl:when>
                <xsl:when test="exists($awaiting-tag)">
                    <xsl:sequence select="subsequence($awaiting-tag, 1, $count-awaiting)"/>
                </xsl:when>
                <xsl:when test="$awaiting = $xxCloseTagEnd and $char eq $cTagEnd">
                     <xsl:sequence select="$cTagStart"/>                   
                </xsl:when>
                <xsl:when test="$awaiting = $xxAnyTagEnd and $char = ($xSlash, $cTagEnd)">
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
       

        <!-- required to correct an empty tag falsely assumed to be an open tag <empty/> -->          
        <xsl:variable name="isEmptyTag" as="xs:boolean"
            select="$awaiting = $xxAnyTagEnd and $char eq $xSlash and $n1Char eq $cTagEnd"/>       
                
        <xsl:variable name="isEmbeddedXQuery" as="xs:boolean"
            select="$char eq $cFnStart and $awaiting = ($cApos, $cQuote, $cTagStart)"/>
        
        <xsl:variable name="newLevel" as="xs:integer"
            select="if ($isOpenTag) then $level + 1
                    else if ($isCloseTag or $isEmptyTag) then $level - 1
                    else $level"/>
        
<!--       <xsl:variable name="test-string" select="codepoints-to-string(subsequence($chars, $index + 1, 10))"/>-->
        
        <xsl:variable name="result2" as="element()*">
            <xsl:choose>
                <xsl:when test="$isTagNameEnd">
                    <xml-name-end pos="{$index}"/>
                </xsl:when>
                <xsl:when test="$isOpenTag">
                    <xml-open-tag pos="{if ($char eq $cTagStart) then $index else $index - 1}"/>                    
                </xsl:when>
                <xsl:when test="$isEmptyTag">
                    <x-tag-end pos="{$index}" length="2"/>
                </xsl:when>
                <xsl:when test="$isCloseTag">
                    <xml-close-tag pos="{$index}"/>
                </xsl:when>
                <xsl:when test="$isLiteralStart">
                     <xml-att-quote pos="{$index}"/>
                     <xsl:if test="not($n1Char = ($nowAwaiting, $cFnStart))">
                        <xml-literal-start pos="{$index + 1}"/>                            
                     </xsl:if>            
                </xsl:when>
                <xsl:when test="$isLiteralEnd">
                     <xml-att-quote pos="{$index}"/>
                     <xsl:if test="not($n1Char = ($xSlash, $cTagEnd))">
                        <xml-literal-end pos="{$index + 1}"/>                         
                     </xsl:if>               
                </xsl:when>
                <xsl:when test="exists($awaiting-tag)">
                    <xml-tag pos="{$index}" type="{$awaiting-tag[last() - 1]}" length="{$awaiting-tag[last()]}"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        
        <xsl:variable name="final-result" as="element()*" select="($result, $result1, $result2)"></xsl:variable>
               
        <xsl:choose>
            <xsl:when test="$index eq count($chars)">
                 <terminate-xml/>                   
                 <xsl:sequence select="$final-result"/>
            </xsl:when>
            <xsl:when test="$level eq 0 and $char eq $cTagEnd">
                <xsl:variable name="end" as="element()">
                 <start-xquery pos="{$index + 1}" level="top"/>                     
                </xsl:variable>  
                <xsl:sequence select="f:createXqBlocks($chars, false(), $index + 1, (), 0, 0, $xq-fnlevel, $newLevel, $nowAwaiting, ($final-result, $end))"/>                 
            </xsl:when>
            <xsl:when test="$awaiting = ($cTagStart, $cApos, $cQuote) and $char eq $cFnStart">
                <xsl:variable name="end" as="element()+">
                <nested-query pos="{$index}"/>
                <start-xquery pos="{$index + 1}" level="nested"/>
                </xsl:variable>  
                <xsl:sequence select="f:createXqBlocks($chars, false(), $index + 1, (), 0, 0, $xq-fnlevel, $newLevel, $nowAwaiting, ($final-result, $end))"/>               
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="f:createXmlBlocks($chars, $index + 1, $nowAwaiting, $start, $newLevel, $xq-fnlevel, $final-result)"/>                
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
        <xsl:param name="result" as="element()*"/>

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

        <xsl:variable name="result1" as="element()?">
            <xsl:if test="exists($awaiting) and $isFound">
                <xsl:element name="{if (deep-equal($awaiting, ($cColon, $cBracketEnd))) then 'comment' else 'literal'}">
                    <xsl:if test="not($awaiting = ($cColon, $cBracketEnd))">
                        <xsl:attribute name="type" select="$char"/>
                    </xsl:if>
                    <xsl:attribute name="start" select="$start"/>
                    <xsl:attribute name="end" select="$index"/>
                </xsl:element>
            </xsl:if>            
        </xsl:variable>

        
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
        
        <xsl:variable name="final-result" as="element()*" select="$result, $result1"/>
        
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
                <xsl:variable name="end" as="element()">
                    <terminate-xquery/>
                </xsl:variable>
                <xsl:sequence select="$final-result, $end"></xsl:sequence>

            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="$xqueryEnds">
                        <xsl:variable name="end" as="element()+">
                            <unnested-xquery pos="{$index}"/>
                            <xsl:if test="$nChar ne $xAwaiting">
                                <resume-x-literal pos="{$index + 1}"/>                                
                            </xsl:if>                           
                        </xsl:variable>
                        <xsl:sequence select="f:createXmlBlocks($chars, $index + 1, $xAwaiting, $index, $xLevel, 0, ($final-result, $end))"/>                       
                    </xsl:when>
                    <xsl:when test="$xmlStarts">
                        <xsl:variable name="end" as="element()">
                            <xml-constructor pos="{$index}"/>
                        </xsl:variable>
                        <xsl:sequence select="f:createXmlBlocks($chars, $index + 1, (), $index, $xLevel, $fnLevel, ($final-result, ()))"/>                       
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:sequence select="f:createXqBlocks($chars, $nowSkip, $index + 1, $nowAwaiting, $newStart, $newLevel, $newFnLevel, $xLevel, $xAwaiting, $final-result)"/>                           
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
                                            ($xHyphen, $xHyphen, $cTagEnd, 'x-comment', 4)
                                       else
                                            ($cParenEnd, $cTagEnd, 'x-dtd', 2) (: not supported in XQuery anyway :)
                                  else if ($char eq $xPI) then
                                       ($xPI, $cTagEnd, 'x-pi', 2)
                                  else
                                        ($xxInitTagEnd, 'x-tag', 1)"/>
    </xsl:function>
    
    <xsl:function name="f:tagStart" as="xs:boolean">
        <xsl:param as="xs:integer" name="char1"/>
        <xsl:param as="xs:integer" name="char2"/>
        
        <xsl:sequence select="$char1 eq $cTagStart and ($char2 gt 64 or $char2 eq 33 or $char2 eq 63) 
            and not($char2 = (91,92,93,94,96,123,124,125,126,127))"/>
    </xsl:function>
</xsl:stylesheet>
