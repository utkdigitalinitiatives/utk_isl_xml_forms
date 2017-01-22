<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.og/2001/XMLSchema"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd"
                xmlns:xlink="http://www.w3.org/1999/xlink"
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

  <!-- *if* the valueURI is empty, copy the name element, but remove all attributes but @type='personal' -->
  <xsl:template match="mods:name[@authority='orcid'][@valueURI='']">
    <xsl:copy>
      <xsl:apply-templates select="@type"/>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!--
    *if* the @valueURI attached to mods:name[@authority='orcid'] is not
    empty AND does not start with 'http://orcid.org', process it separately
    in this template. this overrides the default identity transform.
  -->
  <xsl:template match="mods:name[@authority='orcid']/@valueURI[(not(.='')) and (not(starts-with(.,'http://orcid.org')))]">
    <xsl:attribute name="valueURI">
        <xsl:value-of select="concat('http://orcid.org/', .)"/>
    </xsl:attribute>
  </xsl:template>

  <!--
    *if* the valueURI attached to mods:name[@authority='orcid'] is not empty
    AND starts with 'http://orcid.org', use the default template rules to copy
    the valueURI attribute.
  -->
  <xsl:template match="mods:name[@authority='orcid']/@valueURI[(not(.='')) and (starts-with(.,'http://orcid.org'))]">
    <xsl:copy>
      <xsl:apply-templates/>
    </xsl:copy>
  </xsl:template>

  <!--
    copy the initial values in mods:originInfo. test for a mods:dateCreated element and,
    if it doesn't exist create mods:dateCreated.
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
    this template adds a mods:recordInfo element to the file if the element is not present
   -->
  <xsl:template match="mods:physicalDescription[@authority='local']">
    <xsl:copy>
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