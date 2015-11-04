#!/usr/bin/perl
require 'quickies.pl'

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
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";
$UserPath = $MasterPath . "/se/Planets/$Planet/users/$User";
$SEPath = "http://www.bluewand.com/classic/images/Ingame";
&parse_form;

open (IN, "$UserPath/userinfo.txt");
@Nation = <IN>;
close (IN);
&chopper (@Nation);
if (@Nation[4] eq "DE" or @Nation[4] eq "RE") {$Symbol = "%"}

if ($Mode == 1) {
	open (IN, "$UserPath/City.txt");
	@Cities = <IN>;
	close (IN);
	&chopper (@Cities);
	foreach $Item (@Cities) {
		($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $Item);

		$Names = $Name;
		$Name =~ tr/ /_/;
		if ((@Nation[4] eq "DE") or (@Nation[4] eq "RE")) {
			$Value = (abs($data{"Ag$Name"}) + abs($data{"Co$Name"}) + abs($data{"In$Name"}) + abs($data{"Re$Name"}))
		} else {$Value = 0}
		if (($Value <= 100) and ($Value >= 0)) {
			push (@NewCity, qq!$Names|$Population|$Status|$BorderLevel|$Acceptance|$Feature|$Hospitals|$Barracks|$data{"Ag$Name"}|$Ag|$data{"Co$Name"}|$Co|$data{"In$Name"}|$In|$data{"Re$Name"}|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft!)
		} else {
			push (@NewCity, "$Names|$Population|$Status|$BorderLevel|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft")
		}
	}

	open (OUT, ">$UserPath/City.txt");
	foreach $WriteLine (@NewCity) {
		print OUT "$WriteLine\n";
	}
	close (OUT);
}	

