#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($Userh,$Planet,$Authcode)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if($Authcode ne $authcode{$Userh}){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);

$GameKeepPath=qq!http://www.bluewand.com/classic!;
$Header = "#333333";$HeaderFont = "#CCCCCC";$Sub = "#999999";$SubFont = "#000000";$Content = "#666666";$ContentFont = "#FFFFFF";
&parse_form;

if($Planet eq ""){$Planet = $data{'planet'}}
$UsersPath = $MasterPath . "/se/Planets/$Planet/users/";
$endgraph =qq!<IMG SRC="$GameKeepPath/images/begin.gif" HEIGHT = "12" WIDTH="3">!;
$begingraph=qq!<IMG SRC="$GameKeepPath/images/end.gif" HEIGHT = "12" WIDTH="3">!;

chdir ("$UsersPath");
if ($data{'mode'} eq "military") {$mode = "Military Size"}
if ($data{'mode'} eq "economy") {$mode = "Economy"}
if ($data{'mode'} eq "population") {$mode = "Total Population"}
if ($data{'mode'} eq "net") {$mode = "NetWorth"}
if (length($data{'mode'}) < 4) {$mode = "Networth"}
opendir (DIR, '.');
@users = readdir (DIR);
closedir (DIR);
if ($mode eq "Military Size") {
	foreach $datas (@users) {
		$exteny = substr ($datas,length($datas)-4,length($datas));
		if ($datas ne '.' and $datas ne '..' and -d "$UsersPath/$datas") {
		unless (-f "$UsersPath/$datas/Dead.txt") {
			$TotalSize = 0;
			$temppath ="$UsersPath$datas";
			
			chdir ("$temppath/") or print "CANNOT CHANGE DIR<BR>";
			if (-e "continent.txt") {
				open (DATAIN, "continent.txt");
				flock (DATAIN, 1);
				$Continent = <DATAIN>;
				close (DATAIN);
				$datas =~ tr/ /_/;
				if ($Continent == 1) {$colourcode{$datas} = "Cont1.gif"} #OliveDrab2
				if ($Continent == 2) {$colourcode{$datas} = "Cont2.gif"} #CadetBlue
				if ($Continent == 3) {$colourcode{$datas} = "Cont3.gif"} #ivory4
				if ($Continent == 4) {$colourcode{$datas} = "Cont4.gif"} #MediumPurple
			}
			chdir ("$temppath/military/");

			opendir (DIR, '.');	
			@lists = readdir (DIR);
			closedir (DIR);


			foreach $dir (@lists) {
				chdir ("$temppath/military/");
				$exten = substr($dir, length($dir)-4, length($dir));
				if ($dir ne '.' and $dir ne '..' and $exten ne ".txt") {
					chdir ("$dir/");
					open (DATAIN, "army.txt");
					flock (DATAIN, 1);
					@armydata = <DATAIN>;
					close (DATAIN);
					&chopper (@armydata);
					if (@armydata[3] < @armydata[5]) {@armydata[5] = @armydata[3]}
					if (@armydata[5] < 0) {@armydata[5] = 0;}
					$TotalSize += @armydata[5];
				}
			}
			$exten = substr($datas,0,5);
			if ($exten ne "Admin") {
				$sorter{$datas} = $TotalSize;
		#		print "$datas $sorter{$datas}<BR>";
				if ($MaxSize <= $TotalSize) {$MaxSize = $TotalSize}
			}
		}
		}
	}
}
if ($mode eq "Economy") {
	foreach $datas (@users) {
		$exteny = substr ($datas,length($datas)-4,length($datas));

		if ($datas ne '.' and $datas ne '..' and -d "$UsersPath/$datas") {
			unless (-f "$UsersPath/$datas/Dead.txt") {	
				$TotalSize = 0;
				$temppath ="$UsersPath$datas/";
				chdir ("$temppath") or print "CANNOT CHANGE DIR<BR>";
				if (-e "continent.txt") {
					open (DATAIN, "continent.txt");
					flock (DATAIN, 1);
					$Continent = <DATAIN>;
					close (DATAIN);
					$datas =~ tr/ /_/;
					if ($Continent == 1) {$colourcode{$datas} = "Cont1.gif"} #OliveDrab2
					if ($Continent == 2) {$colourcode{$datas} = "Cont2.gif"} #CadetBlue
					if ($Continent == 3) {$colourcode{$datas} = "Cont3.gif"} #ivory4
					if ($Continent == 4) {$colourcode{$datas} = "Cont4.gif"} #MediumPurple
				} else {$colourcode{$datas} = "Cont1.gif"}

				open (DATAIN, "country.txt");
				flock (DATAIN, 1);
				@CountData = <DATAIN>;
				close (DATAIN);
				&chopper (@CountData);
				$TotalSize = $CountData[6];
			}
			$exten = substr($datas,0,5);
			if ($exten ne "Admin") {
				$sorter{$datas} = $TotalSize;
			} elsif ($exten eq "Admin") {print "$datas $sorter{$datas}<BR>";}
			if ($MaxSize <= $TotalSize) {$MaxSize = $TotalSize;}		
			$TotalSize=0;
		}
	}
}

