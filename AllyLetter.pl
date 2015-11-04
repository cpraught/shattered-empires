#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$Alliance,$Sender,$Land)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}

$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

dbmclose(%authCode);
$Path = $MasterPath . "/se/Planets/$Land/users/$Sender";
open (DATAIN, "$Path/apply.txt");
$Senders = <DATAIN>;
@Text = <DATAIN>;
close (DATAIN);

&dirty(@Text);

$Sender =~ tr/_/ /;
print qqﬁ
<HTML>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<BODY>
<body BGCOLOR="#000000" text="#FFFFFF">
<table border=1 cellspacing=0 width=100%><TR><TD BGCOLOR="$Header"><CENTER><B><font FACE="Arial" size="-1">Application Message</font></TD></TR></Table><BR><BR>
<font FACE="Arial" size="-1">
Message from $Sender<BR><BR>
@Text
ﬁ;


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
