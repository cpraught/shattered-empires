#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode,$Alliance)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);

$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";


$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
$HomePath = $MasterPath . "/se/Planets/";

open (IN, "$AlliancePath/members.txt");
@Members = <IN>;
close (IN);
&chopper (@Members);

$LeaderFlag = $LCounter = 0;

foreach $Item (@Members) {
	($Rank,$Leader,$Blah) = split(/\|/,$Item);


	if (substr ($Item, 0, 1) eq "0" && (-e "$HomePath/$Blah/users/$Leader")) {$LCounter ++;}
	if ($Leader eq $User && $Rank == 0) {
		$LeaderFlag = 1;
	} elsif ($Leader eq $User && $Rank == 1) {
		$LeaderFlag = 3;
	} elsif ($Leader eq $User && $Rank > 1) {
		$LeaderFlag = 2;
	}
}


if ($LCounter == 0 && $LeaderFlag == 3) {
	$LeaderFlag = 1;
}
unless ($LeaderFlag == 1) {
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/AllyDisplay.pl?$User&$Planet&$AuthCode&$Alliance\r\n\r\n!;
	die;
}

print "Content-type: text/html\n\n";
$Path  = "AllyLetter.pl";
$Path2 = "AllyUtil.pl";
$AllyPath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
$AllyTekPath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance/tech";
$NAlliance = $Alliance;
$NAlliance =~ tr/_/ /;
&parse_form;

open (DATAIN, "$AllyPath/ranks.txt");
flock (DATAIN, 1);
@Ranks = <DATAIN>;
close (DATAIN);
&chopper (@Ranks);

if ($data{'one'} ne "")   {@Ranks[0] = $data{'one'}}
if ($data{'two'} ne "")   {@Ranks[1] = $data{'two'}}
if ($data{'three'} ne "") {@Ranks[2] = $data{'three'}}
if ($data{'four'} ne "")  {@Ranks[3] = $data{'four'}}
if ($data{'five'} ne "")  {@Ranks[4] = $data{'five'}}
if ($data{'six'} ne "")   {@Ranks[5] = $data{'six'}}

if ($data{'AllianceMessage'} ne "") {
	open (OUT, ">$AllyPath/message.txt");
	flock (OUT, 2);
	print OUT qq£$data{'AllianceMessage'}\n£;
	close (OUT);
}

if ($data{'AllianceMessage'} eq "") {
	open (IN, "$AllyPath/message.txt");
	flock (IN, 1);
	$AllianceMessage = <IN>;
	close (IN);
} else {$AllianceMessage=$data{'AllianceMessage'}}

open (DATAOUT, ">$AllyPath/ranks.txt");
flock (DATAOUT, 2);
foreach $WriteLine (@Ranks) {
	print DATAOUT "$WriteLine\n";
}
close (DATAOUT);

open (DATAIN, "$AllyPath/applicant.txt");
flock (DATAIN, 1);
@Apps = <DATAIN>;
close (DATAIN);
&chopper (@Apps);

foreach $Run (@Apps) {
	($Ap,$Plan) = split(/\|/,$Run);
	$Applicants{$Ap} = $Plan;
}

open (DATAIN, "$AllyPath/members.txt");
flock (DATAIN, 1);
@Apps = <DATAIN>;
close (DATAIN);
&chopper (@Apps);
$Numbers=0;

foreach $Run (@Apps) {
	($Rank,$Member,$Planets2) = split(/\|/,$Run);
	$Members = $Member;
	$Members =~ tr/_/ /;
	@Options[$Numbers] = qqﬁ<OPTION VALUE=$Member>$Members</OPTION>ﬁ;
	$Numbers++;
}

print qqﬁ
<html>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<body BGCOLOR="#000000" text="#FFFFFF">
<table border=1 cellspacing=0 width=100%><TR><TD BGCOLOR="$Header"><CENTER><B><font FACE="Arial" size="-1">Set Alliance Stats</font></TD></TR></TAble><BR><BR>
<CENTER>

