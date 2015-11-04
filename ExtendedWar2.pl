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
$UnitPath = "/home/bluewand/data/unitsdir";
$WeaponPath = "/home/bluewand/data/weapons";

$AttackMode = $data{'mode'};
if ($AttackeMode eq "") {$AttackMode = "Standard";}
########## Attacker:Defender Ratios: ##############
if ($AttackMode eq "Standard") {$WinRatio = 10;}
if ($AttackMode eq "Siege") {$WinRatio = 4;}
if ($AttackMode eq "Raid") {$WinRatio = 5;}
if ($AttackMode eq "Recovery") {$WinRatio = 6;}




@Types = (Ground,Air,Sea,Space);
$zappa = time();
srand($zappa);

$PlanetDir = $MasterPath . "/Planets/$Planet";
$AttackerDir = "$PlanetDir/users/$User";
$DefenderDir = "$PlanetDir/users/$Target";
$UnitDir = "/home/bluewand/data/unitsdir";
$NewsDir = "$PlanetDir/News";
$WeaponDir = "/home/bluewand/data/weapons";
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
$turns = <DATAIN>;
$turns = <DATAIN>;

close (DATAIN);
chop ($turns);

if ($turns < 72) {
	print "<SCRIPT>alert(\"You cannot attack until you have played 72 turns.\");history.back();</SCRIPT>";
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
DefendersOfTheRealm;

########################################################################################################################
#
#						Combat Routine
#
#########################################################################################################################

if ($AttackerCount == 1) {

	#Calculate Attacker Damage
	foreach $Warrior (keys(%AttackerForces)) {
		$AttackerPower = &AquirePower($Warrior, $AttackerForces{$Warrior}, $AttackerPower);
	}
	#Add UWG Forces If Necessary
	if ($AttackerNetPower > (1.25 * $DefenderNetPower) && $AttackHash{$Target} < 1) {
		$Send = int($AttackerNetPower - (1.25 * $DefenderNetPower));
		&WorldGovernmentIntervention($Send);
		#Set Intervention Flag to 1
		$UWGAid = 1;		
	}
	#Calculate Defender / Ally / UWG Damage
	foreach $Warrior (keys(%DefenderForces)) {
		$DefenderPower = &AquirePower($Warrior, $DefenderForces{$Warrior}, $DefenderPower);
	} 

	#Distribute Casualties
	&Casualties;
#	print "- $AttackerPoints - $DefenderPoints-<BR>";
	if ($AttackerPoints > ($DefenderPoints * $WinRatio)) {$VictoryConditions = 1;} else {$VictoryConditions = 2;}
} else {$VictoryConditions = 2;}

#print "VicCon - $VictoryConditions<BR>";
if ($VictoryConditions < 1) {$VictoryConditions = 2;}
#print "AP:", join (',', @$AttackerPower)," <BR>";
#print "DP:", join (',', @$DefenderPower)," <BR>";

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
	$TotalSize = @At[8] + @De[8];
	my $TempSize = $TempPercent = 0;
	if (@At[8] > @De[8]) {$TempSize = @At[8];} else {$TempSize = @De[8];}
	$TempPercent = ($TempSize / $TotalSize);
	
	if ($TempPercent > 0.75 && $AttackClear != 1) {
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
			&chopper(@ACity);
			open (IN, "$DefenderDir/City.txt");
			flock (IN, 1);
			@DCity = <IN>;
			close (IN);
			&chopper(@DCity);


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
			open (IN, "$DefenderDir/City.txt");
			flock (IN, 1);
			@DCity = <IN>;
			close (IN);


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
			close (IN);
			open (IN, "$DefenderDir/City.txt");
			flock (IN, 1);
			@DCity = <IN>;
			close (IN);


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
		open (OUT, ">$AttackerDir/country.txt");
		foreach $Item (@At) {
			print OUT "$Item\n";
		}
		close (OUT);
	}
}


#DisplayResults

