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
    empty, process it separately in this template. this overrides the
    default identity transform.
  -->
  <xsl:template match="mods:name[@authority='orcid']/@valueURI">
    <xsl:if test="not(.='')">
      <xsl:attribute name="valueURI">
        <xsl:value-of select="concat('http://orcid.org/', .)"/>
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>