<?xml version="1.0" encoding="UTF-8"?>
<!--
$Id: fontMetrics.xsl 1 2008-12-17 13:24:36Z piater $

Copyright (C) 2008 by Alexandre Stevens and Justus H. Piater.

This file is part of pMML2SVG.

pMML2SVG is free software; you can redistribute it and/or modify it
under the terms of the GNU Lesser General Public License as published by the
Free Software Foundation; either version 2, or (at your option) any
later version.

pMML2SVG is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
for more details.

You should have received a copy of the GNU Lesser General Public License
along with pMML2SVG; see the file COPYING.  If not, write to the Free
Software Foundation, 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
-->

<!--
Metrics files format comes from FOP TTFReader tool (http://xmlgraphics.apache.org/fop/)
The metric formats currently supported are :
- Type 1 font metric file (WinAnsiEncoding type)
- True Type metrics encoded with TTFReader in CID or WinAnsiEncoding type

The best file format is CID that give more information about metrics
-->
<xsl:stylesheet version="2.0"
		xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns:func="http://localhost/functions">

  <doc:reference>
    <info>
      <title>Font metrics stylesheet</title>
    </info>
    <partintro>
      <title>Introduction</title>
      
      <para>
	This stylesheet offers functions to interact with an <acronym>XML</acronym> <acronym>FOP</acronym> metrics file. Currently, three types
	of <acronym>FOP</acronym> metrics are supported: WinAnsiEncoding, Type1 font and <acronym>TTF</acronym> font. The latter is preferred
	because the metrics contain more symbol metrics and more precise metrics. WinAnsiEncoding and Type1 files only contain a maximum of 255 metrics.
      </para>
    </partintro>
  </doc:reference>

  <doc:function name="findFont">
    <refpurpose>Finds an existing font metrics file for a font name with respect to variants (italic, bold, etc.)</refpurpose>

    <refdescription>
      <para>
	Firstly, if a metrics file exists for the current font name and variant, the name of this file is returned. If not, a check is proceeded to simplify
	the variant.
      </para>

      <para>
	If the variant is <filename>-Bold-Italic</filename>, a metrics file is searched for the <filename>-Bold</filename>
	and the <filename>-Italic</filename> variant. If one of them exists, the name of this metrics file is returned. Otherwise, a metrics file
	with no variant is checked and returned if it exists.
      </para>

      <para>
	If the variant is only <filename>-Bold</filename> or only <filename>-Italic</filename>, a check for a file with no variant is proceeded.
	If it succeeds, the name of this metrics file is returned.
      </para>

      <para>
	In all other cases, when no font metrics file can be found, an empty name is returned.
      </para>
    </refdescription>
    
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>font</term>
	  <listitem>
	    <para>Font name</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>variant</term>
	  <listitem>
	    <para>
	      Variant for the font, this variant can be <filename>-Italic</filename>, <filename>-Bold</filename>, <filename>-Bold-Italic</filename> or empty.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
    
    <refreturn>
      <para>Returns the name of the metrics file (without extension) or an empty string if no font was found.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:findFont">
    <xsl:param name="font"/>
    <xsl:param name="variant"/>

    <xsl:variable name="demandedFont" select="concat($font, $variant)"/>

    <xsl:variable name="chosenFont">
      <xsl:choose>
	<!-- Font exists, return this font -->
	<xsl:when test="doc-available(concat($demandedFont, '.xml'))">
	  <xsl:value-of select="$demandedFont"/>
	</xsl:when>
	<!-- Otherwise, no font metrics found -->
	<xsl:otherwise>
	  <xsl:variable name="varLenght" select="string-length($variant)"/>
	  <xsl:choose>
	    <!-- Variant = -Bold-Italic -->
	    <xsl:when test="$varLenght = 12">
	      <!-- Test bold -->
	      <xsl:choose>
		<!-- Bold exist so return bold -->
		<xsl:when test="doc-available(concat($font, '-Bold.xml'))">
		  <xsl:value-of select="concat($font, '-Bold')"/>
		</xsl:when>
		<!-- Italic exist so return bold -->
		<xsl:when test="doc-available(concat($font, '-Italic.xml'))">
		  <xsl:value-of select="concat($font, '-Italic')"/>
		</xsl:when>
		<!-- Otherwise, check no variant -->
		<xsl:otherwise>
		  <xsl:value-of
		      select="if (doc-available(concat($font, '.xml')))
			      then $font else ''"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:when>
	    <!-- No variant, return empty string -->
	    <xsl:when test="$varLenght = 0"/>
	    <!-- Bold or Italic variant -->
	    <xsl:otherwise>
	      <!-- Test with no variant -->
	      <xsl:value-of select="if (doc-available(concat($font, '.xml')))
				    then $font else ''"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="string-length($chosenFont) = 0">
	<xsl:message terminate="yes">
	  <xsl:text>ERROR: font </xsl:text>
	  <xsl:value-of select="$demandedFont"/>
	  <xsl:text> not found</xsl:text>
	</xsl:message>
      </xsl:when>
      <xsl:when test="compare($chosenFont, $demandedFont)">
	<xsl:message>
	  <xsl:text>WARNING: font </xsl:text>
	  <xsl:value-of select="$demandedFont"/>
	  <xsl:text> not found, using </xsl:text>
	  <xsl:value-of select="$chosenFont"/>
	  <xsl:text> instead</xsl:text>
	</xsl:message>
      </xsl:when>
    </xsl:choose>

    <xsl:value-of select="$chosenFont"/>
  </xsl:function>


  <doc:template name="findWidth">
    <refpurpose>Find the width of a character from a list of fonts. The first font of the list that contains the character will be used.</refpurpose>

    <refdescription>
      <para>
	Firstly, a check is done to verify if the character is not an invisible operator such as invisible time or apply function. If it is one,
	the size 0 is returned. Otherwise, the character is checked among the font list.
      </para>

      <para>
	The list is browsed to find a metrics file (using <filename>findFont</filename> function) that contains the character. If such a file
	can be found, the width metric from this file is returned. Otherwise size 0.8 is returned.
      </para>

      <para>
	To retrieve a width from a metric file, the template <filename>findWidthFile</filename> is used.
      </para>
    </refdescription>
    
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>name</term>
	  <listitem>
	    <para>Character to check.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>fonts</term>
	  <listitem>
	    <para>
	      Font list that is used to find the character width.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>variant</term>
	  <listitem>
	    <para>
	      Variant for the font, this variant can be <filename>-Italic</filename>, <filename>-Bold</filename>, <filename>-Bold-Italic</filename> or empty.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>

      <varlistentry>
	<term>fontInit</term>
	<listitem>
	  <para>
	    Initial font list that is used to find the character width. Since the font list will be modified through the recursion. The initial 
	    list has to be saved.
	  </para>
	</listitem>
      </varlistentry>
    </refparameter>
    
    <refreturn>
      <para>Returns the width of the character in em or 0.8em if the character is not found within the font list.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="findWidth">
    <xsl:param name="name"/>
    <xsl:param name="fonts"/>
    <xsl:param name="variant"/>
    <xsl:param name="fontInit" select="$fonts"/>

    <xsl:choose>
      <!-- Invisible operators
	   &InvisibleTimes;  	&it;
	   &ApplyFunction; 	&af;
	   &InvisibleComma; 	&ic;
	   &ZeroWidthSpace;
      -->
      <xsl:when test="$name='&#8290;' or $name='&#8289;' or $name='&#8291;' or $name='&#8203;'">
	<xsl:value-of select="0"/>
      </xsl:when>
      <!-- All other characters -->
      <xsl:otherwise>
	<xsl:choose>
	  <!-- There is font to test -->
	  <xsl:when test="$fonts[1]">
	    <xsl:variable name="currentFont" select="func:findFont($fonts[1], $variant)"/>

	    <!-- Compute width -->
	    <xsl:variable name="width">
	      <xsl:choose>
		<xsl:when test="$currentFont">
		  <xsl:call-template name="findWidthFile">
		    <xsl:with-param name="name" select="$name"/>
		    <xsl:with-param name="fontName" select="$currentFont"/>
		  </xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="-1"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:variable>

	    <xsl:choose>
	      <xsl:when test="$width &lt; 0">
		<xsl:call-template name="findWidth">
		  <xsl:with-param name="name" select="$name"/>
		  <xsl:with-param name="fonts" select="$fonts[position() &gt; 1]"/>
		  <xsl:with-param name="variant" select="$variant"/>
		  <xsl:with-param name="fontInit" select="$fontInit"/>
		</xsl:call-template>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="$width"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <!-- No metrics found with variant, remove it -->
	  <xsl:when test="not($fonts[1]) and $variant != ''">
	    <xsl:call-template name="findWidth">
	      <xsl:with-param name="name" select="$name"/>
	      <xsl:with-param name="fonts" select="$fontInit"/>
	      <xsl:with-param name="variant" select="''"/>
	      <xsl:with-param name="fontInit" select="$fontInit"/>
	    </xsl:call-template>
	  </xsl:when>
	  <!-- Default value is 0.8 -->
	  <xsl:otherwise>
	    <xsl:message>
	      <xsl:text>WARNING: no glyph found for </xsl:text>
	      <xsl:value-of select="$name"/>
	      <xsl:text> (U+</xsl:text>
	      <xsl:value-of select="func:int2hex(string-to-codepoints($name))"/>
	      <xsl:text>)</xsl:text>
	    </xsl:message>
	    <xsl:value-of select="0.8"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <doc:template name="findWidthFile">
    <refpurpose>Find the width of a character from a font metrics file.</refpurpose>

    <refdescription>
      <para>
	Firstly, the final font name is computed by adding the extension <filename>.xml</filename> to the <filename>fontName</filename> parameter, and the
	character code point is retrieved by using the XPath <filename>string-to-codepoints</filename> function. The metrics file document tree is then
	retrieved by using the <filename>document</filename> function.
      </para>

      <para>
	After that, the width attribute is retrieved from the metrics document with respect to the font metrics encoding. If the encoding is 
	<filename>CID</filename>, a glyph start index (<filename>gs</filename>) and unicode start value (<filename>us</filename>) are 
	computed to retrieve the attribute <filename>w</filename> (which contains the width of the character) from the 
	<computeroutput>(gi + 1 + codePoint - us)</computeroutput>th <filename>wx</filename> element of the metrics file. In all other cases (WinAnsiEncoding), the
	<filename>wdt</filename> attribute (which contains the width of the character) from the <filename>char</filename> element whose its
	<filename>idx</filename> attribute is <filename>codePoint</filename>.
      </para>

      <para>
	Finally, if this width is zero, the width of <command>x</command> is returned instead. If no width was found, -1 is returned and, in all other
	cases, the width divided by 1000 is returned.
      </para>
    </refdescription>
    
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>name</term>
	  <listitem>
	    <para>Character to find.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>fontName</term>
	  <listitem>
	    <para>
	      Name of the font metric file (without extension).
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
    
    <refreturn>
      <para>Returns the width of the character in em or -1 if the character is not found in the font metrics file.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="findWidthFile">
    <xsl:param name="name"/>
    <xsl:param name="fontName"/>

    <xsl:variable name="normalizeFontName" select="concat($fontName, '.xml')"/>
    
    <!-- Character code as xs:integer -->
    <xsl:variable name="codePoint" select="string-to-codepoints($name)"/>

    <!-- Font Metrics document -->
    <xsl:variable name="fontMetricsDoc" select="document($normalizeFontName)"/>
    
    <xsl:variable name="width">
      <!-- Which type of FOP font metrics does we have
	   Currently supported : Type1 (WinAnsiEncoding), TrueType (WinAnsiEncoding), TrueType (CID Encoding)
      -->
      <xsl:choose>
	<!-- CID Encoding -->
	<xsl:when test="$fontMetricsDoc//multibyte-extras">
	  <!-- Glyph Start Index -->
	  <xsl:variable name="gi" 
			select="$fontMetricsDoc/font-metrics/multibyte-extras/bfranges/
				bf[@us &lt;= $codePoint and $codePoint &lt;= @ue]/@gi"/>
	  <!-- Unicode Start -->
	  <xsl:variable name="us" 
			select="$fontMetricsDoc/font-metrics/multibyte-extras/bfranges/
				bf[@us &lt;= $codePoint and $codePoint &lt;= @ue]/@us"/>

	  <xsl:value-of select="$fontMetricsDoc/font-metrics/multibyte-extras/cid-widths/wx[$gi + 1 + $codePoint - $us ]/@w"/>
	</xsl:when>
	<!-- WinAnsiEncoding -->
	<xsl:otherwise>
	  <xsl:value-of select="$fontMetricsDoc//widths/char[@idx=$codePoint]/@wdt"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$width != '' and $width = 0">
	<!-- If width is 0, give to the string the size of x -->
	<xsl:call-template name="findWidthFile">
	  <xsl:with-param name="name" select="'x'"/>
	  <xsl:with-param name="fontName" select="$fontName"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:when test="$width != '' and $width &gt; 0">
	<xsl:value-of select="$width div 1000"/>
      </xsl:when>
      <xsl:otherwise>
	<!-- No metric found, return -1 -->
	<xsl:value-of select="-1"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:function name="func:int2hex" as="xs:string">
    <xsl:param name="int" as="xs:integer"/>
    <xsl:variable name="base" as="xs:integer" select="16"/>
    <xsl:variable name="chr" as="xs:string" select="'0123456789abcdef'"/>
    <xsl:if test="(1 gt $base) or (string-length($chr) lt $base)">
      <xsl:message terminate="yes">
	<xsl:text>Internal error: invalid base </xsl:text>
	<xsl:value-of select="$base"/>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="car" as="xs:integer" select="$int mod $base"/>
    <xsl:variable name="cdr" as="xs:integer"
		  select="($int div $base) cast as xs:integer"/>
    <xsl:value-of select="concat(if ($base lt $int)
			  then func:int2hex($cdr) else '',
			  substring($chr, 1+$car, 1))"/>
  </xsl:function>


  <doc:function name="findBbox">
    <refpurpose>Find the bounding box of a character from a list of fonts. The first font of the list containing the character will be used.</refpurpose>

    <refdescription>
      <para>
	This function simply calls the <filename>findBbox</filename> template. It is used because functions are easier to call in some cases than a template.
      </para>
    </refdescription>

    <refsee>
      <para>
	<filename>findBbox</filename>
      </para>
    </refsee>
    
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>name</term>
	  <listitem>
	    <para>Character to check.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>fonts</term>
	  <listitem>
	    <para>
	      Font list that is used to find the character width.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>variant</term>
	  <listitem>
	    <para>
	      Variant for the font, this variant can be <filename>-Italic</filename>, <filename>-Bold</filename>, <filename>-Bold-Italic</filename> or empty.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
    
    <refreturn>
      <para>Returns the bounding box of the character in em or <filename>(0, 0, 0, 0)</filename> if the character is not found within the font list. The 
      bounding box is returned in a sequence of four elements: <filename>(xMin, xMax, yMin, yMax)</filename>.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:findBbox" as="xs:double+">
    <xsl:param name="name"/>
    <xsl:param name="fonts"/>
    <xsl:param name="variant"/>

    <xsl:call-template name="findBbox">
      <xsl:with-param name="name" select="$name"/>
      <xsl:with-param name="fonts" select="$fonts"/>
      <xsl:with-param name="variant" select="$variant"/>
    </xsl:call-template>
  </xsl:function>

  <doc:template name="findBbox">
    <refpurpose>Finds the bounding box of a character from a list of font. The first font of the list that contains the character will be used.</refpurpose>

    <refdescription>
      <para>
	Firstly, a check is done to verify if the character is not an invisible operator such as invisible time or apply function. If it is one,
	the bounding box <filename>(0, 0, 0, 0)</filename> is returned. Otherwise, the character is checked among the font list.
      </para>

      <para>
	The list is browsed to find a metrics file (using <filename>findFont</filename> function) that contains the character. If such a file
	can be found, the bounding box metrics from this file is returned. Otherwise sequence <filename>(0, 0, 0, 0)</filename> is returned.
      </para>

      <para>
	To retrieve a bounding box from a metric file, the template <filename>findBboxFile</filename> is used.
      </para>
    </refdescription>
    
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>name</term>
	  <listitem>
	    <para>Character to check.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>fonts</term>
	  <listitem>
	    <para>
	      Font list that is used to find the character bounding box.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>variant</term>
	  <listitem>
	    <para>
	      Variant for the font, this variant can be <filename>-Italic</filename>, <filename>-Bold</filename>, <filename>-Bold-Italic</filename> or empty.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>fontInit</term>
	  <listitem>
	    <para>
	      Initial font list that is used to find the character bounding box. Since the font list will be modified through the recursion. The initial 
	      list has to be saved.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
    
    <refreturn>
      <para>Returns the bounding box of the character in em or <filename>(0, 0, 0, 0)</filename> if the character is not found within the font list. The 
      bounding box is returned in a sequence of four elements: <filename>(xMin, xMax, yMin, yMax)</filename>.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="findBbox" as="xs:double+">
    <xsl:param name="name"/>
    <xsl:param name="fonts"/>
    <xsl:param name="variant"/>
    <xsl:param name="fontInit" select="$fonts"/>

    <xsl:choose>
      <!-- Invisible operator 
	   &InvisibleTimes;  	&it;
	   &ApplyFunction; 	&af;
	   &InvisibleComma; 	&ic;
	   &ZeroWidthSpace;
      -->
      <xsl:when test="$name='&#8290;' or $name='&#8289;' or $name='&#8291;' or $name='&#8203;'">
	<xsl:sequence select="(0, 0, 0, 0)"/>
      </xsl:when>
      <!-- All other characters -->
      <xsl:otherwise>
	<xsl:choose>
	  <!-- There is font to test -->
	  <xsl:when test="$fonts[1]">
	    <xsl:variable name="currentFont" select="func:findFont($fonts[1], $variant)"/>

	    <!-- Compute width -->
	    <xsl:variable name="bbox" as="xs:double+">
	      <xsl:choose>
		<xsl:when test="$currentFont">
		  <xsl:call-template name="findBboxFile">
		    <xsl:with-param name="name" select="$name"/>
		    <xsl:with-param name="fontName" select="$currentFont"/>
		  </xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="-1"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:variable>

	    <xsl:choose>
	      <xsl:when test="count($bbox) = 1 and $bbox = -1">
		<xsl:call-template name="findBbox">
		  <xsl:with-param name="name" select="$name"/>
		  <xsl:with-param name="fonts" select="$fonts[position() &gt; 1]"/>
		  <xsl:with-param name="variant" select="$variant"/>
		  <xsl:with-param name="fontInit" select="$fontInit"/>
		</xsl:call-template>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:sequence select="$bbox"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:when>
	  <!-- No metrics found with variant, remove it -->
	  <xsl:when test="not($fonts[1]) and $variant != ''">
	    <xsl:call-template name="findBbox">
	      <xsl:with-param name="name" select="$name"/>
	      <xsl:with-param name="fonts" select="$fontInit"/>
	      <xsl:with-param name="variant" select="''"/>
	      <xsl:with-param name="fontInit" select="$fontInit"/>
	    </xsl:call-template>
	  </xsl:when>
	  <!-- Default value is 0 0 0 0 -->
	  <xsl:otherwise>
	    <xsl:message>
	      <xsl:text>WARNING: Cannot determine bounding box for glyph </xsl:text>
	      <xsl:value-of select="$name"/>
	      <xsl:text> in </xsl:text>
	      <xsl:value-of select="$fontInit"/>
	      <xsl:value-of select="$variant"/>
	    </xsl:message>
	    <xsl:sequence  select="(0, 0, 0, 0)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <doc:template name="findBboxFile">
    <refpurpose>Finds the bounding box of a character from a font metrics file.</refpurpose>

    <refdescription>
      <para>
	Firstly, the final font name is computed by adding the extension <filename>.xml</filename> to the <filename>fontName</filename> parameter, and the
	character code point is retrieved by using the XPath <filename>string-to-codepoints</filename> function. The metrics file document tree is then
	retrieved by using the <filename>document</filename> function.
      </para>

      <para>
	After that, the bounding box attribute is retrieved from the metrics document with respect to the font metrics encoding. The bounding box
	can only be retrieved in the CID encoding. Therefore, the glyph start index (<filename>gs</filename>) and unicode start value (<filename>us</filename>) are 
	computed to retrieve the attributes <filename>xMin</filename>, <filename>xMax</filename>, <filename>yMin</filename> and <filename>yMax</filename>, 
	from the <computeroutput>(gi + 1 + codePoint - us)</computeroutput>th <filename>wx</filename> element of the metrics file. With a metrics file
	encoded in WinAnsiEncoding, bounding box <filename>(0, 0, 0, 0)</filename> is returned.
      </para>

      <para>
	If the character cannot be found in the metrics file, the value -1 is returned.
      </para>
    </refdescription>
    
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>name</term>
	  <listitem>
	    <para>Character to find.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>fontName</term>
	  <listitem>
	    <para>
	      Name of the font metric file (without extension).
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
    
    <refreturn>
      <para>Returns the bounding box of the character in em or -1 if the character is not found in the font metrics file. The bounding box is 
      returned in a sequence like that <filename>(xMin, xMax, yMin, yMax)</filename></para>
    </refreturn>
  </doc:template>
  <xsl:template name="findBboxFile" as="xs:double+">
    <xsl:param name="name"/>
    <xsl:param name="fontName"/>

    <xsl:variable name="normalizeFontName" select="concat($fontName, '.xml')"/>
    
    <!-- Character code as xs:integer -->
    <xsl:variable name="codePoint" select="string-to-codepoints($name)"/>

    <!-- Font Metrics document -->
    <xsl:variable name="fontMetricsDoc" select="document($normalizeFontName)"/>
    
    <xsl:variable name="bbox" as="xs:double+">
      <!-- Which type of FOP font metrics does we have
	   Currently supported : Type1 (WinAnsiEncoding), TrueType (WinAnsiEncoding), TrueType (CID Encoding)
      -->
      <xsl:choose>
	<!-- CID Encoding -->
	<xsl:when test="$fontMetricsDoc//multibyte-extras">
	  <!-- Glyph Start Index -->
	  <xsl:variable name="gi" 
			select="$fontMetricsDoc/font-metrics/multibyte-extras/bfranges/
				bf[@us &lt;= $codePoint and $codePoint &lt;= @ue]/@gi"/>
	  <!-- Unicode Start -->
	  <xsl:variable name="us" 
			select="$fontMetricsDoc/font-metrics/multibyte-extras/bfranges/
				bf[@us &lt;= $codePoint and $codePoint &lt;= @ue]/@us"/>

	  <xsl:choose>
	    <xsl:when test="$fontMetricsDoc/font-metrics/multibyte-extras/cid-widths/wx[$gi + 1 + $codePoint - $us ]/@xMin != ''">
	      <xsl:sequence select="(number($fontMetricsDoc/font-metrics/multibyte-extras/cid-widths/wx[$gi + 1 + $codePoint - $us ]/@xMin div 1000),
				    number($fontMetricsDoc/font-metrics/multibyte-extras/cid-widths/wx[$gi + 1 + $codePoint - $us ]/@xMax div 1000),
				    number($fontMetricsDoc/font-metrics/multibyte-extras/cid-widths/wx[$gi + 1 + $codePoint - $us ]/@yMin div 1000),
				    number($fontMetricsDoc/font-metrics/multibyte-extras/cid-widths/wx[$gi + 1 + $codePoint - $us ]/@yMax div 1000))"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="-1"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:when>
	<!-- WinAnsiEncoding -->
	<xsl:otherwise>
	  <xsl:sequence select="(0, 0, 0, 0)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:sequence select="$bbox"/>
  </xsl:template>


  <doc:function name="findHeight">
    <refpurpose>Finds height and depth of a string from a list of font by using the bounding box (from metrics) of each character in the string. The first 
    font of the list containing the character will be used.</refpurpose>

    <refdescription>
      <para>
	This function simply calls <filename>findHeightAlt</filename> template.
      </para>
    </refdescription>

    <refsee>
      <para>
	<filename>findHeightAlt</filename>
      </para>
    </refsee>
    
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>str</term>
	  <listitem>
	    <para>String to check.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>fonts</term>
	  <listitem>
	    <para>
	      Font list that is used to find the character width.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>variant</term>
	  <listitem>
	    <para>
	      Variant for the font, this variant can be <filename>-Italic</filename>, <filename>-Bold</filename>, <filename>-Bold-Italic</filename> or empty.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
    
    <refreturn>
      <para>Returns the height and depth of a string in a sequence: <filename>(height, depth)</filename>.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:findHeight" as="xs:double+">
    <xsl:param name="str"/>
    <xsl:param name="fonts"/>
    <xsl:param name="variant"/>

    <xsl:call-template name="findHeightAlt">
      <xsl:with-param name="str" select="$str"/>
      <xsl:with-param name="strLen" select="string-length($str)"/>
      <xsl:with-param name="fonts" select="$fonts"/>
      <xsl:with-param name="variant" select="$variant"/>
    </xsl:call-template>
  </xsl:function>

  <doc:template name="findHeightAlt">
    <refpurpose>Finds height and depth of a string from a list of font by using the bounding box (from metrics) of each character in the string. The first 
    font of the list containing the character will be used.</refpurpose>

    <refsee>
      <para>
	<filename>findBbox</filename>
      </para>
    </refsee>

    <refdescription>
      <para>
	For each character, the bounding box is retrieved and the template is called recursively with an updated value for <filename>height</filename>
	and <filename>width</filename>. For the height value, the maximum between <filename>yMax</filename> (from the bounding box) and the 
	<filename>height</filename> paramater is taken, and for the depth, the minimum between <filename>yMin</filename> (from the bounding box) and
	the <filename>depth</filename> parameter is taken.
      </para>
    </refdescription>
    
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>str</term>
	  <listitem>
	    <para>String to check.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>strLen</term>
	  <listitem>
	    <para>Number of characters in the string.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>i</term>
	  <listitem>
	    <para>Index of the character that is currently analysed.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>fonts</term>
	  <listitem>
	    <para>
	      Font list that is used to find the character width.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>variant</term>
	  <listitem>
	    <para>
	      Variant for the font, this variant can be <filename>-Italic</filename>, <filename>-Bold</filename>, <filename>-Bold-Italic</filename> or empty.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>height</term>
	  <listitem>
	    <para>
	      Accumulator that saves the highest height for the first <filename>i</filename> characters.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>depth</term>
	  <listitem>
	    <para>
	      Accumulator that saves the lowest depth for the first <filename>i</filename> characters.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
    
    <refreturn>
      <para>Returns the height and depth of a string in a sequence: <filename>(height, depth)</filename>.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="findHeightAlt">
    <xsl:param name="str"/>
    <xsl:param name="strLen"/>
    <xsl:param name="i" select="1"/>
    <xsl:param name="fonts"/>
    <xsl:param name="variant"/>
    <xsl:param name="height" select="0"/>
    <xsl:param name="depth" select="0"/>

    <xsl:choose>
      <xsl:when test="$i &lt;= $strLen">
	<xsl:variable name="bbox" as="xs:double+">
	  <xsl:call-template name="findBbox">
	    <xsl:with-param name="name" select="substring($str, $i, 1)"/>
	    <xsl:with-param name="fonts" select="$fonts"/>
	    <xsl:with-param name="variant" select="$variant"/>
	  </xsl:call-template>
	</xsl:variable>

	<xsl:call-template name="findHeightAlt">
	  <xsl:with-param name="str" select="$str"/>
	  <xsl:with-param name="strLen" select="$strLen"/>
	  <xsl:with-param name="i" select="$i + 1"/>
	  <xsl:with-param name="fonts" select="$fonts"/>
	  <xsl:with-param name="variant" select="$variant"/>
	  <xsl:with-param name="height" select="if ($bbox[4] &gt; $height)
						then $bbox[4]
						else $height"/> <!-- yMax : bbox[4] -->
	  <xsl:with-param name="depth" select="if ($bbox[3] &lt; $depth)
					       then $bbox[3]
					       else $depth"/> <!-- yMin : bbox[3] -->
	  
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:sequence select="($height, $depth)"/>
      </xsl:otherwise>
   </xsl:choose>
  </xsl:template>
</xsl:stylesheet>