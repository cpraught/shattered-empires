#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode,$Alliance,$MiscOne,$MiscTwo,$Mode)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);

$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
$UserPath = $MasterPath . "/se/Planets/$Planet/users/$User";
$HomePath = $MasterPath . "/se/Planets";

open (IN, "$AlliancePath/members.txt");
@Members = <IN>;
close (IN);
&chopper (@Members);

$LeaderFlag = $LCounter = 0;

foreach $Item (@Members) {
	($Rank,$Leader,$Blah) = split(/\|/,$Item);


	if (substr ($Item, 0, 1) eq "0" && (-d "$HomePath/$Blah/users/$Leader")) {$LCounter ++;}
	if ($Leader eq $User && $Rank == 0) {
		$LeaderFlag = 1;
	} elsif ($Leader eq $User && $Rank == 1) {
		$LeaderFlag = 3;
	} elsif ($Leader eq $User && $Rank > 1) {
		$LeaderFlag = 2;
	}
}


if ($LCounter == 0 && $LeaderFlag == 3) {
	$LeaderFlag = 1;
}
unless ($LeaderFlag == 1 || $Mode == 11111 || $Mode == 11112) {
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/AllyDisplay.pl?$User&$Planet&$AuthCode&$Alliance\r\n\r\n!;
	die;
}

&parse_form;

if ($Mode == 10101 or $Mode == 11112) {
	$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
	$NAlliance = $Alliance;
	$NAlliance =~ tr/_/ /;

	$NLeader = $User;
	$NLeader =~ tr/_/ /;

	$NLeader2 = $data{'transfer'};
	$NLeader2 =~ tr/_/ /;


	if ($LeaderFlag == 1) {
		open (OUT, ">$AlliancePath/members.txt");
		flock (OUT, 2);
		foreach $Item (@Members) {
			($Rank,$Member,$Planet)=split(/\|/,$Item);
			if ($Member eq $User) {$Rank = 4}
			if ($Member eq $data{'transfer'}) {$Rank = 0}
			print OUT "$Rank\|$Member\|$Planet\n";
		}
		close (OUT);
	
	
		open (IN, "$AlliancePath/allianceinfo.txt");
		flock (IN, 1);
		@DataIn = <IN>;
		close (IN);
		&chopper (@DataIn);

		open (IN, "$AlliancePath/ranks.txt");
		flock (IN, 1);
		$position = <IN>;
		close (IN);
		chop ($position);

		@DataIn[0] = "$NLeader2";
		open (OUT, ">$AlliancePath/allianceinfo.txt");
		flock (OUT, 2);
		foreach $WriteLine (@DataIn) {
			print OUT "$WriteLine\n";
		}
		close (OUT);

		$MessageDir = $MasterPath . "/se/Planets/$Planet/events";

		($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
		$Mon++;
		open (DATAOUT, ">$MessageDir/$Year$Mon$Mday$Hour$Min$Sec");
		flock (DATAOUT, 2);
		print DATAOUT "Resignation.\n";
		print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mday\/$Mon\/$Year\n";
		print DATAOUT "$NLeader has resigned from the position of $position.  $NLeader2 has been selected to assume command of the alliance.\n";
		close (DATAOUT);
	}
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/Allys.pl?$User&$Planet&$AuthCode\r\n\r\n!;
}

if ($Mode == 11101) {
	$Booted = $MiscOne;
	$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
#	print "Content-type: text/html\n\n";

	$NAlliance = $Alliance;
	$NAlliance =~ tr/_/ /;

	open (IN, "$AlliancePath/members.txt");
	flock (IN, 1);
	@Members = <IN>;
	close (IN);
	&chopper (@Members);
	open (OUT, ">$AlliancePath/members.txt");
	flock (OUT, 2);
	foreach $Item (@Members) {

		($Rank,$Country,$Blah) = split(/\|/,$Item);
		unless ($Country eq $Booted) {
			print OUT "$Item\n";
		}
	}
	close (OUT);
	$MessageDir = $MasterPath . "/se/Planets/$Planet/users/$Booted/events/";
	$BootedDir = $MasterPath . "/se/Planets/$Planet/users/$Booted/";

	($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
	$Mon++;
	open (DATAOUT, ">$MessageDir/$Year$Mon$Mday$Hour$Min$Sec");
	flock (DATAOUT, 2);
	print DATAOUT "Expelled from $NAlliance.\n";
	print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mday\/$Mon\/$Year\n";
	print DATAOUT "Your nation has been expelled from $NAlliance.\n";
	close (DATAOUT);
	unlink ("$BootedDir/alliance.txt");

	print qq!Location: http://www.bluewand.com/cgi-bin/classic/AllySet.pl?$User&$Planet&$AuthCode&$Alliance\r\n\r\n!;
}

if ($Mode == 11111) {
	print "Content-type: text/html\n\n";

	$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
	$Quitter = $User;

	open (IN, "$AlliancePath/members.txt");
	flock (IN, 1);
	@Members = <IN>;
	close (IN);
	&chopper (@Members);
	open (OUT, ">$AlliancePath/members.txt");
	flock (OUT, 2);
	foreach $Item (@Members) {

		($Rank,$Country,$Blah) = split(/\|/,$Item);
		unless ($Country eq $Quitter) {
			print OUT "$Item\n";
		}
	}
	close (OUT);

	open (IN, "$AlliancePath/allianceinfo.txt");
	flock (IN, 1);
	$Leader = <IN>;
	close (IN);
	chop ($Leader);
	$Leader =~ tr/ /_/;

	$MessageDir = $MasterPath . "/se/Planets/$Planet/users/$Leader/events/";
	$BootedDir = $MasterPath . "/se/Planets/$Planet/users/$Quitter/";

	$Quitter =~ tr/_/ /;
	($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
	$Mon++;
	open (DATAOUT, ">$MessageDir/$Year$Mon$Mday$Hour$Min$Sec");
	flock (DATAOUT, 2);
	print DATAOUT "Withdrawal From Alliance.\n";
	print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mday\/$Mon\/$Year\n";
	print DATAOUT "The nation of $Quitter has quit the alliance.\n";
	close (DATAOUT);

	unlink ("$BootedDir/alliance.txt");

	print qq!Location: http://www.bluewand.com/cgi-bin/classic/Allys.pl?$User&$Planet&$AuthCode\r\n\r\n!;
}

if ($Mode == 11112) {
	print "Content-type: text/html\n\n";

	$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";

	open (IN, "$AlliancePath/applicant.txt");
	flock (IN, 1);
	@Members = <IN>;
	close (IN);
	&chopper (@Members);
	open (OUT, ">$AlliancePath/applicant.txt");
	flock (OUT, 2);
	foreach $Item (@Members) {

		($Rank,$Country) = split(/\|/,$Item);
		unless ($Rank eq $User) {
			print OUT "$Item\n";
		}
	}
	close (OUT);

	$BootedDir = $MasterPath . "/se/Planets/$Planet/users/$User";
	unlink ("$BootedDir/apply.txt");

	print qq!Location: http://www.bluewand.com/cgi-bin/classic/Allys.pl?$User&$Planet&$AuthCode\r\n\r\n!;
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
#		chop($k);
#	}
#}
#
#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}
