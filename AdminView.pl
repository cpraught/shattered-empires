#!/usr/bin/perl
require 'quickies.pl'
($Mode, $Alliance, $Planet) = split (/&/, $ENV{QUERY_STRING});

print "Content-type: text/html\n\n";

$Type{'10111'} = "Charter";
$Type{'11011'} = "History";
$Type{'10011'} = "Summary";



$Header = "#333333";
$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

$Path = $MasterPath . "/Planets/$Planet/alliances/$Alliance";
$NAlliance = $Alliance;
$NAlliance =~ tr/_/ /;

if ($Mode == 10011) {
	if (-e "$Path/summary.txt") {
		open (IN, "$Path/summary.txt");
		@Information = <IN>;
		close (IN)
		&chopper (@Information);
		&dirty(@Information);
	} else {
		@Information = "$NAlliance does not have a written Summary.";
	}
}  


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


print qq!
<HTML><BODY bgcolor=000000 text=white>
<Font face=verdana size=-1>
<Table width=100% border=1 cellspacing=0><TR><TD BGCOLOR=$Header><Center><B><font face=verdana size=-1>$Type{$Mode}</TD></TR></table>
<BR><BR>
@Information
</HTML>
</BODY>
!;

# in quickies, deletable?
#sub chopper{
#	foreach $k(@_){
#		chop($k);
#	}
#}


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
ÿÿÿÿ
