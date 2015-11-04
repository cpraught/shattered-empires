#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$Target,$City)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);
&parse_form;

$SF = qq!<font face=verdana size=-1>!;
$UnitPath = $MasterPath . "/unitsdir";
$WeaponPath = $MasterPath . "/weapons";

$AttackMode = $data{'mode'};
if ($AttackeMode eq "") {$AttackMode = "Standard";}
########## Attacker:Defender Ratios: ##############
if ($AttackMode eq "Standard") {$WinRatio = 1.5;}
if ($AttackMode eq "Siege") {$WinRatio = 2;}
if ($AttackMode eq "Raid") {$WinRatio = 1.5;}
if ($AttackMode eq "Recovery") {$WinRatio = 1;}




@Types = (Ground,Air,Naval,Space);
$zappa = time();
srand($zappa);

$PlanetDir = $MasterPath . "/se/Planets/$Planet";
$AttackerDir = "$PlanetDir/users/$User";
$DefenderDir = "$PlanetDir/users/$Target";
$UnitDir = $MasterPath . "/unitsdir";
$NewsDir = "$PlanetDir/News";
$WeaponDir = $MasterPath . "/weapons";
$UWGDir = "$PlanetDir/UWG";

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
flock (IN, 1);
$turns = <DATAIN>;
$turns = <DATAIN>;
close (DATAIN);

chop ($turns);

