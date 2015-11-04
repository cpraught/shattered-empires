#!/usr/bin/perl

#will this be necessary?
#i'll just hard code it.
open (OUT, ">/home/virtual/site23/fst/home/bluewand/data/classic/se/Planets/SystemOne-Gaia/alliances/NEVAH/members.txt");

print OUT "0|NEW_USA|SystemOne-Gaia\n";
print OUT "1|Yiff|SystemOne-Gaia\n";
print OUT "1|Zhadum|SystemOne-Gaia\n";
print OUT "2|Nigeria|SystemOne-Gaia\n";
print OUT "3|Slomakia|SystemOne-Gaia\n";
print OUT "4|Seville|SystemOne-Gaia\n";
print OUT "5|techtonia|SystemOne-Gaia\n";
print OUT "5|Skoaler|SystemOne-Gaia\n";
print OUT "5|Jarelia|SystemOne-Gaia\n";
print OUT "5|Gelenia|SystemOne-Gaia\n";
print OUT "5|Menzoberranzan|SystemOne-Gaia\n";
print OUT "5|Rohnan|SystemOne-Gaia\n";
print OUT "5|Phakland_Keep|SystemOne-Gaia\n";
print OUT "5|Midgard|SystemOne-Gaia\n";


close (OUT);


print "Content-type: html/text\n\n";

print "Repaired.";

