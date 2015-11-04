#!/usr/bin/perl
require 'quickies.pl'


$Mode="Closed";
&parse_form;

if ($Mode eq "Accept" or $data{'emailaddress'} eq "cpraught205\@rogers.com") {
$data{'handle'} =~ tr/ /_/;
$user_information = $MasterPath . "/User Information";

#$Block  = substr($ENV{'REMOTE_ADDR'},0,7);
#$Block2  = substr($ENV{'REMOTE_ADDR'},0,6);
#if ($Block eq "209.156" or $Block eq "209.252" or $Block2 eq "216.70")  {die;}
#if($ENV{'REMOTE_HOST'} =~ /209.156/) {die;}
#if($ENV{'REMOTE_HOST'} =~ /209.252/) {die;}
#if($ENV{'REMOTE_HOST'} =~ /216.70/) {die;}


#will this work?
if (-C $MasterPath . "/home/bluewand/data/classic/IP.txt" > 1) {unlink ($MasterPath . "/home/bluewand/data/classic/IP.txt")} else {

	open (IN, "/home/bluewand/data/IP.txt");
	flock (IN, 1);
	my @IPS = <IN>;
	close (IN);
	&chopper (@IPS);

	foreach $Item (@IPS) {
		$IPHash{$Item}++;
	}

	if ($IPHash{$ENV{'REMOTE_ADDR'}} >= 2) {
		print "Location: http://www.bluewand.com/classic/HTML/Lock.html\r\n\r\n";
		die;
	}
}

&check_for_valid_handle;
&check_for_valid_email;
&write_the_files;
&email_the_code;

open (OUT, ">>/home/bluewand/data/classic/IP.txt");
flock (OUT, 2);
print OUT $ENV{'REMOTE_ADDR'};
print OUT "\n";
print "Location: http://www.bluewand.com/pages/se/seclassiccreate2.php\r\n\r\n";

sub check_for_valid_handle {
	if ($data{'handle'} =~ m/[^A-Z_a-z]/) {
		print "Content-type: text/html\n\n";
		print "<SCRIPT>alert(\"You have attempted to use characters in your country name that are not valid.  Valid characters include all letters and space.\")\;history.back()</SCRIPT>";
		die;
	}

	dbmopen(%datain, "$user_information/accesscode", 0777) or print "$! $user_information/accesscode<BR>";
	if ($datain{$data{'handle'}} ne "") {
		print "Content-type: text/html\n\n";
		print qq!<SCRIPT>alert("Sorry, there is already a nation in existance possessing that country name.  Please try with a new nation name.");history.back();</SCRIPT>!;
		dbmclose(%datain);
		die;
	}
	dbmclose(%datain);



	if ($data{'handle'} eq 'None' or $data{'handle'} eq "") {
		print "Content-type: text/html\n\n";
		print "<SCRIPT>alert(\"Sorry, the country name you entered is invalid.  Please try again with a new name.\")\;history.back()</SCRIPT>";
		die;
	}
}

sub check_for_valid_email{

	dbmopen(%email, "$user_information/emailaddress", 0777);
	foreach $k (values(%email)){
		if($k eq $data{'emailaddress'} and $data{'emailaddress'} ne "cpraught205\@rogers.com"){$Count++}
	}
	dbmclose(%email);



	if ($Count > 1) {
		print "Content-type: text/html\n\n";
		print "<SCRIPT>alert(\"Sorry, that e-mail address is in use.\")\;history.back()</SCRIPT>";
		die;
	}
}





sub write_the_files {
	srand();
	$authcode = int(rand(9)).chr(int(rand(26)) + 65).chr(int(rand(26)) + 65).int(rand(9)).int(rand(9)).int(rand(9)).int(rand(9)).chr(int(rand(26)) + 65).chr(int(rand(26)) + 65).int(rand(9));
	dbmopen(%datain, "$user_information/accesscode", 0777) or print $!;
	$datain{$data{'handle'}} = $authcode or print $!;
	dbmclose(%datain);

	dbmopen(%writemail, "$user_information/emailaddress", 0777);
	$writemail{$data{'handle'}} = $data{'emailaddress'};
	dbmclose(%writemail);

	($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
	$Mon++;

	open (OUT, ">>/home/bluewand/data/Joined.txt");
	flock (OUT, 2);
	print OUT "$Hour:$Min:$Sec - $Mday/$Mon/$Year - $data{'handle'}\n";
	close (OUT);
}





sub email_the_code {

	srand();
	open(MAIL, "|/usr/sbin/sendmail $data{'emailaddress'}") or die "Sorry could not run mail program.";
	print MAIL "Reply-to: admin\@bluewand.com\n";
	print MAIL "From: Shattered Empires E-mail Verification Script <admin\@bluewand.com>\n";
	print MAIL "Subject: E-Mail Verification\n\n";
	print MAIL "Shattered Empires Classic:\n";
	$data{'handle'} =~tr/_/ /;
	print MAIL "Congratulations on signing up for Shattered Empires, one of the most realistic and entertaining strategy games available on the internet today!\n\n";
	print MAIL "Now that you have recieved your authorization code, you can continue the sign-up process by going back to the \"Account Manager\", and following the \"Validation\" link.  Enter your countries name and the code contained in this email, and you will then be able to set-up your country and begin play.";
	print MAIL "This is the authorization code for $data{'handle'}:\n";
	print MAIL $authcode."\n";
	print MAIL "Please save this code for future reference.  If you experience problems, or have to reset, it will be needed.";
	print MAIL "Treat your authorization code as you would your password.  Do not give it out to anyone.  The Bluewand";
	print MAIL "Entertainment team will never ask you for your password, and has a special page setup for submitting your authorization code.  This page is located on the Shattered Empires server, will be used as necessary to submit your authorization code for validation purposes.\n\n";
	print MAIL "http://www.bluewand.com\n";
	close(MAIL);
}

} else {
	print "Content-type: text/html\n\n";
	print qqﬁ
<BODY>
<BR><BR><BR><BR><BR>
<font face=verdana size=-1><CENTER>SE is offline at the moment.  Please stand by.
	ﬁ;
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



#sub chopper{
#	foreach $k(@_){
#		chomp($k);
#	}
#}

