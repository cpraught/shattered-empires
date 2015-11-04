#!/usr/bin/perl
require 'quickies.pl'



$address = "cpraught205\@rogers.com";

$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

&parse_form;
$data{'User'}  =~ tr/ /_/;
$blahs = $data{'User'};
$user_information = $MasterPath . "/User Information";

dbmopen(%emailaddress, "$user_information/emailaddress", 0777);
$adddy = $emailaddress{$blahs};
dbmclose(%emailaddress);


&sendmail;
print "Content-type: text/html\n\n";

print qq!
<body bgcolor=000000 text=white>
<table border=1 cellspacing=0 width=100%><TR><TD bgcolor="$Header"><font face=verdana size=-1><B><Center>Bug Report: Submitted</TD></TR></table>
<BR><BR><BR><BR><font face=verdana size=-1><Center>
Thank you for submitting this report.
!;
die;

sub sendmail {
$name=$data{'User'};
$name =~ tr/_/ /;
open(MAIL, "|/usr/sbin/sendmail $address") or die "Sorry could not run mail program.";
print MAIL "From: $adddy\n";
print MAIL "Subject: Bug Report\n\n";
print MAIL "Planet: $data{'Planet'}\n";
print MAIL "Country: $data{'User'}\n";
print MAIL "Bug Type: $data{'bugtype'}\n";
print MAIL "Description:\n";
print MAIL "$data{'description2'}\n";
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

#sub chopper {
#foreach $k (@_) {
#	chop($k);
#	}
#}
