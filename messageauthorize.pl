#!/usr/bin/perl

$user_information = "/home/admin/classic/se/User Information";
$worlddir="/home/admin/classic/se/Planets/";

&parse_form;
$data{'handle'} =~ tr/ /_/;
&check_code;
&write_data;
print "Location: http://www.bluewand.com/cgi-bin/classic/messageboard.pl\r\n\r\n";

sub check_code{
dbmopen(%datain, "$user_information/accesscode", 0777);
if ($datain{$data{'handle'}} ne $data{'author'}) {
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"Sorry, That code does not match the one on record.\")\;history.back()</SCRIPT>";
	dbmclose(%datain);
	die;
}
dbmclose(%datain);
}

sub write_data{
dbmopen(%password, "$user_information/password", 0777);
$password{$data{'handle'}}=$data{'password'};
dbmclose(%password);
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
