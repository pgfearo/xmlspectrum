<?xml version="1.0" encoding="UTF-8"?>
<!-- 
    xproc file for running XMLSpectrum XSLT transform
    this file offers no real benefits to using the command-line
    or a batch file or shell script, however it
    does add the capability to use within another XProc pipeline

    no CSS file is generated using this method, because the output-method
    param is set to 'xml' - this prevents non-XML issues in XProc steps
-->
                
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc" xmlns:cx="http://xmlcalabash.com/ns/extensions"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:c="http://www.w3.org/ns/xproc-step"
    name="xmlspecturm-xsl" version="1.0">

    <p:input port="my-source" primary="true" sequence="false"/>

    <p:output port="result" sequence="true">
        <!-- there's no primary output, only secondary result-document output -->
        <p:empty/>
    </p:output>

    <!--
<p:serialization port="store-result" encoding="UTF-8" indent="false" method="xml"/>
-->

    <p:xslt name="step1" template-name="main" version="2">

        <p:input port="stylesheet">
            <p:document href="../xsl/highlight-file.xsl"/>
        </p:input>
        <p:with-param name="color-theme" select="'dark'"/>
        <p:with-param name="css-inline" select="'yes'"/>
        <p:with-param name="sourcepath" select="'../samples/xpathcolorer-x.xsl'"/>
        <!-- output must be XML for an XProc step -->
        <p:with-param name="output-method" select="'xml'"/>

    </p:xslt>
    <!-- result-document output from xslt is returned on the secondary output port -->
    <p:sink/>
    <p:for-each name="step2">
        <p:iteration-source>
            <p:pipe step="step1" port="secondary"/>
        </p:iteration-source>
        <!-- can't use method='HTML' in p:store but can add DOCTYPE -->
        <p:store name="step3" encoding="utf-8" indent="false" omit-xml-declaration="true"
            method="xml" doctype-system="about:legacy-compat">

            <!-- xslt adds an xml extension, so replace this with html -->
            <p:with-option name="href" select="concat(p:base-uri(), '.html')"/>
        </p:store>
    </p:for-each>
</p:declare-step>
