#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode,$Mode)=split(/&/,$ENV{QUERY_STRING});
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
$user_information = "/home/bluewand/data/classic/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);

$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

&parse_form;

$RootPath = $MasterPath . "/se/Planets/$Planet/alliances";
$PlayerPath = $MasterPath "/se/Planets/$Planet/users/$User";

if (-e "$PlayerPath/alliance.txt") {
	open (IN, "$PlayerPath/alliance.txt");
	flock (IN, 1);
	$AllianceJoined = <IN>;
	close (IN);
	chop ($AllianceJoined);
}

$Path = "http://www.bluewand.com/cgi-bin/classic/AllyDisplay.pl";

if ($Mode eq "ackd") {&MakeAlliance}

opendir (DIR, $RootPath) or print $!;
@List = readdir (DIR);
closedir (DIR);

@List = sort(@List);

print qqﬁ
<html>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<body BGCOLOR="#000000" text="#FFFFFF">
<table border=1 cellspacing=0 width=100%><TR><TD BGCOLOR="$Header"><CENTER><B><font FACE="Arial" size="-1">Alliances</font></TD></TR></TAble><BR><BR>

<TABLE border=1 cellspacing=0 width=100%>
<TR BGCOLOR="$Header"><TD WIDTH="22%"><FONT FACE="Arial" size="-1">Name</FONT></TD><TD WIDTH="11%"><FONT FACE="Arial" size="-1">Type</FONT></TD><TD WIDTH="15%"><FONT FACE="Arial" size="-1">Members</FONT></TD><TD WIDTH="25%"><FONT FACE="Arial" size="-1">Theory</FONT></TD>
ﬁ;
$ACount = 0;
foreach $Item (@List) {
	if ($Item ne '.' and $Item ne '..') {
		if (-f "$RootPath/$Item") {unlink ("$RootPath/$Item")} else {
			if (-f "$RootPath/$Item/Faction.txt") {$BTag = "<B>"} else {$BTag = ""}
			$ACount ++;
			$NItem = $Item;
			$NItem =~ tr/_/ /;
			open (DATAIN, "$RootPath/$Item/allianceinfo.txt") or print $!;
			flock (DATAIN, 1);
			@Info = <DATAIN>;
			close (DATAIN);
			&chopper (@Info);

			open (DATAIN, "$RootPath/$Item/members.txt");
			flock (DATAIN, 1);
			@Members = <DATAIN>;
			close (DATAIN);
			$MemberCount = scalar(@Members);

			$c = "white";
			if ($Item eq $AllianceJoined) {
				$c = "0F5030";
				$b = qq!Color ="#0F5030"!;
			} else {$b = ""}
	$Wowzers = qq!<A href = "$Path?$User&$Planet&$AuthCode&$Item" target ="Frame5" ONMOUSEOVER = "parent.window.status='$NItem Information';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:$c">$BTag$NItem</a></FONT>!;
			print qqﬁ<TR BGCOLOR="$Content"><TD WIDTH="22%"><FONT FACE="Arial" size="-1" $b>$Wowzers</FONT></TD><TD WIDTH="11%"><FONT FACE="Arial" size="-1" $b>$BTag@Info[1]</FONT></TD><TD WIDTH="15%"><FONT FACE="Arial" size="-1" $b>$BTag$MemberCount</FONT></TD><TD WIDTH="25%"><FONT FACE="Arial" size="-1" $b>$BTag@Info[4] @Info[3]</FONT></TD></TR>ﬁ;
		}
	}
}
if ($ACount < 1) {
	print qq!<TR BGCOLOR="$Content"><TD colspan = 5><FONT FACE="Arial" size="-1"><CENTER>There are currently no alliances</TD></TR>!;
}
print $Acount;
print qqﬁ</table><BR>ﬁ;

