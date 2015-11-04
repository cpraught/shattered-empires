#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$Alliance,$Accepted,$AcceptedPlanet,$Mode)=split(/&/,$ENV{'QUERY_STRING'});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}

$Path2 = "http://www.bluewand.com/cgi-bin/classic/AllySet.pl";

$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
$HomePath = $MasterPath . "/se/Planets";
open (IN, "$AlliancePath/members.txt");
flock (IN, 1);
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
unless ($LeaderFlag == 1) {
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/AllyDisplay.pl?$User&$Planet&$AuthCode&$Alliance\r\n\r\n!;
	die;
}


if ($Mode == 31111) {
	$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance/tech";
	$AlliancePath2 = $MasterPath . "se/Planets/$Planet/alliances/$Alliance";
	$Accepted =~ tr/_/ /;
	open (IN, "$AlliancePath/$Accepted");
	flock (IN, 1);
	@Data = <IN>;
	$Accepted =~ s/.wrk/.cpl/;

	open (IN, "$AlliancePath2/members.txt");
	flock (IN, 1);
	@Players = <IN>;
	close (IN);
	&chopper (@Players);

	foreach $Member (@Players) {
		($Rank,$User2,$Planet2) = split(/\|/,$Member);
		$MemberPath = $MasterPath . "se/Planets/$Planet2/users/$User2/tech";
		$Accepted =~ s/.cpl/.wrk/;
		unlink ("$MemberPath/$Accepted");
		$Accepted =~ s/.wrk/.cpl/;
		open (OUT, ">$MemberPath/$Accepted");
		flock (OUT, 2);
		print OUT "$Data[0]\n";
		print OUT "$Data[1]\n";
		close (OUT);
	}
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/AllySet.pl?$User&$Planet&$AuthCode&$Alliance\r\n\r\n!;
}

#sub chopper{
#	foreach $k(@_){
#		chop($k);
#	}
#}
