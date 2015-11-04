#!/usr/bin/perl
($User,$Planet,$AuthCode)=split(/&/,$ENV{QUERY_STRING});
$user_information = "/home/admin/classic/se/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);

print "Content-type: text/html\n\n";
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
    <frame src="http://www.shatteredempires.com/SE/Gametop2.html" name="gameviewb" scrolling="NO" noresize frameborder="NO" marginwidth="0" marginheight="0">
    <frame src="http://www.bluewand.com/cgi-bin/classic/Dead.pl?$data{'handle'}&$planet&$authcode{$data{'handle'}}" name="Frame5">
  </frameset>
</frameset>
<noframes>
<body bgcolor="#000000">
</body></noframes>
</html>




<noframes><body bgcolor="#FFFFFF">
</body></noframes>
</html>
!;
