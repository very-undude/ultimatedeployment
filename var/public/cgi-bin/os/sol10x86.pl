#!/usr/bin/perl

require "kickstart.pl";

sub sol10x86_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("sol10x86");
 return $result;
}

sub sol10x86_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub sol10x86_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"sol10x86");
  return ($result);
}


sub sol10x86_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="";
  return $commandline;
}

sub sol10x86_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub sol10x86_GetDefaultConfigFile2
{
  local($template)=@_;
  local($configfile)=$TEMPLATECONFDIR."/$template.cf2";
  return $configfile;
}


sub sol10x86_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub sol10x86_GetDefaultPublishDir
{
  local($templateid)=@_;
  local($publishdir)=$TFTPDIR."/pxelinux.cfg/templates/$templateid";
  return $publishdir;
}

sub sol10x86_GetDefaultPublishDir2
{
  local($template)=@_;
  local($publishdir)=$WWWDIR."/jumpstart/$template";
  return $publishdir;
}


sub sol10x86_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="/pxelinux.cfg/templates/[TEMPLATEID]/pxegrub.0";
  return $kernel;
}

sub sol10x86_CreateTemplate
{
  local($template)=$formdata{TEMPLATE};

  local($result)=&CheckTemplateName($template);
  if ($result)
  {
    return 1;
  }
  local($flavor)=$formdata{OSFLAVOR};
  local($os)=$formdata{OS};
  local($mac)=$formdata{MAC};
  local($description)=$formdata{DESCRIPTION};
  local($publish)="ON";
  if (!defined($formdata{PUBLISH}))
  {
    $publish="OFF";
  }
  local(%config)=();
  $config{TEMPLATE}=$template;
  $config{TEMPLATEID}=&GetNewTemplateID();
  $config{OS}=$os;
  $config{FLAVOR}=$flavor;
  $config{DESCRIPTION}=$description;
  $config{PUBLISH}=$publish;
  $config{MAC}=$mac;
  $config{CONFIGFILE1}=&{$os."_GetDefaultConfigFile1"}($template);
  $config{CONFIGFILE2}=&{$os."_GetDefaultConfigFile2"}($template);
  $config{PUBLISHFILE1}=&{$os."_GetDefaultPublishFile"}($template);
  $config{PUBLISHDIR1}=&{$os."_GetDefaultPublishDir"}($config{TEMPLATEID});
  $config{PUBLISHDIR2}=&{$os."_GetDefaultPublishDir2"}($template);
  $config{CMDLINE}=&{$os."_GetDefaultCommandLine"}($template);
  $config{KERNEL}=&{$os."_GetDefaultKernel"}($template);

  # Copy Template Configuration File\n";
  local($result)=&{$os."_CopyTemplateFile"}($template,$config{CONFIGFILE1});
  if ($result != 0 ) { return $result};

  # misuse the kickstart function to copy the second configfile
  local($result)=&{"kickstart_CopyTemplateFile"}($template,$config{CONFIGFILE2},"sol10x86_anymachine");
  if ($result != 0 ) { return $result};

  # Write Config File
  local($result)=&WriteTemplateInfo(%config);
  if ($result)
  {
    &PrintError("Could not write template info for $template");
    return 1;
  }

  # Create the kickstart publish directry for this template
  local($result)=&CreateDir($config{PUBLISHDIR1});
  if ($result)
  {
    &PrintError("Could not create directory $config{PUBLISHDIR1}");
    return 1;
  }

  # Create the kickstart publish directry for this template
  local($result)=&CreateDir($config{PUBLISHDIR2});
  if ($result)
  {
    &PrintError("Could not create directory $config{PUBLISHDIR2}");
    return 1;
  }

  if ($config{PUBLISH} eq "ON")
  {
    # print "<LI>PUBLISHING template $template\n";
    local($result)=&PublishTemplate($template);
    if ($result)
    {
      &PrintError("Could not publish template $template");
      return 1;
    }
  }

  local($result)=&AddToTemplateSortFile($template);
  if ($result)
  {
    &PrintError("Could not add template $template to the sort file");
    return 1;
  }


  local($result)=&{$os."_WriteTemplatePXEMenu"}($template,%config);
  if ($result)
  {
   &PrintError("Could not write PXE menu for template $template");
   return 1;
  }

  # Writing PXE configuration file
  local($result)=&WriteDefaultFile();
  if ($result)
  {
   &PrintError("Could not write PXE default file");
   return 1;
  }   
   &PrintSuccess("Created template $template");

  return 0;
}


