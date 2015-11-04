#!/usr/bin/perl
print "Content-type: text/html\n\n";


srand();

$Value = int(rand(3));
if ($Value > 0) {
	$LogoPath = qq!<center><a href="http://www.brokersys.com/~rwyvern/SENN/" target="NewWindow"><img src="NNB.gif" alt="Shattered Empires News Network." border=0></a></center>!;
} else {
	$LogoPath = qq!<center><a href="http://www.opticpower.com/clans/" target="NewWindow"><img src="SEC.jpg" alt="Shattered Empires dot Com." border=0></a></center>!;
}

print $LogoPath;

