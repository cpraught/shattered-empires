#!/usr/bin/perl

#From /home/bluewand/data/classic/se/Planets/$Planet
#To /home/virtual/site23/fst/home/bluewand/data/classic/se/Planets?$Planet
$user_information = $MasterPath . "/User Information";
$messageboard = "home/shatteredempires/SE/public_html/messageboard";
&parse_form;
&check_content;
&check_pword;

if($data{'messagedir'} eq ""){
mkdir("$messageboard/$data{'topicarea'}/$data{'thread'}",0777);

open(NEWMESSAGE,">$messageboard/$data{'topicarea'}/$data{'thread'}/originator");
print NEWMESSAGE "$data{'user'}\n";
close(NEWMESSAGE);

open(NEWMESSAGE,">$messageboard/$data{'topicarea'}/$data{'thread'}/0.msg");
print NEWMESSAGE "$data{'user'}\n";
$body = $data{'message'};
$body =~ s/\cM//g;
$body =~ s/\n\n/<p>/g;
$body =~ s/\n/<br>/g;

$body =~ s/&lt;/</g; 
$body =~ s/&gt;/>/g; 
$body =~ s/&quot;/"/g;
print NEWMESSAGE "$body";
close(NEWMESSAGE);

open(FLAG,">$messageboard/$data{'topicarea'}.cnt");
print FLAG localtime(time);
close(FLAG);

open(FLAG,">$messageboard/$data{'topicarea'}/$data{'thread'}.cnt");
print FLAG localtime(time);
close(FLAG);

$data{'thread'} =~ tr/ /+/;
$data{'topicarea'} =~ tr/ /+/;
print "Location: http://www.bluewand.com/cgi-bin/classic/messageboard.pl?topicarea=$data{'topicarea'}&message=$data{'thread'}\r\n\r\n";
} else {

open(FLAG,">$messageboard/$data{'topicarea'}.cnt");
print FLAG localtime(time);
close(FLAG);

open(FLAG,">$messageboard/$data{'topicarea'}/$data{'messagedir'}.cnt");
print FLAG localtime(time);
close(FLAG);

$counter = 0;
while(-f "$messageboard/$data{'topicarea'}/$data{'messagedir'}/$counter.msg"){$counter++}

open(NEWMESSAGE,">$messageboard/$data{'topicarea'}/$data{'messagedir'}/$counter.msg");
print NEWMESSAGE "$data{'user'}\n";
$body = $data{'message'};
$body =~ s/\cM//g;
$body =~ s/\n\n/<p>/g;
$body =~ s/\n/<br>/g;

$body =~ s/&lt;/</g; 
$body =~ s/&gt;/>/g; 
$body =~ s/&quot;/"/g;
print NEWMESSAGE "$body";
close(NEWMESSAGE);

$data{'topicarea'} =~ tr/ /+/;
$data{'messagedir'} =~ tr/ /+/;
print "Location: http://www.bluewand.com/cgi-bin/classic/messageboard.pl?topicarea=$data{'topicarea'}&message=$data{'messagedir'}\r\n\r\n";
}

sub check_content{
if($data{'message'} eq ""){
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"Sorry, you must have some content for your message.\")\;history.back()</SCRIPT>";
	die;
}
}

sub check_pword{
$data{'user'} =~ tr/ /_/;
dbmopen(%password, "$user_information/password", 0777);
if ($password{$data{'user'}} ne $data{'password'} or $data{'password'} eq "") {
	print "Content-type: text/html\n\n";
	print "<SCRIPT>alert(\"Sorry, Your login and/or password are incorrect.\")\;history.back()</SCRIPT>";
	dbmclose(%password);
	die;
}
$data{'user'} =~ tr/_/ /;
}

sub parse_form {
read(STDIN, $webstuff, $ENV{'CONTENT_LENGTH'});
@input = split(/&/, $webstuff);
foreach $k (@input) {
	($key, $value) = split(/=/, $k);
	$value =~ tr/+/ /;
	$value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
	$value =~ tr/<!--(.|\n)*-->//;
	$value =~ tr/<([^>]|\n)*>//;
	$data{$key} = $value;
	}
}
