#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

$Path = $MasterPath . "/Planets/SystemTwo-Nedic/users";
$Path2 = $MasterPath . "/Planets/SystemTwo-Nedic/alliances";

opendir (DIR, "$Path") or print "Cannot open Dir $Path<BR>";
@Users = readdir (DIR);
closedir (DIR);


foreach $Item (@Users) {
	print "$Alliance<BR> $Item - ";
	if (-f "$Path/$Item/alliance.txt") {
		open (IN, "$Path/$Item/alliance.txt");
		flock (IN, 1);
		$Alliance = <IN>;
		chomp ($Alliance);
		print "$Item - $Alliance<BR>";
		if ($Alliance eq "Spiritual_Assasins") {
			if ($User eq "Zhsdasfsdadum") {$Rank = 0} else {$Rank = 5}
			push (@Alliance, "$Rank\|$Item\|SystemTwo-Nedic\n");
			print "$Item - $Alliance<BR>";
		}
		close (IN);	
	}
}

open (OUT, ">$Path2/Spiritual_Assasins/members.txt") or print "Cannot open ($Path2/Spiritual_Assasins/members.txt)<BR>";
flock (OUT, 2);
print OUT @Alliance;
close (OUT);
