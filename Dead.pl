#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$Target,$City)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);
$SF = qq!<font face=verdana size=-1>!;
$PlanetDir = $MasterPath . "/se/Planets/$Planet";
$AttackerDir = "$PlanetDir/users/$User";

open (IN, "$AttackerDir/Dead.txt");
@Data=<IN>;
close (IN);

if (@Data eq "") {@Data=qq!Our nation has been destroyed.!}
print qq!
<HTML>
<BODY BGCOLOR="#000000" TEXT="#FFFFFF">
$SF@Data
</html>
!;
