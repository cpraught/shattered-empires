#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($User,$Planet,$Authcode)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
#dbmopen(%authcode, "$user_information/accesscode", 0777);
if ($Authcode == 1){
	$ContentFlag = 1;
}
#dbmclose(%authcode);

$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";


print qq!
<HTML>
<BODY BGCOLOR="#000000" TEXT="#FFFFFF"><CENTER>
<table width=100% border=1 cellspacing=0>
<TR bgcolor="$Header"><TD><font face=verdana size=-1 color=$HeaderFont><center><B>News</TD></TR></table><BR>
!;

$UserPath = $MasterPath . "/se/Planets/$Planet/users/$User/events/";
$MainPath = $MasterPath . "/se/News/";
$WorldPath  = $MasterPath . "/se/Planets/$Planet/News/";

opendir (DIR, "$MainPath") or print "Cannot open dir";
@gameNews = readdir (DIR);
closedir (DIR);


unless ($ContentFlag == 1) {
	print qq!
<CENTER>
<FONT FACE="Arial" size="-1">
<B>Game News:</B>
<TABLE BORDER="1" WIDTH="80%" cellspacing=0>
	!;
	foreach $Item (@gameNews) {
		if ($Item ne '.' and $Item ne '..') {
			open (DATAIN, "$MainPath$Item");
			flock (DATAIN, 1);
			@stuff = <DATAIN>;
			close (DATAIN);
			&chopper (@stuff);
			$header = shift(@stuff);
			$date = shift(@stuff);
			print qq!
<FONT FACE="Arial" size="-1">
<TR>
<TD BGCOLOR="$Header"><CENTER><FONT face=verdana size=-1><A HREF="Newsf2.pl?$User&$Planet&$Authcode&$Item&1" TARGET="bottom" STYLE="text-decoration:none;color:$HeaderFont">$header</A></TD>
<TD BGCOLOR=$Content><CENTER><FONT face=verdana size=-1 color=$ContentFont>$date</TD>
</TR>
			!;	
	        }
	}
}

unless ($ContentFlag == 1) {
	print qq!
</TABLE></CENTER>!;

print qq!
<CENTER><FONT FACE="Arial" size="-1"><B>Global News: $Planet</B><TABLE BORDER="1" WIDTH="80%" cellspacing=0>!;

	opendir (DIR, "$WorldPath");
	@globalNews = readdir (DIR);
	closedir (DIR);
	@globalNews = reverse(sort (@globalNews));

	foreach $Dated (@globalNews) {
		($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat("$WorldPath/$Dated");
		$Thread{$Dated} = $mtime;
	}
	foreach $Item ((sort {$Thread{$b} <=> $Thread{$a}} keys %Thread )) {
		if (-f "$WorldPath$Item") {
			open (DATAIN, "$WorldPath$Item");
			@stuff = <DATAIN>;
			close (DATAIN);
			&chopper (@stuff);
			$header = shift(@stuff);
			$date = shift(@stuff);
			print qq!
<FONT FACE="Arial" size="-1">
<TR>
<TD BGCOLOR=$Header><CENTER><FONT face=verdana size=-1><A HREF="Newsf2.pl?$User&$Planet&$Authcode&$Item&2" TARGET="bottom" STYLE="text-decoration:none;color:$HeaderFont">$header</A></TD>
<TD BGCOLOR=$Content><CENTER><FONT face=verdana size=-1 color=$ContentFont>$date</TD>
</TR>
			!;
			if ((-C "$WorldPath$Item")> 2) {
				unlink ("$WorldPath$Item");
			}	
		}
	}
}

$NiceName = $User;
$NiceName =~ tr/_/ /;


print qq!
</TABLE>
<BR>
<FONT FACE="Arial" size="-1"><B>National News: $NiceName</B>
<TABLE BORDER="1" WIDTH="80%" cellspacing=0>
!;

opendir (DIR, "$UserPath") or print "Cannot open local news directory: $UserPath<BR>";
@natNews = reverse(readdir (DIR));
closedir (DIR);
sort(@natNews);

foreach $Dated (@natNews) {
	($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,$atime,$mtime,$ctime,$blksize,$blocks) = stat("$UserPath/$Dated");
	$Thread{$Dated} = $mtime;
}
foreach $Item ((sort {$Thread{$b} <=> $Thread{$a}} keys %Thread )) {
	if (-f "$UserPath$Item") {
		open (DATAIN, "$UserPath$Item");
		@stuff = <DATAIN>;
		close (DATAIN);
		&chopper (@stuff);
		$header = shift(@stuff);
		$date = shift(@stuff);	

print qq!
<FONT FACE="Arial" size="-1">
<TR>
<TD BGCOLOR=$Header><CENTER><FONT face=verdana size=-1><A HREF="Newsf2.pl?$User&$Planet&$Authcode&$Item&3" TARGET="bottom" STYLE="text-decoration:none;color:$HeaderFont">$header</A></TD>
<TD BGCOLOR=$Content><CENTER><FONT face=verdana size=-1 color=$ContentFont>$date</TD>
</TR>
!;
		if ((-C "$UserPath$Item")> 2) {
			unlink ("$UserPath$Item");
		}
	}	
}
print qq!
</TABLE>
</CENTER>
</BODY>
</HTML>
!;

#sub chopper {
#foreach $k (@_) {
#	chop($k);
#	}
#}
