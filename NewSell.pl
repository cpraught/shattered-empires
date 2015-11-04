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
dbmopen(%authCode, "$user_information/accesscode", 0777) or print "Cannot open file<BR>";

if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

$PlayerMainPath = $MasterPath . "/se/Planets/$Planet/users/$User";
$PlayerArmyPath = $MasterPath . "/se/Planets/$Planet/users/$User/military";
$TradePath = $MasterPath . "/se/Planets/$Planet/market";
$UnitPath = $MasterPath . "/unitsdir";
$SF = qq!<FONT FACE="Arial" size=-1>!;


&parse_form;

if ($Mode == 1) {
	opendir (DIR, "$PlayerArmyPath");
	@Files = readdir (DIR);
	closedir (DIR);

	foreach $Item (@Files) {
		if (-f "$PlayerArmyPath/$Item") {
			$Item =~ s/.num/.unt/;
			open (IN, "$PlayerArmyPath/Pool/$Item");
			$Number = <IN>;
			close (IN);
			chop ($Number);

			open (IN, "$UnitPath/$Item");
			@UnitInfo = <IN>;
			close (IN);
			&chopper (@UnitInfo);

			$Item =~ tr/ /_/;
			$Item =~ s/.unt//;
			$data{"1$Item"} =~ s/ //;

			$data{"2$Item"} =~ s/\D//g;
			if ($data{"2$Item"} <= $Number and $data{"2$Item"} > 0) {
				
				$Item2 = $Item;
				$Item2 =~ tr/_/ /;


				if ($data{"1$Item"} > (10 * $UnitInfo[2])) {
					$WarnMsg = $WarnMsg.qq!Units ($Item2) cannot be sold for more than ten times manufacturing costs.<BR>!;
				} elsif ($data{"1$Item"} < $UnitInfo[2]) {
					$WarnMsg = $WarnMsg.qq!Units ($Item2) cannot be sold for less than manufacturing cost.<BR>!;
				} else {
					$Number -= $data{"2$Item"};
					open (OUT, ">$PlayerArmyPath/Pool/$Item2.unt");
					print OUT "$Number\n";
					close (OUT);

					if ($data{"3$Item"} == 4) {
						$Income = ((int(@UnitInfo[2] * 0.75)) * $data{"2$Item"});
						open (IN, "$PlayerMainPath/money.txt");
						$Funds = <IN>;
						close (IN);
						chop ($Funds);

						$Funds += $Income;

						open (OUT, ">$PlayerMainPath/money.txt");
						print OUT "$Funds\n";
						close (OUT);

						$Income = &Space($Income);
						$WarnMsg = $WarnMsg.qq!$data{"2$Item"} $Item2 sold on the National Market for \$$Income.<BR>!;

						open (IN, "$PlayerArmyPath/$Item2.num");
						@Info = <IN>;
						close (IN);
						chop (@Info[0]);
						$Info[0] -= $data{"2$Item"};

						open (OUT, ">$PlayerArmyPath/$Item2.num");
						print OUT "@Info[0]\n";
						print OUT "@Info[1]\n";
						close (OUT);

					} else {
						$AddCounter++;
						($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
						if (-e "$TradePath/$Year$Mon$Mday$Hour$Min$Sec") {
							open (OUT, ">$TradePath/$Year$Mon$Mday$Hour$Min$Sec$AddCounter");
						} else {
							open (OUT, ">$TradePath/$Year$Mon$Mday$Hour$Min$Sec");
						}
	
						print OUT "$Item2\n";
						print OUT "$User\n";
						print OUT qq!$data{"2$Item"}\n!;
						print OUT qq!$data{"1$Item"}\n!;
						print OUT qq!$data{"3$Item"}\n!;
						close (OUT);
						chmod (0777, "$TradePath/$Year$Mon$Mday$Hour$Min$Sec");
						$WarnMsg = $WarnMsg.qq!$data{"2$Item"} $Item2 have been placed on the International Market for \$$data{"1$Item"} each.<BR>!;


						open (IN, "$PlayerArmyPath/$Item2.num");
						@Info = <IN>;
						close (IN);
						chop (@Info[0]);
						$Info[0] -= $data{"2$Item"};

						open (OUT, ">$PlayerArmyPath/$Item2.num");
						print OUT "@Info[0]\n";
						print OUT "@Info[1]\n";
						close (OUT);

						&NewNetworth;
					}			
				}
			}
		}
	}
}

unless ($WarnMsg eq "") {$Bump = "<BR>"}

opendir (DIR, "$PlayerArmyPath/Pool");
@Units = readdir (DIR);
closedir (DIR);

open (DATAIN, "$PlayerMainPath/money.txt");
$money = <DATAIN>;
close (DATAIN);
chop ($money);

open (DATAIN, "$PlayerMainPath/turns.txt");
$turns = <DATAIN>;
close (DATAIN);
chop ($turns);

$money = &Space($money);

print qqﬁ<BODY BGCOLOR="#000000" TEXT="#FFFFFF">$SF
<table width=100% border=1 cellspacing=0><TR><TD bgcolor=$Header><CENTER><B>$SF Sell Units</B></TD></TR></Table><BR><Center>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT><BR>
<TABLE BORDER="1" WIDTH="100%" BORDER=1 CELLSPACING=0>
  <TR>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Current Funds :</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">\$$money</TD>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Turns Remaining:</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$turns</TD>
  </TR>
</TABLE>
Note: Units sold on national markets will be sold for the price listed.<BR>A transaction fee of 20% applies to all international market purchases.<BR>
$WarnMsg$Bump
<form METHOD=POST action="http://www.bluewand.com/cgi-bin/classic/NewSell.pl?$User&$Planet&$AuthCode&1">
<table border=1 cellspacing=0 bgcolor="$Content" width=100%>
<TR bgcolor="$Header"><TD>$SF Unit Name</td><TD>$SF Home Price</TD><TD>$SF Cost Per Unit</TD><TD>$SF Available</TD><TD>$SF Amount To Sell</TD><TD>$SF Mode</TD></TR>
ﬁ;

foreach $Item (@Units) {
	if ($Item ne '.' and $Item ne '..' and $Item ne 'army.txt') {
		open (IN, "$PlayerArmyPath/Pool/$Item");
		$Number = <IN>;
		chop ($Number);
		close (IN);

		open (IN, "$UnitPath/$Item") or print "Cannot open $Item<BR>";
		@UnitInfo = <IN>;
		close (IN);
		&chopper (@UnitInfo);
		$HomeCost = &Space(int(@UnitInfo[2] * 0.75));
		$AwayCost = @UnitInfo[2];

		$Items = $Item;
		$Items =~ s/.unt//;
		$Item2 = $Items;
		$Item2 =~ tr/ /_/;

		$Number = &Space($Number);
		if ($Number ne "") {
			print qqﬁ<TR><TD>$SF $Items</td><TD>$SF\$$HomeCost</TD><TD>$SF\$<input type="text" size=9 value="$AwayCost" name="1$Item2"></TD><TD>$SF $Number</TD><TD>$SF<input type="text" value=0 name="2$Item2" size=9></TD><TD>$SF<font size=-2><select name="3$Item2"><option value=1>Allies Only</option><option value=2>Allies/Neutral</option><option value=3>All Countries</option><option value=4 SELECTED>National Market</option></select></TD></TR>
ﬁ;
			$Count++;
		}
	}
}
if ($Count < 1) {
	print qqﬁ<TR><TD colspan=5>$SF<center>No Units Available</TD></TR>ﬁ;
}

print qqﬁ
</table><BR><BR>
<center><input type=submit value="Place on Market" name=sell>
</form>
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
#
#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}


sub NewNetworth
{
	#Get Old Networth
	open (IN, "$PlayerMainPath/country.txt");
	flock (IN, 1);
	my @CountryDataIn = <IN>;
	close (IN);
	&chopper (@CountryDataIn);

	@CountryDataIn[8] -= int(abs($data{"2$Item"} * (@UnitInfo[3]/100)));
	@CountryDataIn[10] += int(abs($data{"2$Item"} * (@UnitInfo[3]/100)));
	@CountryDataIn[11] += int(abs(@UnitInfo[3] * $data{"2$Item"}));

	open (OUT, ">$PlayerMainPath/country.txt");
	flock (OUT, 2);
	foreach $Instance (@CountryDataIn) {
		print OUT "$Instance\n";
	}
	close (OUT);
}
