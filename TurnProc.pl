#!/usr/bin/perl
require 'quickies.pl'

$zappa = time();
srand($zappa);

($User,$Planet,$AuthCode, $WriteAllow)=split(/&/,$ENV{QUERY_STRING});
$PlanetDir = $MasterPath . "/se/Planets/$Planet";
$UserDir = "$PlanetDir/users/$User";

$Zha = qq!Admin_Smee!;
$User2 = "BOb";
if ($User =~ /$Zha/) {print "Content-type: text/html\n\n"}

if (-e "$UserDir/Dead.txt") {
	print "Location: http://www.bluewand.com/cgi-bin/classic/Dead.pl?$User&$Planet&$AuthCode\n\n";
	die;
}
if (-e "$UserDir/dupe.txt") {
	print "<SCRIPT>alert(\"Your nation has been locked down for security reasons.  Please contact the Bluewand team at shatteredempires\@shatteredempires.com for details.\");history.back();</SCRIPT>";
	die;
}
if (-e "$UserDir/notallowed.txt") {
	print "<SCRIPT>alert(\"Your nation has been taken off-line temporarily.  Please contact the Bluewand team for details.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}
$user_information = $MasterPath . "/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authcode{$User}) || ($AuthCode eq "")){
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
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
$NetWorth = 0;
foreach $State (@Cities) {
	($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools,$PercentLeft,$TurnsLeft) = split(/\|/, $State);
	int $Schools;
	int $Barracks;
	int $Hospitals;
	int $Population;
	int $Food;
	$TempCityCounter++;
	if ($TempCityCounter == 1) {$CapName = $Name} else {@CityName[$TempCityCounter-2] = $Name}
	$NetWorth += ( ($Hospitals * 15) + ($Barracks * 20) + ($Ag * 20) + ($Co * 40) + ($In * 50) + ($Re * 40) );
}

$User =~ tr/_/ /;
$UserName = $User;
$User =~ tr/ /_/;
&Initialize;
if ($User =~ /$Zha/) {print "a"}
&Economy;
if ($User =~ /$Zha/) {print "b"}


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
</table></center><BR>$SF<BR>ﬁ;
#<TR><TD bgcolor="$Content" colspan=2>$SF<center>Economy: $EcMess</td></TR>

foreach $State (@Cities) {
	($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools) = split(/\|/, $State);
	$TempCityCounter++;
	$TAg += abs(int($Ag));
	$TCo += abs(int($Co));
	$TIn += abs(int($In));
	$TRe += abs(int($Re));

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


$Screen .= qq!<center><Table border=1 cellspacing=0 bgcolor="$Content" width=60%><TR bgcolor="$Header"><TD>$SF Category</TD><TD align=right>$SF Required Funding</TD><TD align=right>$SF Allocated Funding</TD></TR>!;

&Work2;
if ($User =~ /$Zha/) {print "c"}
&Health;
if ($User =~ /$Zha/) {print "d"}
&Education;
if ($User =~ /$Zha/) {print "e"}
&Welfare;
if ($User =~ /$Zha/) {print "f"}
&Science;
if ($User =~ /$Zha/) {print "g"}
&Military;
if ($User =~ /$Zha/) {print "h"}
&Administer;
if ($User =~ /$Zha/) {print "i<BR>"}

$Screen .= qq!<TR bgcolor="$Header"><TD>$SF Total</TD><TD>$SF&nbsp;</TD><TD align=right>$SF \$@{[&Space($TotalCost)]}</TD>!;
$Screen2 .= "<BR>$TaxMessage";
$ResearchMsg =~ tr/_/ /;
$Screen2 .= "<BR>$ResearchMsg<Br>";
$TotalPopulation = 0;

unless ($WriteAllow == 2)
{
	open (OUT, ">$UserPath/City.txt");
	flock (OUT, 2);
}

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

	$Acceptance2 = (0.5 + ($Acceptance * 0.5));
	
	$NationMorale += $TotalMorale;
	&Smarts;
	if ($User2 =~ /$Zha/) {print "$Name - 1<BR>"}
	&Income;
	if ($User2 =~ /$Zha/) {print "$Name - 2<BR>"}
	&PopAdjuster;
	if ($User2 =~ /$Zha/) {print "$Name - 3<BR>"}
	&Food;
	if ($User2 =~ /$Zha/) {print "$Name - 4<BR>"}
	&Buildings;
	if ($User2 =~ /$Zha/) {print "$Name - 5<BR>"}

	$THealth = $Health * 0.25;
	$TLiterate = $Literate * 0.25;
	$TWelfare = $Welfare * 0.25;
	$TUnemployed = (1 - $Unemployed) * 0.25;

	if ($THealth > 0.25) {$THealth = 0.25;}
	if ($TLiterate > 0.25) {$TLiterate = 0.25;}
	if ($TWelfare > 0.25) {$TWelfare = 0.25;}
	if ($TUnemployed > 0.25) {$TUnemployed = 0.25;}

	$NewMorale = ($THealth) + ($TLiterate) + ($TWelfare) + ((1 - $Unemployed) * 0.25);
	$BuildingDecay = 1 - ((1 - $Administration) * 0.05);

	if ($BuildingDecay < 1) {
		($Ag) *= $BuildingDecay;
		($Co) *= $BuildingDecay;
		($Re) *= $BuildingDecay;
		($In) *= $BuildingDecay;
		$Ag = int($Ag);
		$Co = int($Co);
		$Re = int($Re);
		$In = int($In);
		$DecayNotice = "Buildings are being lost due to inadequate administration costs.<BR>";
	} else {$DecayNotice = "";}


	$OldPopulation = &Space($OldPopulation);
	$Populations = &Space($Population);
	$NationalIncome = &Space($NationalIncome);
	$NewFoods = &Space($NewFood);
	if ($PNationalIncome == 0) {$PNationalIncome=0}
	$PNationalIncome = &Space($PNationalIncome);
	$TotalMorale = int ($TotalMorale * 100);
	if ($TotalMorale < 0) {$TotalMorale = 0;}
	$Unemployment = int($Unemployed * 100);

	$Literates = ($Literate * 100);
	$Literates = int($Literates);

	if ($Population > 0) {
		$Food += $NewFood;
		if ($Food < 0) {$Food = 0};
	}

	$Ag = abs(int($Ag));
	$Co = abs(int($Co));
	$In = abs(int($In));
	$Re = abs(int($Re));

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
		$LandSize = int($Ag + $Co + $Re + $In);
		$Worth = int(($Ag * $AgIn) + ($Co * $CoIn) + ($Re * $ReIn) + ($In * $InIn)/100);
		$TotalLit += $Literate;
		$IndustrialZones += $In;
		if ($TurnsLeft < 0) {$TurnsLeft++;}

		unless ($WriteAllow == 2)
		{
			print OUT qqﬁ$Name|$Population|$Status|$BorderLevel|$NewMorale|$Feature|$Hospitals|$Barracks|$Agriculture|$Ag|$Commercial|$Co|$Industrial|$In|$Residential|$Re|$LandSize|$FormerOwner|$CityPlanet|$Worth|$Modern|$CityType|$Schools|$PercentLeft|$TurnsLeft\nﬁ;
		}


		$Screen2 = $Screen2."<BR>";
	} else {
		$Screen2 = $Screen2.qq!The city of $Name has been abandoned.<BR>!;
	}
}

#//////////////////////////////////////// Unit Build! ///////////////////////////////////////////////////

&Rebel;
&GoBuild;



$Screen .= qq!
<TR bgcolor="$Header"><TD>$SF Manufacturing</TD><TD>$SF&nbsp;</TD><TD align=right>$SF \$@{[&Space($UnitCost)]}</TD>
<TR bgcolor="$Header"><TD>$SF Income</TD><TD>$SF&nbsp;</TD><TD align=right>$SF \$@{[&Space($CountryIncome + $PCountryIncome)]}</TD>
<TR bgcolor="$Header"><TD>$SF Profit / Loss</TD><TD>$SF&nbsp;</TD><TD align=right>$SF \$@{[&Space($CountryIncome + $PCountryIncome - $TotalCost - $UnitCost)]}</TD>
</table></center><BR>!;


