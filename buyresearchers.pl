#!/usr/bin/perl
require 'quickies.pl'

($user,$planet,$Authcode)=split(/&/,$ENV{QUERY_STRING});
$PlanetDir = $MasterPath . "/se/Planets/$planet";
$UserDir = "$PlanetDir/users/$user";

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
if($Authcode ne $authcode{$user} || $Authcode eq "") {
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";
&parse_form;

$UserPath = $MasterPath . "/se/Planets/$planet/users/$user";
$SF = qq!<FONT FACE="Arial" size="-1">!;
print qq!
<HTML>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<body BGCOLOR="000000" text="white">
!;

open (DATAIN, "$UserPath/turns.txt");
$turns = <DATAIN>;
close (DATAIN);
&chopper ($turns);

open (RESEARCH, "$UserPath/research.txt");
@researchers=<RESEARCH>;
&chopper(@researchers);

open (RESEARCH, "$UserPath/UsedTech.txt");
@researchers2=<RESEARCH>;
&chopper(@researchers2);

open (DATAIN, "$UserPath/money.txt");
$money = <DATAIN>;
close (DATAIN);
&chopper ($money);

open (DATAIN, "$UserPath/country.txt");
@Country = <DATAIN>;
close (DATAIN);
&chopper (@Country);

opendir (DIR, "$UserPath/research");
@Files = readdir (DIR);
closedir (DIR);

if ($data{'hire1'} > 0) {
	if ($data{'hire1'}  <= int(@Country[0] * 0.05 * @Country[4]/1000)-$researchers[0]) {
		if ($data{'hire1'} * 1000000 <= $money) {
			$researchers[0] += abs($data{'hire1'});
			$money -= abs($data{'hire1'})*1000000;
			if ($data{'hire1'} >= 0 ) {
				$hire = &Space($data{'hire1'});
				$HireMsg = qqﬁ<center>$SF$hire scholars have been hired.<BR></center>ﬁ;
			}
		}
		else {
			if ($data{'hire1'} >= 1) {
				$HireMsg = qqﬁ<center>$SF You do not have enough money to hire that many scholars.<BR></center>ﬁ;
				$money = &Space($money);
				print qq!
<Table border=1 cellspacing=0 width=100%><TR><TD bgcolor="$Header"><Font face="Arial" size="-1"><cENTER>Hire Scientists</center></font></td></tr></table>
<BR><table border="1" width="100%" cellspacing=0>
<tr><TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Current Funds:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">\$$money</td>
<TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Remaining Turns:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">$turns</td></tr></table>
<BR><BR>$HireMsg<BR>!;
				die;
			}
		}
	}
	else {
		$HireMsg = qqﬁ<center>$SF You do not have enough available scholars in your country.<BR></center>ﬁ;
				$money = &Space($money);
				print qq!
<Table border=1 cellspacing=0 width=100%><TR><TD bgcolor="$Header"><Font face="Arial" size="-1"><cENTER>Hire Scientists</center></font></td></tr></table>
<BR><table border="1" width="100%" cellspacing=0>
<tr><TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Current Funds:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">\$$money</td>
<TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Remaining Turns:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">$turns</td></tr></table>
<BR><BR>$HireMsg<BR>!;
		die;
	}
}
elsif ($data{'hire1'} < 0) {
	if (abs($data{'hire1'}) <= ($researchers[0] - $researchers2[0])) {
		$researchers[0] -= abs($data{'hire1'});
		$fire = abs($data{'hire1'});
		$fire2 = " researchers have been fired.<BR>";
	}
	else {
		$FireMsg = qqﬁ<center>$SF You cannot fire more scholars than you employ.<BR></center>ﬁ;
				$money = &Space($money);
				print qq!
<Table border=1 cellspacing=0 width=100%><TR><TD bgcolor="$Header"><Font face="Arial" size="-1"><cENTER>Hire Scientists</center></font></td></tr></table>
<BR><table border="1" width="100%" cellspacing=0>
<tr><TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Current Funds:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">\$$money</td>
<TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Remaining Turns:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">$turns</td></tr></table>
<BR><BR>$HireMsg<BR>$FireMsg!;
		die;
	}
}

if ($data{'hire2'} > 0) {
	if ($data{'hire2'}  < int(@Country[0] * 0.02 * @Country[4]/1000)-$researchers[1]) {
		if ($data{'hire2'} * 5000000 <= $money) {
			$researchers[1] += abs($data{'hire2'});
			$money -= abs($data{'hire2'})*5000000;
			if ($data{'hire2'} > 0 ) {
				$hire = &Space($data{'hire2'});
				$HireMsg = qqﬁ<center>$SF$hire researchers have been hired.<BR></center>ﬁ;
				print qq!
<Table border=1 cellspacing=0 width=100%><TR><TD bgcolor="$Header"><Font face="Arial" size="-1"><cENTER>Hire Scientists</center></font></td></tr></table>
<BR><table border="1" width="100%" cellspacing=0>
<tr><TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Current Funds:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">\$$money</td>
<TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Remaining Turns:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">$turns</td></tr></table>
<BR><BR>$HireMsg<BR>!;
			}
		}
		else {
			if ($data{'hire2'} >= 1) {
				$HireMsg = qqﬁ<center>$SF You do not have enough money to hire that many researchers.<BR></center>ﬁ;
				$money = &Space($money);
				print qq!
<Table border=1 cellspacing=0 width=100%><TR><TD bgcolor="$Header"><Font face="Arial" size="-1"><cENTER>Hire Scientists</center></font></td></tr></table>
<BR><table border="1" width="100%" cellspacing=0>
<tr><TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Current Funds:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">\$$money</td>
<TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Remaining Turns:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">$turns</td></tr></table>
<BR><BR>$HireMsg<BR>FireMsg!;
				die;
			}
		}
	}
	else {
		$HireMsg = qqﬁ<center>$SF You do not have enough available researchers in your country.<BR></center>ﬁ;
				$money = &Space($money);	
				print qq!
<Table border=1 cellspacing=0 width=100%><TR><TD bgcolor="$Header"><Font face="Arial" size="-1"><cENTER>Hire Scientists</center></font></td></tr></table>
<BR><table border="1" width="100%" cellspacing=0>
<tr><TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Current Funds:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">\$$money</td>
<TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Remaining Turns:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">$turns</td></tr></table>
<BR><BR>$HireMsg<BR>!;
		die;
	}
}
elsif ($data{'hire2'} < 0) {
	if (abs($data{'hire2'}) <= ($researchers[1] - $research2[1])) {
		$researchers[1] -= abs($data{'hire2'});
		$fire = abs($data{'hire2'});
		$fire2 = " researchers have been fired.<BR>";
	}
	else {
		$FireMsg = qqﬁ<center>$SF You cannot fire more researchers than you employ.<BR></center>ﬁ;
				$money = &Space($money);
				print qq!
<Table border=1 cellspacing=0 width=100%><TR><TD bgcolor="$Header"><Font face="Arial" size="-1"><cENTER>Hire Scientists</center></font></td></tr></table>
<BR><table border="1" width="100%" cellspacing=0>
<tr><TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Current Funds:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">\$$money</td>
<TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Remaining Turns:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">$turns</td></tr></table>
<BR><BR>$HireMsg<BR>!;
		die;
	}
}

open (DATAIN, ">$UserPath/research.txt");
print DATAIN "$researchers[0]\n";
print DATAIN "$researchers[1]\n";
print DATAIN "0\n";
print DATAIN "0\n";
close (DATAIN);
chmod (0777, "$UserPath/research.txt");

open (DATAIN, ">$UserPath/money.txt");
print DATAIN "$money\n";
close (DATAIN);

if ($researchers[0] > 0) {$cash = ($researchers[0]*750000)}
else {$cash=0}

$remaining1 = &Space(int(@Country[0] * 0.05 * @Country[4]/1000) - $researchers[0]);
$remaining2 = &Space(int(@Country[0] * 0.02 * @Country[4]/1000) - $researchers[1]);
if ($remaining1 < 0) {$remaining1=0}
if ($remaining2 < 0) {$remaining2=0}

$money = &Space($money);
$Aresearchers[0] = &Space($researchers[0] - $researchers2[0]);
$Aresearchers[1] = &Space($researchers[1] - $researchers2[1]);
print qq!
<Table border=1 cellspacing=0 width=100%><TR><TD bgcolor="$Header"><Font face="Arial" size="-1"><cENTER>Hire Scientists</center></font></td></tr></table>
<BR><table border="1" width="100%" cellspacing=0>
<tr><TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Current Funds:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">\$$money</td>
<TD BGCOLOR ="$Header" width="25%"><FONT FACE="Arial" size="-1">Remaining Turns:</td>
<TD BGCOLOR="$Content" width="25%"><FONT FACE="Arial" size="-1">$turns</td></tr></table>
<BR><BR>$HireMsg<BR>$FireMsg<BR>
<FORM NAME="Research" METHOD = "POST" ACTION="http://www.bluewand.com/cgi-bin/classic/buyresearchers.pl?$user&$planet&$Authcode">
<Table border=1 cellspacing=0 width=100%>
<TR bgcolor="$Content"><TD><Font face="Arial" size="-1">Type</font></td><TD><Font face="Arial" size="-1">Cost</font></td><TD><Font face="Arial" size="-1">Remaining</font></td><TD><Font face="Arial" size="-1">Employed</font></td><TD><Font face="Arial" size="-1">Fireable</TD><TD><Font face="Arial" size="-1">Hire</font></td></tr>
<TR bgcolor="$Header"><TD><Font face="Arial" size="-1">Scholars</font></td><TD><Font face="Arial" size="-1">\$1 000 000</font></td><TD><Font face="Arial" size="-1">$remaining1</font></td><TD><Font face="Arial" size="-1">$researchers[0]</font></td><TD><Font face="Arial" size="-1">$Aresearchers[0]</TD><TD><Font face="Arial" size="-1"><input type="text" name="hire1" size ="10"></font></td></tr>!;

if (-e "$UserPath/research/Researcher.cpl") {
print qq!<TR bgcolor="$Header"><TD><Font face="Arial" size="-1">Researchers</font></td><TD><Font face="Arial" size="-1">\$5 000 000</font></td><TD><Font face="Arial" size="-1">$remaining2</font></td><TD><Font face="Arial" size="-1">$researchers[1]</font></td><TD><Font face="Arial" size="-1">$Aresearchers[1]</TD><TD><Font face="Arial" size="-1"><input type="text" name="hire2" size ="10"></font></td></tr>!;

}

print qq!

</table><BR><CENTER>
<Font face="Arial" size="-1"><input type="SUBMIT" name="purchase" value=" Hire ">
</FORM>
</body>
</html>!;

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
