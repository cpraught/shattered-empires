#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

opendir (DIR, ".");
@Files = readdir (DIR);
closedir (DIR);

$A = qq!if(($AuthCode ne $authCode{$User}) and ($AuthCode ne "")){!;
$B = qq!if(($AuthCode ne $authCode{$User}) and ($AuthCode ne "")){!;

$Count = 0;
foreach $Item (@Files) {
	if ($Item ne 'Modify.pl') {
		open (IN, "$Item");
		@FileData = <IN>;
		close (IN);

		&chopper (@FileData);

		open (OUT, ">$Item");
		foreach $Line (@FileData) {

			if ($Line eq "$A") {$Line =$B}
			print OUT "$Line\n";
		}
		close (OUT);
	}
$Count++;
}

#print "Done<BR>";
#sub chopper{
#	foreach $k(@_){
#		chop($k);
#	}
#}

