#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$Authcodes)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if($Authcodes ne $authcode{$User} || $Authcodes eq ""){
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}

$PlayerPath = "/home/bluewand/data/classic/Planets/$Planet/users";
$AllyPath = "/home/bluewand/data/classic/Planets/$Planet/alliances";
open (IN, "$PlayerPath/$User/apply.txt");
flock (IN, 1);
$AllyName = <IN>;
close (IN);
chomp ($AllyName);

open (IN, "$AllyPath/$AllyName/apply.txt");
flock (IN, 1);
@AllyData = <IN>;
close (IN);
&chopper (@AllyData);

Pax_Mortis|SystemOne-Clarica

open (OUT, ">"$AllyPath/$AllyName/apply.txt");
flock (OUT, 2);
foreach $Item (@AllyData) {
	@Array = split (/\|/,$Item);
	unless ($Array[0] eq "$User") {print OUT "$Item\n"}
}
close (OUT);

unlink ("$AllyPath/$AllyName/apply.txt");
