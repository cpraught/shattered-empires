#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode,$Mode,$To)=split(/&/,$ENV{QUERY_STRING});
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
	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

print qqﬁ
<HTML>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT><BODY bgcolor="#000000" text=white><center>
<table border=1 cellspacing=0 width=100%><TR><TD BGCOLOR=$Header><B><font face=verdana size=-1><center>Read Messages</td></tr></table><BR><BR>ﬁ;

if ($Mode == 110101) {
	if ($AuthCode eq "") {print qq!<script>history.back();</script>!} else {
	print qqﬁ<SCRIPT>window.open("http://www.bluewand.com/cgi-bin/classic/Message2.pl?$User&$Planet&$AuthCode&0&&$To",'SendMessage','scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,width=350,height=450');history.back();</SCRIPT>ﬁ;
	}
}

if ($Mode == 101101) {
	$MsgDir = $MasterPath . "/se/Planets/$Planet/users/$User/messages";

	opendir (DIR, $MsgDir);
	@Messages = readdir (DIR);
	sort (@Messages);
	closedir (DIR);

	foreach $Item (@Messages) {
		unless (-d "$MsgDir/$Item") {
			$MsgCount++;
			open (DATAIN, "$MsgDir/$Item");
			@Content = <DATAIN>;
			close (DATAIN);
			&chopper (@Content);
			$Content[0] =~ tr/_/ /;
			print  qqﬁ
			<FORM method=POST action="http://www.bluewand.com/cgi-bin/classic/MessageUtil.pl?$User&$Planet&$AuthCode&$Item">
			<Table width=60% border=1 cellspacing=0 bgcolor=$Content>
			<tr><TD width=50% bgcolor=$Header><font face=verdana size=-1><a href="http://www.bluewand.com/cgi-bin/classic/Message2.pl?$User&$Planet&$AuthCode&2&$Item" STYLE="text-decoration:none;color:white;" >$Content[0] (Click to Read)</a> </td><TD><CENTER><font face=arial size=-1>$Content[2]</td>
			<tr><TD colspan=2><font face=verdana size=-1><CENTER>$Content[3]</td>
			</table><font size=-2><input type=submit name=submit value=" Delete Message "></FORM><BR><BR>ﬁ;
		}
	}
}
if ($MsgCount < 1) {
	print qq!<table border=1 cellspacing=0 width=60%><TR><TD BGCOLOR=$Content><font face=verdana size=-1><center>No Messages</td></tr></table>!;
}
print qqﬁ</HTML>ﬁ;

#sub chopper{
#	foreach $k(@_){
#		chop($k);
#	}
#}
