#!/usr/bin/perl
require 'quickies.pl'

$zappa = time();
srand($zappa);

($User,$Planet,$AuthCode)=split(/&/,$ENV{QUERY_STRING});
$PlanetDir = $MasterPath . "/se/Planets/$Planet";
$UserDir = "$PlanetDir/users/$User";

if (-e "$UserDir/Dead.txt") {
	print "Location: http://www.bluewand.com/cgi-bin/classic/Dead.pl?$User&$Planet&$AuthCode\n\n";
	die;
}
if (-e "$UserDir/dupe.txt") {
	print "<SCRIPT>alert(\"Your nation has been locked down for security reasons.  Please contact the Bluewand Entertainment team at shattered.empires\@canada.com for details.\");history.back();</SCRIPT>";
	die;
}
if (-e "$UserDir/notallowed.txt") {
	print "<SCRIPT>alert(\"Your nation has been taken off-line temporarily.  Please contact the Bluewand Entertainment team for details.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}
$user_information = $MasterPath . "/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authcode{$User}) || ($AuthCode eq "")){
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);

$SF = qqﬁ<font face=verdana size=-1>ﬁ;
$UnitPath = $MasterPath . "/unitsdir";
$MessageDir = $MasterPath . "/se/Planets/$Planet/News";
$PlanetPath = $MasterPath . "/se/Planets";
$zappa = time();


&SetPaths;
&OpenFiles;
foreach $State (@Cities) {
	($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $State);
	int $Schools;
	int $Barracks;
	int $Hospitals;
	int $Population;
	int $Food;

	$TempCityCounter++;
	if ($TempCityCounter == 1) {$CapName = $Name} else {@CityName[$TempCityCounter-2] = $Name}
}

$User =~ tr/_/ /;
$UserName = $User;
$User =~ tr/ /_/;
&Initialize;
&Economy;

$Header = "#333333";
$HeaderFont = "#CCCCCC";
$Sub = "#999999";
$SubFont = "#000000";
$Content = "#666666";
$ContentFont = "#FFFFFF";

$Screen = $Screen.qqﬁ
<Body bgcolor=000000 text=white>
<SCRIPT>parent.frames[1].location.reload()</SCRIPT>
<table width=100% border=1 cellspacing=0><TR><TD bgcolor="$Header"><B><center>$SF End of Turn for $UserName</TD></TR></table><BR>
<center><table width=50% border=1 cellspacing=0 bgcolor="$Header"><TR><TD width=50%>$SF$Eco $Gov</TD><TD>$SF Turns Remaining: $TurnData[0]</TD></TR>
</table></center><BR>$SFﬁ;
#<TR><TD bgcolor="$Content" colspan=2>$SF<center>Economy: $EcMess</td></TR>

foreach $State (@Cities) {
	($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools) = split(/\|/, $State);
	$TempCityCounter++;
	$TAg += int($Ag);
	$TCo += int($Co);
	$TIn += int($In);
	$TRe += int($Re);

	$TotHosp += abs($Hospitals);
	$TotBarr += abs($Barracks);
	$TotScho += abs($Schools);
	$TotalPopulation += $Population;
	$TotalWork += $Jobs;

	$MinDebt += $Worth;
}
opendir (DIR, "$UserPath/messages");
@MessageFiles = readdir (DIR);
closedir (DIR);
if (scalar(@MessageFiles) > 3) {$Screen .= "<center><B>You have messages.</B><BR><BR></center>"}


$Screen .= qq!<center><Table border=1 cellspacing=0 bgcolor="$Content" width=60%><TR bgcolor="$Header"><TD>$SF Category</TD><TD>$SF Required Funding</TD><TD>$SF Allocated Funding</TD></TR>!;

&Work2;
&Health;
&Education;
&Welfare;
&Science;
&Military;
&Administer;

$TotalCost = &Space($TotalCost);
$Screen .= qq!<TR bgcolor="$Header"><TD>$SF Total</TD><TD>$SF&nbsp;</TD><TD>$SF \$$TotalCost</TD></table></center><BR>!;

$Screen .= "<BR>$TaxMessage<BR>";

$ResearchMsg =~ tr/_/ /;
$Screen .= "<BR>$ResearchMsg<Br>";

foreach $State (@Cities) {
	($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $State);
	int $Schools;
	int $Barracks;
	int $Hospitals;
	int $Population;
	int $Ag;
	int $Co;
	int $In;
	int $Re;
	$WarnMsg = "";
	$ConstructMsg = "";
	$BuildMsg = "";

	$Screen2 = $Screen2.qqﬁ<center><table width=80% border=1 cellspacing=0 bgcolor="$Content"><TR><TD bgcolor="$Header" colspan=4>$SF$Name ($CityType)</TD></TR>ﬁ;

	$OldPopulation = $Population;
	$TotalPopulation += $Population;

	$TotalMorale = ($Acceptance * 0.75) + ($MoraleValue * 0.25);
	if ($TotaleMorale < 0 ) {$TotalMorale = 0}

	if (@GovtData[5] eq "CA" or @GovtData[5] eq "ME" or @GovtData[5] eq "FA") {
		$TotalMorale -= (($CorporateTax * 1/300) + ($PersonalTax * 1/300) + ($ConscriptionRate/50));
	}
	
	$Births = $Population * 0.045/8;
	$Deaths = $Population * 0.015/12;

	$Imigrants = ($Population * 0.015) + ($Population * ($TotalMorale - 1) * 0.001 * $ComeMod);
	$Emigrants = ($Population * 0.0025) + ($Population * (1 - $TotalMorale) * 0.001 * $LeaveMod);

	$Ivar = 0.9 + rand(0.2);
	$Evar = 0.9 + rand(0.2);

	$Imigrants *= $Ivar;
	$Emigrants *= $Evar;

	$NationMorale += $TotalMorale;

	&Smarts;
	&Income;
	&PopAdjuster;
	&Food;
	&Buildings;

	$NewMorale = ($Health * 0.25) + ($Literate * 0.25) + ($Welfare * 0.25) + ((1 - $Unemployed) * 0.25);


	$BuildingDecay = 1 - ((1 - $Administration) * 0.25);

	if ($BuildingDecay < 1) {
		$Ag *= $BuildingDecay;
		$Co *= $BuildingDecay;
		$Re *= $BuildingDecay;
		$In *= $BuildingDecay;
		$DecayNotice = "Buildings are being lost due to inadequate administration costs.<BR>";
	} else {$DecayNotice = "";}


	$OldPopulation = &Space($OldPopulation);
	$Populations = &Space($Population);
	$NationalIncome = &Space($NationalIncome);
	$NewFoods = &Space($NewFood);
	if ($PNationalIncome == 0) {$PNationalIncome=0}
	$PNationalIncome = &Space($PNationalIncome);

	$TotalMorale = int ($TotalMorale * 100);
	$Unemployment = int($Unemployed * 100);

	$Literates = ($Literate * 100);
	$Literates = int($Literates);

	if ($Population > 0) {
		$Food += $NewFood;
		if ($NewFood < 0) {$NewFood = 0};
	}
	$Screen2 = $Screen2.qqﬁ
	<TR><TD>$SF Old Population</TD><TD>$SF $OldPopulation</td><TD>$SF Population</TD><TD>$SF $Populations</TD></TR>
	<TR><TD>$SF Corporate Revenue</TD><TD>$SF \$$NationalIncome</td><TD>$SF Personal Revenue</TD><TD>$SF \$$PNationalIncome</TD></TR>
	<TR><TD>$SF Agriculture</TD><TD>$SF $Ag </TD><TD>$SF Commercial</TD><TD>$SF $Co </TD>
	<TR><TD>$SF Industrial</TD><TD>$SF $In </TD><TD>$SF Residential</TD><TD>$SF $Re </TD>
	<TR><TD>$SF Unemployment</TD><TD>$SF $Unemployment%</TD><TD>$SF Morale</TD><TD>$SF $TotalMorale%</TD></TR>
	<TR><TD>$SF Food Storage</TD><TD>$SF$NewFoods</TD><TD>$SF Literacy</TD><TD>$SF $Literates%</TD><TR>
	</table>$WarnMsg$PopMsg$ConstructMsg$BuildMsg$DecayNotice<BR>ﬁ;
	if ($Population > 0) {
		$Cities2++;
		$LandSize = $Ag + $Co + $Re + $In;
		$Worth = int(($Ag * $AgIn) + ($Co * $CoIn) + ($Re * $ReIn) + ($In * $InIn)/100);
		$TotalLit += $Literate;
		$IndustrialZones += $In;
		if ($TurnsLeft < 0) {$TurnsLeft++;}
		$Screen2 = $Screen2."<BR>";
	} else {
		$Screen2 = $Screen2.qq!The city of $Name has been abandoned.<BR>!;
	}
}

