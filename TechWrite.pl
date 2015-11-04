#!/usr/bin/perl
require 'quickies.pl'

($User,$Planet,$AuthCode)=split(/&/,$ENV{QUERY_STRING});

$user_information = $MasterPath . "/User Information";
dbmopen(%authCode, "$user_information/accesscode", 0777);
if(($AuthCode ne $authCode{$User}) || ($AuthCode eq "")){
	print "<SCRIPT>alert(\"Security Failure.  Please notify the GSD team immediately.\");history.back();</SCRIPT>";
	die;
}
dbmclose(%authCode);

#New Tech Format - (Player) - Name|Points|PointsRequired|Type1|Type2|Type3|Type4|Tech1|Tech2|Tech3|Tech4
#New Tech Format - (Index)  - Name|PointsRequired|Tech1|Tech2|Tech3|Tech4

$Type{'0'} = "Scholars";
$Type{'1'} = "Technicans";
$Type{'2'} = "Engineers";
$Type{'3'} = "Scientists";
&parse_form;

$ResearchPath = $MasterPath . "/research";
$PlayerPath = $MasterPath . "/se/Planets/$Planet/users/$User";
$PlayerTechPath = $MasterPath . "/se/Planets/$Planet/users/$User/research";

open (DATAIN, "$PlayerPath/research.txt");
@SciType = <DATAIN>;
close (DATAIN);
&chopper (@SciType);

if ($SciType[0] < 1) {$SciType[0] = 0}
if ($SciType[1] < 1) {$SciType[1] = 0}
if ($SciType[2] < 1) {$SciType[2] = 0}
if ($SciType[3] < 1) {$SciType[3] = 0}

	open (IN, "$PlayerTechPath/TechData.tk");
	flock (IN, 1);
	@TechData = <IN>;
	close (IN);
	&chopper (@TechData);

	open (IN, "$ResearchPath/TechData.tkF");
	flock (IN, 1);
	@CompleteTechData = <IN>;
	close (IN);
	&chopper (@CompleteTechData);

	#Index Technologies
	foreach $Tech (@TechData) {
		$Storage{@TechData[1]} = 1;
	}

	foreach $RemoveTech (keys(%data)) {
		push (@TechNames,(substr($RemoveTech,0,length($RemoveTech)-1)));
	}

	foreach $Item (@TechData) {
		(@TechLine) = split(/\|/,$Item);
		my $Num = 0;

		while ($Num < 4) {
			if ($SciType[$Num] >= (abs($data{"$TechLine[1]$Num"}) + $RunningTotal[$Num])) {
				$TechLine[4 + $Num] = abs($data{"$TechLine[1]$Num"});
				$RunningTotal[$Num] += abs($data{"$TechLine[1]$Num"});
			} else {
				$TechLine[4 + $Num] = 0;
			}
			$Num++;
		}
		$Item = "";
		$CounterLine = 0;
		while ($CounterLine < scalar(@TechLine)) {
			$Item .= qq!@TechLine[$CounterLine]|!;
			$CounterLine++;
		}
		push (@Used, @TechLine[1]);
		push (@FinishedTech, $Item);
	}

	#Sci assignment for new techs
	foreach $NewTech (@TechNames) {
		$Flag = 0;
		$LastInfoSave = "";

		#If tech is previously discovered, flag as old
		foreach $OldTech (@Used) {
			if ($OldTech eq $NewTech) {$Flag = 1}
		}

		#if tech is flagged as new, continue
		if ($Flag == 0) {
			my @NewTechLine = ();
			my $Num = 0;

			#loop through diff sci types
			while ($Num < 4) {
				#if there are more total scientists than there are scientists used, allow assignment
				if ($SciType[$Num] >= abs($data{"$NewTech$Num"}) + $RunningTotal[$Num]) {
					@NewTechLine[3 + $Num] = abs($data{"$NewTech$Num"});
					$RunningTotal[$Num] += abs($data{"$NewTech$Num"})
				} else {
					@NewTechLine[3 + $Num] = 0;
				}

				$Num++;
			}

			foreach $LastInfo (@CompleteTechData) {
				(@TechLine) = split(/\|/,$LastInfo);
				if (@TechLine[0] eq $NewTech) {$LastInfoSave = $LastInfo;}
				
			}
			if ($LastInfoSave ne "") {
				(@TechLine) = split(/\|/,$LastInfoSave);
				$Item = qq!0|$NewTech|0|@TechLine[1]|$NewTechLine[3]|$NewTechLine[4]|$NewTechLine[5]|$NewTechLine[6]|$TechLine[2]|$TechLine[3]|$TechLine[4]|$TechLine[5]|!;
				push (@FinishedTech, $Item);
				push (@Used, @TechLine[1]);
			}
		}
	}

	open (OUT, ">$PlayerTechPath/TechData.tk");
	flock (OUT, 2);

	foreach $Writer (@FinishedTech) {
		print OUT "$Writer\n";
	}
	close (OUT);


open (OUT, ">$PlayerPath/UsedTech.txt");
foreach $Item (@RunningTotal) {
	print OUT "$Item\n";
}
close (OUT);


print "Location: http://www.bluewand.com/cgi-bin/classic/TechAssign.pl?$User&$Planet&$AuthCode\r\n\r\n";


#sub chopper{
#	foreach $k(@_) {
#		chop($k);
#	}
#}

sub parse_form {

   # Get the input
   read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});

   # Split the name-value pairs
   @pairs = split(/&/, $buffer);

   foreach $pair (@pairs) {
      ($name, $value) = split(/=/, $pair);

      # Un-Webify plus signs and %-encoding
      $value =~ tr/+/ /;
      $value =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("C", hex($1))/eg;
      $value =~ s/<!--(.|\n)*-->//g;
      $value =~ s/<([^>]|\n)*>//g;
         
      

      $data{$name} = $value;
      }
}