if ($Mode == 2) {
	open (IN, "$UserPath/Colony.txt");
	@Colony = <IN>;
	close (IN);
	&chopper (@Colony);

	if (@Nation[4] eq "RE" or @Nation[4] eq "DE") {
		$Value = abs($data{'AgBuild'}) + abs($data{'CoBuild'}) + abs($data{'ReBuild'}) + abs($data{'InBuild'});
		if ($Value <= 100 and $Value >= 0) {
			@Colony[0] = int(abs($data{'AgBuild'}));
			@Colony[1] = int(abs($data{'CoBuild'}));
			@Colony[2] = int(abs($data{'InBuild'}));
			@Colony[3] = int(abs($data{'ReBuild'}));
		}
	} else {
		@Colony[0] = int(abs($data{'AgBuild'}));
		@Colony[1] = int(abs($data{'CoBuild'}));
		@Colony[2] = int(abs($data{'InBuild'}));
		@Colony[3] = int(abs($data{'ReBuild'}));
	}
	$Value2 = int(abs($data{'AgInit'})) + int(abs($data{'CoInit'})) + int(abs($data{'ReInit'})) + int(abs($data{'InInit'}));
	if ($Value2 <= 10 and $Value2 >= 0) {
		@Colony[4] = int(abs($data{'AgInit'}));
		@Colony[5] = int(abs($data{'CoInit'}));
		@Colony[6] = int(abs($data{'InInit'}));
		@Colony[7] = int(abs($data{'ReInit'}));
	}

	@Colony[8] = $data{'ColonistStart'};
	open (OUT, ">$UserPath/Colony.txt");
	foreach $WriteLine (@Colony) {
		print OUT "$WriteLine\n";
	}
	chmod (0777, "$UserPath/Colony.txt");
	close (OUT);

	if ($data{'name'} ne "" && !(-e "$UserPath/ColonyBuilt.txt")) {
		&CheckCount;

		open (IN, $MasterPath . "/se/Planets/$Planet/CityList.txt") or print $!;
		flock (IN, 1);
		@CityNames = <IN>;
		&chopper (@CityNames);
		close (IN);
		$ClearToBuild = 1;

		foreach $Item (@CityNames) {
			if ($ClearToBuild != 2 and $Item ne $data{'name'}) {$ClearToBuild = 1} else {$ClearToBuild = 2}
		}


		if (-f "$UserPath/Colony.txt") {
			if ($ClearToBuild == 1) {
				open (IN, "$UserPath/money.txt");
				$Money = <IN>;
				chop($Money);

				open (IN, "$UserPath/Colony.txt");
				@Colony = <IN>;
				close (IN);
				&chopper(@Colony);
				@Colony[8] =~ tr/_/ /;

				open (IN, "$UserPath/City.txt");
				@Cities = <IN>;
				close (IN);
				&chopper(@Cities);

				if (scalar(@Cities) >= $Cities2) {
					$BuyMsg = "<center>At our current level of technological advancement, our nation cannot construct more colonies</center><BR>."
				} else {

					$PopAllow = "No";
					foreach $Item (@Cities) {
						($Name,$Pop,@Junk)=split(/\|/,$Item);
						if ($Name eq @Colony[8]) {
							if ($Pop - 500 < 0) {
								$PopAllow = "No";
							} else {
								$PopAllow = "Yes";

								if ($Name eq $data{'name'}) {
									$BuyMsg = 1;
									$BuyMsg = "<center>You cannot have two cities with the same name.</center><BR>";
								}
							}
						}
					}	
					if ($Money - 50000000 < 0) {
					$BuyMsg = "<center>Constructing a new colony costs \$50 000 000.  You do not possess enough funds.</center><BR>";
					$Buy = 1;
					}
					if ($Colony[4] + $Colony[5] + $Colony[6] + $Colony[7] < 1) {
						$BuyMsg = "<center>You must specifiy at least one initial building for your colony.</center><BR>";
						$Buy = 1;
					}
					if ($PopAllow eq "No") {
						$BuyMsg = "<center>Constructing a new colony requires 500 colonists.  @Colony[8] does not have the necessary people.</center><BR>";
						$Buy = 1;
					}
			
					if ($Buy != 1) {

						if ($data{'name'} =~ m/[^A-Z a-z_1-90]/) {
							$data{'name'} =~ s/[^A-Z a-z_1-90]//g;
							$BuyMsg = qq!<center>Special characters have been removed from your colonies name</center><BR>!;
						}
						$Money -= 50000000;
						open (OUT, ">$UserPath/money.txt");
						print OUT "$Money\n";
						close (OUT);
						$BuyMsg .= "<center>$data{'name'} has been constructed.  \$50 000 000 has been deducted from the national reserves<BR></center>";
					
						open (IN, "$UserPath/City.txt");
						@Cities2 = <IN>;
						close (IN);
						&chopper(@Cities2);

						open (OUT, ">>/home/bluewand/data/classic/se/Planets/$Planet/CityList.txt");
						print OUT "$data{'name'}\n";
						close (OUT);
				
						open (OUT, ">$UserPath/City.txt");
						foreach $Items (@Cities2) {
							($Names,$Pops,$Junks,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft)=split(/\|/,$Items);
							if ($Names eq @Colony[8] and $Pops - 500 > 0) {
								$NPops = $Pops - 500;
								print OUT qq!$Names|$NPops|$Junks|$BorderLevel|$NewMorale|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\n!;
							} else {print OUT "$Items\n";}
						}
						$Worth = (@Colony[4] * 12000) + (@Colony[5] * 91000) + (@Colony[6] * 132500) + (@Colony[7] * 5000);

						#Determine Which Level To Build City- 
						$CityLevel = (scalar(@Cities) - 1 )/5;
						$CityLevel = int ($CityLevel + 1);

						print OUT qqﬁ$data{'name'}|500|1|$data{'cont'}|$Acceptance|$data{'feature'}|0|0|@Colony[0]|@Colony[4]|@Colony[1]|@Colony[5]|@Colony[2]|@Colony[6]|@Colony[3]|@Colony[7]|10|None|$Planet|$Worth|1.00|Settlement|0|1|$CityLevel\nﬁ;
						close (OUT);

						open (OUT, ">$UserPath/ColonyBuilt.txt");
						close (OUT);
					}
				}
			} else {	
				print "<SCRIPT>alert(\"The a city with the name $data{'name'} already exists.  Please select another name.\");history.back();</SCRIPT>";
				die;
			}
		} else {
			print "<SCRIPT>alert(\"Colony settings must be choosen before any colonies are constructed.\");history.back();</SCRIPT>";
			die;
		}
	} elsif (-e "$UserPath/ColonyBuilt.txt") {
		print "<SCRIPT>alert(\"You can only build one colony per turn.\");history.back();</SCRIPT>";
		die;
	}
}

open (IN, "$UserPath/City.txt");
@Villas = <IN>;
close (IN);
&chopper (@Villas);

open (IN, "$UserPath/continent.txt");
$Continent = <IN>;
close (IN);

open (IN, "$UserPath/Colony.txt");
@Colony = <IN>;
close (IN);
&chopper (@Colony);


open (DATAIN, "$UserPath/money.txt");
$money = <DATAIN>;
close (DATAIN);
chop ($money);

open (DATAIN, "$UserPath/turns.txt");
$turns = <DATAIN>;
close (DATAIN);
chop ($turns);

$money = &Space($money);

$StyleFont = qq!<font face=verdana size=-1>!;
print qqﬁ
<BODY BGCOLOR="#000000" text="#FFFFFF">$StyleFont
<table width=100% border=1 cellspacing=0 bgcolor="$Header"><TD><Font face=verdana size=-1 color=$HeaderFont><B><Center>City Management</table><BR>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<TABLE BORDER="1" WIDTH="100%" BORDER=1 CELLSPACING=0>
  <TR>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Current Funds:</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">\$$money</TD>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Turns Remaining:</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$turns</TD>
  </TR>
</TABLE>

$BuyMsg<BR>
<form method=POST action="http://www.bluewand.com/cgi-bin/classic/City.pl?$User&$Planet&$AuthCode&1">
<table width=100% border=1 cellspacing=0 bgcolor="$Content">
<TR bgcolor="$Header"><TD>$StyleFont City Name</td><TD>$StyleFont Population</TD><td><font face=verdana size=-1>Agricultural</td><td><font face=arial size=-1>Commercial</td><td><font face=arial size=-1>Industrial</td><td><font face=arial size=-1>Residential</td><td><font face=arial size=-1>Modernization</td></TR>ﬁ;

