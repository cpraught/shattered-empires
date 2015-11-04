#!/usr/bin/perl
require 'quickies.pl'

&parse_form;

$data{'handle'} =~ tr/ /_/;

$user_information = $MasterPath . "/User\ Information";
$userpath=$MasterPath . "/se/Planets/$data{'planet'}/users/";
$PlainPath=$MasterPath . "/se/Planets/$data{'planet'}";

$zappa = time();
srand($zappa);

chdir ($MasterPath . "/");
if ($data{'planet'} eq "none") {
	print "Content-type: text/html\n\n";
	print qqﬁ<script>alert("You must select a planet to play on.");history.back();</script>ﬁ;
	die;
}

if ($data{'password'} eq "") {
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"You must enter a password.\");history.back();</SCRIPT>";
	die;
}

$UseDir = $MasterPath . "/se/Planets/$data{'planet'}";

unless (($data{'capital'} eq $data{'colony1'}) or ($data{'capital'} eq $data{'colony2'}) or ($data{'colony1'} eq $data{'colony2'})) {$PassFlag = 1}
if ($PassFlag != 1) {
	print "Content-type: text/html\n\n";
	print qq©<SCRIPT>alert("You cannot have more than one city with the same name.");history.back();</SCRIPT>©;
	die;
}

if ( ($data{'capital'} =~ m/[^A-Z a-z0-9]/) || ($data{'colony2'} =~ m/[^A-Z a-z0-9]/) || ($data{'colony1'} =~ m/[^A-Z a-z0-9]/) ) {
	print "Content-type: text/html\n\n";
	print qq©<body bgcolor=black text=white><SCRIPT>alert("You have attempted to use invalid characters in the name of one of yur cities. Valid characters are letters, numbers and space.");history.back();</SCRIPT>©;
	die;
}

open (IN, "$UseDir/CityList.txt");
flock (IN, 1);
@CityNames = <IN>;
&chopper (@CityNames);
close (IN);

foreach $Item (@CityNames) {if ($Item ne $data{'capital'} and $CapFlag != 2) {$CapFlag = 1} else {$CapFlag = 2}}
foreach $Item (@CityNames) {if ($Item ne $data{'colony1'} and $ColFlag1 != 2) {$ColFlag1 = 1} else {$ColFlag1 = 2}}
foreach $Item (@CityNames) {if ($Item ne $data{'colony2'} and $ColFlag2 != 2) {$ColFlag2 = 1} else {$ColFlag2 = 2}}

if ($data{'password'} ne $data{'password2'}) {
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"The confirmation must be the same as the password.\");history.back();</SCRIPT>";
	die;
}
if ($data{'planet'} eq "none") {
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"You must select a planet to play on.\");history.back();</SCRIPT>";
	die;
}


if (($CapFlag == 2) or ($ColFlag1 == 2) or ($ColFlag2 == 2)) {
	if ($CapFlag == 2) {$Line .= "The name you chose for your Capital is already in use.  Please select another."}
	if ($ColFlag1 == 2) {$Line .= "The name you chose for your first colony is already in use.  Please select another."}
	if ($ColFlag2 == 2) {$Line .= "The name you chose for your second colony is already in use.  Please select another."}

	print "Content-type: text/html\n\n";
	print qq©<SCRIPT>alert("$Line");history.back();</SCRIPT>©;
	die;
} else {
	open (OUT, ">>$UseDir/CityList.txt");
	print OUT "$data{'capital'}\n$data{'colony1'}\n$data{'colony2'}\n";
	close (OUT);
}

open (DAT, "$data{'planet'}.pln");
flock (DAT, 1);
$num = <DAT>;
close (DAT);
$num++;

open (DAT, ">$data{'planet'}.pln");
flock (DAT, 2);
print DAT $num;
close (DAT);

@timecalc = localtime (time);
$writetime = @timecalc[7];

srand(time);

open (IN, $MasterPath . "/se/$data{'planet'}.pln");
flock (IN, 1);
$Counter = <IN>;
close (IN);

