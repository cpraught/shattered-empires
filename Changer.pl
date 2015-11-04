#!usr/bin/perl

opendir (DIR, '.');
@List = readdir (DIR);
closedir (DIR);

foreach $File (@List) {
		if ($File =~ /.pl/i and $File ne "Changer.pl") {
		print "$File\n";
		open (IN, $File);
		@FileData = <IN>;
		close (IN);

		open (OUT, ">$File");
		foreach $Line (@FileData) {
			$Line =~ s/\n\n/\n/;
			print OUT $Line;

		}
		close (OUT);
	}
}
