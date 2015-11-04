#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$Alliance,$Mode)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);

#Set Paths
$Path = $MasterPath . "/se/Planets/$Planet/alliances";
$NewsDir = $MasterPath . "/se/Planets/$Planet/News";
$HomePath = $MasterPath . "/home/bluewand/data/classic/se/Planets";

open (IN, "$Path/$Alliance/members.txt");
flock (IN, 1);
@Members = <IN>;
close (IN);
&chopper (@Members);


$LeaderFlag = $LCounter = 0;

foreach $Item (@Members) {
	($Rank,$Leader,$Blah) = split(/\|/,$Item);

	if (substr ($Item, 0, 1) eq "0" && (-e "$HomePath/$Blah/users/$Leader")) {$LCounter ++;}
	if ($Leader eq $User && $Rank == 0) {
		$LeaderFlag = 1;
	} elsif ($Leader eq $User && $Rank == 1) {
		$LeaderFlag = 3;
	} elsif ($Leader eq $User && $Rank > 1) {
		$LeaderFlag = 2;
	}
}


if ($LCounter == 0 && $LeaderFlag == 3) {
	$LeaderFlag = 1;
}
unless ($LeaderFlag == 1) {
	print qq!Location: http://www.bluewand.com/cgi-bin/classic/AllyDisplay.pl?$User&$Planet&$AuthCode&$Alliance\r\n\r\n!;
	die;
}


#Obtain List of Alliances
opendir (DIR, $Path);
@Alliances = readdir(DIR);
closedir (DIR);

@Alliances = sort (@Alliances);

#Create Drop-Down List
foreach $Item (@Alliances)
{
	unless ($Item eq "." || $Item eq "..") {
		$Item2 = $Item;
		$Item2 =~ tr/_/ /;
		$List .= "<option value='$Item'>$Item2</option>";
		$Orientation{$Item} = 0; #Set Default Orientation to Zero
	}
}

if ($Mode == 1) {
	&parse_form;
	open (IN, "$Path/$Alliance/Enemy.txt");
	flock (IN, 1);
	@Enemies = <IN>;
	close (IN);
	&chopper (@Enemies);
	open (IN, "$Path/$Alliance/Ally.txt");
	flock (IN, 1);
	@Allies = <IN>;
	close (IN);
	&chopper (@Allies);

	foreach $One (@Enemies) {
		$Orientation{$One} = 1;
	}
	foreach $One (@Allies) {
		$Orientation{$One} = 2;
	}
	($Sec,$Min,$Hour,$Mday,$Mon,$Year,$Wday,$Yday,$Isdst) = localtime(time);
	$Mon++;
	$Year += 1900;

	if (length($Sec) == 1) {$Sec = "0$Sec";}
	if (length($Min) == 1) {$Min = "0$Min";}
	if (length($Hour) == 1) {$Hour = "0$Hour";}
	$NiceAlliance = $Alliance;
	$NiceAlliance =~ tr/_/ /;

	if ($data{"Enemy"} ne "") {
		unless ($data{"Enemy"} eq $Alliance)
		{
			$NiceEnemy = $data{'Enemy'};
			$NiceEnemy =~ tr/_/ /;

			open (DNEWSOUT, ">$NewsDir/$Year$Mon$Mday$Hour$Min$Sec") or print "Cannot open path for news<BR>";
			print DNEWSOUT "$NiceAlliance Declares War!\n";
			print DNEWSOUT "<Center>$Hour:$Min:$Sec    $Mon/$Mday/$Year\n";
			print DNEWSOUT "The alliance of $NiceAlliance has declared war upon $NiceEnemy.\n";
			close (DNEWSOUT);
			$Orientation{$data{'Enemy'}} = 1;
		}
	}
	if ($data{"Ally"} ne "") {
		unless ($data{"Ally"} eq $Alliance)
		{
			$NiceEnemy = $data{'Ally'};
			$NiceEnemy =~ tr/_/ /;

			open (DNEWSOUT, ">$NewsDir/$Year$Mon$Mday$Hour$Min$Sec") or print "Cannot open path for news<BR>";
			print DNEWSOUT "$NiceAlliance Strengthens Ties!\n";
			print DNEWSOUT "<Center>$Hour:$Min:$Sec    $Mon/$Mday/$Year\n";
			print DNEWSOUT "The alliance of $NiceAlliance has allied itself with $NiceEnemy.\n";
			close (DNEWSOUT);
			$Orientation{$data{'Ally'}} = 2;
		}
	}
	if ($data{"Neutral"} ne "") {
		unless ($data{"Neutral"} eq $Alliance)
		{
			$NiceEnemy = $data{'Neutral'};
			$NiceEnemy =~ tr/_/ /;

			open (DNEWSOUT, ">$NewsDir/$Year$Mon$Mday$Hour$Min$Sec") or print "Cannot open path for news<BR>";
			print DNEWSOUT "$NiceAlliance Ends War!\n";
			print DNEWSOUT "<Center>$Hour:$Min:$Sec    $Mon/$Mday/$Year\n";
			print DNEWSOUT "The alliance of $NiceAlliance has resumed peaceful relations with $NiceEnemy.\n";
			close (DNEWSOUT);
			$Orientation{$data{'Neutral'}} = 0;
		}
	}


	foreach $One (keys(%Orientation)) {
		if ($Orientation{$One} == 1) {push (@Enemy, "$One\n");}
		if ($Orientation{$One} == 2) {push (@Ally, "$One\n");}
		if ($Orientation{$One} == 0) {push (@Neutral, "$One\n");}
	}

	open (OUT, ">$Path/$Alliance/Enemy.txt");
	flock (OUT, 2);
	print OUT @Enemy;
	close (OUT);
	open (OUT, ">$Path/$Alliance/Ally.txt");
	flock (OUT, 2);
	print OUT @Ally;
	close (OUT);
	open (OUT, ">$Path/$Alliance/Neutral.txt");
	flock (OUT, 2);
	print OUT @Neutral;
	close (OUT);
}



