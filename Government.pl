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

$UserPath = $MasterPath . "/se/Planets/$Planet/users/$User";
$SF = qq!<font FACE="Arial" size="-1">!;
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

open (DATAIN, "$UserPath/money.txt");
$money = <DATAIN>;
close (DATAIN);
chop ($money);

open (DATAIN, "$UserPath/turns.txt");
$turns = <DATAIN>;
close (DATAIN);
chop ($turns);

$money = &Space($money);

&PayCheck;

open (IN, "$UserPath/userinfo.txt");
@GovtArray = <IN>;
close (IN);
&chopper(@GovtArray);

open (IN, "$UserPath/City.txt");
@Cities = <IN>;
close (IN);
&chopper(@Cities);

if (@GovtArray[5] eq "CA" or @GovtArray[5] eq "ME" or @GovtArray[5] eq "FA") {$GovMode = 1}
if (@GovtArray[5] eq "CO") {$GovMode = 2}

&Initialize;
&AddBonus;

foreach $State (@Cities) {
	($Name,$Population,$Status,$BorderLevel,$Acceptance,$Feature,$Hospitals,$Barracks,$Agriculture,$Ag,$Commercial,$Co,$Industrial,$In,$Residential,$Re,$LandSize,$FormerOwner,$CityPlanet,$Worth,$Modern,$CityType,$Schools) = split(/\|/, $State);	$TAg += $Ag;
	$TCo += $Co;
	$TIn += $In;
	$TRe += $Re;

	$TotHosp += $Hospitals;
	$TotBarr += $Barracks;
	$TotScho += $Schools;
	$TotalPopulation += $Population;
	$TotalWork += $Jobs;
	$TotalWorth += abs(int($Worth * 0.025));
}
$TotalWorth = &Space($TotalWorth);
&Work;

