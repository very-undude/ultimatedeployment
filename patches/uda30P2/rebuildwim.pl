#!/usr/bin/perl

unshift ( @INC,"/var/public/cgi-bin");
unshift ( @INC,"/var/public/cgi-bin/os");

require "general.pl";
require "config.pl";
require "action.pl";
require "os.pl";
require "windows7.pl";

local(@flavors)=&GetOSFlavorList();
for $theflavor (@flavors)
{
  print ("Checking flavor $theflavor\n");
  if ($theflavor =~ /windows7;(.*)/)
  {
    my($flavor)=$1;
    print ("  Found windows flavor $flavor\n");
    local(%osinfo)=GetOSInfo($flavor);
    local($sourcedir)=$osinfo{MOUNTPOINT_1}."/sources";
    if (! -d $sourcedir)
    {
      $sourcedir=$osinfo{MOUNTPOINT_1}."/SOURCES";
      if (! -d $sourcedir)
      {
        print("    Sourcedir $sourcedir was not found for flavor $flavor\n");
        next;
      }
    }
    local($result)=&windows7_CreateWim(0,$sourcedir,$osinfo{DIR_1},$osinfo{SORTEDDRIVERS},$args{ACTIVEDRIVERS});
    if ($result)
    {
      print ("    Creating wim for flavor $flavor failed\n");
      next;
    } else {
      print ("    Creating wim for flavor $flavor was succesfull\n");
    }
  } else {
    print ("  Skipping non-windows flavor $flavor\n");
  }
}