$Money += $CountryIncome + $PCountryIncome;

unless ($WriteAllow == 2)
{
	close (OUT);
}

if ($Cities2 > 0)
{
	$Morales = int(($NationMorale / $Cities2) * 100);
	if ($Morales < 1) {$Morales = 0;}
	$AvgLit = int(($TotalLit/$Cities2) * 100);
}

$Moneys = int($Money);
$Money = &Space(int($Money));
$CountryIncome = &Space($CountryIncome);
$PCountryIncome = &Space($PCountryIncome);
$Foods = &Space(int($CountryData[2]));
$Screen3 = qqﬁ
<table width=100% border=1 cellspacing=0 bgcolor="$Content">
<TR><TD bgcolor="$Header">$SF National Morale</TD><TD>$SF$Morales%</TD><TD bgcolor ="$Header">$SF Monetary Reserves</TD><TD>$SF \$$Money</TD></TR>
<TR><TD bgcolor="$Header">$SF Corporate Income</TD><TD>$SF \$$CountryIncome</TD><TD bgcolor="$Header">$SF Corporate Tax Rate</TD><TD>$SF $CorporateTax%</TD></TR>
<TR><TD bgcolor="$Header">$SF Personal Income</TD><TD>$SF \$$PCountryIncome</TD><TD bgcolor="$Header">$SF Personal Tax Rate</TD><TD>$SF $PersonalTax%</TD></TR>
<TR><TD bgcolor="$Header">$SF National Food</TD><TD>$SF $Foods</TD><TD bgcolor="$Header">$SF Average Literacy</TD><TD>$SF $AvgLit%</TD></TR>
</table><BR><BR>

$TestOTest


ﬁ;

$Morales /= 100;
if ($Morales < 0) {$Morales = 0}
if ($Morales > 1) {$Morales = 1}

unless ($WriteAllow == 2) 
{
	open (OUT, ">$UserPath/money.txt");
	flock (OUT, 2);
	print OUT "$Moneys\n";
	close (OUT);
}


$Recruits = $TotalRecruits - $ReserveSoldiers2 + $ReserveSoldiers;
$Food += $CountryData[2];
$Food = int($Food);

if ($MinDebt > 0) {$EcStrength = (int(($KeepTrack/$MinDebt) * 10000))/10000;} else {$EcStrength = 0;}


unless ($WriteAllow == 2) 
{
	open (OUT, ">$UserPath/country.txt");
	flock (OUT, 2);


	if ($Food < 0) {$Food = 0;}
	if (@CountryData[10] <= 0) {@CountryData[10] = 0;}
	$NetWorth += int(($TotalTechPoints / 10) + $TotalArmyWorth) + @CountryData[10] + int(@CountryData[1] * 0.025);


	if ($UWG eq "") {$UWG = "Accepted";}
	@CountryData[0] = $TotalPopulation;
	@CountryData[1] = $Recruits;
	@CountryData[2] = $Food;
	@CountryData[3] = $Morales;
	@CountryData[4] = $AvgLit;
	@CountryData[5] = $Economy;
	@CountryData[6] = $EcStrength;
	@CountryData[7] = $UWG;
	@CountryData[8] = $NetWorth;

#						print OUT "$TotalPopulation\n";
#						print OUT "$Recruits\n";
#						print OUT "$Food\n";
#						print OUT "$Morales\n";
#						print OUT "$AvgLit\n";
#						print OUT "$Economy\n";
#						print OUT "$EcStrength\n";
#						print OUT "$UWG\n";
#						print OUT "$NetWorth\n";
#						print OUT "@CountryData[9]\n";
#						print OUT "@CountryData[10]\n";

	foreach $WriteItem (@CountryData) {
		print OUT "$WriteItem\n";
	}
	close (OUT);

	unlink ("$UserPath/ColonyBuilt.txt");
}

if ($TotalPopulation <= 20) {
		unless ($WriteAllow == 2) 
		{
			open (OUT, ">$UserPath/Dead.txt");
			print OUT qq©<BR><BR><BR><center>Your cities stand abandoned, your towns in ruin.  You have failed your peoples, and they have fled.<BR><BR>$TotalPopulation©;
			close (OUT);
			chmod (0777, "$UserPath/Dead.txt");
		}
		print qq!Location:http://www.bluewand.com/cgi-bin/classic/Dead.pl?$User&$Planet&$AuthCode\n\n!;
		die;
}

unless ($WriteAllow == 2) 
{
	open (OUT, ">$UserPath/Life.txt");
	flock (OUT, 2);
	print OUT $AvgLife;
	close (OUT);
}

unless ($WriteAllow == 2) 
{
	if (-e "$UserPath/Retal.txt") {
		open (IN, "$UserPath/Retal.txt");
		flock (IN, 1);
		@Retal = <IN>;
		close (IN);
		&chopper (@Retal);

		foreach $Line (@Retal) {
			($AgrCountry, $TurnsToAttack) = split (/,/, $Line);
			$AttackerHash{$AgrCountry} = $TurnsToAttack;
		}
		$AttackerHash{$User}--;

		open (OUT, ">$UserPath/Retal.txt");
		flock (OUT, 2);
		while (($Key, $Value) = each(%AttackerHash)) {
			if ($Value > 0) {
				print OUT "$Key,$Value\n";
			}
		}
		close (OUT);
	}
}

print "Content-type: text/html\n\n";
print $Screen;
print $BuildMsgUnit;
print $Screen3;
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
			
					$Item =~ s/con$/unt/;
					open (IN, "$UnitPath/$Item");
					flock (IN, 1);
					@UnitData = <IN>;
					close (IN);
					&chopper (@UnitData);
		
					$BuiltUnits = int($Percent/@UnitData[2]);
					if ((@BuildData[0] - $BuiltUnits) < 0) {$BuiltUnits = @BuildData[0]}
					$UnitCost += ($BuiltUnits * @UnitData[2]);

					@BuildData[0] -= $BuiltUnits;
		
					$Item =~ s/unt$/con/;

					unless ($WriteAllow == 2) 
					{
						open (OUT, ">$UserPath/units/$Item");
						flock (OUT, 2);
						print OUT "@BuildData[0]\n";
						print OUT "@BuildData[1]\n";
						close (OUT);
					}
					&chopper (@BuildData);


					$Item =~ s/con$/num/;
					open (IN, "$UserPath/military/$Item");
					flock (IN, 1);
					@Num = <IN>;
					close (IN);

					unless ($WriteAllow == 2) 
					{
						open (OUT, ">$UserPath/military/$Item");
						flock (OUT, 2);
						@Num[0] += $BuiltUnits;
						print OUT "@Num[0]\n";
						print OUT "@Num[1]\n";
						close (OUT);
					}
			
	
					$Item =~ s/num$/unt/;
					open (IN, "$UserPath/military/Pool/$Item");
					flock (IN, 1);
					$Num2 = <IN>;
					close (IN);
		
					$Num2 += $BuiltUnits;
					unless ($WriteAllow == 2) 
					{
						open (OUT, ">$UserPath/military/Pool/$Item");
						flock (OUT, 2);
						print OUT "$Num2\n";
						close (OUT);
						chmod (0777, "$UserPath/military/Pool/$Item");
					}
	
					$Item =~ tr/_/ /;
					$Item =~ s/.unt//;
					$BuildMsgUnit .= qq!<center>$BuiltUnits $Item have been constructed.</center><BR>!;
				}
			}	
		}
	}
	$Money -= $UnitCost;
}

