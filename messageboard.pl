#!/usr/bin/perl


$messageboard = "home/shatteredempires/SE/public_html/messageboard";
$adpath="home/shatteredempires/SE/public_html/";

($topicarea,$message) = split(/&/,$ENV{'QUERY_STRING'});
($temp,$topicarea) = split(/=/,$topicarea);
($temp,$message) = split(/=/,$message);
$topicarea =~ tr/+/ /;
$message =~ tr/+/ /;

open(AD,"$adpath/ad.txt");
@ad=<AD>;
close(AD);

open(FLAG,"$messageboard/$topicarea.cnt");
$flag=<FLAG>;
close(FLAG);
open(MFLAG,"$messageboard/$topicarea/$message.cnt");
$mflag=<MFLAG>;
close(MFLAG);



$topicarea =~ tr/ /_/;
$message =~ tr/ /_/;
if($topicarea ne ""){print "Set-Cookie: $topicarea=$flag; expires=Wednesday, 09-Nov-99 00:00:00 GMT; path=/~hardi/;\n";};
if($message ne ""){print "Set-Cookie: $topicareaô$message=$mflag; expires=Wednesday, 09-Nov-99 00:00:00 GMT; path=/~hardi/;\n";};
$topicarea =~ tr/_/ /;
$message =~ tr/_/ /;

print "Content-type: text/html\n\n";
print qqô
<HTML>
<HEAD>
<SCRIPT>
function getcookievalue(cookie,servercookie){
var cookie = getcookievalue.arguments[0];
var cookieeq = cookie+"=";
if(document.cookie.indexOf(";",document.cookie.indexOf(cookieeq)) != "-1")
{var place = document.cookie.indexOf(";",document.cookie.indexOf(cookieeq))}
else{var place = document.cookie.length}
if((document.cookie.indexOf(cookieeq)) != "-1"){
var cookie = document.cookie.substring(document.cookie.indexOf(cookieeq)+cookieeq.length,place);
} else {
var cookie = ""
}

if(cookie != servercookie)
{return "<IMG SRC = 'http://www.golden.net/~hardi/images/newmessage.gif'>";}
else{return "&nbsp;";}
}
function getcookie(cookie){
var cookieeq = cookie+"=";
if(document.cookie.indexOf(";",document.cookie.indexOf(cookieeq)) != "-1")
{var place = document.cookie.indexOf(";",document.cookie.indexOf(cookieeq))}
else{var place = document.cookie.length}
if((document.cookie.indexOf(cookieeq)) != "-1"){
var cookie = document.cookie.substring(document.cookie.indexOf(cookieeq)+cookieeq.length,place);
} else {
var cookie = ""
}
return cookie;
}
</SCRIPT>
</HEAD>
<BODY BGCOLOR="#FFFFFF">
<center><P><FONT SIZE="5"><B><FONT FACE="Arial, Helvetica, sans-serif">Global Simulations 
    Development</FONT></B></FONT> </P>
  <P><FONT FACE="Arial, Helvetica, sans-serif"><B>Shattered Empires Beta Development<BR>
    <U>Message Board</U></B></FONT></P>
</center>
@ad
<hr>

ô;

if($topicarea eq ""){
	&select_topicarea;
}
if($message eq "" and  $topicarea ne ""){
	&select_thread;
}
if($message ne "" and  $topicarea ne ""){
	&display_messages;
}

