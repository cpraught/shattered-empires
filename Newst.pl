#!/usr/bin/perl
require 'quickies.pl'

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
$user_information = $MasterPath . "/User\ Information";
print "Content-type: text/html\n\n";

print qq!
<HTML>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
!;

print qq!

<FRAMESET BORDER =0 ROWS= "70%,*">
  <FRAME SRC="Newsf1.pl?$ENV{QUERY_STRING}" NAME="top">
  <FRAME SRC="Newsf2.pl?$ENV{QUERY_STRING}" NAME="bottom">
</FRAMESET>
</HTML>
!;

