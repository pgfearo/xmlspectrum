<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:loc="com.qutoric.sketchpath.functions"
exclude-result-prefixes="loc f xs"
xpath-default-namespace="http://www.w3.org/1999/xhtml"
xmlns="http://www.w3.org/1999/xhtml"
xmlns:f="internal">

<!-- Creates a table of contents derived from globals result-tree -->


<xsl:template name="create-toc">
<xsl:param name="globals" as="element()" tunnel="yes"/>
<xsl:param name="path"/>
<xsl:param name="css-link"/>
<xsl:param name="output-method"/>
<xsl:param name="is-css-inline" as="xs:boolean"/>

<xsl:result-document href="{concat($path, 'index.html')}" method="{$output-method}" indent="no">

<xsl:if test="$output-method eq 'html'">
<xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html></xsl:text>
</xsl:if>

<html>
<head>
<title><xsl:value-of select="'Summary View'"/></title>
<link rel="stylesheet" type="text/css" href="{$css-link}"/>
</head>
<body>
<div class="spectrum-toc">
<xsl:if test="$is-css-inline">
<xsl:attribute name="style" select="f:inline-css-toc()"/>
</xsl:if>

<p class="av">
<span class="z">(HTML code rendering by XMLSpectrum)</span>
</p>
<h3>
<span class="av">Global XSLT Module Members</span>
</h3>
<p class="av">
<xsl:variable name="epath" select="($globals/file)[1]/@path"/>
<a class="solar" href="{concat($epath,'.html')}" style="text-decoration:none">
<span class="av">Entry file: <xsl:value-of select="$epath"/></span>
</a>
</p>

<ul class="spectrum-toc">
<xsl:apply-templates select="$globals/file" mode="toc"/>
</ul>
</div>
</body>
</html>
</xsl:result-document>

</xsl:template>

<xsl:template match="file" mode="toc">

<li>
<a class="solar" href="{concat(@path,'.html')}" style="text-decoration:none">
<span class="blue">File: <xsl:value-of select="@path"/>
</span>
</a>
</li>
<ul class="spectrum-toc">
<xsl:if test="exists(templates/item)">
<li>
<span class="en">Templates</span>
<ul>
<xsl:apply-templates select="templates/item" mode="toc">
<xsl:sort select="f:resolve-clark-name(.)"/>
<xsl:with-param name="path" select="@path"/>
</xsl:apply-templates>
</ul>
</li>
</xsl:if>
<xsl:if test="exists(functions/item)">
<li>
<span class="fname">Functions</span>
<ul>
<xsl:apply-templates select="functions/item" mode="toc">
<xsl:sort select="f:resolve-clark-name(.)"/>
<xsl:with-param name="path" select="@path"/>
</xsl:apply-templates>
</ul>
</li>
</xsl:if>
<xsl:if test="exists(variables/item)">
<li>
<span class="vname">Variables</span>
<ul>
<xsl:apply-templates select="variables/item" mode="toc">
<xsl:sort select="f:resolve-clark-name(.)"/>
<xsl:with-param name="path" select="@path"/>
</xsl:apply-templates>
</ul>
</li>
</xsl:if>
<xsl:if test="exists(params/item)">
<li>
<span class="vname">Parameters</span>
<ul>
<xsl:apply-templates select="params/item" mode="toc">
<xsl:sort select="f:resolve-clark-name(.)"/>
<xsl:with-param name="path" select="@path"/>
</xsl:apply-templates>
</ul>
</li>
</xsl:if>

<xsl:if test="not(exists(*/item))">
<li><span>[None]</span></li>
</xsl:if>
</ul>

</xsl:template>

<xsl:template match="item" mode="toc">
<xsl:param name="path"/>

<xsl:variable name="char" select="substring(local-name(..),1, 1)"/>
<xsl:variable name="name" select="f:resolve-clark-name(.)"/>
<li>
<a class="solar" href="{concat($path, '.html', '#',$char,'?', string(.))}" style="text-decoration:none">
<span class="atn"><xsl:value-of select="$name"/></span>
</a>
</li>
</xsl:template>

<xsl:function name="f:resolve-clark-name" as="xs:string">
<xsl:param name="text"/>
<xsl:variable name="ns" select="substring(substring-before($text, '}'), 2)"/>
<xsl:value-of select="if ($ns eq '') then
  string($text)  
else
    substring-after($text, '}')
"/>

</xsl:function>

</xsl:stylesheet>