#//////////////////////////////////////// Unit Build! ///////////////////////////////////////////////////

&GoBuild;
$Money += $CountryIncome + $PCountryIncome;


if ($Cities2 > 0) {
	$Morales = int(($NationMorale / $Cities2) * 100);
}

if ($Cities2 > 0) {
	$AvgLit = int(($TotalLit/$Cities2) * 100);
}

$Moneys = int($Money);
$Money = &Space(int($Money));
$CountryIncome = &Space($CountryIncome);
$PCountryIncome = &Space($PCountryIncome);
$Foods = &Space(int($CountryData[2]));
$Screen2 = $Screen2.qqﬁ
<table width=100% border=1 cellspacing=0 bgcolor="$Content">
<TR><TD bgcolor="$Header">$SF National Morale</TD><TD>$SF$Morales%</TD><TD bgcolor ="$Header">$SF Monetary Reserves</TD><TD>$SF \$$Money</TD></TR>
<TR><TD bgcolor="$Header">$SF Corporate Income</TD><TD>$SF \$$CountryIncome</TD><TD bgcolor="$Header">$SF Corporate Tax Rate</TD><TD>$SF $CorporateTax%</TD></TR>
<TR><TD bgcolor="$Header">$SF Personal Income</TD><TD>$SF \$$PCountryIncome</TD><TD bgcolor="$Header">$SF Personal Tax Rate</TD><TD>$SF $PersonalTax%</TD></TR>
<TR><TD bgcolor="$Header">$SF National Food</TD><TD>$SF $Foods</TD><TD bgcolor="$Header">$SF Average Literacy</TD><TD>$SF $AvgLit%</TD></TR>
</table>

$TestOTest


ﬁ;

$Morales /= 100;
if ($Morales < 0) {$Morales = 0}
if ($Morales < 1) {$Morales = 1}


$Recruits = $TotalRecruits - $ReserveSoldiers2 + $ReserveSoldiers;
$Food += $CountryData[2];
$Food = int($Food);

if ($MinDebt > 0) {
	$EcStrength = (int(($KeepTrack/$MinDebt) * 10000))/10000;
} else {
	$EcStrength = 0;
}

print "Content-type: text/html\n\n";
print $Screen;
print $BuildMsgUnit;
print $Screen2;

#//////////////////////////////////////// Unit Build! ///////////////////////////////////////////////////

sub GoBuild {
	opendir (DIR, "$UserPath/units");
	@Construct = readdir (DIR);
	closedir (DIR);
	$TotalProduction2 = 1;

	foreach $Item (@Construct) {
		$UnitCost = 0;
		if (-f "$UserPath/units/$Item") {
			open (IN, "$UserPath/units/$Item");
			flock (IN, 1);
			@BuildData = <IN>;
			close (IN);
			&chopper (@BuildData);

			unless (@BuildData[0] <= 0) {

				$BuildPercent = @BuildData[1]/100;
				$TotalProduction2 -= $BuildPercent;
	

				if ($TotalProduction2 >= 0) {
					$Percent = int($IndustryPoints * $BuildPercent);
			
					$Item =~ s/con/unt/;
					open (IN, "$UnitPath/$Item");
					flock (IN, 1);
					@UnitData = <IN>;
					close (IN);
					&chopper (@UnitData);
		
					$BuiltUnits = int($Percent/@UnitData[2]);
					if ((@BuildData[0] - $BuiltUnits) < 0) {$BuiltUnits = @BuildData[0]}
					$UnitCost += ($BuiltUnits * @UnitData[2]);

					@BuildData[0] -= $BuiltUnits;
		
					$Item =~ s/unt/con/;
					&chopper (@BuildData);


					$Item =~ s/con/num/;
					open (IN, "$UserPath/military/$Item");
					flock (IN, 1);
					@Num = <IN>;
					close (IN);
	
					$Item =~ s/num/unt/;
					open (IN, "$UserPath/military/Pool/$Item");
					flock (IN, 1);
					$Num2 = <IN>;
					close (IN);
		
					$Num2 += $BuiltUnits;

					$Item =~ tr/_/ /;
					$Item =~ s/.unt//;
					$BuildMsgUnit .= qq!<center>$BuiltUnits $Item have been constructed.</center><BR>!;
				}
			}	
		}
	}
	$Money -= $UnitCost;
}