print qq!
<body bgcolor=black text=white><font face=arial>
<SCRIPT>parent.frames[1].location.reload()</SCRIPT>
<table width=100% border=1 bgcolor=333333 cellspacing=0><TR><TD><B><font face=arial size=-1><center>Diplomacy</TD></TR></table>
<BR><BR>
<table width=100% border=0  cellspacing=0>
<TR><TD width=33% valign=top>

	<table width=100% border=1 bgcolor=666666 cellspacing=0>
	<TR><TD bgcolor=333333><font face=arial size=-1>Enemy</TD></TR>!;

	open (IN, "$Path/$Alliance/Enemy.txt");
	flock (IN, 1);
	@EnemyAlliances = <IN>;
	close (IN);

	foreach $One (@EnemyAlliances) {
		$One =~ tr/_/ /;
		print "<TR><TD><font face=arial size=-1>$One</TD></TR>";
	}

print qq!
	<tR><TD bgcolor=333333><font face=arial size=-2><form METHOD=POST action="AllyDiplomacy.pl?$User&$Planet&$AuthCode&$Alliance&1"><select name=Enemy>$List</select><BR><input type=submit name=submit value="Add to enemies"></form></TD></TR>
	</table>

</TD><TD width=34% valign=top>

	<table width=100% border=1 bgcolor=666666 cellspacing=0>
	<TR><TD bgcolor=333333><font face=arial size=-1>Neutral</TD></TR>!;

	open (IN, "$Path/$Alliance/Neutral.txt");
	flock (IN, 1);
	@EnemyAlliances = <IN>;
	close (IN);

	foreach $One (@EnemyAlliances) {
		$One =~ tr/_/ /;
		print "<TR><TD><font face=arial size=-1>$One</TD></TR>";
	}



print qq!
	<tR><TD bgcolor=333333><font face=arial size=-2><form METHOD=POST action="AllyDiplomacy.pl?$User&$Planet&$AuthCode&$Alliance&1"><select name=Neutral>$List</select><BR><input type=submit name=submit value="Add to neutral"></form></TD></TR>
	</table>

</TD><TD width=33% valign=top>

	<table width=100% border=1 bgcolor=666666 cellspacing=0>
	<TR><TD bgcolor=333333><font face=arial size=-1>Allied</TD></TR>!;


	open (IN, "$Path/$Alliance/Ally.txt");
	flock (IN, 1);
	@EnemyAlliances = <IN>;
	close (IN);

	foreach $One (@EnemyAlliances) {
		$One =~ tr/_/ /;
		print "<TR><TD><font face=arial size=-1>$One</TD></TR>";
	}


print qq!
	<tR><TD bgcolor=333333><font face=arial size=-2><form METHOD=POST action="AllyDiplomacy.pl?$User&$Planet&$AuthCode&$Alliance&1"><select name=Ally>$List</select><BR><input type=submit name=submit value="Add to allies"></form></TD></TR>
	</table>
</TD></TR></table>
</body>!;


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

#sub chopper{
#	foreach $k(@_){
#		chomp($k);
#	}
#}
#
#sub Space {
#  local($_) = @_;
#  1 while s/^(-?\d+)(\d{3})/$1 $2/; 
#  return $_; 
#}