sub select_topicarea { 
opendir(DIR,$messageboard);
@topics=readdir(DIR);
close(DIR);
print qqô
<DIV ALIGN="Right"><FONT FACE="Arial, Helvetica, sans-serif"><A HREF="http://www.golden.net/~hardi/messageadduser.html" STYLE = "text-decoration:none;color:black"> Add User </A>
/<A HREF="http://www.golden.net/~hardi/messagevalidate.html" STYLE = "text-decoration:none;color:black"> Verify User </A>
</FONT></DIV>
<table width = "100%">
<TR bgcolor="666666"><TD>&nbsp;</TD><TD width = "30%"><FONT FACE="Arial, Helvetica, sans-serif" COLOR="White">Topic Area</FONT></TD><TD width ="10%"><FONT FACE="Arial, Helvetica, sans-serif" COLOR="White">Threads</FONT></TD><TD><FONT FACE="Arial, Helvetica, sans-serif" COLOR="White">Description</FONT></TD></TR>

ô;

foreach $k(@topics) {
if (-f "$messageboard/$k" or $k eq "." or $k eq "..") {next}
opendir(DIR,"$messageboard/$k");
@threads=readdir(DIR);
splice(@threads,0,2);
close(DIR);
$amount=scalar(@threads);
open(DESCRIPTION,"$messageboard/$k.txt");
@description=<DESCRIPTION>;
close(DESCRIPTION);

open(FLAG,"$messageboard/$k.cnt");
$flag=<FLAG>;
close(FLAG);
$name = $k;
$kunderscore=$k;
$kunderscore =~ tr/ /_/;

$k =~ tr/ /+/;
$amount = int($amount/2);
push(@temphtml,qq!
<TR bgcolor="C0C0C0"><TD><SCRIPT>document.write(getcookievalue('$kunderscore','$flag'))</SCRIPT></TD><TD><FONT FACE="Arial, Helvetica, sans-serif" COLOR="White"><A HREF = "http://www.bluewand.com/cgi-bin/classic/messageboard.pl?topicarea=$k" STYLE = "text-decoration:none;color:black">$name</A></FONT></TD><TD><FONT FACE="Arial, Helvetica, sans-serif">$amount</FONT></TD><TD><FONT FACE="Arial, Helvetica, sans-serif">@description</FONT></TD></TR>
!);
}
print qq!
</SCRIPT>
@temphtml
</table>
</BODY>
!;
}

