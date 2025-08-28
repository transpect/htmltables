<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:tr="http://transpect.io"
  version="1.0"
  name="tr-normalize-html-tables"
  type="tr:normalize-html-tables">
  
  <p:documentation>
    This step represents an XProc wrapper for Andrew J. Welch's 
    table normalization algorithm. The step is called recursively 
    to tackle the problem of nested tables.
  </p:documentation>
  
  <p:input port="source">
    <p:documentation>
      Expects a HTML document with tables.
    </p:documentation>
  </p:input>
  
  <p:output port="result">
    <p:documentation>
      The HTML document with normalized tables.
    </p:documentation>
  </p:output>
  
  <p:option name="process-tables-only" select="'yes'">
    <p:documentation>
      Set to 'yes' to saves some time copying nodes that are not required for table normalization
    </p:documentation>
  </p:option>
  
  <!-- delete redundant colspan and rowspan attributes derived from dtd resolution -->
  
  <p:delete match="@colspan[. eq '1']
                  |@rowspan[. eq '1']"/>
  
  <p:choose>
    <p:when test=".//*:td[@*:colspan or @*:rowspan]
                 |.//*:th[@*:colspan or @*:rowspan]">
      
      <p:viewport match="*:table[    .//*[@*:colspan or @*:rowspan]
                                 and not(@data-table-normalized = 'true')]">
        
        <p:xslt name="expand-table-colspans-rowspans">
          <p:input port="stylesheet">
            <p:document href="http://transpect.io/htmltables/xsl/html-tables-normalize-invoke.xsl"/>
          </p:input>
          <p:with-param name="process-tables-only" select="$process-tables-only"/>
        </p:xslt>
        
        <!-- mark already normalized tables. p:viewport starts always with the outer element. -->
        
        <p:add-attribute match="/*:table" attribute-name="data-table-normalized" attribute-value="true"/>
        
        <p:delete match="@rowspan[not(ancestor::*:table[not(@data-table-normalized = 'yes')])]
                        |@colspan[not(ancestor::*:table[not(@data-table-normalized = 'yes')])]"/>
        
        <tr:normalize-html-tables/>
        
      </p:viewport>
      
    </p:when>
    <p:otherwise>
      <p:identity/>
    </p:otherwise>
  </p:choose>  
  
</p:declare-step>