if (@GovtArray[5] eq "CA" or @GovtArray[5] eq "ME" or @GovtArray[5] eq "FA") {
	if ($Mode == 1) {
		&parse_form;
		$CM = "$SF Settings have been changed.<BR>";
		open (OUT, ">$UserPath/Gov.txt");
		print OUT "$data{'Health'}\n";
		print OUT "$data{'Social'}\n";
		print OUT "$data{'Education'}\n";
		print OUT "$data{'Science'}\n";
		print OUT "$data{'Military'}\n";
		print OUT "$data{'Administration'}\n";

		print OUT "$data{'corptax'}\n";
		print OUT "$data{'personaltax'}\n";
		close (OUT);
		chmod (0777, "$UserPath/Gov.txt");

		open (OUT, ">$UserPath/Specs.txt");
		print OUT "$data{'edu'}\n";
		print OUT "$data{'hlh'}\n";
		print OUT "$data{'wlf'}\n";
		print OUT "$data{'sci'}\n";
		print OUT "$data{'mil'}\n";
		print OUT "$data{'adm'}\n";
		close (OUT);
		chmod (0777, "$UserPath/Specs.txt");
	}
	if (-e "$UserPath/Gov.txt") {
		open (IN, "$UserPath/Gov.txt");
		@Gov = <IN>;
		close (IN);
		&chopper (@Gov);
		$ProgramHealth = @Gov[0];
		$ProgramWelfare = @Gov[1];
		$ProgramEducation = @Gov[2];
		$ProgramScience = @Gov[3];
		$ProgramMilitary = @Gov[4];
		$ProgramAdministration = @Gov[5];
	}
	if (-e "$UserPath/Specs.txt") {
		open (IN, "$UserPath/Specs.txt");
		@SpecValue = <IN>;
		&chopper (@SpecValue);
		if (@SpecValue[0] == 1) {$ed = "CHECKED"}
		if (@SpecValue[1] == 1) {$hl = "CHECKED"}
		if (@SpecValue[2] == 1) {$wl = "CHECKED"}
		if (@SpecValue[3] == 1) {$sc = "CHECKED"}
		if (@SpecValue[4] == 1) {$ml = "CHECKED"}
		if (@SpecValue[5] == 1) {$ad = "CHECKED"}
	}
	&Health;
	&Welfare;
	&Education;
	&Science;
	&Military;
	print qqﬁ
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<body BGCOLOR="#000000" text="#FFFFFF">
<form method=POST action="http://www.bluewand.com/cgi-bin/classic/Government.pl?$User&$Planet&$AuthCode&1">
<table border=1 cellspacing=0 width=100%><TR><TD BGCOLOR="$Header"><CENTER><B><font FACE="Arial" size="-1">Government Settings</font></TD></TR></Table><BR>
<TABLE BORDER="1" WIDTH="100%" BORDER=1 CELLSPACING=0>
  <TR>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Current Funds:</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">\$$money</TD>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Turns Remaining:</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$turns</TD>
  </TR>
</TABLE><BR>
<CENTER>$CM<BR>

<table width=80% border=1 cellspacing=0 bgcolor="$Content">
<TR bgcolor="$Header"><TD>$SF Program Name</TD><TD>$SF Recommended Allocation</TD><TD>$SF Allocation<BR><font size=-2>(or Maximum Spending for Match Value)</TD><TD>$SF Match Value</font></TD></TR>
<TR><TD>$SF Education</TD>   <TD>$SF \$$EdTotalCost</TD><TD>$SF <input type=text name="Education" value=$ProgramEducation></TD> <TD>$SF<input type=checkbox name=edu value=1 $ed></TD></TR>
<TR><TD>$SF Health</TD>      <TD>$SF \$$TotalHealth</TD><TD>$SF <input type=text name="Health" value=$ProgramHealth></TD>       <TD>$SF<input type=checkbox name=hlh value=1 $hl></TD></TR>
<TR><TD>$SF Social</TD>      <TD>$SF \$$WelfareCost</TD><TD>$SF <input type=text name="Social" value=$ProgramWelfare></TD>	<TD>$SF<input type=checkbox name=wlf value=1 $wl></TD></TR>

<TR><TD>$SF Science</TD>      <TD>$SF \$$SciCost</TD><TD>$SF <input type=text name="Science" value="$ProgramScience"></TD>		<TD>$SF<input type=checkbox name=sci value=1 $sc></TD></TR>
<TR><TD>$SF Military</TD>      <TD>$SF \$$MilitaryCost</TD><TD>$SF <input type=text name="Military" value="$ProgramMilitary"></TD>		<TD>$SF<input type=checkbox name=mil value=1 $ml></TD></TR>
<TR><TD>$SF Administration</TD>      <TD>$SF \$$TotalWorth</TD><TD>$SF <input type=text name="Administration" value="$ProgramAdministration"></TD>		<TD>$SF<input type=checkbox name=adm value=1 $ad></TD></TR>


</table><BR>

<table width=100% border=0><TR><TD width=50%>
<Table width=100% border=1 cellspacing=0 bgcolor="$Content">
<TR bgcolor="$Header"><TD>$SF<center>Corporate Tax</TD></TR>
<TR><TD>$SF <center><input type=text value="@Gov[6]" size=5 maxlength=3 name=corptax>%</TD></TR>
</table></TD><TD width=50%>

<Table width=100% border=1 cellspacing=0 bgcolor="$Content">
<TR bgcolor="$Header"><TD>$SF<center>Personal Tax</TD></TR>
<TR><TD>$SF <center><input type=text value="@Gov[7]" size=5 maxlength=3 name=personaltax>%</TD></TR>
</table></table>
<BR>$SF<Center><input type=submit name=submit value="Change Settings"></form>
	ﬁ;
}