if ($mode eq "Total Population") {
	foreach $datas (@users) {
		$exteny = substr ($datas,length($datas)-4,length($datas));
		if ($datas ne '.' and $datas ne '..' and -d "$UsersPath/$datas") {
			unless (-f "$UsersPath/$datas/Dead.txt") {
				$TotalSize = 0;
				$temppath ="$UsersPath$datas/";
				chdir ("$temppath") or print "CANNOT CHANGE DIR<BR>";
				if (-e "continent.txt") {
					open (DATAIN, "continent.txt");
					flock (DATAIN, 1);
					$Continent = <DATAIN>;
					close (DATAIN);
					$datas =~ tr/ /_/;
					if ($Continent == 1) {$colourcode{$datas} = "Cont1.gif"} #OliveDrab2
					if ($Continent == 2) {$colourcode{$datas} = "Cont2.gif"} #CadetBlue
					if ($Continent == 3) {$colourcode{$datas} = "Cont3.gif"} #ivory4
					if ($Continent == 4) {$colourcode{$datas} = "Cont4.gif"} #MediumPurple
				} else {$colourcode{$datas} = "Cont1.gif"}
				open (DATAIN, "country.txt");
				@countrydata = <DATAIN>;
				flock (DATAIN, 1);
				close (DATAIN);
				&chopper (@countrydata);
				$TotalSize = @countrydata[0];
			}
			$exten = substr($datas,0,5);
			if ($exten ne "Admin") {
				$sorter{$datas} = $TotalSize;
			#	print "$datas $sorter{$datas}<BR>";
				if ($MaxSize <= $TotalSize) {$MaxSize = $TotalSize}
			}
			$TotalSize=0;
		}
	}
}
if ($mode eq "Networth") {
	foreach $datas (@users) {
		$exteny = substr ($datas,length($datas)-4,length($datas));
		if ($datas ne '.' and $datas ne '..' and -d "$UsersPath/$datas") {
			unless (-f "$UsersPath/$datas/Dead.txt") {
				$TotalSize = 0;
				$temppath ="$UsersPath$datas/";
				chdir ("$temppath") or print "CANNOT CHANGE DIR<BR>";
				if (-e "continent.txt") {
					open (DATAIN, "continent.txt");
					flock (DATAIN, 1);
					$Continent = <DATAIN>;
					close (DATAIN);
					$datas =~ tr/ /_/;
					if ($Continent == 1) {$colourcode{$datas} = "Cont1.gif"} #OliveDrab2
					if ($Continent == 2) {$colourcode{$datas} = "Cont2.gif"} #CadetBlue
					if ($Continent == 3) {$colourcode{$datas} = "Cont3.gif"} #ivory4
					if ($Continent == 4) {$colourcode{$datas} = "Cont4.gif"} #MediumPurple
				} else {$colourcode{$datas} = "Cont1.gif"}
				open (DATAIN, "country.txt");
				@countrydata = <DATAIN>;
				flock (DATAIN, 1);
				close (DATAIN);
				&chopper (@countrydata);
				$TotalSize = @countrydata[8];
			}
			$exten = substr($datas,0,5);
			if ($exten ne "Admin") {
				$sorter{$datas} = $TotalSize;
				if ($MaxSize <= $TotalSize) {$MaxSize = $TotalSize}
			}
			$TotalSize=0;
		}
	}
}

