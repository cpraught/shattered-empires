#!/usr/bin/perl
require 'quickies.pl'


$Dir = $MasterPath . "/se/Planets/SystemOne-Gaia/users/Despiser/units";
$Dir2 =$MasterPath . "/se/Planets/SystemOne-Gaia/users/Despiser/military";
unlink "$Dir/Grcons.unt";
unlink "$Dir/Grcons.con";
unlink "$Dir2/Grnums.unt";


print "Content-type: html/text\n\n";

print "Removed.";

