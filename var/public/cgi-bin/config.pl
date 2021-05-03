#!/usr/bin/perl

sub  FindAndReplace
{
  local($line,%info)=@_;

  for $mykey (keys(%info))
  {
    if ($mykey =~ /KICKSTART_(.*)/)
    {
      $mykey=$1;
      $line =~ s/\[$mykey\]/$info{"KICKSTART_".$mykey}/g;
    } else {
      $line =~ s/\[$mykey\]/$info{$mykey}/g;
    }
  }
  local(%system)=&GetSystemVariables();
  for $mykey (keys(%system))
  {
    $line =~ s/\[$mykey\]/$system{$mykey}/g;
  }
  return $line;
}

sub AddToTemplateSortFile
{
  local($template);
  local($result)=open(TS,">>$TEMPLATESORT");
  print TS $template."\n";
  close(TS);
  return 0;
}

sub GetNewTemplateID
{
  local(%alltemplates)=&GetTemplateHTMLConfig();
  local(%idlst)=();
  for $item (keys(%alltemplates))
  {
    local(%info)=&GetTemplateInfo($item);
    if (defined($info{TEMPLATEID}))
    {
      # print "<LI>FOUND TEMPLATEID |$info{TEMPLATEID}|";
      $idlist{$info{TEMPLATEID}}=$template;
    }
  }
  local($found)=0;
  for ($i=0;$i<100;$i++)
  {
    local($istring)=sprintf("%02d",$i);
    if(!defined($idlist{$istring}))
    {
      local($returnstring)=sprintf("%02d",$i);
      # print "New ID returning: |$returnstring|\n";
      return $returnstring;
    }
  }
  return(-1);
}


sub DeleteFromTemplateSortFile
{ 
  local($template)=shift;
  local($result)=open(TS,"<$TEMPLATESORT");
  local(@newarrray)=();
  while(<TS>)
  {
    local($line)=$_;
    chomp($line);
    if ($line !~ /^\s*$/)
    {
     if ($line ne $template)
     {
      push(@newarray,$line);
     }
    }
  }
  close(TS);
  local($result)=&WriteTemplateSortFile(@newarray);
  return 0;
}


sub GetTemplateSortOrder
{
  local(%order)=();
  local($result)=open(TS,"<$TEMPLATESORT");
  local($i)=0;
  while (<TS>)
  {
    local($line)=$_;
    chomp($line);
    if ($line !~ /^\s*$/)
    {
      local($index)=sprintf("%08d",$i);
      $i++;
      $order{$index}=$line;
    }
  }
  close(TS);
  return %order;
}

sub WriteTemplateSortFile
{
  local(@templatelist)=@_;
  local($result)=open(TS,">$TEMPLATESORT");
  for $template (@templatelist)
  {
    print TS $template."\n";
  }
  close(TS);
  return 0;
}


