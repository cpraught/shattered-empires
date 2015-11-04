#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCodes,$Mode)=split(/&/,$ENV{QUERY_STRING});
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
if($AuthCodes ne $authcode{$User} || $AuthCodes eq ""){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";

$PlayerArmyPath = $MasterPath . "/se/Planets/$Planet/users/$User/military";
$PlayerMainPath = $MasterPath . "/se/Planets/$Planet/users/$User";
$UserPath = $MasterPath . "/se/Planets/$Planet/users";
$MarketPath = $MasterPath . "/se/Planets/$Planet/market";
$AlliancePath= $MasterPath . "/se/Planets/$Planet/alliance";
$UnitPath = $MasterPath . "/unitsdir";
$SF = qq!<font face=verdana size=-1>!;

if ($Mode == 1) {
	&parse_form;
	opendir (DIR, "$MarketPath");
	@Selling = readdir (DIR);
	closedir (DIR);

	foreach $Item (@Selling) {
		unless ($Item eq '.' or $Item eq '..') {
			if ($data{$Item} > 0) {
				open (IN, "$MarketPath/$Item");
				@Info = <IN>;
				close (IN);
				&chopper (@Info);

				if (@Info[2] >= $data{$Item}) {

					$Cost = $data{$Item} * @Info[3];
					open (IN, "$PlayerMainPath/money.txt");
					$Funds = <IN>;
					chop ($Funds);
					close (IN);

					if (($Funds - $Cost) >= 0) {
						@Info[2] -= $data{$Item};
						$Funds -= $Cost;
						open (OUT, ">$PlayerMainPath/money.txt");
						print OUT "$Funds\n";
						close (OUT);

						open (IN, "$UserPath/@Info[1]/money.txt");
						$NewMoney = <IN>;
						chop ($NewMoney);
						close (IN);

						$NewMoney += abs(int($Cost * 0.80));
						open (OUT, ">$UserPath/@Info[1]/money.txt");
						print OUT "$NewMoney\n";
						close (OUT);

						if (@Info[2] > 0) {
							open (OUT, ">$MarketPath/$Item");
							print OUT "@Info[0]\n";
							print OUT "@Info[1]\n";
							print OUT "@Info[2]\n";
							print OUT "@Info[3]\n";
							print OUT "@Info[4]\n";
							close (OUT);
						} else {unlink "$MarketPath/$Item"}

						@Info[0] =~ tr/_/ /;
						if (-e "$PlayerArmyPath/@Info[0].num") {
							open (IN, "$PlayerArmyPath/@Info[0].num");
							$NumberUnit = <IN>;
							$Blank = <IN>;
							close (IN);
							chop ($NumberUnit);
						} else {$Blank="0\n"}
						
						#Increase Total Number of Units
						open (OUT, ">$PlayerArmyPath/@Info[0].num");
						$NewVal = $NumberUnit + $data{$Item};
						print OUT "$NewVal\n";
						print OUT "$Blank";
						close (OUT);


						#Increase Number of Units in Pool
						if (-e "$PlayerArmyPath/Pool/@Info[0].unt") {
							open (IN, "$PlayerArmyPath/Pool/@Info[0].unt");
							$NumberUnit = <IN>;
							close (IN);
							chop ($NumberUnit);
						}						
						open (OUT, ">$PlayerArmyPath/Pool/@Info[0].unt");
						$NewVal = $NumberUnit + $data{$Item};
						print OUT "$NewVal\n";
						close (OUT);

						#ModifyNetworth
						&NewNetworth;


						$Cost = &Space($Cost);
						$UserNice = $User;
						$UserNice =~ tr/_/ /;

						($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
						$Mon++;
						open (OUT, ">$UserPath/@Info[1]/events/$Year$Mon$Mday$Hour$Min$Sec.vnt");
						print OUT "Market Purchase\n";
						print OUT "<CENTER>$Hour:$Min:$Sec   $Mday\/$Mon\/$Year\n";
						print OUT "$UserNice has purchased $data{$Item} @Info[0] at a cost of \$$Cost.  A 20% transaction fee has been levied on this purchase.\n";
						close (OUT);
	
						$WarnMsg = $WarnMsg."$data{$Item} @Info[0] have been purchased for \$$Cost.<BR>";
					} else {
						@Info[0] =~ tr/_/ /;
						$WarnMsg = $WarnMsg."You cannot afford to purchase $data{$Item} @Info[0].<BR>";
					}
				} else {
					@Info[0] =~ tr/_/ /;
					@Info[1] =~ tr/_/ /;
					$WarnMsg = $WarnMsg."There are not enough $Info[0] being sold by $Info[1] to complete the order.<BR>";
				}
			}
		}
	}
}

if ($WarnMsg ne "") {$Bump = "<BR>"}

opendir (DIR, "$MarketPath");
@Selling = readdir (DIR);
closedir (DIR);


open (DATAIN, "$PlayerMainPath/money.txt");
$money = <DATAIN>;
close (DATAIN);
chop ($money);

open (DATAIN, "$PlayerMainPath/turns.txt");
$turns = <DATAIN>;
close (DATAIN);
chop ($turns);

$money = &Space($money);

print qqﬁ
<body bgcolor="#000000" text="#FFFFFF">$SF
<table width=100% border=1 cellspacing=0 bgcolor="$Header"><TR><TD><B>$SF<Center>International Market</TD></TR></table><BR><center>
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT><BR>
<TABLE BORDER="1" WIDTH="100%" BORDER=1 CELLSPACING=0>
  <TR>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Current Funds :</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">\$$money</TD>
    <TD BGCOLOR="$Header" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">Turns Remaining:</FONT></TD>
    <TD BGCOLOR="$Content" WIDTH="25%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$turns</TD>
  </TR>
</TABLE>


$WarnMsg$Bump
<form method=POST action="http://www.bluewand.com/cgi-bin/classic/NewMarket.pl?$User&$Planet&$AuthCodes&1">
<Table width=100% border=1 cellspacing=0 bgcolor="$Content">
<TR bgcolor="$Header"><TD>$SF Unit Name</TD><TD>$SF Nation</TD><TD>$SF Class</TD><TD>$SF Cost</TD><TD>$SF Available</TD><TD>$SF Owned</TD><TD>$SF Purchase</TD></TR>
ﬁ;

foreach $Item (@Selling) {
	unless ($Item eq "." or $Item eq "..") {
		$Clear = 0;
		open (IN, "$MarketPath/$Item");
		@Info = <IN>;
		close (IN);
		&chopper (@Info);

		if (@Info[4] == 1) {
			if (-e "$UserPath/@Info[1]/alliance.txt") {
				open (IN, "$UserPath/@Info[1]/alliance.txt");
				$Alliance = <IN>;
				close (IN);
			} else {
			}

			if (-e "$PlayerMainPath/alliance.txt") {
				open (IN, "$PlayerMainPath/alliance.txt");
				$Alliance2 = <IN>;
				close (IN);
			}	
			
			if ($Alliance ne $Alliance2) {
				$Clear = 1;
			}
		}

		@Info[0] =~ tr/_/ /;
		if (-e "$PlayerArmyPath/@Info[0].num") {
			open (IN, "$PlayerArmyPath/@Info[0].num");
			$Number = <IN>;
			chop ($Number);
			close (IN);
		} else {
			$Number = 0;
		}

		open (IN, "$UnitPath/@Info[0].unt");
		@UnitInfo = <IN>;
		close (IN);
		&chopper (@UnitInfo);



		@Info[1] =~ tr/_/ /;
		$Infob = @Info[0];
		$Infob =~ tr/ /_/;
		@Info[3] = &Space(@Info[3]);
		@Info[2] = &Space(@Info[2]);
$ShowUnit = qqﬁ<A href = "unitshow.pl?$Infob.unt" target ="Frame5" ONMOUSEOVER = "parent.window.status='@Info[0] Information';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:black">@Info[0]</a>ﬁ;
		if ($Clear == 0) {
			print qqﬁ<TR><TD>$SF $ShowUnit</TD><TD>$SF @Info[1]</TD><TD>$SF @UnitInfo[0]</TD><TD>$SF \$@Info[3]</TD><TD>$SF @Info[2]</TD><TD>$SF @{[&Space($Number)]}</TD><TD>$SF<input type=text value=0 name=$Item size=9></TD></TR>
			ﬁ;
		}
	}
}
print qq!</table><BR><center><input type=submit value="Make Purchase" name=buy"></form>!;




#sub chopper {
#	foreach $k (@_) {
#		chop($k);
#	}
#}
#
#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}


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


sub NewNetworth
{
	#Get Old Networth
	open (IN, "$UserDir/country.txt");
	flock (IN, 1);
	my @CountryDataIn = <IN>;
	close (IN);
	&chopper (@CountryDataIn);

	#Get Military Value
	open (IN, "$UnitPath/@Info[0].unt");
	flock (IN, 1);
	my @UnitStats = <IN>;
	close (IN);
	&chopper (@UnitStats);

	@CountryDataIn[8] += int(abs($data{$Item} * (@UnitStats[3]/100)));

	open (OUT, ">$UserDir/country.txt");
	flock (OUT, 2);
	foreach $Instance (@CountryDataIn) {
		print OUT "$Instance\n";
	}
	close (OUT);

	open (IN, "$UserPath/@Info[1]/country.txt");
	flock (IN, 1);
	my @OtherCountry = <IN>;
	close (IN);

	&chopper (@OtherCountry);

	@OtherCountry[10] -= int(abs($data{$Item} * (@UnitStats[3]/100)));
	@OtherCountry[11] -= int(abs(@UnitInfo[3] * $data{$Item}));

	open (OUT, ">$UserPath/@Info[1]/country.txt");
	flock (OUT, 2);
	foreach $WriteItem (@OtherCountry) {
		print OUT "$WriteItem\n";
	}
	close (OUT);
}
