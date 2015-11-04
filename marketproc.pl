#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

&parse_form;
$User = $data{'user'};
$Planet = $data{'planet'};
$AuthCodes = $data{'authcodes'};
$user_information = "/home/admin/classic/se/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if($AuthCodes ne $authcode{$User}){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);


$UserPath = "/home/admin/classic/se/Planets/$Planet/users/$User/";
$MarketPath ="/home/admin/classic/se/Planets/$Planet/market/";
$ArmyPath = "/home/admin/classic/se/Planets/$Planet/users/$User/military/";
$AlliancePath= "/home/admin/classic/se/Planets/$Planet/alliance/";
$PlayerPath = "/home/admin/classic/se/Planets/$Planet/users/";

$Buyer = $data{'user'};
$Buyer =~ tr/_/ /;
chdir ("$UserPath");
open (DATAIN, "money.txt");
@money=<DATAIN>;
close (DATAIN);
&chopper (@money);
open (DATAIN, "turns.txt");
$turns = <DATAIN>;
close (DATAIN);
&chopper ($turnsmoney);



#Display Table
print qq!
<HTML>
<BODY BGCOLOR=#000000 text=#FFFFFF>
!;
chdir ("$ArmyPath");
opendir(DIR, '.');
@armydir = readdir(DIR);
closedir (DIR);