sub GetOSList
{
  local(@list)=();
  local($result)=open(OSCONF,"<$OSCONF");
  while(<OSCONF>)
  {
    local($line)=$_;
    chomp($line);
    if ($line !~ /\s*\#.*/)
    {
      local(@lineinfo)=split(";",$line);
      push(@list,"$lineinfo[0];$lineinfo[1] $lineinfo[2]");
    }
  }
  close(OSCONF);
  return (@list);
}

sub GetOSHash
{
  local(%list)=();
  local($result)=open(OSCONF,"<$OSCONF");
  while(<OSCONF>)
  {
    local($line)=$_;
    chomp($line);
    if ($line !~ /\s*\#.*/)
    {
      local(@lineinfo)=split(";",$line);
      $list{$lineinfo[0]}="$lineinfo[1] $lineinfo[2]";
    }
  }
  close(OSCONF);
  return (%list);
}

sub GetTemplateInfo
{
   local($template)=shift;
   local($templateconffile)=$TEMPLATECONFDIR."/".$template.".dat";
   local(%templateconfig)=();
   local($result)=open(TCONF,"<$templateconffile");
   while(<TCONF>)
   {
     local($line)=$_;
     if ( $line =~ /^\s*([A-Za-z0-9_]+)\s*=\s*(.*)$/)
     {
       $templateconfig{$1}=$2;
     }
   }
   close(TCONF);
   return (%templateconfig);
}

sub GetVersionInfo
{
   local($module)=shift;
   local($versionconffile)=$VERSIONDIR."/".$module.".dat";
   local(%versionconfig)=();
   local($result)=open(MCONF,"<$versionconffile");
   while(<MCONF>)
   {
     local($line)=$_;
     if ( $line =~ /^\s*([A-Za-z0-9]+)\s*=\s*(.*)$/)
     {
       $versionconfig{$1}=$2;
     }
   }
   close(MCONF);
   return (%versionconfig);
}



sub GetAllSubTemplateInfo
{
  local($template)=@_;
  local(%subtemplates)=();
  # print "<LI>NOW HERE for template $template\n";
  local($subtemplateconffile)=$TEMPLATECONFDIR."/".$template.".sub";
  local($result)=open(TCONF,"<$subtemplateconffile");
  # print "<LI>Opening file |$subtemplateconffile| result: |$result|\n";
  if ($result != 1)
  {
    return (%subtemplates);
  }
  local($linenum)=0;
  local($fieldnum)=0;
  local($counter)=1;
  local(@headerinfo)=();
  while(<TCONF>)
  {
   local($line)=$_;
   chomp($line);
   $line =~ s/\s*$//g;
   if ($line !~ /^\s*$/)
   {
    # print "LINE= $line\n";
    if ($linenum == 0)
    {
      local(@headerinfo)=split(";",$line);
      for ($i=0;$i<=$#headerinfo;$i++)
      {
       # print "<LI> i = $i : Header - $headerinfo[$i]\n";
        if ($headerinfo[$i] eq "SUBTEMPLATE")
        {
          $fieldnum=$i;
          # print "<LI>Found template column at: $fieldnum\n";
        }
      }
     $subtemplates{__HEADER__}=$line.";SUBTEMPLATEID";
     $linenum++;
    } else {
      local(@lineinfo)=split(";",$line);
      local($subidstring)=sprintf("%03d",$counter);
      $counter++;
      $subtemplates{$lineinfo[$fieldnum]}=$line.";$subidstring";
      # print "<LI>ADDING line |$line| for subtemplate $lineinfo[$fieldnum]\n";
    }
   }
  }
  close(TCONF);
  return (%subtemplates);
}

sub GetSubTemplateInfo
{
  local($headerline,$subtemplateline,%info)=@_;
  local(@headerinfo)=split(";",$headerline);
  local(@subtemplateinfo)=split(";",$subtemplateline);

  for ($i=0;$i<=$#headerinfo;$i++)
  {
    $info{$headerinfo[$i]}=$subtemplateinfo[$i];
  }
  # for $mykey (keys(%info))
  #{
  #  print "<LI>|$mykey| => |$info{$mykey}|\n";
  #}
  return (%info);
}

sub GetSubTemplateSort
{
  local($template)=@_;
  local(%subtemplates)=();
  local($subtemplateconffile)=$TEMPLATECONFDIR."/".$template.".sub";
  local($result)=open(TCONF,"<$subtemplateconffile");
  if ($result != 1)
  {
    return (%subtemplates);
  }
  local($linenum)=0;
  local($fieldnum)=0;
  local(@headerinfo)=();
  while(<TCONF>)
  {
   local($line)=$_;
   chomp($line);
   $line =~ s/\s*$//g;
   if ($line !~ /^\s*$/)
   {
    if ($linenum == 0)
    {
      local(@headerinfo)=split(";",$line);
      for ($i=0;$i<=$#headerinfo;$i++)
      {
        if ($headerinfo[$i] eq "SUBTEMPLATE")
        {
          $fieldnum=$i;
        }
      }
     $linenum++;
    } else {
      local(@lineinfo)=split(";",$line);
      local($index)=sprintf("%08d",$linenum);
      $subtemplates{$index}=$lineinfo[$fieldnum];
      # print "<LI>Adding number $linenum for subtemplate $lineinfo[$fieldnum]";
      $linenum++;
    }
   }
  }
  close(TCONF);
  return (%subtemplates);
}


sub GetSubTemplateField
{
  local($subtemplate,$field,%subtemplates)=@_;
  local(@headers)=split(";",$subtemplates{__HEADER__});
  local(@lineinfo)=split(";",$subtemplates{$subtemplate});
  for ($i=0;$i<=$#headers;$i++)
  {
    if ($headers[$i] == $field)
    {
      return($lineinfo[$i]);
    }
  }
}


sub GetOSInfo
{
   local($os)=shift;
   local($osconffile)=$OSCONFDIR."/".$os.".dat";
   local(%osconfig)=();
   local($result)=open(OCONF,"<$osconffile");
   while(<OCONF>)
   {
     local($line)=$_;
     if ( $line =~ /^\s*([A-Za-z0-9_]+)\s*=\s*(.*)$/)
     {
       $osconfig{$1}=$2;
     }
   }
   close(OCONF);
   return (%osconfig);
}

sub GetMountInfo
{
   local($mount)=shift;
   local($mountconffile)=$MOUNTCONFDIR."/".$mount.".dat";
   local(%mountconfig)=();
   local($result)=open(MCONF,"<$mountconffile");
   while(<MCONF>)
   {
     local($line)=$_;
     if ( $line =~ /^\s*([A-Za-z0-9]+)\s*=\s*(.*)$/)
     {
       $mountconfig{$1}=$2;
     }
   }
   close(MCONF);
   return (%mountconfig);
}

sub WriteTemplateInfo
{
  local(%info)=@_;
  if (!defined($info{OVOFILE}))
  {
    $info{OVOFILE}=$TEMPLATECONFDIR."/".$template.".ovo";
    $info{OVAFILE}="/ova/builtin/$info{OS}/default.ova";
    $info{OVAMOUNT}="local";
    $info{OVADESTINATION}="vi://[UDA_OVA_VI_USERNAME]:[UDA_OVA_VI_PASSWORD]@[UDA_OVA_VI_IP]/";
    if (! -f $info{OVOFILE})
    {
       local($result)=open(INFILE,"<$OVOTEMPLATE");
       local($result)=open(OUTFILE,">$info{OVOFILE}");
       while(<INFILE>)
       {
         print OUTFILE $_;
       }
       close(INFILE);
       close(OUTFILE);
    }
  }

  if (defined($info{TEMPLATE}))
  {
    local($template)=$info{TEMPLATE};
    local($templateconfigfilename)=$TEMPLATECONFDIR."/".$template.".dat";
    local($result)=open(TCONF,">$templateconfigfilename");
    for $key (keys(%info))
    {
      print TCONF "$key=$info{$key}\n";
    }
    close(TCONF);
  } else {
    return 1;
  }
  return 0;
}

sub WriteOSInfo
{
 local(%info)=@_;
  if (defined($info{FLAVOR}))
  {
    local($osconfigfilename)=$OSCONFDIR."/".$info{FLAVOR}.".dat";
    # print "Configfile = |$osconfigfilename|\n";
    local($result)=open(OCONF,">$osconfigfilename");
    for $key (keys(%info))
    {
      print OCONF "$key=$info{$key}\n";
    }
    close(OCONF);
  } else {
    print "no flavor fond";
    return 1;
  }
  return 0;
}

sub WriteMountInfo
{
  local(%info)=@_;
  if (defined($info{MOUNT}))
  {
    local($mount)=$info{MOUNT};
    local($mountconfigfilename)=$MOUNTCONFDIR."/".$mount.".dat";
    local($result)=open(MCONF,">$mountconfigfilename");
    for $key (keys(%info))
    {
      print MCONF "$key=$info{$key}\n";
    }
    close(MCONF);
  } else {
    print " Could not find mount id\n";
    return 1;
  }
  return 0;
}

sub DeleteTemplateDatFile
{
  local($template)=shift;
  local($templateconfigfile)=$TEMPLATECONFDIR."/".$template.".dat";
  local($result)=&RunCommand("rm -f $templateconfigfile","Removing configuration file $templateconfigfile for template $template");
  return $result;
}

sub DeleteSubtemplateFile
{
  local($template)=shift;
  local($subtemplateconfigfile)=$TEMPLATECONFDIR."/".$template.".sub";
  local($result)=&RunCommand("rm -f $subtemplateconfigfile","Removing configuration file $subtemplateconfigfile for template $template");
  return $result;
}

sub DeleteMountConfigFile
{
  local($mount)=shift;
  local($mountconfigfile)=$MOUNTCONFDIR."/".$mount.".dat";
  local($result)=&RunCommand("rm -f $mountconfigfile","Removing configuration file $mountconfigfile for mount $mount");
  return $result;
}

sub DeleteOSConfigFile
{
  local($os)=shift;
  local($osconfigfile)=$OSCONFDIR."/".$os.".dat";
  local($result)=&RunCommand("rm -f $osconfigfile","Removing configuration file $osconfigfile for os $os");
  return $result;
}

sub GetOSFlavorList
{
 local($result)=opendir(DIR,"$OSCONFDIR");
 while ($fn=readdir(DIR))
 {
    if( $fn =~ /^([A-Za-z0-9\_]+)\.[Dd][Aa][Tt]$/)
    {     
       local($flavor)=$1;
       local(%curconfig)=&GetOSInfo($flavor);
       push(@config,"$curconfig{OS};$flavor");
     }
  }
  closedir(DIR);
  return @config;
}

sub GetMenuFlavorList
{
 local(@config)=();
 local($result)=opendir(DIR,"$OSCONFDIR");
 while ($fn=readdir(DIR))
 {
    if( $fn =~ /^([A-Za-z0-9\_]+)\.[Dd][Aa][Tt]$/)
    {
     local($flavor)=$1;
     push (@config,$flavor);
     }
  }
  closedir(DIR);
  return @config;
}

sub GetVersionList
{
 local(%config)=();
 local($result)=opendir(DIR,"$VERSIONDIR");
 while ($fn=readdir(DIR))
 {
    if( $fn =~ /^([A-Za-z0-9\_]+)\.[Dd][Aa][Tt]$/)     
    {
     local($module)=$1;
     local(%curconfig)=&GetVersionInfo($module);
     $config{$module}="$curconfig{VERSION}";
     }
  }
  closedir(DIR);
  return %config;
}

sub GetMountList 
{
 local(@config)=();
 local($result)=opendir(DIR,"$MOUNTCONFDIR");
 while ($fn=readdir(DIR))
 {
    if( $fn =~ /^([A-Za-z0-9\_]+)\.[Dd][Aa][Tt]$/)     
    {
     local($mount)=$1;
     local(%curconfig)=&GetMountInfo($mount);
     push (@config,"$mount;$mount ($curconfig{SHARE} on $curconfig{HOSTNAME})");
     }
  }
  closedir(DIR);
  return @config;
}



sub GetMenuMountList
{
 local(@config)=();
 local($result)=opendir(DIR,"$MOUNTCONFDIR");
 while ($fn=readdir(DIR))
 {
    if( $fn =~ /^([A-Za-z0-9\_]+)\.[Dd][Aa][Tt]$/)
    {
     local($mount)=$1;
     push (@config,$mount);
     }
  }
  closedir(DIR);
  return @config;
}

sub GetMountHTMLConfig
{
  local(%config)=();
  local($result)=opendir(DIR,"$MOUNTCONFDIR");
  while ($fn=readdir(DIR))
  {
     if( $fn =~ /^([A-Za-z0-9\_]+)\.[Dd][Aa][Tt]$/)
     {
       local($mount)=$1;
       local(%curconfig)=&GetMountInfo($mount);
       local($configline)="<TD>$mount</TD><TD>$curconfig{TYPE}</TD><TD>$curconfig{HOSTNAME}</TD><TD>$curconfig{SHARE}</TD><TD>$curconfig{MOUNTONBOOT}</TD>";
       $config{$mount}=$configline;
     }
  }
  closedir(DIR);
  return %config;
}

sub GetTemplateHTMLConfig
{
  local(%config)=();
  local($result)=opendir(DIR,"$TEMPLATECONFDIR");
  while($fn=readdir(DIR))
  {
     if( $fn =~ /^([A-Za-z0-9\_\-]+)\.[Dd][Aa][Tt]$/)
     {
       local($template)=$1;
       local(%curconfig)=&GetTemplateInfo($template);
       local($macentry)="<INPUT TYPE=CHECKBOX CHECKED DISABLED>";
       if ($curconfig{GENERATEMAC} eq "OFF")
       {
         $macentry="<INPUT TYPE=CHECKBOX DISABLED>";
       }
       local($publishentry)="<INPUT TYPE=CHECKBOX CHECKED DISABLED>";
       if ($curconfig{PUBLISH} eq "OFF")
       {
         $publishentry="<INPUT TYPE=CHECKBOX DISABLED>";
       }
       local($configline)="<TD>$curconfig{TEMPLATE}</TD><TD>$curconfig{OS}</TD><TD>$curconfig{FLAVOR}</TD><TD>$publishentry</TD><TD>$macentry</TD><TD>$curconfig{DESCRIPTION}</TD>";
       $config{$template}=$configline;
     }
  }
  closedir(DIR);
  return %config;
}

sub GetMenuTemplateList
{
  local(@config)=();
  local($result)=opendir(DIR,"$TEMPLATECONFDIR");
  # print "<LI>Checking directory |$TEMPLATECONFDIR|\n";
  while($fn=readdir(DIR))
  {
     if( $fn =~ /^([A-Za-z0-9\_]+)\.[Dd][Aa][Tt]$/)
     {
       local($template)=$1;
       # print "<LI>Adding template $template\n";
       push(@config,$template);
     }
  }
  closedir(DIR);
  return @config;
}

sub WriteDefaultFile
{
  # local(@templateinfo)=&GetMenuTemplateList();

  local($passwordenabled)=0;
  local($result)=open(DEFAULT,">$DEFAULTFILE");    
  local($result)=open(HDR,"<$PXEHEADER");
  local(@mactemplates)=();
  while(<HDR>)
  {
    local($line)=$_;
    if (lc($line) =~ /^\s*menu\s+master\s+passwd\s+.+/)
    {
      $passwordenabled=1;
    }
    print DEFAULT $line;
  }
  close(HDR);

 local(@menuitem)=&GetConfigFile($PXEMENUITEM);

 local(%templateconfig)=&GetTemplateHTMLConfig();
 local(%templatesortorder)=&GetTemplateSortOrder();
  require "templates.pl";
  for $mytemplate (sort(keys(%templatesortorder)))
  {
    local($template)=$templatesortorder{$mytemplate};
    if (defined($templateconfig{$templatesortorder{$mytemplate}}))
    {
      local(%info)=&GetTemplateInfo($template);
      if ($info{GENERATEMAC} eq "ON")
      {
        push(@mactemplates,$info{TEMPLATE});
      }
      for $menuline (@menuitem)
      {
        local($newline)=&FindAndReplace($menuline,%info);
        print DEFAULT $newline;
      }
      delete($templateconfig{$templatesortorder{$mytemplate}});
    }
  }
  # put the templates not in the sortorder at the end of the table in random order
  for $template (sort(keys(%templateconfig)))
  {
    local(%info)=&GetTemplateInfo($template);
    if ($info{GENERATEMAC} eq "ON")
    {
      push(@mactemplates,$info{TEMPLATE});
    }
    for $menuline (@menuitem)
    {
      local($newline)=&FindAndReplace($menuline,%info);
      print DEFAULT $newline;
    }
  }
  close(DEFAULT);

  local($result)=&CopyMacFiles(@mactemplates);
  return 0;
}

sub CopyMacFiles
{
  local(@mactemplates)=@_;
  # remove all current mac files
  local($result)=opendir(DIR,"$PXECFG");
  while ($fn=readdir(DIR))
  {
    if( $fn =~ /^([0-9]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2})$/)
    {
      local($result)=&RunCommand("rm $PXECFG/$fn","Removing template mac file $PXECFG/$fn");
    }
  }
  closedir(DIR);
  for $mactemplate (@mactemplates)
  {
    local($result)=opendir(NEWDIR,"$PXETEMPLATEDIR");
    while($newfn=readdir(NEWDIR))
    {
       if ($newfn =~ /$mactemplate\.([0-9]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2}-[0-9A-Fa-f]{2})$/)
       {
          local($templatemac)=$1;
          local($command)="cp $PXETEMPLATEDIR/$mactemplate.$templatemac $PXECFG/$templatemac";
          local($result)=&RunCommand($command,"Copying template mac file $PXETEMPLATEDIR/$mactemplate.$templatemac to $PXECFG/$templatemac");
       }
    }
    closedir(NEWDIR);
  }
  return 0;
}

sub GetOSHTMLConfig
{
  local(%config)=();
  local(%oshash)=&GetOSHash();
  local(%mountstatus)=&GetMountStatusConfig();
  local($result)=opendir(DIR,"$OSCONFDIR");
  while($fn=readdir(DIR))
  {
     if( $fn =~ /^([A-Za-z0-9\_]+)\.[Dd][Aa][Tt]$/)
     {
       local($flavor)=$1;
       local(%curconfig)=&GetOSInfo($flavor);
       local($mymountstatus)="N/A";
       local($requirefile)="$OSDIR/$curconfig{OS}.pl";
       if ( -f $requirefile)
       {
         require "os/$curconfig{OS}.pl";
         local($curstatus)=1;
         if (defined(&{$curconfig{OS}."_GetMountStatus"}))
         {
           $curstatus=&{$curconfig{OS}."_GetMountStatus"}($flavor,%mountstatus);
         } else {
           require "os.pl";
           $curstatus=&Generic_GetMountStatus($flavor,%mountstatus);
         }
         if ($curstatus == 0)
         {
           $mymountstatus = "Mounted";
         } elsif ($curstatus == -1) {
           $mymountstatus = "N/A";
         } else {
           $mymountstatus = "Not Mounted";
         }
       }
       local($configline)="<TD>$flavor</TD><TD>$curconfig{OS}</TD><TD>$oshash{$curconfig{OS}}</TD><TD>$mymountstatus</TD>";
       $config{$flavor}=$configline;
     }
  }
  closedir(DIR);
  return %config;
}

sub RebuildNFSExports
{
  local($result)=open(EXPORTS,">$NFSEXPORTS");
  local($result)=open(HF,"<$NFSHEADER");
  while(<HF>)
  {
    local($line)=$_;
    print EXPORTS $line;
  }
  close(HF);
  local(%flavorlist)=&GetOSHTMLConfig();
  for $flavor (keys(%flavorlist))
  {
    # print "Now processing flavor $flavor\n";
    local(%curconfig)=&GetOSInfo($flavor);
    for $mykey (keys(%curconfig))
    {
      # print "Now processing key $mykey\n";
      if ($mykey =~ /NFSEXPORT_([0-9]+)/)
      {
        local($exportnum)=$1;
        local($optionskey)="NFSEXPORTOPTIONS_$exportnum";
        #print "Found key $mykey with exportnum $exportnum Optionskey= $optionskey\n";
        if (defined($curconfig{$optionskey}))
        {
          # print "Found options: $curconfig{$optionskey}\n";
          print EXPORTS "$curconfig{$mykey} $curconfig{$optionskey}\n";
        }
      }
    }
  }

  local(%alltemplates)=&GetTemplateHTMLConfig();
  for $item (keys(%alltemplates))
  {
    local(%curconfig)=&GetTemplateInfo($item);
    # print "<LI>Now processing Template $item\n";
    for $mykey (keys(%curconfig))
    {
      # print "Now processing key $mykey\n";
      if ($mykey =~ /NFSEXPORT_([0-9]+)/)
      {
        local($exportnum)=$1;
        local($optionskey)="NFSEXPORTOPTIONS_$exportnum";
        # print "Found key $mykey with exportnum $exportnum Optionskey= $optionskey\n";
        if (defined($curconfig{$optionskey}))
        {
          #print "Found options: $curconfig{$optionskey}\n";
          print EXPORTS "$curconfig{$mykey} $curconfig{$optionskey}\n";
        }
      } 
    }
  }
 
  close(EXPORTS);

  local($result)=&RunCommand("/usr/sbin/exportfs -ra","Reexporting all filesystems in /etc/exportfs");
  if ($result)
  {
    return $result;
  }
  return 0;
}







sub GetSubTemplateHTMLConfig
{
  local($template)=shift;
  local(%config)=();
  local($result)=open(SUBFILE,"<$TEMPLATECONFDIR/$template.sub");
  local($first)=0;
  while(<SUBFILE>)
  {
    local($line)=$_;
    chomp($line);
    local(@info)=split(";",$line);
    local($mykey)=$info[0];
    if ($first == 0)
    {
       $mykey="__HEADER__";
       $first=1;
    } 
    # print "<LI>now procccing $mykey: $line\n";
    $config{$mykey}="<TD>".join("</TD><TD>",@info)."</TD>";
  }
  close(SUBFILE);
  return (%config);
}

sub GetSubTemplateStanzaInfo
{
  local($template)=shift;
  local(%config)=();
  local($result)=open(SUBFILE,"<$TEMPLATECONFDIR/$template.sub");
  local($first)=0;
  local($templatefield)=0;
  local($kernelfield)=-1;
  local($cmdlinefield)=-1;
  while(<SUBFILE>)
  {
    local($line)=$_;
    chomp($line);
    $line =~ s/\s*$//g;
    local(@info)=split(";",$line);
    if ($first == 0)
    {
       $mykey="__HEADER__";
       local(@headerinfo)=split(";",$line);
       for ($i=0;$i<=$#headerinfo;$i++)
       {
         if ($headerinfo[$i] eq "SUBTEMPLATE")
         {
          $templatefield=$i;
         }
         if ($headerinfo[$i] eq "KERNEL")
         {
          $kernelfield=$i;
         }
         if ($headerinfo[$i] eq "CMDLINE")
         {
          $cmdlinefield=$i;
         }
       }
       $first=1;
    } else {
      local($kernel)="Defaultkernel";
      if ($kernelfield >= 0)
      {
        $kernel=$info[$kernelfield];
      }
      local($cmdline)="DefaultCommandline";
      if ($cmdlinefield >= 0)
      {
        $cmdline=$info[$cmdlinefield];
      }
      local($mykey)=$info[$templatefield];
      $config{$mykey}="$kernel;$cmdline";
    }
  }
  close(SUBFILE);
  return (%config);
}

sub GetSubTemplateFile
{
  local($template)=shift;
  local(@config)=();
  local($result)=open(SUBFILE,"<$TEMPLATECONFDIR/$template.sub");
  while(<SUBFILE>)
  {
    local($line)=$_;
    # chomp($line);
    push(@config,$line);
  }
  close(SUBFILE);
  return (@config);
}

sub SaveTemplateOvaConfig
{
  local($template)=shift;
  local($info)=shift;
  # print "<LI>Now saving ova options file\n";
  local($tmpfile)=$TEMPDIR."/$template.ovo.$$";
  local($subfile)="$TEMPLATECONFDIR/$template.ovo";
  local($result)=open(SUBFILE,">$tmpfile");
  print SUBFILE $info;
  close(SUBFILE);
  local($result)=&RunCommand("cp $tmpfile $subfile","Copying temporary file |$tmpfile to |$subfile|\n");
  unlink($tmpfile);

  return 0;
}

sub SaveSubTemplateFile
{
  local($template)=shift;
  local($info)=shift;
  # print "<LI>Now saving Subtemplate file\n";
  local($tmpfile)=$TEMPDIR."/$template.sub.$$";
  local($subfile)="$TEMPLATECONFDIR/$template.sub";
  local($result)=open(SUBFILE,">$tmpfile");
  print SUBFILE $info;
  close(SUBFILE);
  local($result)=&RunCommand("cp $tmpfile $subfile","Copying temporary file |$tmpfile to |$subfile|\n");
  unlink($tmpfile);

  return 0;
}

sub GetGeneralConfig
{
  local(%config)=();
  local($generalconfigfile)=$CONFDIR."/general.conf";
  local($result)=open(GENERAL,"<$generalconfigfile");
  while(<GENERAL>)
  {
    local($line)=$_;
    if ( $line =~ /^\s*([A-Za-z0-9_]+)\s*=\s*(.*)$/)
    {
      $config{$1}=$2;
     }
  }
  close(GENERAL);
  return (%config);
}

sub WriteGeneralInfo
{
  local(%config)=@_;
  local($generalconfigfile)=$CONFDIR."/general.conf";
  local($result)=open(GENERAL,">$generalconfigfile");
  for $key (keys(%config))
  {
    print GENERAL "$key=$config{$key}\n";
  }
  close(GENERAL);
  return 0;
}

sub GetSystemVariables
{
  local(%sysconfig)=&GetOnlySystemVariables();
  local(%globals)=&GetGeneralConfig();
  for $key (keys(%sysconfig))
  {
    $globals{$key}=$sysconfig{$key};
  }
  return %globals;
}

sub GetOnlySystemVariables
{
   local(%config)=();
   local($ifcfgfile)="/etc/sysconfig/network-scripts/ifcfg-eth0";
   local($result)=open(IFCFGFILE,"<$ifcfgfile");
   while(<IFCFGFILE>)
   {
     local($line)=$_;
     if ($line =~ /^\s*IPADDR\s*=\s*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/)
     {
      $config{UDA_IPADDR}=$1;
     }
     if ($line =~ /^\s*NETMASK\s*=\s*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/)
     {
      $config{UDA_NETMASK}=$1;
     }
   }
   close(IFCFGFILE);

   local($networkfile)="/etc/sysconfig/network";
   local($result)=open(NETWORKFILE,"<$networkfile");
   while(<NETWORKFILE>)
   {
     local($line)=$_;
     if ($line =~ /^\s*GATEWAY\s*=\s*([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/)
     {
      $config{UDA_GATEWAY}=$1;
     }
     #if ($line =~ /^\s*HOSTNAME\s*=\s*([^\s]+)/)
     #{
     # $config{UDA_HOSTNAME}=$1;
     #}
   }
   close(NETWORKFILE);

   $config{UDA_HOSTNAME}=`hostname`;

   local($dnsfile)="/etc/resolv.conf";
   local($dnsnum)=1;
   local($result)=open(DNSFILE,"<$dnsfile");
   while(<DNSFILE>)
   {
     local($line)=$_;
     if ($line =~ /^\s*domain\s+([^\s]+)/)
     {
       $config{UDA_DNS_DOMAIN}=$1;
     }
     if ($line =~ /^\s*nameserver\s*([^\s]+)/)
     {
       $config{"UDA_DNS_".$dnsnum}=$1;
       $dnsnum++;
     }
     if ($line =~ /^\s*search\s+([^\s]+)/)
     {
       $config{UDA_DNS_SEARCH_PATH}=$1;
     }
   }
   close(DNSFILE);

   return %config;
}

sub GetConfigFile
{
  local($filename)=shift;
  local(@config)=();
  local($result)=open(SUBFILE,"<$filename");
  while(<SUBFILE>)
  {
    local($line)=$_;
    # chomp($line);
    push(@config,$line);
  }
  close(SUBFILE);
  return (@config);
}

sub PutConfigFile
{
  local($filename,$config)=@_;
  local($tempfile)=$filename;
  $tempfile =~ s/.*\/([^\/]+)$/\1/g;
  $tempfile = $TEMPDIR."/".$tempfile.".$$";
  local($savefile)=$tempfile.".save";
  local($result)=open(CONFFILE,">$tempfile");
  print CONFFILE $config ;
  close(CONFFILE);
  
  local($command)="cp $filename $savefile";
  local($result)=&RunCommand($command,"Backing up $filename in $savefile");
  if ($result) { return $result } ;

  local($command)="cp $tempfile $filename";
  local($result)=&RunCommand($command,"Replacing $filename with temporary file $tempfile");
  if ($result) { return $result } ;

  return 0;
}

sub GetMenuServiceList
{
  local(@services)=();
  for $item (keys(%SERVICES))
  {
    push(@services,$item);
  }
  return @services;
}


1;