<Table border=0 width=100%><TR height=60><TD width=50%>
<table border=1 cellspacing=0 width=100%>
<TR><TD BGCOLOR="$Header"><Center><font face=verdana size=-1>Disband Alliance</TD></TR>
<TR valign=top><TD BGCOLOR="$Content" valign=middle><Center><font face=verdana size=-1><img src="http://www.bluewand.com/classic/images/Ingame/invis.gif" height=20 width=1><a href="http://www.bluewand.com/cgi-bin/classic/AllyUtil.pl?$User&$Planet&$AuthCode&$Alliance&&1&22111"  target ="Frame5" ONMOUSEOVER = "parent.window.status='Disband Alliance';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Click to disband Alliance</a></TD></TR>
</table></TD><TD width=50%>
<table border=1 cellspacing=0 width=100%>
<TR><TD BGCOLOR="$Header"><Center><font face=verdana size=-1>Transfer Leadership</TD></TR>
<form method=post action="http://www.bluewand.com/cgi-bin/classic/AllyUtil2.pl?$User&$Planet&$AuthCode&$Alliance&blah&1&10101"><TR valign=top height=10><TD BGCOLOR="$Content"><Center><font face=verdana size=-2><select name=transfer>@Options</select> <input type=submit value="Transfer" name=submit2></TD></form></TR>
</table></TD></TR></table>
<BR>
<FORM method="POST" action="http://www.bluewand.com/cgi-bin/classic/AllySet.pl?$User&$Planet&$AuthCode&$Alliance">
<table border=1 cellspacing=0 width=60%>
<TR BGCOLOR="$Header"><TD><font FACE="Arial" size="-1">Rank One</TD><TD><font FACE="Arial" size="-1">Rank Two</TD><TD><font FACE="Arial" size="-1">Rank Three</TD><TR>
<TR BGCOLOR="$Content"><TD><font FACE="Arial" size="-1"><INPUT TYPE="text" size="20" name=one value="@Ranks[0]"></TD><TD><font FACE="Arial" size="-1"><INPUT TYPE="text" size="20" name=two value="@Ranks[1]"></TD><TD><font FACE="Arial" size="-1"><INPUT TYPE="text" size="20" name=three value="@Ranks[2]"></TD><TR>
<TR BGCOLOR="$Header"><TD><font FACE="Arial" size="-1">Rank Four</TD><TD><font FACE="Arial" size="-1">Rank Five</TD><TD><font FACE="Arial" size="-1">Rank Six</TD><TR>
<TR BGCOLOR="$Content"><TD><font FACE="Arial" size="-1"><INPUT TYPE="text" size="20" name=four value="@Ranks[3]"></TD><TD><font FACE="Arial" size="-1"><INPUT TYPE="text" size="20" name=five value="@Ranks[4]"></TD><TD><font FACE="Arial" size="-1"><INPUT TYPE="text" size="20" name=six value="@Ranks[5]"></TD><TR>
</table><BR><BR></center>
<Font face=verdana>
Applicants
<table border=0 cellspacing=0 width=100%>
<TR><TD width=80%>
<table border=1 cellspacing=0 width=100%>
<TR BGCOLOR="$Header"><TD><font FACE="Arial" size="-1">Nations Name</TD><TD><font FACE="Arial" size="-1">Read Message</TD><TD><font FACE="Arial" size="-1">View National Statistics</TD></TR>ﬁ;
foreach $Item (keys(%Applicants)) {
	$ApCount++;
	$Aps = $Item;
	$Aps =~ tr/_/ /;
#<a href="$Path?$User&$Planet&$AuthCode&$Alliance" target ="Frame5" ONMOUSEOVER = "parent.window.status='Application Message';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">
	print qqﬁ
<TR BGCOLOR="$Content"><TD><font FACE="Arial" size="-1">$Aps</TD><TD><font FACE="Arial" size="-1"><a href="$Path?$User&$Planet&$AuthCode&$Alliance&$Item&$Applicants{$Item}" target ="Frame5" ONMOUSEOVER = "parent.window.status='Application Message';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Message</a></TD><TD><font FACE="Arial" size="-1">View National Statistics</TD></TR>ﬁ;
}
if ($ApCount < 1) {
print qq!<TR><TD BGCOLOR=$Content colspan=3><font FACE="Arial" size="-1"><CENTER>There are currently no applicants</center></TD></TR>!;
}
print qqﬁ
</table></TD><TD><BR>
<table border=1 cellspacing=0 width=100%>ﬁ;
foreach $Item (keys(%Applicants)) {
	$Aps = $Item;
	$Aps =~ tr/_/ /;
	print qqﬁ
<TR>
<TD BGCOLOR=$Content><font FACE="Arial" size="-1"><a href="$Path2?$User&$Planet&$AuthCode&$Alliance&$Item&$Applicants{$Item}&10101" target ="Frame5" ONMOUSEOVER = "parent.window.status='Accept $Aps';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Accept</a></TD>
<TD BGCOLOR=$Content><font FACE="Arial" size="-1"><a href="$Path2?$User&$Planet&$AuthCode&$Alliance&$Item&$Applicants{$Item}&10111" target ="Frame5" ONMOUSEOVER = "parent.window.status='Accept $Aps';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Reject</a></TD>
</TR>ﬁ;
}
print qqﬁ
</table>
</TD></TR></table>
<BR><BR>
<font face=verdana>Members
<table border=1 cellspacing=0 width=60% bgcolor=$Content>
<TR bgcolor=$Header><TD><font face=verdana size=-1>Member</TD><TD><font face=arial size=-1>Rank</TD><TD><font face=arial size=-1>Expel Member</TD><TD><font face=arial size=-1>Last Played</TD></TR>ﬁ;

