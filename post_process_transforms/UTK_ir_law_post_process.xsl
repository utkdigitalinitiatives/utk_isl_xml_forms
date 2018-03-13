<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:etd="http://www.ndltd.org/standards/metadata/etdms/1.0"
                exclude-result-prefixes="xs"
                version="1.0">

  <xsl:output encoding="UTF-8" indent="yes" method="xml"/>
  <xsl:strip-space elements="*"/>

  <xsl:param name="date-in" select="''"/>

  <!-- identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- if any of the following elements are empty, drop them from the transform. this list could grow. -->
  <!-- if there are any empty 'type' attributes (@type), ignore them -->
  <xsl:template match="@type[.='']"/>
  <!-- if no supplemental files are attached in the initial form -->
  <xsl:template match="mods:relatedItem[@type='constituent'][mods:titleInfo[mods:title='']][mods:abstract='']"/>

  <!--
    copy the initial values in mods:originInfo. test for a mods:dateCreated element and,
    if it doesn't exist create mods:dateCreated.
    existential test for mods:recordInfo[@displayLabel='submission']; if the following-sibling
    does not exist, create it.
  -->
  <xsl:template match="mods:originInfo">
    <xsl:copy>
      <xsl:if test="not(mods:dateCreated[@encoding='w3cdtf'])">
        <mods:dateCreated encoding="w3cdtf">
          <xsl:value-of select="$date-in"/>
        </mods:dateCreated>
      </xsl:if>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    <xsl:if test="not(following-sibling::mods:recordInfo[@displayLabel='Submission'])">
      <mods:recordInfo displayLabel="Submission">
        <mods:recordCreationDate encoding="w3cdtf">
          <xsl:value-of select="$date-in"/>
        </mods:recordCreationDate>
        <mods:recordChangeDate keyDate="yes" encoding="w3cdtf">
          <xsl:value-of select="$date-in"/>
        </mods:recordChangeDate>
      </mods:recordInfo>
    </xsl:if>
  </xsl:template>

  <!--
    *if* there is a mods:originInfo/mods:dateCreated, update the value.
  -->
  <xsl:template match="mods:originInfo/mods:dateCreated[@encoding='w3cdtf']">
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:value-of select="$date-in"/>
    </xsl:copy>
  </xsl:template>

  <!--
    this template updates the mods:recordInfo element with a new mods:recordDateChange for each edit of the MODS datastream
  -->
  <xsl:template match="mods:recordInfo[@displayLabel='Submission']/mods:recordChangeDate[@keyDate='yes'][@encoding='w3cdtf'][position() = last()]">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    <mods:recordChangeDate keyDate="yes" encoding="w3cdtf">
      <xsl:value-of select="$date-in"/>
    </mods:recordChangeDate>
  </xsl:template>
</xsl:stylesheet>