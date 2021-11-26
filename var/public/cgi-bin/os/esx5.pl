#!/usr/bin/perl

require "kickstart.pl";

sub esx5_NewTemplate_2
{
  local($result)=&kickstart_NewTemplate_Finish("esx5");
  return $result;
}

sub esx5_NewTemplate_Finish
{
 local($result)=&kickstart_NewTemplate_Finish("esx5");
 return $result;
}

sub esx5_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub esx5_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"esx5");
  return ($result);
}

sub esx5_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)=" -c /pxelinux.cfg/templates/[TEMPLATE]/[SUBTEMPLATE].cfg";
  return $commandline;
}

sub esx5_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub esx5_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub esx5_GetDefaultPublishFile2
{
  local($publishfile)="$TFTPDIR/pxelinux.cfg/templates/[TEMPLATE]/[SUBTEMPLATE].cfg";
  return $publishfile;
}

sub esx5_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub esx5_GetDefaultPublishDir2
{
  local($publishdir)="$TFTPDIR/pxelinux.cfg/templates/[TEMPLATE]";
  return $publishdir;
}

sub esx5_GetDefaultEFIPublishFile3
{
  local($publishdir)="$WWWDIR/ipxe/templates/[TEMPLATE]/[SUBTEMPLATE].cfg";
  return $publishdir;
}

sub esx5_GetDefaultEFIPublishFile2
{
  local($publishdir)="$WWWDIR/ipxe/templates/[TEMPLATE]/[SUBTEMPLATE].ipxe";
  return $publishdir;
}

sub esx5_GetDefaultEFIPublishLink1
{
  local($publishdir)="$WWWDIR/ipxe/templates/[TEMPLATE]/files";
  return $publishdir;
}

sub esx5_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="[OS].[FLAVOR].mboot.c32";
  return $kernel;
}

sub esx5_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("esx5");
  return $result;
}

sub esx5_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("esx5",$template,$desttemplate,%info);
  return $result;
}

sub esx5_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"esx5");
  return $result;
}

sub esx5_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("esx5",$template,%config);
  return $result;
}

sub esx5_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("esx5",$template,%info);
  return $result;
}

sub esx5_NewOS_2
{
 local($result)=&kickstart_NewOS_2("esx5");
 return result;
}

sub esx5_ExtraConfiguration
{
  local(%info)=();
  $info{PUBLISHDIR2}=&esx5_GetDefaultPublishDir2();
  $info{PUBLISHFILE2}=&esx5_GetDefaultPublishFile2();
  $info{PUBLISHEFIFILE2}=&esx5_GetDefaultEFIPublishFile2();
  $info{PUBLISHEFIFILE3}=&esx5_GetDefaultEFIPublishFile3();
  $info{PUBLISHEFILINK1}=&esx5_GetDefaultEFIPublishLink1();
  return %info;
}

