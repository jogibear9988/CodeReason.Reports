<?xml version="1.0" encoding="utf-8"?>
<!-- 
###############################################################################
$Id: pmml2svg.xsl 256 2012-02-04 20:57:33Z piater $

CREATED: JUNE 2005

AUTHORS: [AST] Alexandre Stevens (alex@dourfestival.be) {STUDENT}
         [JHP] Justus H. Piater (Justus.Piater@ULg.ac.be) {PhD}
         [TMO] Thibault Mouton (Thibault.Mouton@student.ULg.ac.be) {STUDENT}
	 [JJO] Jerome Joslet (Jerome.Joslet@student.ULg.ac.be) {STUDENT}
         Montefiore Institute - University of Liege - Belgium
         
         [STM] Manuel Strehl {STUDENT}
         University of Regensburg - Germany

DESCRIPTION: This stylesheet converts MathML presentation markup into SVG.


Copyright (C) 2005 by Alexandre Stevens and Justus H. Piater.

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

###############################################################################
-->

<!-- IMPORTANT WARNING:

This file is not ready for production use. It is a proof of concept of the
transformation as explained in the report.
The code was written by an XSLT newbie. Nevertheless, the key components
are present, and the code was designed to be easily extensible, hopefully
until the fonctionality is complete or at least sufficient for practical use.

REMARKS:

- The following elements are partially supported:
  mi, mn, mo, mtext, ms, mrow, mfrac, msqrt, msub, msup, msubsup,
  mroot, merror, mphantom, mfenced, munder, mover, munderover, mtable,
  mtr, mtd, mspace, menclose, mstyle, maction

- The following elements are not yet supported:
  mmultiscripts, mlabeledtr, mpadded, mglyph
