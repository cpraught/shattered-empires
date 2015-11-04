#!/usr/bin/perl
print "Content-type: text/html\n\n";

($User,$Planet,$Authcode,$SendNum,$pathnum)=split(/&/,$ENV{QUERY_STRING});
$user_information = "/home/admin/classic/se/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);

if ($pathnum == 1) {
  $path = "/home/admin/classic/se/News/"
} 
elsif ($pathnum == 2) {
  $path = "/home/admin/classic/se/Planets/$Planet/events/"
}  
elsif ($pathnum == 3) {
  $path = "/home/admin/classic/se/Planets/$Planet/users/$User/events/"
}
else {
  print qq!
    error please report
  !;
} 
  

open (DATAIN, "$path$SendNum.vnt");
$blah = <DATAIN>;
$blah = <DATAIN>;
@message = <DATAIN>;
close (DATAIN);

print qq!
<HTML>
<BODY BGCOLOR="#000000" TEXT="#FFFFFF"><CENTER>
<CENTER>
<TABLE WIDTH="90%" Border=1>
<TR>
<TD>@message<TD>
</TR>
</TABLE>
</CENTER>
</BODY>
</HTML>
!;