sort (values(%sorter));

print qq!
<HTML>
<BODY BGCOLOR="#000000" TEXT="#FFFFFF"><Center>
<TABLE BORDER="1" cellspacing=0 WIDTH="100%"><TR><TD BGCOLOR="$Header" width ="50%"><CENTER><FONT FACE="Arial" size="-1" color=$HeaderFont><B>$Planet: $mode</b></td></tr></table><BR>
<form name = "ListType" method="POST" action = "http://www.bluewand.com/cgi-bin/classic/sort.pl">
<INPUT TYPE="HIDDEN" NAME="planet" VALUE="$Planet">

<TABLE BORDER="1" WIDTH="100%" border=1 cellspacing=0>
  <TR>
    <TD BGCOLOR="$Header" width=20%><FONT FACE="Arial" size="-1">Networth</FONT></TD>
    <TD BGCOLOR="$Content" width=5%><DIV ALIGN="CENTER"><INPUT TYPE="radio" NAME="mode" VALUE="net"></DIV></TD>
    <TD BGCOLOR="$Header" width=20%><FONT FACE="Arial" size="-1">Military Size</FONT></TD>
    <TD BGCOLOR="$Content" width=5%><DIV ALIGN="CENTER"><INPUT TYPE="radio" NAME="mode" VALUE="military"></DIV></TD>
    <TD BGCOLOR="$Header" width=20%><FONT FACE="Arial" size="-1">Total Population</FONT></TD>
    <TD BGCOLOR="$Content" width=5%><DIV ALIGN="CENTER"><INPUT TYPE="radio" NAME="mode" VALUE="population"></DIV></TD>
    <TD BGCOLOR="$Header" width=20%><FONT FACE="Arial" size="-1">Economic Strength</FONT></TD>
    <TD BGCOLOR="$Content" width=5%><DIV ALIGN="CENTER"><INPUT TYPE="radio" NAME="mode" VALUE="economy"></DIV></TD>
  </TR>
</TABLE><center>
<BR>
<TABLE  WIDTH="40%" border=1 cellspacing=0>
<TR>
<TD BGCOLOR="$Content"><font size="-1"><DIV ALIGN="CENTER"><INPUT TYPE="submit" value="  Display  " name="submit"></DIV></TD>
</TR>
</TABLE>
<BR></form>
<TABLE BORDER="1" WIDTH="100%" cellspacing=0>
<TR>
<TD BGCOLOR="$Content"><CENTER><FONT FACE="Arial" size="-1">Continent One: Merca<BR><img src="http://www.bluewand.com/classic/images/Ingame/Cont1.gif"></B></FONT></TD>
<TD BGCOLOR="$Content"><CENTER><FONT FACE="Arial" size="-1">Continent Two: Trula<BR><img src="http://www.bluewand.com/classic/images/Ingame/Cont2.gif"></B></FONT></TD>
<TD BGCOLOR="$Content"><CENTER><FONT FACE="Arial" size="-1">Continent Three: Rica<BR><img src="http://www.bluewand.com/classic/images/Ingame/Cont3.gif"></B></FONT></TD>
<TD BGCOLOR="$Content"><CENTER><FONT FACE="Arial" size="-1">Continent Four: Antar<BR><img src="http://www.bluewand.com/classic/images/Ingame/Cont4.gif"></B></FONT></TD>
</TR></TABLE><BR>
<TABLE BORDER="1" WIDTH="100%" border=1 cellspacing=0>
<TR>
<TD bgcolor=$Header><FONT FACE="Arial" size="-1">Rank</td>
<TD bgcolor=$Header width=5%><FONT FACE="Arial" size="-1">Continent</td>
<TD BGCOLOR="$Header" WIDTH="20%"><FONT FACE="Arial" size="-1">Country Name</FONT></TD>
<TD BGCOLOR="$Header" WIDTH="30%"><FONT FACE="Arial" size="-1">Governed By</FONT></TD>
<TD BGCOLOR="$Header" WIDTH="15%"><FONT FACE="Arial" size="-1">UWG Standing</FONT></TD>
<TD BGCOLOR="$Header" WIDTH="30%"><FONT FACE="Arial" size="-1">$mode</FONT></TD>
</TR>$Message
!;		



