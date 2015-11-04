#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$Mode)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authcode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";
$UserPath = $MasterPath . "/Planets/$Planet/users/$User";

&parse_form;

open (IN, "$UserPath/userinfo.txt");
@Inf = <IN>;
close (IN);
&chopper (@Inf);
&Display2;
if ($Mode == 1) {
	if ($data{'agri2'} < 0 or $data{'comm2'} < 0 or $data{'indu2'} < 0 or $data{'resi2'} < 0) {
		$SF = qq!<font face=verdana size=-1>!;
		print qqﬁ
<BODY BGCOLOR="#000000" text="#FFFFFF">
<table width=100% border=1 cellspacing=0 bgcolor="$Header"><TD><Font face=verdana size=-1><B><Center>Colonization Setup</table><BR>
<BR><BR><BR><Center>$SF Zones cannot be negative.
		ﬁ;
		die;
	}
	if ($data{'agri2'} + $data{'comm2'} + $data{'indu2'} + $data{'resi2'} == 0) {
		$SF = qq!<font face=verdana size=-1>!;
		print qqﬁ
<BODY BGCOLOR="#000000" text="#FFFFFF">
<table width=100% border=1 cellspacing=0 bgcolor="$Header"><TD><Font face=verdana size=-1><B><Center>Colonization Setup</table><BR>
<BR><BR><BR><Center>$SF In order to form a viable colony, you must create it with buildings.  Specify the buildings to be built in the "Initial Buildings" section of the Manage Cities page.
		ﬁ;
		die;
	}

	$a = $data{'agri2'} +$data{'comm2'} +$data{'indu2'} +$data{'resi2'}; 
	if ($a < 0 or $a > 10) {
		$SF = qq!<font face=verdana size=-1>!;
		print qqﬁ
<BODY BGCOLOR="#000000" text="#FFFFFF">
<table width=100% border=1 cellspacing=0 bgcolor="#Header"><TD><Font face=verdana size=-1><B><Center>Colonization Setup</table><BR>
<BR><BR><BR><Center>$SF Your colonies cannot support more than 10 zones.
		ﬁ;
		die;
	}
	$TotPer = ($data{'agri'} + $data{'comm'} + $data{'indu'} + $data{'resi'});
	if (($TotPer < 0 or $TotPer > 100)  & ($SpecMod != 2)) {
		$SF = qq!<font face=verdana size=-1>!;
		print qqﬁ
<BODY BGCOLOR="#000000" text="#FFFFFF">
<table width=100% border=1 cellspacing=0 bgcolor="$Header"><TD><Font face=verdana size=-1><B><Center>Colonization Setup</table><BR>
<BR><BR><BR><Center>$SF You cannot allocate more than 100% to your zoning goals.
		ﬁ;
		die;
	}

	open (OUT, ">$UserPath/Colony.txt") or print "Cant open to save";


	print OUT "$data{'agri'}\n";
	print OUT "$data{'comm'}\n";
	print OUT "$data{'indu'}\n";
	print OUT "$data{'resi'}\n";
	print OUT "$data{'agri2'}\n";
	print OUT "$data{'comm2'}\n";
	print OUT "$data{'indu2'}\n";
	print OUT "$data{'resi2'}\n";
	$data{'city'} =~ tr/ /_/;
	print OUT "$data{'city'}\n";
	close (OUT);
}

open (IN, "$UserPath/Colony.txt");
@Colony = <IN>;
close (IN);
&chopper (@Colony);

open (IN, "$UserPath/City.txt");
@City = <IN>;
close (IN);
&chopper (@City);

foreach $Line (@City) {
	($Name,$junk) = split(/\|/,$Line);
	$Name2 = $Name;
	$Name2 =~ tr/ /_/;
	if ($Name2 eq @Colony[8]) {$a = "Selected"}
	$Cities = $Cities.qqﬁ<option name="$Name2" $a>$Name</option>ﬁ;
}

$StyleFont = qq!<font face=verdana size=-1>!;

print qqﬁ
<BODY BGCOLOR="#000000" text="#FFFFFF">
<form method=POST action="http://www.bluewand.com/cgi-bin/classic/Colonization.pl?$User&$Planet&$AuthCode&1">
<table width=100% border=1 cellspacing=0 bgcolor="$Header"><TD><Font face=verdana size=-1><B><Center>Colonization Setup</table><BR>

<center>
<table width=60% border=1 cellspacing=0>
<TR><TD bgcolor="$Header">$StyleFont<Center>Colonist City</TD></TR>
<TR><TD bgcolor="$Content">$StyleFont<Center><select name=city>$Cities</select></TD></TR>
</table><BR><BR>
</center>

<table width=100% border=0 cellspacing=0>
<TR><TD width=50%><table width=100% border=1 cellspacing=0 bgcolor="$Content">
<TR><TD colspan=2 bgcolor="$Header">$StyleFont $ab</TD></TR>
<TR><TD bgcolor="$Header" width=50%>$StyleFont $ac</TD><TD>$StyleFont<center><input type=text value="@Colony[0]" name=agri size=4>$c</TD></TR>
<TR><TD bgcolor="$Header">$StyleFont $ad</TD> <TD>$StyleFont<center><input type=text value="@Colony[1]" name=comm size=4>$c</TD></TR>
<TR><TD bgcolor="$Header">$StyleFont $ae</TD> <TD>$StyleFont<center><input type=text value="@Colony[2]" name=indu size=4>$c</TD></TR>
<TR><TD bgcolor="$Header">$StyleFont $af</TD><TD>$StyleFont<center><input type=text value="@Colony[3]" name=resi size=4>$c</TD></TR>
</table></TD>

<TD><table width=100% border=1 cellspacing=0 bgcolor="$Content">
<TR><TD colspan=2 bgcolor="$Header">$StyleFont Initial Buildings (max 10)</TD></TR>
<TR><TD bgcolor="$Header" width=50%>$StyleFont Agriculture</TD><TD><Center>$StyleFont <input type=text name=agri2 size=5 value="@Colony[4]"></TD></TR>
<TR><TD bgcolor="$Header">$StyleFont Commercial</TD><TD><Center>$StyleFont <input type=text name=comm2 size=5 value="@Colony[5]"></TD></TR>
<TR><TD bgcolor="$Header">$StyleFont Industrial</TD><TD><Center>$StyleFont <input type=text name=indu2 size=5 value="@Colony[6]"></TD></TR>
<TR><TD bgcolor="$Header">$StyleFont Residential</TD><TD><Center>$StyleFont <input type=text name=resi2 size=5 value="@Colony[7]"></TD></TR>
</table>
</TD></table>
<BR><Center>$StyleFont<font size=-2><input type=submit name=submit value="Submit"></font>
</form>
ﬁ;


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
         
      

      $data{$name} = abs($value);
      }
}


#sub chopper{
#	foreach $k(@_){
#		chop($k);
#	}
#}

sub Display2 {
if (@Inf[4] eq "DI" or @Inf[4] eq "TH" or @Inf[4] eq "MO") {
	$ab = "Colony Goals";
	$ac = "Agricultural Goal";
	$ad = "Commercial Goal";
	$ae = "Industrial Goal";
	$af = "Residential Goal";
	$c = "";
	$SpecMod = 2;
}

if (@Inf[4] eq "DE" or @Inf[4] eq "RE" or @Inf[4] eq "FA") {
	$ab = "Colony Percentages";
	$ac = "Agricultural Percentage";
	$ad = "Commercial Percentage";
	$ae = "Industrial Percentage";
	$af = "Residential Percentage";
	$c = "%";
	$TotPer = 100;
	$SpecMod = 1;
}

}