#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$Target,$City)=split(/&/,$ENV{QUERY_STRING});
$user_information = "/home/admin/classic/se/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);
&parse_form;

if ($User eq "Admin_Three") {$AdminMode = 12}
$SF = qq!<font face=verdana size=-1>!;
$UnitPath = "/home/admin/classic/unitsdir";
$WeaponPath = "/home/admin/classic/weapons";


@Types = (Ground,Air,Sea,Space);
$zappa = time();
srand($zappa);

$PlanetDir = "/home/admin/classic/se/Planets/$Planet";
$AttackerDir = "$PlanetDir/users/$User";
$DefenderDir = "$PlanetDir/users/$Target";
$NewsDir = "$PlanetDir/News";

#########################################################################################################################
#
#						Get Target Data
#
#########################################################################################################################
open (IN, "$AttackerDir/City.txt");
flock (IN, 1);
@Cities = <IN>;
close (IN);
if (scalar(@Cities) == 0) {
	print "<SCRIPT>alert(\"Your nation is dead.  You cannot attack.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}

open (DATAIN, "$AttackerDir/turns.txt");
$turns = <DATAIN>;
$turns = <DATAIN>;
close (DATAIN);
chop ($turns);

if ($turns < 48) {
	print "<SCRIPT>alert(\"You cannot attack until you have played 48 turns.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}


open (IN, "$DefenderDir/located.txt");
@List = <IN>;
close (IN);
&chopper (@List);

foreach $Item (@List) {
	$FoundCountry{$Item}++;
}
$FoundCountry{$User}++;

foreach $Item (keys(%FoundCountry)) {
	push (@NewList, "$Item\n");
}

open (OUT, ">$DefenderDir/located.txt");
print OUT @NewList;
close (OUT);


open (IN, "$DefenderDir/City.txt") or print "Cannot open city data for read.<BR>";
@CityData = <IN>;
close (IN);
&chopper (@CityData);

$City =~ tr/_/ /;
foreach $State (@CityData) {
	($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $State);
	if ($Name eq $City) {$CityLocation = $BorderLevel}
	$DefendPop = int($Population * 0.12 * $Acceptance);
	$DefendPopPoints = int($DefendPop * 0.75);
}
$City =~ tr/ /_/;



#########################################################################################################################
#
#						Initialize Armies
#
#########################################################################################################################

#Check Attacking Armies For Availability

opendir (DIR, "$AttackerDir/military");
@Files = readdir(DIR);
closedir (DIR);
&IncludeIt(1);

opendir (DIR, "$DefenderDir/military");
@Files = readdir(DIR);
closedir (DIR);
&IncludeIt(2);

open (IN, "$DefenderDir/alliance.txt");
$Alliance = <IN>;
close (IN);
chop ($Alliance);
&DefendersOfTheRealm;

#########################################################################################################################
#
#						Combat Routine
#
#########################################################################################################################

if ($AttackerCount > 0) {
	&ICQNotify;
	&WriteCountry;
	&SelectTargets;
	&VictoryDetermine;

	if ($APoints > 0) {$AttackerCasualtyMod = $DPoints / $APoints} else {$AttackerCasualtyMod = 1;}
	if ($DPoints > 0) {$DefenderCasualtyMod = $APoints / $DPoints} else {$DefenderCasualtyMod = 1;}
	if ($DefenderCasualtyMod < 0) {$DefenderCasualtyMod = 0}
	if ($DefenderCasualtyMod > 4) {$DefenderCasualtyMod = 4}
	if ($AttackerCasualtyMod < 0) {$AttackerCasualtyMod = 0}
	if ($AttackerCasualtyMod > 4) {$AttackerCasualtyMod = 4}

	$QQQs .= qq!"Combat Extender Information<BR>"
	"Attacker Numbers: $APoints<BR>"
	"Defender Numbers: $DPoints<BR>"
	"Attacker Percentage: $AttackerCasualtyMod<BR>"
	"Defender Percentage: $DefenderCasualtyMod<BR>"!;
	&CombatCalc;

	&VictoryDetermine;

	$QQQs .= "Combat Extender Information (Please Report): $APoints >-< $DPoints<BR>";

	if ($APoints > ($DPoints * 3)) {
		&VictoryConditions(1);
	} else {
		&VictoryConditions(2);
	}
	&DeadCheck;
	&Diabolics;
} else {
print qq!
<HTML>
<BODY BGCOLOR="#000000" TEXT="#FFFFFF"><CENTER>
<SCRIPT>parent.frames[1].location.reload()</SCRIPT>
<table width=100% border=1 cellspacing=0>
<TR bgcolor="#333333"><TD><font face=verdana size=-1 color=#CCCCCC><center><B>Combat Results</TD></TR></table><BR><BR><BR>
<font face=verdana size=-1>
We need at least one army to attack.!;

}


#########################################################################################################################
#
#						SubRoutines
#
#########################################################################################################################

# Notify Defender Via ICQ
sub ICQNotify {
	open (IN, "$DefenderDir/userinfo.txt");
	@Data = <IN>;
	close (IN);
	&chopper (@Data);
	$Target =~ tr/_/ /;
	$User =~ tr/_/ /;
	$CityName = $City;
	$CityName =~ tr/_/ /;

	if (@Data[3] ne "") {
open(MAIL, "|/usr/sbin/sendmail @Data[3]\@pager.icq.com") or die "Sorry could not run mail program.";
print MAIL "From: Attack Notification System <shatteredempires\@shatteredempires.com>\n";
print MAIL "Your city of $CityName in the country of $Target has fallen under attack from $User.\n";
print MAIL "http://www.shatteredempires.com\n";
close(MAIL);
	}

}

sub VictoryDetermine {
	$APoints = $DPoints = 0;
	foreach $Item (@AttackerNames) {
		opendir (DIR, "$AttackerDir/military/$Item") or $LossMessage .= "CEE2 - 1 (Report This)<BR>";
		local @Units = readdir (DIR);
		closedir (DIR);

		foreach $ArmyUnit (@Units) {
			if ($ArmyUnit ne "." && $ArmyUnit ne ".." && $ArmyUnit ne "army.txt") {
				open (IN, "$AttackerDir/military/$Item/$ArmyUnit") or $LossMessage .= "CEE2 - 2 (Report This)<BR>";
				local $UnitNum = <IN>;
				&chopper ($UnitNum);

				open (IN, "$UnitPath/$ArmyUnit") or $LossMessage .= "CEE2 - 3 (Report This)<BR>";
				my @UnitData = <IN>; 
				close (IN);
				&chopper (@UnitData);
				if (@UnitData[0] eq "Infantry") {$APoints += $UnitNum * 1 * @UnitData[20]}
				if (@UnitData[0] eq "Armour") {$APoints += $UnitNum * 5 * @UnitData[20]}
			}
		}		
	}
	foreach $Item (@DefenderNames) {
		opendir (DIR, "$DefenderDir/military/$Item") or $LossMessage .= "CEE2 - 1b (Report This)<BR>";
		my @Units = readdir (DIR);
		local $Points = 0;
		closedir (DIR);

		foreach $ArmyUnit (@Units) {
			if ($ArmyUnit ne "army.txt" && $ArmyUnit ne "." && $ArmyUnit ne "..") {
				open (IN, "$DefenderDir/military/$Item/$ArmyUnit") or $LossMessage .= "CEE2 - 2a (Report This)<BR>";
				my $UnitNum = <IN>;
				&chopper ($UnitNum);

				open (IN, "$UnitPath/$ArmyUnit") or $LossMessage .= "CEE2 - 3a (Report This)<BR>";
				my @UnitData = <IN>;
				close (IN);
				&chopper (@UnitData);
				if (@UnitData[0] eq "Infantry") {$DPoints += $UnitNum * 1 * @UnitData[20]}
				if (@UnitData[0] eq "Armour") {$DPoints += $UnitNum * 5 * @UnitData[20]}
			}
		}		
	}
}

#Make the bastards pay
sub Diabolics {
	open (IN, "$AttackerDir/Diabolic.txt");
	flock (IN, 1);
	$Diabic = <IN>;
	close (IN);

	if ($APoints > ($DPoints + 0.001)) {
		$Diabolic += 50;
	} else {
		$Diabolic += 20;
	}

	open (OUT, ">$AttackerDir/Diabolic.txt");
	flock (OUT, 2);
	print OUT $Diabolic ;
	close (OUT);

	open (OUT, ">$AttackerDir/WarState.txt");
	flock (OUT, 2);
	print OUT "$Target-\n";
	close (OUT);
}

#Turn Army Into Occupation Force
sub SecureCity {
	foreach $Item (@AttackerNames) {
		$TimeToWait = int(($CapturedMorale * 100)/10);
		open (IN, "$AttackerDir/military/$Item/army.txt");
		@ArmyData = <IN>;
		close (IN);
		&chopper (@ArmyData);
		@ArmyData[1] = int(-1 * (($TimeToWait/2) + 2));
		@ArmyData[8] = "Occupying $CapturedName";

		open (OUT, ">$AttackerDir/military/$Item/army.txt");
		foreach $WriteLine (@ArmyData) {
			print OUT "$WriteLine\n";
		}
		close (OUT);
	}
}

#Regroup Period
sub FailCity {
	foreach $Item (@AttackerNames) {
		$TimeToWait = 4;
		open (IN, "$AttackerDir/military/$Item/army.txt");
		@ArmyData = <IN>;
		close (IN);
		&chopper (@ArmyData);
		@ArmyData[1] = (-1 * $TimeToWait);
		@ArmyData[8] = "Regrouping From Last Offensive<BR>";

		open (OUT, ">$AttackerDir/military/$Item/army.txt");
		foreach $WriteLine (@ArmyData) {
			print OUT "$WriteLine\n";
		}
		close (OUT);
	}
}


#Add Attacker To Defender's List

sub WriteCountry {
	open (IN, "$DefenderDir/located.txt");
	@CountriesFound = <IN>;
	close (IN);

	foreach $Item (@CountriesFound) {
		if ($User eq $Item) {$PassCode = 1}
	}

	if ($PassCode != 1) {
		open (OUT, ">>$DefenderDir/located.txt");
		print OUT "$User\n";
		close (OUT);
	}
}

#See if country is dead

sub DeadCheck {
	open (IN, "$DefenderDir/City.txt");
	@CitiesIn = <IN>;
	close (IN);

	$NiceAttacker = $User;
	$NiceAttacker =~ tr/_/ /;
	if (scalar(@CitiesIn) == 0) {
		open (OUT, ">$DefenderDir/Dead.txt");
		print OUT qq©
"We need to evacuate!" Shouted the soldier, standing between the thick oaken doors which controlled entrance into the room.  "They'll reach us shortly!"<BR><BR>
Your eyes swept the city again, from the relative safety of the governmental compound.  The fighting had been edging its way towards the compound for several days now, but it had been only a few brief hours since it had reached the last bunkers, and already, those were breached.  The rumble of artillery shook the building, small puffs of plaster exploding from the walls.<BR><BR>
"It's time to go!" screams the soldier again, "We'll use force i-"<BR><BR>
His shout turned suddenly to a scream as the first bullet pierced his leg, the second shattering his knee.  He toppled, narrowly avoiding the hail of gunfire that crashed into the wall, where his chest had been scarcely moments before.  With superhuman effort, his rifle swings up, pointing down the hallway.  His action, heroic but futile, rewarded him with a quick death, red blossoms sprouting all across his chest.<BR><BR>
The sudden report of a gunshot behind you makes you jump, and you turn to see one of your personal guards, sidearm in hand, standing over the body of the other.  She turns to you, gun at the ready.  She knows all too well the only way to survive this day.  Bowing your head, you close your eyes as the muzzle of the pistol settles on your forehead.  A thought flashes through your mind, of how things could have been, had it not been for the war, a brief thought, cut off by sudden nothingness.<BR><BR>
Your nation has been conquered by $NiceAttacker.<BR>©;	
		close (OUT);
	}
}
#Someone's won, go nuts
sub VictoryConditions {
	local ($Condition) = @_;
	open (IN, "$DefenderDir/City.txt");
	@Cities = <IN>;
	close (IN);
	&chopper (@Cities);

	open (IN, "$$AttackerDir/City.txt");
	flock (IN, 1);
	@AttackerCities = <IN>;
	close (IN);


	open (DEFENDEROUT, ">$DefenderDir/City.txt") or print "Cannot Open File 1<BR>";
	open (ATTACKEROUT, ">>$AttackerDir/City.txt") or print "Cannot Open File 2<BR>";
	

	foreach $CityName (@Cities) {
		($Name,$Population,$Status,$Contint,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $CityName);
		$City2 = $City;
		$City2 =~ tr/_/ /;
		if ($Name eq $City2) {
			if ($Condition != 3) {
				$Destroyed = 0.05 * (int((($APoints/2) + ($DPoints/10))/3)/10000000);
				if ($Destroyed > 0.075) {$Destroyed = 0.075}
				if ($Destroyed < 0) {$Destroyed = 0}
				$Destroyed = 1 - $Destroyed;

				$Hospitals = int($Destroyed * $Hospitals);
				$Barracks = int($Barracks * $Destroyed);
				$Schools = int($Schools * $Destroyed);
				$Ag = int($Ag * $Destroyed);
				$Co = int($Co * $Destroyed);
				$In = int($In * $Destroyed);
				$Re = int($Re * $Destroyed);
				$Population = int ($Population * $Destroyed) - $PopKilled;

				if ($Condition == 1 and $Population > 0) {
					$FormerOwner = $Target;
					$Agriculture=$Commercial=$Industrial=$Residential=0;	
					if ($FormerOwner eq "none") {$FormerOwner = $User}
					$Agriculture=$Commercial=$Industrial=$Residential=0;

					#Determine area of country to build in
					$TurnsLeft = nt(((scalar(@AttackerCities)-1)/5))+1;

					print ATTACKEROUT "$Name|$Population|$Status|$Contint|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\n";
					$CapturedMorale = $Acceptance;
					$CapturedName = $Name;
					$FormerOwner = $Target;
					$Conditionf = "<BR><center>We have successfully secured the city of $City.";
					$Conditionf2 = "<BR><center>We have lost the city of $City.";
				} 
				if ($Condition != 1 and $Population > 0) {
					print DEFENDEROUT "$Name|$Population|$Status|$Contint|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\n";
					$CapturedName = $Name;
				}
				if ($Population <= 0) {
					$Conditionf = "<BR><center><B>$City has been destroyed in the fighting.<BR></center>";
					$Conditionf2 = "<BR><center><B>$City has been destroyed in the fighting.<BR></center>";
					$NPopulation = -1;
				}
			}
		} else {
			print DEFENDEROUT "$CityName\n";
		}
	}
	close (ATTACKEROUT);
	close (DEFENDEROUT);

	($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
	$Mon++;
	if (length($Sec) == 1) {$Sec = "0$Sec"}
	if (length($Min) == 1) {$Min = "0$Min"}
	if (length($Hour) == 1) {$Hour = "0$Hour"}
	$Year+=1900;
	$NiceAttacker = $User;
	$NiceAttacker =~ tr/_/ /;
	$NiceTarget = $Target;
	$NiceTarget =~ tr/_/ /;

	if ($NPopulation <= 0) {
		&FailCity;
	}
	open (DNEWSOUT, ">$NewsDir/$Year$Mon$Mday$Hour$Min$Sec") or print "Cannot open path for news<BR>";
	print DNEWSOUT "$NiceAttacker Invades $NiceTarget\n";
	print DNEWSOUT "<Center>$Hour:$Min:$Sec    $Mon/$Mday/$Year\n";

	if ($Condition == 1) {
		&SecureCity;
		print qq!
			<HTML>
			<BODY BGCOLOR="#000000" TEXT="#FFFFFF"><CENTER>
			<SCRIPT>parent.frames[1].location.reload()</SCRIPT>
			<table width=100% border=1 cellspacing=0>
			<TR bgcolor="#333333"><TD><font face=verdana size=-1 color=#CCCCCC><center><B>Combat Results</TD></TR></table><BR><BR><BR>
			<font face=verdana size=-1>
			$QQQ<BR>
			$Conditionf
			$LossMessage!;
		print  DNEWSOUT "$NiceTarget has been attacked and defeated by the country of $NiceAttacker.  It has lost the city of $City2.\n";
	}
	if ($Condition == 2) {
		&FailCity;
		print qq!
			<HTML>
			<BODY BGCOLOR="#000000" TEXT="#FFFFFF"><CENTER>
			<SCRIPT>parent.frames[1].location.reload()</SCRIPT>
			<table width=100% border=1 cellspacing=0>
			<TR bgcolor="#333333"><TD><font face=verdana size=-1 color=#CCCCCC><center><B>Combat Results</TD></TR></table><BR><BR><BR>
			<font face=verdana size=-1>
			$QQQ<BR>
			We were unsuccessful in capturing the city of $City2.<BR>
			$LossMessage!;
		print  DNEWSOUT "$NiceTarget has been attacked by the country of $NiceAttacker.  They were turned back, the city of $City2 remains free.\n";
	}
	close (DNEWSOUT);

	open (DANEWSOUT, ">$DefenderDir/events/$Year$Mon$Mday$Hour$Min$Sec.vnt");
	print DANEWSOUT "$NiceAttacker Invades $NiceTarget\n";
	print DANEWSOUT "<Center>$Hour:$Min:$Sec    $Mon/$MDay/$Year\n";
	print DANEWSOUT "$Conditionf2<BR>$LossMessage\n";
	close (DANEWSOUT);

	foreach $DefenderAlly (@AidListing) {
		open (DANEWSOUT, ">$AidList{$DefenderAlly}/events/$Year$Mon$Mday$Hour$Min$Sec.vnt");
		print DANEWSOUT "$NiceAttacker Invades $NiceTarget\n";
		print DANEWSOUT "<Center>$Hour:$Min:$Sec    $Mon/$MDay/$Year\n";
		if ($Condition == 1) {
			print  DANEWSOUT "$NiceTarget has been attacked by $NiceAttacker.  The army of $DefenderAlly participated in the defense of $City2, but was not enough to turn the tide of battle.  The city has fallen to the enemy.\n";
		}
		if ($Condition == 2) {
			print  DANEWSOUT "The army of $DefenderAlly has participated in the successful defense of the city of $City2.  $NiceTarget has thanked us for our support in the battle against $NiceAttacker.\n";
		}
		close (DANEWSOUT);
	}
}

#Main Combat Routine
sub CombatCalc {
	foreach $ArmySelected (@AttackerNames) {
		&DamageCount($AttackerList{$ArmySelected},1);
		&DamageCount($DefenderList{$AttackerTarget{$ArmySelected}},2);
	
		&DamageAdmin($AttackerList{$ArmySelected},1);
		&DamageAdmin($DefenderList{$AttackerTarget{$ArmySelected}},2);
	}
}	

#Administer Damage to Targets
sub DamageAdmin {
	my @Units;
	$DTEMPPoints = 0;
	$ATEMPPoints = 0;
	local (@Element) = @_;
	$CrewKilled = 0;
	$SpecificUnit = "";
	$AHold=0;
	$DHold=0;

	unless (@Element[0] eq "") {
		opendir (DIR, "@Element[0]") or print "Cannot Open Directory for DamageAdmin<BR>";
		@Units = readdir (DIR);
		closedir (DIR);
	}
		if (@Element[1] == 1) {$LossMessage .= "<BR>Attacker Round<BR>"}
		if (@Element[1] == 2) {$LossMessage .= "<BR>Defender Round<BR>"}
	
		foreach $SpecificUnit (@Units) {
			unless (($SpecificUnit eq ".") or ($SpecificUnit eq "..") or ($SpecificUnit eq "army.txt") or ($SpecificUnit eq "")) {
			
				open (IN, "@Element[0]/$SpecificUnit") or print "Cannot open unit for damage<BR>";
				$Number = <IN>;
				close (IN);
				chop ($Number);
	
				if ((@Element[1] == 1) and ($TotalAttackerUnits > 0)) {$Ratio = $Number/$TotalAttackerUnits}
				if ((@Element[1] == 2) and ($TotalDefenderUnits+$DefendPop > 0)) {$Ratio = $Number/($TotalDefenderUnits+$DefendPop)}
				if (@Element[1] == 1) {$NormPath="$AttackerDir/military";$CasualtyMod = $AttackerCasualtyMod;}
				if (@Element[1] == 2) {$NormPath="$DefenderDir/military";$CasualtyMod = $DefenderCasualtyMod}
	
				open (IN, "$UnitPath/$SpecificUnit");
				@UnitData = <IN>;
				close (IN);
				&chopper (@UnitData);
		
				if ((@UnitData[0] eq "Infantry")) {$Type = "Ground";$TypePts = 0.001}
				if ((@UnitData[0] eq "Armour")) {$Type = "Ground";$TypePts = 0.010}
				if ((@UnitData[0] eq "")) {$Type = "Air";$TypePts = 0.005}

				if (@Element[1] == 1) {$DamageApplied = int(($Ratio * $AttackerArmyDamage{$Type}) * (2 - (@UnitData[7]+@UnitData[9])/2 ))}
				if (@Element[1] == 2) {$DamageApplied = int(($Ratio * $DefenderArmyDamage{$Type}) * (2 - (@UnitData[7]+@UnitData[9])/2 ))}

				$Kills = int(($DamageApplied/@UnitData[5]) * $CasualtyMod);
				if ($Kills > int(0.15 * $Number * $CasualtyMod)) {$Kills = int(0.15 * $Number * $CasualtyMod)}
				$RemainingUnits = ($Number - $Kills);
				if ($RemainingUnits < 0) {$RemainingUnits = 0;$Kills = $Number}
	
				$UnitNameS = substr($SpecificUnit,0,length($SpecificUnit)-4);
				$LossMessage .=  "Unit Type: $UnitNameS - Loses: $Kills<BR>";


	
				$CrewKilled += ($Kills * @UnitData[1]);
				if (@Element[1] == 1) {
					if (@UnitData[0] eq "Infantry" or @UnitData[0] eq "Armour") {
						$OccupationForce += int($RemainingUnits * @UnitData[1]/5);
					}
				}
				unless ($AdminMode == 1) {
					if ($RemainingUnits == 0) {unlink ("@Element[0]/$SpecificUnit")} else {
					open (OUT, ">@Element[0]/$SpecificUnit");
						print OUT "$RemainingUnits\n";
						close (OUT);
					}
				}
			}
			$SpecificUnit =~ s/unt/num/;

			open (IN, "$NormPath/$SpecificUnit");
			@GlobalArmy = <IN>;
			&chopper (@GlobalArmy);
			@GlobalArmy[0] -= $Kills;
			if (@GlobalArmy[0] < 0) {unlink ("$NormPath/$SpecificUnit")}
			else {
				unless ($AdminMode == 1) {
					open (OUT, ">$NormPath/$SpecificUnit");
					foreach $WriteLine (@GlobalArmy) {
						print OUT "$WriteLine\n";
					}
					close (OUT);
				}
			}
			$SpecificUnit =~ s/num/unt/;
		}
	#}
	if (@Element[1] == 2) {
		
		$DamageApplied = int((  ($DefendPop/($TotalDefenderUnits+$DefendPop))  * $DefenderArmyDamage{"Ground"}) * 0.75);
		$PopKilled = int($DamageApplied/15);
		if ($PopKilled > $DefendPop) {$PopKilled = $DefendPop}
		if ($PopKilled < 0) {$PopKilled = 0}
		$LossMessage .= "Unit Type: Civilian Resistance - Loses: $PopKilled<BR>";
	}
	unless (@Element[0] eq "") {
		open (IN, "@Element[0]/army.txt");
		@ArmyData = <IN>;
		close (IN);
		&chopper (@ArmyData);

		@ArmyData[1] = 0;
		if (@Element[1] == 2) {
			@ArmyData[0] = 2;
			@ArmyData[1] = 1;	
		}
		@ArmyData[3] = int(@ArmyData[3] - $CrewKilled);
		if (@ArmyData[3] < 0) {@ArmyData[3] = 0}
		@ArmyData[5] = int(@ArmyData[5] - $CrewKilled);
		if (@ArmyData[5] < 0) {@ArmyData[5] = 0}

		unless ($AdminMode == 1) {
			open (OUT, ">@Element[0]/army.txt");
			foreach $Line (@ArmyData) {
				print OUT "$Line\n";
			}
			close (OUT);
		}
	}
}

#Choose Targets for Attackers & Defenders
sub SelectTargets {
	foreach $Attacker (@AttackerNames) {
		$AttackerTarget{$Attacker} = @DefenderNames[int(rand(scalar(@DefenderNames)))];
		$DefenderTarget{$AttackerTarget{$Attacker}} = $Attacker;
	}
}


#Calculate Damage
sub DamageCount {
	local (@Element) = @_;
	opendir (DIR, @Element[0]);
	@TempUnits = readdir(DIR);
	foreach $UnitSelected (@TempUnits) {
		unless ($UnitSelected eq "army.txt" or $UnitSelected eq "." or $UnitSelected eq "..") {
			open (IN, "@Element[0]/$UnitSelected");
			$NumberofUnits = <IN>;
			chop ($NumberofUnits);
			close (IN);
			open (IN, "$UnitPath/$UnitSelected") or print "Cannot open Unit Directory<BR>";
			@UnitData = <IN>;
			close (IN);
			&chopper (@UnitData);
			open (IN, "$WeaponPath/@UnitData[10].wpn");	
			@WeaponDataOne = <IN>;
			close (IN); 
			&chopper (@WeaponDataOne);
			open (IN, "$WeaponPath/@UnitData[12].wpn");	
			@WeaponDataTwo = <IN>;
			close (IN); 
			&chopper (@WeaponDataTwo);
			if (@Element[1] == 1) {
				$TotalAttackerUnits += $NumberofUnits;
				$DefenderArmyDamage{@WeaponDataOne[2]} += int(@WeaponDataOne[0] * @WeaponDataOne[1] * $NumberofUnits);
				$DefenderArmyDamage{@WeaponDataTwo[2]} += int(@WeaponDataTwo[0] * @WeaponDataTwo[1] * $NumberofUnits);
			}	
			if (@Element[1] == 2) {
				$TotalDefenderUnits += $NumberofUnits;
				$AttackerArmyDamage{@WeaponDataOne[2]} += int(@WeaponDataOne[0] * @WeaponDataOne[1] * $NumberofUnits);
				$AttackerArmyDamage{@WeaponDataTwo[2]} += int(@WeaponDataTwo[0] * @WeaponDataTwo[1] * $NumberofUnits);
			}
		}	
	}
	# Citizen Damage
	if ($User =~ /Admin/ and @Element[1] == 2) {
		$Type = "Ground";
		$AttackerArmyDamage{$Type} += $DefendPopPoints;
	}
}

#Determine Defender Assistance
sub DefendersOfTheRealm {
	#File Format - Continent,Owner
	open (IN, "$PlanetDir/alliances/$Alliance/Assistance");
	@AssistanceInfo = <IN>;	
	close (IN);
	&chopper (@AssistanceInfo);

	foreach $AssistingArmy (@AssistanceInfo) {
		if (substr(@AssistingArmy,0,1) == $CityLocation) {
			open (IN, "$PlanetDir/$Owner/military/$AssistingArmy");
			@ArmyData = <IN>;
			close (IN);
			&chopper (@ArmyData);
			if ((@ArmyData[1] == 1) and (@ArmyData[0] == 1) and (@ArmyData[5] >= int (0.5 * @ArmyData[3])) and (@ArmyData[6] == $CityLocation)) {
				$Owner = substr($AssistingArmy,1,length($AssistingArmy));
				$DefenderList{$AssistingArmy} = qq!$PlanetDir/$Owner/military/$AssistingArmy!;
				$AidList{$AssistingArmy} = "$PlanetDir/$Owner";
				$DefenderCount++;
				push(@DefenderNames,$Item);
				push(@AidListing,$AssistingArmy);
			}
		}
	}
}



#Assign Attacker/Defender Armies.
sub IncludeIt {
	local ($Element) = @_;
	foreach $Item (@Files) {
		if ($Element == 1) {$Simp = "$AttackerDir/military/$Item"}
		if ($Element == 2) {$Simp = "$DefenderDir/military/$Item"}
		if (-d "$Simp" and $Item ne '.' and $Item ne '..' and $Item ne 'Pool') {

			open (IN, "$Simp/army.txt");
			@ArmyData = <IN>;
			close (IN);
			&chopper (@ArmyData);			
			if ($Element == 1) {
				#Check to see if army can participate:  Go Code - Ready - Full Soldiers - Same Continent
				if (($Data{$Item} eq "Yes") and (@ArmyData[1] == 1) and (@ArmyData[5] >= int(0.5 * @ArmyData[3])) and (@ArmyData[6] == $CityLocation) and (@ArmyData[0] == 3) and ($ArmyData[3] > 0)) {
					opendir (DIR, "$Simp");
					@Files2 = readdir (DIR);
					closedir (DIR);
					if (scalar(@Files2) > 3) {
						$AttackerList{$Item} = $Simp;
						$AttackerCount++;
						push(@AttackerNames,$Item);
							$WarCosts += @ArmyData[2];
						@ArmyData[1]=0;

						unless ($AdminMode == 1) {
							open (OUT, ">$Simp/army.txt");
								foreach $Line (@ArmyData) {
								print OUT "$Line\n";
							}
							close (OUT);
					
						}
					} else {push(@FailureList,$Item);}
				} else {push(@FailureList,$Item);}
			}
			if ($Element == 2) {	
				if ((@ArmyData[1] == 1) and ( (@ArmyData[0] == 2) || (@ArmyData[1] <= 0 and @ArmyData[8] =~ $City)) and (@ArmyData[5] >= int(0.5 * @ArmyData[3])) and (@ArmyData[6] == $CityLocation) and (@ArmyData[3] > 0)) {
					opendir (DIR, $Simp);
					@Files2 = readdir (DIR);
					closedir (DIR);
					if (scalar(@Files2) > 3) {
						$DefenderList{$Item} = $Simp;
						$DefenderCount++;
						push(@DefenderNames,$Item);
					}
				} else {push(@DefenderFailureList,$Item)}
			}
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
         
      

      $Data{$name} = $value;
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
