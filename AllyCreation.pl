#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);

print qq±
<FORM method="POST" action="http://www.bluewand.com/cgi-bin/classic/Allys.pl?$UserName&$Planet&$Authcode&ackd">
html>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<body BGCOLOR="#000000" text="#FFFFFF">
<table border=1 cellspacing=0 width=100%><TR><TD BGCOLOR="#333333"><CENTER><B><font fACE="Arial" size="-1">Faction Creation</font></TD></TR></TAble><BR><BR>


<table border=0 cellspacing=0 width=100%><TR><TD width=50%>
<table border=1 cellspacing=0 width=100%>
<TR><TD width=50% BGCOLOR="#333333"><font FACE="Arial" size="-1">Name</TD><TD BGCOLOR="#666666"><font FACE="Arial" size="-1"><INPUT TYPE="textbox" maxsize=20 size=22 name="Alliance"></TD></TR>
<TR><TD width=50% BGCOLOR="#333333"><font FACE="Arial" size="-1">Dues</TD><TD BGCOLOR="#666666"><font FACE="Arial" size="-1">$<INPUT TYPE="textbox" maxsize=20 size=21 name ="Dues" value=0></TD></TR>
<TR><TD width=50% BGCOLOR="#333333"><font FACE="Arial" size="-1">Style</TD><TD BGCOLOR="#666666"><font FACE="Arial" size="-1"><SELECT NAME="econ">
<OPTION VALUE="Capitalist">Capitalist</OPTION>
<OPTION VALUE="Facist">Facist</OPTION>
<OPTION VALUE="Feudalist">Feudalist</OPTION>
<OPTION VALUE="Mercantalist">Mercantalist</OPTION>
<OPTION VALUE="Socalist">Socialist</OPTION>
</SELECT><SELECT NAME="gov">
<OPTION VALUE="Democracy">Democracy</OPTION>
<OPTION VALUE="Despotism">Despotism</OPTION>
<OPTION VALUE="Dictatorship">Dictatorship</OPTION>
<OPTION VALUE="Theocracy">Theocracy</OPTION>
<OPTION VALUE="Monarchy">Monarchy</OPTION>
<OPTION VALUE="Oligarchy">Oligarchy</OPTION>
<OPTION VALUE="Republic">Republic</OPTION>
</SELECT></TD></TR>
</TABLE></TD><TD WIDTH=50%>

<table border=1 cellspacing=0 width=100%>
<TR><TD width=25% BGCOLOR="#333333"><font FACE="Arial" size="-1">Logo Path</TD><TD BGCOLOR="#666666"><font FACE="Arial" size="-1"><INPUT TYPE="textbox" size=30 name="Image" value="http://shatteredempires.shatteredempires.com/shatteredempires/images/Ingame/invis.jpg"></TD></TR>
<TR><TD width=25% BGCOLOR="#333333"><font FACE="Arial" size="-1">Homepage</TD><TD BGCOLOR="#666666"><font FACE="Arial" size="-1"><INPUT TYPE="textbox" size=30 name="Link" value="http://"></TD></TR>
<TR><TD width=25% BGCOLOR="#333333"><font FACE="Arial" size="-1">Summary</TD><TD BGCOLOR="#666666"><font FACE="Arial" size="-1"><textarea name="Summary" cols="28" rows="2" wrap="VIRTUAL">Enter brief summary here</textarea></TD></TR>
</TABLE>
</TD></TR></TABLE><FONT SIZE="-1"><CENTER><BR>
<INPUT TYPE=submit name=submit value="Proceed">
</FORM>±;
ÿÿÿÿ