for ($i=0;$i <= $data{'max'}; $i++) {
	chdir ("$MarketPath");
	if ($data{$i} > 0) {
		open (UNITINFO, "$i.unt") or print "Cannot open market file $i.  Please report.";
		@purchase=<UNITINFO>;
		close (UNITINFO);
		&chopper (@purchase);

		$cash = $data{$i} * @purchase[3];
		$mp="s";
		#CHECK IF ENOUGH MONEY IS AVAILABLE
		@purchase[0] =~ tr/_/ /;
		if ($data{$i} > 1) {
			$s = "@purchase[0]s";
			$h = "have";
			}
		else {
			$s = "@purchase[0]";
			$h="has";
		}
		if ($data{$i} > 1 and substr (@purchase[0], length(@purchase[0])-1,length@purchase[0]) eq 'y') {
			$s = "@purchase[0]";
			$h = "have";
			}
		elsif ($data{$i} == 1 and substr (@purchase[0], length(@purchase[0])-1,length@purchase[0]) eq 'y'){
			$s = "@purchase[0]";
			$h="has";
		}
		@purchase[0] =~ tr/ /_/;
		if ($cash < @money[0]) {
			#CHECK IF ENOUGH UNITS ARE AVAILABLE
			if (@purchase[2] >= $data{$i}) {
				$OwnerPath = "/home/admin/classic/se/Planets/$Planet/users/@purchase[1]/";
				@money[0] -= $cash;
				$bn = &Space($cash);
				$BuyMsg = $BuyMsg."$data{$i} $s $h been purchased at a cost of \$$bn.<BR>";
				chdir ("$UserPath") or print "Money CHDIR not working";
				open (DATAOUT, ">money.txt");
				print DATAOUT "@money[0]\n";
				close (DATAOUT);

				
				#ADD UNITS TO POOL
				$Military = "military/";
				$dest = "dest";
				$abxc = "$i$dest";

				chdir ("$UserPath$Military") or print "CHDIR not workin";
				if (-e "@purchase[0].num") {
#					opendir (DIR, '.');
#					print readdir (DIR);
					open (ADDS, "@purchase[0].num") or print "File Not opening";
					@stuff = <ADDS>;
					close (ADDS) or print "File Not Closing";
					}
				else {
					$wastetime=1;
				}
				$nametype = @purchase[0];
				open (ADDSS, ">$nametype.num");
				@stuff[0] += $data{$i};
				print ADDSS "$stuff[0]\n";
				close (ADDSS);

				$replacement = "Pool";
				chdir ("$UserPath$Military$replacement/") or print "dang";	
				if (-e "$purchase[0].unt") {			
					open (ADDITION, "$purchase[0].unt") or print "dangit";
					@addstuff=<ADDITION>;
					close (ADDITION);
					$counter=0;
					&chopper (@addstuff);
				}
				@addstuff[0] += $data{$i};
				open (ADDITION, ">$purchase[0].unt");
				print ADDITION "@addstuff[0]\n";
				close (ADDITION);			


				if (@purchase[1] ne 'None') {
					chdir ("$OwnerPath");
					open (DATAIN, "money.txt");
					$funds=<DATAIN>;
					close (DATAIN);
					chop ($funds);
					$funds += $cash;
					open (DATAOUT, ">money.txt");
					print DATAOUT "$funds\n";
					close (DATAOUT);
					chdir ("events/");
					$Counter = 0;
					while (-e "$Counter.vnt") {
						$Counter++;
					}
					open (DATAOUT, ">$Counter.vnt");
					print DATAOUT "Market Purchase\n";
					print DATAOUT "$Buyer has purchased some of your military hardware from the market.\n";
					print DATAOUT "<Center>An order of $data{$i} $s $h been placed.<BR>\n";
					print DATAOUT "\$$bn has been transfered to your reserves.\n";

				}
	
				chdir ("$MarketPath");
				open (ADDSS, ">$i.unt") or print "CHDIR not workin 3";
				@purchase[2] -= $data{$i};
				foreach $writeline (@purchase) {
					print ADDSS "$writeline\n";
				}
				close (ADDSS);

				if (@purchase[2] eq 0) {
					unlink ("$i.unt");
				}


				}
			else {	
				$BuyMsg = $BuyMsg."Not enough @purchase[0]s are available.<BR>The maximum number of available @purchase[0]s is @purchase[2].<BR>";
			}
		}
	else { 
		$a = int(@money[0]/@purchase[3]);
		$BuyMsg = $BuyMsg."You do not possess enough funds to purchase $data{$i} $s.<BR>The maximum number of $s$mp that can be afforded is $a.<BR>";
		}
		
	}		
}
$to = &Space(@money[0]);
print qq!
<SCRIPT>
parent.frames[1].location.reload()
</SCRIPT>
<center>
<FONT FACE="Arial, Helvetica, sans-serif">
<form method="post" action="http://www.bluewand.com/cgi-bin/classic/marketproc.pl">
<B>International Market</B></CENTER><BR>
<table border="1" width="100%" bgcolor="#999999" text = "White" BORDER=1 CELLSPACING=0>
<tr> 
<TD BGCOLOR ="#999999" width="25%"><FONT FACE="Arial, Helvetica, sans-serif">Current Funds:</td>
<TD BGCOLOR="#666666" width="25%"><FONT FACE="Arial, Helvetica, sans-serif">\$$to</td>
<TD BGCOLOR ="#999999" width="25%"><FONT FACE="Arial, Helvetica, sans-serif">Remaining Turns:</td>
<TD BGCOLOR="#666666" width="25%"><FONT FACE="Arial, Helvetica, sans-serif">$turns</td>
</tr>
</table>
<BR><CENTER>$BuyMsg<BR>
<table border="1" width="100%" bgcolor="#666666" text = "White" BORDER=1 CELLSPACING=0>
<tr BGCOLOR="#999999"> 
<td width="20%"><FONT FACE="Arial, Helvetica, sans-serif">Unit Name:</td>
<td width="15%"><FONT FACE="Arial, Helvetica, sans-serif">Class:</td>
<td width="16%"><FONT FACE="Arial, Helvetica, sans-serif">Seller:</td>
<td width="11%"><FONT FACE="Arial, Helvetica, sans-serif">Available:</td>
<td width="10%"><FONT FACE="Arial, Helvetica, sans-serif">Owned:</td>
<td width="18%"><FONT FACE="Arial, Helvetica, sans-serif">Cost:</td>
<td width="10%"><FONT FACE="Arial, Helvetica, sans-serif">Purchase:</td>
</tr>
!;

