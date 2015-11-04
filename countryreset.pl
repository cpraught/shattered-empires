#!/usr/bin/perl
require 'quickies.pl'

$user_information = $MasterPath . "/User Information";
$worlddir = $MasterPath . "/se/Planets/";
if($ENV{'REMOTE_HOST'} =~ /209.156/) {die;}
if($ENV{'REMOTE_HOST'} =~ /209.252/) {die;}
if($ENV{'REMOTE_HOST'} =~ /216.70/) {die;}

&parse_form;

$data{'cname'} =~ tr/ /_/;

if ($data{'cname'} eq "Imperiumz") {print "content-type: text/html\n\n";}


dbmopen(%password, "$user_information/password", 0777) or print "Error 1- $!";
if ($data{'pword1'} eq $password{$data{'cname'}}) {
	dbmclose(%password);

	dbmopen(%planet, "$user_information/planet", 0777) or print "Error 2- $!";
	use File::Find;
	$userdir = $MasterPath . "/se/Planets/$planet{$data{'cname'}}/users/$data{'cname'}";

	if ($data{'cname'} eq "Imperiumz") {
		print "$userdir<BR>";
	}

	unless (-d "$userdir") {
		print "<SCRIPT>alert(\"That country does not exist.  Please confirm your country name and try again.\");history.back();</SCRIPT>";
		die;
	}
	if (-f "$userdir/dupe.txt") {
		print "<SCRIPT>alert(\"Your nation has been locked down for security reasons.  Please contact the GSD team at shattered.empires\@canada.com for details.\");history.back();</SCRIPT>";
		die;
	}

	chdir($MasterPath . '/se/Planets/$planet{$data{"cname"}}/users');
	finddepth(\&deltree,"$userdir") or print "Error 3- $!";
	rmdir("$userdir");
	dbmclose(%planet);

	&RemoveInfo;

	print "Location: http://www.bluewand.com/seclassic.php\n\n";
	die;
} else {
	print "Location: http://www.bluewand.com/seclassic2.php\n\n";
	die;
}

sub parse_form {

   # Get the input
   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

   # Split the name-value pairs
   @pairs = split(/&/, $buffer);

   foreach $pair (@pairs) {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$value =~ s/<!--(.|\n)*-->//g;
        $value =~ s/<([^>]|\n)*>//g;        
	$data{$name} = $value;
   }
}

sub deltree {
	$file = "$File::Find::dir/$_";
	unlink("$File::Find::dir/$_") or rmdir("$File::Find::dir/$_")
}

sub RemoveInfo 
{
	#AccessCode
	dbmopen(%datain, "$user_information/accesscode", 0777) or print "Code - $!<BR>";
	$Code = ($datain{$data{'cname'}});
	delete($datain{$data{'cname'}});
	dbmclose(%datain);

	#Email Address
	dbmopen(%datain, "$user_information/emailaddress",0777) or print "Code - $!<BR>";;
	$Email = ($datain{$data{'cname'}});
	delete($datain{$data{'cname'}});
	dbmclose(%datain);

	#Password
	dbmopen(%password, "$user_information/password",0777) or print "Code - $!<BR>";;
	delete($password{$data{'cname'}});
	dbmclose(%password);

	#Planet
	dbmopen(%planet, "$user_information/planet",0777) or print "Code - $!<BR>";;
	$Planet = ($planet{$data{'cname'}});
	delete($planet{$data{'cname'}});
	dbmclose(%planet);

	#IP
	dbmopen(%ip, "$user_information/ip",0777) or print "Code - $!<BR>";;
	delete($ip{$data{'cname'}});
	dbmclose(%ip);

	#Date
	dbmopen(%date, "$user_information/date",0777) or print "Code - $!<BR>";;
	delete($date{$data{'cname'}});
	dbmclose(%date);

	#Httphost
	dbmopen(%httphost, "$user_information/httphost",0777) or print "Code - $!<BR>";;
	delete($httphost{$data{'cname'}});
	dbmclose(%httphost);
}