open (OUT, ">$AllyPath/members.txt");
foreach $Run (@Apps) {
	($Rank,$Member,$MPlanet) = split(/\|/,$Run);
	$Members = $Member;
	if ($data{$Members} ne "") {$Rank=$data{$Members}}
	print OUT "$Rank\|$Members\|$MPlanet\n";
	$Member =~ tr/_/ /;
	if ($Rank == 0) {$a = "SELECTED";$b=$c=$d=$e=$f=""}
	if ($Rank == 1) {$b = "SELECTED";$a=$c=$d=$e=$f=""}
	if ($Rank == 2) {$c = "SELECTED";$b=$a=$d=$e=$f=""}
	if ($Rank == 3) {$d = "SELECTED";$b=$c=$a=$e=$f=""}
	if ($Rank == 4) {$e = "SELECTED";$b=$c=$d=$a=$f=""}
	if ($Rank == 5) {$f = "SELECTED";$b=$c=$d=$e=$a=""}

	if ($Rank == 0) {
	@RankOptions = qqﬁ<OPTION VALUE=0 $a>$Ranks[0]</OPTION></select>ﬁ;
	} else {
@RankOptions = qqﬁ
<OPTION VALUE=0 $a>$Ranks[0]</OPTION>
<OPTION VALUE=1 $b>$Ranks[1]</OPTION>
<OPTION VALUE=2 $c>$Ranks[2]</OPTION>
<OPTION VALUE=3 $d>$Ranks[3]</OPTION>
<OPTION VALUE=4 $e>$Ranks[4]</OPTION>
<OPTION VALUE=5 $f>$Ranks[5]</OPTION></select>ﬁ;
}
	$MemberPath = $MasterPath . "/se/Planets/$MPlanet/users/$Member";
	$ExpelLink = qqﬁ<a href="http://www.bluewand.com/cgi-bin/classic/AllyUtil2.pl?$User&$Planet&$AuthCode&$Alliance&$Members&&11101" target ="Frame5" ONMOUSEOVER = "parent.window.status='Expel Member';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Expel $Member</a>ﬁ;
	$MailLink = qqﬁ<a href="http://www.bluewand.com/cgi-bin/classic/Message.pl?$User&$Planet&$AuthCode&110101&$Member"target ="Frame5" ONMOUSEOVER = "parent.window.status='Mail Member';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">$Member</a>ﬁ;
	$Age = int(-C "$MemberPath/turns.txt");

	print qqﬁ<TR bgcolor=><TD><font face=verdana size=-1>$MailLink</TD><TD><font face=verdana size=-2><center><select name=$Members>@RankOptions</TD><TD><font face=arial size=-1>$ExpelLink</TD><TD><font face=arial size=-1><center>$Age days ago</TD></TR>ﬁ;
}
close (OUT);

