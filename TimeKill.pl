#!/usr/bin/perl
print "Content-type: text/html\n\n";

$Planet = $ENV{QUERY_STRING};
$userdir="/home/admin/classic/se/Planets/$Planet/users/";
$user_information = "/home/admin/classic/se/User Information";

opendir(USERS, "$userdir");
@dirs=readdir(USERS);
close(USERS);
@dirs=sort(@dirs);
use File::Find;

print "Listing:<BR>";

foreach $i (@dirs) {
	$I++;
	if(-f "$userdir/$i") {unlink("$userdir/$i")} else {
		if ($i ne '..' and $i ne '.') {
			$Play = int(-M "$userdir$i/turns.txt");
			if ($Play >= 10 and $Vac ne "Yes") {

				chdir('../../');
				finddepth(\&deltree,"$userdir/$i");
				rmdir("$userdir/$i");
				&RemoveData;

				print "$i Removed ($Play Days Old)<BR>";
				

			}
		}
	}
}

sub deltree {
	$file = "$File::Find::dir/$_";
	unlink("$File::Find::dir/$_") or rmdir("$File::Find::dir/$_")
}

sub RemoveData {
dbmopen(%password, "$user_information/password",0777);
delete($password{$key});
dbmclose(%password);

dbmopen(%accesscode, "$user_information/accesscode",0777);
delete($accesscode{$key});
dbmclose(%accesscode);

dbmopen(%emailaddress, "$user_information/emailaddress",0777);
delete($emailaddress{$key});
dbmclose(%emailaddress);

dbmopen(%planet, "$user_information/planet",0777);
delete($planet{$key});
dbmclose(%planet);

dbmopen(%ip, "$user_information/ip",0777);
delete($ip{$key});
dbmclose(%ip);

dbmopen(%date, "$user_information/date",0777);
delete($date{$key});
dbmclose(%date);
}
