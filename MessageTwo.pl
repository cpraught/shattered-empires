#!usr/bin/perl
print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$Type) = split(/&/,$ENV{QUERY_STRING});
$user_information = "/home/admin/classic/se/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}

&parse_form;

$RecieveDir = "/home/admin/classic/se/Planets/$data{'Planet'}/users/$data{'User'}/messages";

if ($Type == 0) {
$NUser = $User;
$NUser =~ tr/_/ /;
print qqﬁ
<BODY BGCOLOR="000000" text=white>
<table width=100% border=1 cellspacing=0 BGCOLOR=666666>
<TR><TD BGCOLOR=#999999><font face=verdana size=-1>From</TD><TD><font face=arial size=-1>$NUser</TD></TR>
</table>ﬁ;


} else {
	open (DATAOUT, ">$RecieveDir/$Time.new");
	print DATAOUT "$User\n";
	print DATAOUT "$Planet\n";
	print DATAOUT "$data{'Subject'}\n";
	print DATAOUT "$data{'Message'}\n";
	close (DATAOUT);
}


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

