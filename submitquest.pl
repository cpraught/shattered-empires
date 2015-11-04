#!/usr/bin/perl

$address = 'drink@moonshinehollow.com';

&parse_form;
&sendmail;

print "Location: http://www.golden.net/~hardi/faqb.html\r\n\r\n";
#print "Location: http://www.golden.net/~tufgar/xcompage/files/xpak1.zip\r\n\r\n";

sub sendmail {
open(MAIL, "|/usr/sbin/sendmail $address") or die "Sorry could not run mail program.";
print MAIL "Reply-to: $data{'emailaddress'}\n";
print MAIL "From: $data{'emailaddress'}\n";
print MAIL "Subject: Shattered Empires F.A.Q.\n\n";
print MAIL "Name: $data{'Name'}\n";
print MAIL "Question: $data{'question'}\n";
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

