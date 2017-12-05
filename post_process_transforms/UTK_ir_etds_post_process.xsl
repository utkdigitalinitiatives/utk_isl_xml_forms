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
  <xsl:variable name="lowercase" select="'abcdefghijklmnopqurstuv'"/>
  <xsl:variable name="vDisciplines" select="document('trace-disciplines-list-comp.xml')"/>
  <xsl:variable name="vDegreeDisc" select="/mods:mods/mods:extension/etd:degree/etd:discipline"/>

  <!-- identity transform -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- if any of the following elements are empty, drop them from the transform. this list could grow. -->
  <!-- if an extra thesis advisor or committee member is added to the form -->
  <xsl:template match="mods:name[@type='personal'][mods:displayForm='']"/>
  <!-- if no supplemental files are attached in the initial form -->
  <xsl:template match="mods:relatedItem[@type='constituent'][mods:titleInfo[mods:title='']][mods:abstract='']"/>
  <!-- if no namePart[@type='termsOfAddress'] is present, drop the empty element -->
  <xsl:template match="mods:name[@type='personal']/mods:namePart[@type='termsOfAddress'][.='']"/>

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
    processing affiliation elements. there will only ever be six:
    affiliation[1] = department
    affiliation[2] = department
    affiliation[3] = center
    affiliation[4] = center
    affiliation[5] = college
    affiliation[6] = university
  -->
  <xsl:template match="mods:affiliation[1][.='']">
    <xsl:copy>
      <xsl:value-of select="$vDisciplines//entry[@discipline=$vDegreeDisc]/@dept"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:affiliation[2][.='']">
    <xsl:variable name="affiliation-1" select="preceding-sibling::mods:affiliation[1]"/>
    <xsl:if test="$affiliation-1[not(.='') and not(.=$vDisciplines//@discipline)]">
      <xsl:copy>
        <xsl:value-of select="$vDisciplines//entry[@discipline=$vDegreeDisc]/@dept"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <xsl:template match="mods:affiliation[3][.='']">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:affiliation[4][.='']">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:affiliation[5][.='']">
    <xsl:copy>
      <xsl:value-of select="$vDisciplines//entry[@discipline=$vDegreeDisc]/@college"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="mods:affiliation[6][.='']">
    <xsl:copy>
      <xsl:value-of select="'University of Tennessee'"/>
    </xsl:copy>
  </xsl:template>

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
    based on the value of mods:extension/etd:degree/etd:level, serialize the correct
    URI for mods:genre[@authority='coar'].
  -->
  <xsl:template match="mods:genre[@authority='lcgft']">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
    <xsl:if test="(/mods:mods/mods:extension/etd:degree/etd:level[starts-with(., 'Doctoral')])">
      <mods:genre authority="coar" valueURI="http://purl.org/coar/resource_type/c_db06">doctoral thesis</mods:genre>
    </xsl:if>
    <xsl:if test="(/mods:mods/mods:extension/etd:degree/etd:level[starts-with(., 'Masters')])">
      <mods:genre authority="coar" valueURI="http://purl.org/coar/resource_type/c_bdcc">masters thesis</mods:genre>
    </xsl:if>
  </xsl:template>

  <!--
    *if* there is a pre-existing mods:genre[@authority='coar'] ignore it.
  -->
  <xsl:template match="mods:genre[@authority='coar']"/>

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