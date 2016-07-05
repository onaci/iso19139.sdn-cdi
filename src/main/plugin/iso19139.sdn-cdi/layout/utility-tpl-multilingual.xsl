<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:gmd="http://www.isotc211.org/2005/gmd" xmlns:gco="http://www.isotc211.org/2005/gco"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:gn="http://www.fao.org/geonetwork"
  xmlns:xslutil="java:org.fao.geonet.util.XslUtil"
  exclude-result-prefixes="#all">


  <!-- Get the main metadata languages -->
  <xsl:template name="get-iso19139.sdn-cdi-language">
    <xsl:value-of select="$metadata/gmd:language/gco:CharacterString|
      $metadata/gmd:language/gmd:LanguageCode/@codeListValue"/>
  </xsl:template>


  <!-- Get the list of other languages in JSON -->
  <xsl:template name="get-iso19139.sdn-cdi-other-languages-as-json">
    <xsl:variable name="langs">
      <xsl:choose>
       <xsl:when test="$metadata/gn:info[position() = last()]/isTemplate = 's'">

        <xsl:for-each select="distinct-values($metadata//gmd:LocalisedCharacterString/@locale)">
          <xsl:variable name="locale" select="string(.)" />
          <xsl:variable name="langId" select="xslutil:threeCharLangCode(substring($locale,2,2))" />
          <lang><xsl:value-of select="concat('&quot;', $langId, '&quot;:&quot;#', ., '&quot;')"/></lang>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="mainLanguage">
          <xsl:call-template name="get-iso19139.sdn-cdi-language"/>
        </xsl:variable>
        <xsl:if test="$mainLanguage">
          <xsl:variable name="mainLanguageId"
                        select="$metadata/gmd:locale/gmd:PT_Locale[
                                gmd:languageCode/gmd:LanguageCode/@codeListValue = $mainLanguage]/@id"/>

          <lang><xsl:value-of select="concat('&quot;', $mainLanguage, '&quot;:&quot;#', $mainLanguageId, '&quot;')"/></lang>
        </xsl:if>

        <xsl:for-each select="$metadata/gmd:locale/gmd:PT_Locale[gmd:languageCode/gmd:LanguageCode/@codeListValue != $mainLanguage]">
          <lang><xsl:value-of select="concat('&quot;', gmd:languageCode/gmd:LanguageCode/@codeListValue, '&quot;:&quot;#', @id, '&quot;')"/></lang>
        </xsl:for-each>
      </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:text>{</xsl:text><xsl:value-of select="string-join($langs/lang, ',')"/><xsl:text>}</xsl:text>
  </xsl:template>

  <!-- Get the list of other languages -->
  <xsl:template name="get-iso19139.sdn-cdi-other-languages">
    <xsl:choose>
      <xsl:when test="$metadata/gn:info[position() = last()]/isTemplate = 's'">

        <xsl:for-each select="distinct-values($metadata//gmd:LocalisedCharacterString/@locale)">
        <xsl:variable name="locale" select="string(.)" />
        <xsl:variable name="langId" select="xslutil:threeCharLangCode(substring($locale,2,2))" />
          <lang id="{.}" code="{$langId}"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>

        <xsl:for-each select="$metadata/gmd:locale/gmd:PT_Locale">
          <lang id="{@id}" code="{gmd:languageCode/gmd:LanguageCode/@codeListValue}"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  

  <!-- Template used to return a gco:CharacterString element
        in default metadata language or in a specific locale
        if exist. 
        FIXME : gmd:PT_FreeText should not be in the match clause as gco:CharacterString 
        is mandatory and PT_FreeText optional. Added for testing GM03 import.
    -->
  <xsl:template mode="localised" match="*[gco:CharacterString or gmd:PT_FreeText]">
    <xsl:param name="langId"/>

    <xsl:choose>
      <xsl:when
        test="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId] and
        gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId] != ''">
        <xsl:value-of
          select="gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[@locale=$langId]"/>
      </xsl:when>
      <xsl:when test="not(gco:CharacterString)">
        <!-- If no CharacterString, try to use the first textGroup available -->
        <xsl:value-of
          select="gmd:PT_FreeText/gmd:textGroup[position()=1]/gmd:LocalisedCharacterString"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="gco:CharacterString"/>
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>
  
</xsl:stylesheet>
