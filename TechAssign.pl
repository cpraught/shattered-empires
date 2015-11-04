#!/usr/bin/perl
require 'quickies.pl'

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

print "Content-type: text/html\n\n";
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

#New Tech Format - (Player) - Type|Name|Points|PointsRequired|Type1|Type2|Type3|Type4|Tech1|Tech2|Tech3|Tech4
#New Tech Format - (Index)  - Name|PointsRequired|Tech1|Tech2|Tech3|Tech4

$GameKeepPath=qq!http://www.bluewand.com/classic!;

&parse_form;

$ResearchPath = $MasterPath . "/research";
$PlayerPath = $MasterPath . "/se/Planets/$Planet/users/$User";
$PlayerTechPath = $MasterPath . "/se/Planets/$Planet/users/$User/research";
$Path = "AllyUtil.pl";

#unless ($User eq "Admin_One") {die}
if (-e "$PlayerPath/alliance.txt") {
	$SendTech = 1;
	open (IN, "$PlayerPath/alliance.txt");
	$Alliance = <IN>;
	close (IN);
	chop ($Alliance);
}


open (DATAIN, "$PlayerPath/research.txt");
flock (DATAIN, 1);
@Sci = <DATAIN>;
close (DATAIN);
&chopper (@Sci);

$begingraph =qq!<IMG SRC="$GameKeepPath/images/begin.gif" HEIGHT = "12" WIDTH="3">!;
$endgraph=qq!<IMG SRC="$GameKeepPath/images/end.gif" HEIGHT = "12" WIDTH="3">!;

open (DATAIN, "$PlayerPath/research.txt");
flock (DATAIN, 1);
@Scis = <DATAIN>;
close (DATAIN);

open (IN, "$PlayerTechPath/TechData.tk");
flock (IN, 1);
@TechData = <IN>;
close (IN);
&chopper (@TechData);

#Index Technologies
foreach $Tech (@TechData) {
	(@TechInfo) = split(/\|/,$Tech);
	if (@TechInfo[2] >= @TechInfo[3]) {$Storage{@TechInfo[1]} = 1}
#	$l = $Storage{@TechInfo[1]};
#	if ($User eq "Admin_One") {print "@TechInfo[2] >= @TechInfo[3]) : $l = 1, '@TechInfo[1]'<BR>"}
	if (@TechInfo[0] == 1) {push (@Military, $Tech)}
}
$Storage{""} = 1;
$Storage{0} = 1;

open (IN, "$ResearchPath/TechData.tkF") or print "$!";
flock (IN, 1) or print $!;
@CompleteTechData = <IN> or print $!;;
close (IN);
&chopper (@CompleteTechData);

push (@CompleteTechData, @Military);


open (DATAIN, "$PlayerPath/money.txt");
$money = <DATAIN>;
close (DATAIN);
chop ($money);

open (DATAIN, "$PlayerPath/turns.txt");
$turns = <DATAIN>;
close (DATAIN);
chop ($turns);

$money = &Space($money);

print qqﬁ
<HTML>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<BODY bgcolor=#000000 text=#FFFFFF>
<FONT face=verdana size=-1>
<table width=100% border=1 cellspacing=0><TR><TD BGCOLOR=$Header><CENTER><B><FONT face=verdana size=-1>Technology</TD></TR></TABLE><BR>
<TABLE BORDER="1" WIDTH="100%" BORDER=1 CELLSPACING=0>
  <TR>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Current Funds:</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">\$$money</TD>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Turns Remaining:</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$turns</TD>
  </TR>
</TABLE><BR>
<FORM method="POST" action="http://www.bluewand.com/cgi-bin/classic/TechWrite.pl?$User&$Planet&$AuthCode">

<table border=1 cellspacing=0 width=25%><TR><TD bgcolor=$Header width=50%><FONT face=verdana size=-1>Scholars</td><td bgcolor=$Content><FONT face=arial size=-1>$Sci[0]</td></tr></table>ﬁ;
if (-e "$PlayerTechPath/Researcher.cpl") {
	print qq!<table border=1 cellspacing=0 width=25%><TR><TD bgcolor=$Header width=50%><FONT face=verdana size=-1>Researchers</td><td bgcolor=$Content><FONT face=arial size=-1>$Sci[1]</td></tr></table>!;
}

print qqﬁ<BR><Table width=100% border=1 cellspacing=0 bgcolor=$Content><TR bgcolor=$Header><TD><FONT face=verdana size=-1>Tech Name</TD><TD width=12%><FONT face=arial size=-1>Completed</TD><TD width=102><FONT face=arial size=-1>Percent Completed</TD><TD width=*><FONT face=arial size=-1>Scholars</TD>ﬁ;
if (-e "$PlayerTechPath/Researcher.cpl") {print qqﬁ<TD><FONT face=verdana size=-1>Researcher</TD>ﬁ}
if (-e "$PlayerTechPath/engineer.cpl") {print qqﬁ<TD><FONT face=verdana size=-1>Engineer</TD>ﬁ}
if (-e "$PlayerTechPath/scientist.cpl") {print qqﬁ<TD><FONT face=verdana size=-1>Scientist</TD>ﬁ}
print "<\/TR>";


#print @CompleteTechData;

