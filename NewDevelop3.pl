#!/usr/bin/perl
require 'quickies.pl'

&parse_form;
($User,$Planet,$Authcodes,$Unit,$Name)=split(/&/,$ENV{QUERY_STRING});
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
if($Authcodes ne $authcode{$User} || $Authcodes eq ""){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

$TechPath = $MasterPath . "/se/Planets/$Planet/users/$User/research";
$WeaponPath = $MasterPath . "/weapons";
$NormalPath =$MasterPath . "/se/Planets/$Planet/users/$User";
$ArmourPath=$MasterPath . "/armour";
$StealthPath=$MasterPath . "/stealth";
$TempPath= $MasterPath . "/template";
$UnitPath = $MasterPath . "/unitsdir";

if ($Name eq "") {
	print "<SCRIPT>alert(\"You have neglected to enter a unit name.  All units must be named.\")\;history.back()</SCRIPT>";
	die;
}

open (IN, "$UnitPath/unitnames.txt");
@UnitNames = <IN>;
close (IN);
&chopper(@UnitNames);

foreach $Item (@UnitNames) {
	if ($Item eq $Name) {
		print "<SCRIPT>alert(\"You have attempted to use a unit name that has already been chosen.  Please select a new name.\")\;history.back()</SCRIPT>";
		die;
	}
}

if ($Name =~ m/[^A-Z a-z_1-90]/) {
	print "<SCRIPT>alert(\"You have attempted to use characters in an unit name that are not valid.  Valid characters include all letters and space.\")\;history.back()</SCRIPT>";
	die;
}


open (IN, "$TechPath/TechData.tk");
flock (IN, 1);
@Tech  = <IN>;
close (IN);
&chopper (@Tech);

foreach $Item (@Tech) {
	@TechData = split (/\|/, $Item);
	if (@TechData[2] >= @TechData[3]) {$Storage{@TechData[1]} = 1}
}


if ($Unit eq "1GAr") {$Check = "1st_Generation_Armour"}
if ($Unit eq "1GVe") {$Check = "1st_Generation_Vessel"}
if ($Unit eq "1GAi") {$Check = "1st_Generation_Aircraft"}

if ($Unit eq "2GIn") {$Check = "2nd_Generation_Infantry"}
if ($Unit eq "2GAr") {$Check = "2nd_Generation_Armour"}
if ($Unit eq "2GVe") {$Check = "2nd_Generation_Vessel"}
if ($Unit eq "2GAi") {$Check = "2nd_Generation_Aircraft"}


unless ($Storage{$Check} == 1 or $Unit eq "1GIn") {print "<SCRIPT>alert(\"You have specified a unit type which you have not yet researched.\");history.back(2);</SCRIPT>";die;}
$Check =~ tr/_/ /;

open (IN, "$TempPath/$Unit.tpl");
@Profile = <IN>;
close (IN);

&chopper (@Profile);
&chopper (@Profile);

$PoliteName = $Name;
$PoliteName =~ tr/_/ /;
$Pts = @Profile[12];

$data{'Gun1'} =~ s/.wpn//;
$data{'Gun2'} =~ s/.wpn//;
$data{'Armour'} =~ s/.arm//;
$data{'Stealth'} =~ s/.stl//;

unless ($Storage{$data{'Gun1'}} == 1 or $data{'Gun1'} eq "Spear" or $data{'Gun1'} eq "None") {print "<SCRIPT>alert(\"You have specified a weapon which you have not yet researched.  Please reselect weapon one.\");history.back();</SCRIPT>";die;}
unless ($Storage{$data{'Gun2'}} == 1 or $data{'Gun2'} eq "Spear" or $data{'Gun2'} eq "None") {print "<SCRIPT>alert(\"You have specified a weapon which you have not yet researched.  Please reselect weapon two.\");history.back();</SCRIPT>";die;}
unless ($Storage{$data{'Armour'}} == 1 or $data{'Armour'} eq "None") {print "<SCRIPT>alert(\"You have specified an armour which you have not yet researched.  Please reselect armour.\");history.back();</SCRIPT>";die;}
unless ($Storage{$data{'Stealth'}} == 1 or $data{'Stealth'} eq "None") {print "<SCRIPT>alert(\"You have specified a stealth enhancement which you have not yet researched.  Please reselect stealth.\");history.back();</SCRIPT>";die;}

if ($data{'Mount1'} > @Profile[6]) {$data{'Mount1'} = 1}
if ($data{'Mount2'} > @Profile[7]) {$data{'Mount2'} = 1}
if ($data{'Gun1'} ne "None") {
	foreach $Item (@Tech) {
		@TechData = split (/\|/, $Item);
		if ($data{'Gun1'} eq @Tech[1]) {$Pts += int (@Tech[3] * 0.1)}
	}
	$data{'Gun1'} =~ tr/_/ /;
	open (IN, "$WeaponPath/$data{'Gun1'}.wpn") or print qq!Cannot open Gun File ($TechPath/$data{'Gun1'}.cpl)<BR>!;;
	@GunOne = <IN>;
	close (IN);
	&chopper (@GunOne);
	&chopper (@GunOne);
} else {
	$data{'Mount1'} = 0;
}

if ($data{'Gun2'} ne "None") {
	foreach $Item (@Tech) {
		@TechData = split (/\|/, $Item);
		if ($data{'Gun2'} eq @Tech[1]) {$Pts += int (@Tech[3] * 0.1)}
	}

	$data{'Gun2'} =~ tr/_/ /;
	open (IN, "$WeaponPath/$data{'Gun2'}.wpn") or print qq!Cannot open Gun File ($TechPath/$data{'Gun2'}.cpl)<BR>!;;
	@GunTwo = <IN>;
	close (IN);
	&chopper (@GunTwo);
	&chopper (@GunTwo);
} else {
	$data{'Mount2'} = 0;
}

if ($data{'Shield'} ne "None" and $data{'Shield'} ne "") {
	foreach $Item (@Tech) {
		@TechData = split (/\|/, $Item);
		if ($data{'Shield'} eq @Tech[1]) {$Pts += int (@Tech[3] * 0.1)}
	}
} else {
	$data{'Shield'} = "None";
	$ShieldRating = 0;
}
if ($data{'Armour'} ne "None") {
	foreach $Item (@Tech) {
		@TechData = split (/\|/, $Item);
		if ($data{'Armour'} eq @Tech[1]) {$Pts += int (@Tech[3] * 0.1)}
	}
	open (IN, "$ArmourPath/$data{'Armour'}.arm");
	@Armour = <IN>;
	close (IN);
	&chopper (@Armour);
} else {
	$Protection = 0;
}

$Cost = @Profile[8] + (@GunOne[4] * $data{'Mount1'}) + (@GunTwo[4] * $data{'Mount2'}) + @Armour[4] + @Stealth[4];
$Maint = int($Cost/25);
$SF = qq!<font face=verdana size=-1>!;



#New Tech Format - (Player) - Type|Name|Points|PointsRequired|Type1|Type2|Type3|Type4|Tech1|Tech2|Tech3|Tech4

#Unit Tech MilResearch(1)|Name|Points|PointsRequiredType|Type1|Type2|Type3|Type4|Tech1|Tech2|Tech3|Tech4|Crew|Cost|Maintenance|Health|Armour|Armour Rating|Shield|Shield Rating|Primary Weapon|Mounts|Secondary Weapon|Mounts|Stealth|Heigh|Weight|Width|Length|Transport Capacity|Generation

$PoliteName =~ tr/ /_/;

open (OUT, ">>$TechPath/TechData.tk");
flock (OUT, 2);
print OUT qq!1|$PoliteName|0|$Pts|0|0|0|0|0|0|0|0|@Profile[9]|@Profile[0]|$Cost|$Maint|$Pts|@Profile[11]|$data{'Armour'}|$Protection|$data{'Shield'}|$ShieldRating|$data{'Gun1'}|$data{'Mount1'}|$data{'Gun2'}|$data{'Mount2'}|$data{'Stealth'}|@Profile[1]|@Profile[2]|@Profile[3]|@Profile[4]|@Profile[5]|@Profile[10]\n!;
close (OUT);

$PoliteName =~ tr/_/ /;
open (OUT, ">>$UnitPath/unitnames.txt");
print OUT "$PoliteName\n";
close (OUT);

$PoliteNames = $PoliteName;
$PoliteName =~ tr/ /_/;

$Cost = &Space($Cost);
$Maint = &Space($Maint);
print qq!
<body bgcolor="#000000" text=white><BR><BR><BR><center>$SF
Specifications for the $PoliteNames have been completed.<BR>
Cost estimates are \$$Cost initially and \$$Maint monthly in maintenance.<BR><BR>
<table border=1 cellspacing=0 width=40%><tr bgcolor="$Content"><TD><Center>$SF<a href="UnitDelete.pl?$User&$Planet&$Authcodes&$PoliteName.unt&$PoliteName">Click here to cancel research.</a></TD></TR></table>



!;



#sub chopper {
#foreach $k (@_) {
#	chop($k);
#	}
#}
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
