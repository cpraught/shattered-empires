#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCodes)=split(/&/,$ENV{QUERY_STRING});
$PlanetDir = $MasterPath . "/se/Planets/$Planet";
$UserDir = "$PlanetDir/users/$User";

if (-e "$UserDir/Dead.txt") {
	print "Location: http://www.bluewand.com/cgi-bin/classic/Dead.pl?$User&$Planet&$AuthCode\n\n";
	die;
}
if (-e "$UserDir/dupe.txt") {
	print "<SCRIPT>alert(\"Your nation has been locked down for security reasons.  Please contact the Bluewand Entertainment team at shattered.empires\@canada.com for details.\");history.back();</SCRIPT>";
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
if($AuthCodes ne $authcode{$User}){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "$Header";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

print qq!<HTML>
<HEAD>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<TITLE>Untitled Document</TITLE>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=iso-8859-1">
<SCRIPT LANGUAGE="JavaScript">
function display(selection) {

	var tempIndex, selectedBug;

	tempIndex=selection.selectedIndex;
	selectedBug=selection.options[tempIndex].text;

	if (selectedBug == "Graphics") {
	document.bugform.bugdescription.value = "The graphics do not look proper.  Please include resolution." }
	if (selectedBug == "Script Error") {
	document.bugform.bugdescription.value = "JavaScript error or improper calculation." }
	if (selectedBug == "Poor Formula") {
	document.bugform.bugdescription.value = "An internal calculation does not seem right.  Can apply to anything." }
	if (selectedBug == "Server Error") {
	document.bugform.bugdescription.value = "The mother of them all.  Something really doesn't work." }
	if (selectedBug == "Other") {
	document.bugform.bugdescription.value = "An error that was not covered above occured.  Detail carefully." }
}
</SCRIPT>
</HEAD>
<BODY BGCOLOR="#000000" text="#FFFFFF">
<table border=1 cellspacing=0 width=100%><TR bgcolor="$Header"><TD><font face=verdana size=-1><B><Center>Bug Report: Submit</TD></TR></table><BR><BR>
<Center>
  <Form name = "bugform" method ="post" action = "http://www.bluewand.com/cgi-bin/classic/bug.pl">
    <table border="1" width="100%" cellspacing=0>
    <tr> 
        <td width="22%" bgcolor="$Header"><font face="Arial" size=-1>Type 
          of Bug:</font></td>
        <td width="78%" bgcolor="$Content"><font face="Arial" size=-1> 
          <font face="Arial" size=-1><font face="Arial" size=-1> 
          <input type = "text" name="bugdescription" size = "80" value = "The graphics do not look proper.  Please include resolution.">
          </font></font> <BR>
          <select name="bugtype" OnChange = "display(this)">
            <option selected>Graphics 
            <option>Script Error 
            <option>Poor Formula 
            <option>Server Error 
            <option>Other 
          </select>
          </font></td>
    </tr>
    <tr> 
        <td width="22%" bgcolor="$Header"><font face="Arial" size=-1>Brief 
          Description:</font></td>
        <td width="78%" bgcolor="$Content">&nbsp;</td>
    </tr>
    <tr> 
        <td colspan=2 width="22%" bgcolor="$Content"><font face="Arial" size=-1><CENTER> 
          <textarea name="description2" cols="50" rows="10" wrap=virtual></textarea>
          </font> </td>
    </tr>
  </table>
    <p> 
      <input type="submit" name="submit" value="Report Bug">
    </p>
<INPUT TYPE="HIDDEN" value="$User" name="User">
<INPUT TYPE="HIDDEN" value="$Planet" name="Planet">
<INPUT TYPE="HIDDEN" value="$AuthCodes" name="authcode">
  </form>
  </CENTER>
</BODY>
</HTML>
!;
