#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

($User,$Planet,$AuthCode,$Alliance,$Mode)=split(/&/,$ENV{QUERY_STRING});
$user_information = $MasterPath . "/User Information";
dbmopen(%authcode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authcode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the Bluewand Entertainment team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authcode);
dbmopen(%emailaddress, "$user_information/emailaddress", 0777);
$Address = $emailaddress{$User};

if ($Mode == 1) {
&parse_form;

open(MAIL, "|/usr/sbin/sendmail 11009feg\@conestogac.on.ca") or die "Sorry could not run mail program.";
print MAIL "From: $User <$Address>\n";
print MAIL "Subject: Alliance Application\n\n";
print MAIL "Alliance Name: $Alliance\n";
print MAIL "Alliance Planet: $Planet\n";
print MAIL "Alliance Charter:\n";
print MAIL "$data{'Charter'}\n\n";
print MAIL "Alliance History:\n";
print MAIL "$data{'History'}\n\n";
print MAIL "Alliance Summary:\n";
print MAIL "$data{'Summary'}\n\n";
print MAIL "Alliance Ranks:\n";
print MAIL "Rank One:   $data{'rank1'}\n";
print MAIL "Rank Two:   $data{'rank2'}\n";
print MAIL "Rank Three: $data{'rank3'}\n";
print MAIL "Rank Four:  $data{'rank4'}\n";
print MAIL "Rank Five:  $data{'rank5'}\n";
print MAIL "Rank Six:   $data{'rank6'}\n";
close(MAIL);




$SF = qq!<font face=verdana size=-1>!;
print qqﬁ
<body bgcolor="#000000" text="white">
<table width=100% border=1 cellspacing=0 bgcolor="#999999"><TR><TD>$SF<Center><B>Faction Application</TD></TR></table>
<BR><BR><BR><BR>
<Center>$SF Thank you for submitting your application.  We will reply to you as soon as possible.
</body>
ﬁ;


die;
}

$ApplicationPath = $MasterPath . "/Planets/$Planet/factions";

$FactionName = $Alliance;
$FactionName =~ tr/ /_/;
$SF = qq!<font face=verdana size=-1>!;
print qqﬁ
<body bgcolor="#000000" text="white">
<table width=100% border=1 cellspacing=0 bgcolor="#999999"><TR><TD>$SF<Center><B>Faction Application</TD></TR></table>
$SF<BR>Although some players want no more than the simple ranking and messaging system the Faction offers, some groups of players want more of an edge.  The Alliance is that edge.  Alliance members have a much greater range of tools, including the ability to cooperate on research and sell specifically to other alliance members, without allowing any nation not in the alliance access to the unit or its statistics.  Being a member in an alliance carries a responsibility however.  While it is only recommended that Factions actively roleplay, for Alliances, it is a requirement.  If the basics of an Alliance application are not done in roleplay, the Alliance will be rejected, no questions asked.
 Alliances are integral to the theme and environment of Shattered Empires, and care must be taken to preserve the environment.  Consequently, an Alliance which moves away from roleplay, and transforms into an alliance with the attitude <i>All Kewl D00Ds join us. Were the best!</i> will rapidly have its Alliance status revoked.

<form method=POST action="http://www.bluewand.com/cgi-bin/classic/AllyFaction.pl?$User&$Planet&$AuthCode&$Alliance&1">
<center>
<table width=100% border=1 cellspacing=0 bgcolor="#666666"><TR><TD>$SF Alliance Charter</TD></TR></table>
<textarea name="Charter" wrap=virtual cols=70 rows=5>Enter your alliance charter here</textarea>
<BR><BR><BR>

<table width=100% border=1 cellspacing=0 bgcolor="#666666"><TR><TD>$SF Alliance History</TD></TR></table>
<textarea name="History" wrap=virtual cols=70 rows=5>Enter your alliance history (Roleplay) here</textarea>

<BR><BR><BR>

<table width=100% border=1 cellspacing=0 bgcolor="#666666"><TR><TD>$SF Alliance Summary</TD></TR></table>
<textarea name="Summary" wrap=virtual cols=70 rows=2>Enter a brief summary of your alliance here</textarea>

<BR><BR><BR>

<table width=100% border=1 cellspacing=0 bgcolor="#666666"><TR><TD>$SF Alliance Ranks</TD></TR></table>
<center>
<table width=80% border=0 cellspacing=0>
<TR><TD>$SF<center><input type=text name=rank1 value=Founder></TD><TD><center>$SF<input type=text name=rank2></TD></TR>
<TR><TD>$SF<center><input type=text name=rank3></TD><TD>$SF<center><input type=text name=rank4></TD></TR>
<TR><TD>$SF<center><input type=text name=rank5></TD><TD>$SF<center><input type=text name=rank6 value=Initiate></TD></TR>
</TR>
</table>
</center>
<BR><BR>
<input type=submit name=submit value="Send Application">
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
         
      

      $data{$name} = $value;
      }
}
