#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";
($Planet, $Country, $Rate) = split(/&/, $ENV{QUERY_STRING});

if (undef $Rate) {$Rate = 0.3;}
$Path = "/home/admin/classic/se/Planets";

$TotalPath = "$Path/$Planet/users/$Country";
$MessageDir = "/home/admin/classic/se/Planets/$Planet/News";

open (IN, "$TotalPath/City.txt");
flock (IN, 1);
@Data = <IN>;
close (IN);

foreach $State (@Data) {
	($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools) = split(/\|/, $State);
	$Ag = int($Ag * $Rate);
	$Co = int($Co * $Rate);
	$In = int($In * $Rate);
	$Re = int($Re * $Rate);

	push (@NewData, qqÞ$Name|$Population|$Status|$BorderLevel|$NewMorale|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\nÞ);
}

open (OUT, ">$TotalPath/City.txt");
flock (OUT, 2);
print OUT @NewData;
close (OUT);

	($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
	if (length($Sec) == 1) {$Sec = "0$Sec"}
	if (length($Min) == 1) {$Min = "0$Min"}
	if (length($Hour) == 1) {$Hour = "0$Hour"}
	$Mon++;
	$Year += 1900;
	
	$NCountry = $Country;
	$NCountry =~ tr/_/ /;
	print "<BR>$TotalPath/events/$Year$Mon$Mday$Hour$Min$Sec.vnt<BR>";
	open (DATAOUT, ">$TotalPath/events/$Year$Mon$Mday$Hour$Min$Sec.vnt") or print "Cannot Write Local News";
	print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
	print DATAOUT "UWG Forces have attacked our nation, inflicting decimating approximately $Rate percent of our nations cities.  We have been informed by the UWG that further attacks against weaker nations will result in additional offensives.\n";
	close (DATAOUT);

	print "$MessageDir/$Year$Mon$Mday$Hour$Min$Sec";	
	open (DATAOUT, ">$MessageDir/$Year$Mon$Mday$Hour$Min$Sec") or print "Cannot Write News";
	print DATAOUT "UWG Forces Deployed Against $NCountry\n";
	print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
	print DATAOUT "UWG Forces, responding to the recent military activities of $NCountry, launched a vigerous assault, bypassing the national armed forces and striking deep into the heart of the nation.  According to eye-witnesses, the punitive strikes were carried out by what seemed to be units of a pre-war design.  The UWG later released a statement, saying that 'The wartime atrocities of $NCountry have lead us to this regretable action, and we trust that its leaders shall quickly undertake to reform, lest it be subject to more attacks.\n";
	close (DATAOUT);
	
	print "Attack Complete.";	

#sub chopper{
#	foreach $k(@_){
#		chomp($k);
#	}
#}
