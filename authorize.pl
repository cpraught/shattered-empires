#!/usr/bin/perl
require 'quickies.pl'

print "Content-type: text/html\n\n";

$user_information = $MasterPath . "/User Information";
$worlddir= $MasterPath . "/se/Planets/";

&parse_form;
$data{'handle'} =~ tr/ /_/;
&check_code;
&CountOff;
&multipleaccounts;
&display_html;
$PlanPath = $MasterPath;

sub CountOff {
	opendir (DIR, "$worlddir");
	@Worlds = readdir (DIR);
	closedir (DIR);
	foreach $Item (@Worlds) {
		if ($Item ne '.' and $Item ne '..') {
			open (DIR, "$worlddir/$Item");
			@Countries = readdir (DIR);
			closedir (DIR);
			foreach $Name (@Countries) {
				$Name =~ tr/_/ /;
				if ($Name eq $data{'handle'}) {$Warning = 1}
			}
		}
	}

	if ($Warning == 1) {
		&display_no;
		die;
	}
}

sub display_no {
	print qq!

<html>
  <body background="../Background.jpg">
  <font face=arial color=white>

  <table width=70% height=85% border=0>
      <TR>
          <TD valign=middle align=middle>

	<Table border=1 width=598 height=398 cellspacing=0 cellpadding=0 bgcolor=white bordercolor=#B3B5FF>
	<TR><TD valign=top><font face=verdana<BR><BR><div align=justify>

<center><img src=../images/SEC.jpg border=0><BR><BR></center>


<BODY BGCOLOR="black" text="white">
<font face=verdana size=-1><BR><BR><BR><Center>A Country with this authorization number already exists.</center>
       </TD>
    </tR>
  </table>

	</TD></TR>
	</table>
          </td>
      </TR>
  </table>
  </body>
</html>!;

}



sub multipleaccounts {
	dbmopen(%email, "$user_information/emailaddress", 0777);
	dbmopen(%planet, "$user_information/planet", 0777);
	$Address = $email{$data{'handle'}};
	foreach $k (keys(%email)){
		if($email{$k} eq $Address and $Address ne "chris\@blueand.com"){
			if (substr($planet{$k},0,9) eq "SystemOne") {$Sys1++}
			if (substr($planet{$k},0,9) eq "SystemTwo") {$Sys2++}
		}
	}
	dbmclose(%email);
	dbmclose(%planet);
}



sub check_code{
	dbmopen(%datain, "$user_information/accesscode", 0777);
	if ($datain{$data{'handle'}} ne $data{'author'}) {
		print "<SCRIPT>alert(\"Sorry, That code does not match the one on record.\")\;history.back()</SCRIPT>";
		dbmclose(%datain);
		die;
	}
	dbmclose(%datain);
}