if ($turns < 72) {
	print "<SCRIPT>alert(\"You cannot attack until you have played 72 turns.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}

if ($Target =~ /Admin/) {
	print "<SCRIPT>alert(\"You have selected an invalid target.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}


open (IN, "$AttackerDir/money.txt") or print $!;
flock (IN, 1);
@Money = <IN>;
close (IN);
&chopper (@Money);

open (IN, "$AttackerDir/located.txt") or print $!;
flock (IN, 1);
@List = <IN>;
close (IN);
&chopper (@List);

$Go = 0;
foreach $Item (@List) {
#	$Item  = substr ($Item, 0, scalar($Item) - 1);
	if ($Target eq $Item) {$Go = 1;}
}

if ($Go != 1) {
	print "<SCRIPT>alert(\"You have selected an invalid target.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}

open (DATAIN, "$DefenderDir/turns.txt");
flock (IN, 1);
$dturns = <DATAIN>;
$dturns = <DATAIN>;
close (DATAIN);

chop ($dturns);

if ($dturns < 72) {
	print "<SCRIPT>alert(\"You cannot attack until your target has played 72 turns.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}

open (IN, "$AttackerDir/Retal.txt");
flock (IN, 1);
@DataIn = <IN>;
close (IN);
&chopper (@DataIn);

foreach $Line (@DataIn) {
	($AgrCountry, $TurnsToAttack) = split (/,/, $Line);
	$AttackHash{$AgrCountry} = $TurnsToAttack;
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


open (IN, "$DefenderDir/City.txt");
@CityData = <IN>;
close (IN);
&chopper (@CityData);

$City =~ tr/_/ /;
foreach $State (@CityData) {
	($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $State);

	if ($Name eq $City) {
		$CityLocation = $BorderLevel;
		$DefendPop = int($Population * 0.12 * $Acceptance);
		$DefendPopPoints = int($DefendPop * 0.75);
		$OrigNetWorth = ( ($Hospitals * 15) + ($Barracks * 20) + ($Ag * 20) + ($Co * 40) + ($In * 50) + ($Re * 40) );
	}
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

if ($WarCosts > @Money[0]) {
	print "<SCRIPT>alert(\"You do not possess the funds to attack your target.\");history.back();</SCRIPT>";
	die;
} else {
	@Money[0] -= $WarCosts;
	open (OUT, ">$AttackerDir/money.txt") or print $!;
	flock (OUT, 2);
	print OUT "@Money[0]\n";
	close (OUT);
}

opendir (DIR, "$DefenderDir/military");
@Files = readdir(DIR);
closedir (DIR);
&IncludeIt(2);

#open (IN, "$DefenderDir/alliance.txt");
#$Alliance = <IN>;
#close (IN);
#chop ($Alliance);
#DefendersOfTheRealm;

########################################################################################################################
#
#						Combat Routine
#
#########################################################################################################################

if ($AttackerCount == 1) {

	#Calculate Attacker Damage
	$AttackArmyType = 1;
	foreach $Warrior (keys(%AttackerForces)) {
		&AquirePower($Warrior, $AttackerForces{$Warrior});
	}
	$Debug2 .= qq!AttackerPower $AttackerPower[0] - $AttackerPower[1] - $AttackerPower[2] - $AttackerPower[3] - $AttackerPower[4]<BR>!;

	#Calculate Defender / Ally / UWG Damage
	$AttackArmyType = 0;
	foreach $Warrior (keys(%DefenderForces)) {
		&AquirePower($Warrior, $DefenderForces{$Warrior});
	} 
	$Debug2 .= qq!DefenderPower $DefenderPower[0] - $DefenderPower[1] - $DefenderPower[2] - $DefenderPower[3] - $DefenderPower[4]<BR>!;
	#Distribute Casualties
	&Casualties;


	$Debug2 .= qq!(Apoints - $AttackerPoints > (Dpoints - $DefenderPoints * WinRatio - $WinRatio) && (Apoints - $AttackerPoints > Dpoints - $DefendPopPoints)<BR>!;
	if ($AttackerPoints > ($DefenderPoints * $WinRatio) && ($AttackerPoints > $DefendPopPoints)) {$VictoryConditions = 1;} else {$VictoryConditions = 2;}
} else {$VictoryConditions = 2;}

if ($VictoryConditions < 1) {$VictoryConditions = 2;}

$Debug2 .= "VicCon - $VictoryConditions<BR>";
$Debug2 .= "AP:", join (',', @AttackerPower)," <BR>";
$Debug2 .= "DP:", join (',', @DefenderPower)," <BR>";

&AdministerVictory;
&ModifyArmies;
&Punish;
&Display;

#########################################################################################################################
#
#						SubRoutines
#
#########################################################################################################################

sub Punish 
{
	open (IN, "$AttackerDir/country.txt");
	flock (IN, 1);
	@At = <IN>;
	close (IN);
	&chopper (@At);

	open (IN, "$DefenderDir/country.txt");
	flock (IN, 1);
	@De = <IN>;
	close (IN);
	&chopper (@De);

	open (IN, "$DefenderDir/Retal.txt");
	flock (IN, 1);
	@Retal = <IN>;
	close (IN);
	&chopper (@Retal);

	foreach $Line (@Retal) {
		($AgrCountry, $TurnsToAttack) = split (/,/, $Line);
		$AttackerHash{$AgrCountry} = $TurnsToAttack;
	}
	$AttackerHash{$User} += 8;

	open (OUT, ">$DefenderDir/Retal.txt");
	flock (OUT, 2);
	while (($Key, $Value) = each(%AttackerHash)) {
		print OUT "$Key,$Value\n";
	}

	close (OUT);

	#Punish if size descrepancy is too large.

	open (IN, "$AttackerDir/Retal.txt");
	flock (IN, 1);
	my @TempRetal = <IN>;
	close (IN);
	&chopper (@TempRetal);

	#Check to see if retaliation without punishment possible
	foreach $Item (@TempRetal) {
		my @Temp = split(/,/, $Item);
		if (@Temp[0] eq $Target && @Temp[1] > 0) {$AttackClear = 1;}
	}

	#Determine if punishment is applicable.


	if (((@At[8] * .75) > @De[8]) || ((@De[8] * .75) > @At[8]) && ($AttackClear != 1)) {
		$User =~ tr/_/ /;
		if (@At[9] < 1) {
			$WarnMessage = qq!UWG Spokesman Corp Mathain announced today that the UWG would take action against $User if attacks against inappropriate nations were not halted immediately. As he assured world leaders that this was the UWG's first and final warning to $User, the UWG Diplomatic Office downgraded relations with the state.!;

			open (OUT, ">$NewsDir/$Year$Mon$Mday$Hour$Min$Sec".a) or print "Cannot open International for writing<BR>";
			flock (OUT, 2);
			print OUT "UWG makes statement against $User.\n";
			print OUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
			print OUT "$WarnMessage";
			close (OUT);
			@At[7] = "Sanctioned";

		} elsif (@At[9] == 1) {

			open (IN, "$AttackerDir/City.txt");
			flock (IN, 1);
			@ACity = <IN>;
			close (IN);
			&chopper (@ACity);
			open (IN, "$DefenderDir/City.txt");
			flock (IN, 1);
			@DCity = <IN>;
			close (IN);
			&chopper (@DCity);


			$CityTaken = int(rand(scalar(@ACity)));
			($CityName,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, @ACity[$CityTaken]);
			$TurnsLeft = int((scalar(@DCity)-1) * 0.2) + 1;
			$Agriculture=$Commercial=$Industrial=$Residential=0;

			open (OUT, ">>$DefenderDir/City.txt");
			flock (OUT, 2);
			print OUT qq!$CityName|$Population|$Status|$BorderLevel|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\n!;
			close (OUT);

			open (OUT, ">$AttackerDir/City.txt");
			flock (OUT, 2);
			for ($i=0;$i<=scalar(@ACity);$i++) {
				if ($i != $CityTaken) {print OUT "@ACity[$i]\n";}
			}
			close (OUT);

			$WarnMessage = qq!Responding to an attack by the nation of $User against a weaker country, UWG forces launched a massive suprise attack, securing the city of $CityName.  Spokesman Corp Mathain made the following statement;  "The UWG has never tolerated acts of aggression against weaker and undefensable nations.  $CityName will be given to the victim of this atrocity as reperation.  Should $User launch more attacks against our weaker brothers in the future, the punishment shall be much more severe."!;

			open (OUT, ">$NewsDir/$Year$Mon$Mday$Hour$Min$Sec".a) or print "Cannot open International for writing<BR>";
			flock (OUT, 2);
			print OUT "UWG invades $User in response to attacks.\n";
			print OUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
			print OUT "$WarnMessage";
			close (OUT);

			@At[7] = "Rogue";
		} elsif (@At[9] > 1 && @At[9] < 4) {
			open (IN, "$AttackerDir/City.txt");
			flock (IN, 1);
			@ACity = <IN>;
			close (IN);
			&chopper (@ACity);
			open (IN, "$DefenderDir/City.txt");
			flock (IN, 1);
			@DCity = <IN>;
			close (IN);
			&chopper (@DCity);


			$CityTaken = int(rand(scalar(@ACity)));
			($CityName,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, @ACity[$CityTaken]);
			$TurnsLeft = int((scalar(@DCity)-1) * 0.2) + 1;
			$Agriculture=$Commercial=$Industrial=$Residential=0;

			open (OUT, ">>$DefenderDir/City.txt");
			flock (OUT, 2);
			print OUT qq!$CityName|$Population|$Status|$BorderLevel|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\n!;
			close (OUT);

			open (OUT, ">$AttackerDir/City.txt");
			flock (OUT, 2);
			for ($i=0;$i<=scalar(@ACity);$i++) {
				if ($i != $CityTaken) {print OUT "@ACity[$i]\n";}
			}
			close (OUT);

			$WarnMessage = qq!The UWG launched an all-out assault against $User today, as punishment for its attacks against weaker nations.  UWG special forces secured the city of $CityName, as artillery bombardment and airstrikes flattened the remaining cities.  UWG Spokesman Corp Mathain had only the following to say;  "This is the price of unwarranted agression."!;

			open (OUT, ">$NewsDir/$Year$Mon$Mday$Hour$Min$Sec".a) or print "Cannot open International for writing<BR>";
			flock (OUT, 2);
			print OUT "UWG invades $User in response to attacks.\n";
			print OUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
			print OUT "$WarnMessage";
			close (OUT);

			@At[7] = "Enemy";
		} elsif (@At[9] > 3) {
			open (IN, "$AttackerDir/City.txt");
			flock (IN, 1);
			@ACity = <IN>;
			&chopper (@ACity);
			close (IN);
			open (IN, "$DefenderDir/City.txt");
			flock (IN, 1);
			@DCity = <IN>;
			close (IN);
			&chopper (@DCity);


			$CityTaken = int(rand(scalar(@ACity)));
			($CityName,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, @ACity[$CityTaken]);
			$TurnsLeft = int((scalar(@DCity)-1) * 0.2) + 1;
			$Agriculture=$Commercial=$Industrial=$Residential=0;

			open (OUT, ">>$DefenderDir/City.txt");
			flock (OUT, 2);
			print OUT qq!$CityName|$Population|$Status|$BorderLevel|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\n!;
			close (OUT);

			open (OUT, ">$AttackerDir/City.txt");
			flock (OUT, 2);
			for ($i=0;$i<=scalar(@ACity);$i++) {
				if ($i != $CityTaken) {print OUT "@ACity[$i]\n";}
			}
			close (OUT);
			$WarnMessage = qq!The UWGs on-going campaign against $User took an astonishing turn today, as a team of elite UWG Special Forces (UWG-SF) infiltrated the capital city, took control of the governmental offices, and executed every last state official, including $LeaderName.  As they carried out this assassination, UWG armies converged on military bases, supply depots and training facilities, anhiliating every last soldier and piece of equipment.  UWG Spokesman Corp Mathain declined comment.!;

			open (OUT, ">$NewsDir/$Year$Mon$Mday$Hour$Min$Sec".a) or print "Cannot open International for writing<BR>";
			flock (OUT, 2);
			print OUT "UWG invades $User in response to attacks.\n";
			print OUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
			print OUT "$WarnMessage";
			close (OUT);
			@At[7] = "Enemy";

			open (OUT, ">$AttackerDir/Dead.txt");
			print OUT "$WarnMessage\n";
			close (OUT);

			open (OUT, ">$AttackerDir/City.txt");
			close (OUT);
		}

		@At[9]++;
	}

	@At[8] = @At[8] - $ANetLoss + $CNewGain;
	open (OUT, ">$AttackerDir/country.txt");
	foreach $Item (@At) {
		print OUT "$Item\n";
	}
	close (OUT);

	@De[8] = @De[8] - $DNetLoss - ($OrigNetWorth - $NewNetWorth);
	open (OUT, ">$DefenderDir/country.txt");
	foreach $Item (@De) {
		print OUT "$Item\n";
	}
	close (OUT);
}


#DisplayResults

sub Display 
{

#	$DebugMsg = "Debug mode is ON.  In order to make combat run as smoothly as possible, please save this page into notepad and email it to chris\@bluewand.com.  Thank you for your cooperation.";

	print qq!
<body bgcolor=black text=white>
<font face=arial>
<Table width=100% border=1 cellspacing=0 cellpadding=0><TR><TD><center><font face=arial><B>Combat Results</B></TD></TR></table>
<BR><BR><BR><center>$DebugMsg$WarnMessage<BR>$CaptureMessage</center><BR><BR>$CasualtyScreen!;

#print qq!<BR>$Debug2!;
}



#Change Armies to reflect attack
sub ModifyArmies
{
	foreach $Item (@AttackerNames) {
		print "Modifying $Item<BR>";

		open (IN, "$AttackerDir/military/$Item/army.txt") or print $!;
		flock (IN, 1);
		my @Info = <IN>;
		close (IN);
		&chopper (@Info);

		if ($VictoryConditions == 1) {
			@Info[1] = -6;
			$City =~ tr/_/ /;
			@Info[8] = "Occupying $City";
			$City =~ tr/ /_/;
			print "$Item - Occupying<BR>";
		} else {
			@Info[1] = -4;
			@Info[8] = "Regrouping";
			print "$Item - Regrouping<BR>";
		}

		open (OUT, ">$AttackerDir/military/$Item/army.txt") or print $!;
		flock (OUT, 2);
		foreach $Item (@Info) {
			print OUT "$Item\n";
		}
		close (OUT);
	}
	foreach $Item (@DefenderNames) {
		open (IN, "$DefenderDir/military/$Item");
		flock (IN, 1);
		my @Info = <IN>;
		close (IN);
		&chopper (@Info);

		if ($VictoryConditions == 1) {
			@Info[1] = 0;
			@Info[8] = "";
		}

		open (OUT, ">$DefenderDir/military/$Item");
		flock (OUT, 2);
		foreach $Item (@Info) {
			print OUT "$Item\n";
		}
		close (OUT);

	}
}





#Administer The Victory

sub AdministerVictory

{
	open (IN, "$DefenderDir/City.txt");
	flock (IN, 1);
	@Cities = <IN>;
	close (IN);
	&chopper(@Cities);
	
	open (IN, "$AttackerDir/City.txt");
	flock (IN, 1);
	@AttackerCities = <IN>;
	close (IN);

	$NiceNation = $User;
	$NiceNation =~ tr/_/ /;
	$NiceDefender = $Target;
	$NiceDefender =~ tr/_/ /;
	
	foreach $Item (@Cities) {
		$City =~ tr/_/ /;
		($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $Item);
		unless ($City eq $Name) {
			push (@NewCities, "$Item\n");
		} else {
			#City is captured
			if ($AttackMode eq "Standard" && $VictoryConditions == 1) {			
				$TurnsLeft = int((scalar(@AttackerCities)-1) * 0.2) + 1;
				$Agriculture=$Commercial=$Industrial=$Residential=0;
				push (@AttackerCities, qq!$Name|$Population|$Status|$BorderLevel|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\n!);

				$Ag = abs(int($Ag * 0.90));
				$Co = abs(int($Co * 0.90));
				$In = abs(int($In * 0.90));
				$Re = abs(int($Re * 0.90));

				$CaptureMessage = "The nation of $NiceDefender was over-run by $NiceNation.  The city of $Name has been surrendered to the attackers.";
				if ($UWGAid == 1) {$CaptureMessage .= "  United World Government forces aided in the battle, but were not enough to turn the tide against the onslaught.  UWG Miltary Spokesman Corp Mathain promised swift justice against the attackering party.\n";} else {$CaptureMessage .= "\n";}

				$NewNetWorth = 0;
				$CNewGain = ( ($Hospitals * 15) + ($Barracks * 20) + ($Ag * 20) + ($Co * 40) + ($In * 50) + ($Re * 40) );
			}
			#City Resists Attackers
			if ($AttackMode eq "Standard" && $VictoryConditions != 1) {
			 	push (@NewCities, "$Item\n");
			 	$CaptureMessage = "The nation of $NiceDefender repelled an assault conducted by $NiceNation.  The attackers were unable to capture the city of $Name.";
		 		if ($UWGAid == 1) {$CaptureMessage .="  United World Government forces participated in the successful defense, and Military Spokesman Corp Mathain pledged that the UWG would do everything in its power to deter the attacker.\n";} else {$CaptureMessage .= "\n";}

				$Ag = abs(int($Ag * 0.90));
				$Co = abs(int($Co * 0.90));
				$In = abs(int($In * 0.90));
				$Re = abs(int($Re * 0.90));


				$NewNetWorth = ( ($Hospitals * 15) + ($Barracks * 20) + ($Ag * 20) + ($Co * 40) + ($In * 50) + ($Re * 40) );
				$CNewGain = 0;
			}
			if ($AttackMode eq "Siege" && $VictoryConditions == 1) {
				$PercentLeft -= (0.10 +  (0.15 * (($Barracks/($LandSize + $Hospitals + $Schools + $Barracks)))));
	  			#Determine if City is actually captured
	  			if ($PercentLeft <= 0) {
	  				#City has been captured  			
	  				$TurnsLeft = int((scalar(@AttackerCities)-1) * 0.2) + 1;
	  				$PercentLeft = 0.50;
					$Agriculture=$Commercial=$Industrial=$Residential=0;
					push (@AttackerCities, qq!$Name|$Population|$Status|$BorderLevel|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\n!);
	  				$CaptureMessage = "The city of $Name in $NiceDefender has finally succumbed to the besieging forces of $NiceNation.";
	  				if ($UWGAid == 1) {$CaptureMessage .= "  UWG assistance was unable to prevent the capture of $Name.  UWG Spokesman Corp Mathain promised that the UWG would not stand idly by.";} else {$CaptureMessage .= "\n";}


					$Ag = abs(int($Ag * 0.90));
					$Co = abs(int($Co * 0.90));
					$In = abs(int($In * 0.90));
					$Re = abs(int($Re * 0.90));


					$NewNetWorth = 0;
					$CNewGain = ( ($Hospitals * 15) + ($Barracks * 20) + ($Ag * 20) + ($Co * 40) + ($In * 50) + ($Re * 40) );
	  			} else {
	  				#City stands free
	  				push (@NewCities, qq!$Name|$Population|$Status|$BorderLevel|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\n!);
	  				$CaptureMessage = "The city of $Name in $NiceDefender has managed to hold off besieging attackers of $NiceNation once again.";
	  				if ($UWGAid == 1) {$CaptureMessage .= "  UWG soldiers participated in the victory.  According to UWG Spokesman Corp Mathain, the UWG would take action against the attacker.";} else {$CaptureMessage .= "\n";}

					$Ag = abs(int($Ag * 0.95));
					$Co = abs(int($Co * 0.95));
					$In = abs(int($In * 0.95));
					$Re = abs(int($Re * 0.95));

					$NewNetWorth = ( ($Hospitals * 15) + ($Barracks * 20) + ($Ag * 20) + ($Co * 40) + ($In * 50) + ($Re * 40) );
					$CNewGain = 0;
	  			}
			}
		}		
	}

	open (OUT, ">$DefenderDir/City.txt");
	flock (OUT, 2);
	print OUT @NewCities;
	close (OUT);
	
	open (OUT, ">$AttackerDir/City.txt");
	flock (OUT, 2);
	print OUT @AttackerCities;
	close (OUT);	
	$DefenderMessage = $CaptureMessage ."<BR><BR>$CasualtyScreen";
	
	($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
	if (length($Sec) == 1) {$Sec = "0$Sec"}
	if (length($Min) == 1) {$Min = "0$Min"}
	if (length($Hour) == 1) {$Hour = "0$Hour"}
	$Mon ++;
	$Year += 1900;
	
	open (OUT, ">$NewsDir/$Year$Mon$Mday$Hour$Min$Sec") or print "Cannot open International for writing<BR>";
	flock (OUT, 2);
	print OUT "$AttackMode attack conducted in $NiceDefender by $NiceNation.\n";
	print OUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
	print OUT "$CaptureMessage";
	close (OUT);

	#Alert Defender	
	open (OUT, ">$DefenderDir/events/$Year$Month$Mday$Hour$Min$Sec.vnt") or print "Cannot open National for writing<BR>";
	flock (OUT, 2);
	print OUT "$AttackMode attack conducted in $NiceDefender by $NiceNation.\n";
	print OUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
	print OUT "$DefenderMessage";
	close (OUT);

	#Alert Allies	
	foreach $Item (keys(%AidList)) {
		open (OUT, ">$AidList{$Item}/events/$Year$Month$Mday$Hour$Min$Sec.vnt");
		flock (OUT, 2);
		print OUT "Your armies have assisted $NiceDefender defend against a $AttackMode attack conducted by $NiceNation.\n";
		print OUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
		print OUT "$DefenderMessage";
		close (OUT);
	}

	#Write Debug Data
	open (OUT, ">/home/bluewand/data/classic/ComData/$User-v-$Target-$Min$Sec.html");
	flock (OUT, 2);
	print OUT qq!<html><head><title>Combat Results for $User vs $Target</title></head><body>\n!;
	print OUT "$Debug2<BR><BR><BR>\n";
	print OUT "$CasualtyScreen\n";
	print OUT qq!</body></html>!;
	close (OUT);
}






#Call Real Casualty Sub Based On Army Type

sub Casualties

{
	foreach $Item (@AttackerNames) {
		#Call InflictCasualties sub (Army, Attacker Type)
		&InflictCasualties($Item, 0);
	}
	foreach $Item (@DefenderNames) {
		#Call InflictCasualties sub (Army, Defender Type)
		&InflictCasualties($Item, 1);
	}
	foreach $Item (@AidListing) {
		#Call InflictCasualties sub (Army, Ally Type)
		&InflictCasualties($Item, 2);
	}
}




sub InflictCasualties

{

	my $SoldierDeaths = 0;
	my ($ArmyName, $ArmyType) = @_;
	if ($ArmyType == 0) {$ArmyPath = "$AttackerDir/military/$ArmyName";}
	if ($ArmyType == 1) {$ArmyPath = "$DefenderDir/military/$ArmyName";}
#	if ($ArmyType == 2) {$ArmyPath = "$AidList{$ArmyName}/military/$ArmyName";}

	opendir (DIR, $ArmyPath);
	@ArmyFiles = readdir (DIR);
	closedir (DIR);

	$Debug2 .= qq!<BR><BR><h2>$ArmyName:</h2><BR><BR>!;
	foreach $Unit (@ArmyFiles) {
		if ($Unit eq "army.txt" || $Unit eq "." || $Unit eq "..") {} else {
			open (IN, "$ArmyPath/$Unit");
			flock (IN, 1);
			$NumberOfUnits = <IN>;
			close (IN);
			chomp ($NumberOfUnits);

			if ($NumberOfUnits > 0) {

				if (-e "$UnitDir/$Unit") {

					$Debug2 .= qq!<B>Unit taking casualties: $Unit<BR>!;
					open (IN, "$UnitDir/$Unit") or print "Cannot open Unit File ($Unit)<BR>";
					flock (IN, 1);
					@UnitData = <IN>;
					close (IN);
					&chopper (@UnitData);

					$Debug2 .= qq!Number of Units: $NumberOfUnits</b><BR>!;
	
					if (@UnitData[0] eq "Armour") {$DamageType = "Ground";$DamageTypeNum = 0}
					if (@UnitData[0] eq "Infantry") {$DamageType = "Infantry";$DamageTypeNum = 4;}
					if (@UnitData[0] eq "Naval") {$DamageType = "naval";$DamageTypeNum = 1;}
					$tmpRatio = 1;

					if ($ArmyType == 0) {

						if ($AttackerForcesType{$DamageType} > 0) {

							$Debug2 .= qq!<B> --- Attacker casualty<BR></b>!;
	
							$PercentOfDamage = $NumberOfUnits/$AttackerForcesType{$DamageType};
							$DamageInflicted = int($PercentOfDamage * @DefenderPower[$DamageTypeNum]);
							$Debug2 .= qq!PercentofDamage - $PercentOfDamage : Power Inflicted @DefenderPower[$DamageTypeNum] - Power Blocked @AttackerPower[$DamageTypeNum]<BR><BR>!;

							if ((@AttackerPower[$DamageTypeNum] > 0) && (@AttackerPower[$DamageTypeNum] > @DefenderPower[$DamageTypeNum])) {
								$tmpRatio = ((@DefenderPower[$DamageTypeNum]/@AttackerPower[$DamageTypeNum]) * (@DefenderPower[$DamageTypeNum]/@AttackerPower[$DamageTypeNum]));
								if ($tmpRatio > 1) {$tmpRatio = 1;}

								$DamageInflicted = int($DamageInflicted * $tmpRatio);
								$Debug2 .= qq!Damage Inflicted1 -  $DamageInflicted  ($tmpRatio)<BR>!;
							} else {
								$DamageInflicted = int($PercentOfDamage * @DefenderPower[$DamageTypeNum]);
								$Debug2 .= qq!Default Damage Inflicted2 - $DamageInflicted  ($tmpRatio)<BR>!;
								$tmpRatio = 1;
							}
							if ($DamageInflicted < 0) {$DamageInflicted = 0;}
	
						} else {
							$Debug2 .= qq!No damage to unit class ($DamageType)<BR>!;
							$DamageInflicted = 0;
						}
					} else {
						if ($DefenderForcesType{$DamageType} > 0) {

							$Debug2 .= qq!<B> --- Defender casualty<BR></b>!;

							$PercentOfDamage = $NumberOfUnits/$DefenderForcesType{$DamageType};
							$DamageInflicted = int($PercentOfDamage * @AttackerPower[$DamageTypeNum]);
							$Debug2 .= qq!PercentofDamage - $PercentOfDamage : Power Inflicted @AttackerPower[$DamageTypeNum] - Power Blocked @DefenderPower[$DamageTypeNum]<BR><BR>!;

							$Debug2 .= qq!Damage Inflicted: $DamageInflicted<BR> DefenderPower:  @DefenderPower[$DamageTypeNum]<BR>  Attacker Power: @AttackerPower[$DamageTypeNum])<BR>!;
							if ((@DefenderPower[$DamageTypeNum] > 0) && (@AttackerPower[$DamageTypeNum] < @DefenderPower[$DamageTypeNum])) {
								$tmpRatio = ((@AttackerPower[$DamageTypeNum]/@DefenderPower[$DamageTypeNum]) * (@AttackerPower[$DamageTypeNum]/@DefenderPower[$DamageTypeNum]));
								if ($tmpRatio > 1) {$tmpRatio = 1;}

								$DamageInflicted = int($DamageInflicted * $tmpRatio);
								$Debug2 .= qq!Damage Inflicted1 - $DamageInflicted  ($tmpRatio)<BR>!;
							} else {
								$DamageInflicted = int($PercentOfDamage * @AttackerPower[$DamageTypeNum]);
								$Debug2 .= qq!Default Damage Inflicted2 - $DamageInflicted  ($tmpRatio)<BR>!;
								$tmpRatio = 1;
							}
							if ($DamageInflicted < 0) {$DamageInflicted = 0;}
	
						} else {
							$Debug2 .= qq!No damage to unit class ($DamageType)<BR>!;
							$DamageInflicted = 0;
						}
					}

					#Kills = Damage/Health
					$Kills = int($DamageInflicted/@UnitData[5] * $tmpRatio);

					$Debug2 .= qq!Kills - $Kills = int($DamageInflicted/@UnitData[5] * $tmpRatio)<BR>!;
	
					if ($Kills > $NumberOfUnits * 0.20 * $tmpRatio) {
						$Kills = int($NumberOfUnits * 0.20 * $tmpRatio);
						$Debug2 .= qq!Capped Kills (20%)- $Kills = int($NumberOfUnits * 0.20 * $tmpRatio)<BR>!;
					}
					if ($Kills > $NumberOfUnits) {
						$Kills = $NumberOfUnits;
						$Debug2 .= qq!Capped Kills (All)- $Kills = $NumberOfUnits<BR>!;
					}
	

					$Debug2 .= "<BR><BR>";

					$NumberOfUnits -= $Kills;
					$SoldierDeaths += ($Kills * @UnitData[1]);

					if ($ArmyType == 0) {$ANetLoss += (($Kills  * @UnitData[3]) / 100);}
					if ($ArmyType == 1) {$DNetLoss += (($Kills  * @UnitData[3]) / 100);}
							
					if ($NumberOfUnits == 0) {
						unlink ("$ArmyPath/$Unit");
					} else {
						open (OUT, ">$ArmyPath/$Unit") or print "Cannot open file for unit modifications (1)<BR>";
						flock (OUT, 2);
						print OUT "$NumberOfUnits\n";
					}
					$Unit =~ s/.unt$/.num/;
					open (IN, "$ArmyPath/../$Unit");
					flock (IN, 1);
					@TotalArmyNumbers = <IN>;
					close (IN);
					&chopper (@TotalArmyNumbers);
					@TotalArmyNumbers[0] -= $Kills;
					
					
					if (@TotalArmyNumbers[0] <= 0) {
						unlink ("$ArmyPath/../$Unit");
					} else {
						open (OUT, ">$ArmyPath/../$Unit") or print "Cannot open file for unit modifications (2)<BR>";
						flock (OUT, 2);					
						print OUT "@TotalArmyNumbers[0]\n";
						print OUT "@TotalArmyNumbers[1]\n";
						close (OUT);
					}
				
					#Number of Units * Generation
					if (@UnitData[0] eq "Armour") {$Points = ($NumberOfUnits * @UnitData[20] * 6);}
					if (@UnitData[0] eq "Infantry") {$Points = ($NumberOfUnits * @UnitData[20] * 3);}
			
					if ($ArmyType == 0) {$AttackerPoints += $Points;} else {$DefenderPoints += $Points;}				
				
					#Format Names -
					$ArmyName =~ tr/_/ /;
					$Kills = &Space($Kills);
					$Unit =~ tr/_/ /;
					$Unit =~ s/.num$//;
					$CasualtyScreen .= qq!$ArmyName has lost $Kills $Unit<BR><BR>!;
				}
			}
		}
	}

	open (IN, "$ArmyPath/army.txt");
	flock (IN, 1);
	@TotalArmyData = <IN>;
	close (IN);
	&chopper (@TotalArmyData);
	
	$Debug2 .= qq!Dead Soldiers - $SoldierDeaths<BR>!;
	@TotalArmyData[3] -= $SoldierDeaths;
	@TotalArmyData[5] -= $SoldierDeaths;

	open (OUT, ">$ArmyPath/army.txt");
	flock (OUT, 2);
	foreach $Item (@TotalArmyData) {
		print OUT "$Item\n";
	}
	close (OUT);
}


#Determine Power Ratings For Each Group

sub AquirePower 
{
	#Declare Variables
	my ($WarriorName, $Numbers) = @_;
	my %Damage;
	#Groups - Land, Naval, Air, Infantry, Space

	unless (-e "$UnitDir/$Warrior.unt") {
		print qq!Error Code C1 - $WarriorName.unt does not exist - Please Report<BR>!;
	} else {
		open (IN, "$UnitDir/$WarriorName.unt");
		$Debug2 .= qq!$AttackArmyType $Warrior * $Numbers Units<BR>!;
		flock (IN, 1);
		my @UnitData = <IN>;
		close (IN);
		&chopper (@UnitData);		
		if (@UnitData[10] ne "None") {
			open (IN, "$WeaponDir/@UnitData[10].wpn") or print "Cannot open @UnitData[10] for read<BR>";
			flock (IN, 1);
			@WeaponData = <IN>;
			&chopper (@WeaponData);
			@Generation = split (/ /, @WeaponData[3]);
			#Damage{To Group Type} += Mounts * Damage * Accuracy * Generation Bonus (10% per level)	* Number
			$Damage{@WeaponData[2]} += @UnitData[11] * @WeaponData[1] * @WeaponData[0] * (1 + ((@Generation[0] - 1) * 0.1)) * $Numbers;

			$Debug2 .= qq! - - Weapon Type One:@UnitData[10] - $Damage{@WeaponData[2]} += @UnitData[11] * @WeaponData[1] * @WeaponData[0] * (1 + (@Generation[0] - 1 ) * 0.1)) * $Numbers<BR>!;
			if (@WeaponData[2] eq "Ground") {$Damage{Infantry} = int(abs( ($Damage{Ground} * 0.050) )); $Damage{Ground} = int($Damage{Ground} * 0.9);}
		}

		if (@UnitData[12] ne "None") {
			open (IN, "$WeaponDir/@UnitData[12].wpn");
			flock (IN, 1);
			@WeaponData = <IN>;
			&chopper (@WeaponData);
			@Generation = split (/ /, @WeaponData[3]);
			#Damage{To Group Type} += Mounts * Damage * Accuracy * Generation Bonus (10% per level)	* Number
			$Damage{@WeaponData[2]} += @UnitData[13] * @WeaponData[1] * @WeaponData[0] * (1 + ((@Generation[0] - 1) * 0.1)) * $Numbers;

			$Debug2 .= qq! - - Weapon Type Two: @UnitData[12] - $Damage{@WeaponData[2]} += @UnitData[13] * @WeaponData[1] * @WeaponData[0] * (1 + (@Generation[0] - 1) * 0.1)) * $Numbers<BR><BR>!;
			if (@WeaponData[2] eq "Ground") {$Damage{Infantry} += int(abs( ($Damage{Ground} * 0.05) )); $Damage{Ground} += int($Damage{Ground} * 0.9);}
		}
		$Debug2 .= qq!<BR>(1 - Att : 0 - Def) --$AttackArmyType Ground $Damage{Ground} naval $Damage{Naval} Air $Damage{Air} Space $Damage{Space} Infantry $Damage{Infantry}<BR>!;

		if ($AttackArmyType == 1) {
			$AttackerPower[0] += $Damage{Ground};
			$AttackerPower[1] += $Damage{Naval};
			$AttackerPower[2] += $Damage{Air};
			$AttackerPower[3] += $Damage{Space};
			$AttackerPower[4] += $Damage{Infantry};
		} else {
			$DefenderPower[0] += $Damage{Ground};
			$DefenderPower[1] += $Damage{Naval};
			$DefenderPower[2] += $Damage{Air};
			$DefenderPower[3] += $Damage{Space};
			$DefenderPower[4] += $Damage{Infantry};
		}
	}

}


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
print MAIL "From: Attack Notification System <shatteredempires\@bluewand.com>\n";
print MAIL "Your city of $CityName in the country of $Target has fallen under attack from $User.\n";
print MAIL "http://www.bluewand.com\n";
close(MAIL);
	}
}


#Assign Attacker/Defender Armies.

sub IncludeIt {
	local ($Element) = @_;
	foreach $Item (@Files) {
		if ($Element == 1) {$Simp = "$AttackerDir/military/$Item"}
		if ($Element == 2) {$Simp = "$DefenderDir/military/$Item"}
		if (-d "$Simp" and $Item ne '.' and $Item ne '..' and $Item ne 'Pool') {

			unlink ("$Simp/army.unt");
			open (IN, "$Simp/army.txt");
			@ArmyData = <IN>;
			close (IN);
			&chopper (@ArmyData);			
			if ($Element == 1) {
				#Check to see if army can participate:  Go Code - Ready - Full Soldiers - Same Continent
				if (($Data{$Item} eq "Yes") and (@ArmyData[1] == 1) and (@ArmyData[5] >= int(0.5 * @ArmyData[3])) and (@ArmyData[6] == $CityLocation) and (@ArmyData[0] == 3) and ($ArmyData[3] > 0)) {
					$TotalCount = 0;
					opendir (DIR, "$Simp");
					@Files2 = readdir (DIR);
					closedir (DIR);

					foreach $UnitName (@Files2) {
						if ($UnitName ne "army.txt" && $UnitName ne "." && $UnitName ne "..") {
							$Number = 0;
							open (IN, "$Simp/$UnitName") or print "Cannot open $Simp/$UnitName<BR>";
							flock (IN, 1);
							$Number = <IN>;
							close (IN);
							if ($Number > 0) {
								open (IN, "$UnitDir/$UnitName");
								flock (IN, 1);
								my @UnitData = <IN>;
								close (IN);
								&chopper (@UnitData);		
								$UnitName =~ s/.unt$//;				
								$AttackerForces{$UnitName} += $Number;
								$TotalCount++;
								$TotalAttackers += $Number;


								if (@UnitData[0] eq "Infantry") {$Type = "Infantry";}
								if (@UnitData[0] eq "Armour") {$Type = "Ground";}
								if (@UnitData[0] eq "Vessel") {$Type = "Naval";}

								$AttackerForcesType{$Type} += $Number;
							}						
						}
					}
					if ($TotalCount > 0) {
						$AttackerList{$Item} = $Simp;
						$AttackerCount = 1;
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
					} else {push(@FailureList,$Item)}
				} else {push(@FailureList,$Item)}
			}
			if ($Element == 2) {	
				if ((@ArmyData[1] == 1) and ( (@ArmyData[0] <= 3) || (@ArmyData[1] <= 0 and @ArmyData[8] =~ $City)) and (@ArmyData[5] >= int(0.5 * @ArmyData[3])) and (@ArmyData[6] == $CityLocation) and (@ArmyData[3] > 0)) {
					opendir (DIR, $Simp);
					@Files2 = readdir (DIR);
					closedir (DIR);
					$TotalCount = 0;

					foreach $UnitName (@Files2) {
						if ($UnitName ne "army.txt" && $UnitName ne "." && $UnitName ne "..") {
							$Number = 0;
							open (IN, "$Simp/$UnitName");
							flock (IN, 1);
							$Number = <IN>;
							close (IN);
							if ($Number > 0) {

								open (IN, "$UnitDir/$UnitName");
								flock (IN, 1);
								my @UnitData = <IN>;
								close (IN);
								&chopper (@UnitData);	

								$UnitName =~ s/.unt$//;				
								$DefenderForces{$UnitName} += $Number;
								$TotalCount++;
								$TotalDefenders += $Number;

								if (@UnitData[0] eq "Infantry") {$Type = "Infantry";}
								if (@UnitData[0] eq "Armour") {$Type = "Ground";}
								if (@UnitData[0] eq "Vessel") {$Type = "Naval";}
								$DefenderForcesType{$Type} += $Number;

							}
						}
					}
					if ($TotalCount > 0) {
						$DefenderList{$Item} = $Simp;
						$DefenderCount++;
						push(@DefenderNames,$Item);
					}
				} else {push(@DefenderFailureList,$Item)}
			}
		}
	}
}

#Determine Defender Assistance

sub DefendersOfTheRealm {
	#File Format - Continent,Owner, Army
	open (IN, "$PlanetDir/alliances/$Alliance/Assistance");
	@AssistanceInfo = <IN>;	
	close (IN);
	&chopper (@AssistanceInfo);

	foreach $AssistingArmy (@AssistanceInfo) {
		if (substr($AssistingArmy,0,1) == $CityLocation) {
			($AlliedCont,$Owner,$Assist) = split(/,/, $AssistingArmy);
			open (IN, "$PlanetDir/$Owner/military/$Assist");
			@ArmyData = <IN>;
			close (IN);
			&chopper (@ArmyData);
			if ((@ArmyData[1] == 1) and (@ArmyData[0] == 1) and (@ArmyData[5] >= int (0.5 * @ArmyData[3])) and (@ArmyData[6] == $CityLocation)) {
				$DefenderList{$Assist} = qq!$PlanetDir/$Owner/military/$Assist!;
				$AidList{$Assist} = "$PlanetDir/$Owner";
				$DefenderCount++;
				push(@DefenderNames,$Item);
				push(@AidListing,$Assist);


				opendir (DIR, "$PlanetDir/$Owner/military/$Assist");
				@Files2 = readdir (DIR);
				closedir (DIR);
				$TotalCount = 0;

				foreach $UnitName (@Files2) {
					if ($UnitName ne "army.txt" && $UnitName ne "." && $UnitName ne "..") {
						$Number = 0;
						open (IN, "$PlanetDir/$Owner/military/$Assist/$UnitName");
						flock (IN, 1);
						$Number = <IN>;
						close (IN);
						$Number = chomp($Number);
						if ($Number > 0) {
							$UnitName =~ s/.unt$//;				
							$DefenderForces{$UnitName} += $Number;
							$TotalCount++;
						}						
					}
				}
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
#		chomp ($k);
#	}
#}
#
#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}