&Science;
if (@GovtArray[5] eq "CO") {
	if ($Mode == 1) {
		&parse_form;
		$CM = "$SF Settings have been changed.<BR>";
		open (OUT, ">$UserPath/Gov.txt");
		print OUT "$data{'Health'}\n";
		print OUT "$data{'Social'}\n";
		print OUT "$data{'Education'}\n";
		print OUT "$data{'Science'}\n";
		print OUT "$data{'Military'}\n";
		print OUT "$data{'Administration'}\n";		


		$data{'farm'} = abs(int($data{'farm'}));
		$data{'farm1'} = abs(int($data{'farm1'}));
		$data{'store'} = abs(int($data{'store'}));
		$data{'store1'} = abs(int($data{'store1'}));
		$data{'factory'} = abs(int($data{'factory'}));
		$data{'factory1'} = abs(int($data{'factory1'}));
		$data{'house'} = abs(int($data{'house'}));
		$data{'house1'} = abs(int($data{'house1'}));

		print OUT "$data{'farm'}\n";
		print OUT "$data{'store'}\n";
		print OUT "$data{'factory'}\n";
		print OUT "$data{'house'}\n";
		print OUT "$data{'farm1'}\n";
		print OUT "$data{'store1'}\n";
		print OUT "$data{'factory1'}\n";
		print OUT "$data{'house1'}\n";
		close (OUT);

		open (OUT, ">$UserPath/Specs.txt");
		print OUT "$data{'edu'}\n";
		print OUT "$data{'hlh'}\n";
		print OUT "$data{'wlf'}\n";
		print OUT "$data{'sci'}\n";
		print OUT "$data{'mil'}\n";
		print OUT "$data{'adm'}\n";
		close (OUT);
	}
	&Health;
	&Welfare;
	&Education;
	&Science;
	&Military;

if (-e "$UserPath/Gov.txt") {
	open (IN, "$UserPath/Gov.txt");
	@Infos = <IN>;
	close (IN);
	&chopper (@Infos);

	$ProgramHealth = @Infos[0];
	$ProgramWelfare = @Infos[1];
	$ProgramEducation = @Infos[2];
	$ProgramScience = @Infos[3];
	$ProgramMilitary = @Infos[4];
	$ProgramAdministration = @Infos[5];

	$F = @Infos[6];
	$C = @Infos[7];
	$I = @Infos[8];
	$R = @Infos[9];

	$F1 = @Infos[10];
	$C1 = @Infos[11];
	$I1 = @Infos[12];
	$R1 = @Infos[13];
}

if (-e "$UserPath/Specs.txt") {
	open (IN, "$UserPath/Specs.txt");
	@SpecValue = <IN>;
	&chopper (@SpecValue);
	if (@SpecValue[0] == 1) {$ed = "CHECKED"}
	if (@SpecValue[1] == 1) {$hl = "CHECKED"}
	if (@SpecValue[2] == 1) {$wl = "CHECKED"}
	if (@SpecValue[3] == 1) {$sc = "CHECKED"}
	if (@SpecValue[4] == 1) {$ml = "CHECKED"}
	if (@SpecValue[5] == 1) {$ad = "CHECKED"}
}
print qqﬁ
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<body BGCOLOR="#000000" text="#FFFFFF">

<form method=POST action="http://www.bluewand.com/cgi-bin/classic/Government.pl?$User&$Planet&$AuthCode&1"><table border=1 cellspacing=0 width=100%><TR><TD BGCOLOR="$Header"><CENTER><B><font FACE="Arial" size="-1">Government Settings</font></TD></TR></Table><BR>
<TABLE BORDER="1" WIDTH="100%" BORDER=1 CELLSPACING=0>
  <TR>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Current Funds:</FONT></TD>

    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">\$$money</TD>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Turns Remaining:</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$turns</TD>
  </TR>
</TABLE><BR>
<CENTER>$CM<BR>
<table width=80% border=1 cellspacing=0 bgcolor="$Content">
<TR bgcolor="$Header"><TD>$SF Program Name</TD><TD>$SF Recommended Allocation</TD><TD>$SF Allocation<BR><font size=-2>(or Maximum Spending for Match Value)</TD><TD>$SF Match Value</TD></TR>
<TR><TD>$SF Education</TD>   <TD>$SF \$$EdTotalCost</TD><TD>$SF <input type=text name="Education" value="$ProgramEducation"></TD> <TD>$SF<input type=checkbox name=edu value=1 $ed></TD></TR>
<TR><TD>$SF Health</TD>      <TD>$SF \$$TotalHealth</TD><TD>$SF <input type=text name="Health" value="$ProgramHealth"></TD>       <TD>$SF<input type=checkbox name=hlh value=1 $hl></TD></TR>
<TR><TD>$SF Social</TD>      <TD>$SF \$$WelfareCost</TD><TD>$SF <input type=text name="Social" value="$ProgramWelfare"></TD>	<TD>$SF<input type=checkbox name=wlf value=1 $wl></TD></TR>

<TR><TD>$SF Science</TD>      <TD>$SF \$$SciCost</TD><TD>$SF <input type=text name="Science" value="$ProgramScience"></TD>		<TD>$SF<input type=checkbox name=sci value=1 $sc></TD></TR>
<TR><TD>$SF Military</TD>      <TD>$SF \$$MilitaryCost</TD><TD>$SF <input type=text name="Military" value="$ProgramMilitary"></TD>		<TD>$SF<input type=checkbox name=mil value=1 $ml></TD></TR>
<TR><TD>$SF Administration</TD>      <TD>$SF \$$TotalWorth</TD><TD>$SF <input type=text name="Administration" value="$ProgramAdministration"></TD>		<TD>$SF<input type=checkbox name=adm value=1 $ad></TD></TR>

</table><BR>

<table width=100% border=0 cellspacing=0>
<TR><TD width=50%>
<table width=100% border=1 cellspacing=0 bgcolor="$Content">

<TR bgcolor="$Header"><TD>$SF Employee Type</TD><TD>$SF Recommended</TD><TD>$SF Wage</TD></TR>
<TR><TD>$SF Agriculture</TD> <TD>$SF \$$FWage</TD> <TD>$SF \$<input type=text name="farm" value="$F"  size=10></TD></TR
<TR><TD>$SF Commercial</TD>  <TD>$SF \$$CWage</TD> <TD>$SF \$<input type=text name="store" value="$C"  size=10></TD></TR>
<TR><TD>$SF Industrial</TD>  <TD>$SF \$$IWage</TD> <TD>$SF \$<input type=text name="factory" value="$I" size=10></TD></TR>
<TR><TD>$SF Residential</TD> <TD>$SF \$$RWage</TD> <TD>$SF \$<input type=text name="house" value="$R"  size=10></TD></TR>
</table></TD><TD width=100%>

<table width=100% border=1 cellspacing=0 bgcolor="$Content">
<TR bgcolor="$Header"><TD>$SF Land Type</TD><TD>$SF Recommended</TD><TD>$SF Expenses</TD></TR>
<TR><TD>$SF Agriculture</TD> <TD>$SF \$$FExpen</TD> <TD>$SF \$<input type=text name="farm1" value="$F1"   size=10></TD></TR>
<TR><TD>$SF Commercial</TD>  <TD>$SF \$$CExpen</TD> <TD>$SF \$<input type=text name="store1" value="$C1"  size=10></TD></TR>
<TR><TD>$SF Industrial</TD>  <TD>$SF \$$IExpen</TD> <TD>$SF \$<input type=text name="factory1" value="$I1" size=10></TD></TR>
<TR><TD>$SF Residential</TD> <TD>$SF \$$RExpen</TD> <TD>$SF \$<input type=text name="house1" value="$R1"  size=10></TD></TR>
</table>

</TD></TR></table><BR>$SF<Center><input type=submit name=submit value="Change Settings"></form>
ﬁ;
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
      $data{$name} = abs($value);
      $data{$name} =~ s/[,_ ]//g;
      if ($data{$name} < 1) {$data{$name} = 0;}
      }
}

