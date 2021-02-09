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

  <xsl:import href="http://transpect.io/xslt-util/lengths/xsl/lengths.xsl" />


  <!-- Taken from http://andrewjwelch.com/code/xslt/table/table-normalization.html 
       and stuffed into a function. Should work for both namespaced and sans-namespace HTML.
       Usage example:
       <xsl:template match="*[*:tr]">
         <xsl:sequence select="htmltable:normalize(.)" />
       </xsl:template>
       -->

  <!-- Width calculation only works for tables with absolute values for @css:width on the cells
       (like they are imported from Word). Sorry no relative widths, no even distribution of 
       column widths etc. at the moment. -->
  <xsl:function name="htmltable:normalize" as="element()+">
    <xsl:param name="tgroup" as="element()" />
    <xsl:param name="colgroup" as="element()?" />
    
    <xsl:variable name="table_with_no_colspans" as="element()" >
      <xsl:apply-templates select="$tgroup" mode="htmltable:normalize-colspans" />
    </xsl:variable>
    <xsl:variable name="table_with_no_rowspans">
      <xsl:apply-templates select="$table_with_no_colspans" mode="htmltable:normalize-rowspans">
        <xsl:with-param name="colgroup" select="$colgroup" as="element()?" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:apply-templates select="$table_with_no_rowspans" mode="htmltable:normalize-final" >
      <xsl:with-param name="colgroup" as="element()?" select="$colgroup" tunnel="yes"/>
    </xsl:apply-templates>
  </xsl:function>

  <xsl:function name="htmltable:normalize" as="element()+">
    <xsl:param name="tgroup" as="element()" />
    
    <xsl:variable name="table_with_no_colspans" as="element()" >
      <xsl:apply-templates select="$tgroup" mode="htmltable:normalize-colspans" />
    </xsl:variable>
    <xsl:variable name="table_with_no_rowspans">
      <xsl:apply-templates select="$table_with_no_colspans" mode="htmltable:normalize-rowspans"/>
    </xsl:variable>

    <xsl:apply-templates select="$table_with_no_rowspans" mode="htmltable:normalize-final" />
  </xsl:function>
  
  <xsl:template match="*:tbody | *:thead | *:tfoot | *:table[*:tr]" mode="htmltable:normalize-rowspans">
    <xsl:copy>
      <xsl:copy-of select="@*" />
      <xsl:apply-templates select="* except *:tr" mode="#current" />
      <xsl:for-each select="*:tr[1]">
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="#current" />
          <xsl:variable name="data-twips-width" select="sum(
                                                          for $w in *[not(@data-colspan-part &gt; 1)]/@data-twips-width 
                                                          return (
                                                            if ($w castable as xs:double)
                                                            then xs:double($w) 
                                                            else ()
                                                          ) 
                                                        )" as="xs:double?"/>
          <xsl:if test="$data-twips-width">
            <xsl:attribute name="data-twips-width" select="$data-twips-width" />
          </xsl:if>
          <xsl:apply-templates select="*" mode="#current">
            <xsl:with-param name="rownum" select="1" />
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:for-each>
      <xsl:apply-templates select="*:tr[2]" mode="htmltable:normalize-rowspans">
        <xsl:with-param name="previousRow" select="*:tr[1]" />
        <xsl:with-param name="rownum" select="2" />
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>


  <xsl:template match="*:td | *:th" mode="htmltable:normalize-colspans">
    <xsl:variable name="this" select="." as="element()" />
    <xsl:for-each select="1 to (if (@colspan) then @colspan else 1)">
      <xsl:variable name="count" select="." as="xs:integer" />
      <xsl:for-each select="$this"><!-- this akward for-each is needed in order for the template to stay namespace-agnostic -->
        <xsl:copy>
          <xsl:apply-templates select="@*" mode="#current" />
          <xsl:if test="$this/@colspan &gt; 1">
            <xsl:attribute name="data-colspan-part" select="$count" />
          </xsl:if>
          <xsl:if test="$count eq 1">
            <xsl:apply-templates select="@*:width" mode="#current" />
          </xsl:if>
          <xsl:copy-of select="$this/node()" />
        </xsl:copy>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="@css:width" mode="htmltable:normalize-colspans">
    <xsl:attribute name="data-twips-width" select="tr:length-to-unitless-twip(.)" />
  </xsl:template>

  <xsl:template match="*[*:tr[*/@data-twips-width]]" mode="htmltable:normalize-final">
    <xsl:param name="colgroup" as="element()?" tunnel="yes"/>
    <!-- this only worked if no colspans are in first row -->
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current" />
      <xsl:element name="colgroup" namespace="{namespace-uri(.)}">
        <xsl:variable name="context" select="." as="element(*)" />
        <xsl:choose>
          <xsl:when test="$colgroup[self::*:colgroup]">
            <xsl:for-each select="1 to count($colgroup/*:col)">
              <xsl:element name="col" namespace="{namespace-uri($context)}">
                <xsl:attribute name="data-twips-width" select="tr:length-to-unitless-twip($colgroup/*:col[position() eq current()]/@width)" />
              </xsl:element>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="1 to count(*:tr[1]/*)">
              <xsl:element name="col" namespace="{namespace-uri($context)}">
                <xsl:copy-of select="($context/*:tr/*[position() eq current()]
                                                     [not(@colspan &gt; 1)]
                                                     [not(@data-colspan-part &gt; 1)]
                                     )[1]/@data-twips-width" />
              </xsl:element>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:apply-templates mode="#current" />
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="@data-rownum" mode="htmltable:normalize-final">
    <xsl:copy-of select="." />
    <xsl:attribute name="data-colnum" select="htmltable:index-of(../../*, ..)" />
  </xsl:template>


  <xsl:template match="*:tr" mode="htmltable:normalize-rowspans">
    <xsl:param name="previousRow" as="element()?" />
    <xsl:param name="rownum" as="xs:integer?" />
    <xsl:if test="count($previousRow) eq 0">
      <xsl:message>html-tables-normalize.xsl, mode htmltable:normalize-rowspans, matching *:tr: previousRow is unexpectedly empty. Is the tr in a table/tgroup? Parent: <xsl:value-of select="name(..)"/>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="currentRow" select="." />

    <xsl:variable name="normalizedTDs" as="element()*">
      <xsl:for-each select="$previousRow/*">
        <xsl:choose>
          <xsl:when test="@rowspan &gt; 1">
            <xsl:copy>
              <xsl:copy-of select="@*" />
              <xsl:attribute name="rowspan">
                <xsl:value-of select="@rowspan - 1" />
              </xsl:attribute>
              <xsl:attribute name="data-rowspan-part">
                <xsl:value-of select="if(@data-rowspan-part) then @data-rowspan-part + 1 else 2" />
              </xsl:attribute>
              <xsl:attribute name="data-rownum">
                <xsl:value-of select="$rownum" />
              </xsl:attribute>
              <xsl:copy-of select="node()" />
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates
              select="$currentRow/*[1 + count(current()/preceding-sibling::*[not(@rowspan) or (@rowspan = 1)])]" 
              mode="#current">
              <xsl:with-param name="rownum" select="$rownum" />
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="newRow" as="element()">
      <xsl:copy>
        <xsl:copy-of select="$currentRow/@*" />
        <xsl:variable name="data-twips-width" select="sum(
                                                        for $w in $normalizedTDs[not(@data-colspan-part &gt; 1)]/@data-twips-width 
                                                        return (
                                                          if ($w castable as xs:double)
                                                          then xs:double($w) 
                                                          else ()
                                                        ) 
                                                      )" as="xs:double?"/>
        <xsl:if test="$data-twips-width">
          <xsl:attribute name="data-twips-width" select="$data-twips-width" />
        </xsl:if>
        <xsl:copy-of select="$normalizedTDs" />
      </xsl:copy>
    </xsl:variable>

    <xsl:sequence select="$newRow" />

    <xsl:apply-templates select="following-sibling::*:tr[1]" mode="htmltable:normalize-rowspans">
      <xsl:with-param name="previousRow" select="$newRow" />
      <xsl:with-param name="rownum" select="$rownum + 1" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="*:td | *:th" mode="htmltable:normalize-rowspans">
    <xsl:param name="rownum" as="xs:integer?" />
    <xsl:choose>
      <xsl:when test="$rownum">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="data-rownum" select="$rownum"/>
          <xsl:copy-of select="node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message>Cell <xsl:copy-of select="."/> probably is in a row that is not contained in a table</xsl:message>
        <xsl:comment>not in a table?</xsl:comment>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*|*" 
    mode="htmltable:normalize-colspans
          htmltable:normalize-rowspans
          htmltable:normalize-final
          ">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="#current" />
    </xsl:copy>
  </xsl:template>

  <!-- /normalization -->

  <xsl:function name="htmltable:index-of" as="xs:integer*">
    <xsl:param name="nodes" as="node()*" />
    <xsl:param name="node" as="node()*" />
    <xsl:sequence select="distinct-values(for $s in $node return (index-of(for $n in $nodes return generate-id($n), generate-id($s))))" />
  </xsl:function>



</xsl:stylesheet>
