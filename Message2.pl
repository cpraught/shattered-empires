#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode,$Type,$Msg,$To)=split(/&/,$ENV{QUERY_STRING});
$PlanetDir = $MasterPath . "/se/Planets/$Planet";
$UserDir = "$PlanetDir/users/$User";

if (-e "$UserDir/Dead.txt") {
	print "Location: http://www.bluewand.com/cgi-bin/classic/Dead.pl?$User&$Planet&$AuthCode\n\n";
	die;
}
if (-e "$UserDir/dupe.txt") {
	print "<SCRIPT>alert(\"Your nation has been locked down for security reasons.  Please contact the GSD team at shattered.empires\@canada.com for details.\");history.back();</SCRIPT>";
	die;
}
if (-e "$UserDir/notallowed.txt") {
	print "<SCRIPT>alert(\"Your nation has been taken off-line temporarily.  Please contact the GSD team for details.\");history.back();</SCRIPT>";
	$flags = 1;
	die;
}
print "Content-type: text/html\n\n";
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

$UserDir = $MasterPath . "/se/Planets/$Planet/users";
if ($Type == 0) {
	$NUser = $User;
	$NUser =~ tr/_/ /;
	print qqﬁ
<HTML>
<HEAD><TITLE>Shattered Empires Messaging System</TITLE></HEAD>
<BODY BGCOLOR=000000 text=white>
<form method=POST action="http://www.bluewand.com/cgi-bin/classic/Message2.pl?$User&$Planet&$AuthCode&1">
<Table border=1 cellspacing=0 width=100% bgcolor=$Content>
<TR><TD bgcolor=$Header><FONT face=verdana size=-1>From</td><TD><FONT face=arial size=-1>$NUser</td></TR>
<TR><TD bgcolor=$Header><FONT face=verdana size=-1>To</td><TD><FONT face=arial size=-1><select name="To">ﬁ;
#	open (IN, "$UserDir/$User/located.txt") or print "Cannot Open Located<BR>";
#	flock (IN, 1);
#	@Players = <IN>;
#	close (IN);
#	&chopper (@Players);

	opendir (DIR,"$PlanetDir/users") or print "Cannot Open $PlanetDir<BR>";
	@Players = readdir (DIR);
	closedir (DIR);

	@Players = sort(@Players);
	foreach $Item (@Players) {
		unless ($Item eq "." or $Item eq ".." or $Item eq "") {
			if (-d "$UserDir/$Item") {
				if ($To eq $Item) {$ab = "SELECTED"} else {$ab =""}
				$NItem = $Item;
				$NItem =~ tr/_/ /;
				print qqﬁ<OPTION VALUE="$Item" $ab>$NItem</OPTION>ﬁ;
			}
		}
	}
print qqﬁ
</select></td></TR>
<TR><TD bgcolor=$Header><FONT face=verdana size=-1>Subject</td><TD><FONT face=arial size=-1><INPUT TYPE=text name=Subject size=25></td></TR>
<TR><TD colspan=2><FONT face=verdana size=-1><textarea name=Message wrap=virtual cols=34 rows=20></textarea></td></TR>
<TR><TD colspan=2><FONT face=verdana size=-1><CENTER><INPUT TYPE=submit name=submit value="  Send Message  "></TD></TR>
</table>
</FORM>
</body>
	ﬁ;
}

