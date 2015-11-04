#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode,$Alliance,$Mode)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

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

&parse_form;
&Start;
if ($Mode eq "tosle") {&Modify}

print "Content-type: text/html\n\n";
print qqﬁ
<html>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<body BGCOLOR="#000000" text="#FFFFFF">
<table BORDER="0" WIDTH="100%">
<TABLE BORDER="1" cellspacing=0 WIDTH="100%"><TR><TD BGCOLOR="$Header" width ="50%"><CENTER><FONT FACE="Arial" size="-1"><B>Modify Alliance</b></td></tr></table>
<BR><BR><Center>
<FORM method="POST" action="http://www.bluewand.com/cgi-bin/classic/AllyChange.pl?$User&$Planet&$AuthCode&$Alliance&tosle">
<TABLE BORDER="1" cellspacing=0 WIDTH="60%">
<TR><TD width=25% BGCOLOR="$Header"><FONT FACE="Arial" size="-1">Dues</td><TD BGCOLOR="$Content"><FONT FACE="Arial" size="-1"><INPUT TYPE="text" name="Dues" value="$AllianceData[5]"></TD></tr>
<TR><TD width=25% BGCOLOR="$Header"><font FACE="Arial" size="-1">Logo Path</TD><TD BGCOLOR="$Content"><font FACE="Arial" size="-1"><INPUT TYPE="textbox" size=30 name="Image" value="$AllianceData[7]"></TD></TR>
<TR><TD width=25% BGCOLOR="$Header"><font FACE="Arial" size="-1">Homepage</TD><TD BGCOLOR="$Content"><font FACE="Arial" size="-1"><INPUT TYPE="textbox" size=30 name="Link" value="$AllianceData[6]"></TD></TR>
</table>
<BR><BR><Center>
<TABLE BORDER="1" cellspacing=0 WIDTH="60%">
<TR><TD BGCOLOR="$Header"><font FACE="Arial" size="-1">Summary</TD></TR>
<TR><TD BGCOLOR="$Content"><font FACE="Arial" size="-1"><textarea name="Summary" cols="60" rows="5" wrap="VIRTUAL">ﬁ; print @Summary; print qqﬁ</textarea></TD></TR>
</table>
<BR><BR><Center>
<TABLE BORDER="1" cellspacing=0 WIDTH="60%">
<TR><TD BGCOLOR="$Header"><font FACE="Arial" size="-1">History</TD></TR>
<TR><TD BGCOLOR="$Content"><font FACE="Arial" size="-1"><textarea name="History" cols="60" rows="5" wrap="VIRTUAL">ﬁ; print @History; print qqﬁ</textarea></TD></TR>
</table>
<BR><BR><Center>
<TABLE BORDER="1" cellspacing=0 WIDTH="60%">
<TR><TD BGCOLOR="$Header"><font FACE="Arial" size="-1">Charter</TD></TR>
<TR><TD BGCOLOR="$Content"><font FACE="Arial" size="-1"><textarea name="Charter" cols="60" rows="5" wrap="VIRTUAL">ﬁ; print @Charter; print qqﬁ</textarea></TD></TR>
</table>
<font size="-1"><INPUT TYPE="submit" name="submit" value="Modify">
</FORM>
ﬁ;



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

sub dirty {
	foreach $text (@_) {
		$text =~ s/\cM//g;
		$text =~ s/\n\n/<p>/g;
		$text =~ s/\n/<br>/g;
		$text =~ s/&lt;/</g; 
		$text =~ s/&gt;/>/g; 
		$text =~ s/&quot;/"/g;
	}
	return @_;
}


sub clean {
	foreach $temp (@_) {
		$temp =~ s/<p>/\n\n/g;
		$temp =~ s/<br>/\n/g;
		$temp =~ s/</&lt;/g; 
		$temp =~ s/>/&gt;/g; 
		$temp =~ s/"/&quot;/g;
	}
	return @_;
}


sub Start {

$AllyPath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
$NAlliance = $Alliance;
$NAlliance =~ tr/_/ /;

if (-e "$AllyPath/allianceinfo.txt") {
	open (DATAIN, "$AllyPath/allianceinfo.txt");
	flock (DATAIN, 1);
	@AllianceData = <DATAIN>;
	close (DATAIN);
	&chopper (@AllianceData);
}

if (-e "$AllyPath/ranks.txt") {
	flock (DATAIN, 1);
	open (DATAIN, "$AllyPath/ranks.txt");
	@Rank = <DATAIN>;
	close (DATAIN);
	&chopper (@Rank);
}


if (-e "$AllyPath/members.txt") {
	flock (DATAIN, 1);
	open (DATAIN, "$AllyPath/members.txt");
	@Members = <DATAIN>;
	close (DATAIN);
	&chopper (@Members);
}

if (-e "$AllyPath/summary.txt") {
	flock (DATAIN, 1);
	open (DATAIN, "$AllyPath/summary.txt");
	@Summary = <DATAIN>;
	close (DATAIN);
	&clean(@Summary);
}

if (-e "$AllyPath/history.txt") {
	flock (DATAIN, 1);
	open (DATAIN, "$AllyPath/history.txt");
	@History = <DATAIN>;
	close (DATAIN);
	&clean(@History);
}

if (-e "$AllyPath/charter.txt") {
	flock (DATAIN, 1);
	open (DATAIN, "$AllyPath/charter.txt");
	@Charter = <DATAIN>;
	close (DATAIN);
	&clean (@Charter);
}
}
sub Modify {
	open (DATAIN, "$AllyPath/allianceinfo.txt");
	flock (DATAIN, 1);
	@AllianceData = <DATAIN>;
	close (DATAIN);
	&chopper (@AllianceData);
	
	$ImageEnd = substr($data{'Image'},length($data{'Image'})-3,length($data{'Image'}));
	if ($ImageEnd eq "gif" or $ImageEnd eq "jpg") {@AllianceData[7] = $data{'Image'}}

	@AllianceData[5] = $data{'Dues'};
	@AllianceData[6] = $data{'Link'};
	open (DATAOUT, ">$AllyPath/allianceinfo.txt");
	flock (DATAOUT, 2);
	foreach $WriteLine (@AllianceData) {
		print DATAOUT "$WriteLine\n";
	}
	close (DATAOUT);

	@Sum = $data{'Summary'};
	&dirty(@Sum);
	@Summary=@Sum;

	open (DATAOUT, ">$AllyPath/summary.txt");
	flock (DATAOUT, 2);
	print DATAOUT "@Sum\n";
	close (DATAOUT);

	@Char = $data{'Charter'};
	&dirty(@Char);
	@Charter=@Char;
	
	open (DATAOUT, ">$AllyPath/charter.txt");
	flock (DATAOUT, 2);
	print DATAOUT "@Char\n";
	close (DATAOUT);

	@His = $data{'History'};
	&dirty(@His);
	@History=@His;

	open (DATAOUT, ">$AllyPath/history.txt");
	flock (DATAOUT, 2);
	print DATAOUT "@His\n";
	close (DATAOUT);
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/AllyChange.pl?$User&$Planet&$AuthCode&$Alliance\r\n\r\n!;
}