foreach $User (sort {$sorter{$b} <=> $sorter{$a}} keys %sorter ) {
	if ($User ne '.' and $User ne '..' and $User ne 'located.txt') {
		$Number++;
		open (DATAIN, "$UsersPath/$User/userinfo.txt");
		flock (DATAIN, 1);
		@data = <DATAIN>;
		close (DATAIN);

		&chopper (@data);
		$Player = @data[1];

		open (IN, "$UsersPath/$User/country.txt");
		flock (IN, 1);
		@data2 = <IN>;
		close (IN);
		&chopper (@data2);

		if (-e "$UsersPath/$User/Dead.txt") {
			$DeadCon = "Dead";
			$DeadFlag = 1;

		} else {
			$DeadFlag = 0;
			$DeadCon = qq!<img src="http://www.bluewand.com/classic/images/Ingame/$colourcode{$User}">!;
		}


		if ($User eq $Userh) {$Modst = "<B>"; $UColour = "black"} else {$Modst=""; $UColour = "white";}
		if (@datatwo[23] < 1) {$Diabolics = 0}
		else {
			$Diabolics = @datatwo[23];
		}
		$sizes = int(($sorter{$User}/$MaxSize)*100);
		$midgraph = qq!<IMG SRC="$GameKeepPath/images/graph2.gif" HEIGHT="12" WIDTH="$sizes">!;
		$modestring = "$endgraph$midgraph$begingraph";
		$User2 = $User;
		$User =~ tr/ /_/;
		$User2 =~ tr/_/ /;

		$Value = $sorter{$User};
		if ($Value < 1) {$Value = 0;}
		if ($mode eq "Networth") {$modestring = "$Modst".&Space($Value);}
		print qq!
<TR>	
<TD bgcolor=$Content width=10%><FONT FACE="Arial" size="-1" color=$UColour>$Modst$Number</TD>
<TD bgcolor=$Content width=10%><FONT FACE="Arial" size="-1" color=$UColour><center>$DeadCon</TD>
<TD BGCOLOR="$Content" WIDTH="20%"><FONT FACE="Arial" size="-1" color=$UColour>$Modst<A href="http://www.bluewand.com/cgi-bin/classic/Newst.pl?$User&$Planet&1" STYLE="text-decoration:none;color:$UColour">$User2</a></FONT></TD>
<TD BGCOLOR="$Content" WIDTH="30%"><FONT FACE="Arial" size="-1" color=$UColour>$Modst$Player</FONT></TD>
<TD BGCOLOR="$Content" WIDTH="10%"><FONT FACE="Arial" size="-1" color=$UColour>$Modst@data2[7]</FONT></TD>
<TD BGCOLOR="$Content" WIDTH="15%"><FONT FACE="Arial" size="-1" color=$UColour>$modestring</FONT></TD>
</TR>
	!;
	
		
	}
}
print qq!
</TABLE>
</FONT>
</BODY>
</HTML>
!;
	
#sub chopper {
#foreach $k (@_) {
#	chomp($k);
#	}
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



#sub Space {
#	local($_) = @_;
#	1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#	return $_; 
#}

