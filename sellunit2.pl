#!/usr/bin/perl
print "Content-type: text/html\n\n";

&parse_form;

$Planet = $data{'planet'};
$User = $data{'user'};
$AuthCodes = $data{'authcodes'};
$user_information = "/home/admin/classic/se/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if($AuthCodes ne $authcode{$User}){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);
$ArmyPath = "/home/admin/classic/se/Planets/$Planet/users/$User/military/Pool/";
$OtherArmyPath = "/home/admin/classic/se/Planets/$Planet/users/$User/military/";
$MarketPath = "/home/admin/classic/se/Planets/$Planet/market/";
$UnitPath = "home/shatteredempires/SE/unitsdir/";
$f="unitshow.pl";


print qq!
<HTML>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<BODY BGCOLOR=#000000 text=#FFFFFF>
<FONT FACE="Arial, Helvetica, sans-serif">

<form method="post" action="http://www.bluewand.com/cgi-bin/classic/sellunit2.pl">
<Center><FONT FACE="verdana" size=-1><B>Add Unit to Market</B></FONT>
<BR><BR>
!;
chdir ("$ArmyPath") or print "CRASH";

opendir(DIR, '.');
@armies = readdir (DIR);
closedir (DIR);

foreach $k (@armies) {
	chdir ("$ArmyPath");
	$exten=substr ($k, length($k)-4, length($k));
	if (-f $k and $k ne '.' and $k ne '..' and $exten eq '.unt') {
		open (DATAIN, "$k") or print "Cannot open unit file<BR>";
		$unitdata=<DATAIN>;
		close (DATAIN);
		chop ($unitdata);
		$start = substr($k, 0, length($k)-4);
		$add = "add";
		$cost = "cost";
		$sell = "sell";
		$startcost = "$start$cost";
		$startsell = "$start$sell";
		$startadd = "$start$add";
		$unitdata -= $data{$startadd};
		if ($unitdata > -1) {
			if ($data{$startadd} > 0) {
				$num=0;
				chdir ("$UnitPath");
				$start =~ tr/_/ /;
				open (DATAIN, "$start.unt");
				@UnitInputtedData = <DATAIN>;
				close (DATAIN);
				&chopper (@UnitInputtedData);

				chdir ("$MarketPath") or print "problems";
				while(-e "$num.unt") {
					$num++;
					}
				$tempo = $data{$startadd};
				$names = substr($k, 0, length($k)-4);
#				print $data{$tempss};

				$Price = $data{$startcost};

				$Price =~ tr/ ,//d;
				if ($data{$startcost} < 1) {$data{$startcost} = 0}
				$tempo = &Space($tempo);
				$names =~ tr/_/ /;
				print qq!
<Center>$tempo $names have been placed on the international market.<BR></Center>
					!;
				$names =~ tr/_/ /;
				open (DATA, ">$num.unt") or print "Trouble opening data file for writing";
				print DATA "$names\n";
				print DATA "$data{'user'}\n";
				print DATA "$data{$startadd}\n";
				print DATA "$Price\n";
				print DATA "$data{$startsell}\n";
				print DATA "$UnitInputtedData[1]\n";
				close (DATA);
	
				chdir ("$ArmyPath");
				open (DATA, ">$names.unt");
				print DATA "$unitdata\n";

				close (DATA);
				if ($unitdata == 0) {
					unlink ("$names.unt");
				}
				chdir ("$OtherArmyPath");
				open (DATA, "$names.num");
				$unitstuffs=<DATA>;
				&chopper ($unitstuffs);
				close (DATA);

				open (DATA, ">$names.num");
				$happynumber = $unitstuffs - $data{$startadd};
				print DATA "$happynumber\n";
				close (DATA);
			}
		}
		else  {
			$start =~ tr/_/ /;
			print qq! You cannot sell more $start than you have.<BR>!;
		}
	}
}


print qq!
<BR><BR>
<TABLE border="1" cellspacing=0 WIDTH="100%">
<TR BGCOLOR="999999"> 
<TD WIDTH="20%"><FONT FACE="verdana" size=-1>Unit Name:</FONT></TD>
<TD WIDTH="20%"><FONT FACE="verdana" size=-1>Available:</FONT></TD>
<TD WIDTH="20%"><FONT FACE="verdana" size=-1>Amount to Add:</FONT></TD>
<TD WIDTH="20%"><FONT FACE="verdana" size=-1>Cost per Unit:</FONT></TD>
<TD WIDTH="20%"><FONT FACE="verdana" size=-1>Purchase Setting:</FONT></TD>
</TR>
!;

chdir ("$ArmyPath") or print "Cannot Change To Pool Directory";

opendir(DIR, '.');
@armies = readdir (DIR);
closedir (DIR);

foreach $k (@armies) {
	$exten=substr ($k, length($k)-4, length($k));
	if (-f $k and $k ne '.' and $k ne '..' and $exten eq '.unt') {
		open (DATAIN, "$k") or print "It is to hard for me";
		$unitdata=<DATAIN>;
		close (DATAIN);
		chop ($unitdata);
		$name = substr($k, 0, length($k)-4);
		$names = $name;
		$names =~ tr/_/ /;
		$add = "add";
		$cost = "cost";
		$sell = "sell";
		print qq!
<TR BGCOLOR="666666"> 
<TD WIDTH="20%"><FONT FACE="verdana" size=-1 size="-1"><A href = "$f?$name.unt" target ="Frame5" ONMOUSEOVER = "parent.window.status='$names Information';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:808080">$names</a></td></td>
<TD WIDTH="20%"><FONT FACE="verdana" size=-1 size="-1"><Center>$unitdata</FONT></TD>
<TD WIDTH="20%"><FONT FACE="verdana" size=-1 size="-1"><Center><INPUT TYPE="text" NAME="$name$add" size = "9"></FONT></TD>
<TD WIDTH="20%"><FONT FACE="verdana" size=-1 size="-1"><Center><INPUT TYPE="TEXT" NAME="$name$cost" SIZE="9"></FONT></TD>
<TD WIDTH="20%"><FONT FACE="verdana" size=-1 size="-1"><SELECT NAME="$name$sell">
<OPTION VALUE="1">Everyone</OPTION>
<OPTION VALUE="2">Neutrals &amp; Allies</OPTION>
<OPTION VALUE="3">Allies</OPTION>
</SELECT></FONT></TD>
</TR>
!;
	}
}


print qq!
</TABLE>
<BR><BR><BR>
<TABLE border="1" cellspacing=0 WIDTH="25%">
<TR BGCOLOR="666666"> 
<TD>
<INPUT TYPE="SUBMIT" NAME="sell" VALUE="Place on Market">    
</TD>
<TD>
<INPUT TYPE="RESET" NAME="submit2" VALUE="Clear Choices">    
</TD>
</TR>
<INPUT TYPE=HIDDEN NAME=user VALUE="$User">
<INPUT TYPE=HIDDEN NAME=planet VALUE="$Planet">
<INPUT TYPE=HIDDEN NAME=authcodes VALUE="$AuthCodes">
</TABLE>
</center>
</BODY>
</HTML>
!;


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

sub chopper{
	foreach $k(@_) {
		chop($k);
	}
}

sub Space {
  local($_) = @_;
  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
  return $_; 
}
