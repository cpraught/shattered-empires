#!/usr/bin/perl
require 'quickies.pl'

&parse_form;

($User,$Planet,$Authcodes)=split(/&/,$ENV{QUERY_STRING});
$PlanetDir = $MasterPath . "/se/Planets/$Planet";
$UserDir = "$PlanetDir/users/$User";

if (-e "$UserDir/Dead.txt") {
	print "Location: http://www.bluewand.com/cgi-bin/classic/Dead.pl?$User&$Planet&$AuthCode\n\n";
	die;
}
if (-e "$UserDir/dupe.txt") {
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"Your nation has been locked down for security reasons.  Please contact the GSD team at shattered.empires\@canada.com for details.\");history.back();</SCRIPT>";
	die;
}
if (-e "$UserDir/notallowed.txt") {
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"Your nation has been taken off-line temporarily.  Please contact the GSD team for details.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}
print "Content-type: text/html\n\n";
$user_information = $MasterPath . "/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if($Authcodes ne $authcode{$User} || ($Authcodes eq "")){
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
$FinalPath=$MasterPath . "/unitsdir";

open (IN, "$TechPath/TechData.tk");
flock (IN, 1);
@Tech  = <IN>;
close (IN);
&chopper (@Tech);

foreach $Item (@Tech) {
	@TechData = split (/\|/, $Item);
	if (@TechData[2] >= @TechData[3]) {$Storage{@TechData[1]} = 1}
}


if ($data{'name'} eq "") {
	print "<SCRIPT>alert(\"You have neglected to enter a unit name.  All units must be named.\")\;history.back()</SCRIPT>";
	die;
}

open (IN, "$FinalPath/unitnames.txt");
@UnitNames = <IN>;
close (IN);
&chopper(@UnitNames);

foreach $Item (@UnitNames) {
	if ($Item eq $data{'name'}) {
		print "<SCRIPT>alert(\"You have attempted to use a unit name that has already been chosen.  Please select a new name.\")\;history.back()</SCRIPT>";
		die;
	}
}



$Tempname = $data{'name'};
if ($Tempname =~ m/[^A-Z a-z1-90]/) {
	print "<SCRIPT>alert(\"You have attempted to use characters in an unit name that are not valid.  Valid characters include all letters and space.\")\;history.back()</SCRIPT>";
	die;
}

if (substr($TempName,0,1) =~ m/[^A-Za-z]/) {
	print "<SCRIPT>alert(\"The first character of the unit name must be a letter.\")\;history.back()</SCRIPT>";
}

open (IN, "$TempPath/$data{'type'}.tpl");
@Profile = <IN>;
close (IN);
&chopper(@Profile);
&chopper(@Profile);

$WeaponOne = qq!<option value="None" selected>None</option>!;
$WeaponTwo = qq!<option value="None" selected>None</option>!;
$Armour = qq!<option value="None" selected>None</option>!;
$Stealth = qq!<option value="None" selected>None</option>!;

$SendName = $data{'name'};
$SendName =~ tr/ /_/;
$Temp = 1;
&Pick;
$Temp = 2;
&Pick;
$Temp = 3;
&Pick;
$Temp = 4;
&Pick;
&Mounts;

sub Pick {
	if ($Temp == 1 || $Temp == 2) {
		$Path = $WeaponPath;
	}
	if ($Temp == 3) {
		$Path = $ArmourPath;
	}
	if ($Temp == 4) {
		$Path = $StealthPath;
	}

	opendir (DIR, $Path);
	@FilesList = readdir(DIR);
	closedir (DIR);

	foreach $Item (@FilesList) {
		if (-f "$Path/$Item") {
			open (IN, "$Path/$Item") or print "Cannot Open File<BR>";
			@Info = <IN>;
			close (IN);
			&chopper (@Info);
			$Item =~ s/.wpn//;
			$Item =~ s/.arm//;
			$Item =~ s/.stl//;
			$Item2 = $Item;
			$Item =~ tr/_/ /;
			$Item2 =~ tr/ /_/;
			($BitA,$BitB) = split(/ /,@Info[3]); # Prof[9] = Type (Naval/Armour/etc), Prof[10] = Generation
			if ($BitA <= @Profile[10] and $BitB eq @Profile[9] and ($Storage{$Item2} == 1 or $Item eq "Spear")) {


				if ($Temp == 1 and @Info[5] == 1) {$WeaponOne .=   qq!<option value="$Item2.wpn">$Item</option>!}
				if ($Temp == 1 and @Info[5] == 3) {$WeaponOne .=   qq!<option value="$Item2.wpn">$Item</option>!}
				if ($Temp == 2 and @Info[5] == 2) {$WeaponTwo .=   qq!<option value="$Item2.wpn">$Item</option>!}
				if ($Temp == 2 and @Info[5] == 3) {$WeaponTwo .=   qq!<option value="$Item2.wpn">$Item</option>!}
				if ($Temp == 3 and @Info[5] eq "Ar") {$Armour .=  qq!<option value="$Item2.arm">$Item</option>!}
				if ($Temp == 4 and @Info[5] eq "Stl") {$Stealth .= qq!<option value="$Item2.stl">$Item</option>!}
			}
		}
	}
}


$SF = qq!<font face=verdana size=-1>!;

@Profile[2] = &Space(@Profile[2]);
print qqﬁ
<body bgcolor="#000000" text=white> 
<form method=POST action="http://www.bluewand.com/cgi-bin/classic/NewDevelop3.pl?$User&$Planet&$Authcodes&$data{'type'}&$SendName">
<Table border=1 cellspacing=0 bgcolor="$Content" width=100%>
<TR bgcolor="$Header"><TD colspan=4>$SF<B>$data{'name'}</TD></TR>
<TR><TD bgcolor="$Header">$SF Class</TD><TD>$SF @Profile[9]</TD><TD bgcolor="$Header">$SF Generation</TD><TD>$SF @Profile[10]</TD></TR>
<TR><TD bgcolor="$Header">$SF Height</TD><TD>$SF @Profile[1] m</TD><TD bgcolor="$Header">$SF Weight</TD><TD>$SF @Profile[2] kg</TD></TR>
<TR><TD bgcolor="$Header">$SF Width</TD><TD>$SF @Profile[3] m</TD><TD bgcolor="$Header">$SF Length</TD><TD>$SF @Profile[4] m</TD></TR>
<TR><TD bgcolor="$Header">$SF Weapon One</TD><TD>$SF<center><select name="Gun1">$WeaponOne</select></TD><TD bgcolor="$Header">$SF Weapon Two</TD><TD>$SF<center><select name="Gun2">$WeaponTwo</select></TD></TR>
<TR><TD bgcolor="$Header">$SF Mounts</TD><TD>$SF<center><select name="Mount1">$RoundsOne</select></TD><TD bgcolor="$Header">$SF Mounts</TD><TD>$SF<center><select name="Mount2">$RoundsTwo</select></TD></TR>
<TR><TD bgcolor="$Header">$SF Armour</TD><TD>$SF<center><select name="Armour">$Armour</select></TD><TD bgcolor="$Header">$SF Stealth</TD><TD>$SF<center><select name="Stealth">$Stealth</select></TD></TR>
</table><BR><center>$SF<input type=submit name=submit value="Proceed">
</body>
ﬁ;







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

sub Mounts {
	for ($i = 1;$i <= @Profile[6];$i++) {
		$RoundsOne = $RoundsOne . qq!<option value="$i">$i</option>!;
	}
	for ($i = 1;$i <= @Profile[7];$i++) {
		$RoundsTwo = $RoundsTwo . qq!<option value="$i">$i</option>!;
	}
}

