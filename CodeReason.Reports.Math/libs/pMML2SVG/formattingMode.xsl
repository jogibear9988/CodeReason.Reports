<?xml version="1.0"?>
<!-- 
###############################################################################
$Id: formattingMode.xsl 154 2009-05-12 14:59:29Z jjoslet $

CREATED: JUNE 2005

AUTHORS: [AST] Alexandre Stevens (alex@dourfestival.be) {STUDENT}
         [JHP] Justus H. Piater (Justus.Piater@ULg.ac.be) {PhD}
         [TMO] Thibault Mouton (Thibault.Mouton@student.ULg.ac.be) {STUDENT}
	 [JJO] Jerome Joslet (Jerome.Joslet@student.ULg.ac.be) {STUDENT}
         Montefiore Institute - University of Liege - Belgium
         
         [STM] Manuel Strehl {STUDENT}
         University of Regensburg - Germany

DESCRIPTION: This stylesheet contain all formatting template mode for pMML2SVG


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
<xsl:stylesheet version="2.0"
		xmlns:doc="http://nwalsh.com/xsl/documentation/1.0"
		xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
		xmlns:math="http://www.w3.org/1998/Math/MathML"
		xmlns:xs="http://www.w3.org/2001/XMLSchema"
		xmlns="http://www.w3.org/2000/svg"
		xmlns:t="http://localhost/tmp"
		xmlns:func="http://localhost/functions"
		xmlns:dict="http://localhost/operator-dictionary"
		exclude-result-prefixes="math t xs func doc">

  <doc:reference>
    <info>
      <title>Formatting mode</title>
    </info>
  </doc:reference>


  <!-- ####################################################################
       TOKENS : mi, mn, mtext, ms (formatting mode)
       #################################################################### -->
  <doc:template match="math:mi|math:mn|math:mtext|math:ms" mode="formatting">
    <refpurpose>Formatting a token element.</refpurpose>

    <refdescription>
      <para>
	All these elements are treated the same way with a few exceptions. Therefore, in the implemented stylesheet, they share the same template, both 
	for formatting and for drawing. These elements are the leaf of the <acronym>MathML</acronym> tree, they do not have any children, they only contain 
	text.
      </para>

      <para>
	After computing the font size of these elements, the <filename>ms</filename> <filename>lquote</filename> and <filename>rquote</filename>
	attributes are retrieved. These attributes determine which symbol will be used to surround the text, respectively, on the left and on the right. 
	After that, the text content of the element is retrieved. <filename>lquote</filename> is added before the first character and <filename>rquote</filename>
	after the last one if the element is <filename>ms</filename>.
      </para>
      
      <para>
	Next, the font variant is computed to retrieve the width and the height of the text. An <filename>mi</filename> element with one letter 
	(except infinity symbol) has to be displayed in italic, so the font variant is computed using that particularities. All the parameters of the box 
	can now be computed: the height is given by font metrics file, the width is computed using the <filename>stringWidth</filename> function and 
	the baseline is set on the bottom of the text with descender stretching under it. The box also contains an other measure: 
	<filename>HEIGHTOVERBASELINE</filename> which is the height of the box from its baseline to its top edge. Here is a figure that represent the box 
	for a token element:
	
	<figure>
	  <title>Box for a token element</title>
	  
	  <mediaobject>
	    <imageobject><imagedata align="center" fileref="figures/tokensBaseline.svg" format="SVG"/></imageobject>
	  </mediaobject>
	</figure>
      </para>

      <para>
	The left bearing of the box is computed to shift the character inside the box. If no bearing is computed, some characters are drawn outside
	the box. For exemple, the left part of an italic <command>f</command> goes out of the left side of the box if no shift value is added by using
	the left bearing. The right bearing is computed to place the subscript closer to some characters. In the case of an italic <command>f</command>,
	if the subscript is placed after the letter box, it will be too far away from <command>f</command>. If the right bearing is withdrawn from
	the coordinates of the right side of the box, the subscript will be drawn closer.
      </para>

      <para>
	Finally, the tree node is annotated with the box representation and with style (attributes <filename>STYLE</filename>) information about the box.
	A shift value (<filename>SHIFTX</filename>) is also added when the token has a left bearing. The left bearing is a negative value from the left value of
	the first character bounding box. It occurs, for example, with an italic <command>f</command>.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mi|math:mn|math:mtext|math:ms" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters -->
    <xsl:param name="fontName" tunnel="yes"/>
    <xsl:param name="scriptlevel" tunnel="yes"/>
    <!-- Style -->
    <xsl:param name="mathvariant" tunnel="yes"/>
    <xsl:param name="mathcolor" tunnel="yes"/>
    <xsl:param name="mathbackground" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <!-- ms : Retrieve left quote, default is " -->    
    <xsl:variable name="lquote">
      <xsl:choose>
	<xsl:when test="@lquote">
	  <xsl:value-of select="normalize-space(@lquote)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>&quot;</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- ms : Retrieve right quote, default is " -->    
    <xsl:variable name="rquote">
      <xsl:choose>
	<xsl:when test="@rquote">
	  <xsl:value-of select="normalize-space(@rquote)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:text>&quot;</xsl:text>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="str">
      <xsl:choose>
	<xsl:when test="local-name(.) = 'ms'">
	  <xsl:value-of select="concat($lquote, normalize-space(text()), $rquote)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="normalize-space(text())"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="strLen">
      <xsl:value-of select="string-length($str)"/>
    </xsl:variable>

    <!-- Default mathvariant is normal except for mi 
	 with one letter which is italic (except infinite character) -->
    <xsl:variable name="defaultmathvariant">
      <xsl:choose>
	<xsl:when test="local-name(.) = 'mi' and $strLen = 1 and $str != '&#8734;'">
	  <xsl:value-of select="'italic'"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="'normal'"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Set font name variant -->
    <xsl:variable name="bestMathVariant" select="func:chooseAttribute(@mathvariant, $mathvariant, $defaultmathvariant)"/>
    <xsl:variable name="fontNameVariant" select="func:getFontNameVariant($bestMathVariant)"/>

    <!-- Retrieve max height and min depth of string -->
    <xsl:variable name="bbox" select="func:findHeight($str, $fontName, $fontNameVariant)"/>
    <xsl:variable name="height" select="$size * ($bbox[1] - $bbox[2])"/>
    <xsl:variable name="heightOverBaseline" select="$size * $bbox[1]"/>

    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y + $heightOverBaseline"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline - $heightOverBaseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Compute string size based on metrics files -->
    <xsl:variable name="strSize">
      <xsl:call-template name="stringWidth">
	<xsl:with-param name="str" select="$str"/>
	<xsl:with-param name="strLen" select="$strLen"/>
	<xsl:with-param name="fontName" select="$fontName"/>
	<xsl:with-param name="variant" select="$fontNameVariant"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Left correction for the position of the string -->
    <xsl:variable name="firstCharBBox" select="func:findBbox(substring($str, 1, 1), $fontName, $fontNameVariant)"/>
    <xsl:variable name="leftBearing" select="max((0, -$firstCharBBox[1])) * $size"/>

    <!-- Right bearing for the substring positionning -->
    <xsl:variable name="lastCharBBox" select="func:findBbox(substring($str, $strLen, 1), $fontName, $fontNameVariant)"/>
    <xsl:variable name="lastCharSize">
      <xsl:call-template name="findWidth">
	<xsl:with-param name="name" select="substring($str, $strLen, 1)"/>
	<xsl:with-param name="fonts" select="$fontName"/>
	<xsl:with-param name="variant" select="$fontNameVariant"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="rightBearing" select="max((0, $lastCharBBox[2] - $lastCharSize)) * $size"/>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:SHIFTX" select="$leftBearing"/>
      <xsl:attribute name="t:RIGHTBEARING" select="$rightBearing"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="$strSize * $size"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:HEIGHTOVERBASELINE" select="$heightOverBaseline"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <xsl:attribute name="t:TEXT" select="$str"/>
      <xsl:attribute name="t:STYLE" select="func:setStyle(
					       $bestMathVariant, 
					       func:chooseAttribute(@mathcolor, $mathcolor, 'black'),
					       func:chooseAttribute(@mathbackground, $mathbackground, 'transparent'))"/>
      <xsl:attribute name="t:VARIANT" select="$fontNameVariant"/>

      <xsl:value-of select="$str"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       TOKEN : mspace (formatting)
       #################################################################### -->
  <doc:template match="math:mspace" mode="formatting">
    <refpurpose>Formatting a space.</refpurpose>

    <refdescription>
      <para>
	<filename>mspace</filename> follows the general scheme. After computing the font size, all attributes are retrieved and computed in 
	pixel. The box representation is computed and the tree is annotated with these values.
      </para>
    </refdescription>

    <refparameter>
      <para>
	This element, that represents a space, has three attributes that determine its size:
	
	<variablelist>
	  <varlistentry>
	    <term><filename>width</filename></term>
	    <listitem>
	      <para>
		Determines the width of the space.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>height</filename></term>
	    <listitem>
	      <para>
		Determines the size of the box over the baseline.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>depth</filename></term>
	    <listitem>
	      <para>
		Determines the size of the box under the baseline.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>
      </para>
    </refparameter>
  </doc:template>
  <xsl:template match="math:mspace" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <!-- Retrieve width attribute -->
    <xsl:variable name="width">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@width">
	  <xsl:value-of select="@width"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="0"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Retrieve height attribute -->
    <xsl:variable name="height">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@height">
	  <xsl:value-of select="@height"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="0"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Retrieve depth attribute -->
    <xsl:variable name="depth">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@depth">
	  <xsl:value-of select="@depth"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="0"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="widthPx">
      <xsl:call-template name="unitInPx">
	<xsl:with-param name="valueUnit" select="$width"/>
	<xsl:with-param name="fontSize" select="$size"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="heightPx">
      <xsl:call-template name="unitInPx">
	<xsl:with-param name="valueUnit" select="$height"/>
	<xsl:with-param name="fontSize" select="$size"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="depthPx">
      <xsl:call-template name="unitInPx">
	<xsl:with-param name="valueUnit" select="$depth"/>
	<xsl:with-param name="fontSize" select="$size"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y + $heightPx"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline - $heightPx"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
   
    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="$widthPx"/>
      <xsl:attribute name="t:HEIGHT" select="$heightPx + $depthPx"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       TOKEN : mo (formatting mode)
       #################################################################### -->
  <!-- Normal formatting mode -->
  <doc:template match="math:mo[not(@t:stretchVertical) or @t:stretchVertical != true()]" 
		mode="formatting">
    <refpurpose>Formatting an operator.</refpurpose>

    <refsee>
      Variables <filename>delimPart</filename> and <filename>delimScale</filename>. Function <filename>chooseEntry</filename>.
    </refsee>

    <refdescription>
      <para>
	It is one of the most complex elements to render. It has a lot of attributes that determine many different ways to
	display it. The default behaviour of operators is contained in a dictionary called <filename>operator dictionary</filename>. This dictionary,
	coming from the specification<footnote><para><uri>http://www.w3.org/TR/2003/REC-MathML2-20031021/appendixf.html</uri></para></footnote>, is 
	implemented in the file <filename>operator-dictionary.xml</filename>. It has been implemented in <acronym>XML</acronym> to 
	make access easier using XPath. Modifications have been done to add useful information for our renderer and to add new characters.
	Characters <filename>Prime</filename> and <filename>Times</filename> have been added to the dictionary to facilitate the rendering of these 
	elements. New attributes have also been added:
	
	<variablelist>
	  <varlistentry>
	    <term><filename>stretchHorizontal</filename></term>
	    <listitem>
	      <para>
		If an operator has to stretch, this attributes tells our renderer that it will stretch horizontally.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>stretchVertical</filename></term>
	    <listitem>
	      <para>
		If an operator has to stretch, this attributes tells our renderer that it will stretch vertically.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>

	These two attributes can be both set to true. In this case, the operator has to stretch vertically and horizontally. None of these operators
	will be stretched in the current version of pMML2SVG.
      </para>

      <para>
	The formatting mode for a <filename>mo</filename> element has two different behaviours. The first one is the normal mode that
	annotate the tree like the other elements. The second is used to correct the annotation of the tree when the operator has
	to be stretched vertically.
      </para>
      
      <para>
	The specification tells us that such an operator should have the size of the biggest non-stretchy element present in the 
	same row of it. Therefore, when an operator has to be stretched, the bottom and the top <filename>Y</filename> 
	of this big element have to be known to compute the final size of the stretched operator. When the second mode is called, these two values are
	retrieved by the following template paramaters: <filename>upperY</filename> and <filename>lowerY</filename>. The way these values are
	computed and how this second template mode is called is explained in detail in the <filename>alignChild</filename> template.
      </para>

      <para>
	This template is the normal mode, the correcting mode takes part in another template that is exmplained further.
      </para>

      <para>
	First of all, all attribute values of the operator are retrieved. To determine the default behaviour of these values, the operator 
	dictionary entries for this operator are retrieved. It is done by using XPath and the <filename>document</filename>
	function. This function is used to browse an external file. After that, the best operator dictionary entry is chosen with
	respect to the number of entries and the <filename>form</filename> attribute. If there is only one entry, this entry is chosen.
	If there is more than one entry, a default <filename>form</filename> attribute has to be computed. The rules to determine it
	are:
	<itemizedlist>
	  <listitem>
	    <para>
	      If the operator is a member of a row, if there is more than one element in this row (excluding <filename>mspace</filename>)
	      and if this operator is the first element in the row (excluding <filename>mspace</filename>), the <filename>form</filename>
	      attribute is <filename>prefix</filename>
	    </para>
	  </listitem>

	  <listitem>
	    <para>
	      If the operator is a member of a row, if there is more than one element in this row (excluding <filename>mspace</filename>
	      and if this operator is the last element in the row (excluding <filename>mspace</filename>), the <filename>form</filename>
	      attribute is <filename>postfix</filename>
	    </para>
	  </listitem>

	  <listitem>
	    <para>
	      In all other cases, the <filename>form</filename> attribute is <filename>infix</filename>.
	    </para>
	  </listitem>
	</itemizedlist>

	If there is an entry with this <filename>form</filename> attribute value, this entry will be chosen. If not, an entry
	will be chosen with preference to <filename>infix</filename> <filename>form</filename> attribute value, then 
	<filename>postfix</filename> and finally <filename>prefix</filename>. This choosing rule is implemented in the
	function <filename>chooseEntry</filename>.
      </para>

      <para>
	After choosing an entry, all other attributes will be finally retrieved. The value will be the user's specified one, 
	if it exists, then, the value from the operator dictionary and finally a default value from the specification. The following
	attribute is retrieved:
	
	<variablelist>
	  <varlistentry>
	    <term><filename>lspace, rspace</filename></term>
	    <listitem>
	      <para>
		Determine the space around the operator, respectively, on the left and on the right. Default value is 
		<filename>thickmathspace</filename>.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>stretchy</filename></term>
	    <listitem>
	      <para>
		Determines if an operator has to be stretched. Default value is <filename>false</filename>. If this value is 
		<filename>true</filename>, <filename>stretchHorizontal</filename> and <filename>stretchVertical</filename> variables
		are retrieved from the dictionary, if it is possible. In all other cases, these two last values are set to
		<filename>false</filename>. These variables are specific to pMML2SVG renderer.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>symmetric</filename></term>
	    <listitem>
	      <para>
		Determines if the operator will be stretched symmetrically. The default value is <filename>true</filename>.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>maxsize, minsize</filename></term>
	    <listitem>
	      <para>
		Determine, respectively, the maximum and minimum size of an operator. These two attributes are used to control the
		stretching of the operator. The default value is, respectively, <filename>infinity</filename> and <filename>1</filename>.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>largeop</filename></term>
	    <listitem>
	      <para>
		Determines if the operator is a large operator such as integral, summation, etc. The default value is <filename>false</filename>.
		If <filename>displayStyle</filename> values, from tunnel, and if <filename>largeop</filename> are <filename>true</filename>,
		then the operator will be rendered with higher font size. Typically, the <filename>scriptlevel</filename> to render
		this operator will decrease by one.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>movablelimits</filename></term>
	    <listitem>
	      <para>
		Determines if the limit under or above an operator (such as integral, summation, etc.) can be moved and be rendered 
		on the left of the operator instead of under or above. The default value is <filename>false</filename>. This attribute 
		is not yet used in pMML2SVG.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>accent</filename></term>
	    <listitem>
	      <para>
		Determines if an operator must behave like an accent. The default value is <filename>false</filename>. This attribute
		is used to correct the vertical position of accent operator such as circumflex accent, etc.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>
      </para>

      <para>
	After all attributes have been retrieved, the font size for the box is computed. The font size has to be bigger if the <filename>largeop</filename>
	attribute is <filename>true</filename>. Therefore, the <filename>scriptlevel</filename> value is decremented by one in this case. Otherwise,
	the font size is computed normally.
      </para>

      <para>
	Some operators have to be replaced by similar glyphes to be retrieved in the font metrics. It is the case with the under (and over) brackets.
      </para>

      <para>
	After that, a correction is computed if the operator is an <filename>accent</filename>. This correction includes the computation of the height
	of each glyph part that compose the operator if this last has to be stretched. It is done by retrieving the bouding box of each part of the
	composed operator. This correction is necessary since the parts that compose an operator have a higher height than the non-composed operator.
      </para>

      <para>
	The left and right bearings are also computed the same way as in other tokens. They have the same behaviour as in others tokens.
      </para>

      <para>
	The box size and position is then computed and the computation in pixel of <filename>minsize</filename>, 
	<filename>maxsize</filename>, <filename>lspace</filename> and <filename>rspace</filename> is done. 
      </para>
      
      <para>
	Finally, the tree node is annotated with box information, stretchy information
	(<filename>STRETCHY</filename>, <filename>stretchHorizontal</filename> and <filename>stretchVertical</filename> attributes),
	<filename>minsize</filename> and <filename>maxsize</filename> (in pixel) that will be used when the operator will be corrected 
	to stretch, <filename>lspace</filename> and <filename>rspace</filename> (in pixel), <filename>EMBELLISH</filename> information, 
	style information, <filename>SYMMETRIC</filename> information that will be used when the operator will be corrected to stretch and
	a shift value (<filename>ACCENTSHIFT</filename>) that is used to correct the vertical position of an accent.
      </para>

      <para>
	The <filename>EMBELLISH</filename> information is used to know where to add <filename>lspace</filename> and <filename>rspace</filename>.
	The specification tells us what an embellished operator is:

	<itemizedlist xml:id="embellishedOperator">
	  <title>Embellished operator definition</title>

	  <listitem>
	    <para>
	      An <filename>mo</filename> element.
	    </para>
	  </listitem>

	  <listitem>
	    <para>
	      One of the elements <filename>msub</filename>, <filename>msup</filename>, <filename>msubsup</filename>, <filename>munder</filename>, 
	      <filename>mover</filename>, <filename>munderover</filename>, <filename>mmultiscripts</filename>, or <filename>mfrac</filename>  
	      whose first argument exists and is an embellished operator.
	    </para>
	  </listitem>

	  <listitem>
	    <para>
	      A row whose arguments consist (in any order) of one embellished operator and zero or more space-like elements.
	    </para>
	  </listitem>
	</itemizedlist>

	Adjustements have to be done when an embellished operator is computed. For example, if an <filename>munder</filename> element
	is an embellished operator, the space determined by <filename>lspace</filename> and <filename>rspace</filename> has to be placed 
	around this <filename>munder</filename> element and not around its first <filename>mo</filename> child.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mo[not(@t:stretchVertical) or @t:stretchVertical != true()]" 
		mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="fontName" tunnel="yes"/>
    <xsl:param name="scriptlevel" tunnel="yes"/>
    <xsl:param name="displayStyle" tunnel="yes"/>
    <!-- Style -->
    <xsl:param name="mathvariant" tunnel="yes"/>
    <xsl:param name="mathcolor" tunnel="yes"/>
    <xsl:param name="mathbackground" tunnel="yes"/>
    <!-- Space literals -->
    <xsl:param name="thickmathspace" tunnel="yes"/>

    <!-- Set font name variant -->
    <xsl:variable name="bestMathVariant" select="func:chooseAttribute(@mathvariant, $mathvariant, 'normal')"/>
    <xsl:variable name="fontNameVariant" select="func:getFontNameVariant($bestMathVariant)"/>

    <!-- Retrieve operator -->
    <xsl:variable name="operator">
      <xsl:value-of select="normalize-space(text())"/>
    </xsl:variable>
    
    <!-- Retrieve all operator entries from operator dictionary -->
    <xsl:variable name="opEntries" select="document('operator-dictionary.xml')/dict:operators/dict:mo[@op = $operator]"/>
    
    <xsl:variable name="defaultAttributes">
      <xsl:choose>
	<!-- No entry -->
	<xsl:when test="count($opEntries) = 0">
	  <xsl:text/> <!-- Default values are static, see below when I retrieve attributes -->
	</xsl:when>
	<!-- If there is one entry in dictionary, choose that entry -->
	<xsl:when test="count($opEntries) = 1">
	  <xsl:copy-of select="$opEntries"/>
	</xsl:when>
	<!-- Else retrieve form value with rules -->
	<xsl:otherwise>
	  <xsl:variable name="form">
	    <xsl:choose>
	      <!-- User specified -->
	      <xsl:when test="@form">
		<xsl:value-of select="@form"/>
	      </xsl:when>
	      <!-- Implement rule to determine default form value
		   SEE : http://www.w3.org/TR/MathML2/chapter3.html#presm.mo -->
	      <xsl:otherwise>
		<!-- First test : mo is in mrow -->
		<xsl:variable name="inmrow" select="index-of($rowElement, local-name(parent::*)) &gt;= 0"/>
		<!-- Second test : number of element (excluding mspace) in row is greater than 1 -->
		<xsl:variable name="numinmrow" select="count(parent::*/*[local-name() != 'mspace']) &gt; 1"/>
		<xsl:choose>
		  <!-- Rule 1 : prefix if mo is the first element mrow -->
		  <xsl:when test="$inmrow and $numinmrow and count(preceding-sibling::*[local-name() != 'mspace']) = 0">
		    <xsl:text>prefix</xsl:text>
		  </xsl:when>
		  <!-- Rule 2 : postfix if mo is the last element in mrow -->
		  <xsl:when test="$inmrow and $numinmrow and count(following-sibling::*[local-name() != 'mspace']) = 0">
		    <xsl:text>postfix</xsl:text>
		  </xsl:when>
		  <!-- Rule 3 : infix in all other case -->
		  <xsl:otherwise>
		    <xsl:text>infix</xsl:text>
		  </xsl:otherwise>
		</xsl:choose>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>
	  
	  <xsl:variable name="orderedSequence" select="('infix', 'postfix', 'prefix')"/>
	  <xsl:copy-of select="func:chooseEntry(insert-before(remove($orderedSequence, index-of($orderedSequence, $form)), 0, $form), $opEntries)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Retrieve fence attribute 
	 Not used to render operator -->
    <!--<xsl:variable name="fence">
	<xsl:choose>
	<xsl:when test="@fence">
	<xsl:value-of select="@fence"/>
	</xsl:when>
	<xsl:when test="$defaultAttributes/dict:mo/@fence">
	<xsl:value-of select="$defaultAttributes/dict:mo/@fence"/>
	</xsl:when>
	<xsl:otherwise>
	<xsl:value-of select="false()"/>
	</xsl:otherwise>
	</xsl:choose>
	</xsl:variable>-->
    
    <!-- Retrieve separator attribute -->
    <!--<xsl:variable name="separator">
	<xsl:choose>
	<xsl:when test="@separator">
	<xsl:value-of select="@separator"/>
	</xsl:when>
	<xsl:when test="$defaultAttributes/dict:mo/@separator">
	<xsl:value-of select="$defaultAttributes/dict:mo/@separator"/>
	</xsl:when>
	<xsl:otherwise>
	<xsl:value-of select="false()"/>
	</xsl:otherwise>
	</xsl:choose>
	</xsl:variable>-->
    
    <!-- Retrieve lspace attribute -->
    <xsl:variable name="lspace">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@lspace">
	  <xsl:value-of select="@lspace"/>
	</xsl:when>
	<!-- Dictionary -->
	<xsl:when test="$defaultAttributes/dict:mo/@lspace">
	  <xsl:value-of select="$defaultAttributes/dict:mo/@lspace"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="$thickmathspace"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Retrieve rspace attribute -->
    <xsl:variable name="rspace">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@rspace">
	  <xsl:value-of select="@rspace"/>
	</xsl:when>
	<!-- Dictionary -->
	<xsl:when test="$defaultAttributes/dict:mo/@rspace">
	  <xsl:value-of select="$defaultAttributes/dict:mo/@rspace"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="$thickmathspace"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Retrieve stretchy attribute -->
    <xsl:variable name="stretchy">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@stretchy">
	  <xsl:value-of select="@stretchy"/>
	</xsl:when>
	<!-- Dictionary -->
	<xsl:when test="$defaultAttributes/dict:mo/@stretchy">
	  <xsl:value-of select="$defaultAttributes/dict:mo/@stretchy"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="false()"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Retrieve stretch horizontal attribute (Specific to this renderer) -->
    <xsl:variable name="stretchHorizontal">
      <xsl:choose>
	<!-- Added to dictionary -->
	<xsl:when test="$stretchy = true() and $defaultAttributes/dict:mo/@stretchHorizontal">
	  <xsl:value-of select="$defaultAttributes/dict:mo/@stretchHorizontal"/>
	</xsl:when>
	<!-- Default value -->
	<xsl:otherwise>
	  <xsl:value-of select="false()"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Retrieve stretch vertical attribute (Specific to this renderer) -->
    <xsl:variable name="stretchVertical">
      <xsl:choose>
	<!-- Added to dictionary -->
	<xsl:when test="$stretchy = true() and $defaultAttributes/dict:mo/@stretchVertical">
	  <xsl:value-of select="$defaultAttributes/dict:mo/@stretchVertical"/>
	</xsl:when>
	<!-- Default value -->
	<xsl:otherwise>
	  <xsl:value-of select="false()"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Retrieve symmetric attribute -->
    <xsl:variable name="symmetric">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@symmetric">
	  <xsl:value-of select="@symmetric"/>
	</xsl:when>
	<!-- Dictionary -->
	<xsl:when test="$defaultAttributes/dict:mo/@symmetric">
	  <xsl:value-of select="$defaultAttributes/dict:mo/@symmetric"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="true()"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Retrieve maxsize attribute -->
    <xsl:variable name="maxsize">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@maxsize">
	  <xsl:value-of select="@maxsize"/>
	</xsl:when>
	<!-- Dictionary -->
	<xsl:when test="$defaultAttributes/dict:mo/@maxsize">
	  <xsl:value-of select="$defaultAttributes/dict:mo/@maxsize"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="'infinity'"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Retrieve minsize attribute -->
    <xsl:variable name="minsize">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@minsize">
	  <xsl:value-of select="@minsize"/>
	</xsl:when>
	<!-- Dictionary -->
	<xsl:when test="$defaultAttributes/dict:mo/@minsize">
	  <xsl:value-of select="$defaultAttributes/dict:mo/@minsize"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="1"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    
    <!-- Retrieve largeop attribute -->
    <xsl:variable name="largeop">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@largeop">
	  <xsl:value-of select="@largeop"/>
	</xsl:when>
	<!-- Dictionary -->
	<xsl:when test="$defaultAttributes/dict:mo/@largeop">
	  <xsl:value-of select="$defaultAttributes/dict:mo/@largeop"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="false()"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Retrieve movablelimits attribute -->
    <xsl:variable name="movablelimits">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@movablelimits">
	  <xsl:value-of select="@movablelimits"/>
	</xsl:when>
	<!-- Dictionary -->
	<xsl:when test="$defaultAttributes/dict:mo/@movablelimits">
	  <xsl:value-of select="$defaultAttributes/dict:mo/@movablelimits"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="false()"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Retrieve accent attribute -->
    <xsl:variable name="accent">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@accent">
	  <xsl:value-of select="@accent"/>
	</xsl:when>
	<!-- Dictionary -->
	<xsl:when test="$defaultAttributes/dict:mo/@accent">
	  <xsl:value-of select="$defaultAttributes/dict:mo/@accent"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="false()"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- End of attributes retrieving -->

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize">
	<!-- Large operator correction of size -->
	<xsl:with-param name="scriptlevel" tunnel="yes" select="if ($largeop = true() and $displayStyle = 'true')
								then $scriptlevel - 1
								else $scriptlevel"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Replace some operators with other one 
	 &#65077; -> &#9180;
	 &#65078; -> &#9181;
	 &#65079; -> &#9182;
	 &#65080; -> &#9183;
    -->
    <xsl:variable name="newOperator" select="translate($operator, '&#65077;&#65078;&#65079;&#65080;', '&#9180;&#9181;&#9182;&#9183;')"/>

    <!-- Accent correction shifting -->
    <xsl:variable name="bbox" as="xs:double+">
      <xsl:choose> 
	<xsl:when test="(count($delimPart/*[@hname=$newOperator]/*) &gt; 0)">
	  <xsl:variable name="rotate" select="$delimPart/*[@hname=$newOperator]/@hrotate = 'true'"/>
	  
	  <xsl:variable name="numParts" select="count($delimPart/*[@hname=$newOperator]/*)"/>
	  
	  <!-- Compute parts indexes -->
	  <xsl:variable name="rightIndex" select="1"/>
	  <xsl:variable name="middleIndex" select="3"/>
	  <xsl:variable name="leftIndex" select="if ($numParts = 2)
						 then 1
						 else 2"/>
	  <xsl:variable name="extenserIndex" select="$numParts"/>
	  
	  <xsl:variable name="max" select="if ($rotate) then 2 else 4"/>
	  <xsl:variable name="min" select="if ($rotate) then 1 else 3"/>
	  
	  <!-- Compute parts size -->
	  <xsl:variable name="rightBbox" as="xs:double+" select="if ($numParts != 2 or $delimPart/*[@hname=$newOperator]/@extenser = 'bottom' 
								 or $delimPart/*[@hname=$newOperator]/@extenser = 'left')
								 then func:findBbox($delimPart/*[@hname=$newOperator]/*[$rightIndex], $fontName, $fontNameVariant)
								 else (0, 0, 0, 0)"/>
	  <xsl:variable name="middleBbox" as="xs:double+" select="if ($numParts = 4)
								  then func:findBbox($delimPart/*[@hname=$newOperator]/*[$middleIndex], $fontName, $fontNameVariant)
								  else (0, 0, 0, 0)"/>
	  <xsl:variable name="leftBbox" as="xs:double+" select="if ($numParts != 2 or $delimPart/*[@hname=$newOperator]/@extenser = 'top' 
								or $delimPart/*[@hname=$newOperator]/@extenser = 'right')
								then func:findBbox($delimPart/*[@hname=$newOperator]/*[$leftIndex], $fontName, $fontNameVariant)
								else (0, 0, 0, 0)"/>
	  
	  <xsl:variable name="height" select="max(($rightBbox[$max], $middleBbox[$max], $leftBbox[$max]))"/>
	  <xsl:variable name="depth" select="min(($rightBbox[$min], $middleBbox[$min], $leftBbox[$min]))"/>
	  
	  <xsl:sequence select="($height, $depth)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:sequence select="func:findHeight($newOperator, $fontName, $fontNameVariant)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="initialHeight" select="$size * ($bbox[1] - $bbox[2])"/>
    <xsl:variable name="accentShift" select="if ($accent = true() and (count($delimPart/*[@hname=$newOperator]/*) = 0))
					     then 0.5 * $initialHeight
					     else 0"/>



    <!-- Height computation -->	
    <xsl:variable name="height" select="$initialHeight - $accentShift"/>
    <xsl:variable name="heightOverBaseline" select="if ($bbox[2] &lt; 0)
						    then $height + $size * $bbox[2]
						    else $height"/>

    
    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y + $heightOverBaseline"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline - $heightOverBaseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="strLen">
      <xsl:value-of select="string-length($newOperator)"/>
    </xsl:variable>
    
    <!-- Compute string size based on metrics files -->
    <xsl:variable name="strSize">
      <!-- Additions characters' widths -->
      <xsl:call-template name="stringWidth">
	<xsl:with-param name="str" select="$newOperator"/>
	<xsl:with-param name="strLen" select="$strLen"/>
	<xsl:with-param name="fontName" select="$fontName"/>
	<xsl:with-param name="variant" select="$fontNameVariant"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Left correction for the position of the string -->
    <xsl:variable name="firstCharBBox" select="func:findBbox(substring($newOperator, 1, 1), $fontName, $fontNameVariant)"/>
    <xsl:variable name="leftBearing" select="max((0, -$firstCharBBox[1])) * $size"/>

    <!-- Right bearing for the substring positionning -->
    <xsl:variable name="lastCharBBox" select="func:findBbox(substring($newOperator, $strLen, 1), $fontName, $fontNameVariant)"/>
    <xsl:variable name="lastCharSize">
      <xsl:call-template name="findWidth">
	<xsl:with-param name="name" select="substring($newOperator, $strLen, 1)"/>
	<xsl:with-param name="fonts" select="$fontName"/>
	<xsl:with-param name="variant" select="$fontNameVariant"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="rightBearing" select="max((0, $lastCharBBox[2] - $lastCharSize)) * $size"/>

    <!-- Compute space before and after operator in pixel -->
    <xsl:variable name="defaultLSpace">
      <xsl:choose>
	<xsl:when test="$defaultAttributes/dict:mo/@lspace">
	  <xsl:call-template name="unitInPx">
	    <xsl:with-param name="valueUnit" select="$defaultAttributes/dict:mo/@lspace"/>
	    <xsl:with-param name="fontSize" select="$size"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="unitInPx">
	    <xsl:with-param name="valueUnit" select="$thickmathspace"/>
	    <xsl:with-param name="fontSize" select="$size"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="defaultRSpace">
      <xsl:choose>
	<xsl:when test="$defaultAttributes/dict:mo/@rspace">
	  <xsl:call-template name="unitInPx">
	    <xsl:with-param name="valueUnit" select="$defaultAttributes/dict:mo/@rspace"/>
	    <xsl:with-param name="fontSize" select="$size"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:call-template name="unitInPx">
	    <xsl:with-param name="valueUnit" select="$thickmathspace"/>
	    <xsl:with-param name="fontSize" select="$size"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="lspacepx">
      <xsl:call-template name="unitInPx">
	<xsl:with-param name="valueUnit" select="$lspace"/>
	<xsl:with-param name="fontSize" select="$size"/>
	<xsl:with-param name="default" select="$defaultLSpace"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="rspacepx">
      <xsl:call-template name="unitInPx">
	<xsl:with-param name="valueUnit" select="$rspace"/>
	<xsl:with-param name="fontSize" select="$size"/>
	<xsl:with-param name="default" select="$defaultRSpace"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Compute space maxsize and minsize in pixel -->
    <xsl:variable name="maxsizepx">
      <xsl:choose>
	<xsl:when test="$maxsize = 'infinity'">
	  <xsl:value-of select="'infinity'"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:variable name="defaultMaxSize">
	    <xsl:choose>
	      <xsl:when test="$defaultAttributes/dict:mo/@maxsize and $defaultAttributes/dict:mo/@maxsize != 'infinity'">
		<xsl:call-template name="unitInPx">
		  <xsl:with-param name="valueUnit" select="$defaultAttributes/dict:mo/@maxsize"/>
		  <xsl:with-param name="fontSize" select="$size"/>
		  <xsl:with-param name="default" select="$height"/>
		</xsl:call-template>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="$height"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>

	  <xsl:call-template name="unitInPx">
	    <xsl:with-param name="valueUnit" select="$maxsize"/>
	    <xsl:with-param name="fontSize" select="$size"/>
	    <xsl:with-param name="default" select="$defaultMaxSize"/>
	  </xsl:call-template>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <xsl:variable name="defaultMinSize">
      <xsl:choose>
	<xsl:when test="$defaultAttributes/dict:mo/@minsize">
	  <xsl:call-template name="unitInPx">
	    <xsl:with-param name="valueUnit" select="$defaultAttributes/dict:mo/@minsize"/>
	    <xsl:with-param name="fontSize" select="$size"/>
	    <xsl:with-param name="default" select="$height"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$height"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="minsizepx">
      <xsl:call-template name="unitInPx">
	<xsl:with-param name="valueUnit" select="$minsize"/>
	<xsl:with-param name="fontSize" select="$size"/>
	<xsl:with-param name="default" select="$defaultMinSize"/>
      </xsl:call-template>
    </xsl:variable>
    
    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:STRETCHY" select="$stretchy"/>
      <xsl:attribute name="t:stretchHorizontal" select="$stretchHorizontal"/>
      <xsl:attribute name="t:stretchVertical" select="$stretchVertical"/>
      <xsl:attribute name="t:MINSIZE" select="$minsizepx"/>
      <xsl:attribute name="t:MAXSIZE" select="$maxsizepx"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:SHIFTX" select="$leftBearing"/>
      <xsl:attribute name="t:RIGHTBEARING" select="$rightBearing"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="$strSize * $size + $lspacepx + $rspacepx"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:HEIGHTOVERBASELINE" select="$heightOverBaseline"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <xsl:attribute name="t:TEXT" select="$newOperator"/>
      <xsl:attribute name="t:EMBELLISH" select="true()"/>
      <xsl:attribute name="t:LSPACE" select="$lspacepx"/>
      <xsl:attribute name="t:RSPACE" select="$rspacepx"/>
      <xsl:attribute name="t:ACCENT" select="$accent"/>
      <xsl:attribute name="t:ACCENTSHIFT" select="$accentShift"/>
      <xsl:attribute name="t:SYMMETRIC" select="$symmetric"/>
      <xsl:attribute name="t:STYLE" select="func:setStyle(
					    $bestMathVariant, 
					    func:chooseAttribute(@mathcolor, $mathcolor, 'black'),
					    func:chooseAttribute(@mathbackground, $mathbackground, 'transparent'))"/>
      <xsl:attribute name="t:VARIANT" select="$fontNameVariant"/>

      <xsl:value-of select="$newOperator"/>
    </xsl:copy>
  </xsl:template>

  <!-- Stretch vertical correcting mode -->
  <doc:template match="math:mo[@t:stretchVertical = true()]" mode="formatting">
    <refpurpose>Correcting mode for an operator element.</refpurpose>

    <refdescription>
      <para>
	Some operators have to stretch symmetrically, it depends on the <filename>symmetric</filename> attribute value, it means than 
	its size above the middle of the expression is equal to its size under this middle. The middle can be viewed as the position of
	the minus operator in the expression. Therefore, the first three lines of this mode (after size computation) are used to determine the 
	height of the delimiter with respect to the biggest element and the <filename>symmetric</filename> attributes. 
      </para>

      <para>
	The next computation implements the behaviour of <filename>minsize</filename> and <filename>maxsize</filename> <filename>mo</filename> attributes. 
	Since the correcting mode works directly on the annotated tree computed by the normal mode, these two attributes are retrieved directly from it.
      </para>

      <para>
	Since the parts that compose an operator have a bigger width than the normal operator, the width of the box has to be corrected too. It is done
	by retrieving the bounding box of each part. These bounding boxes are used to compute the new width.
      </para>

      <para>
	Finally, the box represention is corrected and directly annotated in the tree.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mo[@t:stretchVertical = true()]" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <xsl:param name="upperY" select="0" tunnel="yes"/>
    <xsl:param name="lowerY" select="0" tunnel="yes"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="fontName" tunnel="yes"/>
    <xsl:param name="scriptlevel" tunnel="yes"/>
    <xsl:param name="displayStyle" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <!-- Compute height -->
    <xsl:variable name="baselineCenter" select="$baseline - $size * func:getMiddle($fontName, '')"/>
    <xsl:variable name="maxDemiHeight" select="max(($lowerY - $baselineCenter, $baselineCenter - $upperY))"/>
    <!-- If max height in the row is lower or equal than operator, then keep operator height -->
    <xsl:variable name="maxHeight" select="if ((@t:CORRECTED and @t:CORRECTED = true()) or $lowerY - $upperY &lt;= number(@t:HEIGHT))
					   then @t:HEIGHT
					   else if (@t:SYMMETRIC = true())
					   then 2 * $maxDemiHeight
					   else $lowerY - $upperY"/>
    
    <xsl:variable name="height" select="if (number($maxHeight) &lt; number(@t:MINSIZE)) 
					then @t:MINSIZE 
					else if (@t:MAXSIZE != 'infinity' and number($maxHeight) &gt; number(@t:MAXSIZE))
					then @t:MAXSIZE
					else $maxHeight"/>

    <xsl:variable name="delimiter" select="@t:TEXT"/>

    <!-- Sequence: (width, xcorrection) -->
    <xsl:variable name="width" as="xs:double+">
      <xsl:choose>
	<xsl:when test="$height div @t:HEIGHT &gt; 1 and (count($delimPart/*[@vname=$delimiter]/*) &gt; 0) 
			and number(@t:HEIGHT) &lt; number($height)">
	  <xsl:variable name="numParts" select="count($delimPart/*[@vname=$delimiter]/*)"/>
	  <!-- Compute parts indexes -->
	  <xsl:variable name="topIndex" select="1"/>
	  <xsl:variable name="middleIndex" select="3"/>
	  <xsl:variable name="bottomIndex" select="if ($numParts = 2)
						   then 1
						   else 2"/>
	  <xsl:variable name="extenserIndex" select="$numParts"/>

	  <!-- Compute parts width 
	       Default is (1000, -1000, 0, 0) to avoid the default values to perturbate the min and max function -->
	  <xsl:variable name="topBbox" select="if ($numParts != 2 or $delimPart/*[@vname=$delimiter]/@extenser = 'bottom')
					       then func:findBbox($delimPart/*[@vname=$delimiter]/*[$topIndex], $fontName, @t:VARIANT)
					       else (1000, -1000, 0, 0)"/>
	  <xsl:variable name="middleBbox" select="if ($numParts = 4)
						  then func:findBbox($delimPart/*[@vname=$delimiter]/*[$middleIndex], $fontName, @t:VARIANT)
						  else (1000, -1000, 0, 0)"/>
	  <xsl:variable name="bottomBbox" select="if ($numParts != 2 or $delimPart/*[@vname=$delimiter]/@extenser = 'top')
						  then func:findBbox($delimPart/*[@vname=$delimiter]/*[$bottomIndex], $fontName, @t:VARIANT)
						  else (1000, -1000, 0, 0)"/>
	  <xsl:variable name="extenserBbox" select="func:findBbox($delimPart/*[@vname=$delimiter]/*[$extenserIndex], $fontName, @t:VARIANT)"/>

	  <xsl:variable name="partsSize" select="$topBbox[4] - $topBbox[3] + $middleBbox[4] - $middleBbox[3] + $bottomBbox[4] - $bottomBbox[3]"/>
	  <xsl:variable name="extenserSize" select="$extenserBbox[4] - $extenserBbox[3]"/>

	  <xsl:variable name="bestSize" select="func:findBestSize($height, @t:FONTSIZE, $numParts - 1, $partsSize, $extenserSize)"/>

	  <!-- Choose max part width -->
	  <xsl:sequence select="((max(($topBbox[2], $middleBbox[2], $bottomBbox[2], $extenserBbox[2])) - 
				min(($topBbox[1], $middleBbox[1], $bottomBbox[1], $extenserBbox[1], 0))) * $bestSize[2],
				- min(($topBbox[1], $middleBbox[1], $bottomBbox[1], $extenserBbox[1], 0)) * $bestSize[2])"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:sequence select="(@t:WIDTH, @t:SHIFTX)"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="if (@t:SYMMETRIC = true())
					then $baselineCenter - $height div 2
					else $upperY"/>
      <xsl:attribute name="t:SHIFTX" select="$width[2]"/>
      <xsl:attribute name="t:RIGHTBEARING" select="if ((@t:CORRECTED and @t:CORRECTED = true()) or $lowerY - $upperY &lt;= number(@t:HEIGHT))
						   then @t:RIGHTBEARING
						   else 0"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:WIDTH" select="$width[1] + @t:LSPACE + @t:RSPACE"/>
      <xsl:attribute name="t:CORRECTED" select="true()"/>
      <xsl:if test="$baseline != 0">
	<xsl:attribute name="t:BASELINE" select="$baseline"/>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       Choose entry
       #################################################################### -->
  <doc:function name="chooseEntry">
    <refpurpose>Chooses best entry in Operator Dictionary with respect to specification rules.</refpurpose>

    <refdescription>
      <para>
	This function checks if the first form from the <filename>forms</filename> attribute exists in the operator dictionary <filename>entries</filename>.
	If not, the recursion is called with the next form entries.
      </para>

      <para>
	Note thate recursion is never called with the same parameters as the first function call because an element is always removed from the 
	<filename>forms</filename> sequence. Therefore, the recursion will always end because the size of <filename>forms</filename> sequence decrease 
	and fall down to 0.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>forms</term>
	  <listitem>
	    <para>
	      Sequence of <filename>form</filename> attribute string ordered by preference: user specified, rules from <filename>form</filename> attributes, 
	      <filename>infix</filename>, <filename>postfix</filename>, <filename>prefix</filename>.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>nodes</term>
	  <listitem>
	    <para>Entries in the operator dictionary for the current operator.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
    
    <refreturn>
      <para>Returns the best entry from the operator dictionary entries.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:chooseEntry">               
    <xsl:param name="forms"/>
    <xsl:param name="nodes"/>

    <xsl:choose>
      <!-- No more forms, return empty node -->
      <xsl:when test="empty($forms)">
	<xsl:text/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:choose>
	  <xsl:when test="$nodes[@form = $forms[1]][1]">
	    <xsl:copy-of select="$nodes[@form = $forms[1]][1]"/>
	  </xsl:when>
	  <!-- Recursion -->
	  <xsl:otherwise>
	    <xsl:copy-of select="func:chooseEntry(remove($forms, 1), $nodes)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- ####################################################################
       BOXES : math, mrow, merror, mphantom, menclose, mstyle 
       (formatting mode)
       #################################################################### -->
  <doc:template match="math:math|math:mrow|math:merror|math:mphantom|math:menclose|math:mstyle"
		mode="formatting">
    <refpurpose>Formatting a box element.</refpurpose>

    <refsee>
      <para><filename>subMrow</filename></para>
    </refsee>

    <refdescription>
      <para>
	All these elements are considered to have the same grouping comportment. Therefore, they are all handled the same way in the
	same template with some exception in the code.
      </para>

      <para>
	First of all, we retrieve the number of children of the element. If this number is zero, an empty box is created and the
	tree is annotated with that box. If the number of children is greater than zero, the element will be treated normally.
	This distinction is used to handle correctly empty <filename>mrow</filename> that is used frequently.
      </para>

      <para>
	As usual, all attributes are first retrieved. The <filename>notations</filename> <filename>menclose</filename> attribute is 
	retrieved and all multiple spaces are replaced by one space. This attribute is used to determine which element(s) will enclose
	the row. It can contain more than one notation. For example, a row can be enclosed by both a circle and a box. After that, 
	common style attributes are retrieved (there are not all implemented yet) and finally <filename>mstyle</filename>
	attributes are retrieved (in reality, only <filename>scriptlevel</filename> is retrieved here because it needs more complex
	treatment than others). The currently supported attributes are:
	<variablelist>
	  <varlistentry>
	    <term><filename>scriptlevel</filename></term>
	    <listitem>
	      <para>
		Modifies the current level of the font size.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>displaystyle</filename></term>
	    <listitem>
	      <para>
		Modifies the rendering of some elements.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>Space literals (mediummathspace, etc.)</filename></term>
	    <listitem>
	      <para>
		Modify the size value of space literals.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>scriptsizemultiplier</filename></term>
	    <listitem>
	      <para>
		Modifies the <filename>sizeMult</filename> factor.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>

	<filename>mstyle</filename> attributes are quite different from other attributes because they have to be transmitted to their children.
	Therefore, they are retrieved when the child templates are called and only when the current element is an <filename>mstyle</filename> 
	tag. Before formatting all children, new values for <filename>X</filename> and <filename>Y</filename> are computed. These new values will help
	to add more spaces around the children because <filename>menclose</filename> and <filename>merror</filename> need them to add elements (boxes,
	circle, root sign, etc.).
      </para>
      
      <para>
	After that, children are computed using a template that will align them on the same baseline: 
	<filename>subMrow</filename>. It takes four arguments: the new computed <filename>X</filename> and <filename>Y</filename> values,
	the baseline and all the child elements. This template will also correct the operator that has to stretch vertically by calling 
	appropriate templates. After that, the highest right box side 
	of children are retrieved to compute the width of the box. The height and <filename>Y</filename> information is computed by 
	retrieving the lowest top side box and the highest bottom side box of children. A shift value is also computed if the children 
	are getting out of the canvas. For example, if the baseline is at 20 and if a child has a height of 40, it will go out of the 
	canvas by 20. Therefore, all the children have to be shifted to be drawn correctly on the canevas. After that, the baseline 
	for this box is computed by using the shift value and the lowest baseline of all children.
      </para>

      <para>
	Finally, the tree is annotated with box information, with the shift value, with value from its operator child 
	(<filename>EMBELLISH</filename>, <filename>LSPACE</filename>, <filename>RSPACE</filename>, <filename>stretchVertical</filename> 
	and <filename>ACCENT</filename>) if the row is considered as an embellished operator 
	and <filename>NOTATION</filename> attribute for <filename>menclose</filename> element.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:math|math:mrow|math:merror|math:mphantom|math:menclose|math:mstyle"
		mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="errorMargin" tunnel="yes"/>
    <xsl:param name="sizeMult" tunnel="yes"/>
    <xsl:param name="scriptlevel" tunnel="yes"/>
    <xsl:param name="displayStyle" tunnel="yes"/>
    <!-- Style -->
    <xsl:param name="mathvariant" tunnel="yes"/>
    <xsl:param name="mathcolor" tunnel="yes"/>
    <xsl:param name="mathbackground" tunnel="yes"/>
    <!-- Space literals -->
    <xsl:param name="veryverythinmathspace" tunnel="yes"/>
    <xsl:param name="verythinmathspace" tunnel="yes"/>
    <xsl:param name="thinmathspace" tunnel="yes"/>
    <xsl:param name="mediummathspace" tunnel="yes"/>
    <xsl:param name="thickmathspace" tunnel="yes"/>
    <xsl:param name="verythickmathspace" tunnel="yes"/>
    <xsl:param name="veryverythickmathspace" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <xsl:variable name="numOfChild">
      <xsl:value-of select="count(*)" />
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$numOfChild != 0">
	<!-- Retrieve notation (menclose) -->
	<xsl:variable name="notation">
	  <xsl:choose>
	    <xsl:when test="@notation">
	      <xsl:value-of select="replace(@notation, '\s+', ' ')"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="'longdiv'"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<!-- Retrieve scriptlevel (mstyle) -->
	<xsl:variable name="scriptlevelArg">
	  <xsl:choose>
	    <xsl:when test="@scriptlevel">
	      <xsl:value-of select="@scriptlevel"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$scriptlevel"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<!-- Style attributes -->
	<xsl:variable name="newMathvariant" select="func:chooseAttribute(@mathvariant, $mathvariant, '')"/>
	<xsl:variable name="newMathcolor" select="func:chooseAttribute(@mathcolor, $mathcolor, '')"/>
	<xsl:variable name="newMathbackground" select="func:chooseAttribute(@mathbackground, $mathbackground, 'transparent')"/>

	<xsl:variable name="sX">
	  <xsl:choose>
	    <xsl:when test="local-name(.) = 'menclose' and matches($notation, 'longdiv|radical')">
	      <xsl:value-of select="$x + 2 * $errorMargin"/>
	    </xsl:when>
	    <xsl:when test="local-name(.) = 'merror' or local-name(.) = 'menclose'">
	      <xsl:value-of select="$x + $errorMargin"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$x"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="sY">
	  <xsl:choose>
	    <xsl:when test="local-name(.) = 'merror' or local-name(.) = 'menclose'">
	      <xsl:value-of select="$y + $errorMargin"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$y"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="children">
	  <xsl:call-template name="subMrow">
	    <xsl:with-param name="x" select="$sX"/>
	    <xsl:with-param name="y" select="$sY"/>
	    <xsl:with-param name="baseline" select="$baseline"/>
	    <xsl:with-param name="nodes" select="*"/>
	    <!-- Style attributes -->
	    <xsl:with-param name="mathvariant" select="$newMathvariant" tunnel="yes"/>
	    <xsl:with-param name="mathcolor" select="$newMathcolor" tunnel="yes"/>
	    <xsl:with-param name="mathbackground" select="$newMathbackground" tunnel="yes"/>
	    <!-- Space literals : mstyle -->
	    <xsl:with-param name="veryverythinmathspace" tunnel="yes"  
			    select="if (local-name(.) = 'mstyle')
				    then func:chooseAttribute(@veryverythinmathspace, $veryverythinmathspace, '0.0555556em')
				    else $veryverythinmathspace"/>
	    <xsl:with-param name="verythinmathspace" tunnel="yes"
			    select="if (local-name(.) = 'mstyle')
				    then func:chooseAttribute(@verythinmathspace, $verythinmathspace, '0.111111em')
				    else $verythinmathspace"/>
	    <xsl:with-param name="thinmathspace" tunnel="yes"
			    select="if (local-name(.) = 'mstyle')
				    then func:chooseAttribute(@thinmathspace, $thinmathspace, '0.166667em')
				    else $thinmathspace"/>
	    <xsl:with-param name="mediummathspace" tunnel="yes"
			    select="if (local-name(.) = 'mstyle')
				    then func:chooseAttribute(@mediummathspace, $mediummathspace, '0.222222em')
				    else $mediummathspace"/>
	    <xsl:with-param name="thickmathspace" tunnel="yes"
			    select="if (local-name(.) = 'mstyle')
				    then func:chooseAttribute(@thickmathspace, $thickmathspace, '0.277778em')
				    else $thickmathspace"/>
	    <xsl:with-param name="verythickmathspace" tunnel="yes"
			    select="if (local-name(.) = 'mstyle')
				    then func:chooseAttribute(@verythickmathspace, $verythickmathspace, '0.333333em')
				    else $verythickmathspace"/>
	    <xsl:with-param name="veryverythickmathspace" tunnel="yes"
			    select="if (local-name(.) = 'mstyle')
				    then func:chooseAttribute(@veryverythickmathspace, $veryverythickmathspace, '0.388889em')
				    else $veryverythickmathspace"/>
	    <!-- mstyle arguments -->
	    <xsl:with-param name="sizeMult" tunnel="yes"
			    select="if (local-name(.) = 'mstyle')
				    then func:chooseAttribute(@scriptsizemultiplier, $sizeMult, '0.71')
				    else $sizeMult"/>
	    <xsl:with-param name="displayStyle" tunnel="yes"
			    select="if (local-name(.) = 'mstyle')
				    then func:chooseAttribute(@displaystyle, $displayStyle, 'true')
				    else $displayStyle"/>
	    <xsl:with-param name="scriptlevel" tunnel="yes">
	      <xsl:choose>
		<xsl:when test="local-name(.) = 'mstyle'">
		  <xsl:value-of select="if (starts-with($scriptlevelArg, '+') or starts-with($scriptlevelArg, '-'))
					then $scriptlevel + $scriptlevelArg
					else $scriptlevelArg"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="$scriptlevel"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:with-param>
	  </xsl:call-template>
	</xsl:variable>
	
	<!-- x-coordinate of the right side of the box -->
	<xsl:variable name="rightX">
	  <xsl:for-each select="$children/*">
	    <xsl:sort select="@t:X + @t:WIDTH"
		      data-type="number" order="descending"/>
	    <xsl:if test="position() = 1">
	      <xsl:value-of select="@t:X + @t:WIDTH"/>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:variable>
	
	<!-- y-coordinate of the bottom of the box -->
	<xsl:variable name="bottomY">
	  <xsl:for-each select="$children/*">
	    <xsl:sort select="@t:Y + @t:HEIGHT"
		      data-type="number" order="descending"/>
	    <xsl:if test="position() = 1">
	      <xsl:value-of select="@t:Y + @t:HEIGHT"/>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:variable>
	
	<!-- y-coordinate of the highest child -->
	<xsl:variable name="smallestY">
	  <xsl:for-each select="$children/*">
	    <xsl:sort select="@t:Y" data-type="number" order="ascending"/>
	    <xsl:if test="position() = 1">
	      <xsl:value-of select="@t:Y"/>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:variable>

	<xsl:variable name="height">
	  <xsl:choose>
	    <xsl:when test="local-name(.) = 'merror' or local-name(.) = 'menclose'">
	      <xsl:value-of select="$bottomY - $smallestY + $errorMargin * 2"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$bottomY - $smallestY"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="lowestBaseline">
	  <xsl:for-each select="$children/*">
	    <xsl:sort select="@t:BASELINE" data-type="number" order="descending"/>
	    <xsl:if test="position() = 1">
	      <xsl:value-of select="@t:BASELINE"/>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:variable>

	<xsl:variable name="shift">
	  <xsl:choose>
	    <xsl:when test="$baseline = 0">
	      <xsl:choose>
		<xsl:when test="local-name(.) = 'merror' or local-name(.) = 'menclose'">
		  <xsl:value-of select="$y - $smallestY + $errorMargin"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="$y - $smallestY"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="0"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="newBaseline">
	  <xsl:choose>
	    <xsl:when test="$baseline = 0">
	      <xsl:value-of select="$lowestBaseline + $shift"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$baseline"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="newY">
	  <xsl:choose>
	    <xsl:when test="$baseline = 0">
	      <xsl:value-of select="$y"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:choose>
		<xsl:when test="local-name(.) = 'merror' or local-name(.) = 'menclose'">
		  <xsl:value-of select="$smallestY - $errorMargin"/>
		</xsl:when>
		<xsl:otherwise>
		  <xsl:value-of select="$smallestY"/>
		</xsl:otherwise>
	      </xsl:choose>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>


	<xsl:variable name="embellish" select="if (count($children/*[local-name() != 'mspace' and local-name() != 'mo']) = 0 and
					      count($children/*[local-name() = 'mo' and @t:EMBELLISH = true()]) = 1)
					      then true()
					      else false()"/>

	<!-- Add node to tree -->
	<xsl:copy>
	  <xsl:copy-of select="@*"/>
	  <xsl:attribute name="t:X" select="$x"/>
	  <xsl:attribute name="t:Y" select="$newY"/>
	  <xsl:attribute name="t:FONTSIZE" select="$size"/>
	  <xsl:attribute name="t:WIDTH">
	    <xsl:choose>
	      <xsl:when test="local-name(.) = 'merror' or local-name(.) = 'menclose'">
		<xsl:value-of select="$rightX - $x + $errorMargin"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="$rightX - $x"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>
	  <xsl:attribute name="t:HEIGHT" select="$height"/>
	  <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
	  <xsl:attribute name="t:SHIFT" select="$shift"/>
	  <xsl:attribute name="t:EMBELLISH" select="$embellish"/>
	  <xsl:attribute name="t:RSPACE" select="if ($embellish)
						 then $children/*[local-name() = 'mo']/@t:RSPACE
						 else 0"/>
	  <xsl:attribute name="t:LSPACE" select="if ($embellish)
						 then $children/*[local-name() = 'mo']/@t:LSPACE
						 else 0"/>
	  <xsl:attribute name="t:ACCENT" select="if ($embellish = true()) 
						 then $children/*[local-name() = 'mo' and @t:EMBELLISH = true()]/@t:ACCENT 
						 else false()"/>
	  <xsl:attribute name="t:stretchVertical" select="if ($embellish = true())
							  then $children/*[local-name() = 'mo' and @t:EMBELLISH = true()]/@t:stretchVertical
							  else false()"/>
	  <xsl:attribute name="t:STYLE" select="func:setStyle($newMathvariant, $newMathcolor, $newMathbackground)"/>
	  <xsl:if test="local-name(.) = 'menclose'">
	    <xsl:attribute name="t:NOTATION" select="$notation"/>
	  </xsl:if>
	  <xsl:copy-of select="$children"/>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy>
	  <xsl:copy-of select="@*"/>
	  <xsl:attribute name="t:X" select="$x"/>
	  <xsl:attribute name="t:Y" select="$y"/>
	  <xsl:attribute name="t:FONTSIZE" select="$size"/>
	  <xsl:attribute name="t:WIDTH" select="0"/>
	  <xsl:attribute name="t:HEIGHT" select="0"/>
	  <xsl:attribute name="t:BASELINE" select="$baseline"/>
	  <xsl:attribute name="t:SHIFT" select="0"/>
	  <xsl:attribute name="t:EMBELLISH" select="false()"/>
	  <xsl:attribute name="t:RSPACE" select="0"/>
	  <xsl:attribute name="t:LSPACE" select="0"/>
	  <xsl:attribute name="t:ACCENT" select="false()"/>
	  <xsl:attribute name="t:stretchVertical" select="false()"/>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ####################################################################
       subMrow
       #################################################################### -->
  <doc:template name="subMrow">
    <refpurpose>This template is used to align the children of a row on the same baseline.</refpurpose>

    <refsee>
      <para><filename>alignChild</filename>, <filename>getStretchyEmbellished</filename></para>
    </refsee>

    <refdescription>
      <para>
	This template is used to align the children of a row on the same baseline. It also calls stretchy correction on operators that must
	stretch vertically. The first part of this function is to compute all the children on the same baseline. To do that, it calls a template 
	<filename>alignChild</filename> that takes the same parameters plus a <filename>firstChild</filename> parameter that is used to determine
	which element is the first child. This first child will give its basline attribute to all other children in order to align all children
	on the same baseline.
      </para>

      <para>
	After that, the function corrects the elements that must stretch vertically. All the stretchy embellished operators are first retrieved 
	by using <filename>getStretchyEmbellished</filename>. If there are no stretchy embellished operator,
	nothing is done and all the annotated children elements are returned. In the other case, a stretchy correction may be done.
      </para>

      <para>
	If a stretchy correction has to be done, the lowest and highest <filename>Y</filename> of all non stretchy children have to be retrieved to
	know the final size of the stretchy operators. To retrieve these children, <filename>getNonStretchyEmbellished</filename> function is used.
	If there is no element that does not stretch, nothing is done and all the annotated children elements are returned without any correction.
	In the other cases, a stretchy correction is done.
      </para>

      <para>
	Now that the non-stretchy elements are retrieved, the lowest and highest <filename>Y</filename> can be computed and the 
	<filename>alignChild</filename> template is called again to recompute the row with these new parameters. All the elements
	have to be recomputed because if an operator has to be stretched, its width will be greater. Therefore, all the elements that follow it
	must have a new <filename>X</filename> coordinate. Finally, all elements are returned.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>x, y, baseline</term>
	  <listitem>
	    <para>Formatting mode required parameters.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>nodes</term>
	  <listitem>
	    <para>Elements to handle in the template.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns all computed alements of the row.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="subMrow">
     <xsl:param name="x"/>
     <xsl:param name="y"/>
     <xsl:param name="baseline" select="0"/>
     <xsl:param name="nodes"/>

     <xsl:variable name="row">
       <xsl:call-template name="alignChild">
	 <xsl:with-param name="x" select="$x"/>
	 <xsl:with-param name="y" select="$y"/>
	 <xsl:with-param name="baseline" select="$baseline"/>
	 <xsl:with-param name="nodes" select="$nodes"/>
       </xsl:call-template>
     </xsl:variable>

     <xsl:variable name="stretchyOperators">
       <xsl:call-template name="getStretchyEmbellished">
	 <xsl:with-param name="nodes" select="$row/*"/>
	 <xsl:with-param name="mode" select="'v'"/>
       </xsl:call-template>
     </xsl:variable>
     
     <xsl:choose>
       <!-- There is stretchy element to correct -->
       <xsl:when test="count($stretchyOperators/*) &gt; 0">
	 <xsl:variable name="rowElements">
	   <xsl:call-template name="getNonStretchyEmbellished">
	     <xsl:with-param name="nodes" select="$row/*"/>
	     <xsl:with-param name="mode" select="'v'"/>
	   </xsl:call-template>
	 </xsl:variable>

	 <xsl:choose>
	   <!-- There is non stretchy element to fix the max size -->
	   <xsl:when test="count($rowElements/*) &gt; 0">

	     <!-- y-coordinate of the bottom of the box -->
	     <xsl:variable name="newLowerY">
	       <xsl:for-each select="$rowElements/*">
		 <xsl:sort select="@t:Y + @t:HEIGHT"
			   data-type="number" order="descending"/>
		 <xsl:if test="position() = 1">
		   <xsl:value-of select="@t:Y + @t:HEIGHT"/>
		 </xsl:if>
	       </xsl:for-each>
	     </xsl:variable>
	 
	     <!-- y-coordinate of the highest child -->
	     <xsl:variable name="newUpperY">
	       <xsl:for-each select="$rowElements/*">
		 <xsl:sort select="@t:Y" data-type="number" order="ascending"/>
		 <xsl:if test="position() = 1">
		   <xsl:value-of select="@t:Y"/>
		 </xsl:if>
	       </xsl:for-each>
	     </xsl:variable>
	     
	     <!-- Baseline -->
	     <xsl:variable name="lowestBaseline">
	       <xsl:for-each select="$rowElements/*">
		 <xsl:sort select="@t:BASELINE" data-type="number" order="descending"/>
		 <xsl:if test="position() = 1">
		   <xsl:value-of select="@t:BASELINE"/>
		 </xsl:if>
	       </xsl:for-each>
	     </xsl:variable>
	     
	     <xsl:variable name="correctedRow">
	       <xsl:call-template name="alignChild">
		 <xsl:with-param name="x" select="$x"/>
		 <xsl:with-param name="y" select="$y"/>
		 <xsl:with-param name="baseline" select="$lowestBaseline"/>
		 <xsl:with-param name="nodes" select="$row/*"/>
		 <xsl:with-param name="upperY" select="$newUpperY" tunnel="yes"/>
		 <xsl:with-param name="lowerY" select="$newLowerY" tunnel="yes"/>
	       </xsl:call-template>
	     </xsl:variable>
	     
	     <xsl:copy-of select="$correctedRow"/>
	   </xsl:when>
	   <!-- No non stretchy element -->
	   <xsl:otherwise>
	     <xsl:copy-of select="$row"/>
	   </xsl:otherwise>
	 </xsl:choose>
       </xsl:when>
       <!-- No stretchy element -->
       <xsl:otherwise>
	 <xsl:copy-of select="$row"/>
       </xsl:otherwise>
     </xsl:choose>
  </xsl:template>

  <!-- ####################################################################
       alignChild
       
       I never call function recursion with same parameters as first call
       because I always remove the first element of nodes.
       #################################################################### -->
  <doc:template name="alignChild">
    <refpurpose>Align a group of elements on the same baseline.</refpurpose>

    <refdescription>
      <para>
	This template is called from <filename>subMrow</filename> and is used to compute and align a group of elements on the same baseline.
	Typically, these elements will be a part of a row. This template will simply browse all the elements, compute each of them by
	calling the appropriate template in formatting mode and give the baseline of the first non stretchy element to all other elements 
	in order to align them on the same baseline. To know which element is the first non stretchy one, the <filename>firstChild</filename>
	parameter is used. The <filename>X</filename> coordinate value will be incremented by the size of the current element to compute
	the next one.
      </para>

      <para>
	Spaces are sometimes added between two elements. Typically, it will be done between an <filename>msub</filename>, <filename>msup</filename>
	or <filename>msubsup</filename> element and an other element that is not an operator.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>x, y, baseline</term>
	  <listitem>
	    <para>Formatting mode required parameters.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>nodes</term>
	  <listitem>
	    <para>Elements to handle in the template.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>firstNode</term>
	  <listitem>
	    <para>Determines if the current element is the first one in the row. It will give its baseline to all other elements.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns all elements aligned on the same baseline.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="alignChild">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <xsl:param name="nodes"/>
    <xsl:param name="firstNode" select="1"/>
    
    <xsl:if test="$nodes">
      <xsl:variable name="currentNode">
	<xsl:apply-templates select="$nodes[1]" mode="formatting">
	  <xsl:with-param name="x" select="$x"/>
	  <xsl:with-param name="y" select="$y"/>
	  <xsl:with-param name="baseline" select="$baseline"/>
	</xsl:apply-templates>
      </xsl:variable>

      <xsl:copy-of select="$currentNode"/>
      
      <xsl:variable name="currentWidth">
	<xsl:value-of select="$currentNode/*/@t:WIDTH"/>
      </xsl:variable>

      <xsl:variable name="stretchy" select="$currentNode/*/@t:stretchVertical
					    and $currentNode/*/@t:stretchVertical = true()"/>

      <!-- Add space between a msub, msup, msubsup and an other element except 
	   if the second element is a mo element or if the first element is an 
	   embellished operator  -->
      <xsl:variable name="space" select="if (count($nodes) &gt;= 2 
					     and (local-name($nodes[1]) = 'msub'
					         or local-name($nodes[1]) = 'msup'
					         or local-name($nodes[1]) = 'msubsup')
					     and local-name($nodes[2]) != 'mo'
					     and local-name($nodes[2]) != 'mfenced'
					     and (not($currentNode/*/@t:EMBELLISH)
					     or $currentNode/*/@t:EMBELLISH = false()))
					 then $currentNode/*/@t:FONTSIZE * 0.15
					 else 0"/>

      <!-- Recursion -->
      <xsl:call-template name="alignChild">
	<xsl:with-param name="x" select="$x + $currentWidth + $space"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="if ($firstNode and not($stretchy))
						then $currentNode/*/@t:BASELINE
						else $baseline"/>
	<xsl:with-param name="nodes" select="$nodes[position() &gt; 1]"/>
	<xsl:with-param name="firstNode" select="if ($firstNode and not($stretchy))
						 then 0
						 else 1"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       getStretchyEmbellished
       
       I never call function recursion with same parameters as first call
       because I always remove the first element of nodes.
       #################################################################### -->
  <doc:template name="getStretchyEmbellished">
    <refpurpose>Retrieves all the embellished operators that have to stretch vertically, horizontally or both.</refpurpose>
    
    <refsee>
      <para><filename>isEmbellished</filename></para>
    </refsee>

    <refdescription>
      This function simply browses each node and checks if it is an embellished operator using <filename>isEmbellished</filename> function. If the function
      returns <filename>true</filename>, the node is copied. Otherwise, nothing is done.
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>nodes</term>
	  <listitem>
	    <para>Elements to check.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>mode</term>
	  <listitem>
	    <para>Stretching mode: <filename>v</filename> is to retrieve the operators that stretch vertically (default value),
	    <filename>h</filename> is for horizontally, and <filename>b</filename> is for both vertically and horizontally.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns all the embellished operators that have to stretch vertically, horizontally or both.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="getStretchyEmbellished">
    <xsl:param name="nodes"/>
    <xsl:param name="mode" select="'v'"/>

    <xsl:if test="$nodes">
      <xsl:if test="func:isEmbellished($nodes[1], $mode)">
	<xsl:copy-of select="$nodes[1]"/>
      </xsl:if>

      <xsl:call-template name="getStretchyEmbellished">
	<xsl:with-param name="nodes" select="$nodes[position() &gt; 1]"/>
	<xsl:with-param name="mode" select="$mode"/>
      </xsl:call-template>
    </xsl:if>
    
  </xsl:template>

  <!-- ####################################################################
       getNonStretchyEmbellished

       I never call function recursion with same parameters as first call
       because I always remove the first element of nodes.
       #################################################################### -->
  <doc:template name="getNonStretchyEmbellished">
    <refpurpose>Retrieves all the elements that are not an embellished operator that have to stretch vertically, horizontally or both.</refpurpose>
    
    <refsee>
      <para><filename>isEmbellished</filename></para>
    </refsee>

    <refdescription>
      This function simply browses each node and checks if it is an embellished operator using <filename>isEmbellished</filename> function. If the function
      returns <filename>true</filename>, nothing is done. Otherwise, the node is copied.
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>nodes</term>
	  <listitem>
	    <para>Elements to check.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>mode</term>
	  <listitem>
	    <para>Stretching mode: <filename>v</filename> is to retrieve the operators that stretch vertically (default value),
	    <filename>h</filename> is for horizontally, and <filename>b</filename> is for both vertically and horizontally.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns all the elements that are not an embellished operator that have to stretch vertically, horizontally or both.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="getNonStretchyEmbellished">
    <xsl:param name="nodes"/>
    <xsl:param name="mode" select="'v'"/>

    <xsl:if test="$nodes">
      <xsl:if test="not(func:isEmbellished($nodes[1], $mode))">
	<xsl:copy-of select="$nodes[1]"/>
      </xsl:if>

      <xsl:call-template name="getNonStretchyEmbellished">
	<xsl:with-param name="nodes" select="$nodes[position() &gt; 1]"/>
	<xsl:with-param name="mode" select="$mode"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       isEmbellished
       
       I never call function recursion with same parameters as first call
       because I always call function with the first child of node. Node
       cannot be his own child.
       #################################################################### -->
   <doc:function name="isEmbellished">
    <refpurpose>Checks if an element is an embellished operator that has to stretch vertically, horizontally or both.</refpurpose>

    <refdescription>
      This function implements the rules, from the <acronym>MathML</acronym> specification, that determine if an element is an embellished operator.
    </refdescription>

    <refsee>
      <para><uri>http://www.w3.org/TR/2003/REC-MathML2-20031021/chapter3.html#id.3.2.5.7</uri></para>
    </refsee>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>node</term>
	  <listitem>
	    <para>Element to check.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>mode</term>
	  <listitem>
	    <para>Stretching mode: <filename>v</filename> is to retrieve the operators that stretch vertically (default value),
	    <filename>h</filename> is for horizontally, and <filename>b</filename> is for both vertically and horizontally.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns <filename>true</filename> if an element is an embellished operator.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:isEmbellished" as="xs:boolean">
    <xsl:param name="node"/>
    <xsl:param name="mode"/>

    <xsl:choose>
      <xsl:when test="$node[local-name() = 'msub' or local-name() = 'msup' or local-name() = 'msubsup' 
		         or local-name() = 'munder' or local-name() = 'mover' or local-name() = 'munderover' 
			 or local-name() = 'mfrac' or local-name() = 'mmultiscripts' or local-name() = 'mo']">

	<xsl:choose>
	  <!-- Embellished basic operator (mode vertical) -->
	  <xsl:when test="($mode = 'v' or $mode = 'b') and $node[local-name() = 'mo' and @t:STRETCHY = true() and @t:stretchVertical = true()]">
	    <xsl:value-of select="true()"/>
	  </xsl:when>
	  <!-- Embellished basic operator (mode horizontal) -->
	  <xsl:when test="($mode = 'h' or $mode = 'b') and $node[local-name() = 'mo' and @t:STRETCHY = true() and @t:stretchHorizontal = true()]">
	    <xsl:value-of select="true()"/>
	  </xsl:when>
	  <!-- Recursion -->
	  <xsl:otherwise>
	    <xsl:value-of select="func:isEmbellished($node/*[1], $mode)"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <!-- mrow and mtd special case -->
      <xsl:when test="$node[local-name() = 'mrow' or local-name() = 'mtd' or local-name() = 'mstyle'
		         or local-name() = 'mphantom' or local-name() = 'mpadded']">
	<xsl:choose>
	  <xsl:when test="count($node/*[local-name() != 'mspace']) = 1">
	    <xsl:value-of select="func:isEmbellished($node/*[local-name() != 'mspace'], $mode)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="false()"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- ####################################################################
       BOXES : maction (formatting)
       #################################################################### -->
  <doc:template match="math:maction" mode="formatting">
    <refpurpose>Represents an action that reacts at a user sollicitation.</refpurpose>
    
    <refdescription>
      <para>
	This element is not fully supported yet. To implement a default behaviour, the first child of the <filename>maction</filename>
	element is computed by using its formatting mode. Therefore, the <filename>maction</filename> node will not be annotated and will
	be replaced by its first child node.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:maction" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>

    <!-- Only compute the first expression -->
    <xsl:apply-templates select="math:*[1]" mode="formatting">
      <xsl:with-param name="x" select="$x"/>
      <xsl:with-param name="y" select="$y"/>
      <xsl:with-param name="baseline" select="$baseline"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ####################################################################
       MFENCED (formatting mode)
       #################################################################### -->
  <doc:template match="math:mfenced" mode="formatting">
    <refpurpose>Represents an expression enclosed by fences and separated by operators.</refpurpose>

    <refsee>
      <para><filename>mfencedCompose</filename></para>
    </refsee>

    <refdescription>
      <para>
	<filename>mfenced</filename> is an element that can be replaced by a <filename>mrow</filename> composed of two or more <filename>mo</filename> 
	elements and its children. For example
	
	<example>
	  <title>mfenced: original code</title>

	  <programlisting><![CDATA[<mfenced open="[" close="]" separators=";|">
  <mn>1</mn>
  <mn>2</mn>
  <mn>3</mn>
</mfenced>]]></programlisting>
	</example>
	
	can be replaced by:
	
	<example>
	  <title>mfenced: replacement code</title>
	  
	  <programlisting><![CDATA[<mrow>
  <mo fence="true">[</mo>
  <mn>1</mn>
  <mo separator="true">;</mo>
  <mn>2</mn>
  <mo separator="true">|</mo>
  <mn>3</mn>
  <mo fence="true">]</mo>
</mrow>]]></programlisting>
	</example>

	This example will render like that, with:
	<example>
	  <title>mfenced: renderer</title>
	  
	  <equation>
	    <math>
	      <mfenced open="[" close="]" separators=";|">
		<mn>1</mn>
		<mn>2</mn>
		<mn>3</mn>
	      </mfenced>
	    </math>
	  </equation>
	</example>

	We can see in this example the three optionnal arguments of <filename>mfenced</filename>:
	<variablelist>
	  <varlistentry>
	    <term><filename>open</filename></term>
	    <listitem>
	      <para>
		Determines the opening fence of the expression. The default value is <command>(</command>.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>close</filename></term>
	    <listitem>
	      <para>
		Determines the closing fence of the expression. The default value is <command>)</command>.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>separators</filename></term>
	    <listitem>
	      <para>
		Determines a sequence of one character separator that will be used to separate each children of <filename>mfenced</filename>.
		The default value is <command>,</command>. If there are not enoough separators to separate each child, the last one is 
		repeated.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>
      </para>
      
      <para>
	The formatting mode will transform the <filename>mfenced</filename> element into an <filename>mrow</filename> as mentionned
	above, and finally call the formatting mode of the <filename>mrow</filename> on it. First, all attributes are retrieved and
	spaces in <filename>separators</filename> atribute are deleted. A <filename>mrow</filename> node is created containing the
	opening and the closing <filename>mo</filename> and a composition of children and separators. This composition is done
	calling the <filename>mfencedCompose</filename> template. This template takes two arguments: the child nodes and the 
	<filename>separators</filename> string attribute without space.
      </para>
      
      <para>
	Finally, the formatting mode of the newly created <filename>mrow</filename> is called to compute and annotate it.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mfenced" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>

    <!-- Retrieve open glyph, default is ( -->
    <xsl:variable name="openGlyph">
      <xsl:choose>
	<xsl:when test="@open">
	  <xsl:value-of select="normalize-space(@open)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="'('"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    
    <!-- Retrieve close glyph, default is ) -->
    <xsl:variable name="closeGlyph">
      <xsl:choose>
	<xsl:when test="@close">
	  <xsl:value-of select="normalize-space(@close)"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="')'"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Retrieve separators list, default is , -->
    <xsl:variable name="separators">
      <xsl:choose>
	<xsl:when test="@separators">
	  <xsl:value-of select="replace(@separators, '\s+', '')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="','"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="children" select="child::*"/>

    <xsl:variable name="transform">
      <math:mrow>
	<xsl:copy-of select="@*"/>

	<math:mo fence="true"><xsl:value-of select="$openGlyph"/></math:mo>
	<xsl:choose>
	  <xsl:when test="count($children) > 1">
	    <xsl:call-template name="mfencedCompose">
	      <xsl:with-param name="elements" select="$children"/>
	      <xsl:with-param name="separators" select="$separators"/>
	    </xsl:call-template>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:copy-of select="child::*"/>
	  </xsl:otherwise>
	</xsl:choose>
	<math:mo fence="true"><xsl:value-of select="$closeGlyph"/></math:mo>
      </math:mrow>
    </xsl:variable>

    <xsl:apply-templates select="$transform" mode="formatting">
      <xsl:with-param name="x" select="$x"/>
      <xsl:with-param name="y" select="$y"/>
      <xsl:with-param name="baseline" select="$baseline"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ####################################################################
       mfencedCompose
       
       I never call function recursion with same parameters as first call
       because I always remove the first element of elements.
       #################################################################### -->
  <doc:template name="mfencedCompose">
    <refpurpose>Composes the child elements of an mfenced and add the correct separator between them.</refpurpose>

    <refdescription>
      <para>
	This recursive template adds the first element and, if it is not the last element, the first separator is added
	too into an <filename>mo</filename> element with the <filename>separator</filename> attribute set to <filename>true</filename>. 
	Then, the template is called again with elements and separators left. If it lefts only one separator, the recursion will
	always be called with that separator.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>elements</term>
	  <listitem>
	    <para>Child elements that compose the <filename>mfenced</filename>.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>separators</term>
	  <listitem>
	    <para>Separators to add between two consecutive elements.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns the new composed row of elements.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="mfencedCompose">
    <xsl:param name="elements"/>
    <xsl:param name="separators"/>

    <xsl:copy-of select="$elements[1]"/>

    <xsl:if test="count($elements) &gt; 1">
      <math:mo separator="true">
	<xsl:value-of select="substring($separators, 1, 1)"/>
      </math:mo>

      <xsl:call-template name="mfencedCompose">
	<xsl:with-param name="elements" select="remove($elements, 1)"/>
	<xsl:with-param name="separators" select="if (string-length($separators) = 1)
						  then $separators
						  else substring($separators, 2)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       isPrime
       
       I never call function recursion with same parameters as first call
       because I always call function with the first child of node. Node
       cannot be his own child.
       #################################################################### -->
   <doc:function name="isPrime">
    <refpurpose>Checks if an element is a prime token.</refpurpose>

    <refsee>
      <para><uri><![CDATA[http://www.nabble.com/RE%3A-Rendering-primes%3A-<msup><mi>x<-mi><mo>--x2032-<-mo><-msup>-p18157100.html]]></uri></para>
    </refsee>

    <refdescription>
      <para>
	This function check if the node element is a prime. Such an element, as a superscript, has not to be shifted and script level must remain the same
	as the base. The characters that return true with this function are asterisk (x2a), degree (xb0), prime (x2032), double prime (x2033),
	back prime (x2035) and double back prime (x2036).
      </para> 
    </refdescription>


    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>node</term>
	  <listitem>
	    <para>Element to check.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns <filename>true</filename> if an element is an prime operator.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:isPrime" as="xs:boolean">
    <xsl:param name="node"/>

    <xsl:choose>
      <!-- Basic token -->
      <xsl:when test="$node[(local-name() = 'mo' or local-name() = 'mi') 
		      and index-of(('&#42;', '&#176;', '&#8242;', '&#8243;', '&#8245;', '&#8246;'), .) &gt;= 0]">
	<xsl:value-of select="true()"/>
      </xsl:when>
      <!-- mrow special case -->
      <xsl:when test="$node[local-name() = 'mrow' or local-name() = 'mstyle'
		         or local-name() = 'mphantom' or local-name() = 'mpadded']">
	<xsl:choose>
	  <xsl:when test="count($node/*[local-name() != 'mspace']) = 1">
	    <xsl:value-of select="func:isPrime($node/*[local-name() != 'mspace'])"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="false()"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="false()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- ####################################################################
       MSUP (formatting mode)
       #################################################################### -->
  <doc:template match="math:msup" mode="formatting">
    <refpurpose>Formatting a superscript.</refpurpose>

    <refdescription>
      <para>
	<filename>msup</filename> element has two children: the first child is the base and the second is the superscript.
	After font size computation, the base and the superscript are computed by calling the formatting mode template on the first and second child. The 
	superscript gets a <filename>X</filename> coordinate value that depends on the base's size in order to place its box on the right of base one.
	Some general parameters are also modified when the superscript computation is called: the display style has to be <filename>false</filename>
	and the script level has to be incremented by one. Using this new value, the size of superscript elements will be smaller than base ones.
      </para>

      <para>
	After that, some information is retrieved for each child: its height, <filename>Y</filename> coordinate of its top edge and its height over 
	its baseline. This data will be used to compute the final height, baseline and coordinate of the box.
      </para>

      <para>
	The next four variables are used to compute a shift value for the superscript. By default, this value depends on the base height, if the base
	element is lower than 1.2em, the shift value will be 80 percent of the base height over the baseline. In all other case, the default value will
	be 90 percent of the base height over the baseline. If the users as specified a shift value, using the <filename>superscriptshift</filename>
	attributes, this value will be retrieved and used instead of the default one. Then the shift value is corrected with respect to the initial 
	position of the superscript and finally the descender of the superscript is added to the final shift value if it is not a token element.
      </para>

      <para>
	After that, the box representation is computed by using the shift value. The height is computed by taking the difference between the lowest
	and the highest <filename>Y</filename>. The baseline is the baseline of the base.
      </para>

      <para>
	Fnally, the tree node is annotated and contains,
	like all other elements, its box representation, and information that determine if the <filename>msup</filename> is an embellished operator
	(<filename>EMBELLISH</filename>, <filename>LSPACE</filename>, <filename>RSPACE</filename>, <filename>ACCENT</filename> and 
	<filename>stretchVertical</filename>. Some other information is also added to shift and to place the superscript: <filename>SHIFTY_BASE</filename>
	that will shift the base on the y-axis to place it correctly if necessary, <filename>SHIFTY_SUPERSCRIPT</filename> that will shift
	the superscript on the y-axis to its final position, and <filename>SHIFTX_SUPERSCRIPT</filename> that will withdraw the <filename>LSPACE</filename>
	value of the superscript if this one is an embellished operator. This last shift on x-axis is done to draw the superscript much closer
	to its base.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:msup" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="scriptlevel" tunnel="yes"/>
    <xsl:param name="displayStyle" tunnel="yes"/>
    <xsl:param name="rightSwitch" tunnel="yes"/>
    <xsl:param name="fontName" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <!-- Construction of the left child based on the current context -->
    <xsl:variable name="base">
      <xsl:apply-templates select="math:*[1]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="baseHeight" select="$base/*/@t:HEIGHT"/>
    <xsl:variable name="baseY" select="$base/*/@t:Y"/>
    <!-- Base's relative height -->
    <xsl:variable name="baseOverBaseline" select="$base/*/@t:BASELINE - $base/*/@t:Y"/>

    <!-- Superscript is a prime -->
    <xsl:variable name="supPrime" select="func:isPrime(math:*[2])"/>


    <!-- Construction of the right child,
	 placing its box at the right of the left child -->
    <xsl:variable name="superscript">
      <xsl:apply-templates select="math:*[2]" mode="formatting">
	<xsl:with-param name="x" select="if ($base/*/@t:EMBELLISH = true()) 
					 then $x + $base/*/@t:WIDTH - $base/*/@t:RSPACE
					 else $x + $base/*/@t:WIDTH"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="scriptlevel" select="if ($supPrime = true())
						   then $scriptlevel
						   else $scriptlevel + 1" tunnel="yes"/>
	<xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="superscriptHeight" select="$superscript/*/@t:HEIGHT"/>
    <xsl:variable name="superscriptY" select="$superscript/*/@t:Y"/>
    <xsl:variable name="superscriptOverBaseline" select="$superscript/*/@t:BASELINE - $superscript/*/@t:Y"/>


    <!-- Compute superscript shifting
	 If the superscript is a prime, no shift is required.
	 If the base height is lower than 1.2ex, I use the size of x to compute shifting
	 else I use the size of the base over the baseline -->
    <xsl:variable name="defaultSupShift" select="if ($supPrime = true())
						 then 0
						 else if ($baseHeight &lt; 1.2 * $size)
						 then 0.8 * func:getMiddle($fontName, '') * 2 * $size
						 else 0.9 * $baseOverBaseline"/>
    <!-- superscriptshift attribute -->
    <xsl:variable name="initialSupShift">
      <xsl:choose>
	<xsl:when test="@superscriptshift">
	  <xsl:call-template name="unitInPx">
	    <xsl:with-param name="valueUnit" select="@superscriptshift"/>
	    <xsl:with-param name="fontSize" select="$size"/>
	    <xsl:with-param name="default" select="$defaultSupShift"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$defaultSupShift"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- If the baseline is 0, the superscript have already been shifting from the baseline so I
	 need to withdraw this already done shift from the final shifting -->
    <xsl:variable name="correctSupShift" select="if ($baseline = 0)
						 then $initialSupShift - ($base/*/@t:BASELINE - $superscript/*/@t:BASELINE)
						 else $initialSupShift"/>

    <!-- If the superscript is not an identifier nor a text I have to 
	 add the descender in the shift -->
    <xsl:variable name="supShift" select="if (index-of(('mi', 'ms', 'mtext'), local-name(math:*[2])) &gt;= 0)
					  then $correctSupShift
					  else $correctSupShift + $superscriptHeight - $superscriptOverBaseline"/>

    <!-- Compute height -->
    <xsl:variable name="heightOverBase" select="$baseY - ($superscriptY - $supShift)"/>
    <xsl:variable name="heightOverBaseline" select="($baseY + $baseOverBaseline) 
						    - min(($baseY, $superscriptY - $supShift))"/>

    <xsl:variable name="height" select="max(($baseY + $baseHeight, $superscriptY - $supShift + $superscriptHeight)) 
					- min(($baseY, $superscriptY - $supShift))"/>

    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y + $heightOverBaseline"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline - $heightOverBaseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="if ($superscript/*/@t:EMBELLISH = true())
					    then $base/*/@t:WIDTH + $superscript/*/@t:WIDTH - $superscript/*/@t:LSPACE
					    else $base/*/@t:WIDTH + $superscript/*/@t:WIDTH + $rightSwitch"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <xsl:attribute name="t:EMBELLISH" select="if ($base/*/@t:EMBELLISH = true()) 
					       then true() 
					       else false()"/>
      <xsl:attribute name="t:RSPACE" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:RSPACE 
					     else 0"/>
      <xsl:attribute name="t:LSPACE" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:LSPACE 
					     else 0"/>
      <xsl:attribute name="t:ACCENT" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:ACCENT 
					     else false()"/>
      <xsl:attribute name="t:stretchVertical" select="if ($base/*/@t:EMBELLISH = true())
						      then $base/*/@t:stretchVertical
						      else false()"/>
      <xsl:attribute name="t:SHIFTY_BASE" select="abs($base/*/@t:BASELINE - $newBaseline)"/>
      <xsl:attribute name="t:SHIFTY_SUPERSCRIPT" select="if ($baseline = 0) 
							 then max((0, -$supShift))
							 else -$supShift"/>
      <!-- Don't shift superscript if it is an embellished operator -->
      <xsl:attribute name="t:SHIFTX_SUPERSCRIPT" select="if ($superscript/*/@t:EMBELLISH = true())
							 then - $superscript/*/@t:LSPACE
							 else $rightSwitch"/>
      <xsl:copy-of select="$base"/>
      <xsl:copy-of select="$superscript"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       MSUB (formatting mode)
       #################################################################### -->
  <doc:template match="math:msub" mode="formatting">
    <refpurpose>Formatting a subscript.</refpurpose>

    <refdescription>
      <para>
	<filename>msub</filename> element has two children: the first child is the base and the second is the subscript.
	It works quite the same way as <filename>msup</filename>. The first difference is the computation of the initial <filename>X</filename>
	coordinate for the subscript child. This value is computed using the right bearing value of the base if this last one has such a value.
	This computation is done in order to place the subscript elements closer to the base. Other differences appear in the computation of 
	subscript shift value. This value depends on the subscript height and not on the base height like the superscript in the 
	<filename>msup</filename> element. Initially, the shift is 50 percent of the subscript height over the baseline. If the user specified the
	<filename>subscriptshift</filename> attribute, it will be retrieved and used instead of the initial value. A last correction is added
	which depends on the initial positionnement of the subscript.
      </para>
      
      <para>
	The tree node is annotated with the same information as <filename>msup</filename>. However, only the subscript element gets shift attributes: 
	<filename>SHIFTY_SUBSCRIPT</filename> and <filename>SHIFTX_SUBSCRIPT</filename> that have the same role that in the <filename>msup</filename> element.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:msub" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="scriptlevel" tunnel="yes"/>
    <xsl:param name="rightSwitch" tunnel="yes"/>
    <xsl:param name="displayStyle" tunnel="yes"/>
    <xsl:param name="fontName" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <!-- Construction of the left child based on the current context -->
    <xsl:variable name="base">
      <xsl:apply-templates select="math:*[1]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="baseHeight" select="$base/*/@t:HEIGHT"/>
    <xsl:variable name="baseY" select="$base/*/@t:Y"/>
    <!-- Base's relative height -->
    <xsl:variable name="baseOverBaseline" select="$base/*/@t:BASELINE - $base/*/@t:Y"/>


    <xsl:variable name="subscriptX" select="if ($base/*/@t:RIGHTBEARING)
					    then $x + $base/*/@t:WIDTH - $base/*/@t:RIGHTBEARING
					    else $x + $base/*/@t:WIDTH"/>
    <xsl:variable name="subscript">
      <xsl:apply-templates select="math:*[2]" mode="formatting">
	<xsl:with-param name="x" select="if ($base/*/@t:EMBELLISH = true()) 
					 then $subscriptX - $base/*/@t:RSPACE
					 else $subscriptX"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="scriptlevel" select="$scriptlevel + 1" tunnel="yes"/>
	<xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="subscriptOverBaseline" select="$subscript/*/@t:BASELINE - $subscript/*/@t:Y"/>
    <xsl:variable name="subscriptHeight" select="$subscript/*/@t:HEIGHT"/>
    <xsl:variable name="subscriptY" select="$subscript/*/@t:Y"/>

    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y + $baseOverBaseline"/> <!-- Base's baseline -->
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline - $baseOverBaseline"/> <!-- Base's Y -->
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Base height for shifting -->
    <xsl:variable name="baseShiftHeight" select="if ($base/*/@t:EMBELLISH = true() and $base/*/@t:stretchVertical)
						 then $baseHeight
						 else $baseOverBaseline"/>

    <!-- Subscript shifting
	 subscriptshift attribute -->
    <xsl:variable name="defaultSubShift" select="0.5 * $subscriptOverBaseline"/>
    <xsl:variable name="initialSubShift">
      <xsl:choose>
	<xsl:when test="@subscriptshift">
	  <xsl:call-template name="unitInPx">
	    <xsl:with-param name="valueUnit" select="@subscriptshift"/>
	    <xsl:with-param name="fontSize" select="$size"/>
	    <xsl:with-param name="default" select="$defaultSubShift"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$defaultSubShift"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="subShift" select="if ($baseline = 0)
					  then $baseShiftHeight - $subscriptOverBaseline + $initialSubShift
					  else $baseY - $subscriptY + $baseShiftHeight -  $subscriptOverBaseline + $initialSubShift"/>

    <!-- Total height of the box -->
    <xsl:variable name="height" select="max(($baseY + $baseHeight, $subscriptY + $subscriptHeight + $subShift))
					 - min(($baseY, $subscriptY + $subShift))"/>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="$subscript/*/@t:X + $subscript/*/@t:WIDTH + $rightSwitch - $base/*/@t:X"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <xsl:attribute name="t:EMBELLISH" select="if ($base/*/@t:EMBELLISH = true()) 
					       then true() 
					       else false()"/>
      <xsl:attribute name="t:RSPACE" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:RSPACE 
					     else 0"/>
      <xsl:attribute name="t:LSPACE" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:LSPACE 
					     else 0"/>
      <xsl:attribute name="t:ACCENT" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:ACCENT 
					     else false()"/>
      <xsl:attribute name="t:stretchVertical" select="if ($base/*/@t:EMBELLISH = true())
						      then $base/*/@t:stretchVertical
						      else false()"/>
      <xsl:attribute name="t:SHIFTY_SUBSCRIPT" select="$subShift"/>
      <!-- Don't shift subscript if it is an embellished operator -->
      <xsl:attribute name="t:SHIFTX_SUBSCRIPT" select="if ($subscript/*/@t:EMBELLISH = true())
						       then - $subscript/*/@t:LSPACE
						       else $rightSwitch"/>
      <xsl:copy-of select="$base"/>
      <xsl:copy-of select="$subscript"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       MSUBSUP (formatting mode)
       #################################################################### -->
  <doc:template match="math:msubsup" mode="formatting">
    <refpurpose>Formatting both a superscript and a subscript.</refpurpose>

    <refdescription>
      <para>
	<filename>msubsup</filename> element has three children: the first child is the base, the second is the subscript and the third is the superscript.
	The formatting mode is a composition of the <filename>msup</filename> and <filename>msub</filename> formatting mode. The superscript
	has the same computation as in <filename>msup</filename> element and subscript as in <filename>msub</filename>. The shift values for the
	scripts are also the same. A difference appears before computing the box representation, an other shift value is computed if the superscript
	covers the subscript. In this case, both superscript and subscript have to be shifted to remove this covering.
      </para>
      
      <para>
	The box representation is then computed and finally, the tree is annotated exactly the same way as for both <filename>msup</filename> and
	<filename>msub</filename> elements.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:msubsup" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="scriptlevel" tunnel="yes"/>
    <xsl:param name="displayStyle" tunnel="yes"/>
    <xsl:param name="rightSwitch" tunnel="yes"/>
    <xsl:param name="overUnderSpace" tunnel="yes"/>
    <xsl:param name="fontName" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <xsl:variable name="base">
      <xsl:apply-templates select="math:*[1]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="baseWidth" select="$base/*/@t:WIDTH"/>
    <xsl:variable name="baseHeight" select="$base/*/@t:HEIGHT"/>
    <xsl:variable name="baseY" select="$base/*/@t:Y"/>
    <!-- Base's relative height -->
    <xsl:variable name="baseOverBaseline" select="$base/*/@t:BASELINE - $base/*/@t:Y"/>

    <xsl:variable name="subscriptX" select="if ($base/*/@t:RIGHTBEARING)
					    then $x + $base/*/@t:WIDTH - $base/*/@t:RIGHTBEARING
					    else $x + $base/*/@t:WIDTH"/>

    <xsl:variable name="subscript">
      <xsl:apply-templates select="math:*[2]" mode="formatting">
	<!-- Limitation of size reduction -->
	<xsl:with-param name="x" select="if ($base/*/@t:EMBELLISH = true()) 
					 then $subscriptX - $base/*/@t:RSPACE
					 else $subscriptX"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="scriptlevel" select="$scriptlevel + 1" tunnel="yes"/>
	<xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="subscriptHeight" select="$subscript/*/@t:HEIGHT"/>
    <xsl:variable name="subscriptY" select="$subscript/*/@t:Y"/>
    <xsl:variable name="subscriptOverBaseline" select="$subscript/*/@t:BASELINE - $subscript/*/@t:Y"/>

    <!-- Superscript is a prime -->
    <xsl:variable name="supPrime" select="func:isPrime(math:*[3])"/>

    <xsl:variable name="superscript">
      <xsl:apply-templates select="math:*[3]" mode="formatting">
	<xsl:with-param name="x" select="if ($base/*/@t:EMBELLISH = true()) 
					 then $x + $baseWidth - $base/*/@t:RSPACE
					 else $x + $baseWidth"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="scriptlevel" select="if ($supPrime = true())
						   then $scriptlevel
						   else $scriptlevel + 1" tunnel="yes"/>
	<xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="superscriptHeight" select="$superscript/*/@t:HEIGHT"/>
    <xsl:variable name="superscriptY" select="$superscript/*/@t:Y"/>
    <xsl:variable name="superscriptOverBaseline" select="$superscript/*/@t:BASELINE - $superscript/*/@t:Y"/>

    <!-- Compute superscript shifting
	 If the superscript is a prime, no shift is required.
	 If the base height is lower than 1.2ex, I use the size of x to compute shifting
	 else I use the size of the base over the baseline -->
    <xsl:variable name="defaultSupShift" select="if ($supPrime = true())
						 then 0
						 else if ($baseHeight &lt; 1.2 * $size)
						 then 0.8 * func:getMiddle($fontName, '') * 2 * $size
						 else 0.9 * $baseOverBaseline"/>
    
    <!-- superscriptshift attribute -->
    <xsl:variable name="initialSupShift">
      <xsl:choose>
	<xsl:when test="@superscriptshift">
	  <xsl:call-template name="unitInPx">
	    <xsl:with-param name="valueUnit" select="@superscriptshift"/>
	    <xsl:with-param name="fontSize" select="$size"/>
	    <xsl:with-param name="default" select="$defaultSupShift"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$defaultSupShift"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- If the baseline is 0, the superscript have already been shifting from the baseline so I
	 need to withdraw this already done shift from the final shifting -->
    <xsl:variable name="correctSupShift" select="if ($baseline = 0)
						 then $initialSupShift - ($base/*/@t:BASELINE - $superscript/*/@t:BASELINE)
						 else $initialSupShift"/>
    <!-- If the superscrit is not an identifier nor a text I have to 
	 add the descender in the shift -->
    <xsl:variable name="supShift" select="if (index-of(('mi', 'ms', 'mtext'), local-name(math:*[3])) &gt;= 0)
					  then $correctSupShift
					  else $correctSupShift + $superscriptHeight - $superscriptOverBaseline"/>

    <!-- Base height for shifting -->
    <xsl:variable name="baseShiftHeight" select="if ($base/*/@t:EMBELLISH = true() and $base/*/@t:stretchVertical)
						 then $baseHeight
						 else $baseOverBaseline"/>

    <!-- Compute height -->
    <xsl:variable name="heightOverBase" select="$baseY - ($superscriptY - $supShift)"/>
    <xsl:variable name="heightOverBaseline" select="$baseY + $baseOverBaseline
						    - min(($baseY, $superscriptY - $supShift))"/>

    <!-- Subscript shifting
	 subscriptshift attribute -->
    <xsl:variable name="defaultSubShift" select="0.6 * $subscriptOverBaseline"/>
    <xsl:variable name="initialSubShift">
      <xsl:choose>
	<xsl:when test="@subscriptshift">
	  <xsl:call-template name="unitInPx">
	    <xsl:with-param name="valueUnit" select="@subscriptshift"/>
	    <xsl:with-param name="fontSize" select="$size"/>
	    <xsl:with-param name="default" select="$defaultSubShift"/>
	  </xsl:call-template>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$defaultSubShift"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="subShift" select="if ($baseline = 0 and $superscriptHeight != 0)
					  then $heightOverBase + $baseShiftHeight - $subscriptOverBaseline + $initialSubShift
					  else $baseY - $subscriptY + $baseShiftHeight -  $subscriptOverBaseline + $initialSubShift"/>

    <!-- Real supercript shifting -->
    <xsl:variable name="realSupShift" select="if ($baseline = 0 and $supPrime != true())
					      then 0
					      else $supShift"/>

    <!-- Shift correction if subscript covers superscript -->
    <xsl:variable name="shiftCorrection" select="if ($supPrime != true() and
						     $superscriptHeight &gt; 0 and $subscriptHeight &gt; 0 and
						     ($subscriptY + $subShift) &lt;= ($superscriptY - $realSupShift + $superscriptHeight))
						 then ($superscriptY - $realSupShift + $superscriptHeight) - 
						      ($subscriptY + $subShift) + $overUnderSpace
						 else 0"/>

    <!-- Total height and width of the box -->
    <xsl:variable name="height" select="max(($baseY + $baseHeight, $subscriptY + $subShift + $subscriptHeight + $shiftCorrection))
					- min(($baseY, $superscriptY - $realSupShift - $shiftCorrection))"/>
    
    <xsl:variable name="width" select="max(($rightSwitch + $subscript/*/@t:X + $subscript/*/@t:WIDTH, 
				            $rightSwitch + $superscript/*/@t:X + $superscript/*/@t:WIDTH)) 
				       - $base/*/@t:X"/>

    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y + $heightOverBaseline + $shiftCorrection"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline - $heightOverBaseline - $shiftCorrection"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="$width"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <xsl:attribute name="t:EMBELLISH" select="if ($base/*/@t:EMBELLISH = true()) 
					       then true() 
					       else false()"/>
      <xsl:attribute name="t:RSPACE" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:RSPACE 
					     else 0"/>
      <xsl:attribute name="t:LSPACE" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:LSPACE 
					     else 0"/>
      <xsl:attribute name="t:ACCENT" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:ACCENT 
					     else false()"/>
      <xsl:attribute name="t:stretchVertical" select="if ($base/*/@t:EMBELLISH = true())
						      then $base/*/@t:stretchVertical
						      else false()"/>
      <xsl:attribute name="t:SHIFTY_BASE" select="if ($superscriptHeight != 0)
						  then abs($base/*/@t:BASELINE - $newBaseline)
						  else 0"/>
      <!--<xsl:attribute name="t:SHIFTY_SUBSCRIPT" select="if ($supPrime != true())
						       then $subShift + 2 * $shiftCorrection
						       else -$realSupShift + $subShift + 2 * $shiftCorrection"/>-->
      <xsl:attribute name="t:SHIFTY_SUBSCRIPT" select="if ($supPrime != true())
						       then $subShift + 2 * $shiftCorrection
						       else abs($base/*/@t:BASELINE - $newBaseline) - $realSupShift + $subShift + 2 * $shiftCorrection"/>
      <xsl:attribute name="t:SHIFTY_SUPERSCRIPT" select="if ($baseline = 0)
							 then max((0, -$realSupShift - $shiftCorrection))
							 else -$realSupShift - $shiftCorrection"/>
      <!-- Don't shift subscript if it is an embellished operator -->
      <xsl:attribute name="t:SHIFTX_SUBSCRIPT" select="if ($subscript/*/@t:EMBELLISH = true())
						       then - $subscript/*/@t:LSPACE
						       else $rightSwitch"/>
      <!-- Don't shift superscript if it is an embellished operator -->
      <xsl:attribute name="t:SHIFTX_SUPERSCRIPT" select="if ($superscript/*/@t:EMBELLISH = true())
							 then - $superscript/*/@t:LSPACE
							 else $rightSwitch"/>
      <xsl:copy-of select="$base"/>
      <xsl:copy-of select="$subscript"/>
      <xsl:copy-of select="$superscript"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       MOVER (formatting mode)
       #################################################################### -->
  <doc:template match="math:mover" mode="formatting">
    <refpurpose>Formatting an overscript.</refpurpose>

    <refdescription>
      <para>
	It consists of two children: the base is the first child and the overscript is the second.
	First, the base is computed and information about its box is retrieved to achieve further computation. Due to <filename>accent</filename> 
	behaviour, adjustement has to be done to compute the overscript. First, the <filename>accent</filename> attribute is retrieved. 
	If no value has been entered, accent is set to <filename>false</filename>. Then, the overscript is computed and, after that, the accent 
	value is recomputed by using the <filename>ACCENT</filename> attributes of the overscript if this one is an embellished operator. If the new
	<filename>accent</filename> value differs from the old one, the overscript have to be recomputed.
      </para>

      <para>
	These two passes have to be done because the <filename>accent</filename> attribute modifies the computation of the overscript element.
	If <filename>accent</filename> is <filename>true</filename>, the overscript has to be closer and the <filename>scriptlevel</filename> 
	is not modified. On the other hand, when <filename>accent</filename> is <filename>false</filename>, the <filename>scriptlevel</filename>
	for the overscript element has to be incremented by one. Therefore, this element will have a smaller font size.
      </para>

      <para>
	After overscript computation, some information about its box is retrieved to compute the <filename>mover</filename> final box.
      </para>

      <para>
	A shift value is then computed to move the overscript away from the base. This value is zero if the <filename>accent</filename> attribute
	is <filename>true</filename>, if not, this space shift is taken from the <filename>overUnderSpace</filename> global parameter.
      </para>

      <para>
	The box representation of the <filename>mover</filename>box is then computed. The height is the sum of the base height, the overscript height
	and the shift value previously computed. The baseline is the base's one and, since the overscript has to be drawn above the base, 
	then the upper left corner <filename>Y</filename> coordinate is the <filename>Y</filename> coordinate of the overscript top edge.
      </para>

      <para>
	Finally, the tree node is annotated with the box representation, with the embellished operator attributes and with shift values:
	
	<variablelist>
	  <varlistentry>
	    <term><filename>SHIFTX_BASE</filename></term>
	    <listitem>
	      <para>
		This shift value is used to centre the base horizontally with the overscript if the base is smaller than the overscript.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>SHIFTX_OVERSCRIPT</filename></term>
	    <listitem>
	      <para>
		This shift value is used to centre the overscript horizontally  with the base if the overscript is smaller than the base.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>SHIFTY_BASE</filename></term>
	    <listitem>
	      <para>
		This value is used to place the base at its final place. The overscript has to be placed above the base. Therefore, the base has to be 
		shifted down on the y-axis.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>SHIFTY_OVERSCRIPT</filename></term>
	    <listitem>
	      <para>
		The overscript has to be shifted up on the y-axis to be drawn over the base.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mover" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="scriptlevel" tunnel="yes"/>
    <xsl:param name="displayStyle" tunnel="yes"/>
    <xsl:param name="overUnderSpace" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <!-- Compute base -->
    <xsl:variable name="base">
      <xsl:apply-templates select="math:*[1]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="baseHeight" select="$base/*/@t:HEIGHT"/>
    <xsl:variable name="baseOverBaseline" select="$base/*/@t:BASELINE - $base/*/@t:Y"/>
    <xsl:variable name="baseWidth" select="if ($base/*/@t:EMBELLISH = true())
					   then $base/*/@t:WIDTH - $base/*/@t:RSPACE - $base/*/@t:LSPACE
					   else $base/*/@t:WIDTH"/>
    <xsl:variable name="baseY" select="$base/*/@t:Y"/>
    <xsl:variable name="baseStretchH" select="if ($base/*/@t:stretchHorizontal)
					      then $base/*/@t:stretchHorizontal
					      else false()"/>

    <!-- Compute initial accent value -->
    <xsl:variable name="initialAccent" select="func:chooseAttribute(@accent, '', 'false')"/>

    <!-- Compute overscript -->
    <xsl:variable name="initialOverscript">
      <xsl:apply-templates select="math:*[2]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="scriptlevel" select="if ($initialAccent = true())
						   then $scriptlevel
						   else $scriptlevel + 1" tunnel="yes"/>
	<xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <!-- Recompute accent -->
    <xsl:variable name="accent" select="func:chooseAttribute(@accent, $initialOverscript/*/@t:ACCENT, 'false')"/>

    <!-- Recompute overscript, if necessary -->
    <xsl:variable name="overscript">
      <xsl:choose>
	<!-- Recompute overscript with new size -->
	<xsl:when test="$initialOverscript/*/@t:EMBELLISH = true() and $initialAccent != $accent">
	  <xsl:apply-templates select="math:*[2]" mode="formatting">
	    <xsl:with-param name="x" select="$x"/>
	    <xsl:with-param name="y" select="$y"/>
	    <xsl:with-param name="baseline" select="$baseline"/>
	    <xsl:with-param name="scriptlevel" select="if ($accent = true())
						       then $scriptlevel
						       else $scriptlevel + 1" tunnel="yes"/>
	    <xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:copy-of select="$initialOverscript"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="overscriptHeight" select="$overscript/*/@t:HEIGHT"/>
    <xsl:variable name="overscriptWidth" select="$overscript/*/@t:WIDTH"/>
    <xsl:variable name="overscriptY" select="$overscript/*/@t:Y"/>
    <xsl:variable name="overscriptStretchH" select="if ($overscript/*/@t:stretchHorizontal)
						    then $overscript/*/@t:stretchHorizontal
						    else false()"/>

    <!-- Compute accent adjustement shifting -->
    <xsl:variable name="accentShift" select="if ($accent = true())
					     then -$overUnderSpace
					     else 0"/>

    <!-- Total height of the box -->
    <xsl:variable name="height">
      <xsl:value-of select="$baseHeight + $overscriptHeight + $overUnderSpace + $accentShift"/>
    </xsl:variable>

    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y + $overscriptHeight + $overUnderSpace + $baseOverBaseline + $accentShift"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline - $baseOverBaseline - $overscriptHeight - $overUnderSpace - $accentShift"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Embellish operator lspace -->
    <xsl:variable name="addShiftX" select="if ($base/*/@t:EMBELLISH = true())
					   then $base/*/@t:LSPACE
					   else 0"/>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="if ($base/*/@t:EMBELLISH = true()) 
					    then max(($baseWidth, $overscriptWidth)) 
					    + $base/*/@t:RSPACE + $base/*/@t:LSPACE
					    else max(($baseWidth, $overscriptWidth))"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <xsl:attribute name="t:SHIFTX_BASE" select="if ($baseStretchH = false() and number($baseWidth) &lt; number($overscriptWidth))
						  then ($overscriptWidth - $baseWidth) div 2
						  else 0"/>
      <xsl:attribute name="t:SHIFTX_OVERSCRIPT" select="if ($overscriptStretchH = false() and number($overscriptWidth) &lt; number($baseWidth))
							then $addShiftX + ($baseWidth - $overscriptWidth) div 2
							else $addShiftX"/>
      <xsl:attribute name="t:SHIFTY_BASE" select="if ($baseline = 0) 
						  then $overUnderSpace + $overscriptHeight  + $accentShift
						  else $newY - $baseY + $overUnderSpace + $overscriptHeight + $accentShift "/>
      <xsl:attribute name="t:SHIFTY_OVERSCRIPT" select="if ($baseline = 0) 
							then 0
							else $newY - $overscriptY"/>
      <xsl:attribute name="t:EMBELLISH" select="if ($base/*/@t:EMBELLISH = true()) 
					       then true() 
					       else false()"/>
      <xsl:attribute name="t:RSPACE" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:RSPACE 
					     else 0"/>
      <xsl:attribute name="t:LSPACE" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:LSPACE 
					     else 0"/>
      <xsl:attribute name="t:ACCENT" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:ACCENT 
					     else false()"/>
      <xsl:attribute name="t:stretchVertical" select="if ($base/*/@t:EMBELLISH = true())
						      then $base/*/@t:stretchVertical
						      else false()"/>
      <xsl:copy-of select="$base"/>
      <xsl:copy-of select="$overscript"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       MUNDER (formatting mode)
       #################################################################### -->
  <doc:template match="math:munder" mode="formatting">
    <refpurpose>Formatting an underscript.</refpurpose>

    <refdescription>
      <para>
	It consists of two children: the first is the base and the second is the underscript.
	<filename>munder</filename> is computed exactly the same way as the <filename>mover</filename> element. Only some variable names change,
	typically, <filename>overscript</filename> is replaced by <filename>underscript</filename>. The shift values are also computed differently
	because the <filename>underscript</filename> has to be drawn under the base and not over it.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:munder" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="scriptlevel" tunnel="yes"/>
    <xsl:param name="displayStyle" tunnel="yes"/>
    <xsl:param name="overUnderSpace" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <!-- Compute base -->
    <xsl:variable name="base">
      <xsl:apply-templates select="math:*[1]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="baseHeight" select="$base/*/@t:HEIGHT"/>
    <xsl:variable name="baseOverBaseline" select="$base/*/@t:BASELINE - $base/*/@t:Y"/>
    <xsl:variable name="baseWidth" select="if ($base/*/@t:EMBELLISH = true())
					   then $base/*/@t:WIDTH - $base/*/@t:RSPACE - $base/*/@t:LSPACE
					   else $base/*/@t:WIDTH"/>
    <xsl:variable name="baseY" select="$base/*/@t:Y"/>
    <xsl:variable name="baseStretchH" select="if ($base/*/@t:stretchHorizontal)
					      then $base/*/@t:stretchHorizontal
					      else false()"/>

    <!-- Compute initial accent under value -->
    <xsl:variable name="initialAccentunder" select="func:chooseAttribute(@accentunder, '', 'false')"/>

    <!-- Compute underscript -->
    <xsl:variable name="initialUnderscript">
      <xsl:apply-templates select="math:*[2]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="scriptlevel" select="if ($initialAccentunder = true())
						   then $scriptlevel
						   else $scriptlevel + 1" tunnel="yes"/>
	<xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <!-- Recompute accent under -->
    <xsl:variable name="accentunder" select="func:chooseAttribute(@accentunder, $initialUnderscript/*/@t:ACCENT, 'false')"/>

    <!-- Recompute underscript, if necessary -->
    <xsl:variable name="underscript">
      <xsl:choose>
	<!-- Recompute underscript with new size -->
	<xsl:when test="$initialUnderscript/*/@t:EMBELLISH = true() and $initialAccentunder != $accentunder">
	  <xsl:apply-templates select="math:*[2]" mode="formatting">
	    <xsl:with-param name="x" select="$x"/>
	    <xsl:with-param name="y" select="$y"/>
	    <xsl:with-param name="baseline" select="$baseline"/>
	    <xsl:with-param name="scriptlevel" select="if ($accentunder = true())
						       then $scriptlevel
						       else $scriptlevel + 1" tunnel="yes"/>
	    <xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:copy-of select="$initialUnderscript"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="underscriptHeight" select="$underscript/*/@t:HEIGHT"/>
    <xsl:variable name="underscriptWidth" select="$underscript/*/@t:WIDTH"/>
    <xsl:variable name="underscriptY" select="$underscript/*/@t:Y"/>
    <xsl:variable name="underscriptStretchH" select="if ($underscript/*/@t:stretchHorizontal)
						     then $underscript/*/@t:stretchHorizontal
						     else false()"/>

    <!-- Compute accent adjustement shifting -->
    <xsl:variable name="accentunderShift" select="if ($accentunder = true())
						  then -$overUnderSpace
						  else 0"/>

    <!-- Total height of the box -->
    <xsl:variable name="height" select="$baseHeight + $underscriptHeight + $overUnderSpace + $accentunderShift"/>

    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y + $baseOverBaseline"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline - $baseOverBaseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Embellish operator lspace -->
    <xsl:variable name="addShiftX" select="if ($base/*/@t:EMBELLISH = true())
					   then $base/*/@t:LSPACE
					   else 0"/>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="if ($base/*/@t:EMBELLISH = true()) 
					    then max(($baseWidth, $underscriptWidth)) 
					         + $base/*/@t:RSPACE + $base/*/@t:LSPACE
					    else max(($baseWidth, $underscriptWidth))"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <xsl:attribute name="t:SHIFTX_BASE" select="if ($baseStretchH = false() and number($baseWidth) &lt; number($underscriptWidth))
						  then ($underscriptWidth - $baseWidth) div 2
						  else 0"/>
      <xsl:attribute name="t:SHIFTX_UNDERSCRIPT" select="if ($underscriptStretchH = false() and number($underscriptWidth) &lt; number($baseWidth))
							 then $addShiftX + ($baseWidth - $underscriptWidth) div 2
							 else $addShiftX"/>
      <xsl:attribute name="t:SHIFTY_BASE" select="if ($baseline = 0)
						  then 0
						  else $newY - $baseY"/>
      <xsl:attribute name="t:SHIFTY_UNDERSCRIPT" select="if ($baseline = 0) 
							 then $baseHeight + $overUnderSpace + $accentunderShift
							 else $newY - $underscriptY + $baseHeight + $overUnderSpace + $accentunderShift"/>
      <xsl:attribute name="t:EMBELLISH" select="if ($base/*/@t:EMBELLISH = true()) 
					       then true() 
					       else false()"/>
      <xsl:attribute name="t:RSPACE" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:RSPACE 
					     else 0"/>
      <xsl:attribute name="t:LSPACE" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:LSPACE 
					     else 0"/>
      <xsl:attribute name="t:ACCENT" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:ACCENT 
					     else false()"/>
      <xsl:attribute name="t:stretchVertical" select="if ($base/*/@t:EMBELLISH = true())
						      then $base/*/@t:stretchVertical
						      else false()"/>
      <xsl:copy-of select="$base"/>
      <xsl:copy-of select="$underscript"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       MUNDEROVER (formatting mode)
       #################################################################### -->
  <doc:template match="math:munderover" mode="formatting">
    <refpurpose>Formatting both an underscript and an overscript.</refpurpose>

    <refdescription>
      <para>
	It consists of three children: the base is the first, the underscript is the second and the overscript is the third.
	This element is formatted as a combination of both an <filename>mover</filename> and an <filename>munder</filename> element. It first
	computes the base, then the underscript and finally the overscript. These two last elements are computed in two passes to handle
	correctly the <filename>accent</filename> attributes. These two passes are done the same way as for <filename>mover</filename>
	element.
      </para>
      
      <para>
	The box representation is then computed. The height is the sum of each element's height plus the overscript and the underscript shift value.
	The width is the width of the largest element among the base, the overscript and the underscript. The baseline is the base's one and the 
	upper left corner <filename>Y</filename> is the <filename>Y</filename> coordinate of the overscript box top edge.
      </para>
      
      <para>
	The tree is finally annotated with box representation and with all shift values from both <filename>mover</filename> and <filename>munder</filename>
	elements. The x-axis shift values are computed to center each element.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:munderover" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="scriptlevel" tunnel="yes"/>
    <xsl:param name="displayStyle" tunnel="yes"/>
    <xsl:param name="overUnderSpace" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <xsl:variable name="base">
      <xsl:apply-templates select="math:*[1]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="baseWidth" select="if ($base/*/@t:EMBELLISH = true())
					   then $base/*/@t:WIDTH - $base/*/@t:RSPACE - $base/*/@t:LSPACE
					   else $base/*/@t:WIDTH"/>
    <xsl:variable name="baseHeight" select="$base/*/@t:HEIGHT"/>
    <xsl:variable name="baseOverBaseline" select="$base/*/@t:BASELINE - $base/*/@t:Y"/>
    <xsl:variable name="baseY" select="$base/*/@t:Y"/>
    <xsl:variable name="baseStretchH" select="if ($base/*/@t:stretchHorizontal)
					      then $base/*/@t:stretchHorizontal
					      else false()"/>

    <!-- Compute initial accent under value -->
    <xsl:variable name="initialAccentunder" select="func:chooseAttribute(@accentunder, '', 'false')"/>

    <!-- Compute underscript -->
    <xsl:variable name="initialUnderscript">
      <xsl:apply-templates select="math:*[2]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="scriptlevel" select="if ($initialAccentunder = true())
						   then $scriptlevel
						   else $scriptlevel + 1" tunnel="yes"/>
	<xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <!-- Recompute accent under -->
    <xsl:variable name="accentunder" select="func:chooseAttribute(@accentunder, $initialUnderscript/*/@t:ACCENT, 'false')"/>

    <!-- Recompute underscript, if necessary -->
    <xsl:variable name="underscript">
      <xsl:choose>
	<!-- Recompute underscript with new size -->
	<xsl:when test="$initialUnderscript/*/@t:EMBELLISH = true() and $initialAccentunder != $accentunder">
	  <xsl:apply-templates select="math:*[2]" mode="formatting">
	    <xsl:with-param name="x" select="$x"/>
	    <xsl:with-param name="y" select="$y"/>
	    <xsl:with-param name="baseline" select="$baseline"/>
	    <xsl:with-param name="scriptlevel" select="if ($accentunder = true())
						       then $scriptlevel
						       else $scriptlevel + 1" tunnel="yes"/>
	    <xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:copy-of select="$initialUnderscript"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="underscriptHeight" select="$underscript/*/@t:HEIGHT"/>
    <xsl:variable name="underscriptWidth" select="$underscript/*/@t:WIDTH"/>
    <xsl:variable name="underscriptY" select="$underscript/*/@t:Y"/>
    <xsl:variable name="underscriptStretchH" select="if ($underscript/*/@t:stretchHorizontal)
						     then $underscript/*/@t:stretchHorizontal
						     else false()"/>

    <!-- Compute initial accent value -->
    <xsl:variable name="initialAccent" select="func:chooseAttribute(@accent, '', 'false')"/>

     <!-- Compute overscript -->
    <xsl:variable name="initialOverscript">
      <xsl:apply-templates select="math:*[3]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="scriptlevel" select="if ($initialAccent = true())
						   then $scriptlevel
						   else $scriptlevel + 1" tunnel="yes"/>
	<xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <!-- Recompute accent -->
    <xsl:variable name="accent" select="func:chooseAttribute(@accent, $initialOverscript/*/@t:ACCENT, 'false')"/>

    <!-- Recompute overscript, if necessary -->
    <xsl:variable name="overscript">
      <xsl:choose>
	<!-- Recompute overscript with new size -->
	<xsl:when test="$initialOverscript/*/@t:EMBELLISH = true() and $initialAccent != $accent">
	  <xsl:apply-templates select="math:*[3]" mode="formatting">
	    <xsl:with-param name="x" select="$x"/>
	    <xsl:with-param name="y" select="$y"/>
	    <xsl:with-param name="baseline" select="$baseline"/>
	    <xsl:with-param name="scriptlevel" select="if ($accent = true())
						       then $scriptlevel
						       else $scriptlevel + 1" tunnel="yes"/>
	    <xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
	  </xsl:apply-templates>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:copy-of select="$initialOverscript"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="overscriptHeight" select="$overscript/*/@t:HEIGHT"/>
    <xsl:variable name="overscriptWidth" select="$overscript/*/@t:WIDTH"/>
    <xsl:variable name="overscriptY" select="$overscript/*/@t:Y"/>
    <xsl:variable name="overscriptStretchH" select="if ($overscript/*/@t:stretchHorizontal)
						    then $overscript/*/@t:stretchHorizontal
						    else false()"/>

    <!-- Compute accent adjustement shifting -->
    <xsl:variable name="accentunderShift" select="if ($accentunder = true())
						  then -$overUnderSpace
						  else 0"/>
    <xsl:variable name="accentShift" select="if ($accent = true())
					     then -$overUnderSpace
					     else 0"/>

    <!-- Total height and width of the box -->    
    <xsl:variable name="height" select="$baseHeight + $underscriptHeight + $overscriptHeight
					+ 2 * $overUnderSpace + $accentShift + $accentunderShift"/>
    <xsl:variable name="width" select="max(($baseWidth, $underscriptWidth, $overscriptWidth))"/>

    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y + $overscriptHeight + $overUnderSpace + $baseOverBaseline 
				+ $accentShift + $accentunderShift"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline - $baseOverBaseline - $overUnderSpace - $overscriptHeight 
				- $accentShift - $accentunderShift"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Embellish operator lspace -->
    <xsl:variable name="addShiftX" select="if ($base/*/@t:EMBELLISH = true())
					   then $base/*/@t:LSPACE
					   else 0"/>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="if ($base/*/@t:EMBELLISH = true()) 
					    then $width + $base/*/@t:RSPACE + $base/*/@t:LSPACE
					    else $width"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <xsl:attribute name="t:SHIFTY_OVERSCRIPT" select="if ($baseline = 0) 
							then 0
							else $newY - $overscriptY"/>
      <xsl:attribute name="t:SHIFTY_BASE" select="if ($baseline = 0) 
						  then $overscriptHeight + $overUnderSpace + $accentShift
						  else $newY - $baseY + $overscriptHeight 
						       + $overUnderSpace + $accentShift"/>
      <xsl:attribute name="t:SHIFTY_UNDERSCRIPT" select="if ($baseline = 0) 
							 then $overscriptHeight + 2 * $overUnderSpace 
							      + $baseHeight + $accentShift + $accentunderShift
							 else $newY - $underscriptY + $overscriptHeight 
							      + 2 * $overUnderSpace + $baseHeight + $accentShift + $accentunderShift"/>
      <xsl:attribute name="t:SHIFTX_BASE">
	<xsl:choose>
	  <xsl:when test="$baseStretchH = false() and $underscriptWidth = $width">
	    <xsl:value-of select="($underscriptWidth - $baseWidth) div 2"/>
	  </xsl:when>
	  <xsl:when test="$baseStretchH = false() and $overscriptWidth = $width">
	    <xsl:value-of select="($overscriptWidth - $baseWidth) div 2"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="0"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="t:SHIFTX_UNDERSCRIPT">
	<xsl:choose>
	  <xsl:when test="$underscriptStretchH = false() and $baseWidth = $width">
	    <xsl:value-of select="$addShiftX + ($baseWidth - $underscriptWidth) div 2"/>
	  </xsl:when>
	  <xsl:when test="$underscriptStretchH = false() and $overscriptWidth = $width">
	    <xsl:value-of select="$addShiftX + ($overscriptWidth - $underscriptWidth) div 2"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="$addShiftX"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="t:SHIFTX_OVERSCRIPT">
	<xsl:choose>
	  <xsl:when test="$overscriptStretchH = false() and $underscriptWidth = $width">
	    <xsl:value-of select="$addShiftX + ($underscriptWidth - $overscriptWidth) div 2"/>
	  </xsl:when>
	  <xsl:when test="$overscriptStretchH = false() and $baseWidth = $width">
	    <xsl:value-of select="$addShiftX + ($baseWidth - $overscriptWidth) div 2"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="$addShiftX"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="t:EMBELLISH" select="if ($base/*/@t:EMBELLISH = true()) 
					       then true() 
					       else false()"/>
      <xsl:attribute name="t:RSPACE" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:RSPACE 
					     else 0"/>
      <xsl:attribute name="t:LSPACE" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:LSPACE 
					     else 0"/>
      <xsl:attribute name="t:ACCENT" select="if ($base/*/@t:EMBELLISH = true()) 
					     then $base/*/@t:ACCENT 
					     else false()"/>
      <xsl:attribute name="t:stretchVertical" select="if ($base/*/@t:EMBELLISH = true())
						      then $base/*/@t:stretchVertical
						      else false()"/>
      <xsl:copy-of select="$base"/>
      <xsl:copy-of select="$underscript"/>
      <xsl:copy-of select="$overscript"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       MFRAC (formatting mode)
       #################################################################### -->
  <doc:template match="math:mfrac" mode="formatting">
    <refpurpose>Formatting a fraction.</refpurpose>

    <refdescription>
      <para>
	It consists of two children: the first is the numerator and the second is the denominator.
	First, like all other elements, the numerator and the denominator are computed using the corresponding formatting mode template. When calling
	the template, some parameters have to be modified to follow the specification. If the display style is <filename>false</filename>, the script
	level has to be incremented by one, and, if it is <filename>true</filename>, it has to be set to <filename>false</filename>.
      </para>

      <para>
	The width, height and bottom edge <filename>Y</filename> coordinate of each child is then retrieved to help compute the box representation
	of the fraction.
      </para>

      <para>
	After that, <filename>mfrac</filename> attributes is retrieved:
	<variablelist>
	  <varlistentry>
	    <term><filename>linethickness</filename></term>
	    <listitem>
	      <para>
		Determines the size of the fraction bar. By default, this value is 1. After retrieving it, the line thickness is computed in
		pixel using the <filename>unitInPx</filename> function. A value with no unit determines a multiplication of the thin value, for example
		the default value is 1, without unit, it means that the fraction bar must have a height of <computeroutput>1 * thin</computeroutput>. 
		It is why the thin space literal is computed in pixels before computing the final fraction bar height. This value will be used as default 
		value for the <filename>unitInPx</filename> function.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>numalign</filename></term>
	    <listitem>
	      <para>
		Determines the alignement of the numerator. Values can be <filename>center</filename>, <filename>left</filename> or <filename>right</filename>.
		The default one is <filename>center</filename>.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>denomalign</filename></term>
	    <listitem>
	      <para>
		Determines the alignement of the denominator. Values can be <filename>center</filename>, <filename>left</filename> or <filename>right</filename>.
		The default one is <filename>center</filename>.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>
      </para>

      <para>
	A shift value is also computed to place the fraction bar, this value is computed from the baseline. The fraction bar has to be aligned with 
	a minus sign, in the middle of the text. Therefore, the half size of letter <command>x</command> is used.
      </para>
      
      <para>
	The box representation is then computed. The <filename>width</filename> is the maximum between the numerator and the denominator width plus
	a margin value both on the right and on the left from the global parameters (<filename>fracWidMarg</filename>). The baseline and
	the bottom of the box is set.
      </para>

      <para>
	Finally, the tree is annotated with the box representation and with shift value for the numerator and the denominator:

	<variablelist>
	  <varlistentry>
	    <term><filename>SHIFTXNUM</filename></term>
	    <listitem>
	      <para>
		Represents an x-axis shifting to place the numerator with respect to the <filename>numalign</filename> attribute.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>SHIFTXDEN</filename></term>
	    <listitem>
	      <para>
		Represents an x-axis shifting to place the denominator with respect to the <filename>denomalign</filename> attribute.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>SHIFTYNUM</filename></term>
	    <listitem>
	      <para>
		Represents a y-axis shifting to place the numerator above the fraction bar to its final position.
	      </para>
	    </listitem>
	  </varlistentry>

	  <varlistentry>
	    <term><filename>SHIFTYDEN</filename></term>
	    <listitem>
	      <para>
		Represents a y-axis shifting to place the denominator under the fraction bar to its final position.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>

	Values to place and draw the fraction bar are also added to the annotated tree: <filename>FRAC_BAR_Y</filename> is the <filename>Y</filename>
	coordinate of the fraction bar and <filename>FRAC_BAR_HEIGHT</filename> is its size.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mfrac" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="scriptlevel" tunnel="yes"/>
    <xsl:param name="displayStyle" tunnel="yes"/>
    <xsl:param name="fracWidMarg" tunnel="yes"/>
    <xsl:param name="numDenSpace" tunnel="yes"/>
    <xsl:param name="fontName" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <!-- Compute numerator -->
    <xsl:variable name="num">
      <xsl:apply-templates select="math:*[1]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="scriptlevel" select="if ($displayStyle = 'true') 
						   then $scriptlevel 
						   else $scriptlevel + 1" tunnel="yes"/>
	<xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="numWidth" as="xs:double" select="$num/*/@t:WIDTH"/>
    <xsl:variable name="numHeight" select="$num/*/@t:HEIGHT"/>
    <xsl:variable name="numY" select="$num/*/@t:Y"/>

    <!-- Compute denominator -->
    <xsl:variable name="den">
      <xsl:apply-templates select="math:*[2]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="scriptlevel" select="if ($displayStyle = 'true') 
						   then $scriptlevel 
						   else $scriptlevel + 1" tunnel="yes"/>
	<xsl:with-param name="displayStyle" select="'false'" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="denWidth" as="xs:double" select="$den/*/@t:WIDTH"/>
    <xsl:variable name="denHeight" select="$den/*/@t:HEIGHT"/>
    <xsl:variable name="denY" select="$den/*/@t:Y"/>

    <!-- Retrieve fraction bar height -->
    <xsl:variable name="linethickness">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@linethickness">
	  <xsl:value-of select="@linethickness"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="1"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="thinPx">
      <xsl:call-template name="unitInPx">
	<xsl:with-param name="valueUnit" select="$thin"/>
	<xsl:with-param name="fontSize" select="$size"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="fracBarHeight">
      <xsl:call-template name="unitInPx">
	<xsl:with-param name="valueUnit" select="$linethickness"/>
	<xsl:with-param name="fontSize" select="$size"/>
	<xsl:with-param name="default" select="$thinPx"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Retrieve numalign attribute -->
    <xsl:variable name="numalign">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@numalign">
	  <xsl:value-of select="@numalign"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="'center'"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Retrieve numalign attribute -->
    <xsl:variable name="denomalign">
      <xsl:choose>
	<!-- User specified -->
	<xsl:when test="@denomalign">
	  <xsl:value-of select="@denomalign"/>
	</xsl:when>
	<!-- Default value from specification -->
	<xsl:otherwise>
	  <xsl:value-of select="'center'"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- For vertical alignment -->
    <xsl:variable name="fracBarShift" select="$size * func:getMiddle($fontName, '') - $fracBarHeight * 0.5"/>

    <xsl:variable name="width">  <!-- width fraction's bar -->
      <xsl:value-of select="max(($numWidth, $denWidth)) + 2 * $fracWidMarg"/>
    </xsl:variable>

    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y + $numHeight + ($numDenSpace div 2) + $fracBarHeight * 0.5 +
				$fracBarShift"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline - $fracBarShift - $fracBarHeight * 0.5 -
				($numDenSpace div 2) - $numHeight"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="$width"/>
      <xsl:attribute name="t:HEIGHT" select="$numHeight + $numDenSpace + $denHeight + $fracBarHeight"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <!-- y-coordinate of the fraction's bar -->
      <xsl:attribute name="t:FRAC_BAR_Y" select="$newBaseline - $fracBarShift - $fracBarHeight div 2"/>
      <xsl:attribute name="t:FRAC_BAR_HEIGHT" select="$fracBarHeight"/>
      <xsl:attribute name="t:SHIFTXNUM">
	<xsl:choose>
	  <xsl:when test="$numWidth &lt; $denWidth and $numalign = 'center'">
	    <xsl:value-of select="$fracWidMarg + (($denWidth - $numWidth) div 2)"/>
	  </xsl:when>
	  <xsl:when test="$numWidth &lt; $denWidth and $numalign = 'right'">
	    <xsl:value-of select="$fracWidMarg + ($denWidth - $numWidth)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="$fracWidMarg"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="t:SHIFTXDEN">
	<xsl:choose>
	  <xsl:when test="$denWidth &lt; $numWidth and $denomalign = 'center'">
	    <xsl:value-of select="$fracWidMarg + (($numWidth - $denWidth) div 2)"/>
	  </xsl:when>
	  <xsl:when test="$denWidth &lt; $numWidth and $denomalign = 'right'">
	    <xsl:value-of select="$fracWidMarg + ($numWidth - $denWidth)"/>
	  </xsl:when>
	  <xsl:otherwise>
	    <xsl:value-of select="$fracWidMarg"/>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="t:SHIFTYNUM" select="if ($baseline = 0)
						then 0
						else $newY - $numY"/>
      <xsl:attribute name="t:SHIFTYDEN" select="if ($baseline = 0)
						then $numHeight + $numDenSpace + $fracBarHeight
						else $newY - $denY + $numHeight + $fracBarHeight + $numDenSpace"/>

      <xsl:copy-of select="$num"/>
      <xsl:copy-of select="$den"/>
    </xsl:copy>
  </xsl:template>


  <!-- ####################################################################
       MSQRT (formatting mode)
       #################################################################### -->
  <doc:template match="math:msqrt" mode="formatting">
    <refpurpose>Formatting a square root.</refpurpose>

    <refdescription>
      <para>
	Its children constitute a row and must be treated using the same mechanisms that for the <filename>mrow</filename>.
	First of all, the children are computed using the <filename>subMrow</filename> template (like an <filename>mrow</filename>). A space is added
	before the children to allow drawing of the square root symbol in front of them. The space value is computed using <filename>rtFrnSpcFac</filename>
	value from the global parameters with respect to the current font size.
      </para>
      
      <para>
	The box representation is then computed the same way as in an <filename>mrow</filename> element. However, in opposition to <filename>mrow</filename>
	a space is added on the top of the box to draw the square root line over the child elements. This value is coming from the global
	parameters (<filename>rtTopFac</filename>).
      </para>
      
      <para>
	Finally, the tree is annotated the same way as an <filename>mrow</filename> element.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:msqrt" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="rtFrnSpcFac" tunnel="yes"/>
    <xsl:param name="rtTopSpc" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <xsl:variable name="children">
      <xsl:call-template name="subMrow">
	<xsl:with-param name="x" select="$x + $size * $rtFrnSpcFac"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="nodes" select="*"/>
      </xsl:call-template>
    </xsl:variable>
    
    <!-- x-coordinate of the right side of the box -->
    <xsl:variable name="rightX">
      <xsl:for-each select="$children/*">
	<xsl:sort select="@t:X + @t:WIDTH"
		  data-type="number" order="descending"/>
	<xsl:if test="position() = 1">
	  <xsl:value-of select="@t:X + @t:WIDTH"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- y-coordinate of the bottom of the box -->
    <xsl:variable name="bottomY">
      <xsl:for-each select="$children/*">
	<xsl:sort select="@t:Y + @t:HEIGHT"
		  data-type="number" order="descending"/>
	<xsl:if test="position() = 1">
	  <xsl:value-of select="@t:Y + @t:HEIGHT"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- y-coordinate of the highest child -->
    <xsl:variable name="smallestY">
      <xsl:for-each select="$children/*">
	<xsl:sort select="@t:Y" data-type="number" order="ascending"/>
	<xsl:if test="position() = 1">
	  <xsl:value-of select="@t:Y"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="height">
      <xsl:value-of select="$bottomY - $smallestY + $rtTopSpc"/>
    </xsl:variable>

    <xsl:variable name="lowestBaseline">
      <xsl:for-each select="$children/*">
	<xsl:sort select="@t:BASELINE" data-type="number" order="descending"/>
	<xsl:if test="position() = 1">
	  <xsl:value-of select="@t:BASELINE"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <!-- Readjust the baseline -->
    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$lowestBaseline + $rtTopSpc + $y - $smallestY"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Compute the Y coordinate of the box -->
    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$smallestY - $rtTopSpc"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="$rightX - $x"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <xsl:attribute name="t:SHIFT" select="if ($baseline = 0) 
					    then $y - $smallestY + $rtTopSpc
					    else 0"/>
      <xsl:copy-of select="$children"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       MROOT (formatting)
       does not yet support multi-character indices.
       #################################################################### -->
  <doc:template match="math:mroot" mode="formatting">
    <refpurpose>Formatting a n-ary root.</refpurpose>

    <refdescription>
      <para>
	It consists of two children: the first one is the base and the second is the index.
	First, the base child and the index child are computed and some information about their boxes is retrieved (size and position) for further 
	computation. The base initial <filename>X</filename> coordinate is shifted to the right to add space for drawing the root symbol. After that, 
	the box representation is computed using child information.
      </para>
      
      <para>
	Finally, the tree is annotated with the box, with information about the size and the place of the radical (<filename>RADICAL_HEIGHT</filename>
	and <filename>RADICAL_Y</filename>) and with shift values for the children: 
	
	<variablelist>
	  <varlistentry>
	    <term><filename>SHIFTY_INDEX</filename></term>
	    <listitem>
	      <para>
		Determines a y-axis shifting to place the index.
	      </para>
	    </listitem>
	  </varlistentry>
	  
	  <varlistentry>
	    <term><filename>SHIFTY_BASE</filename></term>
	    <listitem>
	      <para>
		Determines a y-axis shifting to place the base.
	      </para>
	    </listitem>
	  </varlistentry>
	</variablelist>
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mroot" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="scriptlevel" tunnel="yes"/>
    <xsl:param name="rtFrnSpcFac" tunnel="yes"/>
    <xsl:param name="rtTopSpc" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <xsl:variable name="index">
      <xsl:apply-templates select="math:*[2]" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="scriptlevel" select="$scriptlevel + 2" tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="indexHeight" select="$index/*/@t:HEIGHT"/>

    <xsl:variable name="base">
      <xsl:apply-templates select="math:*[1]" mode="formatting">
	<xsl:with-param name="x" select="$x + $size * $rtFrnSpcFac"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="baseHeight" select="$base/*/@t:HEIGHT"/>
    <xsl:variable name="baseUnderBaseline" select="$baseHeight - ($base/*/@t:BASELINE - $base/*/@t:Y)"/>

    <xsl:variable name="height" select="0.75 * ($baseHeight + $rtTopSpc) + $indexHeight"/>

    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y + $height - $baseUnderBaseline"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline - $height + $baseUnderBaseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="$base/*/@t:WIDTH + $size * $rtFrnSpcFac"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <xsl:attribute name="t:RADICAL_TOP_Y" select="$newY + $indexHeight - 0.25 * 
						    ($baseHeight + $rtTopSpc)"/>
      <xsl:attribute name="t:RADICAL_HEIGHT" select="$baseHeight + $rtTopSpc"/>
      <xsl:attribute name="t:SHIFTY_BASE" select="if ($baseline = 0)
						  then $height - $baseHeight
						  else 0"/>
      <xsl:attribute name="t:SHIFTY_INDEX" select="if ($baseline = 0)
						   then 0
						   else $newY - $index/*/@t:Y"/>
      <xsl:copy-of select="$base"/>
      <xsl:copy-of select="$index"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       MTABLE (formatting)
       #################################################################### -->
  <doc:template match="math:mtable" mode="formatting">
    <refpurpose>Formatting a table.</refpurpose>

    <refsee>
      <para>
	<filename>computeStretch</filename>, <filename>stretchRows</filename>, <filename>mtableWidth</filename>, <filename>mtableShiftY</filename> and
	<filename>mtableShiftX</filename>.
      </para>
    </refsee>

    <refdescription>
      <para>
	This element has one or more <filename>mtr</filename> elements as children.
	It is also quite complex to render, elements that compose a column have to be aligned. The elements on a line also have
	to be aligned. The table must be centered on the middle of the mathematic expression. The main idea is to first compute all 
	the cells on the same place, as if they were
	not in a table. For example, in the two by two identity matrix, all 0 and 1 are computed like simple <filename>mn</filename>
	element. Finally, shift values are computed to move each cell to its final position.
      </para>
      
      <para>
	Therefore, in the formatting mode, the first action is to compute all <filename>mtr</filename> children by calling the appropriate
	template in formatting mode. After that, cells that contain a stretchy operator have to be stretched with respect to other cells
	that compose the columns and the row. For example, if a column contains a cell with a right arrow, given that the arrow has to stretch
	horizontally, the width of this cell has to have the value of the largest cell in the column. To compute the new size of the cells,
	stretch values are computed using the <filename>computeStretch</filename> function and the cell nodes are modified by using the
	<filename>stretchRows</filename> template.
      </para>
      
      <para>
	After that, the box representation is computed. The height is the sum of each row's height plus spaces between each two lines. The space
	size value comes from the global paramaters (parameter <filename>tableSpace</filename>). The table width is computed by calling the
	<filename>mtableWidth</filename> template on rows. The baseline is placed at the middle of the table. And, the upper left corner 
	<filename>Y</filename> is the <filename>Y</filename> coordinate of the table top edge.
      </para>
      
      <para>
	The <filename>columnalign</filename> is then retrieved. This attributes is used to determine how the cells in a column have to be aligned.
	The default value is <filename>center</filename>. The shift values for the y-axis are computed by using the <filename>mtableShiftY</filename> 
	template and the shift values for the x-axis are computed by using the <filename>mtableShiftX</filename> template and 
	<filename>columnalign</filename> attribute.
      </para>
      
      <para>
	Finally, the tree is annotated with the box representation and all shift values.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mtable" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="tableSpace" tunnel="yes"/>
    <xsl:param name="fontName" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <!-- Compute the number of mtd of the row that contains the most -->
    <xsl:variable name="numberOfMtd">
      <xsl:for-each select="math:mtr">
	<xsl:sort select="count(math:mtd)"
		  data-type="number" order="descending"/>
	<xsl:if test="position() = 1">
	  <xsl:value-of select="count(math:mtd)"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="initialRows">
      <xsl:apply-templates select="math:*" mode="formatting">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="numberOfMtd" select="$numberOfMtd"/>
      </xsl:apply-templates>
    </xsl:variable>

    <!-- Compute width and height of cell that must stretch -->
    <xsl:variable name="stretchValues">
      <xsl:call-template name="computeStretch">
	<xsl:with-param name="rows" select="$initialRows/*"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Correct size of cell that must stretch -->
    <xsl:variable name="rows">
      <xsl:call-template name="stretchRows">
	<xsl:with-param name="rows" select="$initialRows/*"/>
	<xsl:with-param name="stretchValues" select="tokenize(string($stretchValues), ' ; ')"/>
      </xsl:call-template>
    </xsl:variable>
    
    <!-- Compute height and width -->
    <xsl:variable name="height" select="sum($rows/*/@t:HEIGHT) + (count($rows/*) - 1) * $tableSpace"/>
    <xsl:variable name="width">
      <xsl:call-template name="mtableWidth">
	<xsl:with-param name="rows" select="$rows/*"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y + $height div 2 + $size * func:getMiddle($fontName, '')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline - $height div 2 - $size * func:getMiddle($fontName, '')"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Retrieve column align attributes -->
    <xsl:variable name="columnalign">
      <xsl:choose>
	<xsl:when test="@columnalign">
	  <xsl:value-of select="replace(@columnalign, '\s+', ' ')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="'center'"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Compute shiftY vector -->
    <xsl:variable name="shiftY">
      <xsl:call-template name="mtableShiftY">
	<xsl:with-param name="y" select="$newY"/>
	<xsl:with-param name="rows" select="$rows/*"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Compute shiftX vector -->
    <xsl:variable name="shiftX">
      <xsl:call-template name="mtableShiftX">
	<xsl:with-param name="rows" select="$rows/*"/>
	<xsl:with-param name="columnalign" select="tokenize($columnalign, ' ')"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="$width"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <xsl:attribute name="t:SHIFTY" select="$shiftY"/>
      <xsl:attribute name="t:SHIFTX" select="$shiftX"/>
     
      <xsl:copy-of select="$rows"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       computeStretch
       #################################################################### -->
  <doc:template name="computeStretch">
    <refpurpose>This template computes the final size of a cell if its content has to be stretched.</refpurpose>

    <refsee>
      <para><filename>isEmbellished</filename></para>
    </refsee>

    <refdescription>
      <para>
	All cells are handled by using <filename>i</filename> and <filename>j</filename> parameters as if the template were two loops. However,
	given that <acronym>XSLT</acronym> does not provide loop command, the two loops are done by using a recursion scheme.
      </para>
      
      <para>
	For each cell, the width is the largest cell in the column if the element in the current cell has to be stretched horizontally, zero 
	in all other cases. The height is the highest cell in the row if the element in the current cell has to be stretched vertically, zero in 
	all other cases. To check if an element has to be stretched, the <filename>isEmbellished</filename> template is used.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>rows</term>
	  <listitem>
	    <para>Row children from a table.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>i</term>
	  <listitem>
	    <para>Column index of the current element. By default, this index is 1.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>j</term>
	  <listitem>
	    <para>Row index of the current element. By default, this index is 1.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>
	As output, the template provides a list of height and width for each cell. Rows are delimited by a semicolon in that list.
	For example, in the following table <inlineequation><math xmlns="http://www.w3.org/1998/Math/MathML"><mo>(</mo><mtable><mtr><mtd><mn>1</mn></mtd>
	<mtd><mn>2</mn></mtd></mtr><mtr><mtd><mn>3</mn></mtd><mtd><mn>4</mn></mtd></mtr></mtable><mo>)</mo></math></inlineequation>, the
	output will be <computeroutput>1.width 1.height 2.width 2.height ; 3.width 3.height 4.width 4.height</computeroutput>. The value
	for width is zero if the content of the cell has not to be stretched horizontally, if the content has not to be stretched vertically, 
	the height is zero.
      </para>
    </refreturn>
  </doc:template>
  <xsl:template name="computeStretch">
    <xsl:param name="rows"/>
    <xsl:param name="i" select="1"/> <!-- Cols number -->
    <xsl:param name="j" select="1"/> <!-- Rows number -->

    <xsl:if test="count($rows) &gt;= $j">
      <xsl:choose>
	<!-- Treat element in column i and row j -->
	<xsl:when test="count($rows[1]/*) &gt;= $i">
	  <xsl:variable name="maxWidthColumn" select="if (func:isEmbellished($rows[$j]/*[$i], 'h'))
						      then max($rows/*[$i]/@t:WIDTH)
						      else 0"/>
	  <xsl:variable name="maxHeightRows" select="if (func:isEmbellished($rows[$j]/*[$i], 'v'))
						     then max($rows[$j]/*/@t:HEIGHT)
						     else 0"/>

	  <xsl:variable name="recursion">
	    <xsl:call-template name="computeStretch">
	      <xsl:with-param name="rows" select="$rows"/>
	      <xsl:with-param name="i" select="$i + 1"/>
	      <xsl:with-param name="j" select="$j"/>
	    </xsl:call-template>
	  </xsl:variable>
	  
	  <xsl:value-of select="insert-before(insert-before($recursion, 1, $maxHeightRows),
				  1, $maxWidthColumn)"/>
	</xsl:when>
	<!-- Goto next row -->
	<xsl:otherwise>
	  <xsl:variable name="recursion">
	    <xsl:call-template name="computeStretch">
	      <xsl:with-param name="rows" select="$rows"/>
	      <xsl:with-param name="i" select="1"/>
	      <xsl:with-param name="j" select="$j + 1"/>
	    </xsl:call-template>
	  </xsl:variable>

	  <!-- Separe row shifting by ; -->
	  <xsl:value-of select="if ($j = count($rows))
				then $recursion 
				else insert-before($recursion, 1, ';')"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       mtableWidth
       #################################################################### -->
  <doc:template name="mtableWidth">
    <refpurpose>Computes the total width of a table.</refpurpose>

    <refdescription>
      <para>
	For each column, the width of the largest cell in the column and space size between two cells (<filename>tableSpace</filename> global
	parameter) are added to <filename>width</filename>. The recursion is called with an <filename>i</filename> incremented by one
	and the newly computed width. The final output (when there is no more column to treat) is the value of the accumulator 
	<filename>width</filename> minus one space size between to cell.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>rows</term>
	  <listitem>
	    <para>Row children from a table.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>i</term>
	  <listitem>
	    <para>Index of the current column that is handled. By default, this index is 1.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>width</term>
	  <listitem>
	    <para>Accumulator that contains the width for a table composed of the <filename>(i-1)</filename>th first columns of all the row children.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns the total width of a table.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="mtableWidth">
    <xsl:param name="rows"/>
    <xsl:param name="i" select="1"/>
    <xsl:param name="width" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="tableSpace" tunnel="yes"/>

    <xsl:choose>
      <xsl:when test="count($rows[1]/*) &gt;= $i">
	<xsl:call-template name="mtableWidth">
	  <xsl:with-param name="rows" select="$rows"/>
	  <xsl:with-param name="i" select="$i + 1"/>
	  <xsl:with-param name="width" select="$width + max($rows/*[$i]/@t:WIDTH) + $tableSpace"/>
	</xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$width - $tableSpace"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ####################################################################
       mtableShiftY
       #################################################################### -->
  <doc:template name="mtableShiftY">
    <refpurpose>Computes a shift value on the y-axis to move a row to its final position.</refpurpose>

    <refdescription>
      <para>
	Recursion is done over the rows set. At each step, a shift value is computed for the first row in the set by using the difference between
	its final <filename>Y</filename> position (given in parameter) and its current <filename>Y</filename> position. The recursion is called
	for the rest of the set with an updated <filename>Y</filename> value. This new value is computed by using the height of the first row
	and size of space between two cells (<filename>tableSpace</filename> global parameter).
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>rows</term>
	  <listitem>
	    <para>Row children from a table.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>y</term>
	  <listitem>
	    <para>Final top edge <filename>Y</filename> coordinate of the first row in the <filename>rows</filename> parameters.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>
	As output, it provides a sequence of values that represent the shift for all rows: 
	<computeroutput>(1st row shift, 2nd row shift, ..., last row shift)</computeroutput>.
      </para>
    </refreturn>
  </doc:template>
  <xsl:template name="mtableShiftY">
    <xsl:param name="y"/>
    <xsl:param name="rows"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="tableSpace" tunnel="yes"/>

    <xsl:if test="$rows">
      <xsl:variable name="recursion">
	<xsl:call-template name="mtableShiftY">
	  <xsl:with-param name="y" select="$y + $rows[1]/@t:HEIGHT + $tableSpace"/>
	  <xsl:with-param name="rows" select="$rows[position() &gt; 1]"/>
	</xsl:call-template>
      </xsl:variable>
      
      <xsl:value-of select="insert-before($recursion, 1, $y - $rows[1]/@t:Y)"/>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       mtableShiftX
       #################################################################### -->
  <doc:template name="mtableShiftX">
    <refpurpose>Computes a shift value (on the x-axis) for each cell in a table.</refpurpose>

    <refdescription>
      <para>
	The recursion is done the same way as in the <filename>computeStretch</filename> template.
      </para>
      
      <para>
	For each cell, the alignement value (<filename>center</filename>, <filename>left</filename> or <filename>right</filename>) is retrieved from, 
	ordered by preference, <filename>mtd</filename> element (retrieved by using XPath on the rows parameter), <filename>mtr</filename> element 
	(also retrieved by using XPath on the rows parameter) or <filename>mtable</filename> element (given in parameter). If no value is specified by
	the user in <filename>mtd</filename>, <filename>mtr</filename> nor <filename>mtable</filename>, the default alignement value, coming from
	the <filename>mtable</filename> element, is <filename>center</filename>.
      </para>
      
      <para>
	After computing the alignement value, the largest element in the current column and the width of the current cell are retrieved. These values are
	then used to compute a shift value with respect to the alignement value. The width accumulator is used to determine the initial shift value
	to place the current cell in its final column.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>rows</term>
	  <listitem>
	    <para>Row children from a table.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>columnalign</term>
	  <listitem>
	    <para><filename>columnalign</filename> <filename>mtable</filename> attribute formatted as a sequence.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>i</term>
	  <listitem>
	    <para>Column index of the current element. By default, this index is 1.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>j</term>
	  <listitem>
	    <para>Row index of the current element. By default, this index is 1.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>width</term>
	  <listitem>
	    <para>Accumulator that contains the width for a table composed of the <filename>(i-1)</filename>th first columns of all the row children.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>
	As output, it provides a sequence of shift value for each cell, the row are separated by a semicolon. It is done the same way as in the 
	<filename>computeStretch</filename> template. For example, in the following table <inlineequation>
	<math xmlns="http://www.w3.org/1998/Math/MathML"><mo>(</mo><mtable><mtr><mtd><mn>1</mn></mtd>
	<mtd><mn>2</mn></mtd></mtr><mtr><mtd><mn>3</mn></mtd><mtd><mn>4</mn></mtd></mtr></mtable><mo>)</mo></math></inlineequation>, the
	output will be <computeroutput>1.shiftValue 2.shiftValue ; 3.shiftValue 4.shiftValue</computeroutput>.
      </para>
    </refreturn>
  </doc:template>
  <xsl:template name="mtableShiftX">
    <xsl:param name="rows"/>
    <xsl:param name="columnalign"/>
    <xsl:param name="i" select="1"/> <!-- Cols number -->
    <xsl:param name="j" select="1"/> <!-- Rows number -->
    <xsl:param name="width" select="0"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="tableSpace" tunnel="yes"/>

    <xsl:if test="count($rows) &gt;= $j">
      <xsl:choose>
	<!-- Treat element in column i and row j -->
	<xsl:when test="count($rows[1]/*) &gt;= $i">
	  <!-- Compute alignement method -->
	  <xsl:variable name="align">
	    <xsl:choose>
	      <!-- MTD columnalign -->
	      <xsl:when test="$rows[$j]/*[$i]/@t:COLUMNALIGN != 'inherited'">
		<xsl:value-of select="$rows[$j]/*[$i]/@t:COLUMNALIGN"/>
	      </xsl:when>
	      <!-- MTR columnalign -->
	      <xsl:when test="$rows[$j]/@t:COLUMNALIGN != 'inherited'">
		<xsl:variable name="alignRow" select="tokenize($rows[$j]/@t:COLUMNALIGN, ' ')"/>

		<xsl:value-of select="if (count($alignRow) &gt;= $i)
				      then $alignRow[$i]
				      else $alignRow[count($alignRow)]"/>
	      </xsl:when>
	      <!-- MTABLE columnalign -->
	      <xsl:otherwise>
		<xsl:value-of select="if (count($columnalign) &gt;= $i)
				      then $columnalign[$i]
				      else $columnalign[count($columnalign)]"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>

	  <xsl:variable name="maxWidthColumn" select="max($rows/*[$i]/@t:WIDTH)"
			as="xs:double"/>
	  <xsl:variable name="elemWidth" select="$rows[$j]/*[$i]/@t:WIDTH"
			as="xs:double"/>

	  <!-- Shift with respect to align properties -->
	  <xsl:variable name="shift">
	    <xsl:choose>
	      <xsl:when test="$align = 'left'"> <!-- Align left -->
		<xsl:value-of select="$width"/>
	      </xsl:when>
	      <xsl:when test="$align = 'right'"> <!-- Align right -->
		<xsl:value-of select="if ($elemWidth = $maxWidthColumn)
				      then $width
				      else $width + $maxWidthColumn - $elemWidth"/>
	      </xsl:when>
	      <xsl:otherwise> <!-- Align center -->
		<xsl:value-of select="if ($elemWidth = $maxWidthColumn)
				      then $width
				      else $width + ($maxWidthColumn - $elemWidth) div 2"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:variable>
	  <xsl:variable name="recursion">
	    <xsl:call-template name="mtableShiftX">
	      <xsl:with-param name="rows" select="$rows"/>
	      <xsl:with-param name="columnalign" select="$columnalign"/>
	      <xsl:with-param name="i" select="$i + 1"/>
	      <xsl:with-param name="j" select="$j"/>
	      <xsl:with-param name="width" select="$width + $maxWidthColumn + $tableSpace"/>
	    </xsl:call-template>
	  </xsl:variable>
	  
	  <xsl:value-of select="insert-before($recursion, 1, $shift)"/>
	</xsl:when>
	<!-- Goto next row -->
	<xsl:otherwise>
	  <xsl:variable name="recursion">
	    <xsl:call-template name="mtableShiftX">
	      <xsl:with-param name="rows" select="$rows"/>
	      <xsl:with-param name="columnalign" select="$columnalign"/>
	      <xsl:with-param name="i" select="1"/>
	      <xsl:with-param name="j" select="$j + 1"/>
	      <xsl:with-param name="width" select="0"/>
	    </xsl:call-template>
	  </xsl:variable>

	  <!-- Separe row shifting by ; -->
	  <xsl:value-of select="if ($j = count($rows))
				then $recursion 
				else insert-before($recursion, 1, ';')"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>
  
  <!-- ####################################################################
       MTR (formatting)
       #################################################################### -->
  <doc:template match="math:mtr" mode="formatting">
    <refpurpose>This element represent a row of a table.</refpurpose>

    <refsee>
      <para><filename>alignRow</filename></para>
    </refsee>

    <refdescription>
      <para>
	<filename>mtr</filename> element is computed like a basic <filename>mrow</filename> element. It is composed by one or more 
	<filename>mtd</filename> children.
      </para>

      <para>
	Some row can have less <filename>mtd</filename> element that other rows of the table, therefore empty <filename>mtd</filename> element
	have to be added. The <filename>numberOfMtd</filename> parameter gives the number of <filename>mtd</filename> child elements that the
	row musts have.
      </para>
      
      <para>
	After computing the current font size, the cells that compose the row are computed by using the <filename>alignRow</filename> template in
	order to align all the cells on the same baseline. After that, the box representation of the row is computed. The height is the difference
	between the highest and the lowest <filename>Y</filename> coordinate among all the children. The width is the sum of all the cells width plus
	a space between them (using the <filename>tableSpace</filename> global parameter). The baseline is the lowest baseline among children and
	upper left corner <filename>Y</filename> coordinate is the lowest <filename>Y</filename> coordinate among all the children.
      </para>
      
      <para>
	The <filename>columnalign</filename> is then retrieved. The default value is <filename>inherited</filename> if no one is specified.
      </para>
      
      <para>
	Finally, the tree is annotated by using the box representation, the shift value &#8212;as it is computed in an <filename>mrow</filename> element&#8212;,
	and with <filename>COLUMNALIGN</filename> attributes.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mtr" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <xsl:param name="numberOfMtd"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="tableSpace" tunnel="yes"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <xsl:variable name="cols">
      <xsl:call-template name="alignRow">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="$baseline"/>
	<xsl:with-param name="nodes" select="if (count(*) != $numberOfMtd)
					     then insert-before(*, 0, func:getEmptyMtd($numberOfMtd - count(*)))
					     else *"/>
	<xsl:with-param name="firstNode" select="1"/>
      </xsl:call-template>
    </xsl:variable>


    <!-- y-coordinate of the bottom of the box -->
    <xsl:variable name="bottomY">
      <xsl:for-each select="$cols/*">
	<xsl:sort select="@t:Y + @t:HEIGHT"
		  data-type="number" order="descending"/>
	<xsl:if test="position() = 1">
	  <xsl:value-of select="@t:Y + @t:HEIGHT"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    
    <!-- y-coordinate of the highest child -->
    <xsl:variable name="smallestY">
      <xsl:for-each select="$cols/*">
	<xsl:sort select="@t:Y" data-type="number" order="ascending"/>
	<xsl:if test="position() = 1">
	  <xsl:value-of select="@t:Y"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>
    
    <!-- Compute height and width -->
    <xsl:variable name="height" select="$bottomY - $smallestY"/>
    <xsl:variable name="width" select="sum($cols/*/@t:WIDTH) + (count($cols/*) - 1) * $tableSpace"/>

    <!-- Find lowest baseline -->
    <xsl:variable name="lowestBaseline">
      <xsl:for-each select="$cols/*">
	<xsl:sort select="@t:BASELINE" data-type="number" order="descending"/>
	<xsl:if test="position() = 1">
	  <xsl:value-of select="@t:BASELINE"/>
	</xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="newBaseline">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$lowestBaseline"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$baseline"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="newY">
      <xsl:choose>
	<xsl:when test="$baseline = 0">
	  <xsl:value-of select="$y"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="$smallestY"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Retrieve column align attributes -->
    <xsl:variable name="columnalign">
      <xsl:choose>
	<xsl:when test="@columnalign">
	  <xsl:value-of select="replace(@columnalign, '\s+', ' ')"/>
	</xsl:when>
	<xsl:otherwise>
	  <xsl:value-of select="'inherited'"/>
	</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Add node to tree -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="t:X" select="$x"/>
      <xsl:attribute name="t:Y" select="$newY"/>
      <xsl:attribute name="t:FONTSIZE" select="$size"/>
      <xsl:attribute name="t:WIDTH" select="$width"/>
      <xsl:attribute name="t:HEIGHT" select="$height"/>
      <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
      <xsl:attribute name="t:COLUMNALIGN" select="$columnalign"/>
      <xsl:attribute name="t:SHIFT" select="if ($baseline = 0)
					    then $y - $smallestY
					    else 0"/>
      <xsl:copy-of select="$cols"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       Get empty mtd
       #################################################################### -->
  <doc:function name="getEmptyMtd">
    <refpurpose>Returns a number of empty mtd element.</refpurpose>

    <refdescription>
      <para>
	This function creates a certain number of empty <filename>mtd</filename> element.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>number</term>
	  <listitem>
	    <para>
	      The number of empty <filename>mtd</filename> elements to create. This number has to be greater or equal to one.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
    
    <refreturn>
      <para>Returns a sequence of empty mtd elements.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:getEmptyMtd">               
    <xsl:param name="number"/>

    <!-- Create an empty mtd element -->
    <xsl:variable name="mtd">
      <math:mtd/>
    </xsl:variable>

    <xsl:choose>
      <!-- No more forms, return empty node -->
      <xsl:when test="$number = 1">
	<xsl:copy-of select="$mtd"/>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="insert-before(func:getEmptyMtd($number - 1), 0, $mtd)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- ####################################################################
       alignRow
       
       I never call function recursion with same parameters as first call
       because I always remove the first element of nodes.
       #################################################################### -->
  <doc:template name="alignRow">
    <refpurpose>Align a group of cells on the same baseline.</refpurpose>

    <refsee>
      <para><filename>alignChild</filename></para>
    </refsee>

    <refdescription>
      <para>
	This template has the same behaviour as the <filename>alignChild</filename> template from <filename>mrow</filename>. It calls the formatting 
	mode on the current element and aligns it on the first child baseline. This child is found with the <filename>firstNode</filename> parameter.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>x, y, baseline</term>
	  <listitem>
	    <para>Formatting mode required parameters.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>nodes</term>
	  <listitem>
	    <para>Elements handled in the template.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>firstNode</term>
	  <listitem>
	    <para>Determines if the current element is the first one in the row. It will give its baseline to all other elements.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns all cells aligned on the same baseline.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="alignRow">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>
    <xsl:param name="nodes"/>
    <xsl:param name="firstNode" select="0"/>
    
    <xsl:if test="$nodes">
      <xsl:variable name="currentNode">
	<xsl:apply-templates select="$nodes[1]" mode="formatting">
	  <xsl:with-param name="x" select="$x"/>
	  <xsl:with-param name="y" select="$y"/>
	  <xsl:with-param name="baseline" select="$baseline"/>
	</xsl:apply-templates>
      </xsl:variable>

      <xsl:copy-of select="$currentNode"/>

      <!-- Recursion -->
      <xsl:call-template name="alignRow">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="baseline" select="if ($firstNode)
						then $currentNode/*/@t:BASELINE 
						else $baseline"/>
	<xsl:with-param name="nodes" select="$nodes[position() &gt; 1]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       MTD (formatting)
       #################################################################### -->
  <doc:template match="math:mtd" mode="formatting">
    <refpurpose>This element represents a cell in a row. It has the same behaviour as a row element.</refpurpose>

    <refdescription>
      <para>
	The formating mode is exaclty the same as the <filename>mrow</filename> element. The only difference is the
	attribute <filename>columnalign</filename> that has to be retrieved. The default value is <filename>inherited</filename> if none is specified.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mtd" mode="formatting">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="baseline" select="0"/>

    <!-- Compute size -->
    <xsl:variable name="size">
      <xsl:call-template name="computeSize"/>
    </xsl:variable>

    <xsl:variable name="numOfChild">
      <xsl:value-of select="count(*)" />
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$numOfChild != 0">	
	<xsl:variable name="children">
	  <xsl:call-template name="subMrow">
	    <xsl:with-param name="x" select="$x"/>
	    <xsl:with-param name="y" select="$y"/>
	    <xsl:with-param name="baseline" select="$baseline"/>
	    <xsl:with-param name="nodes" select="*"/>
	  </xsl:call-template>
	</xsl:variable>
	
	<!-- x-coordinate of the right side of the box -->
	<xsl:variable name="rightX">
	  <xsl:for-each select="$children/*">
	    <xsl:sort select="@t:X + @t:WIDTH"
		      data-type="number" order="descending"/>
	    <xsl:if test="position() = 1">
	      <xsl:value-of select="@t:X + @t:WIDTH"/>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:variable>
	
	<!-- y-coordinate of the bottom of the box -->
	<xsl:variable name="bottomY">
	  <xsl:for-each select="$children/*">
	    <xsl:sort select="@t:Y + @t:HEIGHT"
		      data-type="number" order="descending"/>
	    <xsl:if test="position() = 1">
	      <xsl:value-of select="@t:Y + @t:HEIGHT"/>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:variable>
	
	<!-- y-coordinate of the highest child -->
	<xsl:variable name="smallestY">
	  <xsl:for-each select="$children/*">
	    <xsl:sort select="@t:Y" data-type="number" order="ascending"/>
	    <xsl:if test="position() = 1">
	      <xsl:value-of select="@t:Y"/>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="height" select="$bottomY - $smallestY"/>
	
	<xsl:variable name="lowestBaseline">
	  <xsl:for-each select="$children/*">
	    <xsl:sort select="@t:BASELINE" data-type="number" order="descending"/>
	    <xsl:if test="position() = 1">
	      <xsl:value-of select="@t:BASELINE"/>
	    </xsl:if>
	  </xsl:for-each>
	</xsl:variable>
	
	<xsl:variable name="newBaseline">
	  <xsl:choose>
	    <xsl:when test="$baseline = 0">
	      <xsl:value-of select="$lowestBaseline"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$baseline"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	
	<xsl:variable name="newY">
	  <xsl:choose>
	    <xsl:when test="$baseline = 0">
	      <xsl:value-of select="$y"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="$smallestY"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>

	<!-- Retrieve column align attributes -->
	<xsl:variable name="columnalign">
	  <xsl:choose>
	    <xsl:when test="@columnalign">
	      <xsl:value-of select="@columnalign"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="'inherited'"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	
	<!-- Add node to tree -->
	<xsl:copy>
	  <xsl:copy-of select="@*"/>
	  <xsl:attribute name="t:X" select="$x"/>
	  <xsl:attribute name="t:Y" select="$newY"/>
	  <xsl:attribute name="t:FONTSIZE" select="$size"/>
	  <xsl:attribute name="t:WIDTH" select="$rightX - $x"/>
	  <xsl:attribute name="t:HEIGHT" select="$height"/>
	  <xsl:attribute name="t:BASELINE" select="$newBaseline"/>
	  <xsl:attribute name="t:COLUMNALIGN" select="$columnalign"/>
	  <xsl:attribute name="t:SHIFT" select="if ($baseline = 0)
						then $y - $smallestY
						else 0"/>

	  <xsl:copy-of select="$children"/>
	</xsl:copy>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy>
	  <xsl:copy-of select="@*"/>
	  <xsl:attribute name="t:X" select="$x"/>
	  <xsl:attribute name="t:Y" select="if ($baseline = 0)
					    then $y
					    else $baseline"/>
	  <xsl:attribute name="t:FONTSIZE" select="$size"/>
	  <xsl:attribute name="t:WIDTH" select="0"/>
	  <xsl:attribute name="t:HEIGHT" select="0"/>
	  <xsl:attribute name="t:BASELINE" select="if ($baseline = 0)
						   then $y
						   else $baseline"/>
	</xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- ####################################################################
       stretchRows
       #################################################################### -->
  <doc:template name="stretchRows">
    <refpurpose>Modifies the width and height value of rows and cells with respect to the values computed by the computeStretch template.</refpurpose>

    <refsee>
      <para><filename>computeStretch</filename></para>
    </refsee>

    <refdescription>
      <para>
	This template simply calls <filename>mtr</filename> stretch mode template on each row. This new template mode is used to modify the
	width and the height of a node. It works directly in the annotated tree and changes the value of <filename>WIDTH</filename> and
	<filename>HEIGHT</filename> annotation.
      </para>
    </refdescription>
    
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>rows</term>
	  <listitem>
	    <para>Rows of a table to correct.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>stretchValues</term>
	  <listitem>
	    <para>Values computed by the <filename>computeStretch</filename> template.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns the corrected rows.</para>
    </refreturn>
  </doc:template>
  <xsl:template name="stretchRows">
    <xsl:param name="rows"/>
    <xsl:param name="stretchValues"/>

    <xsl:if test="$rows">
      <xsl:apply-templates select="$rows[1]" mode="stretch">
	<xsl:with-param name="stretchValues" select="$stretchValues[1]"/>
      </xsl:apply-templates>  

      <xsl:call-template name="stretchRows">
	<xsl:with-param name="rows" select="$rows[position() &gt; 1]"/>
	<xsl:with-param name="stretchValues" select="$stretchValues[position() &gt; 1]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       MTR (stretch correction)
       #################################################################### -->
  <doc:template match="math:mtr" mode="stretch">
    <refpurpose>Correct width and height on a row.</refpurpose>

    <refsee>
      <para><filename>computeStretch</filename>, <filename>stretchCols</filename></para>
    </refsee>

    <refdescription>
      <para>
	First, all its <filename>mtd</filename> elements are recomputed by using the <filename>stretchCols</filename> template. After that, the
	annotated tree is recomposed by using these new cells.
      </para>
    </refdescription>
    
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>stretchValues</term>
	  <listitem>
	    <para>Sequence that represents the new width and height (computed by the <filename>computeStretch</filename> template) for all the 
	    cells in that row.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
  </doc:template>
  <xsl:template match="math:mtr" mode="stretch">
    <xsl:param name="stretchValues"/>

    <xsl:variable name="cols">
      <xsl:call-template name="stretchCols">
	<xsl:with-param name="rows" select="child::*"/>
	<xsl:with-param name="stretchValues" select="tokenize($stretchValues, ' ')"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:copy>
      <xsl:copy-of select="@*"/>

      <xsl:copy-of select="$cols"/>
    </xsl:copy>
  </xsl:template>

  <!-- ####################################################################
       stretchCols
       #################################################################### -->
  <doc:template name="stretchCols">
    <refpurpose>Recomputes width and height of table columns.</refpurpose>

    <refdescription>
      <para>
	It simply recomputes all <filename>mtd</filename> elements by calling their stretch mode template with new width and height as paramaters.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>rows</term>
	  <listitem>
	    <para>All cells that will be corrected.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>stretchValues</term>
	  <listitem>
	    <para>New width and height values (in a sequence) for all these cells.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
  </doc:template>
  <xsl:template name="stretchCols">
    <xsl:param name="rows"/>
    <xsl:param name="stretchValues"/>

    <xsl:if test="$rows">
      <xsl:apply-templates select="$rows[1]" mode="stretch">
	<xsl:with-param name="width" select="number($stretchValues[1])"/>
	<xsl:with-param name="height" select="number($stretchValues[2])"/>
      </xsl:apply-templates>  

      <xsl:call-template name="stretchCols">
	<xsl:with-param name="rows" select="$rows[position() &gt; 1]"/>
	<xsl:with-param name="stretchValues" select="$stretchValues[position() &gt; 2]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       MTD (stretch correction)
       #################################################################### -->
  <doc:template match="math:mtd" mode="stretch">
    <refpurpose>Correct width and height on a cell.</refpurpose>

    <refsee>
      <para><filename>computeStretch</filename></para>
    </refsee>

    <refdescription>
      <para>
	This template simply copies the annotated node and changes <filename>WIDTH</filename> and <filename>HEIGHT</filename> annotations
	if the paramaters are not equal to zero.
      </para>
    </refdescription>
    
    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>width</term>
	  <listitem>
	    <para>New width for the element.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term>height</term>
	  <listitem>
	    <para>New height for the element.</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
  </doc:template>
  <xsl:template match="math:mtd" mode="stretch">
    <xsl:param name="width"/>
    <xsl:param name="height"/>

    <xsl:copy>
      <xsl:copy-of select="@*"/>

      <xsl:if test="$width != 0">
	<xsl:attribute name="t:WIDTH" select="$width"/>
      </xsl:if>

      <xsl:if test="$height != 0">
	<xsl:attribute name="t:HEIGHT" select="$height"/>
      </xsl:if>

      <xsl:copy-of select="child::*"/>
    </xsl:copy>
  </xsl:template>  


  <!-- In case of unsupported element, terminate with a meaningful message: -->
  <xsl:template match="math:*" mode="formatting">
    <xsl:message terminate="yes">
      <xsl:text>ERROR: Unsupported element </xsl:text>
      <xsl:element name="{local-name()}" namespace="{namespace-uri()}"/>
      <xsl:text> encountered.&#x0A;</xsl:text>
      <xsl:text>NOTE: pMML2SVG handles Presentation MathML only.</xsl:text>
    </xsl:message>
  </xsl:template>

</xsl:stylesheet>