# ESX5 does not support getting the kernel from a prefix on the webserver
sub esx5_PublishEFITemplate_disabled
{
  local($template)=shift;

  local(%templateinfo)=&GetTemplateInfo($template);
  local(%osinfo)=&GetOSInfo($templateinfo{FLAVOR});

  local($templatedir)=&FindAndReplace($templateinfo{PUBLISHEFIDIR1},%templateinfo);
  local($result)=&CreateDir($templatedir);
  if ($result) { return 2; }

  local($result)=&CreateDir("$templatedir/subtemplates");
  if ($result) { return 2; }

  #local($result)=&CreateDir("$templatedir/macs");
  #if ($result) { return 2; }

  local($efilink)=&FindAndReplace($templateinfo{PUBLISHEFILINK1},%templateinfo);
  local($command)="rm -f $efilink ; ln -sf $osinfo{MOUNTPOINT_1} $efilink";
  local($result)=&RunCommand($command,"Makeing link to mounted iso");

  local($srcfile)=$osinfo{FILE_2};

  # print "<LI>SRCfile = $srcfile\n";

    local(%subinfo)=&GetAllSubTemplateInfo($template);


    local(@indexes)=keys(%subinfo);
    if ($#indexes<0)
    {
       $templateinfo{SUBTEMPLATE}="default";

       local($publishfile1)=&FindAndReplace($templateinfo{PUBLISHEFIFILE1},%templateinfo);
       local($result)=open(PFILE1,">$publishfile1");
       local($chain)="/ipxe/scripts/storemac.cgi?mac=\$\{net0/mac:hexhyp\}&template=[TEMPLATE]&subtemplate=[SUBTEMPLATE]";
       local($newchain)=&FindAndReplace($chain,%templateinfo);
       print PFILE1 "#!ipxe\n";
       print PFILE1 "chain $newchain\n";
       close(PFILE1);

       local($publishfile2)=&FindAndReplace($templateinfo{PUBLISHEFIFILE2},%templateinfo);
       local($result)=open(PFILE2,">$publishfile2");
       print PFILE2 "#!ipxe\n";
       print PFILE2 "chain /ipxe/templates/$template/files/efi/boot/bootx64.efi\n";
       close(PFILE2);

       local($publishfile3)=&FindAndReplace($templateinfo{PUBLISHEFIFILE3},%templateinfo);
       local($result)=open(PFILE3,">$publishfile3");
       local(@configfile)=&GetConfigFile($srcfile);
       local($prefixfound)=0;
       for $line (@configfile)
       {
        if ($line =~ /^title=(.*)/)
        {
          $line = "title=Loading UDA template [TEMPLATE] - [SUBTEMPLATE]\n"
        }
        if ($line =~ /^kernelopt=(.*)/)
        {
          $line = "kernelopt=$1 ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg\n";
          $line =~ s/cdromboot//i;
        }
        if ($line =~ /^prefix=(.*)/)
        {
          $prefixfound=1;
          $line="prefix=/ipxe/templates/[TEMPLATE]/files\n";
        }
        if ($line =~ /^kernel=\/(.*)/)
        {
          $line="kernel=$1\n";
        }
        if ($line =~ /^modules=\/(.*)/)
        {
          $line =~  s|\/||g;
        }
        $newline=&FindAndReplace($line,%templateinfo);
        print PFILE3 $newline;
       }
       if ($prefixfound == 0)
       {
         $line="prefix=/ipxe/templates/[TEMPLATE]/files\n";
         $newline=&FindAndReplace($line,%templateinfo);
         print PFILE3 $newline;
       }
       close(PFILE3);

    } else  {
      local($headerline)=$subinfo{__HEADER__};
      for $sub (keys(%subinfo))
      {
       if ($sub ne "__HEADER__")
       {
         local(%subinfo)=&GetSubTemplateInfo($headerline,$subinfo{$sub},%info);

         local($publishfile1)=&FindAndReplace($templateinfo{PUBLISHEFIFILE1},%subinfo);
         local($result)=open(PFILE1,">$publishfile1");
         local($chain)="/ipxe/scripts/storemac.cgi?mac=\$\{net0/mac:hexhyp\}&template=[TEMPLATE]&subtemplate=[SUBTEMPLATE]";
         local($newchain)=&FindAndReplace($chain,%subinfo);
         print PFILE1 "#!ipxe\n";
         print PFILE1 "chain $newchain\n";
         close(PFILE1);

         local($publishfile2)=&FindAndReplace($templateinfo{PUBLISHEFIFILE2},%subinfo);
         local($result)=open(PFILE2,">$publishfile2");
         print PFILE2 "#!ipxe\n";
         print PFILE2 "chain /ipxe/templates/$template/files/efi/boot/bootx64.efi\n";
         close(PFILE2);

         local($publishfile3)=&FindAndReplace($subinfo{PUBLISHEFIFILE3},%subinfo);
         # print "<LI>Current publishfile = $publishfile3\n";
         local($result)=open(PFILE3,">$publishfile3");
         local(@configfile)=&GetConfigFile($srcfile);
         local($prefixfound)=0;
         for $line (@configfile)
         {
           if ($line =~ /^title=(.*)/)
           {
             $line = "title=Loading UDA template [TEMPLATE] - [SUBTEMPLATE]\n"
           }
           if ($line =~ /^kernelopt=(.*)/)
           {
             $line = "kernelopt=$1 ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg\n";
             $line =~ s/cdromboot//i;
           }
           if ($line =~ /^prefix=(.*)/)
           {
             $prefixfound=1;
             $line="prefix=/ipxe/templates/[TEMPLATE]/files\n";
           }
           if ($line =~ /^kernel=\/(.*)/)
           {
             $line="kernel=$1\n";
           }
           if ($line =~ /^modules=\/(.*)/)
           {
             $line =~  s|\/||g;
           }
           local($newline)=&FindAndReplace($line,%subinfo);
           print PFILE3 $newline;
         }
         if ($prefixfound == 0)
         {
           $line="prefix=/ipxe/templates/[TEMPLATE]/files\n";
           local($newline)=&FindAndReplace($line,%subinfo);
           print PFILE3 $newline;
         }
      }
    }
  }

  return 0;
}


sub esx5_PublishTemplate
{
  local($template)=shift;

  local(%templateinfo)=&GetTemplateInfo($template);
  local(%osinfo)=&GetOSInfo($templateinfo{FLAVOR});

  local($templatedir)=&FindAndReplace($templateinfo{PUBLISHDIR2},%templateinfo);
  local($result)=&CreateDir($templatedir);
  if ($result) { return 2; }

  local($srcfile)=$osinfo{FILE_2};

  # print "<LI>SRCfile = $srcfile\n";


    local(%subinfo)=&GetAllSubTemplateInfo($template);


    local(@indexes)=keys(%subinfo);
    if ($#indexes<0)
    {
       # print "<LI>Publishsing default subtemplate for $template\n";
       $templateinfo{SUBTEMPLATE}="default";
       local($publishfile)=&FindAndReplace($templateinfo{PUBLISHFILE2},%templateinfo);
       local($result)=open(PFILE,">$publishfile");
       local(@configfile)=&GetConfigFile($srcfile);
       for $line (@configfile)
       {
        if ($line =~ /^title=(.*)/)
        {
          $line = "title=Loading UDA template [TEMPLATE] - [SUBTEMPLATE]\n"
        }
        if ($line =~ /^kernelopt=(.*)/)
        {
          $line = "kernelopt=$1 ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg\n";
        }
        if ($line =~ /^kernel=\/(.*)/)
        {
          $line="kernel=/[OS]/[FLAVOR]/$1\n";
        }
        if ($line =~ /^modules=\/(.*)/)
        {
          $line =~  s|\/|\/\[OS\]\/\[FLAVOR\]\/|g;
        }
        $newline=&FindAndReplace($line,%templateinfo);
        print PFILE $newline;
       }
       close(PFILE);
    } else  {
      local($headerline)=$subinfo{__HEADER__};
      for $sub (keys(%subinfo))
      {
       if ($sub ne "__HEADER__")
       {
         # print "<LI>Publishsing subtemplate $sub\n";
         local(%subinfo)=&GetSubTemplateInfo($headerline,$subinfo{$sub},%info);

         local($publishfile)=&FindAndReplace($subinfo{PUBLISHFILE2},%subinfo);

         # print "<LI>Current publishfile = $publishfile\n";
         local($result)=open(PFILE,">$publishfile");
         local(@configfile)=&GetConfigFile($srcfile);
         for $line (@configfile)
         {
           if ($line =~ /^title=(.*)/)
           {
             $line = "title=Loading UDA template [TEMPLATE] - [SUBTEMPLATE]\n"
           }
           if ($line =~ /^kernelopt=(.*)/)
           {
             $line = "kernelopt=$1 ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg\n";
           }
           if ($line =~ /^kernel=\/(.*)/)
           {
             $line="kernel=/[OS]/[FLAVOR]/$1\n";
           }
           if ($line =~ /^modules=\/(.*)/)
           {
             $line =~  s|\/|\/\[OS\]\/\[FLAVOR\]\/|g;
           }
           local($newline)=&FindAndReplace($line,%subinfo);
           print PFILE $newline;
         }
      }
    }
  }

  return 0;
}

sub esx5_ImportOS
{
 local($result)=&kickstart_ImportOS("esx5");
  return $result;
}

sub esx5_ImportOS_DoIt
{
  require "general.pl";
  require "config.pl";
  require "action.pl";

  local($actionid)=shift;
  local($initrdlocation)="/boot.cfg";
  local($kernellocation)="/mboot.c32";

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) { 
    &UpdateActionProgress($actionid,-1,"Could not read arguments");
    return 1;
  } 
  
  local(%mountinfo)=&GetMountInfo($args{MOUNT});
  local(%osinfo)=();
  $osinfo{FLAVOR}=$args{"OSFLAVOR"};
  $osinfo{OS}="esx5";
  $osinfo{MOUNTFILE_1}=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{FILE1};
  if ($mountinfo{TYPE} eq "CDROM")
  {
    $osinfo{MOUNTFILE_1}=$mountinfo{SHARE};
  } 
  $osinfo{MOUNTPOINT_1}="$TFTPDIR/$osinfo{OS}/$osinfo{FLAVOR}";
  $osinfo{FILE_1}="$TFTPDIR/$osinfo{OS}.$osinfo{FLAVOR}.mboot.c32";
  $osinfo{FILE_2}="$TFTPDIR/$osinfo{OS}.$osinfo{FLAVOR}.boot.cfg";
  $osinfo{MOUNTONBOOT}=$args{MOUNTONBOOT};

  local($initrd)="$osinfo{MOUNTPOINT_1}$initrdlocation";
  local($vmlinuz)="$osinfo{MOUNTPOINT_1}$kernellocation";

  local($result)=&CreateDir("$TFTPDIR/$osinfo{OS}");
  if ($result)
  {
     &UpdateActionProgress($actionid,-2,"Could not create $TFTPDIR/$osinfo{OS}");
     return 2;
  }
  &UpdateActionProgress($actionid,10,"Created/checked os directory $TFTPDIR/$osinfo{OS}");

  local($result)=&WriteOSInfo(%osinfo);
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not write OS information");
    return 1;
  }
  &UpdateActionProgress($actionid,15,"Wrote OS information");

  local($result)=&CreateDir($osinfo{MOUNTPOINT_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not create flavor mount directory $osinfo{MOUNTPOINT_1}");
    return 3;
  }
  &UpdateActionProgress($actionid,20,"Created flavor mount directory $osinfo{MOUNTPOINT_1}");

  local($result)=&MountIso($osinfo{MOUNTFILE_1},$osinfo{MOUNTPOINT_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not mount iso file $osinfo{MOUNTFILE_1} on $osinfo{MOUNTPOINT_1}");
    return 4;
  }
  &UpdateActionProgress($actionid,30,"Mounted iso file $osinfo{MOUNTFILE_1} on $osinfo{MOUNTPOINT_1}");

  local($result)=&ImportFile($vmlinuz,$osinfo{FILE_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not copy vmlinuz $vmlinuz to $osinfo{FILE_1}");
    return 5;
  }
  &UpdateActionProgress($actionid,50,"Copied vmlinuz");

  local($result)=&ImportFile($initrd,$osinfo{FILE_2});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not copy initrd $initrd to $osinfo{FILE_2}");
    return 6;
  }
  &UpdateActionProgress($actionid,60,"Copied initrd");

  local($result)=&WriteOSInfo(%osinfo);
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not rite OS information to file");
    return 7;
  }
  &UpdateActionProgress($actionid,95,"Wrote OS information");

  &UpdateActionProgress($actionid,100,"Successfull");

  #local($result)=&kickstart_ImportOS_DoIt("esx5",$kernellocation,$initrdlocation,$actionid,@otherfiles);
  return 0;
}

1;
