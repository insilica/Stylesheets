<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" 
    xmlns:html="http://www.w3.org/1999/xhtml" 
    xmlns:i="http://www.iso.org/ns/1.0"
    xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:sch="http://purl.oclc.org/dsdl/schematron" 
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:teix="http://www.tei-c.org/ns/Examples" 
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    exclude-result-prefixes="#all"
    version="3.0">

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl" scope="stylesheet" type="stylesheet">
    <desc>
      <p> TEI stylesheet for processing TEI ODD markup </p>
      <p>This software is dual-licensed:

1. Distributed under a Creative Commons Attribution-ShareAlike 3.0
Unported License http://creativecommons.org/licenses/by-sa/3.0/ 

2. http://www.opensource.org/licenses/BSD-2-Clause
                


Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

* Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

This software is provided by the copyright holders and contributors
"as is" and any express or implied warranties, including, but not
limited to, the implied warranties of merchantability and fitness for
a particular purpose are disclaimed. In no event shall the copyright
holder or contributors be liable for any direct, indirect, incidental,
special, exemplary, or consequential damages (including, but not
limited to, procurement of substitute goods or services; loss of use,
data, or profits; or business interruption) however caused and on any
theory of liability, whether in contract, strict liability, or tort
(including negligence or otherwise) arising in any way out of the use
of this software, even if advised of the possibility of such damage.
</p>
      <p>Author: See AUTHORS</p>
      
      <p>Copyright: 2013, TEI Consortium</p>
    </desc>
  </doc>

  <xsl:include href="RngToRnc.xsl"/>
  <xsl:param name="STDOUT">true</xsl:param>
  <xsl:param name="TEIC">false</xsl:param>
  <xsl:param name="autoGlobal">false</xsl:param>
  <xsl:param name="configDirectory"/>
  <xsl:param name="currentDirectory"/>
  <xsl:param name="defaultSource"></xsl:param>
  <xsl:param name="defaultTEIServer">https://www.tei-c.org/Vault/P5/</xsl:param>
  <xsl:param name="defaultTEIVersion">current</xsl:param>
  <xsl:param name="idPrefix"/>
  <xsl:param name="lang"/>
  <xsl:param name="localsource"/>
  <xsl:param name="lookupDatabase">false</xsl:param>
  <xsl:param name="oddmode">tei</xsl:param>
  <xsl:param name="outputDir"/>
  <xsl:param name="outputSuffix">.html</xsl:param>
  <xsl:param name="patternPrefix"/>
  <xsl:param name="outputEncoding">utf-8</xsl:param>
  <xsl:param name="schemaBaseURL">http://localhost/schema/relaxng/</xsl:param>
  <xsl:param name="splitLevel">-1</xsl:param>
  <xsl:param name="verbose">false</xsl:param>
  <!-- Not sure whether this should be specified here or in odd2relax.xsl, or, -->
  <!-- for that matter, whether we really want it at all. It is the max # of   -->
  <!-- clauses of RELAX NG we'll generate in response to @maxOccurs (more than -->
  <!-- this, just allow "unbounded", and insert an annotation saying so). —Syd -->
  <xsl:param name="maxint" select="400"/>
  
  <xsl:key match="tei:elementSpec|tei:classSpec|tei:macroSpec|tei:dataSpec" name="LOCALIDENTS" use="@ident"/>
  <xsl:key match="tei:dataSpec|tei:macroSpec" name="MACROS" use="@ident"/>
  <xsl:key match="tei:elementSpec" name="ELEMENTS" use="@ident"/>
  <xsl:key match="tei:elementSpec" name="ELEMENTS" use="tei:altIdent"/>
  <xsl:key match="tei:classSpec" name="CLASSES" use="@ident"/>
  <xsl:key match="rng:ref" name="REFS"  use="@name"/>
  <xsl:key match="tei:elementRef" name="REFS"  use="@key"/>
  <xsl:key match="tei:classRef" name="REFS"  use="@key"/>
  <xsl:key match="tei:macroRef" name="REFS"  use="@key"/>
  <xsl:key match="tei:dataRef" name="REFS"  use="@key"/>
  <xsl:key match="rng:ref[contains(@name,'_')]" name="REFS" use="substring-before(@name,'_')"/>

  <xsl:key
      match="tei:elementSpec/tei:attList//tei:attDef/tei:datatype/rng:ref"
      name="REFSTO-ELEMENT" 
      use="@name"/>
  <xsl:key
    match="tei:elementSpec/tei:attList//tei:attDef/tei:datatype/tei:dataRef"
    name="REFSTO-ELEMENT" 
    use="@key"/>
  <xsl:key 
      match="tei:classSpec/tei:attList//tei:attDef/tei:datatype/rng:ref" 
      name="REFSTO-CLASS" 
      use="@name"/>
  <xsl:key 
    match="tei:classSpec/tei:attList//tei:attDef/tei:datatype/tei:dataRef" 
    name="REFSTO-CLASS" 
    use="@key"/>

  <xsl:key match="tei:macroSpec/tei:content//rng:ref" name="MACROREFS"  use="@name"/>
  <xsl:key match="tei:macroSpec/tei:content//tei:macroRef" name="MACROREFS"  use="@key"/>
  <xsl:key match="tei:dataSpec/tei:content//tei:dataRef" name="MACROREFS"  use="@key"/>

  <xsl:key match="tei:elementSpec|tei:classSpec" name="CLASSMEMBERS" use="tei:classes/tei:memberOf/@key"/>
  <xsl:key match="tei:elementSpec" name="CLASSMEMBERS-ELEMENTS" use="tei:classes/tei:memberOf/@key"/>
  <xsl:key match="tei:classSpec" name="CLASSMEMBERS-CLASSES" use="tei:classes/tei:memberOf/@key"/>
  <xsl:key match="tei:elementSpec|tei:classSpec|tei:macroSpec|tei:dataSpec" name="IDENTS" use="concat(@prefix,@ident)"/>

  <xsl:key match="tei:macroSpec|tei:dataSpec" name="MACRODOCS" use="1"/>
  <xsl:key match="tei:attDef" name="ATTDOCS" use="1"/>
  <xsl:key match="tei:attDef" name="ATTRIBUTES" use="@ident"/>
  <xsl:key match="tei:classSpec//tei:attDef" name="ATTRIBUTES-CLASS" use="@ident"/>
  <xsl:key match="tei:elementSpec//tei:attDef" name="ATTRIBUTES-ELEMENT" use="@ident"/>
  <xsl:key match="tei:classSpec[@type='atts']" name="ATTCLASSDOCS" use="1"/>
  <xsl:key match="tei:classSpec[@type='model']" name="MODELCLASSDOCS" use="1"/>
  <xsl:key match="tei:elementSpec" name="ELEMENTDOCS" use="1"/>
  <xsl:key match="tei:elementSpec" name="ElementModule" use="@module"/>
  <xsl:key match="tei:classSpec" name="ClassModule" use="@module"/>
  <xsl:key match="tei:macroSpec" name="MacroModule" use="@module"/>
  <xsl:key match="tei:dataSpec" name="MacroModule" use="@module"/>
  <xsl:key match="tei:dataSpec" name="DataMacroModule" use="@module"/>
  <xsl:key match="tei:moduleSpec" name="Modules" use="1"/>
  <xsl:key match="tei:moduleSpec" name="MODULES" use="@ident"/>
  <xsl:key match="tei:classSpec[@predeclare='true']" name="predeclaredClasses" use="1"/>
  <xsl:key match="tei:macroSpec[@predeclare='true']" name="PredeclareMacros" use="@ident"/>
  <xsl:key match="tei:macroSpec[@predeclare='true']" name="PredeclareMacrosModule" use="@module"/>
  <xsl:key match="tei:macroSpec[@predeclare='true']" name="PredeclareAllMacros" use="1"/>


  <xsl:variable name="DEFAULTSOURCE">
    <xsl:choose>
      <xsl:when test="$defaultSource != ''">
        <xsl:value-of select="$defaultSource"/>
      </xsl:when>
      <xsl:when test="$configDirectory != ''">
        <xsl:value-of select="$configDirectory"/>
        <xsl:text>odd/p5subset.xml</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$defaultTEIServer"/>
        <xsl:value-of select="$defaultTEIVersion"/>
        <xsl:text>/xml/tei/odd/p5subset.xml</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="BASE" select="base-uri(/tei:TEI)"/>

  <xsl:variable name="parameterize" select="if (key('SCHEMASPECS',1)) then 'false' else 'true'"/>

  <!-- lookup table of element contents, and templates to access the result -->
  <xsl:key match="Contains" name="ELEMENTPARENTS" use="."/>

  <xsl:variable name="generalPrefix">
    <xsl:choose>
      <xsl:when test="string-length($patternPrefix)&gt;0">
        <xsl:value-of select="$patternPrefix"/>
      </xsl:when>
      <xsl:when test="key('LISTSCHEMASPECS',$whichSchemaSpec)[@prefix]">
        <xsl:value-of select="key('LISTSCHEMASPECS',$whichSchemaSpec)/@prefix"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="targetLanguage">
    <xsl:choose>
      <xsl:when test="string-length($lang)&gt;0">
        <xsl:value-of select="$lang"/>
      </xsl:when>
      <xsl:when test="key('LISTSCHEMASPECS',$whichSchemaSpec)[@targetLang]">
        <xsl:value-of select="key('LISTSCHEMASPECS',$whichSchemaSpec)/@targetLang"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>en</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="anyElement_disambiguator_format" as="xs:string">
    <!-- A string used as the xsl:number/@format to append to pattern names for <anyElement>s (thus to disambiguate them) -->
    <xsl:variable name="zeroes" as="xs:string+">
      <xsl:for-each select="1 to ( count( //tei:anyElement ) => xs:string() => string-length() )">0</xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="concat('_', string-join( $zeroes ))"/>
  </xsl:variable>

  <xsl:template match="processing-instruction()" mode="#default tangle">
    <xsl:choose>
      <xsl:when test="name(.) = 'odds'">
        <xsl:choose>
          <xsl:when test=".='date'"> This formatted version of the Guidelines was created on
          <xsl:sequence select="tei:whatsTheDate()"/>. </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="literal">
    <xsl:text>&#10;</xsl:text>
    <xsl:for-each select="ancestor::rng:*">
      <xsl:text> </xsl:text>
    </xsl:for-each>
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="local-name(.)"/>
    <xsl:for-each select="@*">
      <xsl:text> </xsl:text>
      <xsl:value-of select="local-name(.)"/>="<xsl:value-of select="."/>"</xsl:for-each>
    <xsl:choose>
      <xsl:when test="child::node()">
        <xsl:text>&gt;</xsl:text>
        <xsl:apply-templates mode="literal"/>
        <xsl:if test="node()[last()]/self::rng:*">
          <xsl:text>&#10;</xsl:text>
        </xsl:if>
        <xsl:for-each select="ancestor::rng:*">
          <xsl:text> </xsl:text>
        </xsl:for-each>
        <xsl:text>&lt;/</xsl:text>
        <xsl:value-of select="local-name(.)"/>
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>/&gt;</xsl:text>
        <xsl:if test="node()[last()]/self::rng:*">
          <xsl:text>&#10;         </xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="rng:ref" mode="#default tangle">
    <rng:ref name="{tei:generateRefPrefix(.)}"/>
  </xsl:template>
  
  <xsl:template match="rng:*"  mode="#default tangle">
    <xsl:element name="{local-name()}" namespace="http://relaxng.org/ns/structure/1.0" >
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="rng:*|tei:*|text()|comment()"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="rng:zeroOrMore" mode="#default tangle">
    <xsl:choose>
      <xsl:when
        test="rng:ref/@name='model.global'   and preceding-sibling::rng:*[1][self::rng:zeroOrMore/rng:ref/@name='model.global']"/>
      <xsl:when test="count(rng:*)=1 and rng:zeroOrMore">
        <xsl:apply-templates select="rng:*|tei:*|text()|comment()"/>
      </xsl:when>
      <xsl:otherwise>
        <rng:zeroOrMore>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates select="rng:*|tei:*|text()|comment()"/>
        </rng:zeroOrMore>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="rng:choice" mode="#default tangle">
    <xsl:choose>
      <xsl:when test="count(rng:*)=1">
        <xsl:apply-templates select="a:*|rng:*|tei:*|text()|comment()"/>
      </xsl:when>
      <xsl:otherwise>
        <rng:choice>
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates select="a:*|rng:*|tei:*|text()|comment()"/>
        </rng:choice>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="rng:group" mode="#default tangle">
    <!-- check if this group is identical to the last -->
    <xsl:choose>
      <xsl:when
        test="count(rng:*)=1 and local-name(preceding-sibling::rng:*[1])='group' and rng:zeroOrMore">
        <xsl:variable name="that">
          <xsl:for-each select="preceding-sibling::rng:*[1]">
            <xsl:apply-templates mode="decomposed"/>
          </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="this">
          <xsl:apply-templates mode="decomposed"/>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="$that=$this"/>
          <xsl:otherwise>
            <rng:group>
              <xsl:copy-of select="@*"/>
              <xsl:apply-templates select="rng:*|tei:*|text()|comment()"/>
            </rng:group>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="{local-name()}" namespace="http://relaxng.org/ns/structure/1.0" >
          <xsl:copy-of select="@*"/>
          <xsl:apply-templates select="rng:*|tei:*|text()|comment()"/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="rng:*" mode="decomposed">
    <xsl:value-of select="local-name(.)"/>
    <xsl:for-each select="@*">
      <xsl:text>@</xsl:text>
      <xsl:value-of select="."/>
    </xsl:for-each>
    <xsl:apply-templates mode="decomposed"/>
  </xsl:template>

  <!-- In "tangle" mode we ignore TEI elements unless specifically
       matched, below. -->
  <xsl:template match="tei:*" mode="tangle"/>
  
  <xsl:template match="tei:anyElement" mode="tangle">
    <xsl:variable name="spec" select="ancestor::tei:elementSpec|ancestor::tei:macroSpec"/>
    <xsl:variable name="disambiguator" as="xs:string">
      <xsl:number level="any" format="{$anyElement_disambiguator_format}"/>
    </xsl:variable>
    <xsl:variable name="id" select="concat('anyElement_', $spec/@ident, $disambiguator )"/>
    <xsl:variable name="repeatMe" as="element()">
      <rng:ref name="{$id}"/>
    </xsl:variable>
    <xsl:variable name="repeated_as_needed" as="element()*">
      <xsl:call-template name="repeat_as_needed">
        <xsl:with-param name="repeatMe" select="$repeatMe" as="element()"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:sequence select="$repeated_as_needed"/>
  </xsl:template>

  <!-- Given an element (presumably a RELAX NG element), generate the
       correct RELAX NG code around that element to match it the right
       number of times based on the @minOccurs and @maxOccurs of the
       current context node (which is presumably a member of
       att.repeatable). -->
  <xsl:template name="repeat_as_needed" as="element()+">
    <xsl:param name="repeatMe" as="element()+"/>
    <xsl:variable name="norMinMax" select="tei:norMinMax(.)" as="item()+"/>
    <xsl:variable name="min" select="$norMinMax[1]"/> <!-- minimum number of occurrences as an xs:integer -->
    <xsl:variable name="max" select="$norMinMax[2]"/> <!-- maximum number of occurrences as an xs:integer, -1 for unbounded -->
    <xsl:variable name="owe" select="$norMinMax[3]"/> <!-- occurrence wrapper element, as the string "optional", "zeroOrMore", or "oneOrMore" -->
    <xsl:choose>
      <!-- Handle min=0 max=1, min=0 max=unbounded, and min=1 max=unbounded all in one fell swoop: -->
      <xsl:when test="string-length($owe) ne 0">
        <xsl:element name="{$owe}" namespace="http://relaxng.org/ns/structure/1.0">
          <xsl:copy-of select="$repeatMe"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <!-- a more complex case -->
        <xsl:if test="$min gt 0">
          <xsl:for-each select="1 to $min">
            <xsl:copy-of select="$repeatMe"/>
          </xsl:for-each>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$max eq -1"><!-- i.e., unbounded -->
            <rng:zeroOrMore>
              <xsl:copy-of select="$repeatMe"/>
            </rng:zeroOrMore>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="$min+1 to $max">
              <rng:optional>
                <xsl:copy-of select="$repeatMe"/>
              </rng:optional>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:attRef" mode="tangle">  
    <xsl:choose>
      <xsl:when test="key('IDENTS',@class)">
        <rng:ref name="{tei:generateAttRef(.,$generalPrefix)}"/>
      </xsl:when>
      <xsl:when test="@class"/>
      <xsl:otherwise>
        <rng:ref name="{@name}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:attDef" mode="tangle">
    <xsl:param name="element"/>
    <!-- This tunneled parameters is set when we are processing
      attDefs in the context of generating documentation of an 
      element content model, so that we 
      don't spew out Schematron in the middle of it. -->
    <xsl:param tunnel="yes" as="xs:boolean" name="includeConstraints" select="true()"/>
    <xsl:variable name="I">
      <xsl:value-of select="translate(@ident,':','')"/>
    </xsl:variable>
    <xsl:if test="not(starts-with(@ident,'xmlns'))">
      <xsl:choose>
        <xsl:when test="ancestor::tei:elementSpec">
          <xsl:call-template name="makeAnAttribute"/>
        </xsl:when>
        <xsl:when test="ancestor::tei:classSpec">
          <rng:define
            name="{$element}.attribute.{translate(@ident,':','')}">
            <xsl:call-template name="makeAnAttribute"/>
          </rng:define>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="$includeConstraints = true()">
      <xsl:apply-templates select="tei:constraintSpec"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:attList" mode="tangle">
    <xsl:param name="element"/>
    <xsl:choose>
      <xsl:when test="count(*)=0"/>
      <xsl:when test="@org='group' and         parent::tei:attList[@org='choice']">
        <rng:group>
          <xsl:apply-templates mode="tangle" select="tei:*">
            <xsl:with-param name="element" select="$element"/>
          </xsl:apply-templates>
        </rng:group>
      </xsl:when>

      <xsl:when test="@org='choice'">
        <rng:choice>
          <xsl:apply-templates mode="tangle" select="tei:*">
            <xsl:with-param name="element" select="$element"/>
          </xsl:apply-templates>
        </rng:choice>
      </xsl:when>

      <xsl:otherwise>
        <xsl:apply-templates mode="tangle">
          <xsl:with-param name="element" select="$element"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="tei:classSpec" mode="tangle">
    <xsl:variable name="c">
      <xsl:choose>
        <xsl:when test="@prefix">
          <xsl:value-of select="@prefix"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$generalPrefix"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="@ident"/>
    </xsl:variable>
    
    <xsl:if test="$verbose='true'">
      <xsl:message> classSpec <xsl:value-of select="@ident"/> (type <xsl:value-of select="@type"
      />)</xsl:message>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="@type='model'">
        <xsl:apply-templates mode="processModel" select=".">
          <xsl:with-param name="declare">false</xsl:with-param>
          <!--      <xsl:choose>
            <xsl:when test="@module='tei'">true</xsl:when>
            <xsl:otherwise>false</xsl:otherwise>
            </xsl:choose>
            </xsl:with-param>
          -->
        </xsl:apply-templates>
        <xsl:apply-templates select="tei:constraintSpec"/>
      </xsl:when>
      <xsl:when test="@type='atts'">
        <xsl:call-template name="schemaOut">
          <xsl:with-param name="grammar">true</xsl:with-param>
          <xsl:with-param name="content">
            <Wrapper>
              <xsl:variable name="contents">
                <ROOT>
                  <xsl:for-each select="tei:classes/tei:memberOf">
                    <xsl:for-each select="key('LOCALIDENTS',@key)[1]">
                      <xsl:if test="@type='atts'">
                        <ref  xmlns="http://relaxng.org/ns/structure/1.0">
                          <xsl:attribute name="name">
                            <xsl:choose>
                              <xsl:when test="@prefix">
                                <xsl:value-of select="@prefix"/>
                              </xsl:when>
                              <xsl:otherwise>
                                <xsl:value-of select="$generalPrefix"/>
                              </xsl:otherwise>
                            </xsl:choose>
                            <xsl:value-of select="@ident"/>
                            <xsl:text>.attributes</xsl:text>
                          </xsl:attribute>
                        </ref>
                      </xsl:if>
                    </xsl:for-each>
                  </xsl:for-each>
                  <xsl:for-each select="tei:attList//tei:attDef[not(@mode='delete')]">
                    <xsl:if test="not(starts-with(@ident,'xmlns'))">
                      <rng:ref
                        name="{$c}.attribute.{translate(@ident,':','')}"/>
                    </xsl:if>
                  </xsl:for-each>
                  <xsl:for-each select="tei:attList//tei:attRef">
                    <xsl:choose>
                      <xsl:when test="key('LOCALIDENTS',@class)">
                        <rng:ref name="{tei:generateAttRef(.,$generalPrefix)}"/>
                      </xsl:when>
                      <xsl:when test="@class"/>
                      <xsl:otherwise>
                        <rng:ref name="{@name}"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:for-each>
                </ROOT>
              </xsl:variable>
              <rng:define
                name="{$c}.attributes">
                <xsl:for-each select="$contents/ROOT">
                  <xsl:apply-templates mode="justcopy"/>
                  <xsl:if test="not($contents/ROOT/*)">
                    <rng:empty/>
                  </xsl:if>
                </xsl:for-each>
              </rng:define>
              <xsl:apply-templates mode="tangle" select="tei:attList//tei:attDef">
                <xsl:with-param name="element" select="$c"/>
              </xsl:apply-templates>
              <xsl:apply-templates select="tei:constraintSpec"/>
            </Wrapper>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
    </xsl:choose>
    
  </xsl:template>

  <xsl:template match="tei:classSpec" mode="processModel">
    <xsl:param name="declare">false</xsl:param>
    <xsl:if test="$verbose='true'">
      <xsl:message> .... model class <xsl:value-of select="@ident"/>
      </xsl:message>
    </xsl:if>
    <xsl:call-template name="schemaOut">
      <xsl:with-param name="grammar">true</xsl:with-param>
      <xsl:with-param name="content">
        <Wrapper>
          <xsl:call-template name="processClassDefinition">
            <xsl:with-param name="type">
              <xsl:choose>
                <xsl:when test="@generate">
                  <xsl:value-of select="@generate"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>&#10;                            NULL
                             alternation
                             sequence
                             sequenceOptional
                             sequenceOptionalRepeatable
                           sequenceRepeatable</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:with-param>
            <xsl:with-param name="declare" select="$declare"/>
         </xsl:call-template>
        </Wrapper>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>


  <xsl:template name="processClassDefinition">
    <xsl:param name="type"/>
    <xsl:param name="declare"/>
    <xsl:variable name="Type">
      <xsl:value-of select="normalize-space($type)"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="string-length($Type)=0">
        <xsl:call-template name="makeClassDefinition">
          <xsl:with-param name="type">NULL</xsl:with-param>
          <xsl:with-param name="declare" select="$declare"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:when test="contains($Type,' ')">
        <xsl:call-template name="makeClassDefinition">
          <xsl:with-param name="type" select="substring-before($Type,' ')"/>
          <xsl:with-param name="declare" select="$declare"/>
        </xsl:call-template>
        <xsl:call-template name="processClassDefinition">
          <xsl:with-param name="type" select="substring-after($Type,' ')"/>
          <xsl:with-param name="declare" select="$declare"/>
        </xsl:call-template>
      </xsl:when>

      <xsl:otherwise>
        <xsl:call-template name="makeClassDefinition">
          <xsl:with-param name="type" select="$Type"/>
          <xsl:with-param name="declare" select="$declare"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="makeClassDefinition">
    <xsl:param name="type"/>
    <xsl:param name="declare"/>
    <!--
      alternation
      sequence
      sequenceOptional
      sequenceOptionalRepeatable
      sequenceRepeatable
  -->

    <xsl:variable name="thisClass">
      <xsl:value-of select="@ident"/>
    </xsl:variable>
    <xsl:variable name="localprefix">
      <xsl:choose>
        <xsl:when test="@prefix">
          <xsl:value-of select="@prefix"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$generalPrefix"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="suffix">
      <xsl:choose>
        <xsl:when test="$type='NULL'"> </xsl:when>
        <xsl:otherwise>
          <xsl:text>_</xsl:text>
          <xsl:value-of select="$type"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$declare='true'">
        <xsl:apply-templates mode="tangleModel" select="tei:classes/tei:memberOf"/>
        <rng:define
          name="{$localprefix}{$thisClass}{$suffix}">
          <xsl:if test="@predeclare='true'">
            <xsl:attribute name="combine">choice</xsl:attribute>
          </xsl:if>
          <rng:notAllowed/>
        </rng:define>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="makeDecls">
          <xsl:call-template name="findUses">
            <xsl:with-param name="pattern" select="$type"/>
            <xsl:with-param name="class" select="$thisClass"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <!--
               <xsl:when test="$makeDecls=''">
                  <xsl:if test="$verbose='true'">
                     <xsl:message>Do NOT generate <xsl:value-of select="$thisClass"/>
                        <xsl:value-of select="$suffix"/> (<xsl:value-of select="$type"/>)                     </xsl:message>
                  </xsl:if>
               </xsl:when>
