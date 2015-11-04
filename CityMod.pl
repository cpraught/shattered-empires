#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode,$CityName,$TempMode)=split(/&/,$ENV{QUERY_STRING});
$PlanetDir = $MasterPath . "/se/Planets/$Planet";
$UserDir = "$PlanetDir/users/$User";

if (-e "$UserDir/Dead.txt") {
	print "Location: http://www.bluewand.com/cgi-bin/classic/Dead.pl?$User&$Planet&$AuthCode\n\n";
	die;
}
if (-e "$UserDir/dupe.txt") {
	print "<SCRIPT>alert(\"Your nation has been locked down for security reasons.  Please contact the Bluewand team at shattered.empires\@canada.com for details.\");history.back();</SCRIPT>";
	die;
}

if (-e "$UserDir/notallowed.txt") {
	print "<SCRIPT>alert(\"Your nation has been taken off-line temporarily.  Please contact the Bluewand team for details.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}

print "Content-type: text/html\n\n";



$user_information = $MasterPath . "/User Information";

dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authcode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);

$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

$BaseHealth = 2000000;
$BaseLearn = 1000000;
$FortificationCost = 5000000;
$CityNames = $CityName;

$CityName =~ tr/_/ /;
$CityPath = $MasterPath . "/se/Planets/$Planet/users/$User";

open (IN, "$CityPath/research/TechData.tk");
flock (IN, 1);
@TechData = <IN>;
close (IN);

&chopper (@TechData);

#Index Technologies
foreach $Tech (@TechData) {
	(@TechInfo) = split(/\|/,$Tech);
#	if ($User eq "Admin_One") {print qq!@TechInfo[2] >= @TechInfo[3]) {$Storage{@TechInfo[1]} = @TechInfo[1]!}
	if (@TechInfo[2] >= @TechInfo[3]) {$Storage{@TechInfo[1]} = 1}
}
$Storage{""} = 1;

open (IN, "$CityPath/userinfo.txt") or print "Cannot open";
flock (IN, 1);
@Inf = <IN>;
close (IN);
&chopper (@Inf);
&Display2;
$SF = qq!<font face=verdana size=-1>!;

print qqﬁ
<BODY BGCOLOR="#000000" text="#FFFFFF">$SF
<form method=POST action="http://www.bluewand.com/cgi-bin/classic/CityMod.pl?$User&$Planet&$AuthCode&$CityNames&1">
<table width=100% border=1 cellspacing=0 bgcolor="$Header"><TD><Font face=verdana size=-1><B><Center>$CityName Control</table>ﬁ;

if ($TempMode == 1) {
	$LearnCost = 1000000;
	$HealthCost = 2000000;
	open (IN, "$CityPath/money.txt");
	$Money = <IN>;
	close (IN);
	chop($Money);

	open (IN, "$CityPath/City.txt");
	@Cities = <IN>;
	close (IN);
	&chopper (@Cities);
	open (OUT, ">$CityPath/City.txt") or print "Cannot Write<BR>";
	&parse_form;
	foreach $City (@Cities) {
		($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $City);
		unless ($Name eq $CityName) {
			print OUT "$City\n";
		}
		else {		
			$Agriculture = int(abs($data{'Agr'}));
			$Commercial = int(abs($data{'Com'}));
			$Industrial = int(abs($data{'Ind'}));
			$Residential = int(abs($data{'Res'}));
			if ($GovType == 2) {				
				$a = abs($Agriculture) + abs($Commercial) + abs($Industrial) + abs($Residential);
				if ($a > 100 or $a < 0) {
					print qqﬁ
$SF<BR><Center> You cannot allocate more than 100% to buildings.<BR></center>
					ﬁ;
					$Agriculture=0;
					$Commercial = 0;
					$Industrial=0;
					$Residential=0;
				}
			}
			$Acceptance = (int($Acceptance * 100)/ 100);

			if ($data{'health'} > 0) {
				if ($Money >= ($HealthCost * $data{'health'})) {
					$Hospitals += abs($data{'health'});
					$Money -= ($HealthCost * $data{'health'});
					$HealthMessage = qq!$data{'health'} hospitals have been constructed.<BR>!;
				} else {
					$HealthMessage = qq!You cannot construct more hospitals than you have funds for.<BR>!;
				}
			}
			if ($data{'health'} < 0) {
				if ($Hospitals - abs($data{'health'}) < 0) {
					$HealthMessage = qq!You cannot demolish more hospitals than $Name has constructed.<BR>!;
				} else {
					$Hospitals += $data{'health'};
					$HealthMessage = qq!$data{'health'} hospitals have been demolished.<BR>!;
				}
			}


			if ($data{'fort'} > 0) {
				if ($Money >= ($data{'fort'} * $FortificationCost)) {
					$Barracks += $data{'fort'};
					$Money -= ($data{'fort'} * $FortificationCost);
					$FortMessage = qq!$data{'fort'} fortifications have been constructed.<BR>!;
				} else {
					$FortMessage = qq!You cannot construct more fortifications than you have funds for.<BR>!;					
				}
			}
			if ($data{'fort'} < 0) {
				if ($Barracks - abs($data{'fort'}) < 0) {
					$FortMessage = qq!You cannot demolish more fortifications than $Name has constructed.<BR>!;
				} else {
					$Barracks += $data{'fort'};
					$FortMessage = qq!$data{'fort'} fortifications have been demolished.<BR>!;
				}
			}




			if ($data{'education'} > 0) {
				if ($Money >= ($data{'education'} * $LearnCost)) {
					$Schools += $data{'education'};
					$Money -= ($data{'education'} * $LearnCost);
					$LearnMessage = qq!$data{'education'} schools have been constructed.<BR>!;
				} else {
					$LearnMessage = qq!You cannot construct more schools than you have funds for.<BR>!;					
				}
			}
			if ($data{'education'} < 0) {
				if ($Schools - abs($data{'education'}) < 0) {
					$LearnMessage = qq!You cannot demolish more schools than $Name has constructed.<BR>!;
				} else {
					$Schools += $data{'education'};
					$LearnMessage = qq!$data{'education'} schools have been demolished.<BR>!;
				}
			}
			print OUT qqﬁ$Name|$Population|$Status|$BorderLevel|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\nﬁ;
		}
	}
	close (OUT);
	open (OUT, ">$CityPath/money.txt");
	print OUT "$Money\n";
	close (OUT);
}