if ($Type == 1) {
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) and ($AuthCode ne "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);

	&parse_form;

#	open (IN, "$UserDir/$User/located.txt");
#	flock (IN, 1);
#	@Found = <IN>;
#	close (IN);
#	&chopper (@Found);

	opendir (DIR, "$PlanetDir/users") or print "Cannot open $PlanetDir";
	@Found = readdir (DIR);
	closedir (DIR);

	@Found = sort(@Found);

	foreach $Item (@Found) {
		if ($Item eq $data{'To'}) {$Flag = 1}
	}
	if ($Flag == 1) {

		$SendPath = $MasterPath . "/se/Planets/$Planet/users/$data{'To'}/messages";

		($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
		if (length($Sec) == 1) {$Sec = "0$Sec"}
		if (length($Min) == 1) {$Min = "0$Min"}
		if (length($Hour) == 1) {$Hour = "0$Hour"}

		$Mon++;
		$Year += 1900;

		open (DATAOUT, ">$SendPath/$Year$Mon$Mday$Hour$Min$Sec");
		flock (DATAOUT, 2);
		print DATAOUT "$User\n";
		print DATAOUT "$Planet\n";
		print DATAOUT "$Mon\/$Mday\/$Year - $Hour:$Min:$Sec\n";
		print DATAOUT "$data{'Subject'}\n";
		print DATAOUT "$data{'Message'}\n";
		close (DATAOUT);
		chmod (0777, "$SendPath/$Year$Mon$Mday$Hour$Min$Sec");
		print qqﬁ<SCRIPT>close();</SCRIPT>ﬁ;
	}
}
if ($Type == 2) {
print qqﬁ<SCRIPT>window.open("http://www.bluewand.com/cgi-bin/classic/Message2.pl?$User&$Planet&$AuthCode&3&$Msg&",'SendMessage','scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,width=350,height=470');history.back();</SCRIPT>ﬁ;
}

if ($Type == 3) {
	open (IN, "$UserDir/$User/messages/$Msg") or print "<BR>Cannot open file";
	$Sender = <IN>;
	$blah = <IN>;
	$blah = <IN>;
	$Subject = <IN>;
	@Message = <IN>;
	close (IN);

	$NUser = $User;
	$NUser =~ tr/_/ /;
	chop($Sender);
	chop ($Subject);
	$Line = "\n______________________________\n";
	print qqﬁ
<HTML>
<HEAD><TITLE>Shattered Empires Messaging System - Reply</TITLE></HEAD>
<BODY BGCOLOR=000000 text=white>
<form method=POST action="http://www.bluewand.com/cgi-bin/classic/Message2.pl?$User&$Planet&$AuthCode&1">
<Table border=1 cellspacing=0 width=100% bgcolor=$Content>
<TR><TD bgcolor=$Header><FONT face=verdana size=-1>From</td><TD><FONT face=arial size=-1>$NUser</td></TR>
<TR><TD bgcolor=$Header><FONT face=verdana size=-1>To</td><TD><FONT face=arial size=-1><select name="To">ﬁ;
#	open (IN, "$UserDir/$User/located.txt");
#	flock (IN, 1);
#	@Players = <IN>;
#	close (IN);
#	&chopper (@Players);

	opendir (DIR, "$PlanetDir/users") or print "Cannot open $PlanetDir";
	@Players = readdir (DIR);
	closedir (DIR);

	@Players = sort(@Players);
	foreach $Item (@Players) {
		unless ($Item eq "." or $Item eq ".." or $Item eq "") {
			if (-d "$UserDir/$Item") {
				$NItem = $Item;
				$NItem =~ tr/_/ /;
				if ($Sender eq $Item) {$A = "SELECTED"} else {$A = ""}
				print qqﬁ<OPTION VALUE="$Item" $A>$NItem</OPTION>ﬁ;
			}
		}
	}
print qqﬁ
</select></td></TR>
<TR><TD bgcolor=$Header><FONT face=verdana size=-1>Subject</td><TD><FONT face=arial size=-1><INPUT TYPE=text name=Subject size=25 value="Re: $Subject"></td></TR>
<TR><TD colspan=2><FONT face=verdana size=-1><textarea name=Message wrap=virtual cols=34 rows=20>@Message$Line</textarea></td></TR>
<TR><TD colspan=2><FONT face=verdana size=-1><CENTER><INPUT TYPE=submit name=submit value="  Send Message  "></TD></TR>
</table>
</FORM>
</body>
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
#sub chopper {
#foreach $k (@_) {
#	chop($k);
#	}
#}
