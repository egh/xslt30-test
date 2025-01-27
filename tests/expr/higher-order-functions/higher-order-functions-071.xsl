<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  version="3.0" exclude-result-prefixes="xs map">

  <xsl:template name="process-map" as="map(*)">
    <xsl:param name="map" as="map(*)"/>
    <xsl:param name="operator" as="xs:string"/>
    <xsl:param name="operand" as="xs:anyAtomicType"/>
    <xsl:sequence
      select="map:merge(
                map:for-each($map, function($k, $v) {
                  map { $k : if ($operator eq '+') then $v + $operand
                             else if ($operator eq '-') then $v - $operand
                             else if ($operator eq '*') then $v * $operand
                             else if ($operator eq '/') then $v div $operand
                             else $v }
                  }))"
    />
  </xsl:template>

  <xsl:template name="xsl:initial-template">
    <xsl:variable name="result" as="map(*)">
      <xsl:call-template name="process-map">
        <xsl:with-param name="map" as="map(*)">
          <xsl:map>
            <xsl:map-entry key="'a'" select="22"/>
            <xsl:map-entry key="'b'" select="23"/>
            <xsl:map-entry key="'c'" select="24"/>
            <xsl:map-entry key="'d'" select="25"/>
            <xsl:map-entry key="'e'" select="26"/>
            <xsl:map-entry key="'f'" select="27"/>
          </xsl:map>
        </xsl:with-param>
        <xsl:with-param name="operator" select="'*'"/>
        <xsl:with-param name="operand" select="2"/>
      </xsl:call-template>
    </xsl:variable>
    <out><xsl:value-of select="serialize($result, map{'method':'json'})"/></out>
  </xsl:template>



</xsl:stylesheet>