sub Military {
	opendir (DIR, "$UserPath/military");
	@MilFiles = readdir(DIR);
	closedir (DIR);
	foreach $MilItem (@MilFiles) {
		if (-d "$UserPath/military/$MilItem" and $MilItem ne '.' and $MilItem ne '..') {

			open (IN, "$UserPath/military/$MilItem/army.txt");
			flock (IN, 1);
			@ArmyData = <IN>;
			close (IN);
			&chopper (@ArmyData);
			$Mod = 1;
			if (@ArmyData[0] == 6) {$Mod = 2}
			$ArmyCost += @ArmyData[2] * $Mod;

			push (@Armies, $MilItem);
			if ($Mod == 2) {push (@Explore, $MilItem)}
		}
	}
	$ArmyCost = int ($ArmyCost);
	if (@Values[4] == 1) {
		$TempMil = $ArmyCost;
		if ($TempMil > $MilPaid) {$TempMil = $MilPaid}
	} else {
		$TempMil = $MilPaid;
	}
	if ($TempMil > $Money) {$TempMil = $Money;}
	if ($TempMil < 0) {$TempMil = 0}
	$TotalCost += $TempMil;

	$Money -= $TempMil;
	if ($ArmyCost > 0) {$ArmyEff = $TempMil/$ArmyCost} else {$ArmyEff = 1}
	if ($ArmyEff > 1) {$ArmyEff = 1}
	if ($ArmyEff < 0.5) {$ArmyEff = 0.5}

	$ArmyCost = &Space($ArmyCost);
	$TempMil = &Space($TempMil);
	$Screen .= qq!<TR><TD>$SF Military</TD><TD>$SF \$$ArmyCost</TD><TD>$SF \$$TempMil</TD></TR>!;

	foreach $Controller (@Armies) {
		open (IN, "$UserPath/military/$Controller/army.txt");
		flock (IN, 1);
		@ArmyData = <IN>;
		close (IN);
		&chopper (@ArmyData);

		opendir (DIR, "$UserPath/military/$Controller");
		@Units = readdir (DIR);
		closedir (DIR);

		$ExploreContinent{$Controller} = @ArmyData[6];
		
		$RequiredCrew = 0;
		$RequiredCost = 0;
		$RequiredTransport = 0;
		foreach $Unit (@Units) {
			if ($Unit ne "army.txt") {
				open (IN, "$UserPath/military/$Controller/$Unit");
				flock (IN, 1);
				$Number = <IN>;
				close (IN);
				&chopper($Number);

				$Number *= ($ArmyEff);
				$Number = int($Number);

				open (DATAIN, "$UnitPath/$Unit");
				flock (IN, 1);
				@UnitInfo = <DATAIN>;
				close (DATAIN);
				&chopper (@UnitInfo);
				$RequiredCrew += (@UnitInfo[1] * $Number);
				$RequiredCost += (@UnitInfo[3] * $Number);
				$Size = int((@UnitInfo[15]* @UnitInfo[17] * @UnitInfo[18] * @UnitInfo[16])/34.5);
				$RequiredTransport += ($Size * $Number);

				if (@UnitInfo[0] eq "Infantry") {$ExplorePower = 0.001}
				if (@UnitInfo[0] eq "Armour") {$ExplorePower = 0.0025}
	

				if (@ArmyData[0] == 6 and @ArmyData[3] <= @ArmyData[5]) {
					$ExploreChance{$Controller} += int ($ExplorePower * $Number);
				}
			}
		}
		if (@ArmyData[1] == 0) {@ArmyData[1]++;@ArmyData[8] = ""}
		if (@ArmyData[1] < 0) {@ArmyData[1]++}
		@ArmyData[5] *= $ArmyEff;
		@ArmyData[5] = int(@ArmyData[5]);
	}

	if ($ArmyEff < 1) {
		opendir (DIR, "$UserPath/military");
		@Files = readdir (DIR);
		closedir (DIR);

		foreach $ModFile (@Files) {
			if (-f "$UserPath/military/$ModFile") {
				open (IN, "$UserPath/military/$ModFile");
				flock (IN, 1);
				@UnitNumber = <IN>;
				close (IN);
				&chopper(@UnitNumber);
	
				@UnitNumber[0] *= $ArmyEff;
				@UnitNumber[0] = int (@UnitNumber[0]);
			}
		}
	}

	if (scalar(@Explore) > 0) {
		$Screen .= "Exploring...<BR>";
		foreach $Explorer (@Explore) {
			$Flag = 0;

			open (IN, "$PlanetPath/$Planet/$ExploreContinent{$Explorer}.loc") or print "Cannot open Player Location<BR>";
			flock (IN, 1);
			@CountryNames = <IN>;
			close (IN);
			&chopper (@CountryNames);

			open (IN, "$UserPath/located.txt");
			flock (IN, 1);
			@FoundCountries = <IN>;
			&chopper (@FoundCountries);
			close (IN);
			push (@FoundCountries, $User);

			foreach $Check (@CountryNames) {
				foreach $Check2 (@FoundCountries) {
					unless ($Check2 eq "") {
						
						if (($Check2 eq $Check) or ($Flag == 2)) {$Flag = 2} else {$Flag = 1}
					}
				}
				if ($Flag == 1) {push(@ListedLands, $Check)}
				$Flag = 0;
			}
		
			$zappa = time();
			srand($zappa);

			$Explorer2 = $Explorer;
			$Explorer2 =~ tr/_/ /;
			if (rand(1) <= $ExploreChance{$Explorer}) {
				$FoundLand = @ListedLands[rand(scalar(@ListedLands))];
				$FoundLand2 = $FoundLand;
				$FoundLand2 =~ tr/_/ /;
				$Screen .= qq!$Explorer2 has found - $FoundLand2<BR>!;
			} else { 
				$Screen .= qq!$Explorer2 was unable to find anything.<BR>!;I
			}
		}
	}
	$Screen .= "<BR>";
}