#//////////////////////////////////////// Military - Costs! ///////////////////////////////////////////////////

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

			$TotalArmyWorth += int(@ArmyData[3] * 13.5);

			push (@Armies, $MilItem);
			if ($Mod == 2 && @ArmyData[1] > 0)
			{
				push (@Explore, $MilItem);
			}
		} elsif (-f "$UserPath/military/$MilItem") {
			open (IN, "$UserPath/military/$MilItem");
			flock (IN, 1);
			my $Value = <IN>;
			close (IN);
			chomp ($Value);

			$MilItem =~ s/.num$/.unt/;
			open (IN, "$UnitPath/$MilItem");
			flock (IN, 1);
			my @TempItemData = <IN>;
			close (IN);
			my $UnitValue = int(($Value * @TempItemData[3]) / 100);

			$TotalArmyWorth += $UnitValue;

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
	if ($ArmyEff < 0.75) {$ArmyEff = 0.75}

	$ArmyCost = &Space($ArmyCost);
	$TempMil = &Space($TempMil);
	$Screen .= qq!<TR><TD>$SF Military</TD><TD align=right>$SF \$$ArmyCost</TD><TD align=right>$SF \$$TempMil</TD></TR>!;

#//////////////////////////////////////// Military - Status! ///////////////////////////////////////////////////



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

				if ($Number < 1)
				{
					unlink ("$UserPath/military/$Controller/$Unit");

				}

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
					$ExploreChance{$Controller} += ($ExplorePower * $Number);
				}

				unless ($WriteAllow == 2) 
				{
					open (OUT, ">$UserPath/military/$Controller/$Unit");
					print OUT "$Number\n";
					close (OUT);
				}
			}
		}
		$TotalCrew += $RequiredCrew;

		if (@ArmyData[0] == 6 && @ArmyData[1] > 0)
		{
			@ArmyData[1] = -1;
			@ArmyData[8] = "Exploring";
		}


		if (@ArmyData[1] == 0)
		{
			@ArmyData[1]++;
			@ArmyData[8] = "";
		}
		if (@ArmyData[1] < 0) {
			@ArmyData[1]++;
		}
		@ArmyData[5] = int(@ArmyData[5]);

		unless ($WriteAllow == 2) 
		{

			open (DATAOUT, ">$UserPath/military/$Controller/army.txt") or print "content-type: text/html\n\n Cannot Write $!<BR>";
			flock (DATAOUT, 2);
			print DATAOUT "@ArmyData[0]\n"; #Mode	1 - Assist 2 - Defense 3 - Ready 4 - Retaliation 5 - Transport 6 - Exploration
			print DATAOUT "@ArmyData[1]\n"; #Ready/Used 0 - Used 1 - Ready
			$RequiredCost +=  (@ArmyData[5] * 1350);
			print DATAOUT "$RequiredCost\n"; #Cost
			print DATAOUT "$RequiredCrew\n"; #Soldiers
			print DATAOUT "$RequiredTransport\n"; #Transport
			print DATAOUT "@ArmyData[5]\n"; #Total Soldiers
			print DATAOUT "@ArmyData[6]\n"; #Continent
			print DATAOUT "@ArmyData[7]\n"; #Submerged
			print DATAOUT "@ArmyData[8]\n"; #Occupying
			close (DATAOUT);
		}
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

				unless ($WriteAllow == 2) 
				{
					open (OUT, ">$UserPath/military/$ModFile");
					flock (OUT, 2);
					print OUT "@UnitNumber[0]\n";
					print OUT "@UnitNumber[1]\n";
					close (OUT);
				}
			}
		}
	}

#//////////////////////////////////////// Military - Search! ///////////////////////////////////////////////////

	if (scalar(@Explore) > 0) {
		$Screen .= "Exploring...<BR>";
		foreach $Explorer (@Explore) {
			$Flag = 0;

			open (IN, "$PlanetPath/$Planet/$ExploreContinent{$Explorer}.loc");
			flock (IN, 1);
			@CountryNames = <IN>;
			close (IN);
			&chopper (@CountryNames);

			open (IN, "$UserPath/located.txt");
			flock (IN, 1);
			@FoundCountries = <IN>;
			&chopper (@FoundCountries);
			close (IN);
			push (@FoundCountries, $User) or $Screen .= "$!<BR>";

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
			if ($FoundLand ne "") {

				unless ($WriteAllow == 2) 
				{
					open (OUT, ">>$UserPath/located.txt");
					flock (OUT, 2);
					print OUT "$FoundLand\n";
					close (OUT);
					chmod (0777, "$UserPath/located.txt");
				}
			}
		}
	}
	$Screen .= "<BR>";
}

#//////////////////////////////////////// Research - Conduct! ///////////////////////////////////////////////////

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

	if ($SciCost > 0) {$SciEff = $TempSci/$SciCost;} else {$SciEff = 0}
	if ($SciEff > 1.15) {$SciEff = 1.15}

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
			$Points = int($Points * $SciEff * $SciEff * $SciEff * @CountryData[3]);
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
					if (@TechLine[0] == 1) {
						$UnitName = @TechLine[1];
						$UnitName =~ tr/_/ /;

						unless ($WriteAllow == 2) 
						{
							open (OUT, ">$UnitPath/$UnitName.unt");
							flock (OUT, 2);
							$CounterMil = 12;
							while ($CounterMil < scalar(@TechLine)) {
								print OUT "@TechLine[$CounterMil]\n";
								$CounterMil++;
							}
							close (OUT);
							chmod (0777, "$UnitPath/$UnitName.unt");

							open (OUT, ">$UserPath/units/$UnitName.con");
							flock (OUT, 2);
							print OUT "0\n";
							print OUT "0\n";
							close (OUT);
							chmod (0777, "$UserPath/units/$UnitName.con");
						}
					}
				}
			} else {
				if (@TechLine[3] > 1) {
					push (@NewTechData, $TechItem);
				}
			}
		} else {
			if (@TechLine[3] > 1) {
				push (@NewTechData, $TechItem);
				$TotalTechPoints += @TechLine[3];
			}
		}
	}
	$ResearchMsg .= "</center>";



	unless ($WriteAllow == 2) 
	{
		unless ($WriteAllow == 2) 
		{
			open (OUT, ">$UserPath/research/TechData.tk");
			flock (OUT, 2);
			foreach $Writer (@NewTechData) {
				print  OUT "$Writer\n";
			}
			close (OUT);
			chmod (0777, "$UserPath/research/TechData.tk");
		}
	}
	$SciCost = &Space($SciCost);
	$TempSci = &Space($TempSci);
	$Screen .= qq!<TR><TD>$SF Science</TD><TD align=right>$SF \$$SciCost</TD><TD align=right>$SF \$$TempSci</TD></TR>!;
}

#//////////////////////////////////////// Adjust Population! ///////////////////////////////////////////////////

sub PopAdjuster {
	$MaxFolk = $Re * (400 + $HousingBonus);
	$PopMsg ="";
	if ( ($MaxFolk <= $Population) && ($MaxFolk > 0) ) {
		$Imigrants = 0;
		$Births = $Population * 0.045/8;
		$Deaths = $Population * 0.015/12;
		$Emigrants = ($Population * 0.0055 * (1 - $TotalMorale));

		$PopMsg = "$Name has reached maximum population levels.  Build more residential zones to increase maximum.<BR>";
	} else {
		$Births = $Population * 0.045/8;
		$Deaths = $Population * 0.015/12;

		$Imigrants =int((($MaxFolk - $Population) * 0.05) * $TotalMorale);
		$Emigrants = int($Population * 0.0055 * (1 - $TotalMorale));

		if ($User eq "$Zha") {
			print "Content-type: text/html\n\n";
			print qq!Imigrant - $Imigrants = ($Population * 0.015 * ($TotalMorale - 1))<BR>!;
		}

		$Ivar = 0.9 + rand(0.2);
		$Evar = 0.9 + rand(0.2);
		$Imigrants *= $Ivar;
		$Emigrants *= $Evar;
	}

	if ($Population - int($ConscriptionRate/100 * $Population) > 500) {
		$NewRecruits = int(($ConscriptionRate / 100) * $Population);
	}


	if ($NewRecruits < 0) {$NewRecruits = 0;}
	$TotalRecruits += $NewRecruits;
	$Population += ($Births + 1 + $Imigrants - $Deaths - $Emigrants - $NewRecruits);
	$Population = int($Population);
	if ($Population < 0) {$Population = 0;}

}

