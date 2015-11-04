#!/usr/bin/perl
require 'quickies.pl'

&parse_form;
srand(time);

($User,$Planet,$Authcode)=split(/&/,$ENV{QUERY_STRING});
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
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";
$user_information = $MasterPath . "/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) and ($AuthCode ne "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);


$UserPath = $MasterPath . "/se/Planets/$Planet/users/$User";
$MilPath =  $MasterPath . "/se/Planets/$Planet/users/$User/military/";

open (DATAIN, "$UserPath/money.txt");
$money = <DATAIN>;
close (DATAIN);
chop ($money);

open (DATAIN, "$UserPath/turns.txt");
$turnsf = <DATAIN>;
$turns = <DATAIN>;
close (DATAIN);
chop ($turns);

$money = &Space($money);

opendir (DIR, "$MilPath");
@List = readdir (DIR);
closedir (DIR);

foreach $Item (@List) {
	if (-d "$MilPath$Item" and $Item ne '.' and $Item ne '..') {
	push (@ArmyList, $Item);
	}
}
sort (@ArmyList);

open (DATAIN, "$UserPath/continent.txt");
$Cont = <DATAIN>;
close (DATAIN);

open (DATAIN, "$UserPath/country.txt");
@Nation = <DATAIN>;
close (DATAIN);
&chopper (@Nation);

open (DATAIN, "$UserPath/military.txt");
@Defense = <DATAIN>;
close (DATAIN);
&chopper (@Defense);

if ($data{'secret'} == 1) {
	if (exists $data{'defcon'}) {@Defense[0] = "$data{'defcon'}"}
	if (exists $data{'missile'}) {@Defense[1] = "$data{'missile'}"}
	if (exists $data{'conscription'}) {@Defense[2] = (int($data{'conscription'} * 100))/ 100;}
	if (@Defense[2] > 100 or @Defense[2] < 0) {@Defense[2] = 0}

	$Reserves = @Defense[2];

	foreach $Unit (@ArmyList) {
		$Go = $Unit."1";
			if (exists $data{$Go}) {
			$NUnit = $Unit;
			$NUnit =~ tr/_/ /;
			open (DATAIN, "$MilPath$Unit/army.txt") or print "Cannot open $MilPath$Unit/<BR>";
			@ArmyInfo = <DATAIN>;
			close (DATAIN);
			&chopper (@ArmyInfo);


			@ArmyInfo[0] = $data{$Unit};
			$Troops = $Unit."1";
			$Troops =~ tr/ /_/;
			$Recall = $Unit."2";
			$Recall =~ tr/ /_/;

			if ($data{$Recall} == 1 and @ArmyInfo[1] > 0) {@ArmyInfo[6] = $Cont}

			if (int(abs($data{$Troops})) != @ArmyInfo[5] and @ArmyInfo[1] > 0) {
				if ($data{$Troops} > @Nation[1]+@ArmyInfo[5] or (@Nation[1]+@ArmyInfo[5]-int(abs($data{$Troops})) < 0)) {
					print "<SCRIPT>alert(\"You do not have sufficient reserves to assign the desired troops to $NUnit.\");</SCRIPT>";
				} else {
					@Nation[1] += @ArmyInfo[5];
					@ArmyInfo[2] -= (@ArmyInfo[5] * 1350);
					@ArmyInfo[5] = int(abs($data{$Troops}));
					@ArmyInfo[2] += (@ArmyInfo[5] * 1350);
					@Nation[1] -= @ArmyInfo[5];
				}
			}

			open (DATAOUT, ">$MilPath$Unit/army.txt");
			foreach $WriteLine (@ArmyInfo){
				print DATAOUT "$WriteLine\n";
			}
			close (DATAOUT);
		}
	}

	@Defense[2] = $Reserves;
	close (DATAOUT);
	open (OUT, ">$UserPath/military.txt");
	flock (OUT, 2);
	foreach $WriteLine (@Defense){
		print OUT "$WriteLine\n";
	}
	close (OUT);
	chmod (0777, "$UserPath/military.txt");

	open (OUT, ">$UserPath/country.txt") or print $!;
	flock (OUT, 2);
	foreach $WriteLine (@Nation) {
		print OUT "$WriteLine\n";
	}
	close (OUT);
}

if (@Defense[0] == 0) {$DefSelect1 = "SELECTED"}
if (@Defense[0] == 1) {$DefSelect2 = "SELECTED"}
if (@Defense[0] == 2) {$DefSelect3 = "SELECTED"}

if (@Defense[1] == 0) {$MisSelect1 = "SELECTED"}
if (@Defense[1] == 1) {$MisSelect2 = "SELECTED"}
if (@Defense[1] == 2) {$MisSelect3 = "SELECTED"}