$Continent = int(rand(4)) + 1;

&add_dirs;
&add_units;
&write_userinfo;
&write_data;
&display;

sub add_dirs {
	chdir("$userpath");
	mkdir("$data{'handle'}",0777) or print "Cannot Make Dir 2<BR>";
	mkdir("$data{'handle'}/military",0777);
	mkdir("$data{'handle'}/messages",0777);
	mkdir("$data{'handle'}/research",0777);
	mkdir("$data{'handle'}/events",0777);
	mkdir("$data{'handle'}/units",0777);
	mkdir("$data{'handle'}/intel",0777);
	mkdir("$data{'handle'}/military/Pool",0777);

}



sub add_units {

#	chdir("$userpath$data{'handle'}/military/");
	open (DATAOUT, ">$userpath$data{'handle'}/military/Militia.num");
	print DATAOUT "15\n";
	close (DATAOUT);
	open (DATAOUT, ">$userpath$data{'handle'}/military/Pool/army.txt");

	chmod (0777, "$userpath$data{'handle'}/military/Militia.num") or print "Content-type: text/html\n\n $!<BR>";
	print DATAOUT "1\n";
	print DATAOUT "1\n";
	print DATAOUT "19500\n";
	print DATAOUT "15\n";
	print DATAOUT "0\n";
	print DATAOUT "0\n";
	print DATAOUT "$Continent\n";
	print DATAOUT "0\n";
	close (DATAOUT);
	chmod (0777, "$userpath$data{'handle'}/military/Pool/army.txt");

	open (DATAOUT, ">$userpath$data{'handle'}/military/Pool/Militia.unt");
	print DATAOUT "15\n";
	close (DATAOUT);
	chmod (0777, "$userpath$data{'handle'}/military/Pool/Militia.unt");

	open (OUT, ">$userpath$data{'handle'}/research/TechData.tk");
	close (OUT);
	chmod (0777, "$userpath$data{'handle'}/research/TechData.tk");

#	chdir("$userpath");

#WRITE UNIT TYPES

	chdir("$data{'handle'}/units");
	open (DATAOUT, ">$userpath$data{'handle'}/units/Militia.con");
	flock (DATAOUT, 2);
	print DATAOUT "0\n";
	print DATAOUT "0\n";
	close (DATAOUT);
	chmod (0777, "$userpath$data{'handle'}/units/Militia.con");

#	chdir("$userpath/$data{'handle'}");
	open(RESEARCH,">$userpath$data{'handle'}/research.txt");
	print RESEARCH "5\n";
	print RESEARCH "0\n";
	print RESEARCH "0\n";
	print RESEARCH "0\n";
	close(RESEARCH);
	chmod (0777, "$userpath$data{'handle'}/research.txt");
}



sub write_userinfo {

	open(OUT, ">$userpath/$data{'handle'}/userinfo.txt");
	flock (OUT, 2);
	print OUT "$data{'handle'}\n";
	print OUT "$data{'user'}\n";
	print OUT "$data{'realname'}\n";
	print OUT "$data{'ICQ'}\n";
	print OUT "$data{'govtype'}\n";
	print OUT "$data{'econtype'}\n";
	close(OUT);
	chmod (0777, "$userpath/$data{'handle'}/userinfo.txt");

	dbmopen(%password, "$user_information/password", 0777) or print "Content-type: text/html\n\n $! - 1";
	$password{$data{'handle'}} = $data{'password'} or print "Content-type: text/html\n\n $! - 2";
	dbmclose(%password) or print "Content-type: text/html\n\n $! - 3";

	dbmopen(%planet, "$user_information/planet", 0777) or print "Content-type: text/html\n\n  $! - 4";
	$planet{$data{'handle'}} = $data{'planet'};
	dbmclose(%planet);
}

