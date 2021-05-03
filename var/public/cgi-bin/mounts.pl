#!/usr/bin/perl

sub DisplayMountList
{
  print "<CENTER>\n";
  print "<H2>Storage</H2>\n";
  &PrintToolbar("New","Delete","Mount","Unmount","Configure");
  print "<script language='javascript' src='/js/table.js'></script>\n";
  print "<script language='javascript' src='/js/mountlist.js'></script>\n";
  print "<BR>\n";
  print " <TABLE BORDER=1>\n";
  print "<TR CLASS=tableheader><TD>Name</TD><TD>Type</TD><TD>Hostname</TD><TD>Location</TD><TD>Mount on Boot</TD><TD>Status</TD></TR>\n";

  local(%mountconfig)=&GetMountHTMLConfig($MOUNTSCONF);
  local(%currentmounts)=&GetMountStatusConfig();

  for $curmountconfig (keys(%mountconfig))
  {
    local($mountstatus)="Not Mounted";
    if ($curmountconfig eq "local" && defined($currentmounts{"/local"}))
    {
      $mountstatus="Mounted";
    }
    if (defined($currentmounts{"$SMBMOUNTDIR/".$curmountconfig}))
    {
      $mountstatus="Mounted";
    }
    print "<TR onclick='SelectRow(this)' ID=$curmountconfig>$mountconfig{$curmountconfig}<TD>$mountstatus</TD></TR>\n";
  }
  print "</TABLE>\n";
  print "</CENTER>\n";
}

sub NewMount
{
  print "<CENTER>\n";
  print "<H2>Create New Mount</H2>\n";
  &PrintToolbar("Apply","Cancel");
  &PrintJavascriptArray("mounttypearray",@MOUNTTYPES);
  print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
  print "<script language='javascript' src='/js/mounts.js'></script>\n";
  print "<script language='javascript' src='/js/newmount.js'></script>\n";
  print "<BR>\n";
  print "<FORM NAME=NEWMOUNTFORM METHOD=POST ACTION='uda3.pl'>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE='mounts'>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE='applynew'>\n";

  print " <TABLE>\n";
  print "<TR><TD>Name</TD><TD><INPUT TYPE=TEXT NAME=MOUNT></TD></TR>\n";
  print "<TR><TD>Type</TD><TD><SELECT NAME=TYPE ID=MOUNTTYPE ONCHANGE='EnableDisableMountOptions(\"MOUNTTYPE\");'></SELECT></TD></TR>\n";
  print "<TR><TD>Hostname/IP</TD><TD><INPUT TYPE=TEXT NAME=HOSTNAME></TD></TR>\n";
  print "<TR><TD>Sharename</TD><TD><INPUT TYPE=TEXT NAME=SHARE></TD></TR>\n";
  print "<TR><TD>Mount on boot</TD><TD><INPUT TYPE=CHECKBOX NAME=MOUNTONBOOT CHECKED></TD></TR>\n";
  print " </TABLE>\n";
  print "<DIV ID=CIFS_DIV STYLE=\"display:none\">\n";
  print "<H3>Windows share options</H3>\n";
  print " <TABLE>\n";
  print "<TR><TD>Username</TD><TD><INPUT TYPE=TEXT NAME=USERNAME></TD></TR>\n";
  print "<TR><TD>Password</TD><TD><INPUT TYPE=TEXT NAME=PASSWORD></TD></TR>\n";
  print "<TR><TD>Domain</TD><TD><INPUT TYPE=TEXT NAME=DOMAIN></TD></TR>\n";
  print " </TABLE>\n";
  print "</DIV>\n";
  
  print "</FORM>\n";
  print "<script language='javascript'>\n";
  print "LoadValues(\"MOUNTTYPE\",mounttypearray);\n";
  print "EnableDisableMountOptions(\"MOUNTTYPE\");\n";
  print "</script>\n";

  return 0;
}

