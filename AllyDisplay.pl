#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$Alliance)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);

$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

&parse_form;
$AllyPath = $MasterPath . "/se/Planets/$Planet/alliances/$Alliance";
$UserPaths = $MasterPath . "/se/Planets/$Planet/users/$User";
$HomePath = $MasterPath . "/se/Planets";
$NAlliance = $Alliance;
$NAlliance =~ tr/_/ /;

open (DATAIN, "$AllyPath/allianceinfo.txt");
flock (DATAIN, 1);
@AllianceData = <DATAIN>;
close (DATAIN);
&chopper (@AllianceData);

open (DATAIN, "$AllyPath/ranks.txt");
flock (DATAIN, 1);
@Rank = <DATAIN>;
close (DATAIN);
&chopper (@Rank);

open (DATAIN, "$AllyPath/members.txt") or print $!;
flock (DATAIN, 1);
@Members = <DATAIN>;
close (DATAIN);
&chopper (@Members);

open (DATAIN, "$AllyPath/summary.txt");
flock (DATAIN, 1);
@Summary = <DATAIN>;
close (DATAIN);

$Path = "http://www.bluewand.com/cgi-bin/classic/AllyChange.pl";
$Path2 = "http://www.bluewand.com/cgi-bin/classic/AllySet.pl";
$Path3 = "http://www.bluewand.com/cgi-bin/classic/AllyMembers.pl";
$Path4 = "http://www.bluewand.com/cgi-bin/classic/AllyDiplomacy.pl";

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

$MemCount = scalar(@Members);

@AllianceData[2] = $MemCount;

open (DATAOUT, ">$AllyPath/allianceinfo.txt");
flock (DATAOUT, 2);
foreach $WriteLine (@AllianceData) {
	print DATAOUT "$WriteLine\n";
}
close (DATAOUT);

@AllianceData[0] =~ tr/_/ /;
$abba = &Space(@AllianceData[5]);

print qq!
<html>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<body BGCOLOR="#000000" text="#FFFFFF">
<table BORDER="0" WIDTH="100%">
  <tr>
    <td BGCOLOR="$Content" width="50%"><p align="left"><font face="Arial" size="3"><b>$NAlliance</b></font></td>
  </tr>
</table>
<div align="center"><center><BR>!;
if ($LeaderFlag == 1) {
print qq!
<TABLE WIDTH="100%" BORDER=0>
<TR><TD BGCOLOR="666666"><FONT FACE="Arial" COLOR="white" SIZE="-1"><UL><LI><B><a href="$Path?$User&$Planet&$AuthCode&$Alliance" target ="Frame5" ONMOUSEOVER = "parent.window.status='Alliance Info';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Alliance Info</a></B></FONT></TD></TR>
<TR><TD BGCOLOR="666666"><FONT FACE="Arial" COLOR="white" SIZE="-1"><UL><LI><B><a href="$Path4?$User&$Planet&$AuthCode&$Alliance" target ="Frame5" ONMOUSEOVER = "parent.window.status='Modify Alliance';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Diplomacy</a></B></FONT></TD></TR>
<TR><TD BGCOLOR="666666"><FONT FACE="Arial" COLOR="white" SIZE="-1"><UL><LI><B><a href="$Path2?$User&$Planet&$AuthCode&$Alliance" target ="Frame5" ONMOUSEOVER = "parent.window.status='Modify Alliance';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Modify Alliance</a></B></FONT></TD></TR>
</TABLE>!;
}
if ($LeaderFlag >= 2) {
	print qq!
	<TABLE WIDTH="100%" BORDER=0>
	<TR><TD BGCOLOR="666666"><FONT FACE="Arial" COLOR="white" SIZE="-1"><UL><LI><B><a href="$Path3?$User&$Planet&$AuthCode&$Alliance" target ="Frame5" ONMOUSEOVER = "parent.window.status='Alliance Info';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Member Page</a></B></FONT></TD></TR>
	</table>!;
}