#sub chopper{
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

sub PayCheck {
	$FWage = &Space(500);
	$CWage = &Space(1200);
	$IWage = &Space(600);
	$RWage = &Space(600);

	$FExpen=&Space(7000);
	$CExpen=&Space(120000);
	$IExpen=&Space(30000);
	$RExpen=&Space(20000)
}


sub Health {
	$Critical = int(0.01 * 15000 * $TotalPopulation/6);
	$Serious = int (0.05 * 4000 * $TotalPopulation/6);
	$Fair = int    (0.10 * 100 * $TotalPopulation/6);
	$MedCosts = $Critical + $Fair + $Serious;
	$HospitalCost = ($TotHosp * (500000 + $HospitalBonusCost)/12);
	$TotalHealth = &Space(int(($MedCosts + $HospitalCost)));
}

sub Education {
	$LearnPop = (8 + $AgeMod)/$AvgLife;
	$EdCost = ((400 + $Cost) * $TotalPopulation * $LearnPop);
	$SchoolCost = (100000 + $SchoolBonusCost) * $TotScho;
	$EdTotalCost = int($EdCost + $SchoolCost);
	$EdTotalCost = &Space($EdTotalCost);
}

sub Welfare {
	$CostofLiving = int((4800 + $LifeIncrease)/12);
	$WelfOne = ($CostofLiving * $TotalPopulation * $Unemployed);
	$WelfTwo = (($CostofLiving * 0.625) * $TotalPopulation * 0.1);
	$WelfThree = (($CostofLiving * 0.42) * $TotalPopulation * 0.05);
	$WelfareCost = int($WelfOne + $WelfTwo + $WelfThree);
	$WelfareCost = &Space($WelfareCost);
}

