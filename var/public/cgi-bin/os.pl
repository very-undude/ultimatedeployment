#!/usr/bin/perl

sub DisplayOSList
{
  print "<CENTER>\n";
  print "<H2>Operating Systems</H2>\n";
  &PrintToolbar("New","Delete","Mount","Unmount","Drivers");
  print "<BR><BR>\n";
  print "<script language='javascript' src='/js/table.js'></script>\n";

  print "<FORM NAME=WIZARDFORM>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=none>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
  print "<INPUT TYPE=HIDDEN NAME=flavor VALUE=none>\n";
  print "<INPUT TYPE=HIDDEN NAME=os VALUE=none>\n";
  print "<script language='javascript' src='/js/os.js'></script>\n";

  print " <TABLE BORDER=1>\n";
  print "<TR CLASS=tableheader><TD>Flavor</TD><TD>OS ID</TD><TD>Operating System</TD><TD>Mounted</TD></TR>\n";

  local(%osconfig)=&GetOSHTMLConfig();
  for $curosconfig (keys(%osconfig))
  {
    print "<TR onclick='SelectRow(this)' ID='$curosconfig'>$osconfig{$curosconfig}</TR>\n";
  }
  print "</TABLE>\n";
  print "</CENTER>\n";
}

sub NewOS
{
  print "<CENTER>\n";
  print "<H2>New Operating System Wizard Step 1</H2>\n";

  print "<FORM NAME=WIZARDFORM>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
  print "<INPUT TYPE=HIDDEN NAME=step VALUE=1>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
  print "<script language='javascript' src='/js/newos.js'></script>\n";
  print "<script language='javascript' src='/js/validation.js'></script>\n";
  &PrintToolbar("Next","Cancel");
  print "<BR><BR>";
  &PrintJavascriptArray("osarray",&GetOSList());
  print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
  print "<TABLE>\n";
  print "<TR><TD>Flavor Name</TD><TD><INPUT TYPE=TEXT NAME=OSFLAVOR ID=OSFLAVOR></TD></TR>\n";
  print "<TR><TD>Operating System</TD><TD><SELECT NAME=OS ID=OS></SELECT></TD></TR>\n";
  print"</TABLE>\n";
  print "</FORM>\n";
  print "<script language='javascript'>\n";
  print "LoadValues(\"OS\",osarray);\n";
  print "</script>\n";
  print "</CENTER>\n";
}

sub DeleteOSFlavor
{
  local($flavor)=shift;

  local($result)=&UnmountOSFlavor($flavor);
  if ($result) 
  { 
    &PrintError("Could not unmount flavor $flavor");
    return 1;
  }

  local(%config)=&GetOSInfo($flavor);
  local($os)=$config{OS};

  for $mykey (keys(%config))
  {
    if ($mykey =~ /^FILE_[0-9]+/)
    {
      local($command)="rm -f $config{$mykey}";
      local($result)=&RunCommand($command,"Removing $config{$mykey}");
      if ($result)
      {
        &PrintError("Could not remove flavor file $config{$mykey}");
        return 1;
      }
    }
    if ($mykey =~ /^DIR_[0-9]+/)
    {
      local($command)="rm -rf $config{$mykey}";
      local($result)=&RunCommand($command,"Removing directory $config{$mykey}");
      if ($result)
      {
        &PrintError("Could not remove flavor directory $config{$mykey}");
        return 1;
      }
    }
  }
  local($requirefile)="$OSDIR/$os.pl";
  if ( -f $requirefile )
  {
    require "$requirefile";
    if(defined(&{$os."_DeleteOSFlavor"}))
    {
        local($result)=&{$os."_DeleteOSFlavor"}(%config);
        if ($result) 
        { 
          &PrintError("Could not remove OS specific items for $flavor");
          return 1;
        }
    } 
  }

  local($result)=&DeleteOSConfigFile($flavor);
  if ($result) 
  {
    &PrintError("Remove OS Info file for $flavor");
    return 1;
  }

  &PrintSuccess("Removed flavor $flavor");
}

