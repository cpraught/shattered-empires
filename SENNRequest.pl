#!/usr/bin/perl
print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$TCount,$Mode,$InType)=split(/&/,$ENV{QUERY_STRING});
$user_information = "/home/admin/classic/se/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authcode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);

$Font = qq!<font face=verdana size=-1>!;
$Font2 = qq!<font face=verdana size=-2>!;
$Back2 = qq!bgcolor="#666666"!;
$Back = qq!bgcolor="#333333"!;
$InType2 = $InType;

$InType2 =~ tr/_/ /;

$Path = "/home/shatteredempires/SENN";

if ($Mode == 2) {
	&ParseData;
	open (OUT, ">$Path/$User$InType");
	print OUT "$User|$TCount|$InType\n";
	print OUT "$data{'Information'}\n";
	close (OUT);
	print qq!<script>window.close();</script>!;
} else {

$InType =~ tr/_/ /;

print qq!
<html>
<title>SENN - Request for Information: $InType </title>
<body bgcolor=black text=white>$Font
<form method=post action="http://www.bluewand.com/cgi-bin/classic/SENNRequest.pl?$User&$Planet&$AuthCode&$TCount&2&$InType">
<font face=verdana size=-1>
<table border=1 width=100% cellspacing=0 cellpadding=0 $Back>
<TR><TD>$Font Incident:</TD><TD $Back2>$Font $InType2</TD></TR>
<TR><TD>$Font Nation of Origin:</TD><TD $Back2>$Font $User</TD></TR>
<TR><TD>$Font Target Nation:</TD><TD $Back2>$Font $TCount</TD></TR>
<TR><TD colspan=2 $Back2>$Font2 SENN is requesting information pertaining to the following event: $InType2<BR>
If you wish to comment on the actions of your nation, please enter it below.  If you do not wish to comment, close the window.<BR>
Please note, SENN is a part of Shattered Empires©, and remarks deemed offensive will be acted upon.</TD></TR>
<TR><TD colspan=2><center><textarea name="Information" wrap=virtual cols=40 rows=7></textarea></TD></TR>
</table>
<Center><input type=submit name=submit value="Submit Information"></center></form>
</body>!;
}
sub ParseData {
   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
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
