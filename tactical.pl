#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";


($User,$Planet,$Authcode)=split(/&/,$ENV{QUERY_STRING});
#$user_information = $MasterPath . "/User Information";
#dbmopen(%authcode, "$user_information/accesscode", 0777);
#if ($Authcode ne $authcode{$User}){
#	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
#	die;
#}
#dbmclose(%authcode);
#unless ($User =~ /Zeaniri/ || $User eq "Despiser" || $User eq "") {
#	print "<SCRIPT>alert(\"Not online right yet\");history.back();</SCRIPT>";
#	die;
#}	

if ($User eq "") {$Planet = "SystemOne-Earth";}

print qq!
<HTML>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<body bgcolor="#000000" text="#ffffff"><font face="verdana"><CENTER><B>Tactical Strike:</b></center><BR><BR>
!;



$Agressor = $User;
$Agressor =~ tr/_/ /;
$WorldPath  = $MasterPath . "/se/Planets/$Planet/";
$PlainPath =$MasterPath . "/se/Planets/$Planet/users/";
$EventPath = $MasterPath . "/se/Planets/$Planet/events/";
$UserPath = $MasterPath . "/se/Planets/$Planet/users/$User/";
$MilitaryPath = $MasterPath . "/se/Planets/$Planet/users/$User/military/";
$UnitPath = $MasterPath . "/unitsdir/";
$WeaponPath = $MasterPath . "/weapons/";

print qq!
<FORM method="POST"><CENTER>
<TABLE BORDER="1" WIDTH="60%" cellspacing=0 cellpadding=0>
<TR> 
<TD BGCOLOR="#333333" WIDTH="42%"><FONT FACE="Arial" size=-1><center>Target:</center></FONT></TD>
<TD BGCOLOR="#666666" WIDTH="58%"><FONT FACE="Arial" size=-1><CENTER><SELECT NAME="target">!;


opendir (DIR, "$PlainPath") or print $!;
@Userlist = readdir (DIR);
closedir (DIR);
@Userlist = sort(@Userlist);
$Counter = 0;

foreach $UserName (@Userlist) {
	if ($UserName ne '.' and $UserName ne '..' and $UserName ne 'globalland.txt') {
		open (DATAIN, "$PlainPath$UserName/turns.txt");
		$Value = <DATAIN>;
		$Value = <DATAIN>;
		chop ($Value);		
		if ($Value > 5) {
			unless (-e "$PlainPath$UserName/death.txt") {
				unless (-e "$PlainPath$UserName/notallowed.txt") {
					$Counter++;
					print qq!
<OPTION VALUE ='$UserName'>!;
					$UserName =~ tr/_/ /;
					print qq!$UserName!;
				}
			}
		}
	}
}
if ($Counter == 0) {
print qq!<OPTION VALUE ='None'>No countries available !;
}
print qq!
</SELECT></CENTER></FONT></TD>
</TR>
</table><BR>$FailMessage<BR>
$DispMess<BR>
<table align="right" bgcolor="#666666" width="100%" border="1" cellspacing=0 cellpadding=0>
<tr bgcolor="#333333"><td><font face="verdana" size=-1>Name:</td><td><font face="verdana" size=-1>Weapons Loadout:</td><td><font face="verdana" size=-1>Available:</td><td><font face="verdana" size=-1>Quantity:</td></tr>!;

foreach $Unit (keys(%Number)) {
	$Name = substr ($Unit, 0, length($Unit)-4);
	$names=$Name;
	$Name =~ tr/_/ /;
	open (DATAIN, "$UnitPath$Unit");
	@DataIn = <DATAIN>;
	close (DATAIN);
	&chopper (@DataIn);
	$CountUp++;
	print qq!<tr>
<td bgcolor="#666666"><font face="verdana" size="-1">$Name</font></td>
<td bgcolor="#666666"><font face="verdana" size="-1">$DataIn[9], $DataIn[11]</font></td>
<td bgcolor="#666666"><font face="verdana" size="-1">!;
print $Number{$Unit};
print qq!</td><td bgcolor="#666666"><font face="verdana" size="-1"><center><INPUT TYPE="text" size="6" name="$names"></td>
</tr>
	!;
}
if ($CountUp < 1) {
	print qq!<TR><TD BGCOLOR='#666666' COLSPAN='4'><font face="verdana" size=-1><CENTER>No available tactical weapons</TD></TR>!;
}
print qq!
</table><BR><BR><BR><BR><center><center>
<table width="40%" border="1" cellspacing=0>
<TR><td bgcolor="#666666"><font face="verdana" size=-1><center><Input type="submit" value="Launch"></td></tr></table>
</FORM></body>!;


#sub chopper {
#foreach $k (@_) {
#	chop($k);
#	}
#}
#
#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}


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
