<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="2.0" 
                xmlns:xqf="urn:xq.internal-function"
                xmlns:f="internal"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                 exclude-result-prefixes="f xqf"
                 xpath-default-namespace="http://www.w3.org/1999/xhtml">

<xsl:import href="xmlspectrum.xsl"/>
<xsl:import href="xq-spectrum.xsl"/>
<xsl:output method="xhtml" indent="no"/>
<xsl:variable name="color-theme" select="'github-blue'"/>
<xsl:variable name="span-namespace-uri" select="'http://www.w3.org/1999/xhtml'"/>

<xsl:template match="/">
 <xsl:apply-templates select="*" mode="high"/>   
</xsl:template>
  
<xsl:template match="@*" mode="high">
  <xsl:copy/>
</xsl:template>
  
<xsl:template match="html|head|title|meta|style" mode="high">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()" mode="high"/>    
  </xsl:copy>
</xsl:template>
  
<xsl:template match="body" mode="high">
  <h1><a name="title" id="title"></a>XQuery 3.0: An XML Query
Language</h1>
<h2>Extracted code samples with syntax-highlighting added by XMLSpectrum.</h2>
<h3><a name="w3c-doctype" id="w3c-doctype"></a>W3C Candidate
Recommendation 08 January 2013</h3>
  <p>Reproduced from the W3C documentation at: <a href="http://www.w3.org/TR/2013/CR-xquery-30-20130108/">http://www.w3.org/TR/2013/CR-xquery-30-20130108/</a>. <em>See copyright notice on page footer.</em></p>
  <p>Syntax-highlighting was done using the standard XSLT 2.0 stylesheets from the <a href="https://github.com/pgfearo/xmlspectrum">XMLSpectrum</a> open source project. The XSLT processor was Saxon-HE from Saxonica Ltd.</p>
  <ol>
   <xsl:copy>
    <xsl:apply-templates select=".//div[@class eq 'exampleInner'][pre]" mode="high"/>    
  </xsl:copy>   
  </ol>  
<h1>&#160;</h1>
  <hr/>
    
<div class='div2'><a name='Copyright-notice-document'></a>
<hr width='50' align='center' title='Area separator'/>
<h2 id='Copyright-notice-document-h2' class='div2'>W3C<sup>&#xae;</sup> Document Copyright Notice and License</h2>
<p><b>Note:</b> 
	This section is a copy of the W3C<sup>&#xae;</sup> Document
	Notice and License and could be found at <a class='normative' href='http://www.w3.org/Consortium/Legal/2002/copyright-documents-20021231'>http://www.w3.org/Consortium/Legal/2002/copyright-documents-20021231</a>.
      </p>
<p><b>
      Copyright &#xa9; 2004 <a class='normative' href='http://www.w3.org/'>World Wide Web Consortium</a>, (<a class='normative' href='http://www.lcs.mit.edu/'>Massachusetts Institute of
      Technology</a>, <a class='normative' href='http://www.ercim.org/'>European
      Research Consortium for Informatics and Mathematics</a>, <a class='normative' href='http://www.keio.ac.jp/'>Keio University</a>). All Rights
      Reserved.
    </b></p><p><b>      
      http://www.w3.org/Consortium/Legal/2002/copyright-documents-20021231
    </b></p><p>
      Public documents on the W3C site are provided by the copyright
      holders under the following license. By using and/or copying this
      document, or the W3C document from which this statement is linked,
      you (the licensee) agree that you have read, understood, and will
      comply with the following terms and conditions:</p>
    <p>
      Permission to copy, and distribute the contents of this document,
      or the W3C document from which this statement is linked, in any
      medium for any purpose and without fee or royalty is hereby
      granted, provided that you include the following on
      <em>ALL</em> copies of the document, or portions thereof, that
      you use:</p>
    <ol>
<li>

	  A link or URL to the original W3C document.
	</li>
<li>

	  The pre-existing copyright notice of the original author, or
	  if it doesn't exist, a notice (hypertext is preferred, but a
	  textual representation is permitted) of the form:
	  "Copyright &#xa9; [$date-of-document] <a class='normative' href='http://www.w3.org/'>World Wide Web Consortium</a>,
	  (<a class='normative' href='http://www.lcs.mit.edu/'>Massachusetts Institute
	  of Technology</a>, <a class='normative' href='http://www.ercim.org/'>European Research Consortium for
	  Informatics and Mathematics</a>, <a class='normative' href='http://www.keio.ac.jp/'>Keio University</a>). All
	  Rights Reserved.  <a class='normative' href='http://www.w3.org/Consortium/Legal/2002/copyright-documents-20021231'>http://www.w3.org/Consortium/Legal/2002/copyright-documents-20021231</a>"
	</li>
<li>

	  <em>If it exists</em>, the STATUS of the W3C document.
	</li>
</ol>
<p>
      When space permits, inclusion of the full text of this <b>NOTICE</b> should be provided. We request that
      authorship attribution be provided in any software, documents, or other
      items or products that you create pursuant to the implementation of the
      contents of this document, or any portion thereof.</p>
    <p>
      No right to create modifications or derivatives of W3C documents is
      granted pursuant to this license. However, if additional requirements
      (documented in the <a class='normative' href='http://www.w3.org/Consortium/Legal/IPR-FAQ'>Copyright
      FAQ</a>) are satisfied, the right to create modifications or
      derivatives is sometimes granted by the W3C to individuals complying with
      those requirements.</p>
    <p>
      THIS DOCUMENT IS PROVIDED "AS IS," AND COPYRIGHT HOLDERS MAKE
      NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED, INCLUDING, BUT NOT
      LIMITED TO, WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
      PURPOSE, NON-INFRINGEMENT, OR TITLE; THAT THE CONTENTS OF THE DOCUMENT
      ARE SUITABLE FOR ANY PURPOSE; NOR THAT THE IMPLEMENTATION OF SUCH
      CONTENTS WILL NOT INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS,
      TRADEMARKS OR OTHER RIGHTS.</p>
    <p>
      COPYRIGHT HOLDERS WILL NOT BE LIABLE FOR ANY DIRECT, INDIRECT, SPECIAL OR
      CONSEQUENTIAL DAMAGES ARISING OUT OF ANY USE OF THE DOCUMENT OR THE
      PERFORMANCE OR IMPLEMENTATION OF THE CONTENTS THEREOF.</p>
    <p>
      The name and trademarks of copyright holders may NOT be used in
      advertising or publicity pertaining to this document or its contents
      without specific, written prior permission. Title to copyright in this
      document will at all times remain with copyright holders.</p>
    </div> <!-- div2 Copyright-notice-document -->
</xsl:template>
  
<xsl:template match="div" mode="high">
<li>
  <p><xsl:value-of select="preceding-sibling::*[1]"/></p>
  <xsl:copy>
    <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="pre" mode="high"/>
  </xsl:copy>  
</li>
</xsl:template>
  
<xsl:template match="pre" mode="high">
  <xsl:copy>
    <xsl:copy-of select="@*"/>
    <xsl:variable name="text" select="." as="xs:string"/>
    <xsl:variable name="first-char" select="substring($text, 1,1)"/>
    <xsl:variable name="trim-text" select="if ($first-char eq '&#10;') then substring($text, 2) else $text"/>
    <xsl:variable name="xptokens" as="element()*" select="xqf:show-xquery($trim-text)"/>
    <xsl:sequence select="f:style-spans($xptokens)"/>
  </xsl:copy>
</xsl:template>

</xsl:stylesheet>