$StyleFonts = qq!<font face=verdana size=-1><center>!;
foreach $City (@Villas) {
	$CityCount++;
	($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $City);
	push (@CitNames, $Name);
	$Name2 = $Name;
	$Name2 =~ tr/ /_/;
	$Population = &Space($Population);
	$Size = &Space($Size);

	$NameLink = qqﬁ<a href="http://www.bluewand.com/cgi-bin/classic/CityMod.pl?$User&$Planet&$AuthCode&$Name2"target ="Frame5" ONMOUSEOVER = "parent.window.status='City Modifications';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:000000">$Name</A>ﬁ;
	$Co = int($Co);
	$Ag = int($Ag);
	$In = int($In);
	$Re = int($Re);

	$Modern2 = $Modern * 100;
print qqﬁ<TR><TD>$StyleFont$NameLink</TD><TD>$StyleFonts$Population</TD><TD>$StyleFont<input type=text name="Ag$Name2" size=4 value="$Agriculture">$Symbol $Ag</TD><TD>$StyleFont<input type=text name="Co$Name2" value="$Commercial" size=4>$Symbol $Co</TD><TD>$StyleFont<input type=text name="In$Name2" value="$Industrial" size=4>$Symbol $In</TD><TD>$StyleFont<input type=text name="Re$Name2" size=4 value="$Residential">$Symbol $Re</TD><TD>$StyleFonts$Modern2%</TD></TR>\nﬁ;
}

if ($CityCount < 1) {
	print qq!<TR><TD colspan=8>$StyleFont<center>No cities exist</TD></TR>!;
}

print qqﬁ
</table><center><font size=-2 face=verdana><BR><input type=submit name=submit value="Modify Cities"></center></form><form method=POST action="http://www.bluewand.com/cgi-bin/classic/City.pl?$User&$Planet&$AuthCode&2">
$StyleFont Establish Colony
<table width=50% border=1 cellspacing=0 bgcolor="$Content">
<TR bgcolor="$Header"><TD>$StyleFont Name</TD><TD>$StyleFont Continent</TD><TD>$StyleFont Coastal</TD></TR>
<TR><TD>$StyleFont <input type=text size=15 name=name></TD><TD>$StyleFont<center><Select name=cont>ﬁ;

if (-e "$UserPath/research/Colony Ship.cpl") {
	print qq!
	<option value=1>1</option>
	<option value=2>2</option>
	<option value=3>3</option>
	<option value=4>4</option>
	!;

} else {print qq!<option value=$Continent>$Continent</option>!}

print qqﬁ</select></TD><TD>$StyleFont<center><select name=feature><option value="Port">Yes</option><option value="None" SELECTED>No</option></select></TD></TR>
</table><BR><table border=1 cellspacing=0>
<TR><TD bgcolor="$Header">$StyleFont City of Colonist Origin:</TD><TD bgcolor=$Content>$StyleFont<select name=ColonistStart>ﬁ;


foreach $Item (@CitNames) {
	$Item2 = $Item;
	$Item2 =~ tr/ /_/;
	print qq!<option value="$Item2">$Item</option>!;
}


print qqﬁ
</select></TD></TR></table>

<BR>$StyleFont 
<Table border=1 cellspacing=0 bgcolor="$Content" width=60%>
<TR bgcolor="$Header"><TD>$StyleFont Building Type</TD><TD>$StyleFont Build Rate</TD><TD>$StyleFont Initial Buildings (max 10)</TD></TR>
<TR><TD>$StyleFont Agricultural</TD><TD>$StyleFonts<input type=text name="AgBuild" size=4 value="@Colony[0]">$Symbol</TD><TD>$StyleFonts<input type=text name="AgInit" size=4 value="@Colony[4]"></TD></TR>
<TR><TD>$StyleFont Commercial</TD><TD>$StyleFonts<input type=text name="CoBuild" size=4 value="@Colony[1]">$Symbol</TD><TD>$StyleFonts<input type=text name="CoInit" size=4 value="@Colony[5]"></TD></TR>
<TR><TD>$StyleFont Industrial</TD><TD>$StyleFonts<input type=text name="InBuild" size=4 value="@Colony[2]">$Symbol</TD><TD>$StyleFonts<input type=text name="InInit" size=4 value="@Colony[6]"></TD></TR>
<TR><TD>$StyleFont Residential</TD><TD>$StyleFonts<input type=text name="ReBuild" size=4 value="@Colony[3]">$Symbol</TD><TD>$StyleFonts<input type=text name="ReInit" size=4 value="@Colony[7]"></TD></TR>
</table>
<BR><Center><font size=-2><input type=submit name=submit value="Modify Colonization Settings"></form>
ﬁ;

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

sub CheckCount {
	$Cities2 = 30;
	if (-e "$UserPath/research/Basic Road.cpl") {$Cities2+=3;}
	if (-e "$UserPath/research/Brick Road.cpl") {$Cities2+=3;}
	if (-e "$UserPath/research/Cabling.cpl") {$Cities2+=1;}

}

#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}