sub Science {
	#New Tech Format - (Player) - Class|Name|Points|PointsRequired|Type1|Type2|Type3|Type4|Tech1|Tech2|Tech3|Tech4
	#New Tech Format - (Index)  - Class|Name|PointsRequired|Tech1|Tech2|Tech3|Tech4

	open (IN, "$UserPath/research.txt");
	flock (IN, 1);
	@Scientists = <IN>;
	&chopper(@Scientists);
	close (IN);


	$SciCost = (@Scientists[0] * 500000) + (@Scientists[1] * 9500000) + (@Scientists[2] * 20000000) + (@Scientists[3] * 50000000);


	if (@Values[3] == 1) {
		$TempSci = $SciCost;
		if ($TempSci > $SciPaid) {$TempSci = $SciPaid}
	} else {
		$TempSci = $SciPaid;
	}
	if ($TempSci > $Money) {$TempSci = $Money;}
	if ($TempSci < 0) {$TempSci = 0}
	$TotalCost += $TempSci;
	$Money -= $TempSci;

	if ($SciCost > 0) {
		$SciEff = $TempSci/$SciCost;
	} else {$SciEff = 0}
	if ($SciEff > 1.0) {$SciEff = 1.0}

	open (IN, "$UserPath/research/TechData.tk");
	flock (IN, 1);
	@TechData = <IN>;
	close (IN);
	&chopper (@TechData);
	$ResearchMsg = "<center>";
	foreach $TechItem (@TechData) {
		(@TechLine) = split(/\|/,$TechItem);
		if (@TechLine[2] < @TechLine[3]) {
			$Points = int(((@TechLine[4] * 1.0) + (@TechLine[5] * 5.0) + (@TechLine[6] * 10.0) + (@TechLine[7] * 20.0)));
			$Points = int($Points * $SciEff * $SciEff * $SciEff);
			if ($Points > 0) {
				@TechLine[2] += $Points;
#				&TechBrief(@TechLine[1]);

				$Counter = 0;
				$Lines = "";
				if (@TechLine[0] == 0) {$Max = 11}
				if (@TechLine[0] == 1) {$Max = 32}
				while ($Counter <= $Max) {
					$Lines .= $TechLine[$Counter];
					$Lines .= qq!|!;
					$Counter++;
				}
				push (@NewTechData, "$Lines");

				if (@TechLine[2] >= @TechLine[3]) {
					@TechLine[1] =~ tr/_/ /;
					$TechName = @TechLine[1];
					$ResearchMsg .= "@TechLine[1] has been researched.<BR>";
					&TechNews("$TechName");
				}
			} else {
				if (@TechLine[3] > 1) {
					push (@NewTechData, $TechItem);
				}
			}
		} else {
			if (@TechLine[3] > 1) {
				push (@NewTechData, $TechItem);
			}
		}
	}
	$ResearchMsg .= "</center>";
	$SciCost = &Space($SciCost);
	$TempSci = &Space($TempSci);
	$Screen .= qq!<TR><TD>$SF Science</TD><TD>$SF \$$SciCost</TD><TD>$SF \$$TempSci</TD></TR>!;
}


sub PopAdjuster {

	$MaxFolk = $Re * (2000 + $HousingBonus);
	$PopMsg ="";
	if ($MaxFolk <= $Population and $MaxFolk > 0) {$Imigrants *= ($MaxFolk/($Population + 1));$Births *= 0.01;$Deaths *= 1.15;$Emigrants *= 1.1;$PopMsg="$Name has reached maximum population levels.  Build more residential zones to increase maximum.<BR>"}
	$NewRecruits = int($ConscriptionRate/100*$Population);

	if ($NewRecruits < 0) {$NewRecruits = 0}
	$TotalRecruits += $NewRecruits;
	$Population += ($Births + $Imigrants - $Deaths - $Emigrants - $NewRecruits);
	$Population = int($Population);
	if ($Population < 0) {$Population = 0}

}

sub Food {
	$NeededFood = int($NewFood - int($Population / 10));

	if ($NeededFood < 0) { 
		if ($NeededFood <= $CountryData[2] && $TurnsLeft >= 0) {
			$CountryData[2] += $NeededFood;
			if ($Population > 0) {
				$Per = abs($NeededFood * 10)/$Population;
			} else {$Per = 0}
			$NewMorale -= ($Per);
			$WarnMsg = "Food shortages have been reported in $Name.  National food reserves have covered the shortage.<br>";
		} 
		if ($NeededFood > $CountryData[2] || $TurnsLeft < 0) {
			$NeededFood += $CountryData[2];
			$CountryData[2] = 0;
			if ($Population > 0) {
				$Per = abs($NeededFood * 10)/$Population;
			} else {$Per = 0}
			$NewMorale -= ($Per * 4);
			$ColonistsDead = abs($NeededFood * 10);
			if ($Population - $ColonistsDead - $Emigrants < 0) {$ColonistsDead = $Population}
			$Population -= $ColonistsDead;
			$ColonistsDead = &Space($ColonistsDead);
			$WarnMsg = "$ColonistsDead people have perished due to food shortages.<br>";
			$NewFood = $NeededFood;
		}
	}
}
sub SetPaths {
	$UserPath = $MasterPath . "/se/Planets/$Planet/users/$User";
	$UnitPath = $MasterPath . "/unitsdir";
	$PlayerLoc= $MasterPath . "/se/Planets/$Planet";
	$NewsPath = "$PlayerLoc/News";
}

