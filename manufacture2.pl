#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

&parse_form;

$User = $data{'user'};
$Planet = $data{'planet'};
$AuthCodes = $data{'authcodes'};
$user_information = $MasterPath . "/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if($AuthCodes ne $authcode{$User}){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

$UserUnitPath=$MasterPath . "/se/Planets/$Planet/users/$User/units/";
$UnitPath=$MasterPath . "/unitsdir/";
$cancel = "cancel";
$amount = "amount";
$percent = "percent";
$f="unitshow.pl";

chdir ("$UserUnitPath");

opendir (DIR, '.');
@units = readdir (DIR);
closedir (DIR);
print qq!
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<BODY BGCOLOR="#000000" TEXT="#FFFFFF"><FONT FACE="Arial" size=-1>
<table width=100% border=1 cellspacing=0 bgcolor=$Header><TR><TD><FONT FACE="Arial" size=-1><center><B>Manufacturing</FONT></TD></TR></table><BR><center>
!;
foreach $manufacture (@units) {
	unless ($manufacture eq '.' or $manufacture  eq '..') {
		chdir ("$UserUnitPath");
		$current = 0;
		$exten = substr ($manufacture, length($manufacture)-4,length($manufacture));
		$name = substr ($manufacture, 0,length($manufacture)-4);
		$name =~ tr/ /_/;
		$amount = $name."amount";
		$cancel = $name."cancel";	
		$percent="percent";
		$info = "$name$percent";
		if ($data{$amount} < 0) {
			print "You cannot designate a negative percentage for manufacture.<BR>";
			die;
		} else {
			$data{$amount} = abs($data{$amount});
			$data{$percent} = abs($data{$percent});
			$TotalPercent += $data{$info};
			if ($TotalPercent > 100) {
				&percentwarn;
			}
			if (-e "$name.con" or $data{$amount} >= 0) {
				$names = $name;
				$names =~ tr/_/ /;
				open (DATAOUT, ">$names.con");
				print DATAOUT "$data{$amount}\n";
				print DATAOUT "$data{$info}\n";
				close (DATAOUT);
				$NName = $name;
				$NName =~ tr/_/ /;
				print "$NName set<BR>";
			}
		}
		if ($data{$cancel} eq 'Yes') {
			chdir ("$UserUnitPath");
			$names = $name;
			$names =~ tr/_/ /;
			unlink ("$names.con");
		}
	}
}

&display;


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


#sub chopper {
#foreach $k (@_) {
#	chop($k);
#	}
#}

sub percentwarn {
	print "<B>The total industrial production exceeds 100 percent.  Please re-enter values.</B>";
	&display;
	die;
}

sub display {

	print qq!
<form method ="POST" action = "http://www.bluewand.com/cgi-bin/classic/manufacture2.pl">
<TABLE BORDER="1" cellspacing=0 WIDTH="100%">
<TR BGCOLOR="$Header"> 
<TD WIDTH="24%"><FONT FACE="Arial" size=-1>Unit Name:</FONT></TD>
<TD WIDTH="19%"><FONT FACE="Arial" size=-1>Cost to Produce:</FONT></TD>
<TD WIDTH="20%"><FONT FACE="Arial" size=-1>Production Number:</FONT></TD>
<TD WIDTH="20%"><FONT FACE="Arial" size=-1>Percent of Industry:</FONT></TD>
<TD WIDTH="17%"><FONT FACE="Arial" size=-1>Destroy Plans:</FONT></TD>
</TR>
	!;
foreach $manufacture (@units) {
	chdir ("$UserUnitPath");
	$current = 0;
	$current2 = 0;
	$exten = substr ($manufacture, length($manufacture)-4,length($manufacture));
	$name = substr ($manufacture, 0,length($manufacture)-4);
	if ($exten eq '.con') {
		open (DATAIN, $manufacture);
		@construct = <DATAIN>;
		close (DATAIN);
		&chopper (@construct);
		$current = @construct[0];
		$current2= @construct[1];
		chdir ("$UnitPath");
		open (DATAIN, "$name.unt");
		@unitinfo = <DATAIN>;
		close (DATAIN);
		$cost = @unitinfo[2];
		$cost = &Space($cost);
		&chopper (@unitinfo);
		$amount = "amount";
		$cancel = "cancel";
		$percent = "$percent";
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
<INPUT TYPE="TEXT" NAME="$name$percent" SIZE="2" MAXLENGTH="3" value = "$current2">
%</FONT> 
</DIV>
</TD>
<TD WIDTH="17%"> 
<DIV ALIGN="CENTER">
<FONT FACE="Arial" size=-1 size="-1"> 
<INPUT TYPE="radio" NAME="$name$cancel" VALUE="Yes">
Yes 
<INPUT TYPE="radio" NAME="$name$cancel" VALUE="No" CHECKED>
No</FONT> 
</DIV>
</TD>
</TR>
		!;
	}
}



	print qq!
</TABLE>
<BR><BR><center>
<TABLE BORDER="1" cellspacing=0  WIDTH="40%">
<TR BGCOLOR="$Content"> 
<TD><FONT FACE="Arial" size=-1><center><INPUT TYPE="SUBMIT" NAME="submit" VALUE="Begin Manufacturing"></TD>
<INPUT TYPE=HIDDEN NAME=user VALUE="$User">
<INPUT TYPE=HIDDEN NAME=planet VALUE="$Planet">
<INPUT TYPE=HIDDEN NAME=authcodes VALUE="$AuthCodes">
</TR>
</TABLE>
</form>
</DIV>
</BODY>
</HTML>
	!;
}

#sub Space {
#  local($WinType) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $WinType; 
#}
