#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$Authcodes)=split(/&/,$ENV{QUERY_STRING});
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
dbmopen(%authcode, "$user_information/accesscode", 0777);
if($Authcodes ne $authcode{$User} || $Authcodes eq ""){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

$UserUnitPath=$MasterPath . "/se/Planets/$Planet/users/$User/units/";
$UnitPath=$MasterPath . "/unitsdir/";
chdir ("$UserUnitPath");

opendir (DIR, '.');
@units = readdir (DIR);
closedir (DIR);
$f="unitshow.pl";

print qq!
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<BODY BGCOLOR="#000000" TEXT="#FFFFFF">
<table width=100% border=1 cellspacing=0 bgcolor=$Header><TR><TD><FONT FACE="Arial" size=-1><center><B>Manufacturing</FONT></TD></TR></table><BR><BR>
<form method ="POST" action = "http://www.bluewand.com/cgi-bin/classic/manufacture2.pl">
  <TABLE BORDER="1" cellspacing=0 WIDTH="100%">
    <TR BGCOLOR="$Header"> 
      <TD WIDTH="24%"><FONT FACE="Arial" size=-1>Unit Name:</FONT></TD>
      <TD WIDTH="19%"><FONT FACE="Arial" size=-1>Cost to Produce:</FONT></TD>
      <TD WIDTH="20%"><FONT FACE="Arial" size=-1>Number:</FONT></TD>
      <TD WIDTH="20%"><FONT FACE="Arial" size=-1>Industry Percent:</FONT></TD>
      <TD WIDTH="17%"><FONT FACE="Arial" size=-1>Destroy Plans:</FONT></TD>
    </TR>
!;

foreach $manufacture (@units) {
	chdir ("$UserUnitPath");
	$current = 0;
	$current2=0;
	$exten = substr ($manufacture, length($manufacture)-4,length($manufacture));
	$name = substr ($manufacture, 0,length($manufacture)-4);
	if ($exten eq '.blp' or $exten eq '.con') {
		if ($exten eq '.con') {
			open (DATAIN, $manufacture);
			@construct = <DATAIN>;
			close (DATAIN);
			&chopper (@construct);
			$current = @construct[0];
			$current2 = @construct[1];
		}
		chdir ("$UnitPath");
		open (DATAIN, "$name.unt");
		@unitinfo = <DATAIN>;
		close (DATAIN);
		&chopper (@unitinfo);
		$cost = &Space(@unitinfo[2]);

		$amount = "amount";
		$cancel = "cancel";
		$percent = "percent";
		$names = $name;
		$name =~ tr/ /_/;
		print qq!
<TR BGCOLOR="$Content"> 
<TD WIDTH="24%"><FONT FACE="Arial" size=-1 size="-1"><A href = "$f?$name.unt" target ="Frame5" ONMOUSEOVER = "parent.window.status='$names Information';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:black">$names</a></TD>
<TD WIDTH="19%"><FONT FACE="Arial" size=-1 size="-1">\$$cost</TD>
<TD WIDTH="20%"> 
<DIV ALIGN="CENTER"><FONT FACE="Arial" size=-1 size="-1">
<INPUT TYPE="TEXT" NAME="$name$amount" SIZE="9" value ="$current">
</DIV>
</TD>
<TD WIDTH="20%"> 
<DIV ALIGN="CENTER"><FONT FACE="Arial" size=-1 size="-1">
<INPUT TYPE="TEXT" NAME="$name$percent" SIZE="2" MAXLENGTH="3" value="$current2">
%</FONT> 
</DIV>
</TD>
<TD WIDTH="17%"> 
<DIV ALIGN="CENTER">
<FONT FACE="Arial" size=-1 size="-1"> 
<INPUT TYPE="radio" NAME="$name$cancel" VALUE="Yes">Yes <INPUT TYPE="radio" NAME="$name$cancel" VALUE="No" CHECKED>No</FONT> 
</DIV>
</TD>
</TR>
		!;
	}
}



print qq!
</TABLE><center>
<BR><BR>
<TABLE BORDER="1" cellspacing=0 WIDTH="40%">
<TR BGCOLOR="$Content">
<TD><FONT FACE="Arial" size=-1><center><INPUT TYPE="SUBMIT" NAME="submit" VALUE="Begin Manufacturing"></TD>
<INPUT TYPE=HIDDEN NAME=user VALUE="$User">
<INPUT TYPE=HIDDEN NAME=planet VALUE="$Planet">
<INPUT TYPE=HIDDEN NAME=authcodes VALUE="$Authcodes">
</TR>
</TABLE>
</form>
</DIV>
</BODY>
</HTML>
!;

#sub chopper {
#foreach $k (@_) {
#	chop($k);
#	}
#}
#
#sub Space {
#  local($WinType) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $WinType; 
#}
