<?xml version="1.0"?> 
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="3.0"
  xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs">

  <!-- PURPOSE test xsl:evaluate with schema-aware="yes" -->

  <xsl:import-schema>
    <xs:schema>
      <xs:simpleType name="calendar">
        <xs:union memberTypes="xs:date xs:time xs:dateTime"/>
      </xs:simpleType>
    </xs:schema>
  </xsl:import-schema>
  
  <xsl:template name="main">
    <out>
      <xsl:variable name="xpath">current-date() instance of calendar</xsl:variable>
      <xsl:try>
        <xsl:evaluate schema-aware="no" xpath="$xpath"/>
        <xsl:catch select="false()"/>
      </xsl:try>  
    </out>
  </xsl:template>

</xsl:stylesheet>