if ($turns < 72) {$AttackLine = "Not Available";} else {$AttackLine = qq!<A HREF = "war.pl?$User&$Planet&$Authcode" STYLE="text-decoration:none;color:black" target="Frame5">Mobilize Armies</A>!;}

$Troopers = &Space(@Nation[1]);
print qq!
<HTML>
<BODY BGCOLOR="#000000" TEXT="#FFFFFF"><BR>
<SCRIPT>parent.frames[1].location.reload()</SCRIPT>
<TABLE BORDER="1" WIDTH="100%" BORDER=1 CELLSPACING=0>
  <TR>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Current Funds:</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">\$$money</TD>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Turns Remaining:</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$turnsf</TD>
  </TR>
</TABLE><BR>
<FONT FACE="Arial"><CENTER><B>Operations</b>

<Table width="100%"><TR><TD width="33%">
<Table width="100%" BORDER=1 CELLSPACING=0>
<TR><TD bgcolor=$Header><FONT FACE="Arial" size="-1"><CENTER>Conventional War:</td></tr>
<TR BGCOLOR="$Content"><TD><FONT FACE="Arial" size="-1"><CENTER>$AttackLine</td></tr>
</table>

</TD><TD width="34%">
<Table width="100%" BORDER=1 CELLSPACING=0>
<TR><TD BGCOLOR="$Header"><FONT FACE="Arial" size="-1"><CENTER>Tactical Weapons:</td></tr>
<TR BGCOLOR="$Content"><TD><FONT FACE="Arial" size="-1"><CENTER><A HREF = "tactical.pl?$User&$Planet&$Authcode" STYLE="text-decoration:none;color:black" target="Frame5">Tactical Weapons</A></td></tr>
</table>

</TD><TD width="33%">
<Table width="100%" BORDER=1 CELLSPACING=0>
<TR><TD BGCOLOR="$Header"><FONT FACE="Arial" size="-1"><CENTER>Form Armies:</td></tr>
<TR BGCOLOR="$Content"><TD><FONT FACE="Arial" size="-1"><CENTER><A HREF = "makearmy.pl?$User&$Planet&$Authcode" STYLE="text-decoration:none;color:black" target="Frame5">Form Armies</A></td></tr>
</table>
</Td></TR>
</table><BR><BR>

<FORM method="POST" action="http://www.bluewand.com/cgi-bin/classic/newdef.pl?$User&$Planet&$Authcode">
<B>Status</b>
<table width=100%>
<TR><TD width=50%>
<Table width="100%" BORDER=1 CELLSPACING=0>
<TR BGCOLOR="$Header"><TD><FONT FACE="Arial" size="-1"><Center>Defense Condition:</td></tr>
<TR BGCOLOR="$Content"><TD><FONT FACE="Arial" size="-1"><Center><select name="defcon">
<OPTION VALUE="0" $DefSelect1>Green</OPTION>
<OPTION VALUE="1" $DefSelect2>Yellow</OPTION>
<OPTION VALUE="2" $DefSelect3>Red</OPTION>
</select></td></tr></table>

</td><TD width="50%">

<Table width="100%" BORDER=1 CELLSPACING=0>
<TR BGCOLOR="$Header"><TD><FONT FACE="Arial" size="-1"><Center>Missile Status:</td></tr>
<TR BGCOLOR="$Content"><TD><FONT FACE="Arial" size="-1"><Center><select name="missile">
<OPTION VALUE="0" $MisSelect1>Offline</OPTION>
<OPTION VALUE="1" $MisSelect2>Defense</OPTION>
<OPTION VALUE="2" $MisSelect3>Agressive Defense</OPTION>
</select></td></tr>
</table>
</td></tr></table>


<CENTER>
<Table width="50%" BORDER=1 CELLSPACING=0>
<TR BGCOLOR="$Header"><TD><FONT FACE="Arial" size="-1"><Center>Conscription</td></tr>
<TR BGCOLOR="$Content"><TD><FONT FACE="Arial" size="-1"><Center>$Troopers Reserves</td></tr>
<TR BGCOLOR="$Content"><TD><FONT FACE="Arial" size="-1"><Center><INPUT TYPE="text" size="3" maxlength="9" value="$Defense[2]" name="conscription"> Percentage of Civilians/month</td></tr>
</table>
<BR><BR>
</center>

<B>Armies</b>

<Table width="100%">!;

