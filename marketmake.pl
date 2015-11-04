#!/usr/bin/perl
print "Content-type: text/html\n\n";

$Dir = "home/shatteredempires/SE/";
chdir ("$Dir");
mkdir("weapons/",0755);

print "Done";
