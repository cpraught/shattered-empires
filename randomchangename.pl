#!/usr/bin/perl
print "Content-type: text/html\n\n";

$user_information = "/home/bluewand/data/classic/User Information";

$Planet = $ENV{QUERY_STRING};
&parse_form;
use File::Find;

opendir (DIR, "/home/bluewand/data/classic/se/Planets/$Planet/alliances");
@Entry = readdir (DIR);
closedir (DIR);

foreach $key (@Entry){
	if ($key ne "." and $key ne "..") {
		$key =~ tr/"%27"/\'/;
		print $key;
		$userdir = "/home/bluewand/data/classic/se/Planets/$Planet/alliances/$key";
		chdir('../');
		finddepth(\&deltree,"$userdir");
		rmdir("$userdir");
	}
}
#print"<SCRIPT>history.back()</SCRIPT>";

sub deltree {
	$file = "$File::Find::dir/$_";
	print "$file<BR>";

unlink("$File::Find::dir/$_") or rmdir("$File::Find::dir/$_")
}

print "Alliances deleted.<BR>";

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
