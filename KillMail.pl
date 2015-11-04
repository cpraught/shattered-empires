#!/usr/bin/perl
print "Content-type: text/html\n\n";

$PlayerPath = "/home/admin/classic/se/Planets";

opendir (DIR, $PlayerPath);
@Planets = readdir (DIR);
closedir (DIR);

foreach $Planet (@Planets) {
	opendir (DIR, "$PlayerPath/$Planet/users");
	@Players = readdir (DIR);
	closedir (DIR);
	foreach $Player (@Players) {
		if (-d "$PlayerPath/$Planet/users/$Player" and $Player ne '.' and $Player ne '..') {
			opendir (DIR, "$PlayerPath/$Planet/users/$Player/research");
			@Messages = readdir (DIR);
			closedir(DIR);
			foreach $Message (@Messages) {
				if (-f "$PlayerPath/$Planet/users/$Player/research/$Message") {
					unlink ("$PlayerPath/$Planet/users/$Player/research/$Message");
				}
			}
		}
	}
}

print "Messages All Gone";
