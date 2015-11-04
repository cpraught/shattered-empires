#!/usr/bin/perl

&parse_form;
$data{'handle'} =~ tr/ /_/;
$user_information = "/home/admin/classic/se/User Information";

&check_for_valid_handle;
&check_for_valid_email;
&write_the_files;
&email_the_code;
print "Location: http://www.golden.net/~hardi/messagevalidate.html\r\n\r\n";

sub check_for_valid_handle{

if ($data{'handle'} =~ m/[^A-Z_a-z]/) {
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"You have attempted to use characters in your country name that are not valid.  Valid characters include all letters and space.\")\;history.back()</SCRIPT>";
	die;
}
dbmopen(%datain, "$user_information/accesscode", 0777);
if ($datain{$data{'handle'}} ne "") {
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"Sorry, there is already a nation in existance possessing that country name.  Please try with a new nation name.\")\;history.back()</SCRIPT>";
	dbmclose(%datain);
	die;
}

if ($data{'handle'} eq 'None' or $data{'handle'} eq "") {
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"Sorry, the country name you entered is invalid.  Please try again with a new name.\")\;history.back()</SCRIPT>";
	die;
}
}
sub check_for_valid_email{
dbmopen(%email, "$user_information/emailaddress", 0777);
foreach $k (values(%email)){
if($k eq $data{'emailaddress'}){
print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"Sorry, that e-mail address is in use.\")\;history.back()</SCRIPT>";
	die;
}
}
dbmclose(%email);
}


sub write_the_files {
srand();
$authcode = int(rand(9)).chr(int(rand(26)) + 65).chr(int(rand(26)) + 65).int(rand(9)).int(rand(9)).int(rand(9)).int(rand(9)).chr(int(rand(26)) + 65).chr(int(rand(26)) + 65).int(rand(9));
dbmopen(%datain, "$user_information/accesscode", 0777);
$datain{$data{'handle'}} = $authcode;
dbmclose(%datain);
dbmopen(%writemail, "$user_information/emailaddress", 0777);
$writemail{$data{'handle'}} = $data{'emailaddress'};
dbmclose(%writemail);
}


sub email_the_code {
srand();
$authcode = int(rand(9)).chr(int(rand(26)) + 65).chr(int(rand(26)) + 65).int(rand(9)).int(rand(9)).int(rand(9)).int(rand(9)).chr(int(rand(26)) + 65).chr(int(rand(26)) + 65).int(rand(9));
open(MAIL, "|/usr/sbin/sendmail $data{'emailaddress'}") or die "Sorry could not run mail program.";
print MAIL "Reply-to: shattered.empires\@canada.com\n";
print MAIL "From: Shattered Empires E-mail Verification Script\n";
print MAIL "Subject: E-Mail Verification\n\n";
print MAIL "Shattred Empires:\n";
$data{'handle'} =~tr/_/ /;
print MAIL "This is the authorization code for $data{'handle'}:\n";
print MAIL $authcode."\n";
print MAIL "http://www.golden.net/~hardi/\n";
close(MAIL);
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
