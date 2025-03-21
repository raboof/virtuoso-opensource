<?xml version="1.0" encoding="utf-8"?>
<!--
 -  
 -  This file is part of the OpenLink Software Virtuoso Open-Source (VOS)
 -  project.
 -  
 -  Copyright (C) 1998-2021 OpenLink Software
 -  
 -  This project is free software; you can redistribute it and/or modify it
 -  under the terms of the GNU General Public License as published by the
 -  Free Software Foundation; only version 2 of the License, dated June 1991.
 -  
 -  This program is distributed in the hope that it will be useful, but
 -  WITHOUT ANY WARRANTY; without even the implied warranty of
 -  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 -  General Public License for more details.
 -  
 -  You should have received a copy of the GNU General Public License along
 -  with this program; if not, write to the Free Software Foundation, Inc.,
 -  51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
 -  
 -  
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
                xmlns="http://samples.openlinksw.com/bpel"
                xmlns:virt="http://samples.openlinksw.com/bpel">
  <xsl:output method="xml" indent="yes" />


  <xsl:template match="virt:requestwithrate">
    <creditResult>
      <header>
        <name> <xsl:value-of select="virt:request/virt:lname/text()"/>, <xsl:value-of select="virt:request/virt:fname/text()"/> </name>
      </header>
      <body><xsl:value-of select="virt:request/virt:ssn/text()"/></body>
      <footer>Rate is <xsl:value-of select="virt:rating"/> </footer>
    </creditResult>
  </xsl:template>
</xsl:stylesheet>