sub Work {
	$AgWorkers = 50;
	$CoWorkers = 100;
	$InWorkers = 150;
	$ReWorkers = 25;

	$AgrJobs = $TAg * ($AgWorkers);
	$ComJobs = $TCo * ($CoWorkers);
	$IndJobs = $TIn * ($InWorkers);
	$ResJobs = $TRe * ($ReWorkers);
	$Jobs = $AgrJobs + $ComJobs + $IndJobs + $ResJobs;
	$WorkPop = int(((50 - (8 + $AgeMod)) / $AvgLife) * $TotalPopulation);


	if ($Jobs >= $WorkPop) {$Unemployed =0} 
	else {
		$Unemployed = ($WorkPop - $Jobs)/$WorkPop;
	}
}
sub Science {
	open (IN, "$UserPath/research.txt");
	@Scientists = <IN>;
	&chopper(@Scientists);
	close (IN);

	$SciCost = (@Scientists[0] * 500000) + (@Scientists[1] * 9500000) + (@Scientists[2] * 20000000) + (@Scientists[3] * 50000000);
	$SciCost = &Space($SciCost);
}

sub Military {	opendir (DIR, "$UserPath/military");

	@Listing = readdir (DIR);
	closedir (DIR);

	foreach $Item (@Listing) {
		unless ($Item eq "." or $Item eq "..") {
			$ArmyLocate = 0;
			if (-d "$UserPath/military/$Item") {
				open (IN, "$UserPath/military/$Item/army.txt");
				@ArmyInfo = <IN>;
				close (IN);
				&chopper (@ArmyInfo);
				if (@ArmyInfo[0] == 6) {$CostMod = 2.25} else {$CostMod = 1}
				$ArmyCost += int(@ArmyInfo[2] * $CostMod); 
				@ArmyInfo[1] = 1;
				$Soldiers += @ArmyInfo[5];
			}
		}
	}
	$MilitaryCost = &Space(int($ArmyCost += ($Soldiers * 800)));
}

