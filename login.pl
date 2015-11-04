#!/usr/bin/perl
require 'quickies.pl'

&parse_form;

$user_information = $MasterPath . "/User\ Information";
$Mode="Accept";
unless ($Mode ne "No" or $data{'allow'} eq "in") {
	print "Resetting The Game.  Please Wait<BR>";
	die;
}

$data{'handle'} =~ tr/ /_/;
$PlanetType = $data{'planet'};

print "Content-type: text/html\n\n";
$data{'handle'} =~ tr/ /_/;
dbmopen(%planet, "$user_information/planet", 0777) or print $!;
$planet = $planet{$data{'handle'}};
dbmclose(%planet);
@timecalc = localtime (time);
dbmopen(%password, "$user_information/password", 0777) or print $!;
if ($data{'password'} eq $password{$data{'handle'}} or $PlanetType eq "Carsus") {
	if ($planet eq "") {$planet = $PlanetType}

	$userdir=$MasterPath . "/se/Planets/$planet/users";

	chdir("$userdir/$data{'handle'}/") or print "content-type: text/html\n\n $!";

	if (-f "dupe.txt") {
		print "<SCRIPT>alert(\"Your nation has been locked down for security reasons.  Please contact the Bluewand Entertainment team at shatteredempires\@bluewand.com for details.\");history.back();</SCRIPT>";
		die;
	}

	if (-f "notallowed.txt") {
		print "<SCRIPT>alert(\"Your nation has been taken off-line temporarily.  Please contact the Bluewand Entertainment team for details.\");history.back();</SCRIPT>";
		die;
	}

	open (IN, "City.txt") or print "Cannot Open Source<BR>";
	flock (IN, 1);
	@Cities = <IN>;
	close (IN);

	open (DATAIN, "turns.txt");
	flock (DATAIN, 1);
	@turndata = <DATAIN>;
	close (DATAIN);
	&chopper (@turndata);

	$data{'handle'} =~ tr/ /_/;
	dbmopen(%ip, "$user_information/ip", 0777);
	$ip{$data{handle}} = $ENV{'REMOTE_ADDR'};
	dbmclose(%ip);

dbmopen(%date, "$user_information/date", 0777);
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
@TimeUntil = split(/\./,@turndata[2]);
$Days = $yday - @TimeUntil[0];
$Hours = $hour - @TimeUntil[1];
$TotalTurns += ($Days * 24) + $Hours;
@turndata[0] += $TotalTurns;
if (@turndata[0] > 60) {@turndata[0] = 60}
@turndata[2] = "$yday.$hour";

open (DATAOUT, ">turns.txt");
flock (DATAOUT, 2);
foreach $writeline (@turndata) {
	print DATAOUT "$writeline\n";
}



if ($sec < 10) {$sec = "0$sec";}
if ($min < 10) {$min = "0$min";}
if ($hour < 10) {$hour = "0$hour";}
if ($mon < 10) {$mon = "0$mon";}
if ($mday < 10) {$mday = "0$mday";}

$month = ($mon + 1);
$date{$data{'handle'}} = "$hour\:$min\:$sec $month/$mday/$year";
dbmclose(%date);



dbmopen(%hh, "$user_information/httphost", 0777);
$hh{$data{handle}} = $ENV{'USER_ADDR'};
dbmclose(%hh);

if ($flags < 1) {
	open (DATAIN, "land.txt");
	flock (DATAIN, 1);
	@countcheck = <DATAIN>;
	close (DATAIN);
	&chopper (@countcheck);
	opendir (DIR, "/home/bluewand/classic/se/Planets/$planet/");
	@TotalNations = readdir (DIR);
	closedir (DIR);
	open (IN, "$userdir/located.txt");
	flock (IN, 1);
	@FoundNations = <IN>;
	close (IN);
	&chopper (@FoundNations);
	foreach $One (@FoundNations) {
		$Keeper = 1;
		foreach $Two (@TotalNations) {
			if ($Two eq $One) {$Keeper = 2}
		}
		if ($Keeper == 2) {push (@NewLocated,$One)}
	}

	open (OUT, ">$userdir/located.txt");
	foreach $Item (@NewLocated) {
		print OUT "$Item\n";
	}
	close (OUT);



	close (DATAOUT);
	dbmopen(%authcode, "$user_information/accesscode", 0777);
	$DisplayName = $data{'handle'};
	$DisplayName =~ tr/_/ /;
	unless (-e "$userdir/$data{'handle'}/Dead.txt" or -e "$userdir/$data{'handle'}/dead.txt") {
	print qq!
<html>
<head>
<SCRIPT LANGUAGE = "JavaScript">
var handle="$data{'handle'}"
</script>
<title>Shattered Empires: $DisplayName</title>
</head>

<frameset cols="110,1*" rows="*" frameborder="NO" border="0" framespacing="0"> 
  <frame src="http://www.bluewand.com/cgi-bin/classic/menu2.pl?$data{'handle'}&$planet&$authcode{$data{'handle'}}" SCROLLING="NO" marginwidth="0" marginheight="0">
  <frameset rows="90,1*" frameborder="NO" border="0" framespacing="0"> 
    <frame src="http://www.bluewand.com/classic/Gametop2.html" name="gameviewb" scrolling="NO" noresize frameborder="NO" marginwidth="0" marginheight="0">
    <frame src="http://www.bluewand.com/cgi-bin/classic/Newst.pl?$data{'handle'}&$planet&$authcode{$data{'handle'}}" name="Frame5">
  </frameset>
</frameset>
<noframes>
<body bgcolor="#000000">
</body></noframes>
</html>
<noframes><body bgcolor="#FFFFFF">
</body></noframes>
</html>	!;
} else {
print qq!
<html>
<head>
<SCRIPT LANGUAGE = "JavaScript">
var handle="$data{'handle'}"
</script>
<title>Shattered Empires: $DisplayName</title>
</head>

<frameset cols="110,1*" rows="*" frameborder="NO" border="0" framespacing="0"> 
  <frame src="http://www.bluewand.com/cgi-bin/classic/DeadPanel.pl?$data{'handle'}&$planet&$authcode{$data{'handle'}}" SCROLLING="NO" marginwidth="0" marginheight="0">
  <frameset rows="90,1*" frameborder="NO" border="0" framespacing="0"> 
    <frame src="http://www.bluewand.com/classic/Gametop2.html" name="gameviewb" scrolling="NO" noresize frameborder="NO" marginwidth="0" marginheight="0">
    <frame src="http://www.bluewand.com/cgi-bin/classic/Dead.pl?$data{'handle'}&$planet&$authcode{$data{'handle'}}" name="Frame5">
  </frameset>
</frameset>
<noframes>
<body bgcolor="#000000">
</body></noframes>
</html>
<noframes><body bgcolor="#FFFFFF">
</body></noframes>
</html>!;
}

}

}