#//////////////////////////////////////// Run Food! ///////////////////////////////////////////////////

sub Food {
	$NeededFood = int($NewFood - int($Population / 10));

	if ($NeededFood < 0) { 
		if ($NeededFood <= $CountryData[2] && $TurnsLeft >= 0) {
			$CountryData[2] += $NeededFood;
			if ($Population > 0) {$Per = abs($NeededFood * 10)/$Population;} else {$Per = 0}
			$NewMorale -= ($Per);
			$WarnMsg = "Food shortages have been reported in $Name.  National food reserves have covered the shortage.<br>";
		} 
		if ($NeededFood > $CountryData[2] || $TurnsLeft < 0) {
			$NeededFood += $CountryData[2];
			$CountryData[2] = 0;
			if ($Population > 0) {$Per = abs($NeededFood * 10)/$Population;} else {$Per = 0}
			$NewMorale -= ($Per * 4);
			$ColonistsDead = int(abs($Population * 0.005));
			if ($Population - $ColonistsDead - $Emigrants < 0) {$ColonistsDead = $Population}
			$Population -= $ColonistsDead;
			$ColonistsDead = &Space($ColonistsDead);
			$WarnMsg = "$ColonistsDead people have perished due to food shortages.<br>";
			$NewFood = $NeededFood;
			if ($NewFood < 0) {$NewFood = 0;}
		}
	}
}

#//////////////////////////////////////// Set Paths! ///////////////////////////////////////////////////

sub SetPaths {
	$UserPath = $MasterPath . "/se/Planets/$Planet/users/$User";
	$UnitPath = $MasterPath . "/unitsdir";
	$PlayerLoc= $MasterPath . "/se/Planets/$Planet";
	$NewsPath = "$PlayerLoc/News";
}

#//////////////////////////////////////// Construct Buildings! ///////////////////////////////////////////////////

