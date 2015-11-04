#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";



($User,$Planet,$Authcode,$SendNum,$pathnum)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
#dbmopen(%authcode, "$user_information/accesscode", 0777);
#if(($Authcode ne $authcode{$User}) || ($Authcode eq "")){
#	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
#	die;
#}
#dbmclose(%authcode);

$UserPath = $MasterPath . "/se/Planets/$Planet/users/$User/events";
$MainPath = $MasterPath . "/se/News";
$WorldPath  = $MasterPath . "/se/Planets/$Planet/News";

if ($pathnum == 1) {
	opendir (DIR, "$MainPath");
	@Files = readdir (DIR);
	closedir (DIR);
	open (FILEIN, "$MainPath/$SendNum") or die "Can't find file";
	while (eof(FILEIN) != 1) {  
	    @default = <FILEIN>;
	}

	$blah = shift(@default);
	$blah = shift(@default);
}
if ($pathnum == 2) {
	opendir (DIR, "$WorldPath");
	@Files = readdir (DIR);
	closedir (DIR);
	open (FILEIN, "$WorldPath/$SendNum") or die "Can't find file";
	while (eof(FILEIN) != 1) {  
	    @default = <FILEIN>;
	}

	$blah = shift(@default);

	$blah = shift(@default);

}

if ($pathnum == 3) {

	opendir (DIR, "$UserPath");

	@Files = readdir (DIR);

	closedir (DIR);

	open (FILEIN, "$UserPath/$SendNum") or die "Can't find file";

	while (eof(FILEIN) != 1) {  

	    @default = <FILEIN>;

	}



	$blah = shift(@default);

	$blah = shift(@default);

}



print qq!

<HTML>

<BODY BGCOLOR="#000000" TEXT="#FFFFFF">

<CENTER>

!;



unless ($SendNum eq "") {

print qq!

<FONT FACE="Arial, Helvetica, sans-serif">

<TABLE border=1 WIDTH="90%" cellspacing=0>

<TR>

<TD BGCOLOR=666666><CENTER><FONT face=verdana size=-1>@default</TD>

</TR>

</TABLE>

</CENTER>

</BODY>

</HTML>

!;

}

