<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="html" encoding="utf-8"/>   
    
    <xsl:template match="/">
        <html>
            
            <head></head>
            
            <body>
                
                <xsl:for-each select="sparql/recherche">
                    
                <h1 align="center"><xsl:value-of select="@class"/></h1>
                
                    <xsl:for-each select="entite"> 
                        
                        <table border="1" align="center" width="400">
                            <th colspan="2" bgcolor="#D8D8D8"><xsl:value-of select="@id"/></th>
                                <xsl:for-each select="traduction">
                                    <tr>
                                        <td align="center" width="100"><xsl:value-of select="@lang"></xsl:value-of></td>
                                        <td align="center" width="300"><xsl:value-of select="."></xsl:value-of></td>
                                    </tr>
                                </xsl:for-each>
                            
                        </table>
                        <br/>
                        
                    </xsl:for-each>
                
                </xsl:for-each>
            </body>
            
        </html>
    </xsl:template>
    
    
</xsl:stylesheet>