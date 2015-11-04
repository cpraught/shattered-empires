sub Smarts {
	if ($TotalHealth > 0)
	{

		my $VarOne = ($Population / $Desks);
		my $VarTwo = $Educated;

		if ($VarTwo > 1.15) {$VarTwo == 1.15;}
		if ($VarOne == 0) {$Literate = 0;} else {$Literate = (($Schools) / ($VarOne)) * $VarTwo;}
		if ($Literate > 1) {$Literate = 1;}
		if ($User =~ /$Zha/) {

			print qq!$VarOne = $Population / $Desks)<BR>!;
			print qq!$Literate = ($Schools) / ($VarOne) * $VarTwo<BR>!;
		}
	} else {$Literate = 0;}

	$Literate = ($Literate * $Educated * (1/4)) + (@CountryData[4]/100 * (3/4));
	if ($User =~ /$Zha/) {
		print qq!City: $Name Smarts: $Literate = ($Literate * $Educated) + (@CountryData[4]/100 * (3/4))<BR><BR><BR>!;
	}
	if ($Literate > 1) {$Literate = 1;}
	if ($Literate < 0) {$Literate = 0;}
}