-->
          <xsl:when test="count(key('CLASSMEMBERS',$thisClass))&gt;0">
            <xsl:if test="$verbose='true'">
              <xsl:message> .... ... generate model <xsl:value-of select="$thisClass"/>
                <xsl:value-of select="$suffix"/> (<xsl:value-of select="$type"/>) </xsl:message>
            </xsl:if>
            <rng:define
              name="{$localprefix}{$thisClass}{$suffix}">
              <xsl:choose>
                <xsl:when test="$type='sequence'">
                  <xsl:for-each select="key('CLASSMEMBERS',$thisClass)">
                    <xsl:apply-templates select="."
                                         mode="classmember">
                      <xsl:with-param name="theClass" select="$thisClass"/>
                      <xsl:with-param name="suffix" select="$type"/>
                    </xsl:apply-templates>
                  </xsl:for-each>
                </xsl:when>
                <xsl:when test="$type='sequenceOptional'">
                  <xsl:for-each select="key('CLASSMEMBERS',$thisClass)">
                    <rng:optional>
                      <xsl:apply-templates select="."  mode="classmember">
                        <xsl:with-param name="theClass" select="$thisClass"/>
                        <xsl:with-param name="suffix" select="$type"/>
                      </xsl:apply-templates>
                    </rng:optional>
                  </xsl:for-each>
                </xsl:when>

                <xsl:when test="$type='sequenceRepeatable'">
                  <xsl:for-each select="key('CLASSMEMBERS',$thisClass)">
                    <rng:oneOrMore>
                      <xsl:apply-templates select="."  mode="classmember">
                        <xsl:with-param name="theClass" select="$thisClass"/>              
                        <xsl:with-param name="suffix" select="$type"/>
                      </xsl:apply-templates>
                    </rng:oneOrMore>
                  </xsl:for-each>
                </xsl:when>

                <xsl:when test="$type='sequenceOptionalRepeatable'">
                  <xsl:for-each select="key('CLASSMEMBERS',$thisClass)">
                    <rng:zeroOrMore>
                      <xsl:apply-templates select="." mode="classmember">
                        <xsl:with-param name="suffix" select="$type"/>
                        <xsl:with-param name="theClass" select="$thisClass"/>
                      </xsl:apply-templates>
                    </rng:zeroOrMore>
                  </xsl:for-each>
                </xsl:when>

                <xsl:otherwise>
                  <rng:choice>
                    <xsl:for-each select="key('CLASSMEMBERS',$thisClass)">
                      <xsl:apply-templates select="." mode="classmember">
                        <xsl:with-param name="suffix" select="$type"/>
                        <xsl:with-param name="theClass" select="$thisClass"/>
                      </xsl:apply-templates>
                    </xsl:for-each>
                  </rng:choice>
                </xsl:otherwise>
              </xsl:choose>
            </rng:define>
          </xsl:when>
          <xsl:otherwise>
            <rng:define
              name="{$localprefix}{$thisClass}{$suffix}">
              <xsl:choose>
                <xsl:when
                  test="$type='sequence' or     $type='sequenceOptional' or      $type='sequenceOptionalRepeatable'">
                  <rng:empty/>
                </xsl:when>
                <xsl:otherwise>
                  <rng:notAllowed/>
                </xsl:otherwise>
              </xsl:choose>
            </rng:define>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>



  <xsl:template name="findUses">
    <xsl:param name="pattern"/>
    <xsl:param name="class"/>
    <xsl:variable name="suffix">
      <xsl:choose>
        <xsl:when test="$pattern='NULL'"/>
        <xsl:otherwise>
          <xsl:text>_</xsl:text>
          <xsl:value-of select="$pattern"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="not(ancestor::tei:schemaSpec)">x</xsl:when>
      <xsl:when test="key('REFS',concat($class,$suffix))">x</xsl:when>
      <xsl:when test="key('REFS',$class)">x</xsl:when>
      <xsl:when test="not($suffix='')"/>
      <xsl:when test="tei:classes/tei:memberOf">
        <xsl:for-each select="tei:classes/tei:memberOf">
          <xsl:for-each select="key('CLASSES',@key)">
            <xsl:call-template name="findUses">
              <xsl:with-param name="pattern"/>
              <xsl:with-param name="class" select="@ident"/>
            </xsl:call-template>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
  </xsl:template>


  <xsl:template match="tei:classSpec" mode="tangleadd">
    <xsl:apply-templates mode="tangleadd"/>
  </xsl:template>


  <xsl:template match="tei:classSpec/@ident"/>


  <xsl:template match="tei:code">
    <xsl:call-template name="typewriter">
      <xsl:with-param name="text">
        <xsl:apply-templates/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="text()" mode="doc">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="tei:desc" mode="tangle"/>

  <xsl:template match="tei:classSpec" mode="classmember">
    <xsl:param name="suffix"/>
    <xsl:variable name="localprefix">
      <xsl:choose>
        <xsl:when test="@prefix">
          <xsl:value-of select="@prefix"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$generalPrefix"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$suffix='' or $suffix='NULL'">
        <rng:ref name="{$localprefix}{@ident}"/>
      </xsl:when>
      <xsl:otherwise>
        <rng:ref name="{$localprefix}{@ident}_{$suffix}"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:elementSpec" mode="classmember">
    <xsl:param name="theClass"/>

    <xsl:variable name="min" select="tei:classes/tei:memberOf[@key=$theClass]/@min"/>
    <xsl:variable name="max" select="tei:classes/tei:memberOf[@key=$theClass]/@max"/>

    <xsl:variable name="mini" as="xs:integer">
      <xsl:choose>
        <xsl:when test="not($min castable as xs:integer)">1</xsl:when>
        <xsl:otherwise><xsl:value-of select="$min"/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="elementPrefix">
      <xsl:choose>
        <xsl:when test="@prefix">
          <xsl:value-of select="@prefix"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$generalPrefix"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="ident" select="@ident"/>
    
    <xsl:for-each select="for $i in 1 to $mini return $i">
      <rng:ref name="{$elementPrefix}{$ident}"/>
    </xsl:for-each> 
    <xsl:choose>
      <xsl:when test="$max='unbounded'">
        <rng:zeroOrMore>
          <rng:ref name="{$elementPrefix}{$ident}"/>
        </rng:zeroOrMore>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="maxi" as="xs:integer">
          <xsl:choose>
            <xsl:when test="not($max castable as xs:integer)">1</xsl:when>
            <xsl:otherwise><xsl:value-of select="$max"/></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:for-each select="for $i in ($mini+1) to $maxi return $i">
          <rng:optional>
            <rng:ref name="{$elementPrefix}{$ident}"/>
          </rng:optional>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose> 
  </xsl:template>

  <xsl:template match="tei:elementSpec" mode="tangle">
    <xsl:variable name="elementPrefix">
      <xsl:choose>
        <xsl:when test="@prefix">
          <xsl:value-of select="@prefix"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$generalPrefix"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$verbose='true'">
      <xsl:message> elementSpec [<xsl:value-of select="$elementPrefix"/>]<xsl:value-of select="@ident"/>
        <xsl:if test="@xml:id">: <xsl:value-of select="@xml:id"/>
        </xsl:if>
      </xsl:message>
    </xsl:if>
    <xsl:call-template name="schemaOut">
      <xsl:with-param name="grammar"/>
      <xsl:with-param name="content">
        <Wrapper>
          <xsl:variable name="name" select="tei:createSpecName(.)"/>
          <xsl:choose>
            <xsl:when test="tei:content/rng:notAllowed">
              <rng:define name="{$elementPrefix}{@ident}">
                <rng:notAllowed/>
              </rng:define>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="Attributes">
                <xsl:call-template name="summarizeAttributes"/>
              </xsl:variable>
              <rng:define name="{$elementPrefix}{@ident}">
                <element name="{$name}" xmlns="http://relaxng.org/ns/structure/1.0">
                  <xsl:if test="@ns">
                    <xsl:attribute name="ns">
                      <xsl:value-of select="@ns"/>
                    </xsl:attribute>
                  </xsl:if>
                  <xsl:if test="not($oddmode = 'tei')">
                    <a:documentation>
                      <xsl:sequence select="tei:makeDescription(., true(), true())"/>
                    </a:documentation>
                  </xsl:if>
                  <xsl:choose>
                    <xsl:when test="$parameterize = 'true'">
                      <ref name="{$elementPrefix}{@ident}.content" xmlns="http://relaxng.org/ns/structure/1.0"/>
                      <xsl:if test="not($Attributes = '')">
                        <xsl:if test="$verbose = 'true'">
                          <xsl:message> refer to attributes: </xsl:message>
                        </xsl:if>
                        <ref name="{$elementPrefix}{@ident}.localattributes" xmlns="http://relaxng.org/ns/structure/1.0"/>
                      </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:call-template name="defineContent"/>
                      <xsl:if test="not($Attributes = '')">
                        <xsl:call-template name="defineAttributes"/>
                      </xsl:if>
                    </xsl:otherwise>
                  </xsl:choose>
                </element>
              </rng:define>
              <xsl:if test="$parameterize = 'true'">
                <rng:define
                  name="{$elementPrefix}{@ident}.content">
                  <xsl:call-template name="defineContent"/>
                </rng:define>
                <xsl:if test="not($Attributes = '')">
                  <rng:define
                    name="{$elementPrefix}{@ident}.localattributes">
                    <xsl:call-template name="defineAttributes"/>
                  </rng:define>
                </xsl:if>
                <xsl:apply-templates mode="tangleModel" select="tei:classes/tei:memberOf"/>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </Wrapper>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="summarizeAttributes">
    <xsl:for-each select=".//tei:attDef">x</xsl:for-each>
    <xsl:for-each select=".//tei:attRef">x</xsl:for-each>
    <xsl:for-each select="tei:classes/tei:memberOf">
      <xsl:for-each select="key('CLASSES',@key)">
        <xsl:if test="@type='atts'">x</xsl:if>
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="defineAttributes">
    <xsl:variable name="ORIGINAL" select="."/>
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="@prefix">
          <xsl:value-of select="@prefix"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$generalPrefix"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:value-of select="@ident"/>
    </xsl:variable>
    <xsl:if test="$verbose='true'">
      <xsl:message>   now define attributes for <xsl:value-of
        select="@ident"/> (parameterize=<xsl:value-of select="$parameterize"/>)</xsl:message>
    </xsl:if>
    <xsl:if test="$parameterize='true'">
      <xsl:if test="$autoGlobal='true'">
        <rng:ref name="att.global.attributes"/>
      </xsl:if>
      <xsl:for-each select="tei:classes/tei:memberOf">
        <xsl:for-each select="key('CLASSES',@key)">
          <xsl:if test="@type='atts'">
            <rng:ref>
              <xsl:attribute name="name">
                <xsl:choose>
                  <xsl:when test="@prefix">
                    <xsl:value-of select="@prefix"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$generalPrefix"/>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:value-of select="@ident"/>
                <xsl:text>.attributes</xsl:text>
              </xsl:attribute>
            </rng:ref>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:if>
    <xsl:apply-templates mode="tangle" select="tei:attList">
      <xsl:with-param name="element">
        <xsl:value-of select="$name"/>
      </xsl:with-param>
    </xsl:apply-templates>
    <!-- place holder to make sure something gets into the
      pattern -->
    <rng:empty/>
  </xsl:template>

  <xsl:template name="defineContent">
    <xsl:variable name="Contents">
      <TEMPTREE>
        <xsl:choose>
          <xsl:when test="tei:valList[@type='closed']">
            <xsl:call-template name="valListChildren"/>
          </xsl:when>
          <xsl:when test="tei:content/*">
            <xsl:apply-templates
                select="tei:content/*|tei:content/processing-instruction()"
                mode="tangle"/>
          </xsl:when>
          <xsl:when test="tei:content/processing-instruction()">
            <xsl:apply-templates
                select="tei:content/processing-instruction()" mode="tangle"/>
          </xsl:when>
        </xsl:choose>
      </TEMPTREE>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="count($Contents/TEMPTREE/*)=0">
        <rng:empty/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$Contents/TEMPTREE">
          <xsl:apply-templates mode="justcopy"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:call-template name="schematronInContent"/>
  </xsl:template>


  <xsl:template name="valListChildren">
    <rng:choice>
      <xsl:for-each select="tei:valList/tei:valItem">
        <rng:value>
          <xsl:value-of select="tei:createSpecName(.)"/>
        </rng:value>
        <xsl:if test="not($oddmode='tei')">
          <a:documentation>
            <xsl:sequence select="tei:makeDescription(., true(), true())"/>
          </a:documentation>
        </xsl:if>
      </xsl:for-each>
    </rng:choice>
  </xsl:template>


  <xsl:template match="tei:classSpec/@ident"/>
  <xsl:template match="tei:classSpec/tei:desc"/>
  <xsl:template match="tei:classSpec/tei:gloss"/>
  <xsl:template match="tei:dataSpec/@ident"/>
  <xsl:template match="tei:dataSpec/tei:desc"/>
  <xsl:template match="tei:dataSpec/tei:gloss"/>
  <xsl:template match="tei:elementSpec/@ident"/>
  <xsl:template match="tei:elementSpec/tei:desc"/>
  <xsl:template match="tei:elementSpec/tei:gloss"/>
  <xsl:template match="tei:macroSpec/@ident"/>
  <xsl:template match="tei:macroSpec/tei:desc"/>
  <xsl:template match="tei:macroSpec/tei:gloss"/>

  

  <xsl:template match="tei:index">
      <xsl:call-template name="makeAnchor">
        <xsl:with-param name="name">IDX-<xsl:number level="any"/>
        </xsl:with-param>
      </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:dataSpec | tei:macroSpec" mode="tangle">
    <xsl:param name="filename"/>
    <xsl:variable name="macroPrefix">
      <xsl:choose>
        <xsl:when test="@prefix">
          <xsl:value-of select="@prefix"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$generalPrefix"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="entityContent">
      <TEMPTREE>
        <xsl:choose>
          <xsl:when test="tei:valList[@type = 'closed']">
            <xsl:call-template name="valListChildren"/>
          </xsl:when>
          <xsl:when test="tei:content/rng:group/rng:ref">
            <xsl:apply-templates select="tei:content/* | tei:content/processing-instruction()"/>
          </xsl:when>
          <xsl:when test="tei:content/rng:group">
            <rng:choice>
              <xsl:apply-templates select="tei:content/rng:group/*"/>
            </rng:choice>
          </xsl:when>
          <xsl:when test="tei:content/tei:*">
            <xsl:apply-templates select="tei:content/tei:*" mode="tangle"/>
          </xsl:when>
          <xsl:when test="tei:content/*">
            <xsl:apply-templates select="tei:content/*"/>
          </xsl:when>
          <xsl:when test="tei:content/processing-instruction()">
            <xsl:apply-templates select="tei:content/processing-instruction()"/>
          </xsl:when>
        </xsl:choose>
      </TEMPTREE>
    </xsl:variable>
    <xsl:variable name="entityCount">
      <xsl:for-each select="$entityContent/TEMPTREE">
        <xsl:value-of select="count(rng:* | processing-instruction())"/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="starts-with($entityContent,&#34;'&#34;)">
        <xsl:if test="$verbose = 'true'">
          <xsl:message>Omit <xsl:value-of select="$entityContent"/> for <xsl:value-of
              select="@ident"/>
          </xsl:message>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$entityCount = 0 and starts-with($entityContent,&#34;-&#34;)">
        <xsl:if test="$verbose = 'true'">
          <xsl:message>Omit <xsl:value-of select="$entityContent"/> for <xsl:value-of
              select="@ident"/>
          </xsl:message>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$verbose = 'true'">
          <xsl:message> macro/data Spec <xsl:value-of select="@ident"/>: <xsl:copy-of
              select="$entityContent"/></xsl:message>
        </xsl:if>
        <xsl:call-template name="schemaOut">
          <xsl:with-param name="grammar">true</xsl:with-param>
          <xsl:with-param name="content">
            <Wrapper>
              <rng:define name="{$macroPrefix}{@ident}">
                <xsl:if test="$parameterize = 'true'">
                  <xsl:if test="starts-with(@ident, 'macro.component') or @predeclare = 'true'">
                    <xsl:attribute name="combine">choice</xsl:attribute>
                  </xsl:if>
                </xsl:if>
                <xsl:choose>
                  <xsl:when test="starts-with(@ident, 'type')">
                    <xsl:apply-templates mode="justcopy" select="$entityContent/TEMPTREE/node()"/>
                  </xsl:when>
                  <xsl:when test="$entityCount = 0">
                    <rng:choice>
                      <rng:empty/>
                    </rng:choice>
                  </xsl:when>
                  <xsl:when test="$entityCount = 1">
                    <xsl:apply-templates mode="justcopy" select="$entityContent/TEMPTREE/node()"/>
                  </xsl:when>
                  <xsl:when test="tei:content/rng:text | tei:content/rng:ref">
                    <rng:choice>
                      <xsl:apply-templates mode="justcopy" select="$entityContent/TEMPTREE/node()"/>
                    </rng:choice>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates mode="justcopy" select="$entityContent/TEMPTREE/node()"/>
                  </xsl:otherwise>
                </xsl:choose>
              </rng:define>
            </Wrapper>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
  
  <xsl:template match="tei:dataRef" mode="#default tangle">
    <xsl:choose>
      <xsl:when test="@name">
        <rng:data type="{@name}">
          <xsl:if test="@restriction">
            <rng:param name="pattern">
              <xsl:value-of select="@restriction"/>
            </rng:param>
          </xsl:if>
        </rng:data>
      </xsl:when>
      <xsl:when test="@key">
        <rng:ref name="{@key}"/>
      </xsl:when>
      <!-- this routine does not process @ref, not sure why not (also not sure -->
      <!-- how we would do that, so maybe that's why not :-)  —Syd, 2016-11-25 -->
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:memberOf" mode="tangleModel">
    <!--
    <xsl:variable name="owner">
      <xsl:value-of
        select="ancestor::tei:elementSpec/@ident|ancestor::tei:classSpec/@ident"
      />
    </xsl:variable>
    <xsl:for-each select="key('IDENTS',@key)">
      <xsl:if test="@type='model'">
        <define combine="choice" name="{@ident}"
          xmlns="http://relaxng.org/ns/structure/1.0">
          <ref name="{$generalPrefix}{$owner}"
            xmlns="http://relaxng.org/ns/structure/1.0"/>
        </define>
      </xsl:if>
    </xsl:for-each>
-->
  </xsl:template>


  <xsl:template match="tei:moduleRef" mode="tangle">
    <!-- save a reference to myself so I can access my attrs and -->
    <!-- generated node ID later -->
    <xsl:variable name="me-the-moduleRef" select="."/>
    <xsl:variable name="This" select="@key"/>
    <xsl:if test="$verbose='true'">
      <xsl:message> .... import module [<xsl:value-of select="$This"/> <xsl:value-of select="@url"/>] </xsl:message>
    </xsl:if>
    <xsl:call-template name="schemaOut">
      <xsl:with-param name="grammar">true</xsl:with-param>
      <xsl:with-param name="content">
        <Wrapper>
          <xsl:choose>
            <xsl:when test="@url and $parameterize='true'">
              <rng:include href="{@url}">
                <xsl:apply-templates mode="justcopy"  select="tei:content/*"/>
              </rng:include>
            </xsl:when>
            <xsl:when test="@url and $parameterize='false'">
              <xsl:comment>Start of import of <xsl:value-of select="@url"/>
              </xsl:comment>
              <rng:div>
                <xsl:choose>
                  <xsl:when test="doc-available(resolve-uri(@url,$BASE))">
                    <xsl:for-each select="doc(resolve-uri(@url,$BASE))/rng:grammar">
                      <!-- the "expandRNG" processing changed 2011-08-25 by Syd Bauman: -->
                      <!-- added a 'prefix' parameter which value is prefixed to pattern -->
                      <!-- names in the included schema. This prevents collisions in the -->
                      <!-- output RNG. -->
                      <xsl:apply-templates mode="expandRNG" select="@*|node()">
                        <xsl:with-param name="prefix">
                          <xsl:if test="$me-the-moduleRef/@prefix">
                            <xsl:value-of select="$me-the-moduleRef/@prefix"/>
                          </xsl:if>
                        </xsl:with-param>
                      </xsl:apply-templates>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:message terminate="yes">
                      <xsl:text>Document not available: </xsl:text>
                      <xsl:value-of select="@url"/>
                    </xsl:message>
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates mode="justcopy"  select="tei:content/*"/>
              </rng:div>
              <xsl:comment>End of import of <xsl:value-of select="@url"/>
              </xsl:comment>
            </xsl:when>
            <xsl:otherwise>
              <rng:include
                href="{$schemaBaseURL}{$This}.rng">
                <xsl:attribute name="ns">
                  <xsl:choose>
                    <xsl:when test="ancestor::tei:schemaSpec/@ns">
                      <xsl:value-of select="ancestor::tei:schemaSpec/@ns"/>
                    </xsl:when>
                    <xsl:otherwise>http://www.tei-c.org/ns/1.0</xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:for-each select="../tei:*[@module=$This and not(@mode='add')]">
                  <xsl:apply-templates mode="tangle" select="."/>
                </xsl:for-each>
              </rng:include>
            </xsl:otherwise>
          </xsl:choose>
        </Wrapper>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <!-- begin expand RELAX NG section -->

  <xsl:template match="@*|text()|comment()|processing-instruction" mode="expandRNG">
    <xsl:copy-of select="."/>
  </xsl:template>
  
  <xsl:template match="rng:start" mode="expandRNG"/>
  
  <xsl:template match="rng:include" mode="expandRNG">
    <xsl:param name="prefix"/>
    <xsl:if test="$verbose='true'">
      <xsl:message> .... import <xsl:value-of select="@href"/></xsl:message>
    </xsl:if>
    <xsl:comment>Start of import of <xsl:value-of select="@href"/></xsl:comment>
    <rng:div>
    <xsl:for-each
          select="doc(resolve-uri(@href,base-uri(/)))/rng:grammar">
        <xsl:apply-templates mode="expandRNG" select="@*|node()">
          <xsl:with-param name="prefix" select="$prefix"/>
        </xsl:apply-templates>
      </xsl:for-each>
    </rng:div>
    <xsl:apply-templates mode="expandRNG" select="node()"/>
    <xsl:comment>End of import of <xsl:value-of select="@href"/>
    </xsl:comment>
  </xsl:template>
  
  <xsl:template match="rng:define | rng:ref" mode="expandRNG">
    <xsl:param name="prefix"/>
    <xsl:if test="$verbose='true'">
      <xsl:message>expanding rng:<xsl:value-of select="local-name(.)"/> name=<xsl:value-of select="@name"/>, giving it a prefix of '<xsl:value-of select="$prefix"/>'.</xsl:message>
    </xsl:if>
    <!-- generate a copy of this <define> or <ref> -->
    <xsl:copy>
      <!-- copy over all attributes (including @name) -->
      <xsl:apply-templates select="@*" mode="expandRNG"/>
      <xsl:if test="@name">
        <!-- then replace the copied @name with our own that is the same -->
        <!-- except has our prefix in the value -->
        <xsl:attribute name="name" select="concat( $prefix, @name )"/>
      </xsl:if>
      <!-- then copy over any content -->
      <xsl:apply-templates select="node()" mode="expandRNG">
        <xsl:with-param name="prefix" select="$prefix"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="*" mode="expandRNG">
    <xsl:param name="prefix">erng_</xsl:param>
    <xsl:copy>
      <xsl:apply-templates mode="expandRNG" select="@*|node()">
        <xsl:with-param name="prefix" select="$prefix"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!-- end expand RELAX NG section -->

  <xsl:template match="tei:remarks" mode="#default tangle"/>


  <xsl:template match="tei:specGrp" mode="ok">
    <xsl:param name="filename"/>
    <xsl:if test="$verbose='true'">
      <xsl:message> processing specGrp <xsl:value-of select="@xml:id"/>
      </xsl:message>
    </xsl:if>
    <xsl:call-template name="processSchemaFragment">
      <xsl:with-param name="filename" select="$filename"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="tei:tag">
    <xsl:call-template name="typewriter">
      <xsl:with-param name="text">
        <xsl:text>&lt;</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>&gt;</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="compositeNumber">
    <xsl:choose>
      <xsl:when test="ancestor::tei:div1">
        <xsl:for-each select="ancestor::tei:div1">
          <xsl:number/>
        </xsl:for-each>
        <xsl:text>.</xsl:text>
        <xsl:number from="tei:div1" level="any"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="ancestor::tei:div[1]">
          <xsl:number count="tei:div" from="tei:text" level="multiple"/>
        </xsl:for-each>
        <xsl:text>.</xsl:text>
        <xsl:number from="tei:div"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:p" mode="copyrighttext">
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:list" mode="copyrighttext">
    <xsl:text>&#10;</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:item" mode="copyrighttext">
    <xsl:text>&#10; *</xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:valList"   mode="#default tangle">
    <xsl:for-each select="..">
      <xsl:call-template name="valListChildren"/>
    </xsl:for-each>
  </xsl:template>
  
  <xsl:template name="attributeData">
    <xsl:choose>
      <xsl:when test="tei:valList[@type='closed']">
        <xsl:call-template name="valListChildren"/>
      </xsl:when>
      <xsl:when test="tei:valList[@type='semi']">
        <rng:choice>
          <xsl:for-each select="tei:valList/tei:valItem">
            <rng:value>
              <xsl:choose>
                <xsl:when test="tei:altIdent=@ident">
                  <xsl:value-of select="@ident"/>
                </xsl:when>
                <xsl:when test="tei:altIdent">
                  <xsl:value-of select="normalize-space(tei:altIdent)"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="@ident"/>
                </xsl:otherwise>
              </xsl:choose>
            </rng:value>
            <xsl:if test="not($oddmode='tei')">
              <a:documentation>
                <xsl:sequence select="tei:makeDescription(., true(), true())"/>
              </a:documentation>
            </xsl:if>
          </xsl:for-each>
          <xsl:choose>
            <xsl:when test="tei:datatype/rng:ref[@name='data.enumerated']">
              <rng:data type="Name"/>
            </xsl:when>
            <xsl:when test="not(tei:datatype)">
              <rng:data type="Name"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="tei:datatype/*"/>
            </xsl:otherwise>
          </xsl:choose>
        </rng:choice>
      </xsl:when>
      <xsl:when test="tei:datatype/*">
        <xsl:apply-templates select="tei:datatype/*"/>
      </xsl:when>
      <xsl:otherwise>
        <rng:text/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="makeSimpleAttribute">
    <xsl:variable name="name">
      <xsl:choose>
        <xsl:when test="tei:altIdent=@ident">
          <xsl:value-of select="@ident"/>
        </xsl:when>
        <xsl:when test="tei:altIdent">
          <xsl:value-of select="normalize-space(tei:altIdent)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="@ns='http://www.w3.org/XML/1998/namespace'">xml:</xsl:if>
          <xsl:value-of select="@ident"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <rng:attribute name="{$name}">
      <xsl:if test="@ns">
        <xsl:copy-of select="@ns"/>
      </xsl:if>
      <xsl:if test="tei:defaultVal and not(tei:defaultVal='')">
        <xsl:attribute name="a:defaultValue">
          <xsl:value-of select="normalize-space(tei:defaultVal)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="not($oddmode='tei')">
        <a:documentation>
          <xsl:sequence select="tei:makeDescription(., true(), true())"/>
        </a:documentation>
      </xsl:if>
      <xsl:variable name="norMinMax" as="item()+" select="if (tei:datatype) then tei:norMinMax(tei:datatype) else ( 1, 1, '', '' )"/>
      <xsl:variable name="min" select="$norMinMax[1]"/>
      <xsl:variable name="max" select="$norMinMax[2]"/>
      <xsl:choose>
        <xsl:when test="$min eq 0 and $max eq 1">
          <rng:optional>
            <xsl:call-template name="attributeData"/>
          </rng:optional>
        </xsl:when>
        <xsl:when test="tei:datatype/rng:text  or  not( tei:datatype ) or $max eq 1">
          
          <!-- If there is only going to be one output RELAX NG node   --> 
          <!-- in the attribute definition, then we don't need to      -->
          <!-- bother with the complex min & max code below (in the    -->
          <!-- <xsl:otherwise>). Although it would generate the right  -->
          <!-- number of RELAX NG constructs, it wraps them in a       -->
          <!-- <list>, which makes no sense in some cases, and will    -->
          <!-- cause an error if the RELAX NG node inside the list is  -->
          <!-- <text>.                                                 -->
          <!-- Cases we handle here:                                   -->
          <!-- * my <datatype> child has an <rng:text> child: only 1   -->
          <!--   output node (<rng:text>), which can't be wrapped in   -->
          <!--   a <list>                                              -->
          <!-- * I don't have a <datatype> child: the 'attributeData'  -->
          <!--   template will spit out a single <rng:text> node (see  -->
          <!--   the outermost <xsl:otherwise> of that template)       -->
          <!-- * @maxOccurs=1: whatever ends up being generated, there -->
          <!--   will only be 1 of them, so no need for a <list>       -->
          <xsl:call-template name="attributeData"/>
        </xsl:when>
        <xsl:otherwise>
          <!-- Note that in the (erroneous) event   -->
          <!-- that minOccurs= is greater than      -->
          <!-- maxOccurs=, the latter is simply     -->
          <!-- ignored.                             -->
          <!-- Hack(?): -->
          <!-- The 'attributeData' template needs to operate from this node; -->
          <!-- However, once we've used for-each to "loop", we've lost the -->
          <!-- current node (it has become one of the integers in the select= -->
          <!-- range). So here we remember the current node, and re-set it -->
          <!-- before calling 'attributeData'. Perhaps it would be better to -->
          <!-- send it as a parameter to 'attributeData' and have it set the -->
          <!-- current node, but since I didn't write 'attributeData', I've -->
          <!-- chosen this method so I don't have to muck with it. —Syd -->
          <xsl:variable name="thisNode" select="."/>
          <rng:list>
            <xsl:choose>
              <xsl:when test="$max eq -1 (: i.e., unbounded :)  and  $min eq 1">
                <rng:oneOrMore>
                  <xsl:for-each select="$thisNode">
                    <xsl:call-template name="attributeData"/>
                  </xsl:for-each>
                </rng:oneOrMore>
              </xsl:when>
              <xsl:otherwise>
                <xsl:if test="$min gt 0">
                  <xsl:for-each select="1 to $min">
                    <xsl:for-each select="$thisNode">
                      <xsl:call-template name="attributeData"/>
                    </xsl:for-each>
                  </xsl:for-each>
                </xsl:if>
                <xsl:choose>
                  <xsl:when test="$max eq -1"><!-- i.e., unbounded -->
                    <rng:zeroOrMore>
                      <xsl:for-each select="$thisNode">
                        <xsl:call-template name="attributeData"/>
                      </xsl:for-each>
                    </rng:zeroOrMore>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:for-each select="$min+1 to $max">
                      <rng:optional>
                        <xsl:for-each select="$thisNode">
                          <xsl:call-template name="attributeData"/>
                        </xsl:for-each>
                      </rng:optional>
                    </xsl:for-each>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:otherwise>
            </xsl:choose>
          </rng:list>
        </xsl:otherwise>
      </xsl:choose>
    </rng:attribute>
  </xsl:template>

  <xsl:template name="makeAnAttribute">
    <xsl:choose>
      <xsl:when test="@usage='req'">
        <xsl:call-template name="makeSimpleAttribute"/>
      </xsl:when>
      <!--
      <xsl:when test="parent::tei:attList[@org='choice']">
        <xsl:call-template name="makeSimpleAttribute"/>
      </xsl:when>
-->
      <xsl:otherwise>
        <rng:optional>
          <xsl:call-template name="makeSimpleAttribute"/>
        </rng:optional>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:template>

  <xsl:template name="generateClassParents">
    <xsl:choose>
      <xsl:when test="not(tei:classes)"> (none) </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="tei:classes/tei:memberOf">
          <xsl:if test="preceding-sibling::tei:memberOf">
            <xsl:text>: </xsl:text>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="key('CLASSES',@key)">
              <xsl:for-each select="key('CLASSES',@key)">
                <xsl:call-template name="linkTogether">
                  <xsl:with-param name="name" select="@ident"/>
                </xsl:call-template>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@key"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="linkStyle"/>


  <xsl:template name="getSpecURL">
    <xsl:param name="name"/>
    <xsl:param name="type"/>
    <xsl:choose>
      <xsl:when test="$type='macro'">
        <xsl:for-each select="id('REFENT')">
          <xsl:apply-templates mode="generateLink" select="."/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$type='element'">
        <xsl:for-each select="id('REFTAG')">
          <xsl:apply-templates mode="generateLink" select="."/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$type='class'">
        <xsl:for-each select="id('REFCLA')">
          <xsl:apply-templates mode="generateLink" select="."/>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>
    <xsl:text>#</xsl:text>
    <xsl:value-of select="$name"/>
  </xsl:template>


  <xsl:template name="linkTogether">
    <xsl:param name="name"/>
    <xsl:param name="reftext"/>
    <xsl:param name="class">link_odd</xsl:param>

    <xsl:variable name="partialname">
      <xsl:value-of select="replace($name,'_(alternation|sequenceOptionalRepeatable|sequenceOptional|sequenceRepeatable|sequence)','')"/>
    </xsl:variable>
    <xsl:variable name="link">
      <xsl:choose>
        <xsl:when test="$reftext=''">
          <xsl:value-of select="$name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$reftext"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="glossAndDesc">
      <!-- This variable will hold the string value of the <gloss> and -->
      <!-- <desc> of the construct we are currently dealing with, in   -->
      <!-- the language we are currently dealing with, so as to put it -->
      <!-- on the title= attribute when we output its name in an <a>.  -->
      <xsl:choose>
        <xsl:when test="starts-with( $partialname, 'model.')">
          <xsl:apply-templates select="key('CLASSES', $partialname)" mode="glossDesc"/>
        </xsl:when>
        <xsl:when test="starts-with( $partialname, 'att.')">
          <xsl:apply-templates select="key('CLASSES', replace( $partialname, '\.attributes$',''))" mode="glossDesc"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="key('ELEMENTS', $partialname )" mode="glossDesc"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="not(key('IDENTS',$partialname))">
        <xsl:value-of select="$link"/>
      </xsl:when>
      <xsl:when test="$oddmode='html' and number($splitLevel)=-1">
        <a xmlns="http://www.w3.org/1999/xhtml" class="{$class}" href="#{$partialname}">
          <xsl:value-of select="$link"/>
        </a>
      </xsl:when>
      <xsl:when test="$oddmode='html' and $STDOUT='true'">
        <a xmlns="http://www.w3.org/1999/xhtml" class="{$class}">
          <xsl:attribute name="href">
            <xsl:for-each select="key('IDENTS',$partialname)">
              <xsl:call-template name="getSpecURL">
                <xsl:with-param name="name">
                  <xsl:value-of select="$partialname"/>
                </xsl:with-param>
                <xsl:with-param name="type">
                  <xsl:value-of select="substring-before(local-name(),'Spec')"/>
                </xsl:with-param>
              </xsl:call-template>
            </xsl:for-each>
          </xsl:attribute>
          <xsl:value-of select="$link"/>
        </a>
      </xsl:when>


      <xsl:when test="$oddmode='html'">
        <a xmlns="http://www.w3.org/1999/xhtml" class="{$class}" title="{$glossAndDesc}"
          href="{concat('ref-',$partialname,'.html')}">
          <xsl:value-of select="$link"/>
        </a>
      </xsl:when>

      <xsl:when test="$oddmode='pdf'">
        <fo:inline>
          <xsl:value-of select="$link"/>
        </fo:inline>
      </xsl:when>

      <xsl:when test="$oddmode='tei'">
        <tei:ref target="#{$partialname}">
          <xsl:value-of select="$link"/>
        </tei:ref>
      </xsl:when>

      <xsl:otherwise>
        <xsl:value-of select="$link"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="processSchemaFragment">
    <xsl:param name="filename"/>
    <xsl:variable name="secnum">
      <xsl:call-template name="sectionNumber"/>
    </xsl:variable>
    <xsl:apply-templates mode="tangle"/>
  </xsl:template>


  <xsl:template name="make-ns-declaration">
    <xsl:param name="is-default"/>
    <xsl:param name="prefix"/>
    <xsl:param name="uri"/>
  </xsl:template>

  <xsl:template name="inhnamespace"/>

  <xsl:template match="tei:constraintSpec/tei:desc"/>
  <xsl:template match="tei:constraintSpec/tei:gloss"/>
  <xsl:template match="tei:constraintSpec/tei:equiv"/>


  <xsl:template match="tei:altIdent"/>

  <xsl:template match="a:*">
    <xsl:apply-templates mode="justcopy" select="."/>
  </xsl:template>

  <xsl:template match="tei:classSpec" mode="processDefaultAtts">
    <xsl:if test="$verbose='true'">
      <xsl:message> .. default attribute settings for <xsl:value-of select="@ident"/>
      </xsl:message>
    </xsl:if>
    <xsl:call-template name="schemaOut">
      <xsl:with-param name="grammar">true</xsl:with-param>
      <xsl:with-param name="content">
        <Wrapper>
          <xsl:variable name="c">
            <xsl:choose>
              <xsl:when test="@prefix">
                <xsl:value-of select="@prefix"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$generalPrefix"/>
              </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="@ident"/>
          </xsl:variable>
          <rng:define combine="choice"
            name="{$c}.attributes">
            <rng:empty/>
          </rng:define>
        </Wrapper>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>Process element schemaSpec</desc>
  </doc>

  <xsl:template match="tei:schemaSpec">
    <xsl:call-template name="processSchemaFragment"/>
  </xsl:template>

  <xsl:template name="generateOutput">
    <xsl:param name="body"/>
    <xsl:param name="suffix"/>
    <xsl:param name="method">xml</xsl:param>
    <xsl:variable name="processor">
      <xsl:value-of select="system-property('xsl:vendor')"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$outputDir='' or $outputDir='-'">
        <xsl:copy-of select="$body"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:result-document encoding="{$outputEncoding}" href="{$outputDir}/{@ident}{$suffix}" method="{$method}">
          <xsl:copy-of select="$body"/>
        </xsl:result-document>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template name="sectionNumber">
    <xsl:for-each
      select="(ancestor::tei:div1|ancestor::tei:div2|ancestor::tei:div3|ancestor::tei:div4)[last()]">
      <xsl:for-each select="ancestor-or-self::tei:div1">
        <xsl:number from="tei:body" level="any"/>
        <xsl:text>.</xsl:text>
      </xsl:for-each>
      <xsl:number count="tei:div2|tei:div3|tei:div4" from="tei:div1" level="multiple"/>
    </xsl:for-each>
  </xsl:template>


  <xsl:template match="*" mode="expandSpecs">
    <xsl:apply-templates mode="justcopy" select="."/>
  </xsl:template>

  <xsl:template match="tei:specGrpRef" mode="expandSpecs">
    <xsl:choose>
      <xsl:when test="starts-with(@target,'#')">
        <xsl:for-each select="id(substring(@target,2))">
          <xsl:apply-templates mode="expandSpecs"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="doc(resolve-uri(@target,$BASE))" mode="expandSpecs"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- list inside <desc> -->
  <xsl:template match="tei:desc/tei:list/tei:item" mode="glossDescTitle #default">
    <xsl:text> * </xsl:text>
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="makeTEIVersion">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::tei:TEI/processing-instruction()[name() eq 'TEIVERSION']">
        <!-- JC Additions to form proper URL from version number -->
        <!-- MH and SB: Note that this PI is created during odd2odd.xsl, and used to store version 
             information from p5subset.xml. -->
        <!-- SB modified 2023-05-01 —
          * Simplify code
          * Correctly extract only the version number itself per ticket #607
            - Note that we need to be prepared for both "P5 Version&#xA0;…" and just "Version&#xA0;…"
          * Normalize space of “TEI Edition” output so it is all on one line
        -->
        <xsl:variable name="TEIVersion" select="ancestor-or-self::tei:TEI/processing-instruction()[name() eq 'TEIVERSION'][1]"/>
        <xsl:variable name="TEIVersion-edition" select="substring-before( $TEIVersion, ' Last')"/>
        <xsl:variable name="TEIVersion-datestring" select="concat(' Last', substring-after( $TEIVersion, ' Last') )"/>
        <xsl:variable name="TEIVersion-only" select="replace( $TEIVersion-edition, '^(P5 )?Version&#xA0;(\d+\.\d+\.\d+[abABɑΑΒβ]?)\.$', '$2')"/>
        <xsl:variable name="versionURL" select="concat( $defaultTEIServer, $TEIVersion-only, '/')"/>
        <xsl:sequence select="'&#x0A;TEI Edition: '||normalize-space($TEIVersion)"/>
        <xsl:sequence select="'&#x0A;TEI Edition Location: '||$versionURL"/>
        <xsl:text>&#x0A;</xsl:text>
      </xsl:when>
      <xsl:when test="ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition">
        <xsl:text>&#x0A;Edition: </xsl:text>
        <xsl:value-of select="ancestor-or-self::tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:edition"/>
        <xsl:text>&#x0A;</xsl:text>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  
  <!-- process <gloss> and <desc> to make title= attribute values -->
  <xsl:template match="tei:gloss" mode="glossDescTitle">
    <!-- At the moment the only descendants of a <gloss> that appears in <elementSpec> or <classSpec> -->
    <!-- are 3 <gloss> and 1 <ident>, so we can get away with just taking the value, rather than -->
    <!-- applying templates. -->
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  <xsl:template match="tei:desc" mode="glossDescTitle">
    <!-- 
         As of 2014-08-12, revision 12970, the only descendants of a
         <desc> that appears in an <elementSpec> or a <classSpec> are:
           329 gi
            79 term
            68 att
            11 soCalled
             6 mentioned
             5 ident
             2 q
             2 val
             1 foreign
             1 ref
             1 title
         You might think that from here we can just <apply-templates>
         and be done with it. But if we do that, we end up with an infinite-
         loop of called templates problem. To wit, inside the <desc> we are
         processing there are (e.g.) <gi> elements. They get caught by a
         template in html/html_oddprocessing.xsl, which goes about calling
         linkTogether, which goes about applying templates (in mode glossDesc)
         to the <elementSpec> that defines the element mentioned in the content
         of the <gi>. That, in turn, would apply templates to the <desc> that
         we started with.
    -->
    <xsl:apply-templates mode="#current"/>
  </xsl:template>
  <xsl:template match="tei:gi" mode="glossDescTitle">
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>></xsl:text>
  </xsl:template>
  <xsl:template match="tei:att" mode="glossDescTitle">
    <xsl:text>@</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
  </xsl:template>
  <xsl:template match="tei:term|tei:ref|tei:ident|tei:code|tei:foreign" mode="glossDescTitle">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="tei:mentioned|tei:q" mode="glossDescTitle">
    <xsl:text>“</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>”</xsl:text>
  </xsl:template>
  <xsl:template match="tei:val" mode="glossDescTitle">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>"</xsl:text>
  </xsl:template>
  <xsl:template match="tei:soCalled" mode="glossDescTitle">
    <xsl:text>‘</xsl:text>
    <xsl:value-of select="normalize-space(.)"/>
    <xsl:text>’</xsl:text>
  </xsl:template>
  <xsl:template match="tei:title" mode="glossDescTitle">
    <xsl:text>_</xsl:text>
    <xsl:value-of select="translate( normalize-space(.), ' ', '_' )"/>
    <xsl:text>_</xsl:text>
  </xsl:template>
  
  <xsl:template name="processSchematron">
    <xsl:choose>
      <xsl:when test="self::sch:ns | self::sch:pattern">
        <xsl:apply-templates mode="justcopy" select="."/>
      </xsl:when>
      <xsl:when test="self::sch:rule[not(preceding-sibling::sch:rule)]">
        <pattern xmlns="http://purl.oclc.org/dsdl/schematron">
          <xsl:attribute name="id" select="tei:makePatternID(.)"/>
          <xsl:apply-templates mode="justcopy" select="../sch:rule"/>
        </pattern>
      </xsl:when>
      <xsl:when test="self::sch:rule"/>  <!-- processed immediately above -->
      <xsl:when test="self::sch:let"/>  <!-- <let> processed below -->
      <xsl:when test="(self::sch:assert|self::sch:report)[not( preceding-sibling::sch:assert|preceding-sibling::sch:report )]">
        <pattern xmlns="http://purl.oclc.org/dsdl/schematron">
          <xsl:attribute name="id" select="tei:makePatternID(.)"/>
          <rule>
            <xsl:attribute name="context">
              <xsl:choose>
                <!-- in <attDef> in <elementSpec>: -->
                <xsl:when test="ancestor::tei:attDef/ancestor::tei:elementSpec">
                  <xsl:sequence select="tei:generate-nsprefix-schematron(.)"/>
                  <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
                  <xsl:text>/@</xsl:text>
                  <xsl:value-of select="ancestor::tei:attDef/@ident"/>
                  <xsl:text></xsl:text> <!-- what does this do? —Syd, 2020-02-15 -->
                </xsl:when>
                <!-- in <attDef> in something else: -->
                <xsl:when test="ancestor::tei:attDef">
                  <xsl:text>@</xsl:text>
                  <xsl:value-of select="ancestor::tei:attDef/@ident"/>
                </xsl:when>               
                <xsl:otherwise>
                  <!-- ?? I guess we figure we must be in an
                       <elementSpec>, but I am not at all convinced
                       that is necessarily true. —Syd, 2020-02-15 -->
                  <xsl:sequence select="tei:generate-nsprefix-schematron(.)"/>
                  <xsl:value-of select="ancestor::tei:elementSpec/@ident"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates mode="justcopy" select="parent::*/(sch:let|sch:assert|sch:report)"/>
          </rule>
        </pattern>
      </xsl:when>
      <xsl:when test="self::sch:assert|self::sch:report"/>  <!-- processed immediately above -->
      <xsl:otherwise>
        <xsl:apply-templates mode="justcopy" select="parent::*/sch:let|."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:function name="tei:message" as="xs:string">
    <xsl:param name="message"/>
    <xsl:message><xsl:copy-of select="$message"/></xsl:message>
    <xsl:text/>
  </xsl:function>

  <xsl:template name="die">
    <xsl:param name="message"/>
    <xsl:message terminate="yes">
      <xsl:text>Error: teiodds.xsl: </xsl:text> 
      <xsl:value-of select="$message"/>
    </xsl:message>
  </xsl:template>

   <xsl:template match="@*|text()" mode="justcopy">
      <xsl:copy-of select="."/>
   </xsl:template>

   <xsl:template match="processing-instruction()" mode="justcopy">
      <xsl:copy-of select="."/>
   </xsl:template>

   <xsl:template match="*" mode="justcopy">
     <xsl:copy>
         <xsl:apply-templates
             select="*|@*|processing-instruction()|text()" mode="justcopy"/>
     </xsl:copy>
   </xsl:template>

   <xsl:template match="a:*" mode="justcopy">
     <xsl:element namespace="http://relaxng.org/ns/compatibility/annotations/1.0" name="{name()}">
         <xsl:apply-templates
             select="*|@*|processing-instruction()|text()" mode="justcopy"/>
      </xsl:element>
   </xsl:template>

   <xsl:template match="rng:*" mode="justcopy">
     <xsl:element namespace="http://relaxng.org/ns/structure/1.0" name="{local-name()}">
       <xsl:apply-templates
           select="*|@*|processing-instruction()|text()" mode="justcopy"/>
     </xsl:element>
   </xsl:template>

   <!-- for Pure ODD -->
   <xsl:template match="tei:sequence | tei:interleave" mode="#default tangle">
     <!-- sequences of <dataRef> need use <list>, not <group> -->
     <xsl:variable name="group_or_list" select="if ( *[ not( self::tei:dataRef ) ] ) then 'group' else 'list'"/>
     <xsl:variable name="to_be_sequenced" as="element()+">
       <xsl:apply-templates mode="tangle" select="*"/>
     </xsl:variable>
     <xsl:variable name="group_or_list_content" as="element()+">
       <xsl:choose>
         <xsl:when test="@preserveOrder eq 'false'  or  self::tei:interleave">
           <rng:interleave>
             <xsl:sequence select="$to_be_sequenced[self::element()]"/>
           </rng:interleave>
         </xsl:when>
         <xsl:otherwise>
           <xsl:sequence select="$to_be_sequenced[self::element()]"/>
         </xsl:otherwise>
       </xsl:choose>
     </xsl:variable>
     <xsl:variable name="repeatMe" as="element()+">
       <xsl:sequence select="$group_or_list_content"/>
     </xsl:variable>
     <xsl:element name="{$group_or_list}" namespace="http://relaxng.org/ns/structure/1.0">
       <xsl:call-template name="repeat_as_needed">
         <xsl:with-param name="repeatMe" select="$repeatMe" as="element()+"/>
       </xsl:call-template>
     </xsl:element>
   </xsl:template>

  <xsl:template match="tei:textNode"   mode="#default tangle">
    <rng:text/>
  </xsl:template>

  <xsl:template match="tei:alternate"  mode="#default tangle">
    <xsl:variable name="repeatMe" as="element()">
      <rng:choice>
        <xsl:apply-templates mode="tangle"/>
      </rng:choice>
    </xsl:variable>
     <xsl:call-template name="repeat_as_needed">
       <xsl:with-param name="repeatMe" select="$repeatMe" as="element()"/>
     </xsl:call-template>
  </xsl:template>
  
  <xsl:template match="tei:elementRef|tei:classRef|tei:macroRef"   mode="#default tangle">
    <xsl:variable name="prefixedName" select="tei:generateRefPrefix(.)"/>
    <xsl:variable name="norMinMax" select="tei:norMinMax(.)"/>
    <xsl:variable name="min" select="$norMinMax[1]"/>
    <xsl:variable name="max" select="$norMinMax[2]"/>
    <!-- "owe" = occurence wrapper element -->
    <xsl:variable name="owe" select="$norMinMax[3]"/>
    <?tei winita UPDATE for #627 needed here — Syd, 2023-10-01 ?>
    <xsl:variable name="this" select="@key"/>
    <xsl:variable name="except" select="@except"/>
    <xsl:variable name="include" select="@include"/>
    <xsl:variable name="c" as="element()*">
      <xsl:choose>
        <xsl:when test="not(@expand) and (@include or @except)">
          <xsl:variable name="context" select="."/>
          <xsl:for-each select="key('CLASSMEMBERS',$this)">
            <xsl:if test="key('IDENTS',@ident) and tei:includeMember(@ident,$except,$include)">
              <xsl:apply-templates select="." mode="classmember">
                <xsl:with-param name="theClass" select="$this"/>
                <xsl:with-param name="suffix" select="$context/@expand"/>
              </xsl:apply-templates>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="not(@expand)">
          <rng:ref name="{$prefixedName}"/>
        </xsl:when>
        <xsl:when test="@expand='sequence'">
          <xsl:for-each select="key('CLASSMEMBERS',$this)">
            <xsl:if test="tei:includeMember(@ident,$except,$include)">
              <xsl:apply-templates select="." mode="classmember">
                <xsl:with-param name="theClass" select="$this"/>
                <xsl:with-param name="suffix" select="@expand"/>
              </xsl:apply-templates>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="@expand='sequenceOptional'">
          <xsl:for-each select="key('CLASSMEMBERS',$this)">
            <xsl:if test="tei:includeMember(@ident,$except,$include)">
              <rng:optional>
                <xsl:apply-templates select="." mode="classmember">
                  <xsl:with-param name="theClass" select="$this"/>
                  <xsl:with-param name="suffix" select="@expand"/>
                </xsl:apply-templates>
              </rng:optional>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="@expand='sequenceRepeatable'">
          <xsl:for-each select="key('CLASSMEMBERS',$this)">
            <xsl:if test="tei:includeMember(@ident,$except,$include)">        
              <rng:oneOrMore>
                <xsl:apply-templates select="." mode="classmember">
                  <xsl:with-param name="theClass" select="$this"/>
                  <xsl:with-param name="suffix" select="@expand"/>
                </xsl:apply-templates>
              </rng:oneOrMore>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="@expand='sequenceOptionalRepeatable'">
          <xsl:for-each select="key('CLASSMEMBERS',$this)">
            <xsl:if test="tei:includeMember(@ident,$except,$include)">        
              <rng:zeroOrMore>
                <xsl:apply-templates select="." mode="classmember">
                  <xsl:with-param name="suffix" select="@expand"/>
                  <xsl:with-param name="theClass" select="$this"/>
                </xsl:apply-templates>
              </rng:zeroOrMore>
            </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <rng:choice>
            <xsl:for-each select="key('CLASSMEMBERS',$this)">
              <xsl:if test="tei:includeMember(@ident,$except,$include)">
                <xsl:apply-templates select="." mode="classmember">
                  <xsl:with-param name="suffix" select="@expand"/>
                  <xsl:with-param name="theClass" select="$this"/>
                </xsl:apply-templates>
              </xsl:if>
            </xsl:for-each>
          </rng:choice>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$min eq 1  and  $max eq 1">
        <xsl:copy-of select="$c"/>
      </xsl:when>
      <xsl:when test="$min = ( 0, 1 )  and  $max = ( 1, -1 )">
        <xsl:element name="{$owe}" namespace="http://relaxng.org/ns/structure/1.0">
          <xsl:copy-of select="$c"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="count" select="$max - $min"/>
        <rng:group>
          <xsl:choose>
            <xsl:when test="$min eq 0">
              <rng:optional>
                <xsl:copy-of select="$c"/>
              </rng:optional>
            </xsl:when>
            <xsl:otherwise>
              <xsl:for-each select="1 to min( ( $min, $maxint ) )">
                <xsl:copy-of select="$c"/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:choose>
            <xsl:when test="$max eq -1">
              <rng:zeroOrMore>
                <xsl:if test="$min gt $maxint">
                  <a:documentation> ODD calls for a minimum of <xsl:value-of select="$min"/> occurrences </a:documentation>
                </xsl:if>
                <xsl:copy-of select="$c"/>
              </rng:zeroOrMore>
            </xsl:when>
            <xsl:when test="$count ge $maxint">
              <rng:zeroOrMore>
                <a:documentation> ODD calls for <xsl:value-of
                  select="concat( $min, ' required followed by ',$count)"/> optional occurrences </a:documentation>
                <xsl:copy-of select="$c"/>
              </rng:zeroOrMore>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="generateDeterministicOptionals">
                <xsl:with-param name="count" select="$count"/>
                <xsl:with-param name="c" select="$c"/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </rng:group>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

    <doc xmlns="http://www.oxygenxml.com/ns/doc/xsl">
    <desc>
      <p>“normalized minimum and maximum occurences”, pronounced almost as “Norman Max”</p>
      <p>Input: an element node, theoretically a member of att.repeatable</p>
      <p>Output: a sequence of 4 items:
        <ul>
          <li>1) minOccurs as an integer</li>
          <li>2) maxOccurs as an integer, with -1 for "unbounded"</li>
          <li>3) a string that conforms to xs:NCName, the name of the RELAX NG element that
          should be used to generate this number of occurences, if any; one of "optional",
          "oneOrMore", "zeroOrMore", or '' (the empty string)</li>
          <li>4) a 0- or 1-character long string, the occurence
          indicator that should be used to generate this number of
          occurences in a DTD, if any; one of '?', '+', '*', or ''
          (the empty string)</li>
        </ul>
      </p>
    </desc>
  </doc>
  <xsl:function name="tei:norMinMax" as="item()+">
    <xsl:param name="me" as="element()"/>
    <!-- get the value of @minOccurs, defaulting to "1" -->
    <xsl:variable name="minOccurs" select="if ( $me/@minOccurs!normalize-space() ne '') then $me/@minOccurs!normalize-space() else '1'"/>
    <!-- get the value of @maxOccurs, defaulting to "1" -->
    <xsl:variable name="maxOccurs" select="if ( $me/@maxOccurs!normalize-space() ne '') then $me/@maxOccurs!normalize-space() else '1'"/>
    <!-- We now have two _string_ representations of the attrs, but -->
    <!-- we need integers. So cast them, converting "unbounded" to  -->
    <!-- a special flag value (-1): -->
    <xsl:variable name="min" select="xs:integer( $minOccurs )" as="xs:integer"/>
    <xsl:variable name="max" as="xs:integer">
      <xsl:choose>
        <xsl:when test="$maxOccurs castable as xs:integer">
          <!-- It's an integer, but abort if it cannot be used (i.e., min > max) -->
          <xsl:choose>
            <xsl:when test="xs:integer( $maxOccurs ) lt $min">
              <xsl:message terminate="yes">The default value of @maxOccurs is 1. You cannot have a @minOccurs greater than the @maxOccurs.</xsl:message>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="xs:integer( $maxOccurs )"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <!-- Must be "unbounded". -->
          <xsl:value-of select="-1"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
      Generate the local name of the RELAX NG element used to create
      the requested range of occurrences, iff it is one of the
      available possiblities. If not, use an empty text node (as a
      flag).
    -->
    <xsl:variable name="RelaxOccurenceWrapperElementName" as="xs:string">
      <xsl:choose>
        <xsl:when test="$min eq 0  and  $max eq  1">optional</xsl:when>
        <xsl:when test="$min eq 0  and  $max eq -1">zeroOrMore</xsl:when>
        <xsl:when test="$min eq 1  and  $max eq -1">oneOrMore</xsl:when>
        <xsl:otherwise><xsl:text/></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!--
      Generate the occurence indicator for DTDs, too
    -->
    <xsl:variable name="DTD_occurence_indicator" as="xs:string?">
      <xsl:choose>
        <xsl:when test="$me/tei:textNode | $me/rng:text">*</xsl:when>
        <xsl:when test="$min eq 0  and  $max eq  1">?</xsl:when>
        <xsl:when test="$min eq 0  and  $max eq -1">*</xsl:when>
        <xsl:when test="$min eq 1  and  $max eq -1">+</xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:sequence select="( $min, $max, $RelaxOccurenceWrapperElementName, $DTD_occurence_indicator )"/>
  </xsl:function>

  <xsl:function name="tei:generateAttRef" as="xs:string">
    <xsl:param name="context"/>
    <xsl:param name="prefix"/>
    <xsl:variable name="result">
    <xsl:for-each select="$context">
      <xsl:for-each select="key('IDENTS',@class)">
        <xsl:choose>
          <xsl:when test="@prefix">
            <xsl:value-of select="@prefix"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$prefix"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
      <xsl:choose>
        <xsl:when test="not(@name)">
          <xsl:value-of select="concat(@class,'.attributes')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat(@class,'.attribute.',translate(@name,':',''))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
    </xsl:variable>
    <xsl:value-of select="$result"/>
  </xsl:function>

  <xsl:template name="generateDeterministicOptionals">
    <xsl:param name="count"/>
    <xsl:param name="c"/>
    <xsl:choose>
      <xsl:when test="$count le 0"/>
      <xsl:otherwise>
        <rng:optional>
          <xsl:copy-of select="$c"/>
          <xsl:call-template name="generateDeterministicOptionals">
            <xsl:with-param name="count" select="$count - 1"/>
            <xsl:with-param name="c" select="$c"/>
          </xsl:call-template>
        </rng:optional>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:function name="tei:generateRefPrefix" as="xs:string">
    <xsl:param name="context"/>
    <!-- where we meet a pointer, we have a choice of how to proceed
         
         a) if there is no auto-prefixing, just use as is
         b) if the thing exists in the IDENTS table (which includes prefixes), and starts with the prefix, then use it as is
         c) if it exists in the IDENTS table and has a prefix, use that
         d) otherwise, if it exists in the IDENTS table use the general prefix
         e) otherwise, just use what we are given
    -->
    <xsl:for-each select="$context">
      <xsl:variable name="lookup" select="replace(@name|@key,'_(alternation|sequenceOptionalRepeatable|sequenceOptional|sequenceRepeatable|sequence)','')"/>
      <xsl:variable name="myprefix"
                    select="ancestor::*[@prefix][1]/@prefix"/>
      <xsl:variable name="fullname" select="@name|@key"/>
      <xsl:choose>
        <xsl:when test="ancestor::tei:content[@autoPrefix='false']">
          <xsl:value-of select="$fullname"/>
        </xsl:when>
        <xsl:when test="key('IDENTS',$lookup)">
          <xsl:for-each select="key('IDENTS',$lookup)[1]">
            <xsl:choose>
              <xsl:when test="@prefix and starts-with($fullname,@prefix)">
                <xsl:value-of select="$fullname"/>
              </xsl:when>
              <xsl:when test="@prefix">
                <xsl:value-of select="concat(@prefix,$fullname)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat($generalPrefix,$fullname)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$fullname"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <xsl:function name="tei:includeMember" as="xs:boolean">
    <xsl:param name="ident"  as="xs:string"/>
    <xsl:param name="exc" />
    <xsl:param name="inc" />
      <xsl:choose>
        <xsl:when test="not($exc) and not($inc)">true</xsl:when>
        <xsl:when test="$inc and $ident cast as xs:string  = tokenize($inc, ' ')">true</xsl:when>
        <xsl:when test="$inc">false</xsl:when>
        <xsl:when test="$exc and $ident cast as xs:string = tokenize($exc, ' ')">false</xsl:when>
        <xsl:otherwise>true</xsl:otherwise>
      </xsl:choose>
  </xsl:function>

  <xsl:template match="tei:elementSpec|tei:classSpec" mode="glossDesc">
    <!-- We should probably be more careful about the possibility -->
    <!-- of sub-languages (e.g., having descriptions in both 'en-US' and -->
    <!-- 'en-UK'). However, as of now there are no cases of any sublanguages -->
    <!-- that would cause a problem here. -->
    <xsl:variable name="generatedTitleAttrVal">
      <xsl:if test="tei:gloss[ lang( $targetLanguage ) ]">
        <xsl:text>(</xsl:text>
        <xsl:apply-templates select="tei:gloss[ lang( $targetLanguage ) ]" mode="glossDescTitle"/>
        <xsl:text>) </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="tei:desc[ lang( $targetLanguage ) ]" mode="glossDescTitle"/>
    </xsl:variable>
    <xsl:value-of select="normalize-space($generatedTitleAttrVal)"/>
  </xsl:template>

  <xsl:template match="tei:gloss" mode="inLanguage">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="tei:desc" mode="inLanguage">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template name="schematronInContent">
    <xsl:for-each select="tei:constraintSpec/tei:constraint/*">
      <xsl:call-template name="processSchematron"/>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="tei:constrainSpec|tei:constraint">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="sch:*">
    <xsl:call-template name="processSchematron"/>
  </xsl:template>
  
</xsl:stylesheet>
