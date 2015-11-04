#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$CityName,$TempMode)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authcode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";
$CityNames = $CityName;
$CityName =~ tr/_/ /;
$CityPath = $MasterPath . "/se/Planets/$Planet/users/$User";
open (IN, "$CityPath/City.txt") or print "Cannot open 1";
@Inf = <IN>;
close (IN);
&chopper (@Inf);

open (IN, "$CityPath/money.txt") or print "Cannot open 2";
$Money = <IN>;
chop ($Money);
close ($Money);


open (OUT, ">$CityPath/City.txt") or print "Cannot write 1";
foreach $Item (@Inf) {
	($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $Item);
	if ($Name eq $CityName) {
		if ($User eq "Zekif") {print "C $CityType L $LandSize<BR>";}
		if ($CityType eq "Settlement") {if ($LandSize >= 36) {$CitySizePass=1;}}
		if ($CityType eq "Village") {if ($LandSize >= 121) {$CitySizePass=1;}}
		if ($CityType eq "Town") {if ($LandSize >= 594) {$CitySizePass=2;}}
		if ($CityType eq "City") {if ($LandSize >= 2990) {$CitySizePass=3;}}
		if ($CityType eq "Metropolis") {if ($LandSize >= 8980) {$CitySizePass=5;}}
		if ($CityType eq "Megalopolis") {if ($LandSize >= 19940) {$CitySizePass=8;}}

		if ($User eq "Zekif") {print "CP $CitySizePass<BR>";}
		if ($CitySizePass > 0) {
			$UpCost = int($CitySizePass * $Worth);
			$UpCost2 = &Space($UpCost);
			if ($Money - $UpCost >= 0) {
				$Money -= $UpCost;
				$CityType2 = $CityType;
				if ($CityType eq "Megalopolis") {$CityType="Hub"}
				if ($CityType eq "Metropolis") {$CityType="Megalopolis"}
				if ($CityType eq "City") {$CityType="Metropolis"}
				if ($CityType eq "Town") {$CityType="City"}
				if ($CityType eq "Village") {$CityType="Town"}
				if ($CityType eq "Settlement") {$CityType="Village"}


				print OUT qqﬁ$Name|$Population|$Status|$BorderLevel|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\nﬁ;
				$UpGradeMsg = qq!The $CityType2 of $Name has been upgraded to a $CityType.  This cost of this upgrade was \$$UpCost2.!;
			} else {
				$UpGradeMsg = qq!The $CityType of $Name cannot be upgraded because we lack the required funds.  It will cost \$$UpCost2 to perform the upgrade.!;
				print OUT "$Item\n";
			}
		} else {
			$UpGradeMsg = qq!The $CityType of $Name does not need to be upgraded yet.!;
			print OUT "$Item\n";
		}
	} else {
		print OUT "$Item\n";
	}
}
close (OUT);

open (OUT, ">$CityPath/money.txt") or print "Cannot write 2";
print OUT "$Money\n";
close(OUT);

print qqﬁ
<body bgcolor=#000000 text=#ffffff>
<table border=1 cellspacing=0 width=100%><TR><TD bgcolor=$Header><font face=verdana color=$HeaderFont><B><center>$CityName Upgrade</TD></TR></table>
<font face=verdana size=-1>
<BR><BR><BR><BR><center>$UpGradeMsg</body>
ﬁ;

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

