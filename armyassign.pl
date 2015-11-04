#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

open (DATAOUT, "> $MasterPath . /Planets/Carsus/users/One/1.txt");
print DATAOUT "Pool\n";
close (DATAOUT);

print "Written<BR>";
