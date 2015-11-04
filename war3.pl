#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode,$Target)=split(/&/,$ENV{QUERY_STRING});
$PlanetDir = $MasterPath . "/se/Planets/$Planet";
$UserDir = "$PlanetDir/users/$User";

if (-e "$UserDir/Dead.txt") {
	print "Location: http://www.bluewand.com/cgi-bin/classic/Dead.pl?$User&$Planet&$AuthCode\n\n";
	die;
}
if (-e "$UserDir/dupe.txt") {
	print "<SCRIPT>alert(\"Your nation has been locked down for security reasons.  Please contact the GSD team at shattered.empires\@canada.com for details.\");history.back();</SCRIPT>";
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
$TargetDir = $MasterPath . "/se/Planets/$Planet/users/$Target";
$SF = qq!<font face=verdana size=-1>!;
$Targets = $Target;
$Target =~ tr/_/ /;


open (IN, "$PlayerDir/research/TechData.tk");
flock (IN, 1);
@Tech  = <IN>;
close (IN);
&chopper (@Tech);

foreach $Item (@Tech) {
	@TechData = split (/\|/, $Item);
	if (@TechData[2] >= @TechData[3]) {$Storage{@TechData[1]} = 1}
}


if (-e "$TargetDir/alliance.txt") {
	open (IN, "$TargetDir/alliance.txt");
	$AllianceName = <IN>;
	close (IN);
	chop ($AllianceName);
	$AllianceName =~ tr/_/ /;
} else {
	$AllianceName = "None";
}

open (IN, "$TargetDir/userinfo.txt") or print "Cannot open Info File<BR>";
@Values = <IN>;
close (IN);
&chopper (@Values);

open (IN, "$TargetDir/City.txt") or print "Cannot open City File<BR>";
@City = <IN>;
close (IN);
&chopper (@City);
$Count = scalar(@City);

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


$Target =~ tr/ /_/;

print qq!
<body bgcolor=000000 text=white>$SF
<SCRIPT>parent.frames[1].location.reload()</SCRIPT>
<table width=100% border=1 cellspacing=0><TR><TD bgcolor=333333>$SF<B><Center>Attack Selection</TD></TR></table>
<BR><Center>Please Select Attacking Armies</center><BR>!;

print qq!<form method=POST action="http://www.bluewand.com/cgi-bin/classic/ExtendedWar.pl?$User&$Planet&$AuthCode&$Targets&$data{'City'}"><Center>!;
#print qq!<form method=POST action="http://www.bluewand.com/cgi-bin/classic/NewWar.pl?$User&$Planet&$AuthCode&$Target&$data{'City'}"><center>!;

$Target =~ tr/_/ /;

$AttackModes = qq!<TD><center><font size=-1 face=arial>Standard <input type=radio name="mode" value="Standard" SELECTED></center></TD>!;
if ($Storage{"Siege Warfare"}) {$AttackModes .= qq!<TD><center><font size=-1 face=arial>Siege <input type=radio name="mode" value="Siege"></center></TD>!}


print qq!
<table width=60% border=1 cellspacing=0 bgcolor=666666>
<TR><TD bgcolor="#333333" colspan=4>$SF<center>Attack Mode</TD></TR>
<TR>$AttackModes</TR>
</table><BR>

<table width=100% border=1 cellspacing=0 bgcolor=666666>
<TR><TD bgcolor="#333333" colspan=4>$SF<center>Target Information</TD></TR>
<TR><TD bgcolor="#333333" width=25%>$SF Target Name:</TD><TD bgcolor="#666666" width=25%>$SF$Target</TD><TD bgcolor="#333333" width=25%>$SF Alliance:</TD><TD width=25% bgcolor=#666666>$SF $AllianceName</TD></TR>
<TR><TD bgcolor="#333333">$SF Government:</TD><TD bgcolor="#666666">$SF$GT</TD><TD bgcolor="#333333">$SF Defense Condition:</TD><TD bgcolor="#666666">$SF$Def</TD></TR>
<TR><TD bgcolor="#333333">$SF Cities:</TD><TD bgcolor="#666666">$SF$Count</TD><TD bgcolor="#333333">$SF Continent:</TD><TD bgcolor="#666666">$SF$Continent</TD></TR>
</table>
<BR><BR>
</center>
<Table width=100% border=1 cellspacing=0>
<TR bgcolor="#333333"><TD>$SF City Name</TD><TD>$SF Continent</TD><TD>$SF Size</TD><TD>$SF Population</TD><TD>$SF Worth</TD></TR>!;

foreach $Item (@City) {
	($Name,$Population,$Status,$Contint,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $Item);
	$Name2 = $Name;
	$Name2 =~ tr/ /_/;
	if ($data{'City'} eq $Name2) {
		$Size = &Space($Re + $Ag + $Co + $In);
		$People = &Space($Population);
		$Worth = &Space($Worth);
		$Contint2 = $Contint;
		print qqﬁ<TR bgcolor="#666666"><TD>$SF$Name</TD><TD>$SF$Contint</TD><TD>$SF $Size</TD><TD>$SF$People</TD><TD>$SF \$$Worth</TD></TR>ﬁ;
		$Name3 = $Name;
	}
}

$Name2 =~ tr/_/ /;

print qq!</table><BR><BR>
<table width=100% border=1 cellspacing=0 bgcolor="#666666">
<TR bgcolor="#333333"><TD>$SF Army Name</TD><TD>$SF Personnel</TD><TD>$SF Transport Capacity</TD><TD>$SF Cost</TD><TD>$SF Attack</TD></TR>
!;

opendir (DIR, "$PlayerDir/$User/military");
@Armies = readdir (DIR);
closedir (DIR);

foreach $Item (@Armies) {
	if (-d "$PlayerDir/$User/military/$Item" and $Item ne ".." and $Item ne '.' and $Item ne 'Pool') {
		open (IN, "$PlayerDir/$User/military/$Item/army.txt");
		@ArmyInfo = <IN>;
		close (IN);
		&chopper (@ArmyInfo);
		if ($Contint2 == @ArmyInfo[6]) {
			if (@ArmyInfo[3] <= @ArmyInfo[5] or @ArmyInfo[3] == 0)  {
				if(@ArmyInfo[1] == 1) {
					if (@ArmyInfo[0] == 3) {
						$ArmyCount ++;
						$Personnel = &Space(@ArmyInfo[5]);
						$Carry = &Space(@ArmyInfo[4]);
						$Cost = &Space(@ArmyInfo[2] * 2);
						$Item2 = $Item;
						$Item2 =~ tr/_/ /;
						if (@ArmyInfo[4] > 0) {$WeightWarning = qq!<font color=red>!} else {$WeightWarning = ""}
						print qqﬁ<TR><TD width=35%>$SF $Item2</TD><TD width=20%>$SF $Personnel</TD><TD width=20%>$SF $WeightWarning$Carry</font></TD><TD width=20%>$SF \$$Cost</TD><TD width=5%>$SF<Center><input type=checkbox name="$Item" value=Yes></TD></TR>ﬁ;
					} else {
						$ArmyCount ++;
						$Item2 = $Item;
						$Item2 =~ tr/_/ /;
print qqﬁ<TR><TD width=35%>$SF $Item2</TD><TD colspan=4><Center>$SF Army Is In Wrong Mode.</TD></TR>ﬁ;}
				} else {
					$ArmyCount ++;
					$Item2 = $Item;
					$Item2 =~ tr/_/ /;
print qqﬁ<TR><TD width=35%>$SF $Item2</TD><TD colspan=4><Center>$SF Army Cannot Be Used Again This Round.</TD></TR>ﬁ;}
			} else {
				$ArmyCount ++;
				$Item2 = $Item;
				$Item2 =~ tr/_/ /;

print qqﬁ<TR><TD width=35%>$SF $Item2</TD><TD colspan=4><Center>$SF Army Does Not Have Enough Active Soldiers.</TD></TR>ﬁ;}
		} else {
			$ArmyCount ++;
			$Item2 = $Item;
			$Item2 =~ tr/_/ /;
print qqﬁ<TR><TD width=35%>$SF $Item2</TD><TD colspan=4><Center>$SF Army Is On Wrong Continent (@ArmyInfo[6]).</TD></TR>ﬁ;}
	}
}

if ($ArmyCount < 1) {
print qq!<TR><TD colspan=5>$SF<Center>No available armies</center></TD></TR>!;
}

print qq!</table><BR><BR><center><input type="submit" name=submit value="Invade $Name3"></center>!;

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
