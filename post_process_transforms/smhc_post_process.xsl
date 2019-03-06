<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:mods="http://www.loc.gov/mods/v3"
    xmlns="http://www.loc.gov/mods/v3"
    xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    exclude-result-prefixes="xs mods"
    version="1.0">
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <!-- identity transform -->
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>  
    
    <!-- Copy value of dateCreated to originInfo/datedCreated[@encoding="edtf"][@keyDate="yes"] -->
    <xsl:template match="mods:dateCreated[not(@encoding)]">
        <xsl:copy-of select="."/>
        <dateCreated encoding="edtf" keyDate="yes"><xsl:value-of select="."/></dateCreated>
    </xsl:template>
    
    <xsl:template match="mods:dateCreated[@encoding]"/>
    
</xsl:stylesheet>