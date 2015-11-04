#!/usr/bin/perl

opendir (DIR, "/home/admin/classic/research");
@Techs = readdir (DIR);
closedir (DIR);

#New Tech Format - (Index)  - Name|PointsRequired|Tech1|Tech2|Tech3|Tech4

foreach $Item (@Techs) {
	if (-f "/home/admin/classic/research/$Item") {
	open (IN, "/home/admin/classic/research/$Item");
	@Data = <IN>;
	close (IN);
	&chopper (@Data);
	$Name = $Item;
	$Name =~ s/.cpl//;
	$Name =~ tr/ /_/;
	@TechNeeded = split(/\|/,@Data[0]);
	push (@Tech, qq!$Name|@Data[1]|@TechNeeded[0]|@TechNeeded[1]|@TechNeeded[2]|@TechNeeded[3]!);

	}
}


open (OUT, ">/home/admin/classic/research/TechData.tkF");
foreach $Line (@Tech) {
	print "Line<BR>";
	print OUT "$Line\n";
}
close (OUT);

sub chopper{
	foreach $k(@_){
		chomp($k);
	}
}
