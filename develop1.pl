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

$TechPath = $MasterPath . "/se/Planets/$Planet/users/$User/research/";
$NormalPath =$MasterPath . "/se/Planets/$Planet/users/$User/";

open (IN, "$TechPath/TechData.tk");
flock (IN, 1);
@Tech  = <IN>;
close (IN);
&chopper (@Tech);

foreach $Item (@Tech) {
	@TechData = split (/\|/, $Item);
	if (@TechData[2] >= @TechData[3]) {$Storage{@TechData[1]} = 1}
}


chdir ("$NormalPath");
if (-e "death.txt") {
	print "<SCRIPT>alert(\"Your country has been destroyed.  If you wish to continue to play, you must restart.\");history.back();</SCRIPT>";
	die;
}
open (DATAIN, "money.txt");
$money = <DATAIN>;
close (DATAIN);
chop ($money);

open (DATAIN, "turns.txt");
$turns = <DATAIN>;
close (DATAIN);
chop ($turns);

$money = &Space($money);

print qq!
<BODY BGCOLOR="#000000" TEXT="#FFFFFF">
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<P ALIGN="CENTER"><FONT FACE="Arial, Helvetica, sans-serif"><B>Develop Unit: Phase One</B></FONT></P>
<TABLE BORDER="1" WIDTH="100%" BORDER=1 CELLSPACING=0>
  <TR>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Current Funds :</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">\$$money</TD>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Turns Remaining:</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$turns</TD>
  </TR>
</TABLE>
<form METHOD="POST" action="http://www.bluewand.com/cgi-bin/classic/NewDevelop2.pl?$User&$Planet&$Authcodes">
<TABLE BORDER="1" WIDTH="100%" BORDER=1 CELLSPACING=0>
  <TR> 
    <TD WIDTH="51%" BGCOLOR="$Header"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Unit Name:</FONT></TD>
    <TD WIDTH="49%" BGCOLOR="$Content"> 
      <DIV ALIGN="CENTER"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">
        <INPUT TYPE="TEXT" NAME="name" SIZE="22" max="22">
        </FONT> 
      </DIV>
    </TD>
  </TR>
  <TR> 
    <TD WIDTH="51%" BGCOLOR="$Header"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Unit Type:</FONT></TD>
    <TD WIDTH="49%" BGCOLOR="$Content"> 
      <DIV ALIGN="CENTER"><FONT FACE="Arial, Helvetica, sans-serif" size="-1"><SELECT NAME="type">!;
chdir ("$TechPath");

print "<OPTION VALUE = '1GIn'>Infantry";
if ($Storage{"1st_Generation_Armour"}) {print "<OPTION VALUE = '1GAr'>First Generation Tank"}
if ($Storage{"1st_Generation_Vessel"}) {print "<OPTION VALUE = '1GVe'>First Generation Vessel"}

if ($Storage{"2nd_Generation_Armour"}) {print "<OPTION VALUE = '2GAr'>Second Generation Tank"}
if ($Storage{"2nd_Generation_Infantry"}) {print "<OPTION VALUE = '2GIn'>Second Generation Infantry"}
if ($Storage{"2nd_Generation_Vessel"}) {print "<OPTION VALUE = '2GVe'>Second Generation Vessel"}

if ($Storage{"Short_Range_Ballistic_Missile"}) {print "<OPTION VALUE = 'SRBM'>Short Range Ballistic Missile"}
if ($Storage{"Medium_Range_Ballistic_Missile"}) {print "<OPTION VALUE = 'MRBM'>Medium Range Ballistic Missile"}
if ($Storage{"Long_Range_Ballistic_Missile"}) {print "<OPTION VALUE = 'LRBM'>Long Range Ballistic Missile"}
if ($Storage{"Inter-Continental_Ballistic_Missile"}) {print "<OPTION VALUE = 'ICBM'>Inter-Continental Ballistic Missile"}



print qq!
        </SELECT>
        </FONT> 
      </DIV>
    </TD>
  </TR>
</TABLE>
<BR><BR><CENTER>
<TABLE BORDER="1" WIDTH="40%" BORDER=1 CELLSPACING=0>
<TR BGCOLOR="#666666"> 
<TD><center><INPUT TYPE="SUBMIT" NAME="submit3" VALUE=" Proceed "></center></TD>
<TD><center><INPUT TYPE="RESET" NAME="submit4" VALUE="  Cancel  "></center></TD>
</TR>
</TABLE></CENTER>
</form>
</BODY>
</HTML>
!;


#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}
#
#sub chopper {
#foreach $k (@_) {
#	chop($k);
#	}
#}