sub select_thread {
print qq!
<FONT FACE="Arial, Helvetica, sans-serif"><A HREF = "http://www.bluewand.com/cgi-bin/classic/messageboard.pl" STYLE = "text-decoration:none;color:black">Main Page</A></FONT>
<table width="100%">
<TR bgcolor="666666"><TD>&nbsp;</TD><TD width = "60%"><FONT FACE="Arial, Helvetica, sans-serif" COLOR="White">Thread</FONT></TD><TD><FONT FACE="Arial, Helvetica, sans-serif" COLOR="White">Originator</FONT></TD><TD><FONT FACE="Arial, Helvetica, sans-serif" COLOR="White">Number of posts</FONT></TD></TR>
!;
opendir(DIR,"$messageboard/$topicarea");
@threads=readdir(DIR);
splice(@threads,0,2);
@threads = reverse(@threads);
foreach $k(@threads){
if(-f "$messageboard/$topicarea/$k") {next}
opendir(DIR,"$messageboard/$topicarea/$k");
@messages=readdir(DIR);
splice(@messages,0,2);
close(DIR);
$amount=scalar(@messages)-1;
open(originator,"$messageboard/$topicarea/$k/originator");
@originator=<originator>;
close(originator);
$topicareaname = $topicarea;
$topicareaname =~ tr/ /+/;
$name = $k;
$k =~ tr/ /+/;

open(FLAG,"$messageboard/$topicarea/$name.cnt");
$topicarea =~ tr/ /_/;
$flag=<FLAG>;
close(FLAG);

$kunderscore=$k;
$kunderscore =~ tr/+/_/;

print qq!
<TR bgcolor = "C0C0C0"><TD><SCRIPT>document.write(getcookievalue('$topicareaô$kunderscore','$flag'))</SCRIPT></TD><TD><FONT FACE="Arial, Helvetica, sans-serif"><A HREF = "http://www.bluewand.com/cgi-bin/classic/messageboard.pl?topicarea=$topicareaname&message=$k" STYLE = "text-decoration:none;color:black">$name</A></TD><TD><FONT FACE="Arial, Helvetica, sans-serif">@originator</TD><TD><FONT FACE="Arial, Helvetica, sans-serif">$amount</TD></TR>
!;
$topicarea =~ tr/_/ /;
}
print qq!
</table>
<Center>
<HR>
<form name = "messageboard" method ="post" action = "http://www.bluewand.com/cgi-bin/classic/addmessage.pl">
<table border="0" width="100%">
<tr> 
<td width="22%"><font face="Arial, Helvetica, sans-serif">Handle:</font></td>
<td width="78%"> <font face="Arial, Helvetica, sans-serif"> 
<input type="text" name="user" size="20" maxlength="40">
</font> </td>
</tr>
<tr> 
<td width="22%"><font face="Arial, Helvetica, sans-serif">Password:</font></td>
<td width="78%"> <font face="Arial, Helvetica, sans-serif"> 
<input type="password" name="password" size="20" maxlength="40">
</font> </td>
</tr>
<tr> 
<td width="22%"><font face="Arial, Helvetica, sans-serif"> Thread name:</font></td>
<td width="78%"><font face="Arial, Helvetica, sans-serif"> 
<input type="text" name="thread" size="20" maxlength="40">
</font> </td>
</tr>
<tr> 
<td width="22%"><font face="Arial, Helvetica, sans-serif">Message:</font></td>
<td width="78%">&nbsp;</td>
</tr>
<tr> 
<td colspan=2><font face="Arial, Helvetica, sans-serif"> 
<textarea name="message" cols="50" rows="10" wrap="virtual"></textarea>
</font> </td>
</tr>
</table>
<p>
<input type="hidden" name="topicarea" value = "$topicarea">
<input type="submit" value="    Send    ">
<input type="reset" name="submit2" value="    Clear    ">
</p>
<P></form>
</CENTER>
<HR>
<P><FONT FACE="Arial, Helvetica, sans-serif">©Copyright 1998 Glob</FONT><FONT FACE="Arial, Helvetica, sans-serif">al 
Simulations Development Ltd. All rights reserved. Do not duplicate or redistribute 
in any form without permission. </FONT> </P>
</BODY>
<script>
document.messageboard.user.value=getcookie('user');
document.messageboard.password.value=getcookie('pword');
</script>
!;

}
sub display_messages {
$topicareaname = $topicarea;
$topicareaname =~ tr/ /+/;
print qq!
<FONT FACE="Arial, Helvetica, sans-serif"><A HREF = "http://www.bluewand.com/cgi-bin/classic/messageboard.pl" STYLE = "text-decoration:none;color:black">Main Page</A> / 
<A HREF = "http://www.bluewand.com/cgi-bin/classic/messageboard.pl?topicarea=$topicareaname" STYLE = "text-decoration:none;color:black">$topicarea</A></FONT>
<table width="100%">
<tr bgcolor="666666"><td width="10%"><FONT FACE="Arial, Helvetica, sans-serif" COLOR="White">User</FONT></td><td><FONT FACE="Arial, Helvetica, sans-serif" COLOR="White">Message</FONT></td></tr>
!;
$counter = 0;
while(-f "$messageboard/$topicarea/$message/$counter.msg"){
open(MESSAGE,"$messageboard/$topicarea/$message/$counter.msg") or die "haha!";
@messagetext = <MESSAGE>;
close(MESSAGE);
$user=splice(@messagetext,0,1);
print qq!
<tr bgcolor="C0C0C0"><td><FONT FACE="Arial, Helvetica, sans-serif">$user</FONT></td><td><FONT FACE="Arial, Helvetica, sans-serif">@messagetext</FONT></td></tr>
!;
$counter++;
}
print qq!
</table>
<Center>
<HR>
<form name = "messageboard" method ="post" action = "http://www.bluewand.com/cgi-bin/classic/addmessage.pl">
<table border="0" width="100%">
<tr> 
<td width="22%"><font face="Arial, Helvetica, sans-serif">Handle:</font></td>
<td width="78%"> <font face="Arial, Helvetica, sans-serif"> 
<input type="text" name="user" size="20" maxlength="40">
</font> </td>
</tr>
<tr>
<td width="22%"><font face="Arial, Helvetica, sans-serif">Password:</font></td>
<td width="78%"> <font face="Arial, Helvetica, sans-serif"> 
<input type="PASSWORD" name="password" size="20" maxlength="40">
</font> </td>
</tr>
<tr> 
<td colspan = 4><font face="Arial, Helvetica, sans-serif">Message:</font></td>
</tr>
<tr> 
<td colspan=4><font face="Arial, Helvetica, sans-serif"> 
<textarea name="message" cols="50" rows="10" wrap="virtual"></textarea>
</font> </td>
</tr>
</table>
<p>
<input type="hidden" name="topicarea" value = "$topicarea">
<input type="hidden" name="messagedir" value = "$message">
<input type="submit" value="    Send    ">
<input type="reset" name="submit2" value="    Clear    ">
</p>
<P></form>
</CENTER>
<HR>
<P><FONT FACE="Arial, Helvetica, sans-serif">©Copyright 1998 Glob</FONT><FONT FACE="Arial, Helvetica, sans-serif">al 
Simulations Development Ltd. All rights reserved. Do not duplicate or redistribute 
in any form without permission. </FONT> </P>
</BODY>
<script>
document.messageboard.user.value=getcookie('user');
document.messageboard.password.value=getcookie('pword');
</script>
!;

}
