#!/usr/bin/perl
print "Content-type: text/html\n\n";

$Path = "/home/admin/classic/";
$Path2 = "/home/admin/classic/research";
open (DATAIN, "$Path/techlist.txt");
@Array = <DATAIN>;
close (DATAIN);

foreach $A (@Array) {
	if ($A ne "\n") {
		if ($A =~ /_/i > 0) {
			($Tech,$Points)=split(/_/,$A);
			print "$Tech:<BR>   $Points<BR>";
			open (OUT, ">$Path2/$Tech.cpl");
		} else {
			$A =~ s/, /\|/;
			$A =~ tr/,/\|/d;
			$A =~ tr/.//d;
			$A =~ tr/-//d;
			$A =~ s/none//;
			$A =~ s/None//;
			print OUT "$A";
			print OUT "$Points";
			print "$A<BR><BR>";
			close (OUT);
		}			
	}
}

