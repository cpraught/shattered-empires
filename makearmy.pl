#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";


&parse_form;
srand(time);

($User,$Planet,$Authcode,$Run)=split(/&/,$ENV{QUERY_STRING});
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";
$user_information = $MasterPath . "/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($Authcode ne $authcode{$User}) || ($Authcode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);


$UserPath = $MasterPath . "/se/Planets/$Planet/users/$User";
$MilPath =  $MasterPath . "/se/Planets/$Planet/users/$User/military/";
$UnitPath = $MasterPath . "/unitsdir/";
$SF = qq!<font face=verdana size=-1>!;

$BasicNumber = 3;

opendir (DIR, "$MilPath");
@List = readdir (DIR);
closedir (DIR);

open (DATAIN, "$UserPath/continent.txt");
$Continent = <DATAIN>;
close (DATAIN);

open (DATAIN, "$UserPath/turns.txt");
$turns = <DATAIN>;
$turns = <DATAIN>;
close (DATAIN);
chop ($turns);

open (IN, "$UserPath/research/TechData.tk");
flock (IN, 1);
@Tech  = <IN>;
close (IN);
&chopper (@Tech);

foreach $Item (@Tech) {
	@TechData = split (/\|/, $Item);
	if (@TechData[2] >= @TechData[3]) {$Storage{@TechData[1]} = 1}
}


if ($Storage{Command_Structure}) {$TechNumber += 2}

$TempSoldiers = 0;
foreach $Item (@List) {
	if (-d "$MilPath$Item" and $Item ne '.' and $Item ne '..') {
		if ($data{"Delete$Item"} eq "Delete" and $Item ne "Pool") {
			

			open (IN, "$MilPath/$Item/army.txt");
			flock (IN, 1);
			my @ArmyDat = <IN>;
			&chopper (@ArmyDat);
			close (IN);

			$TempSoldiers += @ArmyDat[5];
			if ((@ArmyDat[1] > 0) && ($Continent == @ArmyDat[6])) {
	
				opendir (DIR, "$MilPath/$Item");
				@ArmyDir = readdir (DIR);
				closedir (DIR);
				foreach $DeleteFile (@ArmyDir) {
					unlink("$MilPath/$Item/$DeleteFile");
				}
				rmdir ("$MilPath/$Item");
			}
		} else {
			push (@ArmyList, $Item);
		}
	}
	if (-f "$MilPath$Item") {
		$Items = substr ($Item,0,length($Item)-4);
		push (@UnitList, $Items);
	}
}

open (DATAIN, "$UserPath/country.txt");
@Nation = <DATAIN>;
close (DATAIN);
&chopper (@Nation);
@Nation[1] += $TempSoldiers;
open (OUT, ">$UserPath/country.txt") or print $!;
flock (OUT, 2);
foreach $WriteLine (@Nation) {
	print OUT "$WriteLine\n";
}
close (OUT);
$TempSoldiers = 0;

sort (@ArmyList);
sort (@UnitList);

foreach $Round (@UnitList) {
	open (IN, "$MilPath$Round.num");
	$Round =~ tr/ /_/;
	$UnitNum{$Round} = <IN>;

	chop($UnitNum{$Round});
	close (IN);
}

