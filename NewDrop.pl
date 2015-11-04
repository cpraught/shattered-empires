#!/usr/bin/perl

$Path = "/home/admin/www/cgi-bin/classic";

opendir (DIR, ".");
@Files = readdir (DIR);
closedir (DIR);

foreach $Item (@Files) {
  print "$Item - ";

  if ($Item ne "NewDrop.pl") {
     $NewName = substr($Item,0, length($Item)-4);
     print "$NewName\n";
     rename $Item, $NewName;
  }
}