sub ConfigureMount
{
  local($mount)=shift;
  local(%info)=&GetMountInfo($mount);
  local($checked)="";
  if ($info{MOUNTONBOOT}=="TRUE")
  {
    $checked="CHECKED";
  }
  print "<CENTER>\n";
  print "<H2>Edit Mount $mount</H2>\n";
  &PrintToolbar("Apply","Cancel");
  &PrintJavascriptArray("mounttypearray",@MOUNTTYPES);
  print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
  print "<script language='javascript' src='/js/mounts.js'></script>\n";
  print "<script language='javascript' src='/js/editmount.js'></script>\n";
  print "<BR>\n";
  print "<FORM NAME=NEWMOUNTFORM METHOD=POST ACTION='uda3.pl'>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE='mounts'>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE='applyconfigure'>\n";
  print "<INPUT TYPE=HIDDEN NAME=MOUNT VALUE='$info{MOUNT}'>\n";
  print " <TABLE>\n";
  print "<TR><TD>Name</TD><TD>$info{MOUNT}</TD></TR>\n";
  print "<TR><TD>Type</TD><TD><SELECT NAME=TYPE ID=MOUNTTYPE ONCHANGE='EnableDisableMountOptions(\"MOUNTTYPE\");'></SELECT></TD></TR>\n";
  print "<TR><TD>Hostname/IP</TD><TD><INPUT TYPE=TEXT NAME=HOSTNAME VALUE='$info{HOSTNAME}'></TD></TR>\n";
  print "<TR><TD>Sharename</TD><TD><INPUT TYPE=TEXT NAME=SHARE VALUE='$info{SHARE}'></TD></TR>\n";
  print "<TR><TD>Mount on boot</TD><TD><INPUT TYPE=CHECKBOX NAME=MOUNTONBOOT $checked></TD></TR>\n";
  print " </TABLE>\n";
  print "<DIV ID=CIFS_DIV STYLE=\"display:none\">\n";
  print "<H3>Windows share options</H3>\n";
  print " <TABLE>\n";
  print "<TR><TD>Username</TD><TD><INPUT TYPE=TEXT NAME=USERNAME VALUE='$info{USERNAME}'></TD></TR>\n";
  print "<TR><TD>Password</TD><TD><INPUT TYPE=TEXT NAME=PASSWORD VALUE='$info{PASSWORD}'></TD></TR>\n";
  print "<TR><TD>Domain</TD><TD><INPUT TYPE=TEXT NAME=DOMAIN VALUE='$ifor{DOMAIN}'></TD></TR>\n";
  print " </TABLE>\n";
  print "</DIV>\n";
  print "</FORM>\n";
  print "<script language='javascript'>\n";
  print "LoadValues(\"MOUNTTYPE\",mounttypearray);\n";
  print "document.getElementById(\"MOUNTTYPE\").value=\"$info{TYPE}\";\n";
  print "EnableDisableMountOptions(\"MOUNTTYPE\");\n";
  print "</script>\n";

  return 0;
}

sub ApplyConfigureMount
{
  local($mountname,$mounttype,$hostname,$sharename,$username,$password,$domain)=@_;

  local($result)=&UnmountMount($mountname);
  if ($result)
  {
    &PrintError("Could not unmount the current mount $mountname");
    return;
  }

  local($result)=&ApplyNewMount($mountname,$mounttype,$hostname,$sharename,$username,$password,$domain);
  if ($result)
  {
    &PrintError("Could not apply mount configuration for $sharename");
    return $result;
  }
  # &DisplayMountList();
  return 0;
}

sub ApplyNewMount
{
  local($mountname,$mounttype,$hostname,$sharename,$username,$password,$domain)=@_;
  local(%confighash)=();
  $confighash{MOUNT}=$formdata{MOUNT};
  $confighash{HOSTNAME}=$formdata{HOSTNAME};
  $confighash{SHARE}=$formdata{SHARE};
  $confighash{TYPE}=$formdata{TYPE};
  if (defined($formdata{MOUNTONBOOT}))
  {
    $confighash{MOUNTONBOOT}="TRUE";
  } else {
    $confighash{MOUNTONBOOT}="FALSE";
  }

  if ($confighash{TYPE} eq "CIFS")
  {
    $confighash{USERNAME}=$formdata{USERNAME};
    $confighash{PASSWORD}=$formdata{PASSWORD};
    $confighash{DOMAIN}=$formdata{DOMAIN};
  }
  
  local($result)=&CreateDir("$SMBMOUNTDIR/$confighash{MOUNT}");
  if ($result) { return $result } ;

  local($result)=&WriteMountInfo(%confighash);
  if ($result) { return $result } ;

  local($result)=&MountMount($confighash{MOUNT});
  if ($result) { return $result } ;

  if ($confighash{TYPE} eq "CIFS")
  {
    local($testfile)="$SMBMOUNTDIR/$config{MOUNT}/.testfile.$$";
    local($command)="touch $testfile"; 
    local($result)=&RunCommand($command,"Trying write permissions on $SMBMOUNTDIR/$config{MOUNT}");
    if ($result)
    {
        &PrintError("Could not create a file on the cifs share $config{SHARE}","I need write permissions to be able to mount an ISO on there");
        return 1;
    } else {
       local($command)="rm -f $testfile";
       local($result)=&RunCommand($command,"Removing testfile $testfile");
    }
  }

  return 0;
}

sub DeleteMount
{
  local($mount)=@_;
  # print "Deleting Mount |$mount|\n";

  local($result)=&UnmountMount($mount);
  if ($result ne 0) 
  {
    print "<LI>Could not unmount the mount";
  }

  local($result)=&DeleteMountConfigFile($mount);
  if ($result ne 0) 
  {
    print "<LI>Mount not currently defined";
  }

  return 0;
}

sub GetMountConfigHash
{
  local($line)=@_;
  local(%mounthash)=();
  local(@lineinfo)=split(";",$line);

  $mounthash{MOUNTTYPE}=$lineinfo[0];
  $mounthash{MOUNTNAME}=$lineinfo[1];
  $mounthash{HOSTNAME}=$lineinfo[2];
  $mounthash{SHARENAME}=$lineinfo[3];
  $mounthash{USERNAME}=$lineinfo[4];
  $mounthash{PASSWORD}=$lineinfo[5];
  $mounthash{DOMAIN}=$lineinfo[6];
  $mounthash{DESCRIPTION}=$lineinfo[7];

  return(%mounthash);
}


