#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode,$Mode)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);

unlink ($MasterPath . "/se/Planets/$Planet/users/$User/messages/$Mode");

print qq!Location: http://www.bluewand.com/cgi-bin/classic/Message.pl?$User&$Planet&$AuthCode&101101\r\n\r\n!;