sub sol10x86_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("sol10x86",$template,$desttemplate,%info);
  return $result;
}

sub sol10x86_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"sol10x86");
  return $result;
}

sub sol10x86_ConfigureTemplate
{
  local($template,%config)=@_;

  local(@sysidcfg)=&GetConfigFile($config{CONFIGFILE1});
  local(@anymachine)=&GetConfigFile($config{CONFIGFILE2});

  print "Template ID: $config{TEMPLATEID}<BR>\n";
  print "<BR>\n";
  print "Kernel<BR>\n";
  print "<INPUT TYPE=TEXT NAME=KERNEL SIZE=20 VALUE=\"$config{KERNEL}\"><BR>\n";
  print "<BR>\n";
  
  print "<INPUT TYPE=HIDDEN NAME=TEMPLATEID VALUE=\"$config{TEMPLATEID}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=CONFIGFILE1 VALUE=\"$config{CONFIGFILE1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=CONFIGFILE2 VALUE=\"$config{CONFIGFILE2}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=PUBLISHFILE1 VALUE=\"$config{PUBLISHFILE1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=PUBLISHDIR1 VALUE=\"$config{PUBLISHDIR1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=PUBLISHDIR2 VALUE=\"$config{PUBLISHDIR2}\">\n";
  print "Sysidcfg File<BR>\n";
  print "<TEXTAREA WRAP=OFF NAME=SYSIDCFGFILE ROWS=12 COLS=60>";
  for $line (@sysidcfg)
  {
    print $line;
  }
  print "</TEXTAREA>\n";

  print "<BR><BR>\n";
  print "Machine File<BR>\n";
  print "<TEXTAREA WRAP=OFF NAME=ANYMACHINEFILE ROWS=10 COLS=60>";
  for $line (@anymachine)
  {
    print $line;
  }
  print "</TEXTAREA>\n";

  return 0;
}

sub sol10x86_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  $info{CMDLINE}=$formdata{CMDLINE};
  $info{TEMPLATEID}=$formdata{TEMPLATEID};

 local($orgtemplate)=$formdata{template};
  local($newtemplate)=$formdata{NEWTEMPLATE};

  if ($orgtemplate ne $newtemplate)
  {
    local($newconfigfile)=&{$info{OS}."_GetDefaultConfigFile1"}($newtemplate);
    local($command)="cp $info{CONFIGFILE1} $newconfigfile";
    local($result)=&RunCommand($command,"Copying configuration file $info{CONFIGFILE1} to $newconfigfile");
    $info{CONFIGFILE1}=$newconfigfile;

    local($newconfigfile2)=&{$info{OS}."_GetDefaultConfigFile2"}($newtemplate);
    local($command)="cp $info{CONFIGFILE2} $newconfigfile2";
    local($result)=&RunCommand($command,"Copying configuration file $info{CONFIGFILE2} to $newconfigfile2");
    $info{CONFIGFILE2}=$newconfigfile2;

    $info{PUBLISHFILE1}=&{$info{OS}."_GetDefaultPublishFile"}($newtemplate);
    $info{PUBLISHDIR1}=&{$info{OS}."_GetDefaultPublishDir"}($newtemplate);
    $info{PUBLISHDIR2}=&{$info{OS}."_GetDefaultPublishDir2"}($newtemplate);
  } else {
    $info{CONFIGFILE1}=$formdata{CONFIGFILE1};
    $info{CONFIGFILE2}=$formdata{CONFIGFILE2};
    $info{PUBLISHFILE1}=$formdata{PUBLISHFILE1};
    $info{PUBLISHDIR1}=$formdata{PUBLISHDIR1};
    $info{PUBLISHDIR2}=$formdata{PUBLISHDIR2};
  }

  $info{KERNEL}=$formdata{KERNEL};

  &WriteTemplateInfo(%info);

  local($tempdir)=$TEMPDIR."/sol10x86config.$$";
  local($result)=&CreateDir($tempdir);

  local($sysidcfg)=$formdata{SYSIDCFGFILE};
  local($tmpfile)=$tempdir."/sysidcfg";
  local($result)=open(SUBFILE,">$tmpfile");
  print SUBFILE $sysidcfg;
  close(SUBFILE);
  &RunCommand("cp $tmpfile $formdata{CONFIGFILE1}","Copying temporary file |$tmpfile| to |$formdata{CONFIGFILE1}|\n");

  local($anymachine)=$formdata{ANYMACHINEFILE};
  local($tmpfile)=$tempdir."/any_machine";
  local($result)=open(SUBFILE,">$tmpfile");
  print SUBFILE $anymachine;
  close(SUBFILE);
  &RunCommand("cp $tmpfile $formdata{CONFIGFILE2}","Copying temporary file |$tmpfile| to |$formdata{CONFIGFILE2}|\n");

  local($result)=&RunCommand("rm -rf $tempdir","Removing temporary directory $tempdir");

  return 0;

  return $result;
}