sub Buildings {
	$TotalBuildings = $LandSize;
	$Total = 0;
 	$CitySizePass = 0;

	if ($CityType eq "Settlement") {
		$Total = int (4 + $TechBuild * 0.5);
		$CitySizePass = 1;
		if ($LandSize >= 40)
		{
			$BuildMsg = "The Settlement of $Name has grown too large.  You must expand it if you wish to continue constructing.<BR>";
			$CitySizePass = 0;
		}
	}

	if ($CityType eq "Village") {
		$Total = int (4 + $TechBuild * 0.75);
		$CitySizePass = 1;
		if ($LandSize >= 125)
		{
			$BuildMsg = "The Village of $Name has grown too large.  You must expand it if you wish to continue constructing.<BR>";
			$CitySizePass = 0;
		}
	}

	if ($CityType eq "Town") {
		$Total = int(6 + $TechBuild * 1.0);
		$CitySizePass = 1;
		if ($LandSize >= 600)
		{
			$BuildMsg = "The Town of $Name has grown too large.  You must expand it if you wish to continue constructing.<BR>";
			$CitySizePass = 0;
		}
	}

	if ($CityType eq "City") {
		$Total = int(8 + $TechBuild * 1.25);
		$CitySizePass = 1;
		if ($LandSize >= 3000)
		{
			$BuildMsg = "The City of $Name has grown too large.  You must expand it if you wish to continue constructing.<BR>";
			$CitySizePass = 0;
		}
	}

	if ($CityType eq "Metropolis") {
		$Total = int(10 + $TechBuild * 1.50);
		$CitySizePass = 1;
		if ($LandSize >= 9000)
		{
			$BuildMsg = "The Metropolis of $Name has grown too large.  You must expand it if you wish to continue constructing.<BR>";
			$CitySizePass = 0;
		}
	}

	if ($CityType eq "Megalopolis") {
		$Total = int(12 + $TechBuild * 1.75);
		$CitySizePass = 1;
		if ($LandSize >= 20000)
		{
			$BuildMsg = "The Megalopolis of $Name has grown too large.  You must expand it if you wish to continue constructing.<BR>";
			$CitySizePass = 0;
		}
	}

	if ($CityType eq "Hub") {
		$Total = int(14 + $TechBuild * 2.0);
	}

	if ($CitySizePass == 1) {
		if (@GovtData[4] eq "DI" or @GovtData[4] eq "TH" or @GovtData[4] eq "MO") {	#Dictatorship/Theocracy
			$CountedZones=0;
			if ($Ag >= $Agriculture) {$AgBuild = 0} else {$CountedZones++;$AgBuild=1;}
			if ($Re >= $Residential) {$ReBuild = 0} else {$CountedZones++;$ReBuild=1;}
			if ($Co >= $Commercial) {$CoBuild = 0} else {$CountedZones++;$CoBuild=1;}
			if ($In >= $Industrial) {$InBuild = 0} else {$CountedZones++;$InBuild=1;}

			if ($CountedZones > 0) {$TotPerCentBuild = (1/$CountedZones);} else {$TotPerCentBuild = 0}

			$AType = ($Total * $TotPerCentBuild * $AgBuild);
			$CType = ($Total * $TotPerCentBuild * $CoBuild);
			$IType = ($Total * $TotPerCentBuild * $InBuild);
			$RType = ($Total * $TotPerCentBuild * $ReBuild);			

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
			$AType = ($Total * $Agriculture/100);
			$CType = ($Total * $Commercial/100);
			$IType = ($Total * $Industrial/100);
			$RType = ($Total * $Residential/100);
	
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

#//////////////////////////////////////// Generate Income! ///////////////////////////////////////////////////

sub Income {

	&Work;
	if (@GovtData[5] eq "CA" or @GovtData[5] eq "ME" or @GovtData[5] eq "FA") {
		if ($WorkPop > 0) {
	
			#Efficiency Rates... number of jobs to number of workers
			$Ratio = ($WorkPop/$Jobs);
		} else {$Ratio = 0;}
		if ($Ratio > 1.25) {$Ratio = 1.25;}
		if ($Ratio < 0) {$Ratio = 0;}

		$AgIncome = int($Ratio * ($AgIn - ($Ratio * $AgWages * $AgWorkers))) * $Ag;
		$AIncome = int ($CorporateTax/100 * $AgIncome * (1.15 - ($CorporateTax/100)));
		$PAIncome = int($Ratio * $AgWages * $AgWorkers * ($PersonalTax/100) * $Ag);
		
		if ($User2 =~ /$Zha2/)
		{
			print qq!Ag Income (C) - $AIncome = int ($CorporateTax/100 * $AgIncome * (1.15 - ($CorporateTax/100)))<BR>!;
			print qq!Ag Income (P) - $PAIncome = int($Ratio * $AgWages * $AgWorkers * ($PersonalTax/100) * $Ag)<BR>!;
		}

		$NewFood = (1.15 - ($CorporateTax/100)) * $Ag * $FoodCreated;

		$CoIncome = int($Ratio * ($CoIn - ($Ratio * $CoWages * $CoWorkers))) * $Co;
		$CIncome = int ($CorporateTax/100 * $CoIncome * (1.15 - ($CorporateTax/100)));
		$PCIncome = int($Ratio * $CoWages * $CoWorkers * $PersonalTax/100 * $Co);

		if ($User2 =~ /$Zha2/)
		{
			print qq!Co Income (C) - $CIncome = int ($CorporateTax/100 * ((($Ratio * ($CoIn - ($Ratio * $CoWages * $CoWorkers))) * $Co)) * (1.15 - ($CorporateTax/100)))<BR>!;
			print qq!Co Income (P) - $PCIncome = int($Ratio * $CoWages * $CoWorkers * ($PersonalTax/100) * $Co)<BR>!;
		}

		$InIncome = int($Ratio * ($InIn - ($InWages * $InWorkers))) * $In;
#		$IIncome = int (($CorporateTax/100) * $InIncome * (1.15 - ($CorporateTax/100)));
		$PIIncome = int($Ratio * $InWages * $InWorkers * ($PersonalTax/100) * $In);
		$Industry += int((1.15 - ($CorporateTax/100)) * $In);

		if ($User2 =~ /$Zha2/)
		{
			print qq!In Income (C) - $IIncome = int ($CorporateTax/100 * $InIncome * (1.15 - ($CorporateTax/100)))<BR>!;
			print qq!In Income (P) - $PIIncome = int($Ratio * $InWages * $InWorkers * ($PersonalTax/100) * $In)<BR>!;
		}

		$IndustryPoints += int((1.15 - $CorporateTax/100) * abs(30000 * $In) * 1/10);
		if ($IndustryPoints < 0) {$IndustryPoints = 0;}

		$ReIncome = int($Ratio * ($ReIn - ($Ratio * $ReWages * $ReWorkers))) * $Re;
		$PRIncome = int($Ratio * $ReWages * $ReWorkers * $PersonalTax/100 * $Re);

		if ($User2 =~ /$Zha2/)
		{
			print qq!Re Income (C) - $RIncome = int ($CorporateTax/100 * $ReIncome * (1.15 - ($CorporateTax/100)))<BR>!;
			print qq!Re Income (P) - $PRIncome = int($Ratio * $ReWages * $ReWorkers * ($PersonalTax/100) * $Re)<BR>!;
		}


		$a = (1.15 - $PersonalTax/100);

		if ($a > 0) {
			$Imigrants *= $a;
			$Emigrants /= $a;
		}

		$NationalIncome =  int(($Economy * ($AIncome + $CIncome + $IIncome) * (1+$TradeMod)) * $Acceptance2);
		$PNationalIncome = int(($Economy * ($PAIncome + $PCIncome + $PIIncome + $PRIncome)) * $Acceptance2);
		$KeepTrack += ($NationalIncome + $PNationalIncome);

		if ($User2 =~ /$Zha/)
		{
			print qq!National - $NationalIncome =  int($Economy * ($AIncome + $CIncome + $IIncome) * (1+$TradeMod))<BR>!;
			print qq!Personal - $PNationalIncome = int($Economy * ($PAIncome + $PCIncome + $PIIncome + $PRIncome))<BR>!;
			print qq!Total    - $KeepTrack += ($NationalIncome + $PNationalIncome)<BR><BR><BR>!;
		}
	}
	if (@GovtData[5] eq "CO") {
		if ($WorkPop > 0) {$Ratio = $WorkPop/$Jobs} else {$Ratio = 0}
		if ($Ratio > 1.25) {$Ratio = 1.25;}
		if ($Ratio < 0) {$Ratio = 0;}
		$AgIncome = int($Ratio * $WFef * ($AgIn - ($Ratio * $AgWages * $AgWorkers) - $F1)) * $Ag;
		$CoIncome = int($Ratio * $WCef * ($CoIn - ($Ratio * $CoWages * $CoWorkers) - $C1)) * $Co;
		$InIncome = int($Ratio * $WIef * ($InIn - ($Ratio * $InWages * $InWorkers) - $I1)) * $In;
		$ReIncome = int($Ratio * $WRef * ($ReIn - ($Ratio * $ReWages * $ReWorkers) - $R1)) * $Re;
		$IndustryPoints += (abs(30000) * 1/10) * $In;

		if ($User2 =~ /$Zha/)
		{
			print "Content-type: text/html\n\n";
			print qq!Ag Income - $AgIncome = int($Ratio * $WFef * ($AgIn - ($Ratio * $AgWages * $AgWorkers) - $F1)) * $Ag<BR>!;
			print qq!Co Income - $CoIncome = int($Ratio * $WCef * ($CoIn - ($Ratio * $CoWages * $CoWorkers) - $C1)) * $Co<BR>!;
			print qq!In Income - $InIncome = int($Ratio * $WIef * ($InIn - ($Ratio * $InWages * $InWorkers) - $I1)) * $In<BR>!;
			print qq!Re Income - $ReIncome = int($Ratio * $WRef * ($ReIn - ($Ratio * $ReWages * $ReWorkers) - $R1)) * $Re<BR><BR><BR>!;
		}

		if ($IndustryPoints < 0) {$IndustryPoints = 0;}
		$NewFood = int($Fef * $Ag * $FoodCreated);
		$NationalIncome = int($Economy * (int($AgIncome * $Fef) + int($CoIncome * $Cef) + int($InIncome * $Ief) + int($ReIncome * $Ref)));
		$NationalIncome = int($NationalIncome * (1+$TradeMod) * $Acceptance2);
		$KeepTrack += int($NationalIncome);

	}

	$CountryIncome += $NationalIncome;
	$PCountryIncome += $PNationalIncome;
}

#//////////////////////////////////////// Employment Rate! ///////////////////////////////////////////////////

sub Work {
	$AgrJobs = $Ag * ($AgWorkers);
	$ComJobs = $Co * ($CoWorkers);
	$IndJobs = $In * ($InWorkers);
	$ResJobs = $Re * ($ReWorkers);
	$Jobs = $AgrJobs + $ComJobs + $IndJobs + $ResJobs;
	if ($AvgLife < 0) {$AvgLife = 30;}
	if ($AvgLife > 70) {$AvgLife = 70;}
#	$WorkPop = int(((50 - (8 + $AgeMod)) / $AvgLife) * $Population);
	$WorkPop = int($Population * 0.60);

	if ($User2 =~ /$Zha/)
	{
		print qq!WorkingPop $WorkPop = int(((50 - (8 + $AgeMod)) / $AvgLife) * $Population) - Jobs $Jobs<BR>!;
	}
	if ($Jobs >= $WorkPop) {$Unemployed =0} else {if ($WorkPop != 0) {$Unemployed = ($WorkPop - $Jobs)/$WorkPop;} else {$Unemployed = 0;}}
}


#//////////////////////////////////////// Initialization! ///////////////////////////////////////////////////

sub Initialize {
	$Cities = 6;
	$Buildbonus = 0;
	#Income
	$AgIn = int(125000 * 1);
	$CoIn = int(1150000 * 1);	#500000
	$InIn = int(100 * 1);
	$ReIn = int(190152 * 1);	#50000
	$FoodCreated = 100;

	#Workers
	$AgWorkers = 50;
	$CoWorkers = 100;
	$InWorkers = 150;
	$ReWorkers = 25;

	#Wages
	$AgWages = 500;
	$CoWages = 1200;
	$InWages = 600;
	$ReWages = 600;

	if (@GovtData[5] eq "CA" or @GovtData[5] eq "ME" or @GovtData[5] eq "FA") {
		$CorporateTax = @Govt[6];
		$PersonalTax = @Govt[7];
		if ($CorporateTax > 100 or $CorporateTax < 0) {
			$Screen = $Screen.qq!<BR><BR><BR>$SF Corporate taxes must be within the range of 0% to 100%!;
			print "Content-type: text/html\n\n";
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
		if (($PersonalTax > 40 + $PersRand) || ($CorporateTax > 20 + $CorpRand)) {

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

			if ($PersonalTax > 45) {$UnRest = ($PersonalTax-25)/4;}
			if ($CorporateTax > 25) {$UnRest += ($CorporateTax-25)/4;}

			open (IN, "$UserPath/Unrest.txt");

			@UnRestData = <IN>;
			close (IN);
			&chopper (@UnRestData);


			@UnRestData[2] += $UnRest;


			unless ($WriteAllow == 2) 
			{
				open (OUT, ">$UserPath/Unrest.txt");
				foreach $Line (@UnRestData) {
					print OUT "$Line\n";
				}
				close (OUT);
				chmod (0777, "$UserPath/Unrest.txt");
			}

			($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
			if (length($Sec) == 1) {$Sec = "0$Sec"}
			if (length($Min) == 1) {$Min = "0$Min"}
			if (length($Hour) == 1) {$Hour = "0$Hour"}
			$Year = $Year + 1900;
			$Mon++;
			if ($User =~ /Admin/) {$Screen .= qq!$UserPath/events/!;}

			unless ($WriteAllow == 2) 
			{
				open (DATAOUT, ">$UserPath/events/$Year$Mon$Mday$Hour$Min$Sec.vnt");
				print DATAOUT "Taxation Source of Unrest in $UserName.\n";
				print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
				print DATAOUT "$Report\n";
				close (DATAOUT);
				chmod (0777, "$UserPath/events/$Year$Mon$Mday$Hour$Min$Sec.vnt");
			}

		}
	}
	if (@GovtData[5] eq "CO") {
		#Buildings
		$F1 = @Govt[10];
		$C1 = @Govt[11];
		$I1 = @Govt[12];
		$R1 = @Govt[13];

		$AgIn = int(25000 * 1);
		$CoIn = int(400000 * 1);
		$InIn = int(240000 * 1);
		$ReIn = int(70000 * 1);

		#RealExpenses
		$RealAgExpense=7000;
		$RealCoExpense=120000;
		$RealInExpense=30000;
		$RealReExpense=20000;

		$RAgWages = 350;
		$RCoWages = 500;
		$RInWages = 600;
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

		#Lower Bonusi
		if ($WFef > 1.15) {$WFef = 1.15}
		if ($WCef > 1.15) {$WCef = 1.15}
		if ($WIef > 1.15) {$WIef = 1.15}
		if ($WRef > 1.15) {$WRef = 1.15}

		#Lower Bonusii
		if ($Fef > 1.15) {$Fef = 1.15}
		if ($Cef > 1.15) {$Cef = 1.15}
		if ($Ief > 1.15) {$Ief = 1.15}
		if ($Ref > 1.15) {$Ref = 1.15}
	}
	#Health
	$HospitalBonusCost=0;
	$Beds = 50;
	open (IN, "$UserPath/Life.txt");
	$AvgLife = <IN>;
	close (IN);

	#Education
	$SchoolBonusCost=0;
	$Desks = 2000;
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

		open (OUT, ">$UserPath/turns.txt");
		flock (OUT, 2);
		print OUT "@TurnData[0]\n";
		print OUT "@TurnData[1]\n";
		print OUT "@TurnData[2]\n";
		close (OUT);
	}

	open (IN, "$UserPath/WarState.txt");
	@MinusIn = <IN>;
	close (IN);
	$MinusInc = scalar(@MinusIn);

	$TradeMod =  - (0.06 * $MinusInc);


	open (IN, "$UserPath/country.txt") or print "Content-type: text/html\n\n Problems opening file<BR>";
	flock (IN, 1);
	@CountryData=<IN>;
	close (IN);
	&chopper (@CountryData);
	$MoraleValue = @CountryData[3];
	$OldEd = @CountryData[4];
	$ReserveSoldiers = @CountryData[1];
	$UWG = @CountryData[7];

	if ($MoraleValue > 1) {$MoraleValue = 1}
	if ($MoraleValue < 0) {$MoraleValue = 0}

	open (IN, "$UserPath/City.txt");
	flock (IN, 1);
	@Cities=<IN>;
	close (IN);

	unless (scalar(@Cities) == 0 && @Cities[0] == "") {
		open (OUT, ">$UserPath/City.backup");
		flock (OUT, 2);
		print OUT @Cities;
		close (OUT);
		chmod (0777, "$UserPath/City.backup");
	}
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



#sub chopper {
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
	if ($Jobs >= $WorkPop) {$Unemployed =0} else {if ($WorkPop > 0) {$Unemployed = ($WorkPop - $Jobs)/$WorkPop;}}
}



sub Health {

	$Critical = int(0.01 * 15000 * $TotalPopulation/6);
	$Serious = int (0.05 * 4000 * $TotalPopulation/6);
	$Fair = int    (0.10 * 100 * $TotalPopulation/6);
	$MedCosts = $Critical + $Fair + $Serious;
	$HospitalCost = ($TotHosp * (500000 + $HospitalBonusCost)/12);
	$TotalHealth = int(($MedCosts + $HospitalCost));

	if (@Values[1] == 1)
	{
		$TempHealthPaid = $TotalHealth;
		if ($TempHealthPaid > $HealthPaid) {$TempHealthPaid = $HealthPaid;}
	} else
	{
		$TempHealthPaid = $HealthPaid;
	}

	if ($TempHealthPaid > $Money) {$TempHealthPaid = $Money;}
	if ($TempHealthPaid < 0) {$TempHealthPaid = 0;}



	if ($TotalHealth > 0)
	{

		my $VarOne = $Population/10000;
		my $VarTwo = $TempHealthPaid/$TotalHealth;

		if ($VarTwo > 1.15) {$VarTwo == 1.15;}
		if ($VarOne == 0) {$Health = 0;} else {$Health = ($TotHosp / ($VarOne)) * $VarTwo;}

	} else {$Health = 0;}

	if ($Health > 1.00) {$Health = 1;}
	if ($Health < 0) {$Health = 0;}

		$AvgLife = int(55/(1.1 - $Health));
		if ($AvgLife > 90) {$AvgLife = 90}
		$AvgLife += $LifeBonus;

	$Money -= int($TempHealthPaid);
	$TotalCost += $TempHealthPaid;
	$TempHealthPaid = &Space($TempHealthPaid);
	$TotalHealth = &Space($TotalHealth);

	$Screen .= qq!<TR><TD>$SF Health</TD><TD align=right>$SF \$$TotalHealth</TD><TD align=right>$SF \$$TempHealthPaid</TD></TR>!;
}

sub Factory {
	if ($TotalFactoryCost > 0) {$FactoryEff = $TempFaPaid/$TotalFactoryCost;} else {$FactoryEff = 1;}
}



sub Education {
	if ($AvgLife > 0) {$LearnPop = (8 + $AgeMod)/$AvgLife;} else {$LearnPop = (8 + $AgeMod) / 40;}
	$EdCost = ((400 + $Cost) * $TotalPopulation * $LearnPop);
	$SchoolCost = (100000 + $SchoolBonusCost) * $TotScho;
	$EdTotalCost = int($EdCost + $SchoolCost);

	if (@Values[0] == 1) 
	{
		$TempEdPaid = $EdTotalCost;
		if ($TempEdPaid > $EdPaid) {$TempEdPaid = $EdPaid}
	} else
	{
		$TempEdPaid = $EdPaid;
	}

	if ($TempEdPaid > $Money) {$TempEdPaid = $Money}
	if ($TempEdPaid < 0) {$TempEdPaid = 0}

	if ($EdTotalCost > 0) {$Educated = ($TempEdPaid/$EdTotalCost);} else {$Educated = 0;}
	if ($EdPaid > 0) {$Educated = ($TempEdPaid/$EdTotalCost);} else {$Educated = 0;}

	$Money -= int($TempEdPaid);
	$TotalCost += $TempEdPaid;
	$TempEdPaid = &Space($TempEdPaid);
	$EdTotalCost = &Space($EdTotalCost);

	$Screen .= qq!<TR><TD>$SF Education</TD><TD align=right>$SF \$$EdTotalCost</TD><TD align=right>$SF \$$TempEdPaid</TD></TR>!;
}



sub Smarts {
	$abc = $Schools * $Desks;
	$e = (8 + $AgeMod);
	$f = $e/$AvgLife;
	$g = $f * $Population;
	if ($Educated > 0)
	{

		my $VarOne = ($Population / $Desks);
		my $VarTwo = $Educated;

		if ($VarTwo > 1.15) {$VarTwo == 1.15;}
		if ($VarOne == 0) {$Literate = 0;} else {$Literate = (($Schools) / ($VarOne)) * $VarTwo;}
		if ($Literate > 1) {$Literate = 1;}
		if ($User =~ /$Zha/) {

			print qq!$VarOne = $Population / $Desks)<BR>!;
			print qq!$Literate = ($Schools) / ($VarOne) * $VarTwo<BR>!;
		}
	} else {$Literate = 0;}

	$Literate = ($Literate * $Educated * (1/4)) + (@CountryData[4]/100 * (3/4));
	if ($User =~ /$Zha/) {
		print qq!City: $Name Smarts: $Literate = ($Literate * $Educated) + (@CountryData[4]/100 * (3/4))<BR><BR><BR>!;
	}
	if ($Literate > 1) {$Literate = 1;}
	if ($Literate < 0) {$Literate = 0;}
}



sub Welfare {
	&Work;

	$CostofLiving = int((4800 + $LifeIncrease)/12);
	$WelfOne = ($CostofLiving * $TotalPopulation * $Unemployed);
	$WelfTwo = (($CostofLiving * 0.625) * $TotalPopulation * 0.1);
	$WelfThree = (($CostofLiving * 0.42) * $TotalPopulation * 0.05);
	$WelfareCost = int($WelfOne + $WelfTwo + $WelfThree);

	if (@Values[2] == 1)
	{
		$TempWelfPaid = $WelfareCost;
		if ($TempWelfPaid > $WelfPaid) {$TempWelfPaid = $WelfPaid}
	} else
	{
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
	$Screen .= qq!<TR><TD>$SF Social</TD><TD align=right>$SF \$$WelfareCost</TD><TD align=right>$SF \$$TempWelfPaid</TD></TR>!;
}



sub Administer {

	$AdministerCost = abs(int($MinDebt * 0.025));

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

	$Screen .= qq!<TR><TD>$SF Administration</TD><TD align=right>$SF \$$AdministerCost</TD><TD align=right>$SF \$$TempAdminPaid</TD></TR>!;
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
	($TechName, $Second) = @_;

	($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
	if (length($Sec) == 1) {$Sec = "0$Sec"}
	if (length($Min) == 1) {$Min = "0$Min"}
	if (length($Hour) == 1) {$Hour = "0$Hour"}
	$Mon++;

	if ($TechName eq "Atomic Detonation") {
		$Title = "$UserName detonates atomic device.";
		$Report = "Scientists in the nation of $UserName have successfully detonated an atomic device, a fearsome display of the culmination of many years research.";
		$TFlag = 1;
	}


	if ($TFlag == 1) {

		unless ($WriteAllow == 2) 
		{
			open (DATAOUT, ">$MessageDir/$Year$Mon$Mday$Hour$Min$Sec") or $Screen .= "Cannot Write News";
			print DATAOUT "$Title \n";
			print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
			print DATAOUT "$Report\n";
			close (DATAOUT);
			chmod (0777, "$MessageDir/$Year$Mon$Mday$Hour$Min$Sec");
		}
	}
}

sub Rebel {

	open (IN, "$UserPath/Unrest.txt");
	@UnRestData = <IN>;
	close (IN);
	&chopper (@UnRestData);
	if (@UnRestData[2] >= 10 and @UnRestData[0] eq "") {
		@UnRestData[0] = &NameGen;
		@UnRestData[1] = &Side;



		@TerrorLineOne[0] = qq!Increasing unrest throughout the nation of $UserName has given rise to organized terrorism, experts say.  !;
		@TerrorLineOne[1] = qq!Government security forces in $UserName have documented the appearance of a terrorist faction.  !;
		@TerrorLineOne[2] = qq!Tensions in $UserName have risen again, with the emergence of a new terrorist group.  !;
		@TerrorLineTwo[0] = qq!The @UnRestData[0], a @UnRestData[1] faction, has consolidated its power, and rapidly restructured itself.  !;
		@TerrorLineTwo[1] = qq!Though terrorism has always been a threat during the long period of unrest, it was not a major concern, until the @UnRestData[0], a small @UnRestData[1] faction began a unification campaign.  !;
		@TerrorLineTwo[2] = qq!There are few people in $UserName who have not not heard of @UnRestData[0], and that number is dropping rapidly as the @UnRestData[1] faction develops its political agenda.  !;
		@TerrorLineThree[1] = qq!"The government has shown itself to be incompetent, a complete failure to its citizens.", their manifesto states, "We shall not lay down our arms until the corruption has been purged."  !;
		@TerrorLineThree[2] = qq!"Our cause is just, the government has shown itself to be a mockery of everything this country stands for,  and this cannot be tolerated", a spokesman for @UnRestData[0] claimed.  !;
		@TerrorLineThree[0] = qq!"We shall show the citizenry of $UserName that their government is a self-serving den of thieves, unfit to lead even the smallest of villages." @UnRestData[0] declared in a statement made earlier.  !;


		@LandType[0] = "mountains";
		@LandType[1] = "hills";
		@LandType[2] = "forests";
		@LandType[3] = "wasteland";
		@LandType[4] = qq!<i>**censored**</I>!;

		@TimeODay[0] = "late last evening";
		@TimeODay[1] = "early this morning";
		@TimeODay[2] = qq!<i>**censored**</I>!;
		@TimeODay[3] = "last night";
		@TimeODay[4] = "at dawn";

		$LandTypeUsed=@LandType[int(rand(scalar(@LandType)))];
		$TimeODayUsed=@TimeODay[int(rand(scalar(@TimeODay)))];


		@TerrorLineFour[0] = qq!Government officials declined comment.!;
		@TerrorLineFour[1] = qq!Security officials of $UserName immediately initiated measures which they are confident will deal with the problem.!;
		@TerrorLineFour[2] = qq!Several military convoys were dispatched into the $LandTypeUsed $TimeODayUsed, demonstrating how seriously security officers are taking this latest threat.!;


		$TerrorReport = qq!</center><i>$CapName</i>, <b>$UserName</b><BR>!;
		$TerrorReport .= @TerrorLineOne[int(rand(2))];
		$TerrorReport .= @TerrorLineTwo[int(rand(2))];
		$TerrorReport .= @TerrorLineThree[int(rand(2))];
		$TerrorReport .= @TerrorLineFour[int(rand(2))];

		($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
	$Mon++;
	$Year += 1900;
	if (length($Sec) == 1) {$Sec = "0$Sec"}
	if (length($Min) == 1) {$Min = "0$Min"}
	if (length($Hour) == 1) {$Hour = "0$Hour"}

		unless ($WriteAllow == 2) 
		{
			open (DATAOUT, ">$MessageDir/$Year$Mon$Mday$Hour$Min$Sec");
			print DATAOUT "Terrorists in $UserName.\n";
			print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
			print DATAOUT "$TerrorReport\n";
			close (DATAOUT);
			chmod (0777, "$MessageDir/$Year$Mon$Mday$Hour$Min$Sec");
		}

		$RebelMessage .= qq!<center>A @UnRestData[1] terrorist faction, @UnRestData[0], has emerged.  Details in <i>Terrorists in $UserName</i> in news.</center><BR>!;

		unless ($WriteAllow == 2) 
		{
			open (OUT, ">$UserPath/Unrest.txt");
			foreach $Line (@UnRestData) {
				print OUT "$Line\n";
			}
			close (OUT);
		}
	}

	
	$Chance = int(rand(200));
	if ($Chance > (@UnRestData[2] - 10)) {
		if (((@UnRestData[2] - 10) >= 120) and ((@UnRestData[2] - 10) < 200)) {

			open (IN, "$UserPath/City.txt");
			@ListCities = <IN>;
			close (IN);

			$RandomCity = @ListCities[rand(scalar(@ListCities))];

			unless ($WriteAllow == 2) 
			{
				open (OUT, ">$UserPath/City.txt");
				foreach $Writer (@ListCities) {
					unless ($RandomCity eq $Writer) {
						print OUT "$Writer";
					}
				}
				close (OUT);
			}
			($CityName,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools) = split(/\|/, $RandomCity);
			@TimeODay[0] = "late last evening";
			@TimeODay[1] = "early this morning";
			@TimeODay[2] = qq!<i>**censored**</I>!;
			@TimeODay[3] = "last night";
			@TimeODay[4] = "at dawn";
			$DayTime=@TimeODay[(int(rand(scalar(@TimeODay))))];
			$OffDown = int(rand(100));
			$MoraleMod += (-1 * $OffDown);
			$OffDown = &Space($OffDown);
			($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
	
	$Mon++;
	$Year += 1900;
	if (length($Sec) == 1) {$Sec = "0$Sec"}
	if (length($Min) == 1) {$Min = "0$Min"}
	if (length($Hour) == 1) {$Hour = "0$Hour"}

			unless ($WriteAllow == 2) 
			{
				open (DATAOUT, ">$UserPath/events/$Year$Mon$Mday$Hour$Min$Sec");
				print DATAOUT "Terrorist Attack in $UserName.\n";
				print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
				print DATAOUT "The @UnRestData[1] @UnRestData[0] forces launched a suprise attack today, sacking the city of $CityName.  Government forces were unprepared for the attack, and sources in the government say casualties were heavy.   The rebel soldiers razed the city, leaving nothing but ashes behind them.\n";
				close (DATAOUT);
				chmod (0777, "$UserPath/events/$Year$Mon$Mday$Hour$Min$Sec");
			}

			$RebelMessage .= qq!<center>The terrorist faction @UnRestData[0] has razed the city of $CityName. Details in <i>Terrorist Attack in $UserName</i> in news.</center><BR>!;
			$UnRestGain -=100;
		}

		if (((@UnRestData[2] - 10) > 80) and ((@UnRestData[2] - 10) < 120)) {

			@TimeODay[0] = "late last evening";
			@TimeODay[1] = "early this morning";
			@TimeODay[2] = qq!<i>**censored**</I>!;
			@TimeODay[3] = "last night";
			@TimeODay[4] = "at dawn";
			$DayTime=@TimeODay[(int(rand(scalar(@TimeODay))))];
			$OffDown = int(rand(100));
			$MoraleMod += (-1 * $OffDown);
			$OffDown = &Space($OffDown);
			($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);

	$Mon++;
	$Year += 1900;
	if (length($Sec) == 1) {$Sec = "0$Sec"}
	if (length($Min) == 1) {$Min = "0$Min"}
	if (length($Hour) == 1) {$Hour = "0$Hour"}

			unless ($WriteAllow == 2) 
			{
				open (DATAOUT, ">$UserPath/events/$Year$Mon$Mday$Hour$Min$Sec");
				print DATAOUT "Terrorist Raid in $UserName.\n";
				print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
				print DATAOUT "In an astonishing and suprising display of strength, the @UnRestData[0], a @UnRestData[1] terrorist faction attacked a police barracks in $UserName $DayTime.  $OffDown police officers were killed in the raid, with an undisclosed number injured.  Government officials have declined comment on the attack, but surely have taken note of the growing displeasure of the citizenry towards their style of rule.\n";
				close (DATAOUT);
				chmod (0777, "$UserPath/events/$Year$Mon$Mday$Hour$Min$Sec");
			}

			$RebelMessage .= qq!<center>The terrorist faction @UnRestData[0] has conducted an attack against a police barracks.  Details in <i>Terrorist Raid in $UserName</i> in news.</center><BR>!;
			$UnRestGain -=20;
		}
		if (((@UnRestData[2] - 10) > 119) and ((@UnRestData[2] - 10) < 200)) {
			@TimeODay[0] = "late last evening";
			@TimeODay[1] = "early this morning";
			@TimeODay[2] = qq!<i>**censored**</I>!;
			@TimeODay[3] = "last night";
			@TimeODay[4] = "at dawn";
			$DayTime=@TimeODay[(int(rand(scalar(@TimeODay))))];
			$OffDown = int((rand(100))*rand(5)+1);

			if ($OffDown > $ReserveSoldiers) {$OffDown=$ReserveSoldiers}
			$Soldiers2 = &Space($OffDown);

			$ReserveSoldiers2 = $OffDown;
			($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);

	$Mon++;
	$Year += 1900;
	if (length($Sec) == 1) {$Sec = "0$Sec"}
	if (length($Min) == 1) {$Min = "0$Min"}
	if (length($Hour) == 1) {$Hour = "0$Hour"}

			unless ($WriteAllow == 2) 
			{
				open (DATAOUT, ">$UserPath/events/$Year$Mon$Mday$Hour$Min$Sec");
				print DATAOUT "Patrol Ambushed in $UserName.\n";
				print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
				print DATAOUT "The remains of an army patrol were located today near the border, the apparent victims of an ambush by @UnRestData[0].  The bodies of some $Soldiers2 soldiers have been located so far, along with unsalvagable military equipment.  While most of the soldiers appeared to have been gunned down in combat, others, especially officers and higher ranking soldiers appear to have been killed execution style.  No statements have been issued by the military or by the government.\n";
				close (DATAOUT);
				chmod (0777, "$UserPath/events/$Year$Mon$Mday$Hour$Min$Sec");
			}
			$RebelMessage .= qq!<center>The terrorist faction @UnRestData[0] has ambushed an army patrol.  Details in <i>Patrol ambushed in $UserName</i> in news.</center><BR>!;
			$UnRestGain -=40;
		}
		if (((@UnRestData[2] - 10) > 199) and ((@UnRestData[2] - 10) < 360)) {
			@TimeODay[0] = "late last evening";
			@TimeODay[1] = "early this morning";
			@TimeODay[2] = qq!<i>**censored**</I>!;
			@TimeODay[3] = "last night";
			@TimeODay[4] = "at dawn";
			$DayTime=@TimeODay[(int(rand(scalar(@TimeODay))))];
			$OffDown = int((rand(100))*rand(5)+1);

			if ($OffDown > $ReserveSoldiers) {$OffDown=$ReserveSoldiers}
			$Soldiers2 = &Space($OffDown);
			$ReserveSoldiers2 = $OffDown;
			($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);

	$Mon++;
	$Year += 1900;
	if (length($Sec) == 1) {$Sec = "0$Sec"}
	if (length($Min) == 1) {$Min = "0$Min"}
	if (length($Hour) == 1) {$Hour = "0$Hour"}

			unless ($WriteAllow == 2) 
			{
				open (DATAOUT, ">$UserPath/events/$Year$Mon$Mday$Hour$Min$Sec");
				print DATAOUT "Defection in $UserName.\n";
				print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mon\/$Mday\/$Year\n";
				print DATAOUT "The military of $UserName is in an uproar today, after a mass defection $DayTime.  $Soldiers2 soldiers defected to the @UnRestData[0], a @UnRestData[1] terrorist faction.  Equipment, weaponry and supplies hav been reported missing from several armouries.\n";
				close (DATAOUT);
				chmod (0777, "$UserPath/events/$Year$Mon$Mday$Hour$Min$Sec");
			}
			$RebelMessage .= qq!<center>The terrorist faction @UnRestData[0] has ambushed an army patrol.  Details in <i>Defection in $UserName</i> in news.</center><BR>!;
			$UnRestGain -=60;
		}
	}	
	@UnRestData[2] += $UnRestGain;


	unless ($WriteAllow == 2) 
	{
		open (OUT, ">$UserPath/Unrest.txt");
		foreach $Line (@UnRestData) {
			print OUT "$Line\n";
		}
		close (OUT);
	}
	chmod (0777, "$UserPath/Unrest.txt");
}


