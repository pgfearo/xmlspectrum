<?xml version="1.0" encoding="UTF-8"?>
<!-- 
     Syntax-highlighted transform of xproccorb.xpl
     on GitHub https://github.com/philipfennell/xproc-libraries.git
-->
<p:declare-step 
xmlns:c="http://www.w3.org/ns/xproc-step"
xmlns:cx="http://xmlcalabash.com/ns/extensions"
xmlns:file="http://www.marklogic.com/xproc/file/"
xmlns:ml="http://xmlcalabash.com/ns/extensions/marklogic"
xmlns:p="http://www.w3.org/ns/xproc"
xmlns:xpc="http://www.marklogic.com/xproccorb/"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
xml:base="../"
exclude-inline-prefixes="xsi"
name="xproccorb"
version="1.0">

<p:input port="source"/>
<p:output port="result"/>

<p:serialization port="result" encoding="UTF-8" indent="true" media-type="application/xml" method="xml"/>

<p:import href="pipelines/library-1.0.xpl"/>



<p:declare-step type="xpc:load-query">
<p:documentation>Retrieves an XQuery referenced in the config file.</p:documentation>
<p:input port="source"/>
<p:output port="result"/>
<p:option name="query" required="true"/>

<p:variable name="user" select="/ml:config/ml:user/text()"/>
<p:variable name="password" select="/ml:config/ml:password/text()"/>
<p:variable name="host" select="/ml:config/ml:host/text()"/>
<p:variable name="port" select="/ml:config/ml:port/text()"/>
<p:variable name="content-database" select="/ml:config/ml:content-database/text()"/>

<p:group>
<p:documentation>Build the request.</p:documentation>
<p:wrap-sequence wrapper="c:request"/>
<p:add-attribute match="/c:request" attribute-name="method" attribute-value="'get'"/>
<p:add-attribute match="/c:request" attribute-name="override-content-type" attribute-value="text/plain"/>
<p:add-attribute match="/c:request" attribute-name="href">
<p:with-option name="attribute-value"
select="/c:request/ml:config/node()
[local-name() = concat($query, '-query')]/@href"/>
</p:add-attribute>
<p:make-absolute-uris match="/c:request/@href"/>
<p:string-replace match="/c:request/@href" replace="replace(., 'file:', 'file://')">
<p:documentation>Fixes the URI so that it can be used by the http-request step.</p:documentation>
</p:string-replace>
<p:add-attribute match="/c:request" attribute-name="detailed" attribute-value="true"/>
<p:delete match="/c:request/ml:config"/>
</p:group>

<p:http-request indent="false" method="text" encoding="utf-8" media-type="text/plain"/>

<p:group>
<p:documentation>Add config properties to the retrieved query's wrapper element.</p:documentation>
<p:add-attribute match="/c:body" attribute-name="user">
<p:with-option name="attribute-value" select="$user"/>
</p:add-attribute>
<p:add-attribute match="/c:body" attribute-name="password">
<p:with-option name="attribute-value" select="$password"/>
</p:add-attribute>
<p:add-attribute match="/c:body" attribute-name="host">
<p:with-option name="attribute-value" select="$host"/>
</p:add-attribute>
<p:add-attribute match="/c:body" attribute-name="port">
<p:with-option name="attribute-value" select="$port"/>
</p:add-attribute>
<p:add-attribute match="/c:body" attribute-name="content-database">
<p:with-option name="attribute-value" select="$content-database"/>
</p:add-attribute>
</p:group>
</p:declare-step>

<p:declare-step type="xpc:get-content-uris">
<p:documentation>
Executes the source XQuery against the specified
database which returns a list of document URIs.
</p:documentation>
<p:input port="source"/>
<p:output port="result" sequence="true"/>

<ml:adhoc-query name="fetch-uris" wrapper="c:uri">
<p:input port="source"/>
<p:input port="parameters">
<p:empty/>
</p:input>
<p:with-option name="user" select="/c:body/@user"/>
<p:with-option name="password" select="/c:body/@password"/>
<p:with-option name="host" select="/c:body/@host"/>
<p:with-option name="port" select="/c:body/@port"/>
<p:with-option name="content-base" select="/c:body/@content-database"/>
</ml:adhoc-query>
</p:declare-step>




<p:group>
<p:documentation>
Main pipeline that loads queries, executes them against the chosen content
in the named database and returns the results of those queries/transforms.
</p:documentation>

<xpc:load-query name="uri-query" query="uri"/>

<xpc:get-content-uris name="content-uris"/>

<p:sink>
<p:documentation>Provides a binding for the result port of 'content-uris'.</p:documentation>
</p:sink>

<xpc:load-query name="transform-query" query="transform">
<p:input port="source">
<p:pipe port="source" step="xproccorb"/>
</p:input>
</xpc:load-query>

<p:for-each name="transform-documents">
<p:iteration-source select="/c:uri">
<p:pipe port="result" step="content-uris"/>
</p:iteration-source>

<ml:adhoc-query wrapper="c:result">
<p:input port="source">
<p:pipe port="result" step="transform-query"/>
</p:input>
<p:input port="parameters">
<p:empty/>
</p:input>
<p:with-param name="URI" select="/c:uri/text()"/>
<p:with-option name="user" select="/c:body/@user">
<p:pipe port="result" step="transform-query"/>
</p:with-option>
<p:with-option name="password" select="/c:body/@password">
<p:pipe port="result" step="transform-query"/>
</p:with-option>
<p:with-option name="host" select="/c:body/@host">
<p:pipe port="result" step="transform-query"/>
</p:with-option>
<p:with-option name="port" select="/c:body/@port">
<p:pipe port="result" step="transform-query"/>
</p:with-option>
<p:with-option name="content-base" select="/c:body/@content-database">
<p:pipe port="result" step="transform-query"/>
</p:with-option>
</ml:adhoc-query>
</p:for-each>

<p:wrap-sequence wrapper="c:results"/>
</p:group>
</p:declare-step>
