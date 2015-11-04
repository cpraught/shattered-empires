#!/usr/bin/perl
print "Content-type: text/html\n\n";
srand(time);

($User,$Planet,$AuthCode,$Mode)=split(/&/,$ENV{QUERY_STRING});
$user_information = "/home/admin/classic/se/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);

$SF = qqﬁ<font face=verdana size=-1>ﬁ;

&parse_form;


if ($Mode == 0) {
	print qqﬁ
<body bgcolor=000000 text=white>
<Table width=100% border=1 cellspacing=0><TR><TD bgcolor="#999999">$SF<center><B>Unit Development:  Phase One</TD></TR></Table><BR><BR>
<form action="http://www.bluewand.com/cgi-bin/classic/UnitDevelop1.pl?$User&$Planet&$AuthCode&1" method=POST><center>
<Table width=60% border=1 cellspacing=0 bgcolor="#666666">
<TR><TD colspan=2 bgcolor="#999999">$SF<center>Unit Name</TD></TR>
<TR><TD colspan=2>$SF<Center><input type=text name=UnitName size=20></TD></TR>
<TR><TD width=50% bgcolor="#999999">$SF Unit Type</Td><TD>$SF<Center><select name=UnitType><option value=None>None Selected</option></select></TD></TR>
</table><BR><BR>$SF<input type=submit value="Proceed" name=submit>
</form>
	ﬁ;
}

if ($Mode == 1) {
	&TemplateSelection;
	print qqﬁ
<body bgcolor=000000 text=white>
<Table width=100% border=1 cellspacing=0><TR><TD bgcolor="#999999">$SF<center><B>Unit Development:  Phase One</TD></TR></Table><BR><BR>
<form action="http://www.bluewand.com/cgi-bin/classic/UnitDevelop1.pl?$User&$Planet&$AuthCode&2" method=POST><center>
<table width=100% border=1 cellspacing=0  bgcolor="#666666">
<TR><TD bgcolor="#999999">$SF Unit Name</TD><TD>$SF $data{'UnitName'}</TD><TD bgcolor="#1b1b1b">$SF Unit Type</TD><TD>$SF $data{'UnitType'}</TD></TR>
<TR><TD bgcolor="#999999">$SF Crew</TD><TD>$SF $Crew</TD><TD bgcolor="#1b1b1b">$SF Initial Cost</TD><TD>$SF $InitCost</TD></TR>
</table>


</form>
	ﬁ;
}

sub TemplateSelection {
	$TemplatePath = "/home/admin/classic/template";


}


sub chopper{
	foreach $k(@_){
		chop($k);
	}
}

sub Space {
  local($_) = @_;
  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
  return $_; 
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
