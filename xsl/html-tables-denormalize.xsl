<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xml2idml="http://transpect.io/xml2idml"
  xmlns:tr="http://transpect.io" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:html="http://www.w3.org/1999/xhtml"
  xmlns:htmltable="http://transpect.io/htmltable"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  >
  
  <xsl:param name="retain" as="xs:string?">
    <!-- retain="data-colnum data-rownum" in order to retain the attributes with these names -->
  </xsl:param>
  
  <xsl:param name="retain-parts" as="xs:string?">
    <!-- retain-parts="data-colspan-part data-rowspan-part" in order to retain the synthetic cells.
         Use retain-parts="data-rowspan-part" in order to keep the generated cells for rowspan > 1. -->
  </xsl:param>
  
  <xsl:variable name="retain-att-names" as="xs:string*" select="tokenize($retain, '\s+')"/>
  
  <xsl:variable name="retain-parts-tokens" as="xs:string*" select="tokenize($retain-parts, '\s+')"/>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[local-name() = ('td', 'th')][@*[name() = ('data-colspan-part', 'data-rowspan-part')]
                                                        [not(name() = $retain-parts-tokens)] > 1]"/>
  
  <xsl:template match="*[local-name() = ('td', 'th')]/@rowspan[empty(../@data-rowspan-part)][$retain-parts-tokens = 'data-rowspan-part']">
    <xsl:copy/>
    <xsl:attribute name="data-rowspan-part" select="'1'"/>
  </xsl:template>
  
  <xsl:template match="*[local-name() = ('td', 'th')]/@colspan[empty(../@data-colspan-part)][$retain-parts-tokens = 'data-colspan-part']">
    <xsl:copy/>
    <xsl:attribute name="data-colspan-part" select="'1'"/>
  </xsl:template>
  
  <xsl:template match="@*[name() = ('data-colspan-part', 'data-rownum-part', 'data-colnum', 'data-rownum')]
                         [not(name() = ($retain-att-names, $retain-parts-tokens))]"/>
  
</xsl:stylesheet>
