#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";


$UserInfo = $MasterPath . "/User Information";
$UsrPath = $MasterPath . "/se/Planets/";

dbmopen (%datain2, "$UserInfo/accesscode", 0777) or print "Code - $!<BR>";
foreach $Item (sort(keys(%datain2))) {
	unless (-d "$UsrPath/SystemOne-Gaia/users/$Item") {
		&RemoveInfo;		
		print qq!$Item - Removed<BR>!;
	}
}
dbmclose (%datain2);


sub RemoveInfo 
{
	#AccessCode
	dbmopen(%datain, "$UserInfo/accesscode", 0777) or print "Code - $!<BR>";
	delete($datain{$Item});
	dbmclose(%datain);

	#Email Address
	dbmopen(%datain, "$UserInfo/emailaddress",0777) or print "Code - $!<BR>";;
	delete($datain{$Item});
	dbmclose(%datain);

	#Password
	dbmopen(%password, "$UserInfo/password",0777) or print "Code - $!<BR>";;
	delete($password{$Item});
	dbmclose(%password);

	#Planet
	dbmopen(%planet, "$UserInfo/planet",0777) or print "Code - $!<BR>";;
	delete($planet{$Item});
	dbmclose(%planet);

	#IP
	dbmopen(%ip, "$UserInfo/ip",0777) or print "Code - $!<BR>";;
	delete($ip{$Item});
	dbmclose(%ip);

	#Date
	dbmopen(%date, "$UserInfo/date",0777) or print "Code - $!<BR>";;
	delete($date{$Item});
	dbmclose(%date);

	#Httphost
	dbmopen(%httphost, "$UserInfo/httphost",0777) or print "Code - $!<BR>";;
	delete($httphost{$Item});
	dbmclose(%httphost);
}
