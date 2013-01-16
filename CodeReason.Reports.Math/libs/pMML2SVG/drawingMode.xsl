<?xml version="1.0"?>
<!-- 
###############################################################################
$Id: drawingMode.xsl 154 2009-05-12 14:59:29Z jjoslet $

CREATED: JUNE 2005

AUTHORS: [AST] Alexandre Stevens (alex@dourfestival.be) {STUDENT}
         [JHP] Justus H. Piater (Justus.Piater@ULg.ac.be) {PhD}
         [TMO] Thibault Mouton (Thibault.Mouton@student.ULg.ac.be) {STUDENT}
	 [JJO] Jerome Joslet (Jerome.Joslet@student.ULg.ac.be) {STUDENT}
         Montefiore Institute - University of Liege - Belgium
         
         [STM] Manuel Strehl {STUDENT}
         University of Regensburg - Germany

DESCRIPTION: This stylesheet contain all drawing template mode for pMML2SVG


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
		exclude-result-prefixes="math t xs func">

  <doc:reference>
    <info>
      <title>Drawing mode</title>
    </info>
  </doc:reference>

  <!-- ####################################################################
       TOKENS : mi, mn, mtext, ms (drawing mode)
       #################################################################### -->
  <doc:template match="math:mi|math:mn|math:mtext|math:ms" mode="draw">
    <refpurpose>Drawing a token.</refpurpose>

    <refdescription>
      <para>
	To draw these elements in the <acronym>SVG</acronym> file, the <acronym>SVG</acronym> <filename>text</filename> element is used.
	The placement of this element is done using the coordinates of the baseline's reference dot. To compute these coordinates, the height over baseline
	value is added to the upper left corner<filename>Y</filename> coordinate.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mi|math:mn|math:mtext|math:ms" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="fontName" tunnel="yes"/>

    <xsl:variable name="newX" select="$xShift + @t:X + @t:SHIFTX"/>
    <xsl:variable name="newY" select="$yShift + @t:Y + @t:HEIGHTOVERBASELINE"/>
    <xsl:variable name="fontSize" select="@t:FONTSIZE"/>

    <text>
      <xsl:attribute name="style" select="concat('font-family: ', string-join($fontName, ', '), '; ', @t:STYLE)"/>

      <xsl:attribute name="x" select="$newX"/>
      <xsl:attribute name="y" select="$newY"/>
      <xsl:attribute name="font-size" select="@t:FONTSIZE"/>

      <xsl:choose>
	<xsl:when test="@t:TEXT = '&#8519;'">e</xsl:when>
	<!--    <xsl:when test="@t:TEXT = 'd'">&#xE040;</xsl:when>  -->
	<xsl:otherwise>
	  <xsl:value-of select="@t:TEXT"/>
	</xsl:otherwise>
      </xsl:choose>
    </text>
  </xsl:template>

  <!-- ####################################################################
       TOKEN : mspace (drawing mode) : Nothing to draw
       #################################################################### -->
  <doc:template match="math:mspace" mode="draw">
    <refpurpose>Drawing a space.</refpurpose>

    <refdescription>
      <para>
	Nothing has to be drawn with these element. Therefore, an empty template has been created in the <acronym>XSLT</acronym> stylesheet.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mspace" mode="draw"/>

  <!-- ####################################################################
       TOKEN : mo (drawing mode)
       #################################################################### -->
  <doc:template match="math:mo" mode="draw">
    <refpurpose>Drawing an operator.</refpurpose>

    <refsee>
      <para><filename>drawHorizontalDelimiter</filename> and <filename>drawVerticalDelimiter</filename></para>
    </refsee>

    <refdescription>
      <para>
	First, the final coordinate is computed according to shift and left space values. There are three different display ways of an operator with
	respect to the direction of stretch. If the operator has to stretch vertically, the <filename>drawVerticalDelimiter</filename> is called,
	if the operator has to stretch horizontally, the <filename>drawHorizontalDelimiter</filename> is called. In all other cases, the operator
	is drawed like other token elements (<filename>mi</filename>, <filename>mn</filename>, etc.).
      </para>
      
      <para>
	The operator that has to be composed is grouped into a <acronym>SVG</acronym> <filename>g</filename> element with a common style attribute.
	This group will simplify the drawing of the stretched operator parts in <filename>drawXxxDelimiter</filename> template.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mo" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="fontName" tunnel="yes"/>

    <xsl:variable name="newX" select="$xShift + @t:X + @t:SHIFTX + @t:LSPACE"/>
    <xsl:variable name="newY" select="$yShift + @t:Y + @t:ACCENTSHIFT"/>

    <xsl:choose>
      <!-- Stretch vertical operator -->
      <xsl:when test="@t:STRETCHY = true() and @t:stretchVertical = true()">
	<g>
	  <xsl:attribute name="style" select="concat('font-family: ', string-join($fontName, ', '), '; ', @t:STYLE)"/>
	  <xsl:call-template name="drawVerticalDelimiter">
	    <xsl:with-param name="delimiter" select="@t:TEXT"/>
	    <xsl:with-param name="height" select="if (local-name(parent::*) = 'mtd')
						  then parent::*/@t:HEIGHT
						  else @t:HEIGHT"/>
	    <xsl:with-param name="x" select="$newX"/>
	    <xsl:with-param name="y" select="$newY + @t:HEIGHT"/>
	    <xsl:with-param name="fontSize" select="@t:FONTSIZE"/>
	    <xsl:with-param name="variant" select="@t:VARIANT"/>
	  </xsl:call-template>
	</g>
      </xsl:when>
      <!-- Stretch horizontal operator -->
      <xsl:when test="@t:STRETCHY = true() and @t:stretchHorizontal = true()">
	<g>
	  <xsl:attribute name="style" select="concat('font-family: ', string-join($fontName, ', '), '; ', @t:STYLE)"/>
	  <xsl:call-template name="drawHorizontalDelimiter">
	    <xsl:with-param name="delimiter" select="@t:TEXT"/>
	    <xsl:with-param name="width" select="if (parent::*/@t:EMBELLISH = true())
						 then parent::*/@t:WIDTH - parent::*/@t:LSPACE - parent::*/@t:RSPACE
						 else parent::*/@t:WIDTH - @t:RSPACE - @t:LSPACE"/>
	    <xsl:with-param name="x" select="$newX"/>
	    <xsl:with-param name="y" select="$newY + @t:HEIGHT"/>
	    <xsl:with-param name="fontSize" select="@t:FONTSIZE"/>
	    <xsl:with-param name="variant" select="@t:VARIANT"/>
	  </xsl:call-template>
	</g>
      </xsl:when>
      <!-- Simply draw operator -->
      <xsl:otherwise>
	<text>
	  <xsl:attribute name="x" select="$newX"/>
	  <xsl:attribute name="y" select="$newY + @t:HEIGHTOVERBASELINE"/>
	  <xsl:attribute name="font-size" select="@t:FONTSIZE"/>
	  <xsl:attribute name="style" select="concat('font-family: ', string-join($fontName, ', '), '; ', @t:STYLE)"/>
	  
	  <xsl:value-of select="@t:TEXT"/>
	</text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ####################################################################
       BOXES : math, mrow, merror, mphantom, menclose, mstyle (drawing mode)
       #################################################################### -->
  <doc:template match="math:math|math:mrow|math:merror|math:mphantom|math:menclose|math:mstyle"
		mode="draw">
    <refpurpose>Drawing a box.</refpurpose>

    <refsee>
      <para><filename>drawEnclose</filename></para>
    </refsee>

    <refdescription>
      <para>
	All the children of a row are grouped in a <acronym>SVG</acronym> <filename>g</filename> tag that represents a group of elements on the
	canvas. The style attribute is set on this tag to determine the default style of the box. After writing this tag, the drawing mode
	template of each child is called in order to draw them, except if the element is a <filename>mphantom</filename>. The children
	of a <filename>mphantom</filename> element are never drawn. These children are shifted on the y-axis if necessary (attribute
	<filename>SHIFT</filename>).
      </para>
      
      <para>
	If the element is an <filename>merror</filename> element, a box is drawn around child elements using the
	<acronym>SVG</acronym> <filename>rect</filename> tag that draws a rectangle.
      </para>
      
      <para>
	If the element is an <filename>menclose</filename> element, the <filename>drawEnclose</filename> template is called to
	write decoration around child elements. This template takes five parameters: <filename>X</filename> and <filename>Y</filename>
	coordinates, <filename>WIDTH</filename> and <filename>HEIGHT</filename> of the row and <filename>NOTATION</filename> attribute
	that is transformed into a sequence to handle multiple notation.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:math|math:mrow|math:merror|math:mphantom|math:menclose|math:mstyle"
		mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>

    <g>
      <xsl:attribute name="style" select="concat('font-family: ', string-join($fontName, ', '), '; ', @t:STYLE)"/>

    <xsl:choose>
      <!-- Do not display phantom -->
      <xsl:when test="local-name(.) = 'mphantom'"/>
      <!-- Display child -->
      <xsl:otherwise>
	<xsl:apply-templates select="child::*" mode="draw">
	  <xsl:with-param name="xShift" select="$xShift"/>
	  <xsl:with-param name="yShift" select="$yShift + @t:SHIFT"/>
	</xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:variable name="newX" select="@t:X + $xShift"/>
    <xsl:variable name="newY" select="@t:Y + $yShift"/>

    <xsl:if test="local-name(.) = 'merror'">
      <rect x="{$newX}" y="{$newY}"
	    width="{@t:WIDTH}" height="{@t:HEIGHT}"
	    fill="none" stroke="black" stroke-width="1"/>
    </xsl:if>

    <xsl:if test="local-name(.) = 'menclose'">
      <xsl:call-template name="drawEnclose">
	<xsl:with-param name="x" select="$newX"/>
	<xsl:with-param name="y" select="$newY"/>
	<xsl:with-param name="width" select="@t:WIDTH"/>
	<xsl:with-param name="height" select="@t:HEIGHT"/>
	<xsl:with-param name="notations" select="tokenize(@t:NOTATION, '\s+')"/>
      </xsl:call-template>
    </xsl:if>

    </g>
  </xsl:template>

  <!-- ####################################################################
       Draw menclose border
       
       I never call recursion with same parameter because I always remove
       one element from notations set.
       #################################################################### -->
  <doc:template name="drawEnclose">
    <refpurpose>Drawing encloses that decorate an menclose element.</refpurpose>

    <refdescription>
      <para>
	This template will browse all notations and draw the appropriate <filename>line</filename> and <filename>rect</filename>
	<acronym>SVG</acronym> tag corresponding to the notation. The circle is drawn using the <acronym>SVG</acronym>
	<filename>ellipse</filename> tag to draw an ellipse and the <filename>longdiv</filename> notation is drawn using
	the <acronym>SVG</acronym> <filename>path</filename> element to draw a curve. This element is used to draw complex
	paths on the canvas.
      </para>
    </refdescription>

    <refparameter>	
      <variablelist>
	<varlistentry>
	  <term><filename>x, y</filename></term>
	  <listitem>
	    <para><filename>X</filename> and <filename>Y</filename> coordinates of the box that is decorated.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>width</filename></term>
	  <listitem>
	    <para>Width of the box that is decorated.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>height</filename></term>
	  <listitem>
	    <para>Height of the box that is decorated.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>notations</filename></term>
	  <listitem>
	    <para>Notation that will decorate the box</para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
  </doc:template>
  <xsl:template name="drawEnclose">
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="width"/>
    <xsl:param name="height"/>
    <xsl:param name="notations"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="errorMargin" tunnel="yes"/>
    
    <xsl:if test="count($notations) &gt; 0">
      <xsl:choose>
	<!-- Box -->
	<xsl:when test="$notations[1] = 'box'">
	  <rect x="{$x}" y="{$y}"
		width="{$width}" height="{$height}"
		fill="none" stroke="black" stroke-width="1"/>
	</xsl:when>
	<!-- Rounded box -->
	<xsl:when test="$notations[1] = 'roundedbox'">
	  <rect x="{$x}" y="{$y}"
		width="{$width}" height="{$height}"
		rx="5px" ry="5px"
		fill="none" stroke="black" stroke-width="1"/>
	</xsl:when>
	<!-- Circle -->
	<xsl:when test="$notations[1] = 'circle'">
	  <ellipse cx="{$x + $width * 0.5}" cy="{$y + $height * 0.5}"
		   rx="{$width * 0.5}" ry="{$height * 0.5}"
		   fill="none" stroke="black" stroke-width="1"/>
	</xsl:when>
	<!-- Left -->
	<xsl:when test="$notations[1] = 'left'">
	  <line x1="{$x}" y1="{$y}" x2="{$x}" y2="{$y + $height}"
		fill="none" stroke="black" stroke-width="1"/>
	</xsl:when>
	<!-- Right -->
	<xsl:when test="$notations[1] = 'right'">
	  <line x1="{$x + $width}" y1="{$y}" x2="{$x + $width}" y2="{$y + $height}"
		fill="none" stroke="black" stroke-width="1"/>
	</xsl:when>
	<!-- Top -->
	<xsl:when test="$notations[1] = 'top'">
	  <line x1="{$x}" y1="{$y}" x2="{$x + $width}" y2="{$y}"
		fill="none" stroke="black" stroke-width="1"/>
	</xsl:when>
	<!-- Bottom -->
	<xsl:when test="$notations[1] = 'bottom'">
	  <line x1="{$x}" y1="{$y + $height}" x2="{$x + $width}" y2="{$y + $height}"
		fill="none" stroke="black" stroke-width="1"/>
	</xsl:when>
	<!-- Updiagonalstrike -->
	<xsl:when test="$notations[1] = 'updiagonalstrike'">
	  <line x1="{$x}" y1="{$y + $height}" x2="{$x + $width}" y2="{$y}"
		fill="none" stroke="black" stroke-width="1"/>
	</xsl:when>
	<!-- Downdiagonalstrike -->
	<xsl:when test="$notations[1] = 'downdiagonalstrike'">
	  <line x1="{$x}" y1="{$y}" x2="{$x + $width}" y2="{$y + $height}"
		fill="none" stroke="black" stroke-width="1"/>
	</xsl:when>
	<!-- Verticalstrike -->
	<xsl:when test="$notations[1] = 'verticalstrike'">
	  <line x1="{$x + $width * 0.5}" y1="{$y}" x2="{$x + $width * 0.5}" y2="{$y + $height}"
		fill="none" stroke="black" stroke-width="1"/>
	</xsl:when>
	<!-- Horizontalstrike -->
	<xsl:when test="$notations[1] = 'horizontalstrike'">
	  <line x1="{$x}" y1="{$y + $height * 0.5}" x2="{$x + $width}" y2="{$y + $height * 0.5}"
		fill="none" stroke="black" stroke-width="1"/>
	</xsl:when>
	<!-- Actuarial -->
	<xsl:when test="$notations[1] = 'actuarial'">
	  <line x1="{$x}" y1="{$y}" x2="{$x + $width}" y2="{$y}"
		fill="none" stroke="black" stroke-width="1"/> <!-- TOP -->
	  <line x1="{$x + $width}" y1="{$y}" x2="{$x + $width}" y2="{$y + $height}"
		fill="none" stroke="black" stroke-width="1"/> <!-- RIGHT -->
	</xsl:when>
	<!-- Radical -->
	<xsl:when test="$notations[1] = 'radical'">
	   <line x1="{$x}"
		 y1="{$y + (0.5 * $height)}"
		 x2="{$x + (0.2 * 2 * $errorMargin)}"
		 y2="{$y + (0.3 * $height)}"
		 fill="none" stroke="black" stroke-width="1"/>
	   <line x1="{$x + (0.2 * 2 * $errorMargin)}"
		 y1="{$y + (0.3 * $height)}"
		 x2="{$x + (0.5 * 2 * $errorMargin)}"
		 y2="{$y + $height}"
		 fill="none" stroke="black" stroke-width="2"/>
	   <line x1="{$x + (0.5 * 2 * $errorMargin)}"
		 y1="{$y + $height}"
		 x2="{$x + 2 * $errorMargin}"
		 y2="{$y}"
		 fill="none" stroke="black" stroke-width="1"/>
	   <line x1="{$x + 2 * $errorMargin}"
		 y1="{$y}"
		 x2="{$x + $width}"
		 y2="{$y}"
		 fill="none" stroke="black" stroke-width="1"/>
	</xsl:when>
	<!-- Fallback : longdiv -->
	<xsl:otherwise>
	  <path d="M{$x},{$y} C{$x + 2 * $errorMargin},{$y} {$x + 2 * $errorMargin},{$y + $height} {$x},{$y + $height}"
		fill="none" stroke="black" stroke-width="1"/>
	  <line x1="{$x}" y1="{$y}" x2="{$x + $width}" y2="{$y}"
		fill="none" stroke="black" stroke-width="1"/> <!-- TOP -->
	</xsl:otherwise>
      </xsl:choose>

      <!-- Recursion -->
      <xsl:call-template name="drawEnclose">
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="width" select="$width"/>
	<xsl:with-param name="height" select="$height"/>
	<xsl:with-param name="notations" select="$notations[position() &gt; 1]"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       MSUP (drawing mode)
       #################################################################### -->
  <doc:template match="math:msup" mode="draw">
    <refpurpose>Drawing a superscript.</refpurpose>

    <refdescription>
      <para>
	The drawing of this element is very simple. It calls the drawing mode template of each child by adding the shift values that have been computed
	in the formatting mode.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:msup" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>
    <xsl:apply-templates select="child::*[1]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_BASE"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="child::*[2]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTX_SUPERSCRIPT"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_SUPERSCRIPT"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ####################################################################
       MSUB (drawing mode)
       #################################################################### -->
  <doc:template match="math:msub" mode="draw">
    <refpurpose>Drawing a subscript.</refpurpose>

    <refdescription>
      <para>
	The drawing mode is exactly similar to the <filename>msup</filename> element. Only the name of the shift attributes differ.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:msub" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>
    <xsl:apply-templates select="child::*[1]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift"/>
      <xsl:with-param name="yShift" select="$yShift"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="child::*[2]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTX_SUBSCRIPT"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_SUBSCRIPT"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ####################################################################
       MSUBSUP (drawing mode)
       #################################################################### -->
  <doc:template match="math:msubsup" mode="draw">
    <refpurpose>Drawing both a superscript and a subscript.</refpurpose>

    <refdescription>
      <para>
	The drawing mode simply draws the base, the subscript and the superscript are drawn by calling the draw mode template of each child. The shift values 
	are added when calling these templates.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:msubsup" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>
    <xsl:apply-templates select="child::*[1]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_BASE"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="child::*[2]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTX_SUBSCRIPT"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_SUBSCRIPT"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="child::*[3]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTX_SUPERSCRIPT"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_SUPERSCRIPT"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ####################################################################
       MOVER (drawing mode)
       #################################################################### -->
  <doc:template match="math:mover" mode="draw">
    <refpurpose>Drawing an overscript.</refpurpose>

    <refdescription>
      <para>
	The drawing mode consists simply of drawing the children of <filename>mover</filename> by calling their template in drawing mode. The shift values
	are added in the call to correctly place each element.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mover" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>
    <xsl:apply-templates select="child::*[1]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTX_BASE"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_BASE"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="child::*[2]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTX_OVERSCRIPT"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_OVERSCRIPT"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ####################################################################
       MUNDER (drawing mode)
       #################################################################### -->
  <doc:template match="math:munder" mode="draw">
    <refpurpose>Drawing an underscript.</refpurpose>

    <refdescription>
      <para>
	Like the formatting mode, the drawing mode of <filename>munder</filename> element is exactly the same as the <filename>mover</filename> one,
	except some variable names.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:munder" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>
    <xsl:apply-templates select="child::*[1]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTX_BASE"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_BASE"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="child::*[2]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTX_UNDERSCRIPT"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_UNDERSCRIPT"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ####################################################################
       MUNDEROVER (drawing mode)
       #################################################################### -->
  <doc:template match="math:munderover" mode="draw">
    <refpurpose>Drawing both an overscript and an underscript.</refpurpose>

    <refdescription>
      <para>
	All children are simply drawn by using the corresponding drawing mode template with the corresponding shift values.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:munderover" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>
    <xsl:apply-templates select="child::*[1]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTX_BASE"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_BASE"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="child::*[2]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTX_UNDERSCRIPT"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_UNDERSCRIPT"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="child::*[3]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTX_OVERSCRIPT"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_OVERSCRIPT"/>
    </xsl:apply-templates>
  </xsl:template>

  <!-- ####################################################################
       MFRAC (drawing mode)
       #################################################################### -->
  <doc:template match="math:mfrac" mode="draw">
    <refpurpose>Drawing a fraction.</refpurpose>

    <refdescription>
      <para>
	The drawing mode is quite simple. It draws each child by calling the drawing mode on the children using computed shift values from the tree.
	Finally, it draws a line for the fraction bar using the <acronym>SVG</acronym> <filename>line</filename> element, <filename>Y</filename>
	coordinate and <filename>height</filename> from the annotated node.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mfrac" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>
    <xsl:apply-templates select="child::*[1]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTXNUM"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTYNUM"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="child::*[2]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift + @t:SHIFTXDEN"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTYDEN"/>
    </xsl:apply-templates>
    <line x1="{@t:X + $xShift}"            y1="{@t:FRAC_BAR_Y + $yShift}"
	  x2="{@t:X + $xShift + @t:WIDTH}" y2="{@t:FRAC_BAR_Y + $yShift}"
	  fill="none" stroke="black" stroke-width="{@t:FRAC_BAR_HEIGHT}"/>
  </xsl:template>

  <!-- ####################################################################
       MSQRT (drawing mode)
       #################################################################### -->
  <doc:template match="math:msqrt" mode="draw">
    <refpurpose>Drawing a square root.</refpurpose>

    <refdescription>
      <para>
	The drawing mode first draws each child by calling the corresponding template in the drawing mode. After that, the square root symbol has to be drawn
	in front of the children and a line is added over them. It is done by using four <acronym>SVG</acronym> <filename>line</filename> elements.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:msqrt" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="rtFrnSpcFac" tunnel="yes"/>

    <xsl:apply-templates select="child::*" mode="draw">
      <xsl:with-param name="xShift" select="$xShift"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFT"/>
    </xsl:apply-templates>

    <xsl:variable name="lineWeight" select="@t:FONTSIZE div 50"/>
    <xsl:variable name="newX" select="@t:X + $xShift + 0.05 * @t:FONTSIZE"/>
    <xsl:variable name="newY" select="@t:Y + $yShift"/>
    <xsl:variable name="frontSpace" select="@t:FONTSIZE * ($rtFrnSpcFac - 0.05)"/>

    <line x1="{$newX}"
	  y1="{$newY + (0.5 * @t:HEIGHT)}"
	  x2="{$newX + (0.2 * $frontSpace)}"
	  y2="{$newY + (0.3 * @t:HEIGHT)}"
	  fill="none" stroke="black" stroke-width="{$lineWeight}"/>
    <line x1="{$newX + (0.2 * $frontSpace)}"
	  y1="{$newY + (0.3 * @t:HEIGHT)}"
	  x2="{$newX + (0.5 * $frontSpace)}"
	  y2="{$newY + @t:HEIGHT}"
	  fill="none" stroke="black" stroke-width="{$lineWeight * 2}"/>
    <line x1="{$newX + (0.5 * $frontSpace)}"
	  y1="{$newY + @t:HEIGHT}"
	  x2="{$newX + $frontSpace}"
	  y2="{$newY}"
	  fill="none" stroke="black" stroke-width="{$lineWeight}"/>
    <line x1="{$newX + $frontSpace}"
	  y1="{$newY}"
	  x2="{$newX + @t:WIDTH}"
	  y2="{$newY}"
	  fill="none" stroke="black" stroke-width="{$lineWeight}"/>
  </xsl:template>

  <!-- ####################################################################
       MROOT (drawing mode)
       #################################################################### -->
  <doc:template match="math:mroot" mode="draw">
    <refpurpose>Drawing a n-ary root.</refpurpose>

    <refdescription>
      <para>
	First, the base and the index are drawn using the appropriate template in the drawing mode. Shift values are also added to <filename>Y</filename> 
	coordinate to draw them in the correct place. After that, the root symbol is drawn the same way as in the <filename>msqrt</filename> element.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mroot" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="rtFrnSpcFac" tunnel="yes"/>

    <xsl:apply-templates select="child::*[1]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_BASE"/>
    </xsl:apply-templates>
    <xsl:apply-templates select="child::*[2]" mode="draw">
      <xsl:with-param name="xShift" select="$xShift"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFTY_INDEX"/>
    </xsl:apply-templates>

    <xsl:variable name="lineWeight" select="@t:FONTSIZE div 50"/>
    <xsl:variable name="newX" select="@t:X + $xShift + 0.05 * @t:FONTSIZE"/>
    <xsl:variable name="newY" select="@t:RADICAL_TOP_Y  + $yShift"/>
    <xsl:variable name="frontSpace" select="@t:FONTSIZE * ($rtFrnSpcFac - 0.05)"/>
    <line x1="{$newX}"
	  y1="{$newY + (0.5 * @t:RADICAL_HEIGHT)}"
	  x2="{$newX + (0.2 * $frontSpace)}"
	  y2="{$newY + (0.3 * @t:RADICAL_HEIGHT)}"
	  fill="none" stroke="black" stroke-width="{$lineWeight}"/>
    <line x1="{$newX + (0.2 * $frontSpace)}"
	  y1="{$newY + (0.3 * @t:RADICAL_HEIGHT)}"
	  x2="{$newX + (0.5 * $frontSpace)}"
	  y2="{$newY + @t:RADICAL_HEIGHT}"
	  fill="none" stroke="black" stroke-width="{$lineWeight * 2}"/>
    <line x1="{$newX + (0.5 * $frontSpace)}"
	  y1="{$newY + @t:RADICAL_HEIGHT}"
	  x2="{$newX + $frontSpace}"
	  y2="{$newY}"
	  fill="none" stroke="black" stroke-width="{$lineWeight}"/>
    <line x1="{$newX + $frontSpace}"
	  y1="{$newY}"
	  x2="{$newX + @t:WIDTH}"
	  y2="{$newY}"
	  fill="none" stroke="black" stroke-width="{$lineWeight}"/>
  </xsl:template>

  <!-- ####################################################################
       MTABLE (drawing mode)
       #################################################################### -->
  <doc:template match="math:mtable" mode="draw">
    <refpurpose>Drawing a table.</refpurpose>

    <refsee>
      <para><filename>drawRows</filename></para>
    </refsee>
    <refdescription>
      <para>
	To apply the correct shift values on each cell, the drawing mode calls an other template: <filename>drawRows</filename>. This template will
	draw each row by using the computed shift values.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mtable" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>

    <xsl:call-template name="drawRows">
      <xsl:with-param name="rows" select="child::*"/>
      <xsl:with-param name="shiftY" select="tokenize(@t:SHIFTY, ' ')"/>
      <xsl:with-param name="shiftX" select="tokenize(@t:SHIFTX, ' ; ')"/>
      <xsl:with-param name="xShift" select="$xShift"/>
      <xsl:with-param name="yShift" select="$yShift"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ####################################################################
       Draw table rows
       #################################################################### -->
  <doc:template name="drawRows">
    <refpurpose>Used to give the correct shift value to the drawing mode template of each row.</refpurpose>

    <refdescription>
      <para>
	This template calls <filename>mtr</filename> drawing mode template on each row by using the correct shift value. The y-axis shift value
	is direclty added to the <filename>yShift</filename> parameters. The x-axis values for a row are transformed into a sequence and given
	to the template through the <filename>shiftX</filename> parameter.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term>rows</term>
	  <listitem>
	    <para>Sequence of <filename>mtr</filename> elements.</para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>shiftX</filename></term>
	  <listitem>
	    <para>
	      Sequence of x-axis shift values for each cell in each row.
	    </para>
	  </listitem>
	</varlistentry>
	
	<varlistentry>
	  <term><filename>shiftY</filename></term>
	  <listitem>
	    <para>
	      Sequence of y-axis shift value to move rows to their final place.
	    </para>
	  </listitem>
	</varlistentry>
	
	<varlistentry>
	  <term><filename>xShift and yShift</filename></term>
	  <listitem>
	    <para>
	      Required parameters of drawing mode template.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
  </doc:template>
  <xsl:template name="drawRows">
    <xsl:param name="rows"/>
    <xsl:param name="shiftY"/>
    <xsl:param name="shiftX"/>
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>

    <xsl:if test="$rows">
      <xsl:apply-templates select="$rows[1]" mode="draw">
	<xsl:with-param name="xShift" select="$xShift"/>
	<xsl:with-param name="yShift" select="$yShift + number($shiftY[1])"/>
	<xsl:with-param name="shiftX" select="$shiftX[1]"/>
      </xsl:apply-templates>  

      <xsl:call-template name="drawRows">
	<xsl:with-param name="rows" select="$rows[position() &gt; 1]"/>
	<xsl:with-param name="shiftY" select="$shiftY[position() &gt; 1]"/>
	<xsl:with-param name="shiftX" select="$shiftX[position() &gt; 1]"/>
	<xsl:with-param name="xShift" select="$xShift"/>
	<xsl:with-param name="yShift" select="$yShift"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       MTR (drawing mode)
       #################################################################### -->
  <doc:template match="math:mtr" mode="draw">
    <refpurpose>Drawing a row in a table.</refpurpose>

    <refsee>
      <para><filename>drawCols</filename></para>
    </refsee>

    <refdescription>
      <para>
	To apply the correct shift values on each cell, the drawing mode calls an other template: <filename>drawCols</filename>. This template will
	draw each cell by using the computed shift values.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mtr" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>
    <xsl:param name="shiftX"/>

    <xsl:call-template name="drawCols">
      <xsl:with-param name="rows" select="child::*"/>
      <xsl:with-param name="shiftX" select="tokenize($shiftX, ' ')"/>
      <xsl:with-param name="xShift" select="$xShift"/>
      <xsl:with-param name="yShift" select="$yShift + @t:SHIFT"/>
    </xsl:call-template>
  </xsl:template>

  <!-- ####################################################################
       Draw table cols
       
       I never call recursion with same parameter because I always remove
       one element from rows and shiftX set.
       #################################################################### -->
  <doc:template name="drawCols">
    <refpurpose>This template is used to give the correct shift value to the drawing mode template of each cell.</refpurpose>

    <refdescription>
      <para>
	This template calls <filename>mtd</filename> drawing mode template on each cell by using the correct shift value. The x-axis shift value
	is direclty added to the <filename>xShift</filename> parameters.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term><filename>rows</filename></term>
	  <listitem>
	    <para>
	      Sequence of <filename>mtd</filename> elements.
	    </para>
	  </listitem>
	</varlistentry>
	
	<varlistentry>
	  <term><filename>shiftX</filename></term>
	  <listitem>
	    <para>
	      Sequence of x-axis shift values for each cell in this row.
	    </para>
	  </listitem>
	</varlistentry>
	
	<varlistentry>
	  <term><filename>xShift and yShift</filename></term>
	  <listitem>
	    <para>
	      Required parameters of drawing mode template.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
  </doc:template>
  <xsl:template name="drawCols">
    <xsl:param name="rows"/>
    <xsl:param name="shiftX"/>
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>

    <xsl:if test="$rows">
      <xsl:apply-templates select="$rows[1]" mode="draw">
	<xsl:with-param name="xShift" select="$xShift + number($shiftX[1])"/>
	<xsl:with-param name="yShift" select="$yShift"/>
	<xsl:with-param name="shiftX" select="$shiftX"/>
      </xsl:apply-templates>  

      <xsl:call-template name="drawCols">
	<xsl:with-param name="rows" select="$rows[position() &gt; 1]"/>
	<xsl:with-param name="shiftX" select="$shiftX[position() &gt; 1]"/>
	<xsl:with-param name="xShift" select="$xShift"/>
	<xsl:with-param name="yShift" select="$yShift"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       MTD (drawing mode)
       #################################################################### -->
  <doc:template match="math:mtd" mode="draw">
    <refpurpose>Drawing a cell of a table.</refpurpose>

    <refdescription>
      <para>
	This mode behaves exactly like the <filename>mrow</filename> drawing mode. It calls the drawing mode of all its children.
      </para>
    </refdescription>
  </doc:template>
  <xsl:template match="math:mtd" mode="draw">
    <xsl:param name="xShift"/>
    <xsl:param name="yShift"/>

    <xsl:apply-templates select="child::*" mode="draw">
      <xsl:with-param name="xShift" select="$xShift"/>
      <xsl:with-param name="yShift" select="$yShift"/>
    </xsl:apply-templates>  
  </xsl:template>

  <!-- ####################################################################
       Draw vertical delimiter and stretch or compose symbol if necessary
       #################################################################### -->
  <doc:template name="drawVerticalDelimiter">
    <refpurpose>Composes a vertical stretchy operator.</refpurpose>

    <refsee>
      <para><filename>findBestSize</filename> and <filename>drawVerticalExtenser</filename></para>
    </refsee>

    <refdescription>
      <para>
	First of all, a verification must be done to know if the operator has to be stretched. If it does not have to stretch, it will be simply drawn
	like a non-stretchy operator. After that, another verification checks if the operator can be composed, stretched or not. This verification
	is done using the two structures: <filename>delimPart</filename> and <filename>delimScale</filename>. If the operator cannot be composed
	or stretched, it will simply be centered by using a <acronym>SVG</acronym> <filename>text</filename> element. If the operator is in the 
	<filename>delimPart</filename> structure, the operator will be composed, if the operator is in the <filename>delimScale</filename>
	structure, the operator will be scaled.
      </para>

      <simplesect>
	<title>Compose</title>
	
	<para>
	  The number of parts needed to compose the symbols is retrieved from the structure. This number will be used to know which type of operator
	  will be composed. After that, the index of part in the structure will be computed and the bounding box of each part will be retrieved from
	  the metrics. A correction is done to avoid the small gaps on the canvas. The next line computes the number of extensers that will be added 
	  and the final font size of the operator calling the function <filename>findBestSize</filename>. A new font size is computed in order to have 
	  a round number of parts.
	</para>

	<para>
	  After all these computations, the bottom and the top parts of the operator will be drawn using a <acronym>SVG</acronym> 
	  <filename>text</filename> element. The top delimiter is only drawn if there are more than two parts or if the
	  <filename>extenser</filename> attribute is <filename>bottom</filename>. In the same way, the bottom delimiter is only draw if 
	  there is more than two parts or if the <filename>extenser</filename> attribute is <filename>top</filename>. Now, the extenser
	  has to be drawn and the way to draw them depends on the number of parts.
	</para>

	<para>
	  If the operator has four parts (like a curly bracket for example), a middle part is then added using a <filename>text</filename> element and 
	  two groups of extenser are drawn around this middle part using <filename>drawVerticalExtenser</filename> function. The extenser is only
	  drawn if the number returned by <filename>findBestSize</filename> is bigger than zero.
	</para>

	<para>
	  If the operator has two or three parts, the extenser will be added if the number returned by <filename>findBestSize</filename> is bigger than zero.
	  If the operator has two parts and if the extensers have to be drawn on the top, the <filename>Y</filename> coordinate has
	  to be on the top of the box. In the other cases, it has to be under the top part of the operator.
	</para>
      </simplesect>

      <simplesect>
	<title>Scale</title>
	
	<para>
	  First, a <filename>scale</filename> factor is computed and then the operator is drawn in a <filename>text</filename> box that
	  is transformed using the <acronym>SVG</acronym> <filename>transform</filename> attribute and a <filename>scale</filename>
	  transformation. The <filename>Y</filename> coordinate has to be corrected because the <filename>scale</filename> transformation
	  modifies the coordinate system.
	</para>
      </simplesect>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term><filename>x, y</filename></term>
	  <listitem>
	    <para>
	      <filename>X</filename> and <filename>Y</filename> coordinates of the bottom left corner of the operator box.
	    </para>
	  </listitem>
	</varlistentry>
	
	<varlistentry>
	  <term><filename>delimiter</filename></term>
	  <listitem>
	    <para>
	      Operator to stretch.
	    </para>
	  </listitem>
	</varlistentry>
	
	<varlistentry>
	  <term><filename>height</filename></term>
	  <listitem>
	    <para>
	      Total height of the box that the operator has to fill.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>fontSize</filename></term>
	  <listitem>
	    <para>
	      Initial font size of the operator.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>variant</filename></term>
	  <listitem>
	    <para>
	      Font variant for the operator.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
  </doc:template>
  <xsl:template name="drawVerticalDelimiter">
    <xsl:param name="delimiter"/>
    <xsl:param name="height"/>
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="fontSize"/>
    <xsl:param name="variant"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="fontName" tunnel="yes"/>

    <xsl:variable name="bbox" select="func:findHeight($delimiter, $fontName, $variant)"/>
    <xsl:variable name="fontHeight" select="$bbox[1] - $bbox[2]"/>

    <!-- Do we need to stretch delimiter ? -->
    <xsl:variable name="stretchDelim" select="$height div ($fontHeight * $fontSize) &gt; 1"/>

    <xsl:choose>
      <!-- Delimiter is composed of multiple parts -->
      <xsl:when test="(count($delimPart/*[@vname=$delimiter]/*) &gt; 0) and $stretchDelim">
	<xsl:variable name="numParts" select="count($delimPart/*[@vname=$delimiter]/*)"/>
	<!-- Compute parts indexes -->
	<xsl:variable name="topIndex" select="1"/>
	<xsl:variable name="middleIndex" select="3"/>
	<xsl:variable name="bottomIndex" select="if ($numParts = 2)
						 then 1
						 else 2"/>
	<xsl:variable name="extenserIndex" select="$numParts"/>

	<!-- Small size correction to avoid small gap in the composition -->
	<xsl:variable name="sizeCorrection" select="0.02"/>

	<!-- Compute parts size -->
	<xsl:variable name="initTopSize" select="if ($numParts != 2 or $delimPart/*[@vname=$delimiter]/@extenser = 'bottom')
						 then func:findHeight($delimPart/*[@vname=$delimiter]/*[$topIndex], $fontName, $variant)
						 else (0, 0)"/>
	<xsl:variable name="topSize" select="if ($initTopSize[1] != 0)
					     then ($initTopSize[1] - $sizeCorrection, $initTopSize[2])
					     else (0, 0)"/>
	<xsl:variable name="initMiddleSize" select="if ($numParts = 4)
						    then func:findHeight($delimPart/*[@vname=$delimiter]/*[$middleIndex], $fontName, $variant)
						    else (0, 0)"/>
	<xsl:variable name="middleSize" select="if ($initMiddleSize[1] != 0)
						then ($initMiddleSize[1] - $sizeCorrection, $initMiddleSize[2])
						else (0, 0)"/>
	<xsl:variable name="initBottomSize" select="if ($numParts != 2 or $delimPart/*[@vname=$delimiter]/@extenser = 'top')
						    then func:findHeight($delimPart/*[@vname=$delimiter]/*[$bottomIndex], $fontName, $variant)
						    else (0, 0)"/>
	<xsl:variable name="bottomSize" select="if ($initBottomSize[1] != 0)
						then ($initBottomSize[1] - $sizeCorrection, $initBottomSize[2])
						else (0, 0)"/>

	<xsl:variable name="partsSize" select="$topSize[1] - $topSize[2] + $middleSize[1] - $middleSize[2] + $bottomSize[1] - $bottomSize[2]"/>
	<xsl:variable name="extenserBbox" select="func:findHeight($delimPart/*[@vname=$delimiter]/*[$extenserIndex], $fontName, $variant)"/>
	<xsl:variable name="extenserSize" select="$extenserBbox[1] - $extenserBbox[2] - $sizeCorrection"/>

	<xsl:variable name="bestSize" select="func:findBestSize($height, $fontSize, $numParts - 1, $partsSize, $extenserSize)"/>

	<!-- Top delimiter part -->
	<xsl:if test="$numParts != 2 or $delimPart/*[@vname=$delimiter]/@extenser = 'bottom'">
	  <text>
	    <xsl:attribute name="x" select="$x"/>
	    <xsl:attribute name="y" select="$y - (- $topSize[2] + $bottomSize[1] - $bottomSize[2] + $middleSize[1] - $middleSize[2] 
					    + $extenserSize * $bestSize[1]) * $bestSize[2]"/>
	    <xsl:attribute name="font-size" select="$bestSize[2]"/>

	    <xsl:value-of select="$delimPart/*[@vname=$delimiter]/*[$topIndex]"/>
	  </text>
	</xsl:if>

	<!-- Bottom delimiter part -->
	<xsl:if test="$numParts != 2 or $delimPart/*[@vname=$delimiter]/@extenser = 'top'">
	  <text>
	    <xsl:attribute name="x" select="$x"/>
	    <xsl:attribute name="y" select="$y + $bottomSize[2] * $bestSize[2]"/>
	    <xsl:attribute name="font-size" select="$bestSize[2]"/>

	    <xsl:value-of select="$delimPart/*[@vname=$delimiter]/*[$bottomIndex]"/>
	  </text>
	</xsl:if>

	<xsl:choose>
	  <!-- Delimiter has four parts -->
	  <xsl:when test="$numParts = 4">
	    <!-- Center delimiter part -->
	    <text>
	      <xsl:attribute name="x" select="$x"/>
	      <xsl:attribute name="y" select="$y - (- $middleSize[2] + $bottomSize[1] - $bottomSize[2] + 
					      $extenserSize * $bestSize[1] * 0.5) * $bestSize[2]"/>
	      <xsl:attribute name="font-size" select="$bestSize[2]"/>
	      
	      <xsl:value-of select="$delimPart/*[@vname=$delimiter]/*[$middleIndex]"/>
	    </text>
	    
	    <!-- Need to add part extenser -->
	    <xsl:if test="$bestSize[1] != 0">
	      <!-- Top extenser -->
	      <xsl:call-template name="drawVerticalExtenser">
		<xsl:with-param name="n" select="$bestSize[1] div 2"/>
		<xsl:with-param name="x" select="$x"/>
		<xsl:with-param name="y" select="$y - (- $extenserBbox[2] + $bottomSize[1] - $bottomSize[2] + 
						 $extenserSize * $bestSize[1] * 0.5 + $middleSize[1] - $middleSize[2]) * $bestSize[2]"/>
		<xsl:with-param name="extenser" select="$delimPart/*[@vname=$delimiter]/*[$extenserIndex]"/>
		<xsl:with-param name="extenserSize" select="$extenserSize"/>
		<xsl:with-param name="fontSize" select="$bestSize[2]"/>
	      </xsl:call-template>
	      
	      <!-- Bottom extenser -->
	      <xsl:call-template name="drawVerticalExtenser">
		<xsl:with-param name="n" select="$bestSize[1] div 2"/>
		<xsl:with-param name="x" select="$x"/>
		<xsl:with-param name="y" select="$y - (- $extenserBbox[2] + $bottomSize[1] - $bottomSize[2]) * $bestSize[2]"/>
		<xsl:with-param name="extenser" select="$delimPart/*[@vname=$delimiter]/*[$extenserIndex]"/>
		<xsl:with-param name="extenserSize" select="$extenserSize"/>
		<xsl:with-param name="fontSize" select="$bestSize[2]"/>
	      </xsl:call-template>
	    </xsl:if>
	  </xsl:when>
	  
	  <!-- Delimiter has three or two parts -->
	  <xsl:otherwise>
	    <!-- Need to add part extenser -->
	    <xsl:if test="$bestSize[1] != 0">
	      <xsl:call-template name="drawVerticalExtenser">
		<xsl:with-param name="n" select="$bestSize[1]"/>
		<xsl:with-param name="x" select="$x"/>
		<xsl:with-param name="y">
		  <xsl:choose>
		    <xsl:when test="$numParts = 3 or $delimPart/*[@vname=$delimiter]/@extenser = 'top'">
		      <xsl:value-of select="$y - (- $extenserBbox[2] + $bottomSize[1] - $bottomSize[2]) * $bestSize[2]"/>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:value-of select="$y + $extenserBbox[2] * $bestSize[2]"/>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:with-param>
		<xsl:with-param name="extenser" select="$delimPart/*[@vname=$delimiter]/*[$extenserIndex]"/>
		<xsl:with-param name="extenserSize" select="$extenserSize"/>
		<xsl:with-param name="fontSize" select="$bestSize[2]"/>
	      </xsl:call-template>
	    </xsl:if>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
	
      <!-- Delimiter can only be stretched -->
      <xsl:when test="(index-of($delimScale, $delimiter) &gt;= 0) and $stretchDelim">
	<!-- Draw scaled delimiter -->
	<xsl:variable name="scale" select="$height div ($fontHeight * $fontSize)"/>
	<text>
	  <xsl:attribute name="x" select="$x"/>
	  <xsl:attribute name="y" select="($y + $bbox[2] * $fontSize * $scale)  div $scale"/>
	  <xsl:attribute name="font-size" select="$fontSize"/>
	  <!-- Scale delimiter -->
	  <xsl:attribute name="transform" select="concat('scale(1, ', $scale, ')')"/>
	  
	  <xsl:value-of select="$delimiter"/>
	</text>
      </xsl:when>

      <!-- Delimiter can't be composed or stretched -->
      <xsl:otherwise>
	<!-- Simply draw and center delimiter -->
	<xsl:variable name="delimHeight" select="$fontHeight * $fontSize"/>

	<text>
	  <xsl:attribute name="x" select="$x"/>
	  <xsl:attribute name="y">
	    <xsl:choose>
	      <xsl:when test="$delimHeight &gt;= $height">
		<xsl:value-of select="$y + $bbox[2] * $fontSize"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="$y - $height div 2 + $delimHeight div 2 + $bbox[2] * $fontSize"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>
	  <xsl:attribute name="font-size" select="$fontSize"/>

	  <xsl:value-of select="$delimiter"/>
	</text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ####################################################################
       Draw n vertical extenser from (x,y) to 
       (x, y - n * fontSize * extenserSize)
       
       I never call function recursion with same parameters as first call
       because I always decrease n (the number of glyph to draw).
       #################################################################### -->
  <doc:template name="drawVerticalExtenser">
    <refpurpose>Draws 'n' vertical 'extenser' of size 'extenserSize' from (x, y) to (x, y - n * fontSize * extenserSize).</refpurpose>

    <refdescription>
      It simply draws an extenser, then, if <filename>n</filename> is greater than one, the function is called again with next 
      <filename>Y</filename> coordinate and decremented <filename>n</filename>.
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term><filename>n</filename></term>
	  <listitem><para>Number of extensers to draw</para></listitem>
	</varlistentry>
	
	<varlistentry>
	  <term><filename>x</filename></term>
	  <listitem><para><filename>X</filename> coordinate for extensers</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>y</filename></term>
	  <listitem><para><filename>Y</filename> coordinate for the bottom extenser</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>extenser</filename></term>
	  <listitem><para>Extenser to draw</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>extenserSize</filename></term>
	  <listitem><para>Extenser size (in em)</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>fontSize</filename></term>
	  <listitem><para>Size of the font to draw the extenser</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>rotate</filename></term>
	  <listitem><para><filename>true</filename> if the extenser has to be rotated</para></listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
  </doc:template>
  <xsl:template name="drawVerticalExtenser">
    <xsl:param name="n"/>
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="extenser"/>
    <xsl:param name="extenserSize"/>
    <xsl:param name="fontSize"/>
    <xsl:param name="rotate" select="false()"/>

    <!-- Draw an extenser -->
    <text>
      <xsl:attribute name="x" select="$x"/>
      <xsl:attribute name="y" select="$y"/>
      <xsl:attribute name="font-size" select="$fontSize"/>

      <xsl:if test="$rotate">
	<xsl:attribute name="transform" select="concat('rotate(90, ', $x, ', ', $y, ')')"/>
      </xsl:if>
      
      <xsl:value-of select="$extenser"/>
    </text>

    <!-- Recursion -->
    <xsl:if test="$n - 1 &gt; 0">
      <xsl:call-template name="drawVerticalExtenser">
	<xsl:with-param name="n" select="$n - 1"/>
	<xsl:with-param name="x" select="$x"/>
	<xsl:with-param name="y" select="$y - $fontSize * $extenserSize"/>
	<xsl:with-param name="extenser" select="$extenser"/>
	<xsl:with-param name="extenserSize" select="$extenserSize"/>
	<xsl:with-param name="fontSize" select="$fontSize"/>
	<xsl:with-param name="rotate" select="$rotate"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       Draw horizontal delimiter and stretch or compose symbol if necessary
       #################################################################### -->
  <doc:template name="drawHorizontalDelimiter">
    <refpurpose>Composes a horizontal stretchy operator.</refpurpose>

    <refsee>
      <para><filename>findBestSize</filename> and <filename>drawHorizontalExtenser</filename></para>
    </refsee>

    <refdescription>
      <para>
	The <filename>drawHorizontalDelimiter</filename> template is similar to the vertical one except in composition of operator. Some operators
	have to be composed with a vertical part that is rotated. In <acronym>SVG</acronym>, the rotation is done using the <filename>transform</filename> 
	attribute and a <filename>rotate</filename> transformation. The modification that is done against the vertical composition is the check
	of the <filename>hrotate</filename> attributes of the <filename>delimPart</filename> that indicates if parts have to be rotated. And, using
	the <filename>hrotate</filename> values, the measure of the part that must retrieve the height if the parts are rotated, or the width of
	parts if not.
      </para>
      
      <para>
	The other modifications concern adding the rotate transformation when the parts are drawn and calling the 
	<filename>drawHorizontalExtenser</filename> template instead of the <filename>drawVerticalExtenser</filename> one.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term><filename>x, y</filename></term>
	  <listitem>
	    <para>
	      <filename>X</filename> and <filename>Y</filename> coordinates of the bottom left corner of the operator box.
	    </para>
	  </listitem>
	</varlistentry>
	
	<varlistentry>
	  <term><filename>delimiter</filename></term>
	  <listitem>
	    <para>
	      Operator to stretch.
	    </para>
	  </listitem>
	</varlistentry>
	
	<varlistentry>
	  <term><filename>width</filename></term>
	  <listitem>
	    <para>
	      Total width of the box that the operator has to fill.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>fontSize</filename></term>
	  <listitem>
	    <para>
	      Initial font size of the operator.
	    </para>
	  </listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>variant</filename></term>
	  <listitem>
	    <para>
	      Font variant for the operator.
	    </para>
	  </listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
  </doc:template>
  <xsl:template name="drawHorizontalDelimiter">
    <xsl:param name="delimiter"/>
    <xsl:param name="width"/>
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="fontSize"/>
    <xsl:param name="variant"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="fontName" tunnel="yes"/>

    <xsl:variable name="fontWidth">
      <xsl:call-template name="stringWidth">
	<xsl:with-param name="str" select="$delimiter"/>
	<xsl:with-param name="strLen" select="string-length($delimiter)"/>
	<xsl:with-param name="fontName" select="$fontName"/>
	<xsl:with-param name="variant" select="$variant"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- Do we need to stretch delimiter ? -->
    <xsl:variable name="stretchDelim" select="$width div ($fontWidth * $fontSize) &gt; 1"/>
    
    <xsl:choose>
      <!-- Delimiter is composed of multiple parts -->
      <xsl:when test="(count($delimPart/*[@hname=$delimiter]/*) &gt; 0) and $stretchDelim">
	<xsl:variable name="rotate" select="$delimPart/*[@hname=$delimiter]/@hrotate = 'true'"/>
	
	<xsl:variable name="numParts" select="count($delimPart/*[@hname=$delimiter]/*)"/>

	<!-- Compute parts indexes -->
	<xsl:variable name="rightIndex" select="1"/>
	<xsl:variable name="middleIndex" select="3"/>
	<xsl:variable name="leftIndex" select="if ($numParts = 2)
					       then 1
					       else 2"/>
	<xsl:variable name="extenserIndex" select="$numParts"/>

	<xsl:variable name="max" select="if ($rotate) then 4 else 2"/>
	<xsl:variable name="min" select="if ($rotate) then 3 else 1"/>

	<!-- Small size correction to avoid small gap in the composition -->
	<xsl:variable name="sizeCorrection" select="0.02"/>

	<!-- Compute parts size -->
	<xsl:variable name="rightBbox" as="xs:double+" select="if ($numParts != 2 or $delimPart/*[@hname=$delimiter]/@extenser = 'bottom' 
							           or $delimPart/*[@hname=$delimiter]/@extenser = 'left')
							       then func:findBbox($delimPart/*[@hname=$delimiter]/*[$rightIndex], $fontName, $variant)
							       else (0, 0, 0, 0)"/>
	<xsl:variable name="rightSize" select="if ($rightBbox != 0)
					       then $rightBbox[$max] - $rightBbox[$min] - $sizeCorrection
					       else 0"/>
	<xsl:variable name="middleBbox" as="xs:double+" select="if ($numParts = 4)
								then func:findBbox($delimPart/*[@hname=$delimiter]/*[$middleIndex], $fontName, $variant)
								else (0, 0, 0, 0)"/>
	<xsl:variable name="middleSize" select="if ($middleBbox != 0)
						then $middleBbox[$max] - $middleBbox[$min] - $sizeCorrection
						else 0"/>
	<xsl:variable name="leftBbox" as="xs:double+" select="if ($numParts != 2 or $delimPart/*[@hname=$delimiter]/@extenser = 'top' 
							          or $delimPart/*[@hname=$delimiter]/@extenser = 'right')
							      then func:findBbox($delimPart/*[@hname=$delimiter]/*[$leftIndex], $fontName, $variant)
							      else (0, 0, 0, 0)"/>
	<xsl:variable name="leftSize" select="if ($leftBbox != 0)
					      then $leftBbox[$max] - $leftBbox[$min] - $sizeCorrection
					      else 0"/>

	<xsl:variable name="partsSize" select="$leftSize + $middleSize + $rightSize"/>
	<xsl:variable name="extenserBbox" select="func:findBbox($delimPart/*[@hname=$delimiter]/*[$extenserIndex], $fontName, $variant)"/>
	<xsl:variable name="extenserSize" select="$extenserBbox[$max] - $extenserBbox[$min] - $sizeCorrection"/>

	<xsl:variable name="bestSize" select="func:findBestSize($width, $fontSize, $numParts - 1, $partsSize, $extenserSize)"/>

	<!-- Correct Y -->
	<xsl:variable name="partWidth">
	  <xsl:choose>
	    <xsl:when test="$rotate">
	      <xsl:value-of select="max(($rightBbox[2], $leftBbox[2], $middleBbox[2])) + min(($rightBbox[1], $leftBbox[1], $middleBbox[1]))"/>
	    </xsl:when>
	    <xsl:otherwise>
	      <xsl:value-of select="0"/>
	    </xsl:otherwise>
	  </xsl:choose>
	</xsl:variable>
	<xsl:variable name="yCorrected" select="$y - $partWidth * $fontSize"/>

	<!-- Right delimiter part -->
	<xsl:if test="$numParts != 2 or $delimPart/*[@hname=$delimiter]/@extenser = 'left'">
	  <xsl:variable name="rightX" select="$x + (- $rightBbox[$min] + $leftSize + $middleSize + $extenserSize * $bestSize[1]) * $bestSize[2]"/>
	  <text>
	    <xsl:attribute name="x" select="$rightX"/>
	    <xsl:attribute name="y" select="$yCorrected"/>
	    <xsl:attribute name="font-size" select="$bestSize[2]"/>
	    <xsl:if test="$rotate">
	      <xsl:attribute name="transform" select="concat('rotate(90, ', $rightX, ', ', $yCorrected, ')')"/>
	    </xsl:if>

	    <xsl:value-of select="$delimPart/*[@hname=$delimiter]/*[$rightIndex]"/>
	  </text>
	</xsl:if>

	<!-- Left delimiter part -->
	<xsl:if test="$numParts != 2 or $delimPart/*[@hname=$delimiter]/@extenser = 'right'">
	  <xsl:variable name="leftX" select="$x - $leftBbox[$min] * $bestSize[2]"/>
	  <text>
	    <xsl:attribute name="x" select="$leftX"/>
	    <xsl:attribute name="y" select="$yCorrected"/>
	    <xsl:attribute name="font-size" select="$bestSize[2]"/>
	    <xsl:if test="$rotate">
	      <xsl:attribute name="transform" select="concat('rotate(90, ', $leftX, ', ', $yCorrected, ')')"/>
	    </xsl:if>

	    <xsl:value-of select="$delimPart/*[@hname=$delimiter]/*[$leftIndex]"/>
	  </text>
	</xsl:if>

	<xsl:choose>
	  <!-- Delimiter has four parts -->
	  <xsl:when test="$numParts = 4">
	    <!-- Center delimiter part -->
	    <xsl:variable name="middleX" select="$x + (- $middleBbox[$min] + $leftSize + $extenserSize * $bestSize[1] * 0.5) * $bestSize[2]"/>

	    <text>
	      <xsl:attribute name="x" select="$middleX"/>
	      <xsl:attribute name="y" select="$yCorrected"/>
	      <xsl:attribute name="font-size" select="$bestSize[2]"/>
	      <xsl:if test="$rotate">
		<xsl:attribute name="transform" select="concat('rotate(90, ', $middleX, ', ', $yCorrected, ')')"/>
	      </xsl:if>
	      
	      <xsl:value-of select="$delimPart/*[@hname=$delimiter]/*[$middleIndex]"/>
	    </text>
	    
	    <!-- Need to add part extenser -->
	    <xsl:if test="$bestSize[1] != 0">
	      <!-- Left extenser -->
	      <xsl:call-template name="drawHorizontalExtenser">
		<xsl:with-param name="n" select="$bestSize[1] div 2"/>
		<xsl:with-param name="x" select="$x + (- $extenserBbox[$min] + $leftSize) * $bestSize[2]"/>
		<xsl:with-param name="y" select="$yCorrected"/>
		<xsl:with-param name="extenser" select="$delimPart/*[@hname=$delimiter]/*[$extenserIndex]"/>
		<xsl:with-param name="extenserSize" select="$extenserSize"/>
		<xsl:with-param name="fontSize" select="$bestSize[2]"/>
		<xsl:with-param name="rotate" select="$rotate"/>
	      </xsl:call-template>
	      
	      <!-- Right extenser -->
	      <xsl:call-template name="drawHorizontalExtenser">
		<xsl:with-param name="n" select="$bestSize[1] div 2"/>
		<xsl:with-param name="x" select="$x + (- $extenserBbox[$min] + $leftSize + $extenserSize * $bestSize[1] * 0.5 + $middleSize) * $bestSize[2]"/>
		<xsl:with-param name="y" select="$yCorrected"/>
		<xsl:with-param name="extenser" select="$delimPart/*[@hname=$delimiter]/*[$extenserIndex]"/>
		<xsl:with-param name="extenserSize" select="$extenserSize"/>
		<xsl:with-param name="fontSize" select="$bestSize[2]"/>
		<xsl:with-param name="rotate" select="$rotate"/>
	      </xsl:call-template>
	    </xsl:if>
	  </xsl:when>
	  
	  <!-- Delimiter has three or two parts -->
	  <xsl:otherwise>
	    <!-- Need to add part extenser -->
	    <xsl:if test="$bestSize[1] != 0">
	      <xsl:call-template name="drawHorizontalExtenser">
		<xsl:with-param name="n" select="$bestSize[1]"/>
		<xsl:with-param name="x">
		  <xsl:choose>
		    <xsl:when test="$numParts = 3 or $delimPart/*[@hname=$delimiter]/@extenser = 'right'">
		      <xsl:value-of select="$x + (- $extenserBbox[$min] + $leftSize) * $bestSize[2]"/>
		    </xsl:when>
		    <xsl:otherwise>
		      <xsl:value-of select="$x - $extenserBbox[$min] * $bestSize[2]"/>
		    </xsl:otherwise>
		  </xsl:choose>
		</xsl:with-param>
		<xsl:with-param name="y" select="$yCorrected"/>
		<xsl:with-param name="extenser" select="$delimPart/*[@hname=$delimiter]/*[$extenserIndex]"/>
		<xsl:with-param name="extenserSize" select="$extenserSize"/>
		<xsl:with-param name="fontSize" select="$bestSize[2]"/>
		<xsl:with-param name="rotate" select="$rotate"/>
	      </xsl:call-template>
	    </xsl:if>
	  </xsl:otherwise>
	</xsl:choose>
      </xsl:when>
	
      <!-- Delimiter can only be stretched -->
      <xsl:when test="(index-of($delimScale, $delimiter) &gt;= 0) and $stretchDelim">
	<xsl:variable name="bbox" select="func:findBbox($delimiter, $fontName, $variant)"/>
	<xsl:variable name="size" select="$bbox[2] - $bbox[1]"/>
	
	<!-- Draw scaled delimiter -->
	<xsl:variable name="scale" select="$width div ($size * $fontSize)" />

	<text>
	  <xsl:attribute name="x" select="($x - $bbox[1] * $fontSize * $scale) div $scale"/>
	  <xsl:attribute name="y" select="$y"/>
	  <xsl:attribute name="font-size" select="$fontSize"/>
	  <!-- Scale delimiter -->
	  <xsl:attribute name="transform" select="concat('scale(', $scale, ', 1)')"/>
	  
	  <xsl:value-of select="$delimiter"/>
	</text>
      </xsl:when>

      <!-- Delimiter can't be composed or stretched -->
      <xsl:otherwise>
	<!-- Simply draw and center delimiter -->
	<text>
	  <xsl:attribute name="y" select="$y"/>
	  <xsl:attribute name="x">
	    <xsl:choose>
	      <xsl:when test="$fontWidth * $fontSize &gt;= $width">
		<xsl:value-of select="$x"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:value-of select="$x + $width div 2 - ($fontWidth * $fontSize) div 2"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:attribute>
	  <xsl:attribute name="font-size" select="$fontSize"/>

	  <xsl:value-of select="$delimiter"/>
	</text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ####################################################################
       Draw n horizontal extenser from (x,y) to 
       (x + n * fontSize * extenserSize, y)
       
       I never call function recursion with same parameters as first call
       because I always decrease n (the number of glyph to draw).
       #################################################################### -->
  <doc:template name="drawHorizontalExtenser">
    <refpurpose>Draws 'n' horizontal 'extenser' of size 'extenserSize' from (x, y) to (x + n * fontSize * extenserSize, y).</refpurpose>

    <refdescription>
      <para>
	This template is similar to <filename>drawVerticalExtenser</filename> except that the <filename>Y</filename> coordinate remains
	the same through the recursive call and <filename>X</filename> is incremented to the next coordinate at each template call.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term><filename>n</filename></term>
	  <listitem><para>Number of extensers to draw</para></listitem>
	</varlistentry>
	
	<varlistentry>
	  <term><filename>x</filename></term>
	  <listitem><para><filename>X</filename> coordinate for extensers</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>y</filename></term>
	  <listitem><para><filename>Y</filename> coordinate for the bottom extenser</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>extenser</filename></term>
	  <listitem><para>Extenser to draw</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>extenserSize</filename></term>
	  <listitem><para>Extenser size (in em)</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>fontSize</filename></term>
	  <listitem><para>Size of the font to draw the extenser</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>rotate</filename></term>
	  <listitem><para><filename>true</filename> if the extenser has to be rotated</para></listitem>
	</varlistentry>
      </variablelist>
    </refparameter>
  </doc:template>
  <xsl:template name="drawHorizontalExtenser">
    <xsl:param name="n"/>
    <xsl:param name="x"/>
    <xsl:param name="y"/>
    <xsl:param name="extenser"/>
    <xsl:param name="extenserSize"/>
    <xsl:param name="fontSize"/>
    <xsl:param name="rotate" select="false()"/>
    <!-- Parameters receive by tunnel -->
    <xsl:param name="fontName" tunnel="yes"/>

    <!-- Draw an extenser -->
    <text>
      <xsl:attribute name="x" select="$x"/>
      <xsl:attribute name="y" select="$y"/>
      <xsl:attribute name="font-size" select="$fontSize"/>

      <xsl:if test="$rotate">
	<xsl:attribute name="transform" select="concat('rotate(90, ', $x, ', ', $y, ')')"/>
      </xsl:if>
      
      <xsl:value-of select="$extenser"/>
    </text>

    <!-- Recursion -->
    <xsl:if test="$n - 1 &gt; 0">
      <xsl:call-template name="drawHorizontalExtenser">
	<xsl:with-param name="n" select="$n - 1"/>
	<xsl:with-param name="x" select="$x + $fontSize * $extenserSize"/>
	<xsl:with-param name="y" select="$y"/>
	<xsl:with-param name="extenser" select="$extenser"/>
	<xsl:with-param name="extenserSize" select="$extenserSize"/>
	<xsl:with-param name="fontSize" select="$fontSize"/>
	<xsl:with-param name="rotate" select="$rotate"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- ####################################################################
       Find exact number of extenser part and best font size (near fontSize) 
       to fill height with minimum minPart glyph.
       Return sequence (x, size) of double where x is the number of extenser 
       part and size is the best font size.
       #################################################################### -->
  <doc:function name="findBestSize">
    <refpurpose>Finds a round number of extensers that will cover a space with a font size as near as possible to the initial font size.</refpurpose>

    <refdescription>
      <para>
	This function follows the following algorithm:

	<procedure>
	  <step>
	    <para>
	      If <computeroutput>$height &lt;= $partsSize * $fontSize</computeroutput> then return <computeroutput>(0, $height div $partsSize)</computeroutput>
	    </para>
	  </step>
	  <step>
	    <para>Else</para>
	    <substeps>
	      <step>
		<para>
		  Compute: <computeroutput>$rawRatio = ($height - $partsSize * $fontSize) div ($fontSize * $extenserSize) + $minPart</computeroutput>
		  and <computeroutput>$roundRatio = round($rawRatio)</computeroutput>
		</para>
	      </step>
	      <step xml:id="stepB">
		<para>
		  Compute <computeroutput>$ratio</computeroutput>:
		</para>
		<substeps>
		  <step>
		    <para>
		      If <computeroutput>$minPart &lt; 3</computeroutput> or <computeroutput>$roundRatio</computeroutput> is even then 
		      <computeroutput>$ratio = $roundRatio</computeroutput>
		    </para>
		  </step>
		  <step>
		    <para>Else</para>
		    <substeps>
		      <step>
			<para>
			  If <computeroutput>$rawRatio &lt; $roundRatio</computeroutput> alors <computeroutput>$ratio = $roundRatio - 1</computeroutput>
			</para>
		      </step>
		      <step>
			<para>
			  Else <computeroutput>$ratio = $roundRatio + 1</computeroutput>
			</para>
		      </step>
		    </substeps>
		  </step>
		</substeps>
	      </step>
	      <step>
		<para>
		  Return <computeroutput>($ratio - $minPart, $height div (($ratio - $minPart) * $extenserSize + $partsSize))</computeroutput>
		</para>
	      </step>
	    </substeps>
	  </step>
	</procedure>

	The <xref linkend="stepB"/> is used to obtain an even number of extensers when the operator has a middle part. The number of extensers at the top
	(or on the left) of the middle part must be equal to the number of extensers at the bottom (or on the right) of this part.
      </para>
    </refdescription>

    <refparameter>
      <variablelist>
	<varlistentry>
	  <term><filename>height</filename></term>
	  <listitem><para>Total height to cover</para></listitem>
	</varlistentry>
	
	<varlistentry>
	  <term><filename>fontSize</filename></term>
	  <listitem><para>Initial font size</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>partsSize</filename></term>
	  <listitem><para>Required part size (in em) (all element excepts the extenser)</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>extenserSize</filename></term>
	  <listitem><para>Extenser size (in em)</para></listitem>
	</varlistentry>

	<varlistentry>
	  <term><filename>minPart</filename></term>
	  <listitem><para>Required number of part</para></listitem>
	</varlistentry>
      </variablelist>
    </refparameter>

    <refreturn>
      <para>Returns a sequence of two numbers: the first is the number of extensers to add and the second is the new computed font size.</para>
    </refreturn>
  </doc:function>
  <xsl:function name="func:findBestSize" as="xs:double+">               
    <xsl:param name="height"/>
    <xsl:param name="fontSize"/>
    <xsl:param name="minPart"/>
    <xsl:param name="partsSize"/>
    <xsl:param name="extenserSize"/>

    <xsl:choose>
      <!-- No need of extenser -->
      <xsl:when test="($partsSize * $fontSize) &gt;= $height">
	<!-- Return sequence -->
	<xsl:sequence select="(0, $height div $partsSize)"/>
      </xsl:when>
      <!-- Need to add extenser -->
      <xsl:otherwise>
	<xsl:variable name="rawRatio" select="($height - $partsSize * $fontSize) div ($fontSize * $extenserSize) + $minPart"/>
	<xsl:variable name="roundedRatio" select="round($rawRatio)"/>

	<xsl:variable name="ratio">
	  <!-- We need the same number of extenser at the top and at the bottom of
	       delimiter center part if delimiter has three part (like braces) -->
	  <xsl:choose>
	    <!-- Delimiter has only two or one parts or extenser number is already even -->
	    <xsl:when test="($minPart &lt; 3) or ($roundedRatio mod 2 = 1)">
	      <xsl:value-of select="$roundedRatio"/>
	    </xsl:when>
	    <!-- Delimiter has three parts, so we need even extenser number -->
	    <xsl:when test="($minPart = 3) and ($roundedRatio mod 2 = 0)">
	      <xsl:value-of select="if ($rawRatio &lt;= $roundedRatio) 
				    then ($roundedRatio - 1) 
				    else ($roundedRatio + 1)"/>
	    </xsl:when>
	  </xsl:choose>
	</xsl:variable>

	<!-- Return sequence -->
	<xsl:sequence select="($ratio - $minPart, $height div (($ratio - $minPart) * $extenserSize + $partsSize))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
</xsl:stylesheet>