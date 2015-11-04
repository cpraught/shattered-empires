#!/usr/bin/perl

($User,$Planet,$Authcodes,$Unit,$Name)=split(/&/,$ENV{QUERY_STRING});
$user_information = "/home/admin/classic/se/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if($Authcodes ne $authcode{$User}){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}

$TechPath = "/home/admin/classic/se/Planets/$Planet/users/$User/research";

$Unit =~ tr/_/ /;
unlink ("$TechPath/$Unit");
$SF = qq!<font face=verdana size=-1>!;
$Name =~ tr/_/ /;
print "Content-type: text/html\n\n";
print qq!
<body bgcolor="#000000" text=white><BR><BR><BR><center>$SF The unit type '$Name' has been removed from research.<BR>!;
