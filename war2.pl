#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode)=split(/&/,$ENV{QUERY_STRING});
$PlanetDir = $MasterPath . "/se/Planets/$Planet";
$UserDir = "$PlanetDir/users/$User";

if (-e "$UserDir/Dead.txt") {
	print "Location: http://www.bluewand.com/cgi-bin/classic/Dead.pl?$User&$Planet&$AuthCode\n\n";
	die;
}
if (-e "$UserDir/dupe.txt") {
	print "<SCRIPT>alert(\"Your nation has been locked down for security reasons.  Please contact the Bluewand Entertainment team at shattered.empires\@canada.com for details.\");history.back();</SCRIPT>";
	die;
}
if (-e "$UserDir/notallowed.txt") {
	print "<SCRIPT>alert(\"Your nation has been taken off-line temporarily.  Please contact the GSD team for details.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}
print "Content-type: text/html\n\n";
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);

&parse_form;
$PlayerDir = $MasterPath . "/se/Planets/$Planet/users";
$TargetDir = $MasterPath . "/se/Planets/$Planet/users/$data{'target'}";
$SF = qq!<font face=verdana size=-1>!;

$Target = $data{'target'};
$Target =~ tr/_/ /;

if (-e "$TargetDir/alliance.txt") {
	open (IN, "$TargetDir/alliance.txt");
	$AllianceName = <IN>;
	close (IN);
	chop ($AllianceName);
	$AllianceName =~ tr/_/ /;
} else {
	$AllianceName = "None";
}

open (IN, "$TargetDir/country.txt");
flock (IN, 1);
@countrydata2 = <IN>;
close (IN);
&chopper (@countrydata2);
$DefTotalSize = @countrydata2[8];

open (IN, "$UserDir/country.txt") or print $!;
flock (IN, 1);
@countrydata = <IN>;
close (IN);
&chopper (@countrydata);
$AttTotalSize = @countrydata[8];


open (IN, "$TargetDir/userinfo.txt");
@Values = <IN>;
close (IN);
&chopper (@Values);

open (IN, "$TargetDir/City.txt");
@City = <IN>;
close (IN);
&chopper (@City);
$Count = scalar(@City);

open (IN, "$PlayerDir/Retal.txt");
flock (IN, 1);
@DataIn = <IN>;
close (IN);
&chopper (@DataIn);

foreach $Line (@DataIn) {
	($AgrCountry, $TurnsToAttack) = split (/,/, $Line);
	$AttackHash{$AgrCountry} = $TurnsToAttack;
}


open (IN, "$TargetDir/military.txt");
$Def = <IN>;
close (IN);
chop ($Def);

if ($Def == 2) {$Def = "Red"}
if ($Def == 1) {$Def = "Yellow"}
if ($Def == 0 or $Def eq "") {$Def = "Green"}

open (IN, "$TargetDir/continent.txt");
$Continent = <IN>;
close (IN);

if (@Values[5] eq "CA") {$GT = "Capitalist "}
if (@Values[5] eq "FA") {$GT = "Facist "}
if (@Values[5] eq "CO") {$GT = "Socialist "}
if (@Values[5] eq "ME") {$GT = "Mercantalist "}


if (@Values[4] eq "DE") {$GT .= "Democracy"}
if (@Values[4] eq "MO") {$GT .= "Monarchy"}
if (@Values[4] eq "DI") {$GT .= "Dictatorship"}
if (@Values[4] eq "TH") {$GT .= "Theocracy"}
if (@Values[4] eq "RE") {$GT .= "Republic"}




if ((($AttTotalSize * .75) > $DefTotalSize) || (($DefTotalSize * .75) > $AttTotalSize)) {
	$WarnMessage = qq!Attacking this nation <B>will</b> incur the wrath of the UWG.!;
}


print qqﬁ
<body bgcolor=000000 text=white>$SF
<SCRIPT>parent.frames[1].location.reload()</SCRIPT>
<table width=100% border=1 cellspacing=0><TR><TD bgcolor=333333>$SF<B><Center>Attack Selection</TD></TR></table>
<BR><Center><font color=red>$WarnMessage</font><BR><BR>Please Select A Target City<BR></center><BR>
<form method=POST action="http://www.bluewand.com/cgi-bin/classic/war3.pl?$User&$Planet&$AuthCode&$data{'target'}"><Center>
<table width=100% border=1 cellspacing=0 bgcolor=666666>
<TR><TD bgcolor="#333333" colspan=4>$SF<center>Target Information</TD></TR>
<TR><TD bgcolor="#333333" width=25%>$SF Target Name:</TD><TD bgcolor="#666666" width=25%>$SF$Target</TD><TD bgcolor="#333333" width=25%>$SF Alliance:</TD><TD width=25% bgcolor=#666666>$SF $AllianceName</TD></TR>
<TR><TD bgcolor="#333333">$SF Government:</TD><TD bgcolor="#666666">$SF$GT</TD><TD bgcolor="#333333">$SF Defense Condition:</TD><TD bgcolor="#666666">$SF$Def</TD></TR>
<TR><TD bgcolor="#333333">$SF Cities:</TD><TD bgcolor="#666666">$SF$Count</TD><TD bgcolor="#333333">$SF Continent:</TD><TD bgcolor="#666666">$SF$Continent</TD></TR>
</table>
<BR><BR>
</center>
<Table width=100% border=1 cellspacing=0>
<TR bgcolor="#333333"><TD>$SF City Name</TD><TD>$SF Continent</TD><TD>$SF Size</TD><TD>$SF Population</TD><TD>$SF Worth</TD><TD>$SF Target</TD></TR>
ﬁ;


foreach $Item (@City) {
	($Name,$Population,$Status,$Contint,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $Item);
	if ($TurnsLeft > $AttackLevel) {$AttackLevel = $TurnsLeft;}
}
if ($AttackLevel < 1) {$AttackLevel = 0;}
foreach $Item (@City) {
	($Name,$Population,$Status,$Contint,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split (/\|/, $Item);
	$Size = &Space($Re + $Ag + $Co + $In);
	$People = &Space($Population);
	$Worth = &Space($Worth);

	$Name2 = $Name;
	$Name2 =~ tr/ /_/;
	if ($TurnsLeft == $AttackLevel) {
		print qqﬁ<TR bgcolor="#666666"><TD>$SF$Name</TD><TD>$SF$Contint</TD><TD>$SF $Size</TD><TD>$SF$People</TD><TD>$SF \$$Worth</TD><TD>$SF Attack <input type=radio name="City" value="$Name2"></TD></TR>ﬁ;
	}
}
print qq!
</table><BR><BR>
$Levels
<center><input type=submit value="Select City" name=city></form>
!;


if (-e "$PlayerDir/alliance.txt") {
	open (IN, "$PlayerDir/alliance.txt");
	$AllianceName = <IN>;
	close (IN);
	chop ($AllianceName);

	print qqﬁ
</table><BR><BR>
<Table width=80% border=1 cellspacing=0>
<TR bgcolor="#999999"><TD>$SF Allied Army Name</TD><TD>$SF Personnel</TD><TD>$SF Cost</TD><TD>$SF Use</TD></TR>ﬁ;



	print qqﬁ
</table>
	ﬁ;
}


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

#sub chopper{
#	foreach $k(@_){
#		chop($k);
#	}
#}
#
#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}