chdir ("$MarketPath") or print "BLAHJH";
opendir (DIR, '.');
@unitp = readdir (DIR);
closedir (DIR);

foreach $ia (@unitp) {
	@unitnum[0] =0;
	chdir ("$MarketPath");
	if (-f $ia) {
	open (UNIT,"$ia") or print "Hello";
	@unitstat=<UNIT>;
	close (UNIT);
	&chopper(@unitstat);

	chdir ("$PlayerPath@unitstat[1]/");
	open (TEMPRELATE, "war.txt");
	@data=<TEMPRELATE>;
	close(TEMPRELATE);
	$status=2;
	foreach $k (@data) {
		chop ($k);
	}
	foreach $k (@data) {
		if ($k eq $user) {
			$status=-1;
		}
	}
	if ($status ne -1) {
			open (TEMPRELATE, "alliance.txt");
			$Ally=<TEMPRELATE>;
			close(TEMPRELATE);
			chop ($Ally);
			chdir ("$AlliancePath$Ally/");
			open (DATAIN, "members.txt");
			@friends = <DATAIN>;
			close (DATAIN);
			if (grep(/$User/, @friends) > 0) {$status = 3}
		if ($status ne 3 and $status ne -1) {
			if ($status >= @unitstat[4]) {
				$f="unitshow.pl";
				
				chdir ("$ArmyPath");
				if (-e "$unitstat[0].num") {
					open (NUMS, "$unitstat[0].num");
					@unitnum=<NUMS>;
					close (NUMS);
				}
				if (@unitnum[0] < 1) {
					@unitnum[0] = 0;
				}
				chdir ("$MarketPath");
				$dest= "dest";
				$i = substr($ia, 0, length($ia)-4);
				$sellerguy = @unitstat[1];
				$sellerguy =~ tr/_/ /;
				$VehicleName = $unitstat[0];
				$VehicleName =~ tr/_/ /;
				$VehicleType = $unitstat[5];
				$pricey = &Space($unitstat[3]);
				$amn = &Space($unitstat[2]);
				$bmn = &Space(@unitnum[0]);

				print qq!
<tr bgcolor="#666666"> 
<td width="20%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1"><A href = "$f?$unitstat[0].unt" target ="Frame5" ONMOUSEOVER = "parent.window.status='$VehicleName Information';return true" ONMOUSEOUT = "parent.window.status='';return true" STYLE="text-decoration:none;color:808080">$VehicleName</a></td></td>
<td width="15%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$VehicleType &nbsp;</td>
<td width="16%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$sellerguy</td>
<td width="11%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$amn</td>
<td width="10%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">$bmn</td>
<td width="18%"><FONT FACE="Arial, Helvetica, sans-serif" size="-1">\$$pricey</td>
<td width="10%"><FONT FACE="Arial, Helvetica, sans-serif"> 
<center>
<input type="TEXT" name="$i" size="5">
</center>
</td>
</tr>
				!;
				}
		}
	}
	}
}



print qq!
</table>
<BR><BR>
<table border="1" width="35%" bgcolor="#666666" BORDER=1 CELLSPACING=0>
<tr> 
<td> 
<div align="CENTER">
<input type="SUBMIT" name="purchase" value="Purchase">
</div>
</td>
<td> 
<div align="CENTER">
<input type="RESET" name="submit2" value="   Clear   ">
</div>
</td>
<INPUT TYPE=HIDDEN NAME="user" VALUE="$User">
<INPUT TYPE=HIDDEN NAME="planet" VALUE="$Planet">
<INPUT TYPE=HIDDEN NAME=authcodes VALUE="$AuthCodes">

</tr>
</table>
<INPUT TYPE=HIDDEN NAME=max VALUE=$i>
</form>
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



#sub chopper {
#foreach $k (@_) {
#	chop($k);
#	}
#}
#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}
