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
  
  <xsl:variable name="retain-att-names" as="xs:string*" select="tokenize($retain, '\s+')"/>
  
  <xsl:template match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*[local-name() = ('td', 'th')][@*[name() = ('data-colspan-part', 'data-rowspan-part')] > 1]"/>
  
  <xsl:template match="@*[name() = ('data-colspan-part', 'data-rownum-part', 'data-colnum', 'data-rownum')]
                         [not(name() = $retain-att-names)]"/>
  
</xsl:stylesheet>