if (-e "$PlayerPath/alliance.txt") {
	open (DATAIN, "$PlayerPath/allianceinfo.txt");
	flock (DATAIN, 1);
	$AllianceName = <DATAIN>;
	close (DATAIN);
	if ($AllianceName eq $User) {&RunAlliance} else {&DispAlliance}
} else {
	if (-e "$PlayerPath/apply.txt") {
		open (IN, "$PlayerPath/apply.txt");
		flock (IN, 1);
		$Alliance = <IN>;
		close (IN);
		&chopper ($Alliance);		

		print qq!<BR><BR><center><font face=arial size=-1><a href="http://www.bluewand.com/cgi-bin/classic/AllyUtil2.pl?$User&$Planet&$AuthCode&$Alliance&blah&blah&11112" STYLE="text-decoration:none;color:808080">Click to revoke application</a>!;
	} else {
		&MakeAlliance2;
	}
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

#
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

sub MakeAlliance {
	unless (-e "$PlayerPath/apply.txt") {
		$Temps = $data{'Alliance'};
		$Temps =~ tr/ /_/;
		if (-e "$RootPath/$Temps") {
			print "<SCRIPT>alert(\"There is already an alliance using that name.  Please enter a new one.\")\;history.back()</SCRIPT>";
			die;
		}
		if ($data{'Alliance'} eq "") {
			print "<SCRIPT>alert(\"You have neglected to enter an alliance name.  All alliances must be named.\")\;history.back()</SCRIPT>";
			die;
		}
		if ($data{'Alliance'} =~ m/[^A-Z a-z 1-90]/) {
			print "<SCRIPT>alert(\"You have attempted to use characters in an alliances name that are not valid.  Valid characters include all letters and space.\")\;history.back()</SCRIPT>";
			die;
		}
		$WorkingName = $data{'Alliance'};
		$WorkingName =~ tr/ /_/;
		mkdir ("$RootPath/$WorkingName", 0777) or print "Cannot Create Directory";
		mkdir ("$RootPath/$WorkingName/military", 0777);
		mkdir ("$RootPath/$WorkingName/reports", 0777 );
		mkdir ("$RootPath/$WorkingName/tech", 0777 );

		open (DATAOUT, ">$RootPath/$WorkingName/members.txt");
		flock (DATAOUT, 2);
		print DATAOUT "0|$User|$Planet\n";
		close (DATATOUT);

		open (DATAOUT, ">$RootPath/$WorkingName/allianceinfo.txt");
		flock (DATAOUT, 2);
		print DATAOUT "$User\n";
		print DATAOUT "Faction\n";
		print DATAOUT "1\n";
		print DATAOUT "$data{'gov'}\n";
		print DATAOUT "$data{'econ'}\n";
		print DATAOUT "$data{'Dues'}\n";
		print DATAOUT "$data{'Link'}\n";

		$ImageEnd = substr($data{'Image'},length($data{'Image'})-3,length($data{'Image'}));
		if ($ImageEnd eq "gif" or $ImageEnd eq "jpg") {print OUT "$data{'Image'}\n"} else {print OUT qq!http://www.bluewand.com/classic/images/Ingame/invis.jpg!}


		print DATAOUT "$data{'Image'}\n";
		close (DATAOUT);

		$text = $data{'Summary'};
		$text =~ s/\cM//g;
		$text =~ s/\n\n/<p>/g;
		$text =~ s/\n/<br>/g;
		$text =~ s/&lt;/</g; 
		$text =~ s/&gt;/>/g; 
		$text =~ s/&quot;/"/g;

		open (DATAOUT, ">$RootPath/$WorkingName/summary.txt");
		flock (DATAOUT, 2);
		print DATAOUT "$text";
		close (DATAOUT);

		open (DATAOUT, ">$RootPath/$WorkingName/ranks.txt");
		flock (DATAOUT, 2);
		print DATAOUT "Founder\n";
		print DATAOUT "Enter Rank\n";
		print DATAOUT "Enter Rank\n";
		print DATAOUT "Enter Rank\n";
		print DATAOUT "Enter Rank\n";
		print DATAOUT "Inductee\n";
		close (DATAOUT);

		open (DATAOUT, ">$PlayerPath/alliance.txt");
		flock (DATAOUT, 2);
		print DATAOUT "$WorkingName\n";
		close (DATAOUT);

#		print qq!<SCRIPT>window.open("http://www.bluewand.com/cgi-bin/classic/SENNRequest.pl?$User&$Planet&$AuthCode&N/A&1&New_Alliance",'SENNRequest','scrollbars=no,toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,width=450,height=300');</SCRIPT>!;
	}	
}

sub MakeAlliance2 {
	print qqﬁ<table border=1 cellspacing=0 width=100%><TR><TD BGCOLOR="$Header"><font FACE="Arial" size="-1">Create Alliance</font></TD></TR></TAble><BR>

<FORM method="POST" action="http://www.bluewand.com/cgi-bin/classic/Allys.pl?$User&$Planet&$AuthCode&ackd">

<table border=0 cellspacing=0 width=100%><TR><TD width=50%>
<table border=1 cellspacing=0 width=100%>
<TR><TD width=50% BGCOLOR="$Header"><font FACE="Arial" size="-1">Name</TD><TD BGCOLOR="$Content"><font FACE="Arial" size="-1"><INPUT TYPE="textbox" maxsize=20 size=22 name="Alliance"></TD></TR>
<TR><TD width=50% BGCOLOR="$Header"><font FACE="Arial" size="-1">Dues</TD><TD BGCOLOR="$Content"><font FACE="Arial" size="-1">\$<INPUT TYPE="textbox" maxsize=20 size=21 name ="Dues" value=0></TD></TR>
<TR><TD width=50% BGCOLOR="$Header"><font FACE="Arial" size="-1">Style</TD><TD BGCOLOR="$Content"><font FACE="Arial" size="-1"><SELECT NAME="econ">
<OPTION VALUE="Capitalist">Capitalist</OPTION>
<OPTION VALUE="Fascist">Fascist</OPTION>
<OPTION VALUE="Mercantalist">Mercantalist</OPTION>
<OPTION VALUE="Socalist">Socialist</OPTION>
</SELECT><SELECT NAME="gov">
<OPTION VALUE="Democracy">Democracy</OPTION>
<OPTION VALUE="Dictatorship">Dictatorship</OPTION>
<OPTION VALUE="Theocracy">Theocracy</OPTION>
<OPTION VALUE="Monarchy">Monarchy</OPTION>
<OPTION VALUE="Republic">Republic</OPTION>
</SELECT></TD></TR>
</TABLE></TD><TD WIDTH=50%>

<table border=1 cellspacing=0 width=100%>
<TR><TD width=25% BGCOLOR="$Header"><font FACE="Arial" size="-1">Logo Path</TD><TD BGCOLOR="$Content"><font FACE="Arial" size="-1"><INPUT TYPE="textbox" size=30 name="Image" value="http://www.bluewand.com/classic/images/Ingame/invis.jpg"></TD></TR>
<TR><TD width=25% BGCOLOR="$Header"><font FACE="Arial" size="-1">Homepage</TD><TD BGCOLOR="$Content"><font FACE="Arial" size="-1"><INPUT TYPE="textbox" size=30 name="Link" value="http://"></TD></TR>
<TR><TD width=25% BGCOLOR="$Header"><font FACE="Arial" size="-1">Summary</TD><TD BGCOLOR="$Content"><font FACE="Arial" size="-1"><textarea name="Summary" cols="28" rows="2" wrap="VIRTUAL" face=arial font=arial>Enter brief summary here</textarea></TD></TR>
</TABLE>
</TD></TR></TABLE><FONT SIZE="-1"><CENTER><BR>
<INPUT TYPE=submit name=submit value="Proceed">
</FORM>ﬁ;
}
