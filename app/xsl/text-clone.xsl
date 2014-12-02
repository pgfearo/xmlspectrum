<?xml version="1.0" encoding="utf-8"?>

<xsl:stylesheet version="2.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:output method="text"/>

<xsl:template match="node()">
    <xsl:copy>
        <xsl:apply-templates/>
    </xsl:copy>    
</xsl:template>

</xsl:stylesheet>