sub Display 
{
	print qq!
<body bgcolor=black text=white>
<font face=arial>
<Table width=100% border=1 cellspacing=0 cellpadding=0><TR><TD><center><font face=arial><B>Combat Results</B></TD></TR></table>
<BR><BR><BR><center>$WarnMessage<BR>$CaptureMessage</center><BR><BR>$CasualtyScreen

	!;
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
		unless ($City eq $Name) {push (@NewCities, "$Item\n");} else {
			#City is captured
			if ($AttackMode eq "Standard" && $VictoryConditions == 1) {			
				$TurnsLeft = int((scalar(@AttackerCities)-1) * 0.2) + 1;
				$Agriculture=$Commercial=$Industrial=$Residential=0;
				push (@AttackerCities, qq!$Name|$Population|$Status|$BorderLevel|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\n!);
				$CaptureMessage = "The nation of $NiceDefender was over-run by $NiceNation.  The city of $Name has been surrendered to the attackers.";
				if ($UWGAid == 1) {$CaptureMessage .= "  United World Government forces aided in the battle, but were not enough to turn the tide against the onslaught.  UWG Miltary Spokesman Corp Mathain promised swift justice against the attackering party.\n";} else {$CaptureMessage .= "\n";}
			}
			#City Resists Attackers
			if ($AttackMode eq "Standard" && $VictoryConditions != 1) {
			 	push (@NewCities, "$Item\n");
			 	$CaptureMessage = "The nation of $NiceDefender repelled an assault conducted by $NiceNation.  The attackers were unable to capture the city of $Name.";
		 		if ($UWGAid == 1) {$CaptureMessage .="  United World Government forces participated in the successful defense, and Military Spokesman Corp Mathain pledged that the UWG would do everything in its power to deter the attacker.\n";} else {$CaptureMessage .= "\n";}		
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
	  			} else {
	  				#City stands free
	  				push (@NewCities, qq!$Name|$Population|$Status|$BorderLevel|$Acceptance|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\n!);
	  				$CaptureMessage = "The city of $Name in $NiceDefender has managed to hold off besieging attackers of $NiceNation once again.";
	  				if ($UWGAid == 1) {$CaptureMessage .= "  UWG soldiers participated in the victory.  According to UWG Spokesman Corp Mathain, the UWG would take action against the attacker.";} else {$CaptureMessage .= "\n";}
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
}






#Call Real Casualty Sub Based On Army Type

sub Casualties

{
#	print "Casualties<BR>";
#	print "Attacker Armies: ", @AttackerNames, "<BR>";
#	print "Defender Armies: ", @DefenderNames, "<BR><BR><BR>";

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

#	print "Inflict<BR>";
	my ($ArmyName, $ArmyType) = @_;
	if ($ArmyType == 0) {$ArmyPath = "$AttackerDir/military/$ArmyName";}
	if ($ArmyType == 1) {$ArmyPath = "$DefenderDir/military/$ArmyName";}
	if ($ArmyType == 2) {$ArmyPath = "$AidList{$ArmyName}/military/$ArmyName";}

	opendir (DIR, $ArmyPath);
	@ArmyFiles = readdir (DIR);
	closedir (DIR);

	
	foreach $Unit (@ArmyFiles) {
		if ($Unit eq "army.txt" || $Unit eq "." || $Unit eq "..") {} else {
			open (IN, "$ArmyPath/$Unit");
			flock (IN, 1);
			$NumberOfUnits = <IN>;
			close (IN);
			chomp ($NumberOfUnits);

			if (-e "$UnitDir/$Unit") {
				open (IN, "$UnitDir/$Unit") or print "Cannot open Unit File ($Unit)<BR>";
				flock (IN, 1);
				@UnitData = <IN>;
				close (IN);
				&chopper (@UnitData);

				if (@UnitData[0] eq "Armour") {$DamageType = "Ground";$DamageTypeNum = 0}
				if (@UnitData[0] eq "Infantry") {$DamageType = "Ground";$DamageTypeNum = 0;}

				if ($ArmyType == 0) {
					if ($AttackerForcesType{$DamageType} > 0) {
						$PercentOfDamage = $NumberOfUnits/$AttackerForcesType{$DamageType};
						$DamageInflicted = int($PercentOfDamage * @$DefenderPower[$DamageTypeNum]);
#						print qq!$DamageInflicted = int($PercentOfDamage * @$DefenderPower[$DamageTypeNum]);<BR>!;
					} else {$DamageInflicted = 0;}
				} else {
					if ($DefenderForcesType{$DamageType} > 0) {
						$PercentOfDamage = $NumberOfUnits/$DefenderForcesType{$DamageType};
						$DamageInflicted = int($PercentOfDamage * @$AttackerPower[$DamageTypeNum]);	
					} else {$DamageInflicted = 0;}
				}

				#Kills = Damage/Health
				$Kills = int($DamageInflicted/@UnitData[5]);
				if ($Kills > $NumberOfUnits) {$Kills = $NumberOfUnits;$NumberOfUnits = 0;} else {$NumberOfUnits -= $Kills;}
								
				if ($NumberOfUnits == 0) {
					unlink ("$ArmyPath/$Unit");
				} else {
					open (OUT, ">$ArmyPath/$Unit") or print "Cannot open file for unit modifications (1)<BR>";
					flock (OUT, 2);
					print OUT "$NumberOfUnits\n";
				}
				$Unit =~ s/.unt/.num/;
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
				$Unit =~ s/.num//;
				$CasualtyScreen .= qq!$ArmyName has lost $Kills $Unit<BR>!;				
			}
		}
	}
}


#UWG Assist Defender If Necessary

sub WorldGovernmentIntervention

{
	my $Commit = @_;
	#Declare Variables
	my $Troop, $Numbers;
	$Numbers = int($Commit/4);

	$UWGSoldiers{"UWG AntiArmour Infantry"} += int($Numbers/125075);
	$DefenderForces{"UWG AntiArmour Infantry"} += int($Numbers/125075);
	$TotalDefenders += int($Numbers/125075);

	$UWGSoldiers{"UWG Infantry"} += int($Numbers/124075);
	$DefenderForces{"UWG Infantry"} += int($Numbers/124075);
	$TotalDefenders += int($Numbers/124075);

	$UWGSoldiers{"UWG Armoured Enforcer"} += int($Numbers/1658500);
	$DefenderForces{"UWG Armoured Enforcer"} += int