sub FlavorExists()
{
  local($flavorname)=shift;
  # print "<LI>Flavor name $flavorname\n";
  local($osconffile)=$OSCONFDIR."/".$flavorname.".dat";

  # print "<LI>conffilename $osconffile\n";
  if ( -f $osconffile)
  {
    return 1;
  }
  return 0;
}

sub MountOSFlavor
{
  local($flavor)=shift;
  local(%config)=&GetOSInfo($flavor);
  local($os)=$config{OS};
  local($requirefile)="$OSDIR/$os.pl";
  if ( -f $requirefile )
  {
    require "$requirefile";
    if(defined(&{$os."_MountOSFlavor"}))
    {
        local($result)=&{$os."_MountOSFlavor"}(%config);
        if ($result) { return $result};
    } else {
      for $mykey (keys(%config))
      {
         if ($mykey =~ /^MOUNTFILE_([0-9]+)/)
         {
           local($numfile)=$1;
           local($mountfile)=$config{$mykey};
           if (defined($config{"MOUNTPOINT_".$numfile}))
           {
             local($mountpoint)=$config{"MOUNTPOINT_".$numfile};
             local($type)="iso9660";
             if (defined($config{"MOUNTTYPE_".$numfile}))
             {
               $type=$config{"MOUNTTYPE_".$numfile};
             }
             local($mountoptions)="";
             if (defined($config{"MOUNTOPTIONS_".$numfile}))
             {
               $mountoptions="-o ".$config{"MOUNTOPTIONS_".$numfile};
             }
             if ($mountoptions == "" && $type == "iso9660")
             {
               $mountoptions="-o loop";
             }
             local($command)="mount -t $type $mountoptions \\\"$mountfile\\\" \\\"$mountpoint\\\"";
             if ($type eq "rbind")
             {
               $command="mount --rbind \\\"$mountfile\\\" \\\"$mountpoint\\\"";
             }
             # print "<LI>Command = |$command|";
             &RunCommand($command,"Mounting $config{$mykey} on $mountpoint");
           } 
         }
      }
    }
  }
  return 0;
}

sub UnmountOSFlavor
{
  local($flavor)=shift;
  local(%config)=&GetOSInfo($flavor);
  local($os)=$config{OS};
  local($requirefile)="$OSDIR/$os.pl";
  if ( -f $requirefile )
  {
    require "$requirefile";
    if(defined(&{$os."_UnmountOSFlavor"}))
    {
        local($result)=&{$os."_UnmountOSFlavor"}(%config);
        if ($result) { return $result};
    } else {
      # just unmount the mountpoints mentioned in the flavorfile
      local(%mountstatus)=&GetMountStatusConfig();
      for $mykey (keys(%config))
      {
         if ($mykey =~ /^MOUNTPOINT_[0-9]+/)
         {
           if (defined($mountstatus{$config{$mykey}}))
           {
             local($command)="umount $config{$mykey}";
             local($result)=&RunCommand($command,"unmounting $mykey on $config{$mykey} for flavor $flavor");
             if ($result) 
             {
               &PrintError("Could not unmount $config{$mykey}");
               return 1;
             }
           }
         }
      }
    }
  }
  return 0;
}

sub Generic_GetMountStatus
{
  local($flavor,%status)=@_;
  local(%config)=&GetOSInfo($flavor);
  for $mykey (keys(%config))
  {
     if ($mykey =~ /^MOUNTPOINT_([0-9]+)/)
     {
        if (!defined($status{$config{$mykey}}))
        {
          return 1;
        }
     }
  }
  return 0;
}

sub MountFlavorsBoottime
{
  local(@flavorlist)=&GetOSFlavorList();
  for $item (@flavorlist)
  {
    local($os,$flavor)=split(";",$item);
    local(%curconfig)=&GetOSInfo($flavor);
    if ($curconfig{MOUNTONBOOT} eq "TRUE")
    {
       print "Mounting flavor $flavor ($os)\n";
       &MountOSFlavor($flavor);
    }
  }
}

1;
