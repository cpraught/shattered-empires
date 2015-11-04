#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode,$Alliance,$Accepted,$AcceptedPlanet,$Mode)=split(/&/,$ENV{'QUERY_STRING'});
$user_information = $MasterPath . "/classic/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}

$Path2 = "http://www.bluewand.com/cgi-bin/classic/AllySet.pl";

$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
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
unless ($LeaderFlag == 1) {
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/AllyDisplay.pl?$User&$Planet&$AuthCode&$Alliance\r\n\r\n!;
	die;
}

if ($Mode == 10101) {
	if ($User eq "Tessic") {print "Content-type: text/html\n\n";}
	$NewPath = $MasterPath . "/se/Planets/$AcceptedPlanet/users/$Accepted";
	$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
	$NAlliance = $Alliance;
	$NAlliance =~ tr/_/ /;

	open (DATAOUT, ">$NewPath/alliance.txt");
	flock (DATAOUT, 2);
	print DATAOUT "$Alliance\n";
	close (DATAOUT);
	
	unlink ("$NewPath/apply.txt");

	open (DATAOUT, ">>$AlliancePath/members.txt");
	flock (DATAOUT, 2);
	print DATAOUT "5|$Accepted|$AcceptedPlanet\n";
	close (DATAOUT);

	$NAccepted = $Accepted;
	$NAccepted =~ tr/_/ /;


	open (DATAIN, "$AlliancePath/applicant.txt");
	flock (DATAIN, 1);
	@ListofNations = <DATAIN>;
	close (DATAIN);
	&chopper (@ListofNations);

	foreach $Item (@ListofNations) {

		($Rank,$Country) = split(/\|/,$Item);
		unless ($Accepted eq $Rank) {push (@NewList,$Item)}
	}

	open (DATAOUT, ">$AlliancePath/applicant.txt");
	flock (DATAOUT, 2);
	foreach $ListItem (@NewList) {
		print DATAOUT "$ListItem\n";
	}
	close (DATAOUT);

	open (DATAIN, "$AlliancePath/allianceinfo.txt");
	flock (DATAIN, 1);
	@Info = <DATAIN>;
	close (DATAIN);
	&chopper (@Info);

	@Info[2]++;

	open (DATAOUT, ">$AlliancePath/allianceinfo.txt");
	flock (DATAOUT, 2);
	foreach $WriteLine (@Info) {
		print DATAOUT "$WriteLine\n";
	}
	close (DATAOUT);

($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
$Mon++;
	open (DATAOUT, ">$NewPath/events/$Year$Mon$Mday$Hour$Min$Sec.vnt");
	flock (DATAOUT, 2);
	print DATAOUT "Your application has been accepted.\n";
	print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mday\/$Mon\/$Year\n";
	print DATAOUT "You are now a member of $NAlliance.\n";
	close (DATAOUT);
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/AllySet.pl?$User&$Planet&$AuthCode&$Alliance\r\n\r\n!;
}


if ($Mode == 10111) {
	$NewPath = $MasterPath . "/se/Planets/$AcceptedPlanet/users/$Accepted";
	$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";

	open (DATAIN, "$AlliancePath/applicant.txt");
	flock (DATAIN, 1);
	@ListofNations = <DATAIN>;
	close (DATAIN);
	&chopper (@ListofNations);

	foreach $Item (@ListofNations) {

		($Rank,$Country) = split(/\|/,$Item);
		unless ($Accepted eq $Rank) {push (@NewList,$Item)}
	}

	open (DATAOUT, ">$AlliancePath/applicant.txt");
	flock (DATAOUT, 2);
	foreach $ListItem (@NewList) {
		print OUT "$ListItem\n";
	}
	close (DATAOUT);

	$NAlliance = $Alliance;
	$NAlliance =~ tr/_/ /;

	unlink ("$NewPath/apply.txt");
($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
	$Mon++;
	open (DATAOUT, ">$NewPath/events/$Year$Mon$Mday$Hour$Min$Sec.vnt");
	flock (DATAOUT, 2);
	print DATAOUT "Your application has been rejected.\n";
	print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mday\/$Mon\/$Year\n";
	print DATAOUT "Officials from $NAlliance rejected your petition for membership.\n";
	close (DATAOUT);
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/AllySet.pl?$User&$Planet&$AuthCode&$Alliance\r\n\r\n!;
}

if ($Mode == 11101) {
	$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance/tech";
	$Accepteds = $Accepted;
	$Accepteds =~ s/.cpl//;
	$Accepteds =~ s/.wrk//;
	$Accepteds =~ tr/_/ /;
	unless (-e "$AlliancePath/$Accepteds.cpl" or -e "$AlliancePath/$Accepteds.apl" or -e "$AlliancePath/$Accepteds.wrk") {
		$Accepted =~ s/.cpl/.apl/;
		$Accepted =~ s/.wrk/.apl/;
		$Accepted =~ tr/_/ /;
		open (OUT, ">$AlliancePath/$Accepted");
		close (OUT);
	}
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/TechAssign.pl?$User&$Planet&$AuthCode&$Alliance\r\n\r\n!;
}
if ($Mode == 11111) {
	$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance/tech";
	$TekPath = $Masterpath . "/research";
	$Accepted =~ tr/_/ /;
	unlink ("$AlliancePath/$Accepted");
	$Accepted =~ s/.apl/.cpl/;
	open (IN, "$TekPath/$Accepted");
	@Data = <IN>;
	&chopper (@Data);
	$Accepted =~ s/.cpl/.wrk/;
	open (OUT, ">$AlliancePath/$Accepted");
	print OUT "$Data[1]\n";
	print OUT "0\n";
	close (OUT);
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/AllySet.pl?$User&$Planet&$AuthCode&$Alliance\r\n\r\n!;
}

if ($Mode == 21111) {
	$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance/tech";
	$AlliancePath2 = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
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
		$MemberPath = $MasterPath . "/se/Planets/$Planet2/users/$User2/research";
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

if ($Mode == 22111) {
	$AlliancePath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
	$NAlliance = $Alliance;
	$NAlliance =~ tr/_/ /;

	$NLeader = $User;
	$NLeader =~ tr/_/ /;
	open (IN, "$AlliancePath/members.txt");
	flock (IN, 1);
	@Members = <IN>;
	close (IN);
	&chopper (@Members);


	opendir (DIR, "$AlliancePath");
	@Stuffs = readdir (DIR);
	closedir (DIR);
	foreach $Item (@Stuffs) {
		if (-f "$AlliancePath/$Item") {
			unlink ("$AlliancePath/$Item") or print "Cannot delete file: $Item<BR>";
		} else {
			if ($Item ne '.' and $Item ne '..') {
				opendir (DIRS, "$AlliancePath/$Item");
				@SecondRun = readdir (DIRS);
				closedir (DIRS);

				foreach $Item2 (@SecondRun) {
					if ($Item2 ne '.' and $Item2 ne '..') {
						unlink ("$AlliancePath/$Item/$Item2") or print "Cannot delete file: $Item/$Item2<BR>";
					}
				}
			}
			rmdir ("$AlliancePath/$Item");
		}
	}
	rmdir ("$AlliancePath");
	foreach $Item (@Members) {
		($Rank,$Leader,$Planets)=split(/\|/,$Item);
		$MemberPath = $MasterPath . "/se/Planets/$Planets/users/$Leader";
		unlink ("$MemberPath/alliance.txt");
	
		($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
		$Mon++;
		open (DATAOUT, ">$MemberPath/events/$Year$Mon$Mday$Hour$Min$Sec.vnt");
		flock (DATAOUT, 2);
		print DATAOUT "$NAlliance has been disbanded.\n";
		print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mday\/$Mon\/$Year\n";
		print DATAOUT "The nation of $NLeader has disbanded $NAlliance.\n";
		close (DATAOUT);
	}
	$MessageDir = $MasterPath . "/se/Planets/$Planet/events";
	open (DATAOUT, ">$MessageDir/$Year$Mon$Mday$Hour$Min$Sec");
	flock (DATAOUT, 2);
	print DATAOUT "$NAlliance has been disbanded.\n";
	print DATAOUT "<CENTER>$Hour:$Min:$Sec   $Mday\/$Mon\/$Year\n";
	print DATAOUT "The nation of $NLeader has disbanded $NAlliance.\n";
	close (DATAOUT);

	print qq!Location: http://www.bluewand.com/cgi-bin/classic/Allys.pl?$User&$Planet&$AuthCode\r\n\r\n!;
}


#
#sub chopper{
#	foreach $k(@_){
#		chop($k);
#	}
#}