foreach $Army (@ArmyList) {
	unless ($Army eq "Pool" || $Army eq '.' || $Army eq '..') {
		open (IN, "$MilPath$Army/army.txt");
		flock (IN, 1);
		my @ArmyDat = <IN>;
		close (IN);
		&chopper (@ArmyDat);

		if (@ArmyDat[6] != $Continent) {
			opendir (DIR, "$MilPath$Army");
			my @Units = readdir (DIR);
			closedir (DIR);

			foreach $Item (@Units) {
				if ($Item ne "army.txt" && $Item ne "." && $Item ne "..") {
					open (IN, "$MilPath$Army/$Item") or print "$! $Item<BR>";
					flock (IN, 1);
					my $NumberUnit = <IN>;
					close (IN);
					&chopper ($NumberUnit);

					$Item = substr ($Item,0,length($Item)-4);

					$Item =~ tr/ /_/;
					$UnitNum{$Item} -= $NumberUnit;
				}
			}
		}
	}
}
if ($Run == 1) {
	foreach $Unit (@UnitList) {
		$Units = $Unit;
		$Units =~ tr/ /_/;
		$Unit2 = $Unit;
		$Unit2 =~ tr/_/ /;

		foreach $Army (@ArmyList) {
			open (IN, "$MilPath$Army/army.txt");
			flock (IN, 1);
			my @ArmyDat = <IN>;
			close (IN);
			&chopper (@ArmyDat);

			unless ($Army eq "Pool" || @ArmyDat[6] != $Continent) {
				$Array = "$Army$Units";
				if ($UnitNum{$Units} >= abs($data{$Array})) {		
					open (IN, "$MilPath$Army/army.txt");
					flock (IN, 1);
					$Blah = <IN>;
					$Ready = <IN>;
					chop ($Ready);
					close (IN);
					if ($Ready == 1) {
						$Value = abs($data{$Array});
						$Unit2 =~ tr/_/ /;
						open (OUT, ">$MilPath$Army/$Unit2.unt");
						flock (OUT, 2);
						print OUT qq!$Value\n!;
						close (OUT);
						chmod (0777, "$MilPath$Army/$Unit2.unt");
					} else {
						open (IN, "$MilPath$Army/$Unit2.unt");
						flock (IN, 1);
						$data{$Array} = <IN>;
						close (IN);
						chop ($data{$Array});
					}
					$UnitNum{$Units} -= $data{$Array};
				} else {
					$Spec = &Space($Value);
					$Armys = $Army;
					$Armys =~ tr/_/ /;
					$WarnMsg = $WarnMsg."<font face=arial size=-1>You do not have enough $Unit2 available to allocate $Spec to the $Armys army.<BR>";
					open (OUT, ">$MilPath$Army/$Unit2.unt");
					flock (OUT, 2);
					print OUT qq!0\n!;
					close (OUT);
					chmod (0777, "$MilPath$Army/$Unit2.unt");
				}
			}
		}
		$Army = "Pool";
		$Unit2 =~ tr/_/ /;
		open (OUT, ">$MilPath$Army/$Unit2.unt");
		print OUT "$UnitNum{$Units}\n";
		close (OUT);
	}

	unless ($Spec eq "") {$Bump = "<BR>"}

	if ($data{'Army'} ne "" and scalar(@ArmyList) < ($BasicNumber + $TechNumber)) {
		unless ($data{'Army'} =~ m/[^A-Z a-z0-9]/) {
			$data{'Army'} =~ tr/ /_/;
			mkdir ("$MilPath$data{'Army'}", 0777) or print $!;
			open (DATAOUT, ">$MilPath$data{'Army'}/army.txt");
			print DATAOUT "3\n";			#Mode
			print DATAOUT "1\n";			#Ready = 1  NotReady = 0
			print DATAOUT "0\n";			#
			print DATAOUT "0\n";			#
			print DATAOUT "0\n";			#
			print DATAOUT "0\n";			#
			print DATAOUT "$Continent\n";		#Continent
			print DATAOUT "0\n";			#
			print DATAOUT "0\n";			#Occupying
			close (DATAOUT);
			chmod (0777, "$MilPath$data{'Army'}/army.txt");

			push (@ArmyList, $data{'Army'});
		} else {$ArmyError = qq!<center>$SF You have attempted to use invalid characters in naming your army.  Letters, numbers and space are considered valid.<BR><BR>!}
	} else {
		if ($data{'Army'} eq "") {} else {
			$TotalNumber = $BasicNumber + $TechNumber;
			$ArmyError = qq!<center>$SF At your present level of technology, you cannot have more than $TotalNumber armies.<BR><BR>!
		}
	}

	foreach $ArmyRun (@ArmyList) {
		$RequiredCrew = 0;
		$RequiredCost = 0;
		$RequiredTransport = 0;
		$Floaters = 0;
		foreach $UnitModel (@UnitList) {
			$UnitModel =~ tr/_/ /;
			if (-e "$MilPath$ArmyRun/$UnitModel.unt" and $UnitModel ne "army.txt") {
				if ($UnitModel eq ".unt") {unlink ("$MilPath$ArmyRun/$UnitModel");NEXT}

				open (DATAIN, "$UnitPath$UnitModel.unt") or print "Cannot Open $UnitModel Type File<BR>";
				@UnitInfo = <DATAIN>;
				close (DATAIN);
				&chopper (@UnitInfo);

		
				open (DATAIN, "$MilPath$ArmyRun/$UnitModel.unt") or print "Cannot Open $UnitModel Data File<BR>";
				$UnitNum = <DATAIN>;
				close (DATAIN);
				chop ($UnitNum);

				$RequiredCrew += (@UnitInfo[1] * $UnitNum);
				$RequiredCost += (@UnitInfo[3] * $UnitNum);
				$Size = int((@UnitInfo[15] * @UnitInfo[17] * @UnitInfo[18] * @UnitInfo[16])/34.5);
				$RequiredTransport += ($Size * $UnitNum);
				if (@UnitInfo[1] ne "" and @UnitInfo[1] ne "") {
					$Floaters = 1;	
				}
			}
		}

		open (DATAIN, "$MilPath$ArmyRun/army.txt");
		@ArmyData = <DATAIN>;
		close (DATAIN);
		&chopper (@ArmyData);

		open (DATAOUT, ">$MilPath$ArmyRun/army.txt") or print "Cannot Write<BR>";
		print DATAOUT "@ArmyData[0]\n"; 	#Mode	1 - Assist 2 - Defense 3 - Ready 4 - Retaliation 5 - Transport 6 - Exploration
		print DATAOUT "@ArmyData[1]\n"; 	#Ready/Used 0 - Used 1 - Ready
		$RequiredCost +=  (@ArmyData[5] * 1350);
		print DATAOUT "$RequiredCost\n"; 	#Cost
		print DATAOUT "$RequiredCrew\n"; 	#Soldiers
		print DATAOUT "$RequiredTransport\n"; 	#Transport
		print DATAOUT "@ArmyData[5]\n"; 	#Total Soldiers
		print DATAOUT "@ArmyData[6]\n"; 	#Continent
		print DATAOUT "$Floaters\n"; 		#Submerged
		print DATAOUT "@ArmyData[8]\n"; 	#Occupying
		close (DATAOUT);
	}
}
@ArmyList = sort (@ArmyList);
@UnitList = sort (@UnitList);