else {
	print "<SCRIPT>alert(\"Sorry your typed in your login or password incorrectly!\")\;history.back()</SCRIPT>";
}

dbmclose(%datain);

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

sub displayno {
print qq!
<HTML>
<HEAD>
<TITLE>Unknown Country</TITLE>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
</HEAD>
<BODY BGCOLOR="#FFFFFF">

<DIV ALIGN="CENTER">

  <P><FONT SIZE="5"><B><FONT FACE="Arial, Helvetica, sans-serif">Bluewand Entertainment</FONT></B></FONT> </P>

  <P><FONT FACE="Arial, Helvetica, sans-serif"><B>Shattered Empires Beta Development<BR>

    <U>Validate Country</U></B></FONT></P>

  <P>&nbsp;</P>

<FONT FACE="Arial, Helvetica, sans-serif">Either your country has not yet been activated, or you have not created it at all.  To activate your nation, please enter the authorization code which was sent to you.  To do this, you will need to switch to the Validation menu option.  To create, use the 'Create New User' link and fill out the information there.<BR>



  <FORM METHOD="post" ACTION="http://www.bluewand.com/cgi-bin/classic/creation.pl">

    <TABLE BORDER="0" WIDTH="60%">

      <TR>

        <TD><FONT FACE="Arial, Helvetica, sans-serif">Country Name:</FONT></TD>

        <TD> 

          <DIV ALIGN="CENTER">

            <FONT FACE="Arial, Helvetica, sans-serif">

            <INPUT TYPE="TEXT" NAME="handle" SIZE="20" MAXLENGTH="20">

            </FONT> 

          </DIV>

        </TD>

      </TR>

      <TR>

        <TD><FONT FACE="Arial, Helvetica, sans-serif">Password:</FONT></TD>

        <TD> 

          <DIV ALIGN="CENTER"><FONT FACE="Arial, Helvetica, sans-serif">

            <INPUT TYPE="PASSWORD" NAME="password" SIZE="20" MAXLENGTH="20"></FONT>

          </DIV>

        </TD>

      </TR>

      <TR>

        <TD><FONT FACE="Arial, Helvetica, sans-serif">Authorization Key:</FONT></TD>

        <TD>

          <DIV ALIGN="CENTER">

            <FONT FACE="Arial, Helvetica, sans-serif"> 

            <INPUT TYPE="TEXT" NAME="author" SIZE="20">

            </FONT> 

          </DIV>

        </TD>

      </TR>

    </TABLE>

    <P>

      <INPUT TYPE="IMAGE" src="http://www.shatteredempires.com/shatteredempires/images/enter.gif" border="0" width="83" height="23" target="parent">

  </FORM>

<BR>

  <HR>

  <FONT FACE="Arial, Helvetica, sans-serif">©Copyright 1998-2000 Bluewand Entertainment. All rights reserved. Do not duplicate or redistribute in any form without permission. </FONT>

</FONT>

  </DIV>

</BODY>

</HTML>

!;

}

#sub chopper{
#	foreach $k(@_) {chop($k);}
#}