-->
<xsl:stylesheet version="2.0"
		xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:math="http://www.w3.org/1998/Math/MathML"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns="http://www.w3.org/2000/svg"
		xmlns:t="http://localhost/tmp"
		xmlns:func="http://localhost/functions"
		exclude-result-prefixes="math t xs func doc">

  <doc:reference>
    <info>
      <title>Main stylesheet</title>
    </info>
    
    <partintro>
      <title>Main idea</title>

      <para>
	Each <acronym>MathML</acronym> element can be viewed as a box that will be placed on the final <acronym>SVG</acronym> document. A box is 
	represented by a minimum of six attributes that give information about its position and its size.
      </para>

      <variablelist>
	<title>Attributes of a box</title>
	
	<varlistentry>
	  <term><filename>X, Y</filename></term>
	  <listitem><para>Represent the two dimension coordinates of the upper left corner of the box.</para></listitem>
	</varlistentry>
	
	<varlistentry>
	  <term><filename>WIDTH, HEIGHT</filename></term>
	  <listitem><para>Represent the size of the box.</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>BASELINE</filename></term>
	  <listitem>
	    <para>
	      Represents the line on which the character will be aligned. Analogies can be made with the light guide lines on a lined sheet.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>FONTSIZE</filename></term>
	  <listitem>
	    <para>
	      Determines the font size used in this box.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>

      <para>
	pMML2SVG works with the <acronym>XML</acronym> tree and transforms <acronym>MathML</acronym> to <acronym>SVG</acronym> in two passes. The first 
	pass, called <filename>formatting</filename> mode, anotates each node of the <acronym>MathML</acronym> tree with information about position 
	and size in order to compute a box. These annotations are placed as attributes on the node and belong to a temporary namespace named 
	<filename>t</filename>. A namespace is a family of <acronym>XML</acronym> tags and attributes defined in an <acronym>XML</acronym> schemas. The second 
	pass, named <filename>drawing</filename> mode, interprets annotations in order to draw the boxes on the <acronym>SVG</acronym> result canevas.
      </para>
      
      <para>
	Some boxes need additionnal information to render correctly. For example, for the fraction, coordinates have to be added to place the fraction bar. 
	Each element will describe which information is added to the tree and how it is handled.
      </para>
      
      <para>
	An <acronym>XSLT</acronym> template is written for each <acronym>MathML</acronym> element and for each pass. It means that to implement a 
	<acronym>MathML</acronym> element, two templates have to be written. One for the <filename>formatting</filename> mode and one for the 
	<filename>drawing</filename> mode.
      </para>
    </partintro>
  </doc:reference>
  
  <!-- PARAMETERS CONFIGURATION (GLOBAL) -->
  <doc:param name="svgMasterUnit">
    <refpurpose>Determines the default unit that will be used to render the SVG picture. The default unit is pixel (px).</refpurpose>
  </doc:param>
  <xsl:param name="svgMasterUnit" select="'px'"/>

  <doc:param name="initSize">
    <refpurpose>Determines the initial font size. By default, the value of this parameter is 50.</refpurpose>
    <refdescription>
      <para>
	This value cannot be changed by any <acronym>MathML</acronym> element. It can only be configured by setting it
	with the <acronym>XSLT</acronym> processor. This value can also be set by an external stylesheet that calls a <acronym>MathML</acronym> 
	to <acronym>SVG</acronym> transformation. For example, the stylesheet that transforms the equation into picture in the 
	<acronym>XSL-FO</acronym> code will set this value with respect to the current context.
      </para>
    </refdescription>
  </doc:param>
  <xsl:param name="initSize" select="50"/>

  <doc:param name="minSize">
    <refpurpose>Determines the minimal font size. By default, this value is 8.</refpurpose>
    <refdescription>
      <para>
	This parameter can be set by a <filename>mstyle</filename> element but it is not yet supported.
      </para>
    </refdescription>
  </doc:param>
  <xsl:param name="minSize" select="8"/>

  <!-- Principal font name -->
  <xsl:param name="fontName" select="'STIXGeneral,STIXSizeOneSym'"/>
  <!-- END OF PARAMETERS CONFIGURATION -->

  <!-- Output method -->
  <xsl:output method="xml" indent="yes" version="1.0"
	      omit-xml-declaration="no"
	      media-type="image/svg+xml"
	      cdata-section-elements="style"/>

  <!-- Includes other stylesheet -->
  <xsl:include href="fontMetrics.xsl"/>
  <xsl:include href="formattingMode.xsl"/>
  <xsl:include href="drawingMode.xsl"/>

  <!-- GLOBAL VARIABLES -->
  <doc:variable name="delimPart">
    <refpurpose>This structure determine which glyphes are used to compose a stretchy operator.</refpurpose>

    <refdescription>
      <para>
	The structure is composed of <filename>parts</filename> tags that represent a horizontal or a vertical operator that have to be stretched.
	A part contains two to four <filename>part</filename> children that represent a glyph which composes the operator. The 
	<filename>parts</filename> element can also have attributes. Here is a description of possible attributes for this tag:
	
	<variablelist>
	  <varlistentry>
	    <term><filename>vname</filename></term>
	    <listitem>
	      <para>
		Indicates which operator is stretched <command>vertically</command> using these glyphes to compose it.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>hname</filename></term>
	    <listitem>
	      <para>
		Indicates which operator is stretched <command>horizontally</command> using these glyphes to compose it.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>hrotate</filename></term>
	    <listitem>
	      <para>
		Indicates that the glyphes have to be rotated to compose the horizontal operator. For example, the over or under bracket is
		stretched using the same vertical glyphes than a normal vertical bracket. Therefore, the glyphes have to be rotated to become
		horizontal. This way of composing an operator is due to the unicode encoding that does not contain the horizontal glyphes
		to compose an over or under bracket.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>extenser</filename></term>
	    <listitem>
	      <para>
		Determines towards which side the extenser has to be added. This attribute is used when the symbol is composed by only two glyphes.
		For example, the right floor operator is composed by a bottom part and an extenser, a right simple arrow is composed by a right
		arrow header and an extenser. In the case of the floor operator, the extenser must be added at the <filename>top</filename> of 
		the other part, and for the arrow, the extenser is added on the <filename>left</filename> of the arrow head. This attribute 
		can take four values:
		<variablelist>
		  <varlistentry>
		    <term><filename>top</filename></term>

		    <listitem>
		      <para>
			The extenser will be added at the <filename>top</filename> of the other part.
		      </para>
		    </listitem>
		  </varlistentry>

		  <varlistentry>
		    <term><filename>bottom</filename></term>

		    <listitem>
		      <para>
			The extenser will be added at the <filename>bottom</filename> of the other part.
		      </para>
		    </listitem>
		  </varlistentry>

		  <varlistentry>
		    <term><filename>left</filename></term>

		    <listitem>
		      <para>
			The extenser will be added on the <filename>left</filename> of the other part.
		      </para>
		    </listitem>
		  </varlistentry>

		  <varlistentry>
		    <term><filename>right</filename></term>

		    <listitem>
		      <para>
			The extenser will be added on the <filename>right</filename> of the other part.
		      </para>
		    </listitem>
		  </varlistentry>
		</variablelist>
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>
	
	The last <filename>part</filename> element is always the extenser, the other parts depend on the number of part element.
	When there are four <filename>part</filename> elements, the first element is the top or the left part, the second is the 
	bottom or the right and the third is the middle. When there are three <filename>part</filename> elements, the first element 
	is the top or the left part, and the second is the bottom or the right. When there are two <filename>part</filename> elements,
	the first part depends on the <filename>extenser</filename> attribute. If <acronym>extenser</acronym> is <filename>top</filename>, 
	the first element is the bottom, if <filename>extenser</filename> is <filename>bottom</filename>, the first part is the top. 
	If <filename>extenser</filename> is <filename>left</filename>, the first element is the right part and for <filename>right</filename> 
	it is the left part.
      </para>

      <para>
	Here are some examples of operators that have to be composed and the corresponding <filename>parts</filename> elements in the structure:
      </para>

      <example>
	<title>Bracket parts</title>

	<programlisting><![CDATA[<parts vname="(" hname="&#65077;" hrotate="true">
  <part>&#9115;</part>
  <part>&#9117;</part>
  <part>&#9116;</part>
</parts>
<parts vname=")" hname="&#65078;" hrotate="true">
  <part>&#9118;</part>
  <part>&#9120;</part>
  <part>&#9119;</part>
</parts>]]></programlisting>
      </example>

      <example>
	<title>Floor parts</title>

	<programlisting><![CDATA[<parts vname="&#8970;" extenser="top">
  <part>&#9123;</part>
  <part>&#9122;</part>
</parts>
<parts vname="&#8971;" extenser="top">
  <part>&#9126;</part>
  <part>&#9125;</part>
</parts>]]></programlisting>
      </example>

      <example>
	<title>Arrow parts</title>
	
	<programlisting><![CDATA[<parts hname="&#8594;" extenser="left">
  <part>&#8594;</part>
  <part>&#9135;</part>
</parts>
<parts hname="&#8596;">
  <part>&#8594;</part>
  <part>&#8592;</part>
  <part>&#9135;</part>
</parts>]]></programlisting>
      </example>

      <example>
	<title>Curly Bracket parts</title>
	
	<programlisting><![CDATA[<parts vname="{{" hname="&#65079;" hrotate="true">
  <part>&#9127;</part>
  <part>&#9129;</part>
  <part>&#9128;</part>
  <part>&#9130;</part>
</parts>]]></programlisting>
      </example>
    </refdescription>
  </doc:variable>
  <xsl:variable name="delimPart">
    <parts vname="(" hname="&#9180;" hrotate="true">
      <part>&#9115;</part>
      <part>&#9117;</part>
      <part>&#9116;</part>
    </parts>
    <parts vname=")" hname="&#9181;" hrotate="true">
      <part>&#9118;</part>
      <part>&#9120;</part>
      <part>&#9119;</part>
    </parts>
    <parts vname="[" hname="&#9140;" hrotate="true">
      <part>&#9121;</part>
      <part>&#9123;</part>
      <part>&#9122;</part>
    </parts>
    <parts vname="]" hname="&#9141;" hrotate="true">
      <part>&#9124;</part>
      <part>&#9126;</part>
      <part>&#9125;</part>
    </parts>
    <parts vname="{{" hname="&#9182;" hrotate="true">
      <part>&#9127;</part>
      <part>&#9129;</part>
      <part>&#9128;</part>
      <part>&#9130;</part>
    </parts>
    <parts vname="}}" hname="&#9183;" hrotate="true">
      <part>&#9131;</part>
      <part>&#9133;</part>
      <part>&#9132;</part>
      <part>&#9130;</part>
    </parts>
    <parts vname="&#8747;">
      <part>&#8992;</part>
      <part>&#8993;</part>
      <part>&#9134;</part>
    </parts>
    <parts vname="&#8968;" extenser="bottom">
      <part>&#9121;</part>
      <part>&#9122;</part>
    </parts>
    <parts vname="&#8970;" extenser="top">
      <part>&#9123;</part>
      <part>&#9122;</part>
    </parts>
    <parts vname="&#8969;" extenser="bottom">
      <part>&#9124;</part>
      <part>&#9125;</part>
    </parts>
    <parts vname="&#8971;" extenser="top">
      <part>&#9126;</part>
      <part>&#9125;</part>
    </parts>
    <!--<parts vname="&#8593;" extenser="bottom">
      <part>&#8593;</part>
      <part>&#9168;</part>
    </parts>
    <parts vname="&#8595;" extenser="top">
      <part>&#8595;</part>
      <part>&#9168;</part>
    </parts>-->
    <parts hname="&#8636;" extenser="right">
      <part>&#8636;</part>
      <part>&#9135;</part>
    </parts>
    <parts hname="&#8637;" extenser="right">
      <part>&#8637;</part>
      <part>&#9135;</part>
    </parts>
    <parts hname="&#8640;" extenser="left">
      <part>&#8640;</part>
      <part>&#9135;</part>
    </parts>
    <parts hname="&#8641;" extenser="left">
      <part>&#8641;</part>
      <part>&#9135;</part>
    </parts>
    <parts hname="&#8594;" extenser="left">
      <part>&#8594;</part>
      <part>&#9135;</part>
    </parts>
    <parts hname="&#8592;" extenser="right">
      <part>&#8592;</part>
      <part>&#9135;</part>
    </parts>
    <parts hname="&#8596;">
      <part>&#8594;</part>
      <part>&#8592;</part>
      <part>&#9135;</part>
    </parts>
  </xsl:variable>

  <doc:variable name="delimScale">
    <refpurpose>Determines which operator cannot be composed but can be stretched.</refpurpose>

    <refdescription>
      <para>
	It contains an <acronym>XSLT</acronym> sequence of characters. These characters will be stretched using the 
	<filename>scale</filename> <acronym>SVG</acronym> transformation.
      </para>
    </refdescription>
  </doc:variable>
  <xsl:variable name="delimScale"
	     select="('|', '&#47;', '&#92;', '&#9001;', 
		     '&#9002;', '&#9136;', '&#9137;', 
		     '&#175;', '&#10216;', '&#10217;',
		     '&#818;')"/>

  <doc:variable name="thin">
    <refpurpose>Represents the thin height literal that is used to compute the height of the fraction bar.</refpurpose>
  </doc:variable>
  <xsl:variable name="thin"   select="'0.0625em'"/>
  <doc:variable name="medium">
    <refpurpose>Represents the medium height literal that is used to compute the height of the fraction bar.</refpurpose>
  </doc:variable>
  <xsl:variable name="medium" select="'0.1875em'"/>
  <doc:variable name="thick">
    <refpurpose>Represents the thick height literal that is used to compute the height of the fraction bar.</refpurpose>
  </doc:variable>
  <xsl:variable name="thick"  select="'0.3125em'"/>

  <doc:variable name="rowElement">
    <refpurpose>Represents the elements that are considered as a row.</refpurpose>

    <refdescription>
      <para>
	It contains an <acronym>XSLT</acronym> sequence of string that represent a list of <acronym>MathML</acronym> elements.
      </para>
    </refdescription>
  </doc:variable>
  <xsl:variable name="rowElement" select="('mrow', 'mtd', 'msqrt', 'mstyle', 'merror', 
					  'menclose', 'mpadded', 'mphantom', 'math')"/>
  <!-- END OF GLOBAL -->

  <!-- GLOBAL FUNCTIONS -->
  <doc:function name="getMiddle">
    <refpurpose>Determines the space between the baseline and the middle of the line. This middle is the horizontal bar of the plus operator.</refpurpose>

    <refdescription>
      <para>
	This value is determined by computing the top edge Y coordinate of the <command>-</command> operator by using the <filename>findHeight</filename>
	function.
      </para>
    </refdescription>

    <refsee>
      <para>
	<filename>findHeight</filename>
      </para>
    </refsee>
  
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>fonts</term>
	  <listitem>
	    <para>Current font list.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>variant</term>
	  <listitem>
	    <para>
	      Variant for the fonts, this variant can be <filename>-Italic</filename>, <filename>-Bold</filename>, <filename>-Bold-Italic</filename> or empty.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
    
    <refreturn>
      <para>Returns the space between the baseline and the middle of the line.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:getMiddle">
    <xsl:param name="fonts"/>
    <xsl:param name="variant"/>

    <xsl:variable name="bbox" select="func:findHeight('-', $fonts, $variant)"/>

    <xsl:value-of select="$bbox[1]"/>
  </xsl:function>

  <doc:template name="computeSize">
    <refpurpose>Computes the font size with respect to the current script level and initial size.</refpurpose>

    <refdescription>
      <para>
	The font size is computed by using the <filename>computeSizeMult</filename> function that returns a multiplication factor with respect to
	the current <filename>scriptLevel</filename> and <filename>sizeMult</filename>. The initial font size is divided by this factor if the 
	current <filename>scriptLevel</filename> is lower than 0, and is multiplied by it if the current <filename>scriptLevel</filename> is greater than 0.
      </para>

      <para>
	The size is then compared to <filename>minSize</filename> to return this new font size or the minmum font size. This comparison is done to avoid
	getting a font size that is too small in order to display correctly an expression.
      </para>
    </refdescription>

    <refsee>
      <para>
	<filename>computeSizeMult</filename>
      </para>
    </refsee>
  
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>Parameters from tunnel</term>
	  <listitem>
	    <para>All the function paramaters are retrieved from the tunnel. These parameters are described in detail in the root element description.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
    
    <refreturn>
      <para>Returns the current font size.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="computeSize">
    <xsl:param name="initSize" tunnel="yes"/>
    <xsl:param name="sizeMult" tunnel="yes"/>
    <xsl:param name="minSize" tunnel="yes"/>
    <xsl:param name="scriptlevel" tunnel="yes"/>

    <xsl:variable name="size" select="if ($scriptlevel &lt; 0)
				      then $initSize div func:computeSizeMult($sizeMult, abs($scriptlevel))
				      else $initSize * func:computeSizeMult($sizeMult, $scriptlevel)"/>

    <xsl:choose>
      <xsl:when test="$size &lt;= $minSize">
	<xsl:value-of select="$minSize"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$size"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <doc:function name="computeSizeMult">
    <refpurpose>Compute the factor that will multiply (or divide) the initial size in the computeSize function.</refpurpose>

    <refdescription>
      <para>
	This recursive function compute <filename>sizeMult</filename> exponent <filename>scriptlevel</filename>. It is done recursively by
	multiplying <filename>sizeMult</filename> by the result of the recursion. The <filename>scriptlevel</filename> is
	decremented by one at each recursion call. The basic case is when this value falls to zero and the function simply returns 1.
      </para>

      <para>
	Note that this function is never recusively called with the same paramaters as in the first call. It is impossible since, the 
	<filename>scriptlevel</filename> is always decremented by one.
      </para>
    </refdescription>
  
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>sizeMult</term>
	  <listitem>
	    <para>Size multiplier represents the factor by wich the initial size has to be multiplied when the script level changes.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>scriptlevel</term>
	  <listitem>
	    <para>
	      Current value for the <filename>scriptlevel</filename>. At each recursion, this value is decremented by one to compute the
	      final factor.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
    
    <refreturn>
      <para>Returns the factor.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:computeSizeMult" as="xs:double+">
    <xsl:param name="sizeMult"/>
    <xsl:param name="scriptlevel"/>

    <xsl:choose>
      <xsl:when test="$scriptlevel = 0">
	<xsl:value-of select="1"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$sizeMult * func:computeSizeMult($sizeMult, $scriptlevel - 1)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <doc:template name="unitInPx">
    <refpurpose>Transforms any vertical or horizontal value from one unit to the master unit.</refpurpose>

    <refdescription>
      <para>
	This template simply applies a computation with respect to the value unit. It can handles all these units: literal, px, em, ex, % and no unit.
	A space literal is computed by using the <filename>getSpaceLiteral</filename> template.
	For example, by using this template, 3em will be computed 3 * <filename>fontSize</filename>, 5 will be computed 5 * <filename>default</filename>, etc.
      </para>
    </refdescription>

    <refsee>
      <para>
	<filename>getSpaceLiteral</filename>
      </para>
    </refsee>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>valueUnit</term>
	  <listitem>
	    <para>The original measure to handle.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>fontSize</term>
	  <listitem>
	    <para>The current font size, this paramater is used to compute relative unit value.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>default</term>
	  <listitem>
	    <para>This parameter is used to compute percentage or no unit measure.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns the value expressed in the master unit.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="unitInPx" as="xs:double+">               
    <xsl:param name="valueUnit"/>
    <xsl:param name="fontSize"/>
    <xsl:param name="default" select="0"/>
    
    <xsl:variable name="value" select="number(replace($valueUnit, '[A-Za-z%]', ''))"/>
    <xsl:variable name="unit" select="replace($valueUnit, '[0-9.\-]', '')"/>
    <xsl:choose>
      <xsl:when test="$unit = 'px'">
	<xsl:value-of select="$value"/>
      </xsl:when>
      <xsl:when test="$unit = 'em' or $unit = 'ex'">
	<xsl:value-of select="$fontSize * $value"/>
      </xsl:when>
      <xsl:when test="$unit = '%'">
	<xsl:value-of select="$default * $value div 100"/>
      </xsl:when>
      <xsl:when test="$unit = ''">
	<xsl:value-of select="$default * $value"/>
      </xsl:when>
      <!-- Literal space -->
      <xsl:otherwise>
	<xsl:variable name="spaceLiteralValue">
	  <xsl:call-template name="getSpaceLiteral">
	    <xsl:with-param name="literal" select="$unit"/>
	  </xsl:call-template>
	</xsl:variable>

	<!-- User may specify that a space literal is equal
	     to itself (for example, mediummathspace='mediummathspace'. 
	     In this case we'll have a infinite recursion because 
	     we'll call recursion with same parameters as the previous 
	     call, so avoid these infinite recursive call and return 0.
	-->
	<xsl:choose>
	  <xsl:when test="$spaceLiteralValue = $unit">
	    <xsl:value-of select="0"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:call-template name="unitInPx">
	      <xsl:with-param name="valueUnit" select="$spaceLiteralValue"/>
	      <xsl:with-param name="fontSize" select="$fontSize"/>
	    </xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <doc:template name="getSpaceLiteral">
    <refpurpose>Retrieve the size expressed by a space literal.</refpurpose>

    <refdescription>
      <para>
	This template simply browses all possible literal names and returns the corresponding space value. It supports the following literals: 
	<filename>veryverythinmathspace</filename>, <filename>verythinmathspace</filename>, <filename>thinmathspace</filename>, 
	<filename>mediummathspace</filename>, <filename>thickmathspace</filename>, <filename>verythickmathspace</filename>, 
	<filename>veryverythickmathspace</filename>.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>literal</term>
	  <listitem>
	    <para>The literal name.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>*mathspace</term>
	  <listitem>
	    <para>Represents the value of the space literals. These values are retrieved from tunnel since the <filename>mstyle</filename> element
	    enables to modify them.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns the value expressed by a space literal.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="getSpaceLiteral">               
    <xsl:param name="literal"/>
    <!-- Space literals from tunnel -->
    <xsl:param name="veryverythinmathspace" tunnel="yes"/>
    <xsl:param name="verythinmathspace" tunnel="yes"/>
    <xsl:param name="thinmathspace" tunnel="yes"/>
    <xsl:param name="mediummathspace" tunnel="yes"/>
    <xsl:param name="thickmathspace" tunnel="yes"/>
    <xsl:param name="verythickmathspace" tunnel="yes"/>
    <xsl:param name="veryverythickmathspace" tunnel="yes"/>
    
    <xsl:choose>
      <xsl:when test="$literal = 'veryverythinmathspace'">
	<xsl:value-of select="$veryverythinmathspace"/>
      </xsl:when>
      <xsl:when test="$literal = 'verythinmathspace'">
	<xsl:value-of select="$verythinmathspace"/>
      </xsl:when>
      <xsl:when test="$literal = 'thinmathspace'">
	<xsl:value-of select="$thinmathspace"/>
      </xsl:when>
      <xsl:when test="$literal = 'mediummathspace'">
	<xsl:value-of select="$mediummathspace"/>
      </xsl:when>
      <xsl:when test="$literal = 'thickmathspace'">
	<xsl:value-of select="$thickmathspace"/>
      </xsl:when>
      <xsl:when test="$literal = 'verythickmathspace'">
	<xsl:value-of select="$verythickmathspace"/>
      </xsl:when>
      <xsl:when test="$literal = 'veryverythickmathspace'">
	<xsl:value-of select="$veryverythickmathspace"/>
      </xsl:when>
      <xsl:when test="$literal = 'thin'">
	<xsl:value-of select="$thin"/>
      </xsl:when>
      <xsl:when test="$literal = 'medium'">
	<xsl:value-of select="$medium"/>
      </xsl:when>
      <xsl:when test="$literal = 'thick'">
	<xsl:value-of select="$thick"/>
      </xsl:when>
      <!-- Fallback : 0em -->
      <xsl:otherwise>
	<xsl:text>0em</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <doc:function name="chooseAttribute">
    <refpurpose>Selects the best value between the three paramaters.</refpurpose>

    <refdescription>
      <para>
	This function is used to retrieve style attributes. The value specified by users has the priority and will be chosen if it is not empty. 
	The second choice is the herited value from a parent if it is not empty. And, finally, the default one is choosen if all other values are
	empty.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>user</term>
	  <listitem>
	    <para>The value wanted by users. Specified via an attribute to an element.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>herited</term>
	  <listitem>
	    <para>It is the value herited from a parent.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>default</term>
	  <listitem>
	    <para>It is the default value from the specification.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns the choosen attribute.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:chooseAttribute">
    <xsl:param name="user"/>
    <xsl:param name="herited"/>
    <xsl:param name="default"/>

    <xsl:choose>
      <xsl:when test="string($user) != ''">
	<xsl:value-of select="$user"/>
      </xsl:when>
      <xsl:when test="string($herited) != ''">
	<xsl:value-of select="$herited"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$default"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <doc:function name="getFontNameVariant">
    <refpurpose>Computes the variant of the font name with respect to the style parameters.</refpurpose>

    <refdescription>
      <para>
	This function computes the variant from the <filename>mathvariant</filename> style attribute. It simply checks if this attribute contains
	the string <filename>bold</filename> and the string <filename>italic</filename>. In the future, more styles have to be implemented.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>mathvariant</term>
	  <listitem>
	    <para>Value of the <filename>mathvariant</filename> attribute from an element.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns the variant: <filename>-Bold</filename>, <filename>-Italic</filename> or <filename>-Bold-Italic</filename>.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:getFontNameVariant">               
    <xsl:param name="mathvariant"/>
    
    <xsl:variable name="bold" select="if (matches($mathvariant, 'bold'))
				      then '-Bold'
				      else ''"/>
    <xsl:variable name="italic" select="if (matches($mathvariant, 'italic'))
					then '-Italic'
					else ''"/>

    <xsl:value-of select="concat($bold, $italic)"/>
  </xsl:function>

  <doc:function name="setStyle">
    <refpurpose>Computes a CSS style rule for an element with respect to all style attributes.</refpurpose>

    <refdescription>
      <para>
	This function computes the <acronym>CSS</acronym> style attribute. It checks if the <filename>mathvariant</filename> contains
	the string <filename>bold</filename> and the string <filename>italic</filename> and adds the correct <acronym>CSS</acronym> rules
	with respect to this verification. It also adds a <filename>fill</filename> rule to change the color of the drawed element width respect
	to the <filename>mathcolor</filename> pamareter.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>mathvariant</term>
	  <listitem>
	    <para>Value of the <filename>mathvariant</filename> attribute from an element.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>mathcolor</term>
	  <listitem>
	    <para>Value of the <filename>mathcolor</filename> attribute from an element.</para>
	  </listitem>
	</varlistentry>
	
	<varlistentry>
	  <term>mathbackground</term>
	  <listitem>
	    <para>Value of the <filename>mathbackground</filename> attribute from an element.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns the <acronym>CSS</acronym> style attribute for an element.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:setStyle">               
    <xsl:param name="mathvariant"/>
    <xsl:param name="mathcolor"/>
    <xsl:param name="mathbackground"/>
    
    <xsl:variable name="bold" select="if (matches($mathvariant, 'bold'))
				      then 'font-weight: bold; '
				      else ''"/>
    <xsl:variable name="italic" select="if (matches($mathvariant, 'italic'))
					then 'font-style: italic; '
					else ''"/>
    <xsl:variable name="color" select="concat('fill: ', $mathcolor, '; ')"/>
    <xsl:variable name="background" select="concat('background-color: ', $mathbackground, '; ')"/>

    <xsl:value-of select="concat($bold, $italic, $color, $background)"/>
  </xsl:function>

  <doc:function name="stringWidth">
    <refpurpose>Function that simply calls the stringWidth template.</refpurpose>

    <refdescription>
      <para>
	This function was created because, in some cases, it is more simple to call a function than a template. The <filename>stringWidth</filename> template 
	computes the width of a string with respect to the metrics files.	
      </para>
    </refdescription>

    <refsee>
      <para>stringWidth</para> template.
    </refsee>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>str</term>
	  <listitem>
	    <para>String to compute the width.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>fontName</term>
	  <listitem>
	    <para>List of fonts that will be used to render the string.</para>
	  </listitem>
	</varlistentry>
	
	<varlistentry>
	  <term>variant</term>
	  <listitem>
	    <para>Variant for the font.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns the value of the <filename>stringWidth</filename> template.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:stringWidth">
    <xsl:param name="str"/>
    <xsl:param name="fontName"/>
    <xsl:param name="variant"/>

    <xsl:call-template name="stringWidth">
      <xsl:with-param name="str" select="$str"/>
      <xsl:with-param name="strLen" select="string-length($str)"/>
      <xsl:with-param name="fontName" select="$fontName"/>
      <xsl:with-param name="variant" select="$variant"/>
    </xsl:call-template>
  </xsl:function>

  <!-- ####################################################################
       stringWidth :
       Additions the widths of the characters of the given string.
       str: String to compute witdh
       strLen: Size of the string
       i: Index of the current character to threat
       size: The summed size of the string character which index is lower 
             than i
       fontName: Name of the font used

       The recursion will always end because index i will reach strLen and
       I never call function recursion with same parameters as first call
       because index i is always incremented.
       #################################################################### -->
  <doc:template name="stringWidth">
    <refpurpose>Computes the width of a string (in em) using the font metrics files.</refpurpose>

    <refdescription>
      <para>
	It is a recursive function that sums the width of each character
	that composes the string. A correction is added to the top and to the bottom of the string. This correction is computed using
	the bounding box of, respectively, the first and the last character of the string. These two corrections are compute in the
	<filename>leftBearing</filename> and <filename>rightBearing</filename> variables.
      </para>

      <para>
	Note that the recursion will always end because the index <filename>i</filename> will finally reached <filename>strLen</filename>. Moreover,
	it is never recursively called with the same parameter values as the first call because the index <filename>i</filename> is 
	always incremented by one.
      </para>
    </refdescription>

    <refsee>
      <para><filename>stringWidth</filename> template.</para>
    </refsee>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>str</term>
	  <listitem>
	    <para>String to compute the width.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>strLen</term>
	  <listitem>
	    <para>Number of character in the string.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>i</term>
	  <listitem>
	    <para>Index of the character that is currently handled.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>size</term>
	  <listitem>
	    <para>This parameter is an accumulator that contains the size (in em) for the first <filename>i-1</filename> characters of the string.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>fontName</term>
	  <listitem>
	    <para>List of fonts that will be used to render the string.</para>
	  </listitem>
	</varlistentry>
	
	<varlistentry>
	  <term>variant</term>
	  <listitem>
	    <para>Variant for the font.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns the width of the string in em.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="stringWidth">
    <xsl:param name="str"/>
    <xsl:param name="strLen"/>
    <xsl:param name="i" select="1"/>
    <xsl:param name="size" select="0"/>
    <xsl:param name="fontName"/>
    <xsl:param name="variant" select="''"/>

    <xsl:choose>
      <xsl:when test="$i &lt;= $strLen">
	<xsl:variable name="letter" select="substring($str, $i, 1)"/>

	<xsl:variable name="letterSize">
	  <xsl:choose>
	    <!-- Space letter -->
	    <xsl:when test="$letter = '&#x0200A;'"> <!-- Very Thin Space -->
	      <xsl:value-of select="1 div 18"/>
	    </xsl:when>
	    <xsl:when test="$letter = '&#x02009;'">
	      <xsl:value-of select="3 div 18"/> <!-- Thin space -->
	    </xsl:when>
	    <xsl:when test="$letter = '&#x0205F;'">
	      <xsl:value-of select="4 div 18"/> <!-- Medium space -->
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:call-template name="findWidth">
		<xsl:with-param name="name" select="$letter"/>
		<xsl:with-param name="fonts" select="$fontName"/>
		<xsl:with-param name="variant" select="$variant"/>
	      </xsl:call-template>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<!-- Left correction for the width of the string -->
	<xsl:variable name="leftBearing">
	  <xsl:choose>
	    <xsl:when test="$i = 1">
	      <xsl:variable name="bbox" select="func:findBbox($letter, $fontName, $variant)"/>

	      <xsl:value-of select="max((0, -$bbox[1]))"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="0"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<!-- Right correction for the width of the string -->
	<xsl:variable name="rightBearing">
	  <xsl:choose>
	    <xsl:when test="$i = $strLen">
	      <xsl:variable name="bbox" select="func:findBbox($letter, $fontName, $variant)"/>

	      <xsl:value-of select="max((0, $bbox[2] - $letterSize))"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="0"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	
	<xsl:call-template name="stringWidth">
	  <xsl:with-param name="str" select="$str"/>
	  <xsl:with-param name="i" select="$i + 1"/>
	  <xsl:with-param name="strLen" select="$strLen"/>
	  <xsl:with-param name="size" select="$size + $letterSize + $leftBearing + $rightBearing"/>
	  <xsl:with-param name="fontName" select="$fontName"/>
	  <xsl:with-param name="variant" select="$variant"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$size"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- END OF FUNCTIONS -->


  <!-- ALL ELEMENTS THAT ARE NOT MATHML: SIMPLY COPY AND GO ON -->
  <xsl:template match="*[namespace-uri()!='http://www.w3.org/1998/Math/MathML']">
    <xsl:copy>
      <xsl:copy-of select="@*"/> <!-- could there be MML attributes attached to non-MML elements? -->
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       ROOT ELEMENT
       #################################################################### -->
  <doc:template match="math:math" id="rootElement">
    <refpurpose>Root element of the transformation.</refpurpose>

    <refdescription>
      <para>
	The root element is the starting point of the transformation. This template is called when a <filename>math</filename> element is found 
	in the document that is currently transformed. This template will call the two passes of the transformation. First, it will retrieve
	the annotated tree from the <filename>formatting</filename> mode by applying <filename>formatting</filename> mode template on the
	entire MathML tree. Then, it will retrieve the total width and height of the expression and writes the header of the <acronym>SVG</acronym>
	file. It will also write metadata information about the baseline. This information is used to shift the <acronym>SVG</acronym> picture
	when pMML2SVG is calling from an other stylesheet and when picture must be embedded into a text line. Finally, the root element will call 
	the <filename>drawing</filename> mode on the annotated tree to draw all element on the canevas.
      </para>

      <para>
	All elements follow the same scheme. In <filename>formatting</filename> mode, the font size is first computed, all attribute for the element 
	are retrieved. After that, the children elements are computed if necessary, then the box is created by computing all its attribute and finally 
	the tree node is annotated.
      </para>

      <para>
	In <filename>drawing</filename> mode, the <filename>X</filename> and <filename>Y</filename> coordinates of the box is first computed. Then, the 
	children are drawn if necessary (by calling their <filename>drawing</filename> mode) and, finally the elements of the box itself are added 
	on the canvas (fraction bar, boxes, etc.).
      </para>

      <para>
	The first element that is called in each transformation is the <filename>math</filename> element. This element is the root of each
	<acronym>MathML</acronym> equation.
      </para>
      
      <para>
	Each template in the <filename>formatting</filename> mode must take at least three parameters:
	<variablelist>
	  <varlistentry>
	    <term><filename>X, Y</filename></term>
	    <listitem>
	      <para>
		Represent the initial upper left corner of the box where the element will be drawn. If the baseline is not set, <filename>Y</filename>
		value is used to set a new baseline for the current element.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>BASELINE</filename></term>
	    <listitem>
	      <para>
		By default, this value is zero. It means that no baseline has been created and that the current element will decide where its
		baseline will be. In that case, the element will align its top edge on the initial <filename>Y</filename> value. If this parameter is set, 
		the element has to be aligned on this baseline.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>
      </para>

      <para>
	In the <filename>drawing</filename> mode, at least two paramaters are required:
	
	<variablelist>
	  <varlistentry>
	    <term><filename>xShift, yShift</filename></term>
	    <listitem>
	      <para>
		These values determine if the element has to be shifted to be correctly displayed. For example, when rendering a fraction. Both numerator and
		denominator will be aligned on the baseline by the formatting mode. Therefore, numerator has to be shifted to the top and denominator to the 
		bottom to find their final correct place. When drawing, numerator and denominator elements will receive shift values via these paramaters.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>
	
      </para>
    </refdescription>

    <refparameter>
      <para>
	Parameters can be retrieved through the tunnel: global parameters or style parameters. A tunnel is a way to forward parameters to
	all elements through the <acronym>XML</acronym> tree without sending them explicitly. It means that each template implicitly forwards these
	paramaters to all templates they call. Global parameters are set by default by the root template. All these values can be changed 
	if the stylesheet is called via another stylesheet. Some of them can also be changed by setting parameters when executing the 
	transformation with an <acronym>XSLT</acronym> processor. Here is a description of all global paramaters.
	
	<variablelist xml:id="globalParameters">
	  <title>Description of global parameters</title>
	  
	  <varlistentry>
	    <term><filename>svgMasterUnit</filename></term>
	    <listitem>
	      <para>
		Determines the default unit that will be used to render the <acronym>SVG</acronym> picture. The default unit is pixel (px).
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>initSize</filename></term>
	    <listitem>
	      <para>
		Determines the initial font size. This value cannot be changed by any <acronym>MathML</acronym> element. It can only be configured by setting it
		with the <acronym>XSLT</acronym> processor. This value can also be set by an external stylesheet that calls a <acronym>MathML</acronym> 
		to <acronym>SVG</acronym> transformation. For example, the stylesheet that transforms the equation into picture in the 
		<acronym>XSL-FO</acronym> code will set this value with respect to the current context. By default, the value of this parameter is 50.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>sizeMult</filename></term>
	    <listitem>
	      <para>
		<filename>sizeMult</filename> is a factor by which the font size has to be multiplied to render script element. This parameter
		works with <filename>scriptLevel</filename>. For example, if the script level is 5, you have to multiply the initial font size by
		<filename>sizeMult</filename> 5 times. This parameter can be set by a <filename>mstyle</filename> element. The default size multiplier
		is 0.71.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>scriptlevel</filename></term>
	    <listitem>
	      <para>
		Determines the number of times you will have to multiply the initial font size by <filename>sizeMult</filename> to render the current element.
		This parameter can be set by a <filename>mstyle</filename> element. The default script level is 0.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>displayStyle</filename></term>
	    <listitem>
	      <para>
		Determines the display scheme on some elements, for example, if display style is <filename>false</filename>, <filename>mover</filename>, 
		<filename>munder</filename> and <filename>munderover</filename> limit of summation or integral operators will be moved from top and bottom
		to right. This parameter can be set by a <filename>mstyle</filename> element. The default script level is <filename>true</filename>.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>minSize</filename></term>
	    <listitem>
	      <para>
		Determines the minimal font size. This parameter can be set by a <filename>mstyle</filename> element but it is not yet supported. By default,
		this value is 8.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>svgBorder</filename></term>
	    <listitem>
	      <para>
		Determines the size of the transparent border that surrounds the picture. By default, this value depends on <filename>initSize</filename>
		and is <filename>initSize</filename> div 5. This value will also set the initial <filename>X</filename> and <filename>Y</filename>
		coordinates to launch the transformation.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>rightSwitch</filename></term>
	    <listitem>
	      <para>
		Determines the size of the space between a base and its subscript or superscript. This parameter is used in <filename>msub</filename>,
		<filename>msup</filename> and <filename>msubsup</filename> elements. By default, this value depends on <filename>initSize</filename>
		and is <filename>initSize</filename> div 15.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>numDenSpace</filename></term>
	    <listitem>
	      <para>
		Determines the space between the numerator and the denominator. This parameter is used in <filename>mfrac</filename> element. By default, 
		this value depends on <filename>initSize</filename> and is <filename>initSize</filename> div 5.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>overUnderSpace</filename></term>
	    <listitem>
	      <para>
		Determines the size of the space between a base and its overscript or underscript. This parameter is used in <filename>munder</filename>,
		<filename>mover</filename> and <filename>munderover</filename> elements. By default, this value depends on <filename>initSize</filename>
		and is <filename>initSize</filename> div 10.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>tableSpace</filename></term>
	    <listitem>
	      <para>
		Determines the size of the space between two cells of a table. This parameter is used in <filename>mtable</filename>,
		<filename>mtd</filename> and <filename>mtr</filename> elements. By default, this value depends on <filename>initSize</filename>
		and is <filename>initSize</filename> div 2.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>fracWidMarg</filename></term>
	    <listitem>
	      <para>
		Determines the size of the fraction bar that outpasses the numerator or the denominator. This parameter is used in <filename>mfrac</filename>
		element. By default, this value depends on <filename>initSize</filename> and is <filename>initSize</filename> div 15.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>rtTopSpc</filename></term>
	    <listitem>
	      <para>
		Determines the size of the space over the base of a root to render the radical line. This parameter is used in <filename>msqrt</filename> and
		<filename>mroot</filename> elements. By default, this value depends on <filename>initSize</filename> and is 
		<filename>initSize</filename> div 6.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>rtFrnSpcFac</filename></term>
	    <listitem>
	      <para>
		Determines the size of the space before the base of a root to render the radical line. By default this value is 0.5.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>fontName</filename></term>
	    <listitem>
	      <para>
		Determines the fonts that will be used to render elements. This parameter is a list of fonts separated by a comma. By default, the font list 
		is <filename>STIXGeneral,STIXSizeOneSym</filename>. The way you can change this parameter is explained in the user guide.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>Math space parameters</filename></term>
	    <listitem>
	      <para>
		These parameters are used to determine the value of a space literal. The space literal can be used when a <acronym>MathML</acronym> attribute
		requires a horizontal measure. The default value for these parameters comes from the <acronym>MathML</acronym> specification. These values can 
		be changed with the <filename>mstyle</filename> element.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>

	Style tunnel parameters are used to implement the heritage of style. Currently, only <filename>mathvariant</filename>, <filename>mathcolor</filename>
	and <filename>mathbackground</filename> are implemented. Other style attributes are easy to add following the current scheme.
	
	<variablelist>
	  <title>Description of each style paramaters</title>
	  
	  <varlistentry>
	    <term><filename>mathvariant</filename></term>
	    <listitem>
	      <para>
		This attribute is partially supported and enables users to put the style in bold, italic or both. It also enables to change 
		the font used to render an element. This last functionnality is not yet supported.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>mathcolor</filename></term>
	    <listitem>
	      <para>
		Enables users to change the color of an element. This attribute is fully supported.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>mathbackground</filename></term>
	    <listitem>
	      <para>
		Enables users to change the background color of an element. Currently, this attribute does nothing because <acronym>SVG</acronym> element
		does not have background to color. To fully implement this attribute, we have to draw a colored rectangle that has the size
		of the element.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>
      </para>

      <para>
	All these tunnel parameters are forwarded to both formatting and drawing mode. They are available everywhere and can be modified by all elements. However, 
	this modification is only reflected on the children, it is a good way to implement the inherited style attributes.
      </para>
    </refparameter>
  </doc:template>
  <xsl:template match="math:math">
    <!-- PARAMETERS CONFIGURATION (tunnel param) -->
    <!-- The units' name of the svg image -->
    <xsl:param name="svgMasterUnit" select="$svgMasterUnit" tunnel="yes"/>

    <!-- Initial font size -->
    <xsl:param name="initSize" select="$initSize" tunnel="yes"/>
    
    <!-- Font size's reduction factor -->
    <xsl:param name="sizeMult" select="0.71" tunnel="yes"/>

    <!-- Minimum font size -->
    <xsl:param name="minSize" select="$minSize" tunnel="yes"/>

    <!-- SVG borders' width -->
    <xsl:param name="svgBorder" select="$initSize div 5" tunnel="yes"/>

    <!-- merror and menclose margin width -->
    <xsl:param name="errorMargin" select="$initSize div 10" tunnel="yes"/>

    <!-- Right switch factor (msup, msub, msubsup) -->
    <xsl:param name="rightSwitch" select="$initSize div 15" tunnel="yes"/>

    <!-- Space between numerator and denominator (mfrac) -->
    <xsl:param name="numDenSpace" select="$initSize div 5" tunnel="yes"/>

    <!-- Space between base and over(under)script (mover, munder, moverunder) -->
    <xsl:param name="overUnderSpace" select="$initSize div 10" tunnel="yes"/>

    <!-- Space between row and column in a mtable element -->
    <xsl:param name="tableSpace" select="$initSize div 2" tunnel="yes"/>

    <!-- Fractions' width margin (mfrac) -->
    <xsl:param name="fracWidMarg" select="$initSize div 15" tunnel="yes"/>

    <!-- Radical's top space (msqrt, mroot) -->
    <xsl:param name="rtTopSpc" select="$initSize div 6" tunnel="yes"/>

    <!-- Radical's front space factor (msqrt, mroot) -->
    <xsl:param name="rtFrnSpcFac" select="0.5" tunnel="yes"/>

    <!-- Principal font name -->
    <xsl:param name="fontName" select="$fontName" tunnel="yes"/>

    <!-- Script level: begin by default at 0: used to compute current 
	 font size of an element  -->
    <xsl:param name="scriptlevel" select="0" tunnel="yes"/>

    <!-- Display style is an mstyle attribute used to determine
	 the display of some element -->
    <xsl:param name="displayStyle" select="'true'" tunnel="yes"/>

    <!-- Space literal definition (size in em)
	 Can be modified by mstyle so placed in the argument tunnel
	 Value from : http://www.w3.org/TR/MathML2/chapter3.html#presm.mstyle -->
    <xsl:param name="veryverythinmathspace"  select="'0.055556em'" tunnel="yes"/>
    <xsl:param name="verythinmathspace"      select="'0.111111em'" tunnel="yes"/>
    <xsl:param name="thinmathspace"          select="'0.166667em'" tunnel="yes"/>
    <xsl:param name="mediummathspace"        select="'0.222222em'" tunnel="yes"/>
    <xsl:param name="thickmathspace"         select="'0.277778em'" tunnel="yes"/>
    <xsl:param name="verythickmathspace"     select="'0.333333em'" tunnel="yes"/>
    <xsl:param name="veryverythickmathspace" select="'0.388889em'" tunnel="yes"/>
    <!-- END OF PARAMETERS CONFIGURATION -->

    <!-- Compute normalized fonts sequence -->
    <xsl:variable name="fonts" select="tokenize(replace($fontName, '\s+', ''), ',')"/>

    <xsl:variable name="x" select="$svgBorder"/>
    <xsl:variable name="y" select="$svgBorder"/>

    <xsl:variable name="formattedTree">
      <xsl:apply-templates mode="formatting" select=".">
      	<xsl:with-param name="x" select="$x"/>
      	<xsl:with-param name="y" select="$y"/>
	<!-- Give parameters to tunnel -->
	<xsl:with-param name="svgMasterUnit" select="$svgMasterUnit" tunnel="yes"/>
	<xsl:with-param name="initSize" select="$initSize" tunnel="yes"/>
	<xsl:with-param name="sizeMult" select="$sizeMult" tunnel="yes"/>
	<xsl:with-param name="minSize" select="$minSize" tunnel="yes"/>
	<xsl:with-param name="svgBorder" select="$svgBorder" tunnel="yes"/>
	<xsl:with-param name="errorMargin" select="$errorMargin" tunnel="yes"/>
	<xsl:with-param name="rightSwitch" select="$rightSwitch" tunnel="yes"/>
	<xsl:with-param name="numDenSpace" select="$numDenSpace" tunnel="yes"/>
	<xsl:with-param name="overUnderSpace" select="$overUnderSpace" tunnel="yes"/>
	<xsl:with-param name="tableSpace" select="$tableSpace" tunnel="yes"/>
	<xsl:with-param name="fracWidMarg" select="$fracWidMarg" tunnel="yes"/>
	<xsl:with-param name="rtTopSpc" select="$rtTopSpc" tunnel="yes"/>
	<xsl:with-param name="rtFrnSpcFac" select="$rtFrnSpcFac" tunnel="yes"/>
	<xsl:with-param name="fontName" select="$fonts" tunnel="yes"/>
	<xsl:with-param name="scriptlevel" select="$scriptlevel" tunnel="yes"/>
	<xsl:with-param name="displayStyle" select="$displayStyle" tunnel="yes"/>
	<!-- Space literals -->
	<xsl:with-param name="veryverythinmathspace"  select="$veryverythinmathspace"  tunnel="yes"/>
	<xsl:with-param name="verythinmathspace"      select="$verythinmathspace"      tunnel="yes"/>
	<xsl:with-param name="thinmathspace"          select="$thinmathspace"          tunnel="yes"/>
	<xsl:with-param name="mediummathspace"        select="$mediummathspace"        tunnel="yes"/>
	<xsl:with-param name="thickmathspace"         select="$thickmathspace"         tunnel="yes"/>
	<xsl:with-param name="verythickmathspace"     select="$verythickmathspace"     tunnel="yes"/>
	<xsl:with-param name="veryverythickmathspace" select="$veryverythickmathspace" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="svgWidth"
		  select="$formattedTree/*/@t:WIDTH + (2 * $svgBorder)"/>
    <xsl:variable name="svgHeight"
		  select="$formattedTree/*/@t:HEIGHT + (2 * $svgBorder)"/>

    <svg version="1.1"
      width="{$svgWidth}{$svgMasterUnit}"
      height="{$svgHeight}{$svgMasterUnit}"
      viewBox="0 0 {$svgWidth} {$svgHeight}"
      xmlns:pmml2svg="https://sourceforge.net/projects/pmml2svg/">
      
      <metadata>
	<pmml2svg:baseline-shift>
	  <xsl:value-of select="$svgHeight - $formattedTree/*/@t:BASELINE"/>
	</pmml2svg:baseline-shift>
      </metadata>

      <g stroke="none" fill="#000000" text-rendering="optimizeLegibility" font-family="{string-join($fontName, ', ')}">
      	<xsl:apply-templates select="$formattedTree/*" mode="draw">
      	  <xsl:with-param name="xShift" select="0"/>
      	  <xsl:with-param name="yShift" select="0"/>
	  <!-- Give parameters to tunnel -->
	  <xsl:with-param name="svgMasterUnit" select="$svgMasterUnit" tunnel="yes"/>
	  <xsl:with-param name="initSize" select="$initSize" tunnel="yes"/>
	  <xsl:with-param name="sizeMult" select="$sizeMult" tunnel="yes"/>
	  <xsl:with-param name="minSize" select="$minSize" tunnel="yes"/>
	  <xsl:with-param name="svgBorder" select="$svgBorder" tunnel="yes"/>
	  <xsl:with-param name="errorMargin" select="$errorMargin" tunnel="yes"/>
	  <xsl:with-param name="rightSwitch" select="$rightSwitch" tunnel="yes"/>
	  <xsl:with-param name="numDenSpace" select="$numDenSpace" tunnel="yes"/>
	  <xsl:with-param name="overUnderSpace" select="$overUnderSpace" tunnel="yes"/>
	  <xsl:with-param name="tableSpace" select="$tableSpace" tunnel="yes"/>
	  <xsl:with-param name="fracWidMarg" select="$fracWidMarg" tunnel="yes"/>
	  <xsl:with-param name="rtTopSpc" select="$rtTopSpc" tunnel="yes"/>
	  <xsl:with-param name="rtFrnSpcFac" select="$rtFrnSpcFac" tunnel="yes"/>
	  <xsl:with-param name="fontName" select="$fonts" tunnel="yes"/>
	  <xsl:with-param name="scriptlevel" select="$scriptlevel" tunnel="yes"/>
	  <xsl:with-param name="displayStyle" select="$displayStyle" tunnel="yes"/>
	  <!-- Space literals -->
	  <xsl:with-param name="veryverythinmathspace"  select="$veryverythinmathspace"  tunnel="yes"/>
	  <xsl:with-param name="verythinmathspace"      select="$verythinmathspace"      tunnel="yes"/>
	  <xsl:with-param name="thinmathspace"          select="$thinmathspace"          tunnel="yes"/>
	  <xsl:with-param name="mediummathspace"        select="$mediummathspace"        tunnel="yes"/>
	  <xsl:with-param name="thickmathspace"         select="$thickmathspace"         tunnel="yes"/>
	  <xsl:with-param name="verythickmathspace"     select="$verythickmathspace"     tunnel="yes"/>
	  <xsl:with-param name="veryverythickmathspace" select="$veryverythickmathspace" tunnel="yes"/>
      	</xsl:apply-templates>
      </g>
    </svg>
  </xsl:template>
</xsl:stylesheet>
