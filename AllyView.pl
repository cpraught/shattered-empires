#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

$Type{'10111'} = "Charter";
$Type{'11011'} = "History";

($User,$Planet,$AuthCode,$Alliance,$Mode)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);

$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

$Path = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
$NAlliance = $Alliance;
$NAlliance =~ tr/_/ /;

if ($Mode == 10111) {
	if (-e "$Path/charter.txt") {
		open (IN, "$Path/charter.txt");
		@Information = <IN>;
		close (IN)
		&chopper (@Information);
		&dirty(@Information);
	} else {
		@Information = "$NAlliance does not have a written charter.";
	}
}  
if ($Mode == 11011) {
	if (-e "$Path/history.txt") {
		open (IN, "$Path/history.txt");
		@Information = <IN>;
		close (IN)
		&chopper (@Information);
		&dirty(@Information);
	} else {
		@Information = "$NAlliance does not have a written history.";
	}
} 

print qqﬁ
<BODY bgcolor=000000 text=white>
<HTML><Font face=verdana size=-1>
<Table width=100% border=1 cellspacing=0><TR><TD BGCOLOR=$Header><Center><B><font face=verdana size=-1>$Type{$Mode}</TD></TR></table>
<BR><BR>
@Information
</HTML>
</BODY>
ﬁ;

#sub chopper{
#	foreach $k(@_){
#		chop($k);
#	}
#}
#
#

sub dirty {
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
