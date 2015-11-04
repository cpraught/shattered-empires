#!/usr/bin/perl
print "Content-type: text/html\n\n";

$tech = $ENV{QUERY_STRING};
$tech =~ tr/_/ /;

open(TECH,"home/shatteredempires/SE/techdes/$tech.des");
@file = <TECH>;
close(TECH);

print qq!
<HTML>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<BODY BGCOLOR="#000000" TEXT="#FFFFFF">
<TABLE BORDER="1" WIDTH="100%">
<TR>    
<TD BGCOLOR="#999999" width ="50%">
<CENTER>
<FONT FACE="Arial, Helvetica, sans-serif">$tech
</CENTER>
</td>
</TR>
<TR>
<TD BGCOLOR="#666666" width = "*"><FONT FACE="Arial, Helvetica, sans-serif">
@file
</td>
</tr>
</TABLE>
</BODY>
</HTML>
!;
