#!/usr/bin/perl
print "Content-type: text/html\n\n";

&parse_form;

$path="/home/admin/classic/se/Planets/$data{'Planet'}/users/$data{'User'}";

open(DATA, ">$path/notallowed.txt") and print "$user successfully blocked." or print "$user not blocked.";
close(DATA);

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