open (IN, "$CityPath/City.txt");
@Cities = <IN>;
close (IN);
&chopper (@Cities);

foreach $City (@Cities) {
	($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $City);
	if ($Name eq $CityName) {
		if ($Obey == 0) {
			$Obey = 1;
			
			$HospitalCost = &Space($BaseHealth);
			$SchoolCost = &Space($BaseLearn);
			$FortificationsCost = &Space($FortificationCost);
			$Population = &Space($Population);

			$Acceptance = int($Acceptance * 100);
			$Modern = $Modern * 100;
			if ($Feature == 0) {$Features = "None"}
			if ($Feature == 1) {$Features = "Coastal City"}

			if ($CityType eq "Settlement") {if ($LandSize >= 36) {$CitySizePass=1;}}
			if ($CityType eq "Village") {if ($LandSize >= 121) {$CitySizePass=1;}}
			if ($CityType eq "Town") {if ($LandSize >= 594) {$CitySizePass=2;}}
			if ($CityType eq "City") {if ($LandSize >= 2990) {$CitySizePass=3;}}
			if ($CityType eq "Metropolis") {if ($LandSize >= 8980) {$CitySizePass=5;}}
			if ($CityType eq "Megalopolis") {if ($LandSize >= 19940) {$CitySizePass=8;}}

			$UpCost = &Space($CitySizePass * $Worth);
			$Worth = &Space($Worth);
if ($CitySizePass >= 1) {$PossUp = "$Name can be upgraded to the next city class.  It will cost \$$UpCost for this upgrade.<BR>"}
if ($CitySizePass >= 1) {$UpgradeLink = qq!<a href="http://www.bluewand.com/cgi-bin/classic/UpgradeCity.pl?$User&$Planet&$AuthCode&$CityNames&1" STYLE="text-decoration:none;color:000000">Click to Upgrade</a>!} else {$UpgradeLink = qq!Not Available!}

			$LandSize = &Space($LandSize);
			$FormerOwner =~ tr/_/ /;

open (DATAIN, "$CityPath/money.txt");
$money = <DATAIN>;
close (DATAIN);
chop ($money);

open (DATAIN, "$CityPath/turns.txt");
$turns = <DATAIN>;
close (DATAIN);
chop ($turns);

$money = &Space($money);







print qqﬁ<SCRIPT>

parent.frames[1].location.reload()

</SCRIPT><BR>

<TABLE BORDER="1" WIDTH="100%" BORDER=1 CELLSPACING=0>

  <TR>

    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Current Funds:</FONT></TD>

    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">\$$money</TD>

    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Turns Remaining:</FONT></TD>

    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$turns</TD>

  </TR>

</TABLE><center>

$HealthMessage

$LearnMessage

$FortMessage

$PossUp</center>

<BR><table border=1 cellspacing=0 width=80%>

<TR bgcolor="$Header"><TD colspan=4>$SF $CityName</TD></TR>

<TR bgcolor="$Content"><TD width=25% bgcolor="$Header">$SF City Size</TD><TD width=25%>$SF$LandSize</TD><TD width=25% bgcolor="$Header">$SF Value</TD><TD width=25%>$SF \$$Worth</TD></TR>

<TR bgcolor="$Content"><TD width=25% bgcolor="$Header">$SF Population</TD><TD width=25%>$SF$Population</TD><TD bgcolor="$Header">$SF Continent</TD><TD>$SF$BorderLevel</TD></TR>

<TR bgcolor="$Content"><TD width=25% bgcolor="$Header">$SF Morale</TD><TD width=25%>$SF$Acceptance%</TD><TD bgcolor="$Header">$SF Specialization</TD><TD>$SF $Features</TD></TR>

<TR bgcolor="$Content"><TD width=25% bgcolor="$Header">$SF Modernization</TD><TD width=25%>$SF$Modern%</TD><TD width=25% bgcolor="$Header">$SF Previous Nation</TD><TD width=25%>$SF $FormerOwner</TD></TR>

<TR bgcolor="$Content"><TD width=25% bgcolor="$Header">$SF Class</TD><TD width=25%>$SF$CityType</TD><TD width=25% bgcolor="$Header">$SF Upgrade</TD><TD width=25%>$SF $UpgradeLink</TD></TR>

</table>



<BR><table border=1 cellspacing=0 bgcolor="$Content" width=80%>



<TR bgcolor="$Header"><TD>$SF Building Type</TD><TD>$SF Existing</TD><TD>$SF Construction Cost</TD><TD>$SF Construct</TD></TR>ﬁ;



#if ($Storage{Basic_Schooling} == 1) {

	print qqﬁ<TR><TD>$SF Schools</TD><TD>$SF $Schools</TD><TD>$SF\$$SchoolCost<TD>$SF<input type=text name="education" size=9></TD></TR>ﬁ;

#}



#if ($Storage{Basic_Medicine} == 1) {

	print qq!<TR><TD>$SF Hospitals</TD><TD>$SF $Hospitals</TD><TD>$SF\$$HospitalCost</TD><TD>$SF<input type=text name="health" size=9></TD></TR>!;

#}



$Co = int($Co);
$Re = int($Re);
$Ag = int($Ag);
$In = int($In);


print qqﬁ

<TR><TD>$SF Barracks</TD><TD>$SF $Barracks</TD><TD>$SF\$$FortificationsCost</TD><TD>$SF<input type=text name="fort" size=9></TD></TR>

</table>

<BR>
Land
<table border=1 cellspacing=0 bgcolor="$Content" width=80%>
<TR bgcolor=$Header><TD>&nbsp;</TD><TD>$SF Agricultural</td><TD>$SF Commercial</td><TD>$SF Industrial</TD><TD>$SF Residential</TD></TR>
<TR><TD bgcolor="$Header">$SF Actual</TD><TD>$SF $Ag</td><TD>$SF $Co</td><TD>$SF $In</TD><TD>$SF $Re</TD></TR>ﬁ;

			$SF = qq!<font face=verdana size=-1>!;

			if ($GovType == 2) {print qqﬁ<TR><TD bgcolor="$Header">$SF</center>Ideal Percentages</TD><TD>$SF<input type=text value="$Agriculture" name=Agr size=9>%</td><TD>$SF<input type=text value="$Commercial" name=Com size=9>%</td><TD>$SF<input type=text value="$Industrial" name=Ind size=9>%</TD><TD>$SF<input type=text value="$Residential" name=Res size=9>%</TD></TR>ﬁ;}
			if ($GovType == 1) {print qqﬁ<TR><TD bgcolor="$Header">$SF</center>Ideal Ratio</TD><TD>$SF<input type=text value="$Agriculture" name=Agr size=9></td><TD>$SF<input type=text value="$Commercial" name=Com size=9></td><TD>$SF<input type=text value="$Industrial" name=Ind size=9></TD><TD>$SF<input type=text value="$Residential" name=Res size=9></TD></TR>ﬁ;}
			if ($GovType == 0) {print qqﬁ<TR><TD bgcolor="$Header">$SF</center>Goal</TD><TD>$SF<input type=text value="$Agriculture" name=Agr size=9></td><TD>$SF<input type=text value="$Commercial" name=Com size=9></td><TD>$SF<input type=text value="$Industrial" name=Ind size=9></TD><TD>$SF<input type=text value="$Residential" name=Res size=9></TD></TR>ﬁ;}
			print qqﬁ
</table><BR>
<font size=-2><Center><input type=submit value="Modify City Options" name=submit>
ﬁ;
		}
	}
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



sub Display2 {

if (@Inf[4] eq "DE" or @Inf[4] eq "RE") {$GovType = 2}



if (@Inf[4] eq "DI" or @Inf[4] eq "TH" or @Inf[4] eq "MO") {$GovType = 0}

}
