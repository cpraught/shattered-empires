#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

$user_information = $MasterPath . "/User Information";

$Planet = $ENV{QUERY_STRING};
&parse_form;
use File::Find;
foreach $key(keys(%data)){
	$key =~ tr/"%27"/\'/;
	print $key;
	$userdir = $MasterPath . "/se/Planets/$Planet/users/$key";
	chdir('../../');
	finddepth(\&deltree,"$userdir");
	rmdir("$userdir");
	&RemoveData;
}
#print"<SCRIPT>history.back()</SCRIPT>";

sub deltree {
$file = "$File::Find::dir/$_";
unlink("$File::Find::dir/$_") or rmdir("$File::Find::dir/$_")
}

sub RemoveData {
dbmopen(%password, "$user_information/password",0777);
delete($password{$key});
dbmclose(%password);

dbmopen(%accesscode, "$user_information/accesscode",0777);
delete($accesscode{$key});
dbmclose(%accesscode);

dbmopen(%emailaddress, "$user_information/emailaddress",0777);
delete($emailaddress{$key});
dbmclose(%emailaddress);

dbmopen(%planet, "$user_information/planet",0777);
delete($planet{$key});
dbmclose(%planet);

dbmopen(%ip, "$user_information/ip",0777);
delete($ip{$key});
dbmclose(%ip);

dbmopen(%date, "$user_information/date",0777);
delete($date{$key});
dbmclose(%date);
}
sub parse_form {

   # Get the input
   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

   # Split the name-value pairs
   @pairs = split(/&/, $buffer);

   foreach $pair (@pairs) {
      ($name, $value) = split(/=/, $pair);

      # Un-Webify plus signs and %-encoding
      $value =~ tr/+/ /;
      $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
      $value =~ s/<!--(.|\n)*-->//g;
      $value =~ s/<([^>]|\n)*>//g;
         
      

      $data{$name} = $value;
      }
}
