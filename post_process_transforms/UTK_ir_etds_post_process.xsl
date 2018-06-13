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
  <!--
    if a thesis advisor or committee member is added via the form without a namePart[@type='given' AND 'family'] AND
    has a role/roleTerm='Thesis advisor' or 'Committee member'.
    MODS added via the form automatically gets an empty mods:displayForm.
  -->
  <xsl:template match="mods:name[mods:displayForm='']
                                [mods:namePart[@type='given']='' and mods:namePart[@type='family']='']
                                [mods:role/mods:roleTerm='Thesis advisor' or mods:role/mods:roleTerm='Committee member']"/>
  <!--
    if a thesis advisor or committee member is added but for some reason has a displayForm but not the following namePart siblings,
    delete the name node.
  -->
  <xsl:template match="mods:name[mods:displayForm='']
                               [not(mods:namePart[@type='given']) and not(mods:namePart[@type='family'])]
                               [mods:role/mods:roleTerm='Thesis advisor' or mods:role/mods:roleTerm='Committee member']"/>
  <!-- if there are any empty 'type' attributes (@type), ignore them -->
  <xsl:template match="@type[.='']"/>
  <!-- if no supplemental files are attached in the initial form -->
  <xsl:template match="mods:relatedItem[@type='constituent'][mods:titleInfo[mods:title='']][mods:abstract='']"/>
  <!-- if no namePart[@type='termsOfAddress'] is present, drop the empty element -->
  <xsl:template match="mods:name[@type='personal']/mods:namePart[@type='termsOfAddress'][.='']"/>



<xsl:template match="mods:name[@authority='orcid']">
    <xsl:variable name="vID" select="@valueURI"/>
    <xsl:variable name="vDigits" select="'0123456789'"/>

    <xsl:choose>
      <!-- ignore @valueURI when @valueURI is empty -->
      <xsl:when test="$vID = ''">
        <xsl:copy>
          <xsl:apply-templates select="@type"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:when>
      <!--
        when @valueURI does not start with http AND matches (\d){4}-(\d){4}-(\d){4}-(\d){4}
        create a new @valueURI and prepend 'http://test.net/' to the string
      -->
      <xsl:when test="not(starts-with($vID,'http://orcid.org'))
                      and string-length(translate(substring($vID, 1, 4), $vDigits, '')) = 0
                      and substring($vID, 5, 1) = '-'
                      and string-length(translate(substring($vID, 6, 4), $vDigits, '')) = 0
                      and substring($vID, 10, 1) = '-'
                      and string-length(translate(substring($vID, 11, 4), $vDigits, '')) = 0
                      and substring($vID, 15, 1) = '-'
                      and string-length(translate(substring($vID, 16, 4), $vDigits, '')) = 0">
        <xsl:copy>
          <xsl:attribute name="valueURI">
            <xsl:value-of select="concat('http://orcid.org/',$vID)"/>
          </xsl:attribute>
          <xsl:apply-templates select="@type"/>
          <xsl:apply-templates select="@authority"/>
          <xsl:apply-templates select="@authorityURI"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:when>
      <!-- when @valueURI starts with http..., we're going to be assumptive and take the value -->
      <xsl:when test="starts-with($vID,'http://orcid.org')">
        <xsl:copy>
          <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
      </xsl:when>
      <!-- otherwise we'll assume that @valueURI and @test are irrelevant and we'll ignore them -->
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates select="@type"/>
          <xsl:apply-templates/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
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
  <!--
    if the affiliation[1] is empty, copy the element and add the appropriate dept, *if*
    dept is not empty.
  -->
  <xsl:template match="mods:affiliation[1][.='']">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$vDegreeDisc=$vDisciplines//@discipline[../@dept!='']">
          <xsl:value-of select="$vDisciplines//@dept[../@discipline=$vDegreeDisc]"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!--
    if affiliation[2] is empty, and affiliation[1] is not empty and
    is *not* in the disciplines list then add the appropriate dept.
  -->
  <xsl:template match="mods:affiliation[2][.='']">
    <xsl:variable name="affiliation-1" select="preceding-sibling::mods:affiliation[1]"/>
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$affiliation-1[not(.='') and not(.=$vDisciplines//@discipline)]">
          <xsl:value-of select="$vDisciplines//@dept[not(.='')][../@discipline=$vDegreeDisc]"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:copy>
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

  <!-- if affiliation[5] is empty, copy the element and add the appropriate college -->
  <xsl:template match="mods:affiliation[5][.='']">
    <xsl:copy>
      <xsl:choose>
        <xsl:when test="$vDegreeDisc=$vDisciplines//@discipline[../@college!='Intercollegiate']">
          <xsl:value-of select="$vDisciplines//@college[../@discipline=$vDegreeDisc]"/>
        </xsl:when>
        <xsl:otherwise/>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!-- if affiliation[6] is empty, copy the element and add the value of etd:grantor -->
  <xsl:template match="mods:affiliation[6][.='']">
    <xsl:copy>
      <xsl:value-of select="/mods:mods/mods:extension/etd:degree/etd:grantor"/>
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