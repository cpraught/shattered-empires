#!/usr/bin/perl
require 'quickies.pl'

#print "Content-type: text/html\n\n";


&parse_form;
#print %data;
	$planet	= $data{'planet'};
	$user = $data{'user'};
	$totalresearchers = $data{'totalresearchers'};
	
	$user_information = "/home/admin/classic/se/User Information";
	$UserResearchPath = "/home/admin/classic/se/Planets/$planet/users/$user/research/";
	$UserDir = "/home/admin/classic/se/Planets/$planet/users/$user/";
	$MainResearchPath = "home/shatteredempires/SE/research/";

	chdir($UserDir);
	open(INPUT, 'tr.txt');
	$tr = <INPUT>;
	close(INPUT);

	delete $data{'purchase'};
	delete $data{'user'};
	delete $data{'planet'};
	delete $data{'totalresearchers'};
	delete $data{'TR'};

	foreach $k (keys(%data)){
	$totalpoints += $data{$k};
	}

	dbmopen(%authcode, "$user_information/accesscode", 0777);
	$authcode = $authcode{$user};
	dbmclose(%authcode);
	
	chdir ("$UserDir");
	if ($totalresearchers >= 0) {
		open(OUTPUT, ">research.txt");
		print OUTPUT $totalresearchers;
		close(OUTPUT);
	}
	else {
		print "Location: http://www.bluewand.com/cgi-bin/classic/tech.pl?$user&$planet&$authcode\r\n\r\n";
	}

	foreach $k (keys(%data)) {
		$flag = 0;
		if(-f "$UserResearchPath$k.pro") {
			open(INPUT, "$UserResearchPath$k.pro") or print "Cannot open";
			@file = <INPUT>;
			close(INPUT);
			chop($file[0]);
			if($file[0] == $data{$k}) {next}
			$file[0] = "$data{$k}\n";
			open(OUTPUT, ">$UserResearchPath$k.pro");
			print OUTPUT @file;
			close(OUTPUT);
			$flag = 1;
		}	
		$k =~ tr/ /_/;
		if (-f "$UserResearchPath$k.unt") {
			open(INPUT, "$UserResearchPath$k.unt") or print "Cannot open";
			@file = <INPUT>;
			close(INPUT);
			$k =~ tr/_/ /;
			chop ($file[24]);
			if($file[24] == $data{$k}) {next}
			$file[24] = "$data{$k}\n";
			$k =~ tr/ /_/;
			open(OUTPUT, ">$UserResearchPath$k.unt");
			print OUTPUT @file;
			close(OUTPUT);
			$flag=1;
		}
		$k =~ tr/_/ /;
		if($data{$k} != 0 and $flag eq 0){
#			print "$k *--* $data{$k}<BR>";
			open(INPUT,"$MainResearchPath$k.res") or print "Cannot open";
			@file=<INPUT>;
			close(INPUT);
			open(OUTPUT, ">$UserResearchPath$k.pro");
			print OUTPUT "$data{$k}\n";
			print OUTPUT "0\n";
			print OUTPUT "$file[0]";
			close(OUTPUT);
		}
	}
print "Location: http://www.bluewand.com/cgi-bin/classic/tech.pl?$user&$planet&$authcode\r\n\r\n";

sub parse_form {

   # Get the input
   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

   # Split the name-value pairs
   @pairs = split(/&/, $buffer);

   foreach $pair (@pairs) {
      ($name, $value) = split(/=/, $pair);

      # Un-Webify plus signs and %-encoding
      $name =~ tr/_/ /;
      $value =~ tr/+/ /;
      $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
      $value =~ s/<!--(.|\n)*-->//g;
      $value =~ s/<([^>]|\n)*>//g;
         
      

      $data{$name} = $value;
      }
}

#sub chopper{
#	foreach $k(@_){
#		chop($k);
#	}
#}