sub display_html{
	dbmopen(%email, "$user_information/emailaddress", 0777);
	$email=$email{$data{'handle'}};
	dbmclose(%email);
	$data{'handle'} =~ tr/_/ /;
	print qqô
<html>

  <head>
    <title>SE Classic Creation</title>
  </head>

  <style>
    A:link { text-decoration: none; color: rgb(00,51,102) }
    A:visited { text-decoration: none; color: rgb(00,51,102) }
    A:hover { text-decoration: none; color: rgb(244,195,0) }
  </style>
 
  <body bgcolor=white>

  <table width=100% cellpadding=0 cellspacing=0>
    <tr>
      <td valign=top width=100%>

      <br>

      <table cellpadding=0 cellspacing=0 border=0 width=95% align=center>
        <tr>
          <td width=44><img src="http://www.bluewand.com/images/general/sections/seclassic-left.jpg" border=0></img></td>
          <td><img src="http://www.bluewand.com/images/general/sections/seclassic-right.jpg" border=0></img></td>  
          <td width=44></td>
        </tr>

        <tr>
          <td width=44 background="http://www.bluewand.com/images/general/bodytable/bg.jpg"></td>
          <td><br><br><br></td>
          <td width=44></td>
        </tr>


        <tr>
          <td width=44><img src="http://www.bluewand.com/images/general/bodytable/subheader-left.jpg"></img></td>
          <td background="http://www.bluewand.com/images/general/bodytable/subheader-bg.jpg">
            <font face=arial size=3 color=#04077E><b>Create SE: Classic Account - Step 3</b></font>
          </td>
          <td width=44><img src="http://www.bluewand.com/images/general/bodytable/subheader-right.jpg"></img></td>
        </tr>
        <tr>
          <td width=44 background="http://www.bluewand.com/images/general/bodytable/bg.jpg"></td>
          <td>
            <br>

             <form method=POST action="http://www.bluewand.com/cgi-bin/classic/createuser.pl">

               <table border=0 cellspacing=0>
                 <tr>
                   <td><div align=right><font face=arial size=2 color=#003366><b>Country Name:</b></font></div></td>
                   <td><font face=arial size=2><input type="HIDDEN" name="handle" align="ABSMIDDLE" maxlength="20" size="25" value="$data{'handle'}">$data{'handle'}</font></td>
                 </tr>
                 <tr>
                   <td><div align=right><font face=arial size=2 color=#003366><b>Full Name (yours):</b></font></div></td>
                   <td><font face=arial size=2><input type=text maxsize=20 size=18 name=realname></font></td>
                 </tr>                
                 <tr>
                   <td><div align=right><font face=arial size=2 color=#003366><b>ICQ:</b></font></div></td>
                   <td><font face=arial size=2><input type=text maxsize=20 size=18 name=ICQ></font></td>
                 </tr>                
                 <tr>
                   <td><div align=right><font face=arial size=2 color=#003366><b>Leader Name:</b></font></div></td>
                   <td><font face=arial size=2><input type=text maxsize=20 size=18 name=user></font></td>
                 </tr>                
                 <tr>
                   <td><div align=right><font face=arial size=2 color=#003366><b>Password:</b></font></div></td>
                   <td><font face=arial size=2><input type=password maxsize=20 size=18 name=password></font></td>
                 </tr>                
                 <tr>
                   <td><div align=right><font face=arial size=2 color=#003366><b>Confirm Password:</b></font></div></td>
                   <td><font face=arial size=2><input type=password maxsize=20 size=18 name=password2></font></td>
                 </tr>
                 <tr>
                   <td><br><div align=right><font face=arial size=2 color=#003366><b>World:</b></font></div></td>
                   <td><br><font face=arial size=2><select name="planet" size="1"><option value="none">No Planet Selected</option>ô;
chdir ("$worlddir");
opendir (DIR, '.');

@world = readdir (DIR);
closedir (DIR);
$Sys1 = 0;
$Sys2 = 0;
foreach $planet (@world){
	unless (-e "$PlanPath/$planet.pln") {NEXT}

	if ($Sys1 < 1) {
		$Val = substr($planet,0,9);
		if (substr($planet,0,9) eq "SystemOne" and $SysOne == 0) {
			open (DAT, $MasterPath . "/se/$planet.pln");
			$num = <DAT>;
			close (DAT);
			chdir ("$worlddir$planet/users/");

			if ($num < 600) {
				unless ($planet =~ m/earth/i) {
					print qq!<OPTION VALUE="$planet">$planet!;
					$SysOne++;
				}
			}
		}
	}
	if ($Sys2 < 1) {
		if (substr($planet,0,9) eq "SystemTwo" and $SysTwo == 0) {
			open (DAT, $MasterPath . "/se/$planet.pln");
			$num = <DAT>;
			close (DAT);
			chdir ("$worlddir$planet/users/");
			if ($num < 600) {
				unless ($planet =~ m/terra/i) {
					print qq!<OPTION VALUE="$planet">$planet!;
					$SysTwo++;
				}
			}
		}
	}
}
print qqô
</select></font></td>
                 </tr>
                 <tr>
                   <td><br><div align=right><font face=arial size=2 color=#003366><b>Government Type:</b></font></div></td>
                   <td><br><font face=arial size=2><select name="govtype" size="1"><OPTION selected VALUE="DE">Democracy</option><OPTION VALUE="DI">Dictatorship</option><OPTION VALUE="TH">Theocracy</option><OPTION VALUE="MO">Monarchy</option><OPTION VALUE="RE">Republic</option></select></font></td>
                 </tr> 
                 <tr>
                   <td><div align=right><font face=arial size=2 color=#003366><b>Economic Model:</b></font></div></td>
                   <td><font face=arial size=2><select name="econtype" size="1"><OPTION selected VALUE="CA">Capitalism</option><OPTION VALUE="FA">Fascism</option><OPTION VALUE="ME">Mercantalism</option><OPTION VALUE="CO">Socialism</option></select></font></td>
                 </tr>                  
                 <tr>
                   <td><br><div align=right><font face=arial size=2 color=#003366><b>Capital:</b></font></div></td>
                   <td><br><font face=arial color=#003366 size=2><input type=text name=capital value="" size=15 maxsize=15> <b>Coastal?</b><input type="checkbox" name=capitalport value="Yes"></font></td>
                 </tr>
                 <tr>
                   <td><div align=right><font face=arial size=2 color=#003366><b>Colony 1:</b></font></div></td>
                   <td><font face=arial color=#003366 size=2><input type=text name=colony1 value="" size=15 maxsize=15> <b>Coastal?</b><input type="checkbox" name=colony1port value="Yes"></font></td>
                 </tr>
                 <tr>
                   <td><div align=right><font face=arial size=2 color=#003366><b>Colony 2:</b></font></div></td>
                   <td><font face=arial color=#003366 size=2><input type=text name=colony2 value="" size=15 maxsize=15> <b>Coastal?</b><input type="checkbox" name=colony2port value="Yes"></font></td>
                 </tr>
                <tr>
                   <td colspan=2><br><center><input type=submit name=submit value="Enter"></center></td>
                </tr>

              </table>

              </form>

            <br>
          </td>
          <td width=44></td>
        </tr>

        <tr>
          <td width=44><img src="http://www.bluewand.com/images/general/bodytable/subheader-left.jpg"></img></td>
          <td background="http://www.bluewand.com/images/general/bodytable/subheader-bg.jpg">
            <a name="creationhelp"></a>
            <font face=arial size=3 color=#04077E><b>Creation Help</b></font>
          </td>
          <td width=44><img src="http://www.bluewand.com/images/general/bodytable/subheader-right.jpg"></img></td>
        </tr>
        <tr>
          <td width=44 background="http://www.bluewand.com/images/general/bodytable/bg.jpg"></td>
          <td>
            <br>
            <font face=arial size=2 color=black>
               The SE: Classic account creation is a three step process:
                 <br><br>
              <a href="seclassiccreate1.php"><b>[ Step 1: Primary ]</b></a>
                 <br>
              Enter a country name and correct E-mail Address, an authentication code will be set to that E-mail address which is needed in step 2.
                 <br><br>
              <a href="seclassiccreate2.php"><b>[ Step 2: Validation ]</b></a>
                 <br>
              Enter your same country name and the authentication code you received in the E-mail sent to you from Bluewand.
                 <br><br>
              <font color=#003366><b>Step 3: Game Information</b></font></a>
                 <br>
              Now that you have been authenticated you can enter all of your country information.  After completing this you can begin playing SE: Classic!
            </font>
            <br><br><br>
          </td>
          <td width=44></td>
        </tr>

        <tr>
          <td width=44><img src="http://www.bluewand.com/images/general/bodytable/bottom.jpg"></img></td>
          <td></td>
          <td width=44></td>
        </tr>

      </table>


      </td>
  
      <td valign=top>
  
            <table cellpadding=0 cellspacing=0 align=right>
        <tr>
          <td><img src="http://www.bluewand.com/images/general/rightbar/topleft.jpg"></img></td>
          <td background="http://www.bluewand.com/images/general/rightbar/topright-bg.jpg" valign=top>

            <br>         
            <img src="http://www.bluewand.com/images/general/rightbar/quicklogin.jpg"></img>

            <center>     
            <font face=arial color=black size="-2"><b><i>...Coming Soon...</i></b></font>
            </center>

            <br><br>
            <img src="http://www.bluewand.com/images/general/rightbar/latestnews.jpg"></img>

            <center>
 
            <font face=arial size="-2"><b>
            <a href="news.php#newspost01">[ Brand Spanking New Layout! ]</a>
            </b></font> 
 
            </center>

            <br><br>
            <img src="http://www.bluewand.com/images/general/rightbar/quicklinks.jpg"></img>

            <center>

            <font face=arial size="-2"><b>
            <a href="seclassic.php">[ SE: Classic ]</a>
            </b></font>
              <br>
            <font face=arial size="-2"><b>
            <a href="ash.php">[ ASH ]</a>
            </b></font> 

            </center>

          </td>
        </tr>
        <tr>
          <td><img src="http://www.bluewand.com/images/general/rightbar/bottomleft.jpg"></img></td>
          <td><img src="http://www.bluewand.com/images/general/rightbar/bottomright.jpg"></img></td>
        </tr>
      </table>

      </td>
    </tr>
  </table>

  <br>

  </body>

</html>
ô;
}





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
