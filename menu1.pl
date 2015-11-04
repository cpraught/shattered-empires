#!/usr/bin/perl
print "Content-type: text/html\n\n";

$Font = qq!<font size=-2>!;
print qqﬁ
<html>
<head>
<title>Shattered Empires</title>
<script language="JavaScript">
<!--

function dm(msgStr) {
    window.status = msgStr;
    document.MM_returnValue = true;
}

function FWFindImage(doc, name, j) {
    var theImage = false;
    if (doc.images) {
        theImage = doc.images[name];
    }
    if (theImage) {
        return theImage;
    }
    if (doc.layers) {
        for (j = 0; j < doc.layers.length; j++) {
            theImage = FWFindImage(doc.layers[j].document, name, 0);
            if (theImage) {
                return (theImage);
            }
        }
    }
    return (false);
}

// -->
</script>
<style type="text/css">
<!--
.cab {  font-family: Verdana; text-decoration: none; font-size: small; color: #FFFFFF}
-->
</style></head>

<body bgcolor="#000000" background="http://www.bluewand.com/classic/images/BGb.gif" >
<table border="0" cellpadding="0" cellspacing="0" width="100"><font size=-1>

  <tr>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="100" height="1" border="0"></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="1" border="0"></td>
  </tr>

  <tr>
   <td><img name="GameMenu_r01_c1" src="http://www.bluewand.com/classic/images/GameMenu_r01_c1.gif" width="100" height="61" border="0"></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="61" border="0"></td>
  </tr>

  <tr>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="100" height="54" border="0"></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="54" border="0"></td>
  </tr>
  <TR><td colspan=2><font size=-1><a href="urnProc.pl?$ENV{QUERY_STRING}&2" target="gamefield">$Font UIN</A></tD></tr>

  <tr>
    <td><font size=-1><a href="TurnProc.pl?$ENV{QUERY_STRING}&2" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Country Stats');return document.MM_returnValue" target="gamefield" class="cab" >$Font Country 
      Stats </a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="Newst.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('News');return document.MM_returnValue" target="gamefield" class="cab" >$Font News</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="sort.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('News');return document.MM_returnValue" target="gamefield" class="cab" >$Font Player 
      List </a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="City.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Manage Cities');return document.MM_returnValue" target="gamefield" class="cab" >$Font Manage 
      Cities </a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="NewMarket.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Buy');return document.MM_returnValue" target="gamefield" class="cab" >$Font Buy</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="NewSell.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Sell');return document.MM_returnValue" target="gamefield" class="cab" >$Font Sell</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="manufacture.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Manufacture');return document.MM_returnValue" target="gamefield" class="cab" >$Font Manufacture</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="buyresearchers.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Hire Scientists');return document.MM_returnValue" target="gamefield" class="cab" >$Font Hire 
      Scientists</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="develop1.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Develop Unit');return document.MM_returnValue" target="gamefield" class="cab" >$Font Develop Units</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="TechAssign.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Research');return document.MM_returnValue" target="gamefield" class="cab" >$Font Research</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="newdef.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Military');return document.MM_returnValue" target="gamefield" class="cab" >$Font Military</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="Message.pl?$ENV{QUERY_STRING}&101101" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Send Messages');return document.MM_returnValue" target="gamefield" class="cab" >$Font Send 
      Messages</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="Message.pl?$ENV{QUERY_STRING}&110101" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Read Messages');return document.MM_returnValue" target="gamefield" class="cab" >$Font Read 
      Messages</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="Allys.pl" onMouseOut="dm(' ');return document.MM_returnValue" onMouseOver="dm('Alliances');return document.MM_returnValue" target="gamefield" class="cab" >$Font Alliances</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="Government.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Government');return document.MM_returnValue" target="gamefield" class="cab" >$Font Government</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="TurnProc.pl?$ENV{QUERY_STRING}&1" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Process Turn');return document.MM_returnValue" target="gamefield" class="cab" >$Font Process 
      Turn</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="ingamebug.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Report a Bug');return document.MM_returnValue" target="gamefield" class="cab" >$Font Report 
      a Bug</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="100" height="10" border="0"></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="10" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="menu2.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Text Menu');return document.MM_returnValue" target="_self" class="cab" >$Font Graphic 
      Menu</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td>&nbsp;</td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="405" border="0"></td>
  </tr>
</table>
</body>
</html>
ﬁ;