sub MountMount
{
  local($mount)=@_;

  local(%config)=&GetMountInfo($mount);
  if (defined($config{MOUNT}))
  {
    local(%status)=&GetMountStatusConfig();
    if (!defined($status{"$SMBMOUNTDIR/".$mount}))
    {
      if ($config{TYPE} eq "LOCAL")
      {
        local($command)="mount -t xfs /dev/mapper/udavg-locallv /local";
        &RunCommand($command,"Mounting ext3 share $mount:");
      } elsif ($config{TYPE} eq "CIFS") {
        local($domainstring)="";
        if (defined($config{DOMAIN}) && $config{DOMAIN} ne "")
        {
          $domainstring=",domain=$config{DOMAIN}";
        }
        $config{PASSWORD} =~ s/\(/\\\(/g;
        $config{PASSWORD} =~ s/\)/\\\)/g;
        $config{PASSWORD} =~ s/\{/\\\{/g;
        $config{PASSWORD} =~ s/\}/\\\}/g;

        local($command)="mount -t cifs -o user=$config{USERNAME},pass=$config{PASSWORD}$domainstring //$config{HOSTNAME}/$config{SHARE} $SMBMOUNTDIR/$config{MOUNT}";
        local($result)=&RunCommand($command,"Mounting cifs share $mount:");
        if ($result) { return $result; }
    
      } elsif ($config{TYPE} eq "NFS") {
        local($command)="mount -t nfs -o vers=3,ro $config{HOSTNAME}:$config{SHARE} $SMBMOUNTDIR/$config{MOUNT}";
        &RunCommand($command,"Mounting nfs share $mount:");
      } elsif ($config{TYPE} eq "CDROM") {
        local($command)="mount -t iso9660 -o loop $config{SHARE} $SMBMOUNTDIR/$config{MOUNT}";
        &RunCommand($command,"Mounting nfs share $mount:");
      }
    }
  }

  return 0;
}

sub UnmountMount
{
  local($mount)=@_;

  # Getting this mounts configuration
  local(%config)=&GetMountInfo($mount);
  if (defined($config{MOUNT}))
  {
    # Checking current mount status
    local(%status)=&GetMountStatusConfig();
    if (defined($status{"$SMBMOUNTDIR/".$mount}) || $mount eq "local" )
    {
      for $submount (keys(%status))
      {
        local($mymount,$mymountpoint,$mytype,$myoptions)=split(";",$status{$submount});
        if($mymount =~ /\/var\/public\/smbmount\/$mount\// || $mymount =~ /\/local/)
        {
          local($command)="umount $submount";
          &RunCommand($command,"Unmounting mount $submount","debug");
        }
      }
      
      local($command)="umount $SMBMOUNTDIR/$mount";
      if ($mount eq "local")
      {
        $command = "umount /local";
      }
      local($result)=&RunCommand($command,"Unmounting mount $mount");
    } 
  }

  return 0;
}

sub MountMountsBoottime
{
  require "config.pl";
  local(%mountconfig)=&GetMountHTMLConfig($MOUNTSCONF);
  for $curmount (keys(%mountconfig))
  {
    local(%info)=&GetMountInfo($curmount);
    if ($info{MOUNTONBOOT} eq "TRUE")
    {
      print "Mounting mount $curmount\n";
      &MountMount($curmount);
    }
  }
  return 0;
}

sub GetCurrentCDDeviceList
{
  local(@info)=();
  local(@result)=`ls -1 /dev/hd*`;
  for $cdrom (@result)
  {
    if ($cdrom =~ /\/dev\/(hd.*)/)
    {
      local($device)=$1;
      push(@info,$device);
    }
  }
  return (@info);
}

sub RemoveAllCDMounts
{
  local(%mountconfig)=&GetMountHTMLConfig($MOUNTSCONF);
  for $curmount (keys(%mountconfig))
  {
    local(%info)=&GetMountInfo($curmount);
    if ($info{TYPE} eq "CDROM")
    {
      print "Removing CDROM mount $curmount\n";
      &DeleteMountConfigFile($curmount);
    }
  }
  return 0;
}

sub CreateCDMounts
{
  require "config.pl";
  local(@devlist)=&GetCurrentCDDeviceList();
  local($i)=0;
  for $device (@devlist)
  {
    print "Creating mount file for CDROM device $device\n";
    local(%mountinfo)=();
    $mountinfo{TYPE}="CDROM";
    $mountinfo{SHARE}="/dev/$device";
    $mountinfo{MOUNTONBOOT}=FALSE;
    $mountinfo{HOSTNAME}=localhost;
    $mountinfo{MOUNT}="cdrom$i";
    $i++;
    &WriteMountInfo(%mountinfo);
  }
  return 0;
}

1;