sub AddBonus {
	if (-e "$UserPath/research/Field Rotation.cpl") {$FoodCreated=330;$AgIn+=4000;$AgWorkers+=4;$AgWages+=50;$RealAgExpenses+=500;}
	if (-e "$UserPath/research/Basic Road.cpl") {$Cities+=2;$CoIn+=5000;$InIn+2500;}
	if (-e "$UserPath/research/Tribal Medicine.cpl") {$LifeIncrease+=1;$HospitalBonusCost+=20000;$Beds+=20;}
	if (-e "$UserPath/research/Brickworking.cpl") {$Buildbonus+=4;}
	if (-e "$UserPath/research/Basic Schooling.cpl") {$SchoolBonusCost+=5000;$Desks+=50;}
	if (-e "$UserPath/research/Agricultural Technique.cpl") {$FoodCreated=370;$AgIn+=18500;$AgWorkers+=10;$AgWages+=75;$RealAgExpenses+=1500;}
	if (-e "$UserPath/research/Scientific Process.cpl") {$SchoolBonusCost+=7000;$Desks+=25;}
	if (-e "$UserPath/research/Basic Chemistry.cpl") {$SchoolBonusCost+=1300;$Desks+=15}
	if (-e "$UserPath/research/Basic Physics.cpl") {$SchoolBonusCost+=1300;$Desks+=15;}	if (-e "$UserPath/research/Basic Biology.cpl") {$SchoolBonusCost+=1300;$HospitalBonusCost+=6000;$Beds+=10;$Desks+=15;}
	if (-e "$UserPath/research/Basic Medicine.cpl") {$HospitalBonusCost+=60000;$Beds+=50;}
	if (-e "$UserPath/research/Brick Road.cpl") {$Cities+=2;}
	if (-e "$UserPath/research/Electricity.cpl") {$AgIn+=6000;$CoIn+=12000;$InIn+=20000;$ReIn+=3000;$FoodCreated=400;$HospitalBonusCost+=40000;$Beds+=40;$AgWorkers+=2;$CoWorkers+=10;$InWorkers+=5;$ReWorkers+=2;$Desks+=20;}
	if (-e "$UserPath/research/Irrigation.cpl") {$AgIn+=12000;$FoodCreated=430;$AgWorkers+=5;$RealAgExpenses+=2000;$AgWages+=25;}
	if (-e "$UserPath/research/Manufacturing Process.cpl") {$InIn+=150000;$InWorkers+=20;$InWage+=20;$RealInExpense}
	if (-e "$UserPath/research/Cabling.cpl") {$Cities+=1;}	if (-e "$UserPath/research/Telegraph.cpl") {$CoIn+=65000;$CoWorkers+=5;$CoWages+=50;$RealCoExpenses+=13000;}
	if (-e "$UserPath/research/Alloys.cpl") {$InIn+=75000;$RealInExpenses+=25000;}
}


sub Initialize {

	$Cities = 6;
	$Buildbonus = 0;

	#Income
	$AgIn = int(25000 * 1);
	$CoIn = int(400000 * 1);
	$InIn = int(100 * 1);
	$ReIn = int(50000 * 1);
	$FoodCreated = 100;

	#Workers
	$AgWorkers = 75;
	$CoWorkers = 100;
	$InWorkers = 100;
	$ReWorkers = 75;

	$AgWages = 500;
	$CoWages = 1200;
	$InWages = 600;
	$ReWages = 600;

	if ($GovMode == 1) {
		$CorporateTax = @Govt[5];
		$PersonalTax = @Govt[6];
	}
	if ($GovMode == 2) {
		#Buildings
		$F1 = @Govt[9];
		$C1 = @Govt[10];
		$I1 = @Govt[11];
		$R1 = @Govt[12];

		#RealExpenses
		$RealAgExpense=7000;
		$RealCoExpense=120000;
		$RealInExpense=30000;
		$RealReExpense=20000;

		#Determine Effeciency Rate
		$Fef = $F1/$RealAgExpense;
		$Cef = $C1/$RealCoExpense;
		$Ief = $I1/$RealInExpense;
		$Ref = $R1/$RealReExpense;

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

