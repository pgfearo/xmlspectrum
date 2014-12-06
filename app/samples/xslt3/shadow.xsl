          <xsl:param name="filter" static="yes"
                     as="xs:string" select="'true()'"/>
          <xsl:include _href="common{$VERSION}.xsl"/>
          <xsl:function name="local:filter" as="xs:boolean">
            <xsl:param name="e" as="element(employee)"/>
            <xsl:sequence _select="$e/({$filter})"/>
          </xsl:function>
          <xsl:template match="/">
            <report>
              <xsl:apply-templates mode="report" select="//employee[local:filter(.)]"/>
            </report>
          </xsl:template>