sub Buildings {
	$TotalBuildings = $LandSize;
 	$CitySizePass = 1;

	if ($CityType eq "Settlement") {
		$Total = int (4 + $TechBuild * 0.5);
		if ($LandSize >= 40) {$BuildMsg = "The Settlement of $Name has grown too large.  You must expand it if you wish to continue constructing.<BR>";$CitySizePass=0;}
	} else {$CitySizePass=1}

	if ($CityType eq "Village") {
		$Total = int (4 + $TechBuild * 0.75);
		if ($LandSize >= 125) {$BuildMsg = "The Village of $Name has grown too large.  You must expand it if you wish to continue constructing.<BR>";$CitySizePass=0;}
	} else {$CitySizePass=1}

	if ($CityType eq "Town") {
		$Total = int(6 + $TechBuild * 1.0);
		if ($LandSize >= 600) {$BuildMsg = "The Town of $Name has grown too large.  You must expand it if you wish to continue constructing.<BR>";$CitySizePass=0;}
	} else {$CitySizePass=1}

	if ($CityType eq "City") {
		$Total = int(10 + $TechBuild * 1.25);
		if ($LandSize >= 3000) {$BuildMsg = "The City of $Name has grown too large.  You must expand it if you wish to continue constructing.<BR>";$CitySizePass=0;}
	} else {$CitySizePass=1}

	if ($CityType eq "Metropolis") {
		$Total = int(20 + $TechBuild * 1.50);
		if ($LandSize >= 9000) {$BuildMsg = "The Metropolis of $Name has grown too large.  You must expand it if you wish to continue constructing.<BR>";$CitySizePass=0;}
	} else {$CitySizePass=1}

	if ($CityType eq "Megalopolis") {
		$Total = int(40 + $TechBuild * 1.75);
		if ($LandSize >= 20000) {$BuildMsg = "The Megalopolis of $Name has grown too large.  You must expand it if you wish to continue constructing.<BR>";$CitySizePass=0;}
	} else {$CitySizePass=1}

	if ($CityType eq "Hub") {
		$Total = int(60 + $TechBuild * 2.0);
	}

	if ($CitySizePass == 1) {
		if (@GovtData[4] eq "DI" or @GovtData[4] eq "TH" or @GovtData[4] eq "MO") {	#Dictatorship/Theocracy
			$CountedZones=0;
			if ($Ag >= $Agriculture) {$AgBuild = 0} else {$CountedZones++;$AgBuild=1;}
			if ($Re >= $Residential) {$ReBuild = 0} else {$CountedZones++;$ReBuild=1;}
			if ($Co >= $Commercial) {$CoBuild = 0} else {$CountedZones++;$CoBuild=1;}
			if ($In >= $Industrial) {$InBuild = 0} else {$CountedZones++;$InBuild=1;}

			if ($CountedZones > 0) {
				$TotPerCentBuild = (1/$CountedZones);
			} else {$TotPerCentBuild = 0}

			$AType = int ($Total * $TotPerCentBuild * $AgBuild);
			$CType = int ($Total * $TotPerCentBuild * $CoBuild);
			$IType = int ($Total * $TotPerCentBuild * $InBuild);
			$RType = int ($Total * $TotPerCentBuild * $ReBuild);			


			if ($AType + $Ag >= $Agriculture) {$AType = ($Agriculture - $Ag)}
				if ($AType < 0) {$AType = 0}
				$Ag += $AType;
				$Money -= ($AType * $AgBuildCost);

			if ($CType + $Co >= $Commercial) {$CType = ($Commercial - $Co)}
				if ($CType < 0) {$CType = 0}
				$Co += $CType;
				$Money -= ($CType * $CoBuildCost);
	
			if ($IType + $In >= $Industrial) {$IType = ($Industrial - $In)}
				if ($IType < 0) {$IType = 0}
				$In += $IType;
				$Money -= ($IType * $InBuildCost);
	
			if ($RType + $Re >= $Residential) {$RType = ($Residential - $Re)}
				if ($RType < 0) {$RType = 0}
				$Re += $RType;
				$Money -= ($RType * $ReBuildCost);
		} 
		if (@GovtData[4] eq "DE" or @GovtData[4] eq "RE" or @GovtData[4] eq "FA") {	#Republic/Democracy
			$AType = int ($Total * $Agriculture/100);
			$CType = int ($Total * $Commercial/100);
			$IType = int ($Total * $Industrial/100);
			$RType = int ($Total * $Residential/100);
	
				$Ag += $AType;
				$Money -= ($AType * $AgBuildCost);
				$Co += $CType;
				$Money -= ($CType * $CoBuildCost);
				$In += $IType;
				$Money -= ($IType * $InBuildCost);
				$Re += $RType;
				$Money -= ($RType * $ReBuildCost);
		}
	}
}

sub Income {
	&Work;
	if (@GovtData[5] eq "CA" or @GovtData[5] eq "ME" or @GovtData[5] eq "FA") {
		if ($WorkPop > 0) {$Ratio = $Jobs/$WorkPop} else {$Ratio = 0}
		if ($Ratio > 1.25) {$Ratio = 1.25}
		$AgIncome = int($Ratio * ($AgIn - ($Ratio * $AgWages * $AgWorkers))) * $Ag;
		$AIncome = int ($CorporateTax/100 * $AgIncome);
		$PAIncome = int($Ratio * $AgWages * $AgWorkers * ($PersonalTax/100) * $Ag);

		$NewFood = (1.15 - ($CorporateTax/100)) * $Ag * $FoodCreated;

		$CoIncome = int($Ratio * ($CoIn - ($Ratio * $CoWages * $CoWorkers))) * $Co;
		$CIncome = int ($CorporateTax/100 * $CoIncome * (1.15 - ($CorporateTax/100)));
		$PCIncome = int($Ratio * $CoWages * $CoWorkers * $PersonalTax/100 * $Co);

		$InIncome = int($Ratio * ($InIn - ($InWages * $InWorkers))) * $In;
		$IIncome = int (($CorporateTax/100) * $InIncome * (1.15 - ($CorporateTax/100)));
		$PIIncome = int($Ratio * $InWages * $InWorkers * ($PersonalTax/100) * $In);
		$Industry += int((1.15 - ($CorporateTax/100)) * $In);

		$IndustryPoints += int((1.15 - $CorporateTax/100) * abs(90000 * $In) * 1/10);
		if ($IndustryPoints < 0) {$IndustryPoints=0}
	
		$ReIncome = int($Ratio * ($ReIn - ($Ratio * $ReWages * $ReWorkers))) * $Re;
		$PRIncome = int($Ratio * $ReWages * $ReWorkers * $PersonalTax/100 * $Re);
		$a = (1.15 - $PersonalTax/100);

		if ($a > 0) {
			$Imigrants *= $a;
			$Emigrants /= $a;
		}

		$NationalIncome =  int($Economy * ($AIncome + $CIncome + $IIncome) * (1+$TradeMod));
		$PNationalIncome = int($Economy * ($PAIncome + $PCIncome + $PIIncome + $PRIncome));
		$KeepTrack += ($NationalIncome + $PNationalIncome);
	}
	if (@GovtData[5] eq "CO") {
		if ($WorkPop > 0) {$Ratio = $Jobs/$WorkPop} else {$Ratio = 0}
		if ($Ratio > 1.25) {$Ratio = 1.25}
		$AgIncome = int($Ratio * $WFef * ($AgIn - ($Ratio * $AgWages * $AgWorkers) - $F1)) * $Ag;
		$CoIncome = int($Ratio * $WCef * ($CoIn - ($Ratio * $CoWages * $CoWorkers) - $C1)) * $Co;
		$InIncome = int($Ratio * $WIef * ($InIn - ($Ratio * $InWages * $InWorkers) - $I1)) * $In;
		$ReIncome = int($Ratio * $WRef * ($ReIn - ($Ratio * $ReWages * $ReWorkers) - $R1)) * $Re;
		$IndustryPoints += (abs(90000) * 1/10) * $In;

		if ($IndustryPoints < 0) {$IndustryPoints=0}

		if ($TurnsLeft == 0) {$NewFood = int($Fef * $Ag * $FoodCreated);} else {$NewFood = 0;}
		$NationalIncome = int($Economy * (int($AgIncome * $Fef) + int($CoIncome * $Cef) + int($InIncome * $Ief) + int($ReIncome * $Ref)));	
		$NationalIncome *= (1+$TradeMod);
		$KeepTrack += int($NationalIncome);

	}

	$CountryIncome += $NationalIncome;
	$PCountryIncome += $PNationalIncome;
}