foreach $Round (@UnitList) {
	$Round =~ tr/_/ /;
	open (IN, "$MilPath$Round.num");
	$Round =~ tr/ /_/;
	$UnitNum{$Round} = <IN>;
	chop($UnitNum{$Round});
	close (IN);
}
if ($turns < 48) {$AttackLine = "Not Available";} else {$AttackLine = qq!<A HREF = "war.pl?$User&$Planet&$Authcode" STYLE="text-decoration:none;color:black" target="Frame5">Mobilize Armies</A>!;}

print qq!
<BODY BGCOLOR="#000000" TEXT="#FFFFFF">
<SCRIPT>parent.frames[1].location.reload()</SCRIPT>
<table width=100% border=1 cellspacing=0><TR><TD bgcolor=$Header><CENTER><B>$SF Form Armies</B></TD></TR></Table><BR><center>
<Table width="100%"><TR><TD width="33%">
<Table width="100%" BORDER=1 CELLSPACING=0>
<TR BGCOLOR="$Header"><TD><FONT FACE="Arial" size="-1"><CENTER>Conventional War:</td></tr>
<TR BGCOLOR="$Content"><TD><FONT FACE="Arial" size="-1"><CENTER>$AttackLine</td></tr>
</table>

</TD><TD width="34%">
<Table width="100%" BORDER=1 CELLSPACING=0>
<TR BGCOLOR="$Header"><TD><FONT FACE="Arial" size="-1"><CENTER>Tactical Weapons:</td></tr>
<TR BGCOLOR="$Content"><TD><FONT FACE="Arial" size="-1"><CENTER>LINK</td></tr>
</table>

</TD><TD width="33%">
<Table width="100%" BORDER=1 CELLSPACING=0>
<TR BGCOLOR="$Header"><TD><FONT FACE="Arial" size="-1"><CENTER>Form Armies:</td></tr>
<TR BGCOLOR="$Content"><TD><FONT FACE="Arial" size="-1"><CENTER><A HREF = "makearmy.pl?$User&$Planet&$Authcode" STYLE="text-decoration:none;color:black" target="Frame5">Form Armies</A></td></tr>
</table>
</Td></TR>
</table><BR>
<FORM method="POST" action="http://www.bluewand.com/cgi-bin/classic/makearmy.pl?$User&$Planet&$Authcode&1">
$WarnMsg$Bump$ArmyError
<table width="50%" border=1 cellspacing=0>
<TR><TD BGCOLOR="$Header" width=40%><FONT FACE="Arial" size="-1">Army Name:</TD><TD BGCOLOR="#666666"><center><FONT FACE="Arial" size="-1"><Input type="Text" value="" name="Army"></TD></tr>
</table>
<table width="100%">!;

