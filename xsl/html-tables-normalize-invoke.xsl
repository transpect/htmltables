<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:htmltable="http://transpect.io/htmltable"
  exclude-result-prefixes="xs"
  version="2.0">
  
  <!-- This stylesheet is used to simply invoke htmltable:normalize()
       without the additional stuff in html-tables.xsl  -->
  
  <xsl:param name="process-tables-only" as="xs:string" select="'no'"/>
  
  <xsl:import href="html-tables-normalize.xsl"/>
  
  <xsl:template match="*[*:tr]">
    <xsl:sequence select="htmltable:normalize(.)"/>
  </xsl:template>
  
  <xsl:template match="*[not(.//*:tr)][$process-tables-only = 'yes']" mode="#default" priority="-0.25">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="@* | * | processing-instruction()" mode="#default" priority="-0.5">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>