if (-e "$AllyPath/Faction.txt") {

	print qqﬁ
</table><BR><BR>

<table width=100% border=1 cellspacing=0>
<TR><TD bgcolor=$Header><Center><font face=verdana size=-1>Alliance-Wide Message</td></tr>
<Tr><TD bgcolor=$Content><font face=verdana size=-1><center><textarea name="AllianceMessage" wrap=virtual cols=70 rows=5>$AllianceMessage</textarea></TD></TR>
</table>

<font face=verdana>Shared Technology<BR>
<Table border=1 cellspacing=0 width=60% bgcolor=$Content>ﬁ;
	opendir (DIR, "$AllyTekPath");
	@AllyTeks = readdir (DIR);
	closedir (DIR);

	foreach $Item (@AllyTeks) {
		if ($Item ne '.' and $Item ne '..') {
			if ($Item =~ /.apl/i) {
				$Itema = $Item;
				$Item =~ s/.apl//;
				$Itema =~ tr/ /_/;
				$Option = qqﬁ<a href="$Path2?$User&$Planet&$AuthCode&$Alliance&$Itema&1&11111" target ="Frame5" ONMOUSEOVER = "parent.window.status='Begin Shared Research';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Begin Cooperating</a>ﬁ;
				$Img = qq!<Td><Center><IMG SRC="http://www.shatteredempires.com/SE/images/notstarted2.gif"></TD>!;
			}
			else {
				open (IN, "$AllyTekPath/$Item");
				@Infos = <IN>;
				close (IN);
				&chopper (@Infos);
				$Itema = $Item;
				$Itema =~ tr/ /_/;
				if (@Infos[1] >= @Infos[0] and @Infos[1] != 0) {
					$Option = qqﬁ<a href="$Path2?$User&$Planet&$AuthCode&$Alliance&$Itema&1&21111" target ="Frame5" ONMOUSEOVER = "parent.window.status='Distribute Completed Technology';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Distribute</a>ﬁ;
					$Img = qq!<Td><Center><IMG SRC="http://www.shatteredempires.com/SE/images/finished2.gif"></TD>!;
				} else {
					if (@Infos[1] != 0) {
						$Opt = int((@Infos[1]/@Infos[0])*100);
					} else {$Opt = 0}
					$Option = qqﬁ$Opt% Completedﬁ;
					$Img = qq!<Td><Center><IMG SRC="http://www.shatteredempires.com/SE/images/inprogress2.gif"></TD>!;
				}
				$Item =~ s/.wrk//;
			}
			print qqﬁ<TR>$Img<TD><FONT face=verdana size=-1>$Item</TD><TD><FONT face=arial size=-1>$Option</TD></TR>ﬁ;
		}
	}
} else {$Tank = 1}

print qqﬁ</table></font><BR>ﬁ;

if ($Tank == 1) {
print qq!

<table width=100% border=1 cellspacing=0>
<TR><TD bgcolor=$Header><Center><font face=verdana size=-1>Alliance-Wide Message</td></tr>
<Tr><TD bgcolor=$Content><font face=verdana size=-1><center><textarea name="AllianceMessage" wrap=virtual cols=70 rows=5>$AllianceMessage</textarea></TD></TR>
</table><BR><BR>
<center>
<Table width=50% border=1 cellspacing=0><TR><TD bgcolor="$Content"><center><FONT face=verdana size=-1><A href="http://www.bluewand.com/cgi-bin/classic/AllyFaction.pl?$User&$Planet&$AuthCode&$Alliance" target ="Frame5" ONMOUSEOVER = "parent.window.status='Alliance Application';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Apply for Alliance Status</A></TD></TR></table><BR><BR>!;
}
print qqﬁ
<center><font size=-1><input type=submit name=submit value="Make Changes">
</FORM>
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

#
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
