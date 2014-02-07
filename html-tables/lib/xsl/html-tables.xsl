<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  version="2.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:htmltable="http://www.le-tex.de/namespace/htmltable"
  xmlns:letex="http://www.le-tex.de/namespace"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:saxon="http://saxon.sf.net/"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  >


  <xsl:import href="html-tables-normalize.xsl"/>

  <xsl:output method="xhtml"/>

  <xsl:template match="* | @* | processing-instruction()"
    mode="htmltable:tables-add-atts htmltable:tables-add-atts-denormalize htmltable:tables-add-atts-scale">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="/">
    <xsl:apply-templates select="/*" mode="htmltable:tables-add-atts"/>
  </xsl:template>

  <xsl:template match="*[not(*:colgroup and @data-colcount and @data-rowcount)]
                        [*:tr]" mode="htmltable:tables-add-atts">
    <xsl:param name="grid" as="xs:string*" tunnel="yes" />
    <xsl:param name="scaling" as="xs:double?" tunnel="yes" />
    <xsl:variable name="normalized" as="document-node(element(*))">
      <xsl:document>
        <xsl:sequence select="htmltable:normalize(.)" />
      </xsl:document>
    </xsl:variable>
    <xsl:variable name="denormalized" as="element(*)+"><!-- element(*:tr)+ -->
      <xsl:apply-templates select="$normalized/*/*" mode="htmltable:tables-add-atts-denormalize" />
    </xsl:variable>
    <!-- grid-scaling is a factor that all table cell widths will be multiplied with -->
    <xsl:variable name="grid-scaling" as="xs:double?">
      <xsl:if test="($denormalized/self::*:tr)[1]/@data-twips-width">
        <xsl:variable name="width" select="($denormalized/self::*:tr)[1]/@data-twips-width * ($scaling, 1.0)[1]" as="xs:double" />
        <xsl:variable name="twips-grid" as="xs:double*" 
          select="for $g in $grid return letex:length-to-unitless-twip($g)" />
        <xsl:variable name="distances" as="xs:double*" 
          select="for $g in $twips-grid return abs($g - $width)" />
        <xsl:variable name="closest" as="xs:double" 
          select="($twips-grid[abs(. - $width) &lt;= min($distances)][1], $width)[1]" />
        <xsl:sequence select="$scaling * ($closest div $width)" />
      </xsl:if>
    </xsl:variable>
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:attribute name="data-colcount" select="count($normalized/*/*:tr[1]/*)" />
      <xsl:attribute name="data-rowcount" select="count($normalized/*/*:tr)" />
      <xsl:if test="$grid-scaling">
        <xsl:attribute name="css:width" select="concat($grid-scaling * number(($denormalized/self::*:tr)[1]/@data-twips-width) * 0.05, 'pt')" />
      </xsl:if>
      <xsl:apply-templates select="$denormalized" mode="htmltable:tables-add-atts-scale">
        <xsl:with-param name="grid-scaling" select="$grid-scaling" tunnel="yes" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*:td | *:th" mode="htmltable:tables-add-atts-denormalize">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@data-twips-width" mode="htmltable:tables-add-atts-scale">
    <xsl:param name="grid-scaling" as="xs:double?" tunnel="yes" />
    <xsl:attribute name="css:width" select="concat(($grid-scaling, 1.0)[1] * number(.) * 0.05, 'pt')" />
  </xsl:template>

  <xsl:template match="*:tr/@data-twips-width" mode="htmltable:tables-add-atts-scale" />

  <xsl:template match="*:td[@data-colspan-part &gt; 1] | *:th[@data-colspan-part &gt; 1]" mode="htmltable:tables-add-atts-denormalize" />

  <xsl:template match="*:td[@data-rowspan-part &gt; 1] | *:th[@data-rowspan-part &gt; 1]" mode="htmltable:tables-add-atts-denormalize" priority="2"/>

  <xsl:template match="@rowspan[. = '1'] | @colspan[. = '1']" mode="htmltable:tables-add-atts-denormalize"/>

  <xsl:template match="@data-rowspan-part | @data-colspan-part" mode="htmltable:tables-add-atts-denormalize" />

</xsl:stylesheet>