sub sol10x86_PublishTemplate
{
  local($template)=shift;

  local(%info)=&GetTemplateInfo($template);

  local(%subinfo)=&GetAllSubTemplateInfo($template);
  local($templateid)=$info{TEMPLATEID};
  # print "<H1>templateid =|$templateid|</H1>\n";

  # Copy the three initialising files to the publishdir
  local($templateidstring)=sprintf("me%02d.lst",$templateid);

  local($kernel)=$info{PUBLISHDIR1}."/pxegrub.0";
  local($result)=&ImportFile($TFTPDIR."/pxegrub.$info{OS}.$info{FLAVOR}",$kernel);

  local($command)="sed -i -e 's/menu\.lst/$templateidstring/gi' $kernel";
  local($result)=&RunCommand($command,"Patching the kernel");

  local($kernelline)="  kernel /multiboot.[OS].[FLAVOR] kernel/unix -v m verbose install http://[UDA_IPADDR]/jumpstart/[TEMPLATE]/[SUBTEMPLATE].tar -B install_media=[UDA_IPADDR]:/solaris/[FLAVOR]";
  local($moduleline)="  module x86.miniroot.[OS].[FLAVOR]";

  local(@indexes)=keys(%subinfo);
  if ($#indexes<0)
  {
    local($result)=open(MENUFILE,">$info{PUBLISHDIR1}/menu.lst");
    $info{SUBTEMPLATE}="default";
    print MENUFILE "timeout=3\n";
    print MENUFILE "\n";
    print MENUFILE "title Ultimate Deployment Appliance Template $template\n";
    print MENUFILE &FindAndReplace($kernelline,%info)."\n";
    print MENUFILE &FindAndReplace($moduleline,%info)."\n";
    close(MENUFILE);
    
    local($result)=&sol10x86_CreateTarFile(%info);

  } else {
      local($headerline)=$subinfo{__HEADER__};
      local($result)=open(MENUFILE,">$info{PUBLISHDIR1}/menu.lst");
      print MENUFILE "timeout=3\n";
      for $sub (keys(%subinfo))
      {
       if ($sub ne "__HEADER__")
       {
         # print "<LI>Publishsing subtemplate $sub\n";
         local(%subinfo)=&GetSubTemplateInfo($headerline,$subinfo{$sub},%info);

         print MENUFILE "\n";
         print MENUFILE "title Ultimate Deployment Appliance Sub Template $subinfo{SUBTEMPLATE}\n";
         print MENUFILE &FindAndReplace($kernelline,%subinfo)."\n";
         print MENUFILE &FindAndReplace($moduleline,%subinfo)."\n";
 
        local($result)=&sol10x86_CreateTarFile(%subinfo);
      }
    }
    close(MENUFILE);
  }
}


sub sol10x86_CreateTarFile
{
  local(%info)=@_;

  local($filename)=$info{PUBLISHDIR2}."/".$info{SUBTEMPLATE}.".tar";

  local($tempdir)=$TMPDIR."/sol10x86template.$$";

  local($result)=&CreateDir($tempdir);

  local(@configfile1)=&GetConfigFile($info{CONFIGFILE1});
  local($result)=open(SYSIDCFG,">$tempdir/sysidcfg");
  for $line (@configfile1)
  {
    local($newline)=&FindAndReplace($line,%info);
    print SYSIDCFG $newline;
  }
  print SYSIDCFG "\n";
  close(SYSIDCFG);

  local(@configfile2)=&GetConfigFile($info{CONFIGFILE2});
  local($result)=open(ANYMACHINE,">$tempdir/any_machine");
  for $line (@configfile2)
  {
    local($newline)=&FindAndReplace($line,%info);
    print ANYMACHINE $newline;
  }
  print ANYMACHINE "\n";
  close(ANYMACHINE);

  local($rulesfile)="$tempdir/rules";
  local($result)=open(RULESFILE,">$rulesfile");
  print RULESFILE "# The following rule matches any system:\n";
  print RULESFILE "# rule_keyword   rule_value   begin     profile    finish\n
";
  print RULESFILE "any              -               begin.sh    any_machine  -\n";
  close (RULESFILE);

  local($rulesokfile)="$tempdir/rules.ok";
  local($result)=open(RULESOKFILE,">$rulesokfile");
  print RULESOKFILE "any - - any_machine -\n";
  print RULESOKFILE "# version=2 checksum=num\n";
  close (RULESOKFILE);

  local($beginfile)="$tempdir/begin.sh";
  local($result)=open(BEGINFILE,">$beginfile");
  print BEGINFILE "echo Skipping mount, since nfs4 seems to work properly\n";
  print BEGINFILE "# mount -F nfs -o vers=3 [UDA_IPADDR]:/ /cdrom \n";
  close (BEGINFILE);


  local($command)="tar -cf $filename -C $tempdir rules rules.ok sysidcfg any_machine begin.sh";
 
  local($result)=&RunCommand($command,"Creating tarfile $filename for solaris template $template");

  local($result)=&RunCommand("rm -rf $tempdir","Removing temporary directory $tempdir");


  return 0;
}

sub sol10x86_NewOS_2
{
 local($result)=&kickstart_NewOS_2("sol10x86");
 return result;
}

sub sol10x86_ImportOS
{
 local($result)=&kickstart_ImportOS("sol10x86");
  return $result;
}

sub sol10x86_ImportOS_DoIt
{
  local($actionid)=shift;

  local($minirootlocation)="/boot/x86.miniroot";
  local($kernellocation)="/boot/multiboot";
  local($grublocation)="/boot/grub/pxegrub";

  require "general.pl";
  require "config.pl";
  require "action.pl";

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) { 
    &UpdateActionProgress($actionid,-1,"Could not read arguments"); 
    return 1;
  }

  local(%mountinfo)=&GetMountInfo($args{MOUNT});
  local(%osinfo)=();
  $osinfo{FLAVOR}=$args{"OSFLAVOR"};
  $osinfo{OS}="sol10x86";
  $osinfo{MOUNTFILE_1}=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{FILE1};
  if ($mountinfo{TYPE} eq "CDROM")
  {
    $osinfo{MOUNTFILE_1}=$mountinfo{SHARE};
  }
  $osinfo{MOUNTPOINT_1}="/solaris/$osinfo{FLAVOR}";
  $osinfo{FILE_1}="$TFTPDIR/multiboot.$osinfo{OS}.$osinfo{FLAVOR}";
  $osinfo{FILE_2}="$TFTPDIR/x86.miniroot.$osinfo{OS}.$osinfo{FLAVOR}";
  $osinfo{FILE_3}="$TFTPDIR/pxegrub.$osinfo{OS}.$osinfo{FLAVOR}";
  $osinfo{MOUNTONBOOT}=$args{MOUNTONBOOT};
  $osinfo{NFSEXPORT_1}="/solaris/$osinfo{FLAVOR}";
  $osinfo{NFSEXPORTOPTIONS_1}="*(ro,nohide,insecure,no_root_squash,no_subtree_check,async)";

  local($miniroot)="$osinfo{MOUNTPOINT_1}$minirootlocation";
  local($kernel)="$osinfo{MOUNTPOINT_1}$kernellocation";
  local($pxegrub)="$osinfo{MOUNTPOINT_1}$grublocation";

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

  local($result)=&ImportFile($kernel,$osinfo{FILE_1});
  if ($result) 
  { 
    &UpdateActionProgress($actionid,-2,"Could not copy kernel"); 
    return 5;
  }
  &UpdateActionProgress($actionid,50,"Copied kernel");

  local($result)=&ImportFile($miniroot,$osinfo{FILE_2});
  if ($result) 
  { 
    &UpdateActionProgress($actionid,-2,"Could not copy miniroot"); 
    return 6;
  }
  &UpdateActionProgress($actionid,90,"Copied miniroot");

  local($result)=&ImportFile($pxegrub,$osinfo{FILE_3});
  if ($result) 
  { 
    &UpdateActionProgress($actionid,-2,"Could not copy pxegrub"); 
    return 6;
  }
  &UpdateActionProgress($actionid,90,"Copied pxegrub");

  local($result)=&RebuildNFSExports();
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not rebuild NFS exports file"); 
    return 7;
  }
  &UpdateActionProgress($actionid,93,"Rebuilt NFS exports file");
  
  local($result)=&WriteOSInfo(%osinfo);
  if ($result) 
  { 
    &UpdateActionProgress($actionid,-2,"Could not write OS information to file"); 
    return 8;
  }
  &UpdateActionProgress($actionid,95,"Wrote OS information");

  &UpdateActionProgress($actionid,100,"Successfull");

  return 0;
}

1;
