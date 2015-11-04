#!/usr/bin/perl
require 'quickies.pl'
print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$Alliance)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";
&parse_form;
$UserPath = "/home/bluewand/data/classic/se/Planets/$Planet/users/$User";
$AllyPath = "/home/bluewand/data/classic/se/Planets/$Planet/alliances/$Alliance";
$NAlliance = $Alliance;
$NAlliance =~ tr/_/ /;
$NUser = $User;
$NUser =~ tr/_/ /;

if ($data{'Text'} ne "") {
	if (-e "$UserPath/apply.txt") {
		$Msg = "You have already applied to an alliance.  You can only submit one application at a time.";
		&DieScreen;
		die;		
	}
	if (-e "$UserPath/alliance.txt") {
		$Msg ="You are already in an alliance.  You can only be in one alliance at a time.";
		&DieScreen;
		die;		
	}
	open (DATAOUT, ">>$AllyPath/applicant.txt");
	print DATAOUT "$User|$Planet\n";
	close (DATAOUT);
	open (DATAOUT, ">$UserPath/apply.txt");
	print DATAOUT "$Alliance\n";
	print DATAOUT "$data{'Text'}\n";
	close (DATAOUT);
	$Msg = "Application Sent.<BR>For the best chance of being accepted, we recommend you contact the leader or an officer of the alliance using email or icq.";
	&DieScreen;
	die;
}



print qqﬁ
<html>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<body BGCOLOR="#000000" text="#FFFFFF">
<table width=100% border=1 cellspacing=0><TR bgcolor="$Header"><TD><font face="Arial" size="-1"><B><center>Submit Alliance Application</B></TR></table>
<center>
<FORM method="POST" action="http://www.bluewand.com/cgi-bin/classic/AllyApply.pl?$User&$Planet&$AuthCode&$Alliance">
<table border=1 cellspacing=0 width=80% bgcolor=$Content>
<TR><TD colspan=2 width=25% bgcolor=$Header><font face="Arial" size="-1"><center>Nations Name<img src="http://shatteredempires.shatteredempires.com/shatteredempires/images/shim.gif" width="72%" height="1">$NUser</center></TD></TR>
<TR><TD colspan=2 bgcolor=$Header><font face="Arial" size="-1">Application Message</td></tr>
<TR><TD colspan=2 bgcolor=$Header><font face="Arial" size="-1"><BR><textarea name="Text" cols="60" rows="5" wrap="VIRTUAL">You must include a message for your application to be sent</textarea><Center>
<INPUT TYPE="submit" name="submit" value="Apply to $NAlliance"></td></tr>
</table>
</FORM>
</body>
</html>
ﬁ;


sub DieScreen {
print qqﬁ
<html>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<body BGCOLOR="#000000" text="#FFFFFF"><font face="Arial" size="-1">
<table width=100% border=1 cellspacing=0><TR bgcolor=$Header><TD><font face="Arial" size="-1"><B><center>Alliance Application Submitted</B></TR></table>
<BR><BR><BR><BR><BR><Center>$Msgﬁ;
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

#in quickie
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
#
#though why you have space twice... ? 
#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}
