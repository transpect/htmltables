<?xml version="1.0" encoding="UTF-8"?>
<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc"
  xmlns:c="http://www.w3.org/ns/xproc-step" 
  xmlns:htmltable="http://transpect.io/htmltable"
  version="1.0"
  name="add-origin-atts"
  type="htmltable:add-origin-atts">

  <p:input port="source" primary="true">
    <p:documentation>An XHTML document (although proper namespace is not important).</p:documentation>
  </p:input>
  <p:input port="stylesheet">
    <p:document href="../xsl/html-tables.xsl"/>
  </p:input>
  <p:output port="result" primary="true"/>

  <p:xslt name="xslt-add-origin-atts" initial-mode="htmltable:tables-add-atts">
    <p:input port="parameters"><p:empty/></p:input>
    <p:input port="stylesheet">
      <p:pipe port="stylesheet" step="add-origin-atts"/>
    </p:input>
  </p:xslt>
  
</p:declare-step>