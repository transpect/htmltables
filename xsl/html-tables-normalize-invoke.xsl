<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:htmltable="http://transpect.io/htmltable"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- This stylesheet is used to simply invoke htmltable:normalize()
       without the additional stuff in html-tables.xsl  -->
  
  <xsl:import href="html-tables-normalize.xsl"/>
  
  <xsl:template match="*|@*|processing-instruction()" 
                mode="htmltable:tables-add-atts htmltable:tables-add-atts-denormalize htmltable:tables-add-atts-scale">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[*:tr]">
    <xsl:sequence select="htmltable:normalize(.)"/>
  </xsl:template>
  
</xsl:stylesheet>