foreach $Round (@ArmyList) {
	$SelectArmyMode1="";$SelectArmyMode2="";$SelectArmyMode3="";$SelectArmyMode4="";$SelectArmyMode6="";$SelectArmyMode5="";
	$Counter++;
	if ($Counter == scalar(@ArmyList)) {$Insert = "<CENTER>"}
	$RoundName = $Round;
	$RoundName =~ tr/_/ /;
	
	open (DATAIN, "$MilPath$Round/army.txt");
	@ArmyData = <DATAIN>;
	close (DATAIN);
	&chopper (@ArmyData);
	if (@ArmyData[0] eq "1"){$SelectArmyMode1 = "SELECTED"}
	if (@ArmyData[0] eq "2"){$SelectArmyMode2 = "SELECTED"}
	if (@ArmyData[0] eq "3"){$SelectArmyMode3 = "SELECTED"}
	if (@ArmyData[0] eq "4"){$SelectArmyMode4 = "SELECTED"}
	if (@ArmyData[0] eq "5"){$SelectArmyMode5 = "SELECTED"}
	if (@ArmyData[0] eq "6"){$SelectArmyMode6 = "SELECTED"}
	if (($Counter-1) % 2 == 0) {
		print qq!<TR><TD width="50%">!;
	}
	$Namess = $Round."1";
	$Namesss = $Round."2";

	$Active = &Space(@ArmyData[3]);
	$Carry = &Space(@ArmyData[4]);
	$Cost = &Space(@ArmyData[2]);
	if (@ArmyData[3] > @ArmyData[5] and $Round ne "Pool") {$ArmyWarnMsg = qq!<font size=-2 color=red>This army will not function without sufficent reserves.</font>!} else {$ArmyWarnMsg = ""}
	if ($ArmyData[5] < 1) {$ArmyData[5] = 0}
	print qq!
<Table width="100%" BORDER=1 CELLSPACING=0 bgcolor=$Content>
<TR BGCOLOR="$Header"><TD colspan=2><FONT FACE="Arial" size="-1">$RoundName<BR>$ArmyWarnMsg</td></tr>
<TR><TD width=50% bgcolor=$Header><FONT FACE="Arial" size="-1">Continent</td><TD><FONT FACE="Arial" size="-1">$ArmyData[6]</td></tr>
<TR><TD width=50% BGCOLOR=$Header><FONT FACE="Arial" size="-1">Required Soldiers</td><TD><FONT FACE="Arial" size="-1">$Active</td></tr>!;

if ($Round ne "Pool" and $ArmyData[1] == 1) {print qq!
<TR><TD width=50% bgcolor=$Header><FONT FACE="Arial" size="-1">Setting</td><TD><FONT FACE="Arial" size="-2"><select name="$Round">
<OPTION VALUE="1" $SelectArmyMode1>Assist</OPTION>
<OPTION VALUE="2" $SelectArmyMode2>Defense</OPTION>!;

if ($ArmyData[7] == 0) {
print qq!<OPTION VALUE="5" $SelectArmyMode5>Naval</OPTION>!}

print qq!
<OPTION VALUE="3" $SelectArmyMode3>Ready</OPTION>
<OPTION VALUE="6" $SelectArmyMode6>Exploration</OPTION>
</select></td></tr>!
}


if ($Round eq "Pool") {print qq!<TR><TD width=50% bgcolor=$Header><FONT FACE="Arial" size="-1">Setting</td><TD><FONT FACE="Arial" size="-1">Warehouse</font></td></tr>!}
if (@ArmyData[1] == 0) {print qq!<TR><TD width=50% bgcolor=$Header><FONT FACE="Arial" size="-1">Setting</td><TD><FONT FACE="Arial" size="-1">Not Available</font></td></tr>!}
if (@ArmyData[1] < 0) {$Turn = abs(@ArmyData[1]);print qq!<TR><TD width=50% bgcolor=$Header><FONT FACE="Arial" size="-1">Setting</td><TD><FONT FACE="Arial" size="-1">@ArmyData[8] - $Turn Months Remaining</font></td></tr>!}

if ($Round ne "Pool") {print qq!
<TR><TD width=50% bgcolor=$Header><FONT FACE="Arial" size="-1">Active Soldiers</td><TD><FONT FACE="Arial" size="-2"><INPUT TYPE="text" value="$ArmyData[5]" name="$Namess" size=9></td></tr>!} 
else {print qq!
<TR><TD width=50% bgcolor=$Header><FONT FACE="Arial" size="-1">Active Soldiers</td><TD><FONT FACE="Arial" size="-1">N/A</td></tr>!}
print qq!
<TR><TD width=50% Bgcolor=$Header><FONT FACE="Arial" size="-1">Maintenance Cost</td><TD><FONT FACE="Arial" size="-1">\$$Cost</td></tr>
<TR><TD width=50% bgcolor=$Header><FONT FACE="Arial" size="-1">Transport</td><TD><FONT FACE="Arial" size="-1">$Carry</td></tr>
</table></td>!;

	if (($Counter-1) % 2 == 0) {
		print qq!<TD width="50%">!;
	}else {
		print qq!</TR>!;
	}
}
print qq!
</table><input type=hidden value=1 name=secret><INPUT TYpe="submit" value="Process" name="submit"></body></HTML>
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

