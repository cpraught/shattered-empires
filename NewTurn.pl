#!/usr/bin/perl
require 'quickies.pl'


#		Turn Processor
#		May 2nd, 2002
#		Chris Praught
#		Copyright 1998-2002 Bluewand Entertainment
#

#		Steps
#
#
#
#		CityFile Format
#
#	1:	Name		2:	Population		3:	Status
#	4:	Border Level	5:	Morale			6:	Special Structure (Airport / Docks / Trainyard / University / Cultural Centre)
#	7:	Hospitals	8:	Barracks		9:	Schools
#	10:	Park		11:	PowerPlant		12:	Networth
#	13:	Modernization	14:	Occupier		15:	Percent Captured
#	16:	Planet		17:	Continent		18:	City Size
#
#
#

# Initialize Script, Check authorization
&Initialization;

# Load country data
&LoadData;

#
&stepOne-CityCalc;

sub stepOne-CityCalc
{
	foreach $Item (@CityData) {
		@ThisCity = split (/,/, $Item);

		
		&findLiteracy;
		&findFood;
		&findHealth;

		&findIncome;



	}
}


sub findLiteracy
{
#			Determine Literacy


}

sub LoadData
{
	unless (-e "$UserDir/Gov.txt") {
		print "Content-type: text/html\n\n";
		print qq!<SCRIPT>alert("You have not yet set your government funding levels.  You must do this before you are able to process a turn.");history.back();</SCRIPT>!;
		die;
	}

	open (IN, "$UserDir/Gov.txt");
	flock (IN, 1);
	@GovData = <IN>;
	close (IN);
	&chopper (@GovData);



	&checkTurns;

	open (IN, "$UserDir/country.txt");
	flock (IN, 1);
	@CountryData = <IN>;
	close (IN);
	&chopper (@CountryData);

#	0	#Population
#	1	#Soldiers
#	2	#Food
#	3	#Morale
#	4	#Average Literacy
#	5	#Economy
#	6	#Economic Strength
#	7	#UWG
#	8	#Networth
#	9	#Open - Blank - Unused
#	10	#Networth Addition (Units on Market)

	open (IN, "$UserDir/City.txt");
	flock (IN, 1);
	@CityData = <IN>;
	close (IN);

	unless (scalar(@CityData) == 0 && @CityData[0] == "") {
		open (OUT, ">$UserPath/City.backup");
		flock (OUT, 2);
		print OUT @CityData;
		close (OUT);
		chmod (0777, "$UserPath/City.backup");
	}

	&chopper (@CityData);

	open (IN, "$UserPath/money.txt");
	flock (IN, 1);
	$Money = <IN>;
	close (IN);

	chop($Money);
}



sub parse_form
{

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

#sub chopper
#{
#	foreach $k(@_){
#		chop($k);
#	}
#}
#
#sub Space
#{
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}

sub checkTurns
{
	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	@TimeUntil = split(/\./,@TurnData[2]);
	$Days = $yday - @TimeUntil[0];
	$Hours = $hour - @TimeUntil[1];
	$TotalTurns += ($Days * 24) + $Hours;

	@TurnData[0] += $TotalTurns;
	if (@TurnData[0] > 60) {@TurnData[0] = 60}
	if ($Planet =~ /SystemFour/) {@TurnData[0]++;}
	@TurnData[2] = "$yday.$hour";
	if (@TurnData[0] < 0) {print "Content-type: text/html\n\n";print qq@<body bgcolor=black text=white><center><BR><BR><BR><BR><BR><BR><center><B><I><font color=white face=arial>Due To a Glitch While Hourly Turns Were Activated, Your Account Was Issued Surplus Turns.<BR>The Extra Turns You Have Played Have Been Subtracted From Your Total.  Turns Will Balance Out Over Time.</B></I></center>@;die}



	unless ($WriteAllow == 2)
	{
		if (@TurnData[0] == 0) {
			print "Content-type: text/html\n\n";
			print qq!<SCRIPT>alert("You are out of turns.  Turns are issued at hourly.");history.back();</SCRIPT>!;
			die;
		}

		@TurnData[0]--;
		@TurnData[1]++;

		open (OUT, ">$UserDir/turns.txt");
		flock (OUT, 2);
		print OUT "@TurnData[0]\n";
		print OUT "@TurnData[1]\n";
		print OUT "@TurnData[2]\n";
		close (OUT);
	}
}


sub Initialization
{
	($User,$Planet,$AuthCode,$Mode)=split(/&/,$ENV{QUERY_STRING});
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
	dbmopen(%authcode, "$user_information/accesscode", 0777);
	if(($AuthCode ne $authcode{$User}) || ($AuthCode eq "")){
		print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
		die;
	}
	dbmclose(%authcode);
}