foreach $Item (@CompleteTechData) {
	(@TechLine) = split(/\|/,$Item);

	if (@TechLine[0] == 1) {$Bump = 6} else {$Bump = 0}
	if (($Storage{@TechLine[2+$Bump]} == 1) and ($Storage{@TechLine[3+$Bump]} == 1) and ($Storage{@TechLine[4+$Bump]} == 1) and ($Storage{@TechLine[5+$Bump]} == 1)) {} 
	$Flag = 0;		

	foreach $UserTech (@TechData) {
		(@TechInfo) = split(/\|/,$UserTech);
		@TechInfo[1] =~ tr/ /_/;
		if (@TechInfo[0] == 1) {$Bump = 1} else {$Bump = 0}

		if (@TechInfo[1] eq @TechLine[0+$Bump]) {
			if (@TechInfo[2] < @TechInfo[3]) {
				$Flag = 1;
				if ($TechInfo[1] < $TechInfo[2]) {$GraphLength = int((($TechInfo[2]/$TechInfo[3]))*100)} else {$GraphLength = 0}
				$TimeLeft = qq!<IMG SRC="$GameKeepPath/images/graph2.gif" HEIGHT="12" WIDTH="$GraphLength">!;			
	
				if ($SendTech == 1 and @TechLine[0] != 1) {
					$Items = $Item;
					$Items =~ tr/ /_/;
#					$Sneak = qq!<TD><font face=verdana size=-1><a href="$Path?$User&$Planet&$AuthCode&$Alliance&$TechInfo[1]&a&11101" target ="Frame5" ONMOUSEOVER = "parent.window.status='Send tech for approval';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Send</a></TD>!;
				}

				$Formatted = @TechInfo[1];
				$Formatted =~ tr/_/ /;
				print qqﬁ\n<TR><TD><FONT face=verdana size=-1>$Formatted</TD><TD><FONT face=arial size=-1>$GraphLength%</TD><TD width=102><FONT face=arial size=-1>$begingraph$TimeLeft$endgraph</TD><TD><FONT face=arial size=-1><INPUT TYPE="text" name="$TechInfo[1]0" value="@TechInfo[4]" size=6></TD>ﬁ;
				if ($Storage{'Researcher'} == 1) {print qqﬁ<TD><FONT face=verdana size=-1><INPUT TYPE="text" name="$TechInfo[1]1" value="$TechLine[5]" size=6></TD>ﬁ}
				if ($Storage{'Engineer'} == 1) {print qqﬁ<TD><FONT face=verdana size=-1><INPUT TYPE="text" name="$TechInfo[1]2" value="$TechLine[6]" size=6></TD>ﬁ}
				if ($Storage{'Scientist'} == 1) {print qqﬁ<TD><FONT face=verdana size=-1><INPUT TYPE="text" name="$TechInfo[1]3" value="$TechLine[7]" size=6></TD>ﬁ}
	
				print qq!$Sneak</TR>!;
			} else {$Flag = 1}
		}
	}
	if ($Flag == 0) {
#		if ($User eq "Admin_One") {print qq!@TechLine[0] - ($Storage{@TechLine[2]} == 1) and ($Storage{@TechLine[3]} == 1) and ($Storage{@TechLine[4]} == 1) and ($Storage{@TechLine[5]} == 1)<BR>!}
		@TechLine[2] =~ tr/ /_/;
		@TechLine[3] =~ tr/ /_/;
		@TechLine[4] =~ tr/ /_/;
		@TechLine[5] =~ tr/ /_/;

		if (($Storage{@TechLine[2]} == 1) and ($Storage{@TechLine[3]} == 1) and ($Storage{@TechLine[4]} == 1) and ($Storage{@TechLine[5]} == 1)) {
			(@TechInfo) = split(/\|/,$Item);
			$GraphLength = 0;
			$Formatted = @TechLine[0];
			$Formatted =~ tr/_/ /;
			$TimeLeft = qq!<IMG SRC="$GameKeepPath/images/graph2.gif" HEIGHT="12" WIDTH="$GraphLength">!;
			print qqﬁ\n<TR><TD><FONT face=verdana size=-1>$Formatted</TD><TD><FONT face=arial size=-1>$GraphLength%</TD><TD width=102><FONT face=arial size=-1>$begingraph$TimeLeft$endgraph</TD><TD><FONT face=arial size=-1><INPUT TYPE="text" name="$TechLine[0]0" value="0" size=6></TD>ﬁ;
	
			if ($Storage{'Researcher'} == 1) {print qqﬁ<TD><FONT face=verdana size=-1><INPUT TYPE="text" name="$TechLine[0]1" value="0" size=6></TD>ﬁ}
			if ($Storage{'Engineer'} == 1) {print qqﬁ<TD><FONT face=verdana size=-1><INPUT TYPE="text" name="$TechLine[0]2" value="0" size=6></TD>ﬁ}
			if ($Storage{'Scientist'} == 1) {print qqﬁ<TD><FONT face=verdana size=-1><INPUT TYPE="text" name="$TechLine[0]3" value="0" size=6></TD>ﬁ}

			print qq!$Sneak</TR>!;
		}
	}
}

print qqﬁ
</table><Font size="-2"><CENTER>
<INPUT TYPE="submit" value="  Assign  ">
<FORM>
</body>
</html>
ﬁ;
sub CheckAll {
	local $TotCount;
	local $TestCount;
	$Counter = grep(/\|/,$ItemInfo[0]);
	(@Pass) = split(/\|/,$ItemInfo[0],5);
	$Num=0;
	$TestCount=0;
	while ($Num <= $#Pass) {
		if ($Counter == $Num) {$Pass[$Num] = substr($Pass[$Num],0,length($Pass[$Num])-1)}
		if ($Pass[$Num] eq "") {$TestCount++}
		$TotCount ++;
		if (grep(/$Pass[$Num]/,@CompletedTechs) > 0) {$TestCount++}
		$Num++;
	}
	if ($TestCount == $TotCount) {return 1} else {return 2}
}

#sub chopper{
#	foreach $k(@_) {
#		chop($k);
#	}
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

#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}


