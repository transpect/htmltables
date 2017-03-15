# htmltables

Library for normalizing HTML tables (adding “physical grid” coordinates to each cell). Requires xslt-util

## Description

This implements Andrew J Welch's [Table Normalization in XSLT 2.0](http://andrewjwelch.com/code/xslt/table/table-normalization.html) in an XSLT function:

```xslt
<xsl:template match="*[*:tr]">
    <xsl:sequence select="htmltable:normalize(.)" />
</xsl:template>
```

Consider an XML or XHTML document containing HTML tables

```xhtml
<table>
  <tbody>
    <tr>
      <td>a</td>
      <td rowspan="2">b</td>
    </tr>
    <tr>
      <td>c</td>
    </tr>
    <tr>
      <td colspan="2">d</td>
    </tr>
  </tbody>
</table>
```

Applying the XSLT function `htmltable:normalize()` will add virtual cells for each colspan and rowspan.

```
-------------         -------------          
|  a  |  b  |         |  a  |  b  |             
-------     -         -------------
|  c  |     |   -->   |  c  |  b  |
-------------         -------------
|     d     |         |  d  |  d  |
-------------         -------------
```

After the normalization, each cell contains `data` attributes which state the former position in the original table. 

```xhtml
<table>         
  <tbody>
    <tr>
      <td data-rownum="1" data-colnum="1">a</td>
      <td rowspan="2" data-rownum="1" data-colnum="2">b</td>
    </tr>
    <tr>
      <td data-rownum="2" data-colnum="1">c</td>
      <td rowspan="1" data-rowspan-part="2" data-rownum="2" data-colnum="2">b</td>
    </tr>
    <tr>
      <td colspan="2" data-colspan-part="1" data-rownum="3" data-colnum="1">d</td>
      <td colspan="2" data-colspan-part="2" data-rownum="3" data-colnum="2">d</td>
    </tr>
  </tbody>
</table>
```
