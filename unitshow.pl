#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

&parse_form;

$UnitPath =$MasterPath . "/unitsdir/";

chdir ("$UnitPath");

#opendir(DIR, '.');
#print readdir(DIR);

$Name = $ENV{QUERY_STRING};
$Name =~ tr/_/ /;
open (DATAIN,"$Name");
@data=<DATAIN>;
close (DATAIN);
$counter=0;
foreach $k (@funds) {	
	chop ($k);
	chop ($k);
	@data[$counter] = $k;
	$counter++;
}
$Name = substr ($ENV{QUERY_STRING}, 0,length($ENV{QUERY_STRING})-4);
$armour = int(@data[7]*100);
$stealth = int(@data[14]*100);

$cost   = &Space(@data[2]);
$maint  = &Space(@data[3]);
$trance  = &Space(@data[19]);
$height = &Space(@data[15]);
$width  = &Space(@data[17]);
$length = &Space(@data[18]);
$weight = &Space(@data[16]);
$Name =~ tr/_/ /;
@data[23]=~ tr/_/ /;

$SF = qq!<font face=verdana size=-1>!;
print qq!
<HTML>

<BODY BGCOLOR="#000000" TEXT="#FFFFFF">
<table width=100% border=1 cellspacing=0><TR><TD bgcolor="#333333"><center><B>$SF Unit Information: $Name</TD></TR></table><BR><BR>
    <TABLE BORDER="1" WIDTH="100%" cellspacing=0>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Unit Name:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>$Name</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Crew:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>@data[1]</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Unit Type:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>@data[0]</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Health:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>@data[5]</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Initial Cost:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>\$$cost</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Maintainance Cost:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>\$$maint</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Stealth</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>$stealth%</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Armour:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>@data[6]</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF&nbsp;&nbsp;- Protection:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>$armour%</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Weapon One:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>@data[10]</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF&nbsp;&nbsp;- Mounts:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>@data[11]</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Weapon Two:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>@data[12]</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF&nbsp;&nbsp;- Mounts:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>@data[13]</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Transport Capacity:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>$trance</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Dimensions - Height:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>$height m</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Dimensions - Width:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>$width m</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Dimensions - Length:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>$length m</TD>
      </TR>
      <TR> 
        <TD WIDTH="25%" BGCOLOR="#333333">$SF Dimensions - Weight:</TD>
        <TD WIDTH="75%" BGCOLOR="#666666">$SF<Center>$weight kg</TD>
      </TR>
    </TABLE>
</center>
</font>
</BODY>
</HTML>
!;


sub parse_form {

   # Get the input
   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

   # Split the name-value pairs
   @pairs = split(/&/, $buffer);

   foreach $pair (@pairs) {
      ($name, $value) = split(/=/, $pair);

      # Un-Webify plus signs and %-encoding
      $value =~ tr/+/ /;
      $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
      $value =~ s/<!--(.|\n)*-->//g;
      $value =~ s/<([^>]|\n)*>//g;
         
      

      $data{$name} = $value;
      }
}
#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}
