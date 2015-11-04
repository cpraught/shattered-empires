#!/usr/bin/perl
print "Content-type: text/html\n\n";
&parse_form;
@date = localtime;
$date[4]++;


$data{'To'} =~tr/ /_/;
$data{'handle'} =~tr/ /_/;
$path = "/home/admin/classic/se/Planets/$data{'planet'}/users/$data{'To'}/messages/";

chdir("$path") or &errorsub;
print"<SCRIPT>close()</SCRIPT>";
opendir (TEMP,'.');
@files=readdir(TEMP);
closedir(TEMP);
$messagenum="0";
while(-e "$messagenum.new" or -e "$messagenum.old") {
	$messagenum++;
}
open (MESSAGE,">$messagenum.new");
print MESSAGE "$date[2]:$date[1]:$date[0] - $date[3]/$date[4]/$date[5]\n";
print MESSAGE "$data{'handle'}\n";
print MESSAGE "$data{'Subject'}\n";
print MESSAGE "$data{'Message'}\n";
close(MESSAGE);
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
sub errorsub {
print "<SCRIPT>alert(\"Sorry that user could not be located on our system.  Check the name and please try again.\");history.back();</SCRIPT>";
die;
}

