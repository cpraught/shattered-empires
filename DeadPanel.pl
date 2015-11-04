#!/usr/bin/perl
print "Content-type: text/html\n\n";

if (grep(/Carsus/, $ENV{QUERY_STRING}) == 1) {$Pass = 1}
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
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="100" height="54" border="0"></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="54" border="0"></td>
  </tr>
<BR><BR><BR>
  <tr>
    <td><font size=-1><a href="Newst.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('News');return document.MM_returnValue" target="gamefield" class="cab" >News</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="sort.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('News');return document.MM_returnValue" target="gamefield" class="cab" >Player 
      List </a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="Message.pl?$ENV{QUERY_STRING}&101101" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Send Messages');return document.MM_returnValue" target="gamefield" class="cab" >Send 
      Messages</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
    <td><font size=-1><a href="Message.pl?$ENV{QUERY_STRING}&110101" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Read Messages');return document.MM_returnValue" target="gamefield" class="cab" >Read 
      Messages</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>
  <tr>
    <td><font size=-1><a href="ingamebug.pl?$ENV{QUERY_STRING}" onMouseOut="dm(' ');return document.MM_returnValue"  onMouseOver="dm('Report a Bug');return document.MM_returnValue" target="gamefield" class="cab" >Report 
      a Bug</a></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="15" border="0"></td>
  </tr>

  <tr>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="100" height="10" border="0"></td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="10" border="0"></td>
  </tr>

  <tr>
    <td>&nbsp;</td>
   <td><img src="http://www.bluewand.com/classic/images/shim.gif" width="1" height="405" border="0"></td>
  </tr>
</table>
</body>
</html>
ﬁ;