sub write_data {
#	chdir ("$userpath$data{'handle'}/");
	open (CNTRY, ">$userpath$data{'handle'}/country.txt");
	print CNTRY "9000\n";			#Population
	print CNTRY "0\n";			#Soldiers
	print CNTRY "50000\n";			#Food
	print CNTRY "1.00\n";			#Morale
	print CNTRY "1.00\n";			#Economy
	print CNTRY "\n\nAccepted\n";		#UWG Standing
	close(CNTRY);
	chmod (0777, "$userpath$data{'handle'}/country.txt");

	open (DATAOUT, ">$userpath$data{'handle'}/continent.txt");
	print DATAOUT "$Continent";
	close (DATAOUT);
	chmod (0777, "$userpath$data{'handle'}/continent.txt");

	open(DATAOUT, ">$userpath$data{'handle'}/money.txt");
	print DATAOUT "40000000\n";
	close(DATAOUT);
	chmod (0777, "$userpath$data{'handle'}/money.txt");

	($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	open(DATAOUT2, ">$userpath$data{'handle'}/turns.txt");
	print DATAOUT2 "24\n";
	print DATAOUT2 "0\n";
	print DATAOUT2 "$yday.$hour\n";
	close(DATAOUT2);
	chmod (0777, "$userpath$data{'handle'}/turns.txt");

	open (OUT, ">$userpath$data{'handle'}/Life.txt");
	print OUT 30;
	close (OUT);
	chmod (0777, "$userpath$data{'handle'}/Life.txt");

	open(LANDOUT, ">$userpath$data{'handle'}/City.txt");
	$Worth = (10 * 19000) + (10 * 140000) + (10 * 400000) + (10 * 20500);

#	NAME|POPULATION|SIZE|CLASS|WORTH|FOUNDER|FOUNDED_IN|MORALE|TERRORIST_INFILTRATION|RESIDENTIAL_ZONES|COMMERCIAL_ZONES|INDUSTRIAL_ZONES|AGRICULTURAL_ZONES|MODERNIZATION|SPECIALIZATION|SCHOOLS|BARRACKS|HOSPITALS|CIVIL_SERVICE|BUILD_ORIENTATION|BUILD_SPEED|BUILD_FOCUS|AVGLIFE|OLDHEALTH|OLDEDUCATION|OLDSOCIAL|RES_BUILDRATE|COM_BUILDRATE|IND_BUILDRATE|AGR_BUILDRATE
#	print LANDOUT qq!$data{'capital'}|5000|20|Village|$Worth|$data{'handle'}|N/A|100|0|3|4|2|2|100|0|0|0|0|0|BUILD_ORIENTATION|BUILD_SPEED|BUILD_FOCUS|AVGLIFE|OLDHEALTH|OLDEDUCATION|OLDSOCIAL|RES_BUILDRATE|COM_BUILDRATE|IND_BUILDRATE|AGR_BUILDRATE    #Percent Holding Out in Seiege | Country Level
	print LANDOUT qqﬁ$data{'capital'}|5000|0|$Continent|1.00|$data{'capitalport'}|0|0|0|10|0|10|0|10|0|10|40|None|$data{'planet'}|$Worth|1.00|Village|1|1|0\nﬁ;
	print LANDOUT qqﬁ$data{'colony1'}|2000|0|$Continent|1.00|$data{'colony1port'}|0|0|0|4|0|3|0|3|0|3|13|None|$data{'planet'}|$Worth|1.00|Settlement|1|1|1\nﬁ;
	print LANDOUT qqﬁ$data{'colony2'}|2000|0|$Continent|1.00|$data{'colony2port'}|0|0|0|4|0|3|0|3|0|3|13|None|$data{'planet'}|$Worth|1.00|Settlement|1|1|1\nﬁ;
	close(LANDOUT);
	chmod (0777, "$userpath$data{'handle'}/City.txt");

	open (OUT, ">>$PlainPath/$Continent.loc");
	flock (OUT, 2);
	print OUT "$data{'handle'}\n";
	close (OUT);
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
      $data{$name} = $value;
      }
}



sub display {
	print "Location: http://www.bluewand.com/pages/se/seclassic.php\r\n\r\n";
}



#sub chopper {
#	foreach $k (@_) {chop($k);}
#}