foreach $Group (@ArmyList) {
	$NiceGroup = $Group;
	$NiceGroup =~ tr/_/ /;
	$Counter++;
	open (DATAIN, "$MilPath$Group/army.txt");
	@stats = <DATAIN>;
	close (DATAIN);
	&chopper (@stats);

	if (@stats[1] == 1) {$Used = "Ready"}
	if (@stats[1] == 0) {$Used = "Used"}
	if (@stats[1] < 0) {$Turn = abs(@stats[1]);$Used  = "Occupying @stats[8] - $Turn Months Remaining"}
	$a = ($Counter-1) % 2;
	if ($a == 0) {
		print qq!
		<TR><TD width="50%">!;
	}
	if (($Group ne "Pool") && (@stats[1] > 0) && ($Continent == @stats[6]))
	{
		$DeleteBox = qq!Delete Army: <input type=checkbox value=Delete name="Delete$Group">!;
	} elsif ($Continent != @stats[6]) 
	{
		$DeleteBox = qq!Army is off home continent!;
	} elsif (@stats[1] < 1)  
	{
		$DeleteBox = qq!Army is performing orders!;
	} else {
		$DeleteBox = "Not Available";
	}
	print qq!

<table border="1" cellspacing="0" width="100%" bgcolor=$Content>
<TR><TD bgcolor="$Header"><FONT FACE="Arial" size="-1">Name</TD><td colspan=2><FONT FACE="Arial" size="-1">$NiceGroup </td></tr>
<TR><td BGCOLOR="$Header"><FONT FACE="Arial" size="-1">Setting</td><td colspan=2><FONT FACE="Arial" size="-1">$Used</td></tr>
<TR><TD bgcolor="$Header"><font face="arial" size="-1">Continent</TD><TD colspan=2><font face="arial" size="-1">@stats[6]</TD></TR>
<TR><td BGCOLOR="$Header"><FONT FACE="Arial" size="-1">Delete</td><td colspan=2><FONT FACE="Arial" size="-1">$DeleteBox</td></tr>
<TR BGCOLOR="$Header"><td width="33%"><FONT FACE="Arial" size="-1">Name</td><td width="33%"><FONT FACE="Arial" size="-1">Available</td><td width="33%"><FONT FACE="Arial" size="-1">In Army</td></tr>!;
	foreach $Unit (@UnitList) {
		$Units = $Unit;
		$Unit =~ tr/_/ /;		
		$Units =~ tr/ /_/;		

		open (DATAIN, "$MilPath$Group/$Unit.unt");
		$Num = <DATAIN>;
		close (DATAIN);
		chop ($Num);
		if ($Num < 1) {$Num = 0}
		$UnitArmy = $Group.$Unit;
		$UnitArmy =~ tr/ /_/;

		if ($Continent == @stats[6]) {
			print qq!<TR><td width="33%" BGCOLOR="$Header"><FONT FACE="Arial" size="-1">$Unit</td><td width="33%"><FONT FACE="Arial" size="-1">@{[&Space($UnitNum{$Units})]}</td><td width="33%"><FONT FACE="Arial" size="-1"><input type=text value="$Num" name="$UnitArmy" size=12></td></tr>!;
		} else {
			print qq!<TR><td width="33%" BGCOLOR="$Header"><FONT FACE="Arial" size="-1">$Unit</td><td width="33%"><FONT FACE="Arial" size="-1">@{[&Space($UnitNum{$Units})]}</td><td width="33%"><FONT FACE="Arial" size="-1">@{[&Space($Num)]}</td></tr>!;
		}

	}
	print qq!
</table></td>!;

	if ($a == 0) {
		print qq!<TD width="50%">!;
	}else {
		print qq!</TR>!;
	}
}
print qq!
</table><input type="submit" name="submit" value="Process"></form></body></HTML>
!;


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