if (@AllianceData[6] eq qq!http://!) {$Redirect = "&nbsp;";$Title="";} else {$Redirect = "@AllianceData[6]";$Title="Homepage";}

print qq!<table BORDER="0" WIDTH="603" cellpadding="10" cellspacing=0>
  <tr>
    <td width="350" valign="top"><table BORDER="1" WIDTH="100%" cellspacing=0>
      <tr>
        <td BGCOLOR="$Header" width="50%"><font FACE="Arial" size="-1">Founder</font></td>
        <td BGCOLOR="$Content" width="50%"><font FACE="Arial" size="-1">@AllianceData[0]</font></td>
      </tr>
      <tr>
        <td BGCOLOR="$Header" width="50%"><font FACE="Arial" size="-1">Guild Page</font></td>
        <td BGCOLOR="$Content" width="50%"><font FACE="Arial" size="-1"><font size=-2>$Redirect</font></td>
      </tr>
      <tr>
        <td BGCOLOR="$Header" width="50%"><font FACE="Arial" size="-1">Ethos</font></td>
        <td BGCOLOR="$Content" width="50%"><font FACE="Arial" size="-1">@AllianceData[4] @AllianceData[3]</font></td>
      </tr>
      <tr>
        <td BGCOLOR="$Header" width="50%"><font FACE="Arial" size="-1">Members</font></td>
        <td BGCOLOR="$Content" width="50%"><font FACE="Arial" size="-1">@AllianceData[2]</font></td>
      </tr>
      <tr>
        <td BGCOLOR="$Header" width="50%"><font FACE="Arial" size="-1">Membership Dues</font></td>
        <td BGCOLOR="$Content" width="50%"><font FACE="Arial" size="-1">\$$abba</font></td>
      </tr>
    </table>
<BR>
    <table BORDER="1" WIDTH="100%" cellspacing=0>
      <tr>
        <td BGCOLOR="$Header" width="30%"><font FACE="Arial" size="-1">Rank One</font></td>
        <td BGCOLOR="$Content" width="*"><font FACE="Arial" size="-1">@Rank[0]</font></td>
      </tr>
      <tr>
        <td BGCOLOR="$Header" width="30%"><font FACE="Arial" size="-1">Rank Two</font></td>
        <td BGCOLOR="$Content" width="*"><font FACE="Arial" size="-1">@Rank[1]</font></td>
      </tr>
      <tr>
        <td BGCOLOR="$Header" width="30%"><font FACE="Arial" size="-1">Rank Three</font></td>
        <td BGCOLOR="$Content" width="*"><font FACE="Arial" size="-1">@Rank[2]</font></td>
      </tr>
      <tr>
        <td BGCOLOR="$Header" width="30%"><font FACE="Arial" size="-1">Rank Four</font></td>
        <td BGCOLOR="$Content" width="*"><font FACE="Arial" size="-1">@Rank[3]</font></td>
      </tr>
      <tr>
        <td BGCOLOR="$Header" width="30%"><font FACE="Arial" size="-1">Rank Five</font></td>
        <td BGCOLOR="$Content" width="*"><font FACE="Arial" size="-1">@Rank[4]</font></td>
      </tr>
      <tr>
        <td BGCOLOR="$Header" width="30%"><font FACE="Arial" size="-1">Rank Six</font></td>
        <td BGCOLOR="$Content" width="*"><font FACE="Arial" size="-1">@Rank[5]</font></td>
      </tr>
    </table>
    </td>
    <td width="15" rowspan="3"></td>
    <td width="232" valign="middle" align="center"><img src="@AllianceData[7]" align="middle"></td>
  </tr>
  <tr>
<TD><table border=1 cellspacing=0 width=100%><TR><TD BGCOLOR="$Header"><font FACE="Arial" size="-1">SUMMARY</font></TD></TR></TAble></td>
    <td width="232" valign="top"><font FACE="Arial"><a href="AllyView.pl?$ENV{QUERY_STRING}&11011" ONMOUSEOVER = "parent.window.status='View $NAlliance history';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">$NAlliance History</a></td>
  </tr>
  <tr>
    <td width="350" valign="top"><font FACE="Arial" size="-1">@Summary</p>
    <p>&nbsp;</td>
    <td width="232" valign="top"><font FACE="Arial"><a href="AllyView.pl?$ENV{QUERY_STRING}&10111" ONMOUSEOVER = "parent.window.status='View $NAlliance charter';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">$NAlliance Charter</a><BR><BR>!;
if ($LeaderFlag == 0) {
	print qq!<a href="AllyApply.pl?$ENV{QUERY_STRING}" ONMOUSEOVER = "parent.window.status='Apply to $NAlliance';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:white">Apply to $NAlliance</a>!;
}
print qq!</font></td>
  </tr>
</table>
</center></div>
</body>
</html>
!;

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