sub Work {
	$AgrJobs = $Ag * ($AgWorkers);
	$ComJobs = $Co * ($CoWorkers);
	$IndJobs = $In * ($InWorkers);
	$ResJobs = $Re * ($ReWorkers);

	$Jobs = $AgrJobs + $ComJobs + $IndJobs + $ResJobs;

	if ($AvgLife < 0) {$AvgLife = 30}
	$WorkPop = int(((50 - (8 + $AgeMod)) / $AvgLife) * $Population);


	if ($Jobs >= $WorkPop) {$Unemployed =0} 
	else {
		if ($WorkPop != 0) {
			$Unemployed = ($WorkPop - $Jobs)/$WorkPop;
		} else {
			$Unemployed = 0;
		}
	}
}

sub Initialize {

	$Cities = 6;
	$Buildbonus = 0;

	#Income
	$AgIn = int(25000 * 1);
	$CoIn = int(400000 * 1);
	$InIn = int(175000 * 1);
	$ReIn = int(50000 * 1);

	$FoodCreated = 100;

	#Workers
	$AgWorkers = 26;
	$CoWorkers = 224;
	$InWorkers = 215;
	$ReWorkers = 50;


	$AgWages = 500;
	$CoWages = 1250;
	$InWages = 650;
	$ReWages = 600;

	if (@GovtData[5] eq "CA" or @GovtData[5] eq "ME" or @GovtData[5] eq "FA") {
		$CorporateTax = @Govt[6];
		$PersonalTax = @Govt[7];
		if ($CorporateTax > 100 or $CorporateTax < 0) {
			$Screen = $Screen.qq!<BR><BR><BR>$SF Corporate taxes must be within the range of 0% to 100%!;
			print $Screen;
			die;
		}
		if ($PersonalTax > 100 or $PersonalTax < 0) {
			$Screen = $Screen.qq!<BR><BR><BR>$SF Personal taxes must be within the range of 0% to 100%!;
			print "Content-type: text/html\n\n";
			print $Screen;
			die;
		}
		$PersRand = int(rand(10)+1);
		$CorpRand = int(rand(10)+1);
		if (($PersonalTax > 18 + $PersRand) || ($CorporateTax > 18 + $CorpRand)) {

			$TaxMessage = qq!<center>Citizens are protesting tax rates.  See <i>Taxation Source of Unrest in $UserName</I> in news for more detail.</center><BR>!;
			$NumberOne = int(rand(100));

			$CityUsed = @CityName[int(rand(scalar(@CityName)))];

			@LineOne[0] = qq!Crowds protesting government established tax rates gathered again today in the capital city of $CapName.  !;
			@LineOne[1] = qq!Demonstrators protesting high tax levels assembled once more in $CapName, citing the need for action on the part of the government.  !;
			@LineOne[2] = qq!Security forces briefly clashed with crowds protesting high tax rates in the capital of $Country. $NumberOne citizens were reported injured in the skimirsh, which has been denounced by activists everywhere. !;

			@LineTwo[0] = qq-"The citizens of $Country have suffered for too long under the burdern of taxation", one angry citizen declared.  "It is time for the government to act!" -;
			@LineTwo[1] = qq!"We're tired of pouring our lives into our work, only to be forced to surrender the better portion of it back to the people in charge", one citizen was quoted as saying.  !;
			@LineTwo[2] = qq!"Our nation was founded on the basis equality, and yet we, the people, are being crushed under the thumb of an oppressive government."  One activist claimed, stating "This is something prior generations never would have tolerated." !;

			@LineThree[0] = qq!Protests in the neighbouring city of $CityUsed turned violent, as demonstrators briefly skirmished against a police line.  !;
			@LineThree[1] = qq!Organized demonstrations in $CityUsed were quickly silenced, as police in riot gear dispersed the gathering crowds.  As of yet, no serious injuries have been reported.  !;
			@LineThree[2] = qq!A demonstration in $CityUsed quickly spiraled out of control, several stores and offices being damaged before the mob was brought under control.  !;

			@LineFour[0] = qq!In a statement released by the government, current tax levels were labeled as "more than fair" and "pose no threat to our citizens."!;
			@LineFour[1] = qq!Government officials refused to comment on recent events.!;
			@LineFour[2] = qq!Several high-level officials met again today to discuss the impact of high taxation, meetings which have gone on for some time already.!;

			$Report = qq!</center><i>$CapName</i>, <b>$UserName</b><BR>!;
			$Report .= @LineOne[int(rand(2))];
			$Report .= @LineTwo[int(rand(2))];
			$Report .= @LineThree[int(rand(2))];
			$Report .= @LineFour[int(rand(2))];

			if ($PersonalTax > 25) {$UnRest = ($PersonalTax-25)/4;}
			if ($CorporateTax > 25) {$UnRest += ($CorporateTax-25)/4;}

			open (IN, "$UserPath/Unrest.txt");
			@UnRestData = <IN>;
			close (IN);
			&chopper (@UnRestData);

			@UnRestData[2] += $UnRest;

			open (OUT, ">$UserPath/Unrest.txt");
			foreach $Line (@UnRestData) {
				print OUT "$Line\n";
			}
			close (OUT);

			
			
	
			($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);

			if (length($Sec) == 1) {$Sec = "0$Sec"}
			if (length($Min) == 1) {$Min = "0$Min"}
			if (length($Hour) == 1) {$Hour = "0$Hour"}

			$Mon++;
			if ($User =~ /Admin/) {$Screen .= qq!$UserPath/events/!;}
			open (DATAOUT, ">$UserPath/events/$Year$Mon$Mday$Hour$Min$Sec.vnt");
			print DATAOUT "Taxation Source of Unrest in $UserName.\n";
			print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
			print DATAOUT "$Report\n";
			close (DATAOUT);

		}
	}
	if (@GovtData[5] eq "CO") {
		#Buildings
		$F1 = @Govt[10];
		$C1 = @Govt[11];
		$I1 = @Govt[12];
		$R1 = @Govt[13];

		#RealExpenses
		$RealAgExpense=7000;
		$RealCoExpense=120000;
		$RealInExpense=35000;
		$RealReExpense=20000;

		$RAgWages = 500;
		$RCoWages = 1250;
		$RInWages = 650;
		$RReWages = 600;

		$AgWages = @Govt[6];
		$CoWages = @Govt[7];
		$InWages = @Govt[8];
		$ReWages = @Govt[9];

		#Determine Effeciency Rate
		$Fef = $F1/$RealAgExpense;
		$Cef = $C1/$RealCoExpense;
		$Ief = $I1/$RealInExpense;
		$Ref = $R1/$RealReExpense;

		#Determine Worker Efficiency Rate
		$WFef = $AgWages/$RAgWages;
		$WCef = $CoWages/$RCoWages;
		$WIef = $InWages/$RInWages;
		$WRef = $ReWages/$RReWages;

		#Lower Bonusii
		if ($Fef > 1.5) {$Fef = 1.5}
		if ($Cef > 1.5) {$Cef = 1.5}
		if ($Ief > 1.5) {$Ief = 1.5}
		if ($Ref > 1.5) {$Ref = 1.5}
	}
	#Health
	$HospitalBonusCost=0;
	$Beds = 50;
	open (IN, "$UserPath/Life.txt");
	$AvgLife = <IN>;
	close (IN);

	#Education
	$SchoolBonusCost=0;
	$Desks = 50;
	$AgeMod=0;

	#Economy
	$LifeIncrease=0;
}
	
