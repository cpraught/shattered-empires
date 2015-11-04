#!/usr/bin/perl
print "Content-type: text/html\n\n";
&parse_form;

use File::Find;

print "Hello";

chdir("$data{'location_on_server'}");

foreach $key (keys(%data)){
if($key =~ m/\//){

finddepth(\&deltree,"$key");
rmdir($key);
}
else {
unlink(keys(%data));
}
}

#print"<SCRIPT>history.back();</SCRIPT>";

sub deltree {
$file = "$File::Find::dir/$_";
print $file;
unlink("$File::Find::dir/$_") or rmdir("$File::Find::dir/$_")
}

sub parse_form {

   # Get the input
   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

   # Split the name-value pairs
   @pairs = split(/&/, $buffer);

   foreach $pair (@pairs) {
      ($name, $value) = split(/=/, $pair);

      # Un-Webify plus signs and %-encoding
      $name =~ tr/+/ /;
      $name =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
      $name =~ s/<!--(.|\n)*-->//g;
      $name =~ s/<([^>]|\n)*>//g;
      $value =~ tr/+/ /;
      $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
      $value =~ s/<!--(.|\n)*-->//g;
      $value =~ s/<([^>]|\n)*>//g;         
      

      $data{$name} = $value;
      }
}
