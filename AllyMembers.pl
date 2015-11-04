#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode,$Alliance)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);

$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";


$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
open (IN, "$AlliancePath/members.txt");
@Members = <IN>;
close (IN);
&chopper (@Members);
foreach $Item (@Members) {
	($Rank,$User2,$Planet2) = split(/\|/,$Item);
	if ($User2 eq $User) {$ExistFlag = 1}
}
unless ($ExistFlag == 1) {
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/Allys.pl?$User&$Planet&$AuthCode\r\n\r\n!;
}

print "Content-type: text/html\n\n";
open (DATAIN, "$AlliancePath/ranks.txt");
@Ranks = <DATAIN>;
close (DATAIN);
&chopper (@Ranks);
open (DATAIN, "$AlliancePath/members.txt");
@Apps = <DATAIN>;
close (DATAIN);
&chopper (@Apps);

open (IN, "$AlliancePath/message.txt");
@MessageFromFounder = <IN>;
close (IN);

&Dirty(@MessageFromFounder);

print qqﬁ
<html>
<SCRIPT>parent.frames[1].location.reload()</SCRIPT>
<body BGCOLOR="#000000" text="#FFFFFF">
<table border=1 cellspacing=0 width=100%><TR><TD BGCOLOR="$Header"><CENTER><B><font FACE="Arial" size="-1">Member Page</font></TD></TR></TAble><BR><BR>

<center>
<table border=1 cellspacing=0 width=50%>
<TR><TD BGCOLOR="$Header"><Center><font face=verdana size=-1>Resign Membership</TD></TR>
<TR valign=top><TD BGCOLOR="$Content"><Center><font face=verdana size=-1><a href="http://www.bluewand.com/cgi-bin/classic/AllyUtil2.pl?$User&$Planet&$AuthCode&$Alliance&&1&11111"  target ="Frame5" ONMOUSEOVER = "parent.window.status='Withdraw Membership';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:808080">Withdraw Membership</a></TD></TR>
</table></center><BR><BR>

<table bgcolor=$Header cellspacing=0 border=1 width=100%>
<TR><TD><b><font face=verdana size=-1><Center>Message From Founder</td></TR>
<TR><TD bgcolor=$Content><font face=verdana size=-1>@MessageFromFounder</TD></TR>
</table><BR><BR>

<table width=100% border=0  cellspacing=0>
<TR><TD width=50% valign=top>

	<table width=100% border=1 bgcolor=666666 cellspacing=0>
	<TR><TD bgcolor=333333><font face=arial size=-1>Enemy</TD></TR>ﬁ;

	open (IN, "$AlliancePath/Enemy.txt");
	flock (IN, 1);
	@EnemyAlliances = <IN>;
	close (IN);

	foreach $One (@EnemyAlliances) {
		$One =~ tr/_/ /;
		print "<TR><TD><font face=arial size=-1>$One</TD></TR>";
	}

print qq!
	</table>
</TD><TD width=50% valign=top>
	<table width=100% border=1 bgcolor=666666 cellspacing=0>
	<TR><TD bgcolor=333333><font face=arial size=-1>Allied</TD></TR>!;


	open (IN, "$AlliancePath/Ally.txt");
	flock (IN, 1);
	@EnemyAlliances = <IN>;
	close (IN);

	foreach $One (@EnemyAlliances) {
		$One =~ tr/_/ /;
		print "<TR><TD><font face=arial size=-1>$One</TD></TR>";
	}

print qqﬁ
	</table>
</TD></TR></table><BR><BR>




<font face=verdana size=-1>Member List
<table border=1 cellspacing=0 width=60% bgcolor=$Content>
<TR bgcolor=$Header><TD><font face=verdana size=-1>Member</TD><TD><font face=arial size=-1>Rank</TD></TR>ﬁ;

foreach $Run (@Apps) {
	($Rank,$Member,$MPlanet) = split(/\|/,$Run);
	$Members = $Member;
	if ($data{$Members} ne "") {$Rank=$data{$Members}}
	$Member =~ tr/_/ /;


	$MailLink = qqﬁ<a href="http://www.bluewand.com/cgi-bin/classic/Message.pl?$User&$Planet&$AuthCode&110101&$Member"target ="Frame5" ONMOUSEOVER = "parent.window.status='Mail Member';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">$Member</a>ﬁ;

	print qqﬁ<TR bgcolor=><TD><font face=verdana size=-1>$MailLink</TD><TD><font face=arial size=-1><center>$Ranks[$Rank]</TD></TR>ﬁ;
}
close (OUT);

print qqﬁ
</table><BR><BR>ﬁ;

#
#sub chopper{
#	foreach $k(@_){
#		chop($k);
#	}
#}


sub Dirty {
	foreach $text (@_) {
		$text =~ s/\cM//g;
		$text =~ s/\n\n/<p>/g;
		$text =~ s/\n/<br>/g;
		$text =~ s/&lt;/</g; 
		$text =~ s/&gt;/>/g; 
		$text =~ s/&quot;/"/g;
	}
	return @_;
}
