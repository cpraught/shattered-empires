opendir (DIR, ".");
@Files = readdir (DIR);
foreach $Item (@Files) {
	unless ($Item eq "ColourChanger.pl") {
		open (IN, "$Item");
		@FileStruc = <IN>;
		close (IN);
		open (OUT, ">$Item");
		foreach $Line (@FileStruc) {
			$Line =~ s/000000/666666/;
			$Line =~ s/2E2E2E/000000/;
			$Line =~ s/2e2e2e/000000/;
			$Line =~ s/1b1b1b/999999/;
			$Line =~ s/arial/verdana/;
			print OUT "$Line";
		}
		close (OUT);
	}
}
