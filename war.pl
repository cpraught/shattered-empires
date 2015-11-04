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
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}

dbmclose(%authCode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";
&parse_form;
$PlayerDir = $MasterPath . "/se/Planets/$Planet/users";


open (IN, "$PlayerDir/$User/City.txt");
flock (IN, 1);
@Cities = <IN>;
close (IN);
if (scalar(@Cities) == 0) {
	print "<SCRIPT>alert(\"Your nation is dead.  You cannot attack.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}

open (IN, "$PlayerDir/$User/research/TechData.tk");
flock (IN, 1);
@Tech  = <IN>;
close (IN);
&chopper (@Tech);

foreach $Item (@Tech) {
	@TechData = split (/\|/, $Item);
	if (@TechData[2] >= @TechData[3]) {$Storage{@TechData[1]} = 1}
}


if ($Storage{Command_Structure}) {$TechNumber += 2}


open (IN, "$PlayerDir/$User/located.txt");
flock (IN, 1);
@Players = <IN>;
close (IN);


$MilPath = "$PlayerDir/$User/military";
opendir (DIR, "$MilPath");
@List = readdir (DIR);
closedir (DIR);

open (DATAIN, "$UserPath/continent.txt");
flock (DATAIN, 1);
$Continent = <DATAIN>;
close (DATAIN);

open (IN, "$PlayerDir/$User/research/TechData.tk") or print "Cannot Open $PlayerDir/$User/research/TechData.tk<BR>";
flock (IN, 1);
@Tech  = <IN>;
close (IN);
&chopper (@Tech);

foreach $Item (@Tech) {
	@TechData = split (/\|/, $Item);
	if (@TechData[2] >= @TechData[3]) {$Storage{@TechData[1]} = 1}
}

foreach $Item (@List) {
	if (-d "$MilPath/$Item" and $Item ne '.' and $Item ne '..' and $Item ne "Pool") {
		push (@ArmyList, $Item);
	}
}


if ($Mode == 1) {
	&parse_form;
	foreach $Army (@ArmyList) {
		if ($data{$Army} == 1) {
			open (IN, "$MilPath/$Army/army.txt");
			flock (IN, 1);
			@ArmyData = <IN>;
			close (IN);
			&chopper (@ArmyData);

			if ($ArmyData[1] = 1) {
				$a = "1$Army";
				$b = "2$Army";
				$TotalCost += (@ArmyData[2] * 2);
				if ($data{$b} eq "1GT") {$ArmyData[1] = -6;$ArmyData[6] = $data{$a};@ArmyData[8] = qq!<font size=-2>Transporting to Cont $data{$a}!}
				open (OUT, ">$MilPath/$Army/army.txt") or print "Cannot open to write<BR>";
				flock (OUT, 2);
				foreach $Run (@ArmyData) {
					print OUT "$Run\n";
				}
				close (OUT);

				$Army =~ tr/_/ /;
				$TransportMsg .= qq!$Army has begun transporting to continent $data{$a}.<BR>!;

			}
		}
	}
	open (IN, "$PlayerDir/$User/money.txt");
	flock (IN, 1);
	$Money = <IN>;
	close (IN);
	&chopper ($Money);

	$Money -= $TotalCost;

	open (OUT, ">$PlayerDir/$User/money.txt");
	flock (OUT, 2);
	print OUT "$Money\n";
	close (OUT);
}



foreach $item (@Players) {
	$item =~ tr/ /_/;
	$Count{$item}++;
}

@PlayerList = keys(%Count);



$Options = qq!<option value=none>No Target Selected</option>!;

@PlayerList = sort(@PlayerList);
foreach $Item (@PlayerList) {
	unless ($Item =~ /\./i or $Item eq "$User" or ($Item =~ /Admin/ and !$User =~ /Admin/) ) {
		$Item =~ tr/ /_/;
		$Item = substr($Item,0,scalar($Item)-1);

		if (-e "$PlayerDir/$Item/turns.txt") {
			if (-e "$PlayerDir/$Item/notallowed.txt") {
			} else {
				if (-e "$PlayerDir/$Item/dupe.txt") {
				} else {
					open (IN, "$PlayerDir/$Item/turns.txt");
					flock (IN, 1);
					@DataIn = <IN>;
						&chopper (@DataIn);
					close (IN);
					if (@DataIn[1] > 72) {
		
						$Items = $Item;
						$Items =~ tr/_/ /;
						unless ($Item =~ /Admin/) {
							$Options = $Options.qq!<option value='$Item'>$Items</option>!;
						}
					}
				}
			}
		}
	}
}

$SF = qq!<font face=verdana size=-1>!;
print qqﬁ
<body bgcolor=000000 text=white>
<SCRIPT>parent.frames[1].location.reload()</SCRIPT>
$SF
<table width=100% border=1 cellspacing=0><TR><TD bgcolor=$Header>$SF<B><Center>Attack Selection</TD></TR></table>
<BR><BR><center>$TransportMsg</center><BR>ﬁ;

$TotalArmyList = 3 + $TechNumber;

if (scalar(@ArmyList) <= $TotalArmyList) {
print qqﬁ
<form method=POST action="http://www.bluewand.com/cgi-bin/classic/war2.pl?$User&$Planet&$AuthCode"><Center>
<table width=60% border=1 cellspacing=0 bgcolor=$Content>
<TR><TD bgcolor=$Header>$SF<center>Select Target<BR><font size=-2>(Countries must have played more than 72 turns to be listed)</font></TD></TR>
<TR><TD>$SF<Center><select name=target>$Options</select></TD></TR>
</table><BR><BR>
<input type=submit name=submit value="Proceed">
</form><BR><BR><BR>ﬁ;

if ($Storage{"1st_Generation_Naval_Transport"} == 1) {
$Method .= qq!<option value=1GT>1st Gen Naval Transport</option>!;
}
#$Method .= qq!<option value=2GT>2nd Gen Naval Transport</option>!;
#$Method .= qq!<option value=1GAT>1st Gen Air Transport</option>!;
#$Method .= qq!<option value=2GAT>2nd Gen Air Transport</option>!;


if ($Method ne "") {
	$ContFinder = qq!<option value=1>Cont One</option><option value=2>Cont Two</option><option value=3>Cont Three</option><option value=4>Cont Four</option>!;
	print qq!
	<form method=POST action="http://www.bluewand.com/cgi-bin/classic/war.pl?$User&$Planet&$AuthCode&1">

	<table border=1 cellspacing=0 cellpadding=0 bgcolor="$Content" width=100%>
	<TR bgcolor=$Header><TD>$SF Army</TD><TD>$SF Personnel</TD><TD>$SF Transport</TD><TD>$SF Cost</TD><TD>$SF Method</TD><TD>$SF Target</TD><TD>$SF Transport</TD></TR>!;
	foreach $Item (@ArmyList) {
		open (IN, "$MilPath/$Item/army.txt") or print "Cannot open $MilPath/$Item/army.txt<BR>";
		flock (IN, 1);
		@ArmyData = <IN>;
		close (IN);
		if ($ArmyData[1] == 1) {

			$NItem = $Item;
			$NItem =~ tr/_/ /;
			$Personnel = &Space(@ArmyData[5]);
			$Carry = &Space(@ArmyData[4]);
			$Cost = &Space(@ArmyData[2] * 2);
			print qq!<TR><TD>$SF $NItem</TD><TD>$SF $Personnel</TD><TD>$SF $Carry</TD><TD>$SF \$$Cost</TD><TD>$SF<font size=-3><select name="2$Item">$Method</select></TD><TD>$SF<font size=-2><select name=1$Item>$ContFinder</select></TD><TD><input type=checkbox name="$Item" value=1></TD></TR>!;
		}
	}
	print qq!</table><BR><input type=submit name=go value="Transport"></form>!;

}

print qq!<\/body>!;
} else {
	print qqﬁ<center>
We currently have too many armies to manage an attack.  The maximum number we can possess is $TotalArmyList.
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
         
      

      $data{$name} = $value;
      }
}

#sub chopper{
#	foreach $k(@_){
#		chomp($k);
#	}
#}
#
#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}