sub Economy {
	$Value = -2 + int(rand(5));
	$Economy = ((@CountryData[5] * 100)+ $Value)/100;
	if ($Economy < .8) {$Economy = 0.8}
	if ($Economy > 1.25) {$Economy = 1.25}

	$EcMess = "Depression";
	if ($Economy > 0.85) {$EcMess = "Strong Recession"}
	if ($Economy > 0.90) {$EcMess = "Moderate Recession"}
	if ($Economy > 1.00) {$EcMess = "Light Recession"}
	if ($Economy > 1.10) {$EcMess = "Light Boom"}
	if ($Economy > 1.15) {$EcMess = "Moderate Boom"}
	if ($Economy > 1.20) {$EcMess = "Strong Boom"}
}




sub OpenFiles {
	unless (-e "$UserPath/Gov.txt") {
		print "Content-type: text/html\n\n";
		print qq!<SCRIPT>alert("You have not yet set your government funding levels.  You must do this before you are able to process a turn.");history.back();</SCRIPT>!;
		die;
	}
	$MainResearchPath = $MasterPath . "/research";
	open (IN, "$UserPath/turns.txt");
	flock (IN, 2);
	@TurnData = <IN>;
	close (IN);
	&chopper (@TurnData);


	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	@TimeUntil = split(/\./,@TurnData[2]);
	$Days = $yday - @TimeUntil[0];
	$Hours = $hour - @TimeUntil[1];
	$TotalTurns += ($Days * 24) + $Hours;
	

	@TurnData[0] += $TotalTurns;
	if (@TurnData[0] > 60) {@TurnData[0] = 60}
	if ($Planet =~ /SystemFour/) {@TurnData[0]++;}
	@TurnData[2] = "$yday.$hour";

	open (IN, "$UserPath/WarState.txt");		
	@MinusIn = <IN>;
	close (IN);
	$MinusInc = scalar(@MinusIn);

	$TradeMod =  - (0.06 * $MinusInc);
	
	open (IN, "$UserPath/country.txt") or print "Problems opening file<BR>";
	flock (IN, 1);
	@CountryData=<IN>;
	close (IN);
	&chopper (@CountryData);
	$MoraleValue = @CountryData[3];
	$OldEd = @CountryData[4];
	$ReserveSoldiers = @CountryData[1];

	if ($MoraleValue > 1) {$MoraleValue = 0}
	if ($MoraleValue < 0) {$MoraleValue = 0}

	open (IN, "$UserPath/City.txt");
	flock (IN, 1);
	@Cities=<IN>;
	close (IN);
	&chopper (@Cities);

	open (IN, "$UserPath/money.txt");
	flock (IN, 1);
	$Money = <IN>;
	close (IN);
	chop($Money);

	open (IN, "$UserPath/userinfo.txt");
	flock (IN, 1);
	@GovtData = <IN>;
	close (IN);
	&chopper(@GovtData);
	&DisplayType;

	open (IN, "$UserPath/Gov.txt");
	flock (IN, 1);
	@Govt = <IN>;
	close (IN);
	&chopper(@Govt);

	$HealthPaid = @Govt[0];
	$WelfPaid = @Govt[1];
	$EdPaid = @Govt[2];
	$MilPaid = @Govt[4];
	$SciPaid = @Govt[3];
	$AdminPaid = @Govt[5];

	open (DATAIN, "$UserPath/military.txt");
	flock (DATAIN, 1);
	@Defense = <DATAIN>;
	close (DATAIN);
	&chopper (@Defense);
	$ConscriptionRate = @Defense[2];

	open (IN, "$UserPath/Specs.txt");
	flock (IN, 1);
	@Values = <IN>;
	close (IN);
	&chopper (@Values);
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




sub Work2 {
	$AgrJobs = $TAg * ($AgWorkers);
	$ComJobs = $TCo * ($CoWorkers);
	$IndJobs = $TIn * ($InWorkers);
	$ResJobs = $TRe * ($ReWorkers);

	$Jobs = $AgrJobs + $ComJobs + $IndJobs + $ResJobs;

	if ($AvgLife < 1) {$AvgLife = 30}
	$WorkPop = int(((50 - (8 + $AgeMod)) / $AvgLife) * $TotalPopulation);


	if ($Jobs >= $WorkPop) {$Unemployed =0} 
	else {
		if ($WorkPop > 0) {
			$Unemployed = ($WorkPop - $Jobs)/$WorkPop;
		}
	}
}

sub Health {
	$Critical = int(0.01 * 15000 * $TotalPopulation/12);
	$Serious = int (0.05 * 4000 * $TotalPopulation/12);
	$Fair = int    (0.10 * 100 * $TotalPopulation/12);
	$MedCosts = $Critical + $Fair + $Serious;
	$HospitalCost = ($TotHosp * (500000 + $HospitalBonusCost)/12);
	$TotalHealth = int(($MedCosts + $HospitalCost));

	if (@Values[1] == 1) {
		$TempHealthPaid = $TotalHealth;
		if ($TempHealthPaid > $HealthPaid) {$TempHealthPaid = $HealthPaid}
	} else {
		$TempHealthPaid = $HealthPaid;
	}
	if ($TempHealthPaid > $Money) {$TempHealthPaid = $Money}
	if ($TempHealthPaid < 0) {$TempHealthPaid = 0}

	$Health = (($TotHosp * 70 * 1000)/$Population) * ($TempHealthPaid/$TotalHealth);
	if ($Health > 1.00) {$Health = 1}

	$AvgLife = int(55/(1.1 - $Health));
	if ($AvgLife > 90) {$AvgLife = 90}
	$AvgLife += $LifeBonus;

	$Money -= int($TempHealthPaid);
	$TotalCost += $TempHealthPaid;
	$TempHealthPaid = &Space($TempHealthPaid);
	$TotalHealth = &Space($TotalHealth);

	$Screen .= qq!<TR><TD>$SF Health</TD><TD>$SF \$$TotalHealth</TD><TD>$SF \$$TempHealthPaid</TD></TR>!;
}

sub Factory {
	$FactoryEff = $TempFaPaid/$TotalFactoryCost;
}

sub Education {
	$LearnPop = (8 + $AgeMod)/$AvgLife;
	$EdCost = ((400 + $Cost) * $TotalPopulation * $LearnPop)/12;
	$SchoolCost = (100000 + $SchoolBonusCost) * $TotScho;
	$EdTotalCost = int($EdCost + $SchoolCost);

	if (@Values[0] == 1) {
		$TempEdPaid = $EdTotalCost;
		if ($TempEdPaid > $EdPaid) {$TempEdPaid = $EdPaid}
	} else {
		$TempEdPaid = $EdPaid;
	}
	if ($TempEdPaid > $Money) {$TempEdPaid = $Money}
	if ($TempEdPaid < 0) {$TempEdPaid = 0}

	if ($EdTotalCost > 0) {
		$Educated = ($TempEdPaid/$EdTotalCost);
	} else {$Educated = 0}
	$Money -= int($TempEdPaid);
	$TotalCost += $TempEdPaid;
	$TempEdPaid = &Space($TempEdPaid);
	$EdTotalCost = &Space($EdTotalCost);

	$Screen .= qq!<TR><TD>$SF Education</TD><TD>$SF \$$EdTotalCost</TD><TD>$SF \$$TempEdPaid</TD></TR>!;
}

sub Smarts {
	$abc = $Schools * $Desks;
	$e = (8 + $AgeMod);
	$f = $e/$AvgLife;
	$g = $f * $Population;


	$LearnRatio = $abc/$g;
	$Literate = ((($Schools * 500)/$g) * $Educated * (1/4)) + ($LearnRatio*(3/4));
	if ($Literate > 1) {$Literate = 1}
	if ($Literate < 0) {$Literate = 0}
}

sub Welfare {
	&Work;
	$CostofLiving = int((4800 + $LifeIncrease)/12);
	$WelfOne = ($CostofLiving * $TotalPopulation * $Unemployed);
	$WelfTwo = (($CostofLiving * 0.625) * $TotalPopulation * 0.1);
	$WelfThree = (($CostofLiving * 0.42) * $TotalPopulation * 0.05);
	$WelfareCost = int($WelfOne + $WelfTwo + $WelfThree);

	if (@Values[2] == 1) {
		$TempWelfPaid = $WelfareCost;
		if ($TempWelfPaid > $WelfPaid) {$TempWelfPaid = $WelfPaid}
	} else {
		$TempWelfPaid = $WelfPaid;
	}
	if ($TempWelfPaid > $Money) {$TempWelfPaid = $Money}
	if ($TempWelfPaid < 0) {$TempWelfPaid = 0}

	if ($WelfareCost > 0) {
		$Welfare = $TempWelfPaid/$WelfareCost;
	} else {$Welfare = 0}
	if ($Welfare > 1.00) {$Welfare = 1.00}
	$TotalCost += $TempWelfPaid;
	$Money -= int($TempWelfPaid);

	$TempWelfPaid = &Space($TempWelfPaid);
	$WelfareCost = &Space($WelfareCost);
	$Screen .= qq!<TR><TD>$SF Social</TD><TD>$SF \$$WelfareCost</TD><TD>$SF \$$TempWelfPaid</TD></TR>!;
}

sub Administer {
	$AdministerCost = abs(int($MinDebt * 0.10));

	if (@Values[5] == 1) {
		$TempAdminPaid = $AdministerCost;
		if ($TempAdminPaid > $AdminPaid) {$TempAdminPaid = $AdminPaid}
	} else {
		$TempAdminPaid = $AdminPaid;
	}
	if ($TempAdminPaid > $Money) {$TempAdminPaid = $Money}
	if ($TempAdminPaid < 0) {$TempAdminPaid = 0}

	if ($AdministerCost > 0) {
		$Administration = $TempAdminPaid/$AdministerCost;
	} else {$Administration = 0}
	if ($Administration > 1.00) {$Administration = 1.00}
	$Money -= int($TempAdminPaid);

	$TotalCost += $TempAdminPaid;
	$TempAdminPaid = &Space($TempAdminPaid);
	$AdministerCost = &Space($AdministerCost);

	$Screen .= qq!<TR><TD>$SF Administration</TD><TD>$SF \$$AdministerCost</TD><TD>$SF \$$TempAdminPaid</TD></TR>!;
}



sub DisplayType {
	if (@GovtData[4] eq "DE") {$Gov = "Democracy"}
	if (@GovtData[4] eq "DI") {$Gov = "Dictatorship"}
	if (@GovtData[4] eq "TH") {$Gov = "Theocracy"}
	if (@GovtData[4] eq "MO") {$Gov = "Monarchy"}
	if (@GovtData[4] eq "RE") {$Gov = "Republic"}

	if (@GovtData[5] eq "CA") {$Eco = "Capitalist"}
	if (@GovtData[5] eq "FA") {$Eco = "Fascist"}
	if (@GovtData[5] eq "ME") {$Eco = "Mercantalist"}
	if (@GovtData[5] eq "CO") {$Eco = "Socialist"}
}

sub Side {
	if (@GovtData[5] eq "CA") {return("right-wing")}
	if (@GovtData[5] eq "FA") {return("left-wing")}
	if (@GovtData[5] eq "ME") {return("left-wing")}
	if (@GovtData[5] eq "CO") {return("right-wing")}
}

sub NameGen {
	@Firstname[0] = "Black";
	@Firstname[1] = "Red";
	@Firstname[2] = "Green";
	@Firstname[3] = "Silver";
	@Firstname[4] = "Golden";
	@Firstname[5] = "Bengaley's";
	@Firstname[6] = "Gleaming";
	@Firstname[7] = "Mutest's";
	@Firstname[8] = "Angry";
	@Firstname[9] = "Dread";
	@Firstname[10] = "Death";
	@Firstname[11] = "Holy";
	@Firstname[12] = "Dark";
	@Firstname[13] = "Furry";
	@Firstname[14] = "Unholy";

	@Secondname[0] = " Knights";
	@Secondname[1] = " Sceptre";
	@Secondname[2] = " Crown";
	@Secondname[3] = " Shield";
	@Secondname[4] = " Might";
	@Secondname[5] = " Chaos";
	@Secondname[6] = " Army";
	@Secondname[7] = " Defenders";
	@Secondname[8] = " Path";
	@Secondname[9] = " Scourge";
	@Secondname[10] = " Daemons";
	@Secondname[11] = " Soldiers";
	@Secondname[12] = " Society";
	@Secondname[13] = " Faith";
	@Secondname[14] = " Resistance";

	$StringToSend = @Firstname[int(rand(scalar(@Firstname)))];
	srand();
	$StringToSend .= @Secondname[int(rand(scalar(@Secondname)))];
	return($StringToSend);
}


sub TechNews {
}
