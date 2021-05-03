#!/usr/bin/perl

require "kickstart.pl";

sub sol10sparc_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("sol10sparc");
 return $result;
}

sub sol10sparc_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"sol10sparc");
  return ($result);
}


sub sol10sparc_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub sol10sparc_GetDefaultConfigFile2
{
  local($template)=@_;
  local($configfile)=$TEMPLATECONFDIR."/$template.cf2";
  return $configfile;
}


sub sol10sparc_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=$FILESDIR."/dhcpd.d/$template.conf";
  return $publishfile;
}

sub sol10sparc_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=$WWWDIR."/jumpstart/$template";
  return $publishdir;
}

sub sol10sparc_CreateTemplate
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
  # $config{PUBLISHFILE1}=&{$os."_GetDefaultPublishFile"}($template);
  $config{PUBLISHDIR1}=&{$os."_GetDefaultPublishDir"}($template);

  # Copy Template Configuration File\n";
  local($result)=&{$os."_CopyTemplateFile"}($template,$config{CONFIGFILE1});
  if ($result != 0 ) { return $result};

  # misuse the kickstart function to copy the second configfile
  local($result)=&{"kickstart_CopyTemplateFile"}($template,$config{CONFIGFILE2},"sol10sparc_anymachine");
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

   &PrintSuccess("Created template $template");

  return 0;
}


sub sol10sparc_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("sol10sparc",$template,$desttemplate,%info);
  return $result;
}

sub sol10sparc_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"sol10sparc");

  local($command)="rm -f $FILESDIR/dhcpd.d/$template.conf";
  local($result)=&RunCommand($command,"Deleting dhcp config file for template $template");
  if ($result) { return $result; }

  local($result)=&sol10sparc_CreateDhcpIncludeFile();
  if ($result) { return $result; }

  local($command)="/sbin/service dhcpd restart";
  local($result)=&RunCommand($command,"Restarting dhcp service");
  if ($result) { return $result; }

  return $result;
}

sub sol10sparc_ConfigureTemplate
{
  local($template,%config)=@_;

  local(@sysidcfg)=&GetConfigFile($config{CONFIGFILE1});
  local(@anymachine)=&GetConfigFile($config{CONFIGFILE2});

  print "Template ID: $config{TEMPLATEID}<BR>\n";
  print "<BR>\n";
  #print "Kernel<BR>\n";
  #print "<INPUT TYPE=TEXT NAME=KERNEL SIZE=20 VALUE=\"$config{KERNEL}\"><BR>\n";
  #print "<BR>\n";
  
  print "<INPUT TYPE=HIDDEN NAME=TEMPLATEID VALUE=\"$config{TEMPLATEID}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=CONFIGFILE1 VALUE=\"$config{CONFIGFILE1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=CONFIGFILE2 VALUE=\"$config{CONFIGFILE2}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=PUBLISHDIR1 VALUE=\"$config{PUBLISHDIR1}\">\n";
  # print "<INPUT TYPE=HIDDEN NAME=PUBLISHFILE1 VALUE=\"$config{PUBLISHFILE1}\">\n";
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

sub sol10sparc_ApplyConfigureTemplate
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
  } else {
    $info{CONFIGFILE1}=$formdata{CONFIGFILE1};
    $info{CONFIGFILE2}=$formdata{CONFIGFILE2};
    $info{PUBLISHDIR1}=$formdata{PUBLISHDIR1};
    # $info{PUBLISHFILE1}=$formdata{PUBLISHFILE1};
  }

  $info{KERNEL}=$formdata{KERNEL};

  &WriteTemplateInfo(%info);

  local($tempdir)=$TEMPDIR."/sol10sparcconfig.$$";
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

sub sol10sparc_PublishTemplate
{
  local($template)=shift;
   
  # print "Now Publishing template $template\n";

  local(%info)=&GetTemplateInfo($template);

  local(%subinfo)=&GetAllSubTemplateInfo($template);

  local(@indexes)=keys(%subinfo);
  if ($#indexes<0)
  {
    $info{SUBTEMPLATE}="default";
    local($result)=&sol10sparc_CreateTarFile(%info);

  } else {
      local($headerline)=$subinfo{__HEADER__};
      for $sub (keys(%subinfo))
      {
       if ($sub ne "__HEADER__")
       {
         # print "<LI>Publishsing subtemplate $sub\n";
         local(%subinfo)=&GetSubTemplateInfo($headerline,$subinfo{$sub},%info);
         local($result)=&sol10sparc_CreateTarFile(%subinfo);
      }
    }
    close(MENUFILE);
  }

  local($result)=&sol10sparc_CreateTemplateDhcpConfig(%info);
  if ($result) { return $result; }

  local($result)=&sol10sparc_CreateDhcpIncludeFile();
  if ($result) { return $result; }

  local($command)="/sbin/service dhcpd restart";
  local($result)=&RunCommand($command,"Restarting dhcp service");
  if ($result) { return $result; }

  $info{NFSEXPORT_1}=$info{PUBLISHDIR1};
  $info{NFSEXPORTOPTIONS_1}="*(ro,nohide,insecure,no_root_squash,no_subtree_check,async)";

   local($result)=&WriteTemplateInfo(%info);

   local($result)=&RebuildNFSExports();
   if($result)
   {
     return $result;
   }
  return 0;
}

sub sol10sparc_CreateDhcpIncludeFile
{
  # print "<LI>Now creating include file\n";
  local($dhcpdddir)=$FILESDIR."/dhcpd.d";
  local($dhcpdinclude)=$FILESDIR."/dhcpd.d.conf";
  local($result)=open(INCLUDEFILE,">$dhcpdinclude");
  print INCLUDEFILE "# This is the include list for the uda templates\n";
  local($result)=opendir(DDIR,$dhcpdddir);
  while($fn=readdir(DDIR))
  {
   # print "<LI>Checking file $fn\n";
    if ($fn =~ /\.conf$/)
    {
      #print "<LI>found file $fn\n";
      print INCLUDEFILE "include \"$dhcpdddir/$fn\" ;\n";
    }
  }
  closedir(DDIR);
  close(INCLUDEFILE);
  return 0;
}

sub sol10sparc_CreateTemplateDhcpConfig
{
  local(%info)=@_;
  local(%system)=&GetSystemVariables();

  local($filename)=$FILESDIR."/dhcpd.d/".$info{TEMPLATE}.".conf";

  local($result)=open(DHCPCONF,">$filename");
  print DHCPCONF "group {\n";
  print DHCPCONF "vendor-option-space SUNW;\n";
  print DHCPCONF "option SUNW.install-server-hostname \"uda\";\n";
  print DHCPCONF "option SUNW.install-server-ip-address $system{UDA_IPADDR};\n";
  print DHCPCONF "option SUNW.install-path \"/solaris10sparc/$info{FLAVOR}\";\n";
  print DHCPCONF "option SUNW.root-server-hostname \"uda\";\n";
  print DHCPCONF "option SUNW.root-server-ip-address $system{UDA_IPADDR};\n";
  print DHCPCONF "option SUNW.root-path-name \"/solaris10sparc/$info{FLAVOR}/Solaris_10/Tools/Boot\";\n";
  print DHCPCONF "next-server $system{UDA_IPADDR};\n";
  print DHCPCONF "if option vendor-class-identifier = \"SUNW.Sun-Fire-T1000\" or\n";
  print DHCPCONF "   option vendor-class-identifier = \"SUNW.Sun-Fire-T200\" {\n";
  print DHCPCONF "     filename \"inetboot.sun4v.$info{OS}.$info{FLAVOR}\";\n";
  print DHCPCONF " } else {\n";
  print DHCPCONF "     filename \"inetboot.sun4u.$info{OS}.$info{FLAVOR}\";\n";
  print DHCPCONF " }\n";
  local(%subinfo)=&GetAllSubTemplateInfo($info{TEMPLATE});

  local(@indexes)=keys(%subinfo);
  if ($#indexes<0)
  {
    $info{SUBTEMPLATE}="default";
    print DHCPCONF "  host $info{TEMPLATE}-$info{SUBTEMPLATE} {\n";
    print DHCPCONF "    hardware ethernet $info{MAC} ;\n";
    print DHCPCONF "    option SUNW.sysid-config-file-server \"uda:/var/public/www/jumpstart/$info{TEMPLATE}/$info{SUBTEMPLATE}\";\n";
    print DHCPCONF "    option SUNW.JumpStart-server \"uda:/var/public/www/jumpstart/$info{TEMPLATE}/$info{SUBTEMPLATE}\";\n";
    print DHCPCONF "  }\n";
  } else {
      local($headerline)=$subinfo{__HEADER__};
      for $sub (keys(%subinfo))
      {
       if ($sub ne "__HEADER__")
       {
         # print "<LI>Publishsing subtemplate $sub\n";
         local(%subinfo)=&GetSubTemplateInfo($headerline,$subinfo{$sub},%info);
         print DHCPCONF "  host $subinfo{TEMPLATE}-$subinfo{SUBTEMPLATE} {\n";
         print DHCPCONF "    hardware ethernet $subinfo{MAC} ;\n";
         print DHCPCONF "    option SUNW.sysid-config-file-server \"uda:/var/public/www/jumpstart/$subinfo{TEMPLATE}/$subinfo{SUBTEMPLATE}\";\n";
         print DHCPCONF "    option SUNW.JumpStart-server \"uda:/var/public/www/jumpstart/$subinfo{TEMPLATE}/$subinfo{SUBTEMPLATE}\";\n";
         print DHCPCONF "  }\n";
      }
    }
    close(MENUFILE);
  }
  print DHCPCONF "}\n";
  close(DHCPCONF);
 
  return 0;
}

sub sol10sparc_CreateTarFile
{
  local(%info)=@_;

  local($filename)=$info{PUBLISHDIR1}."/".$info{SUBTEMPLATE}.".tar";

  local($tempdir)=$WWWDIR."/jumpstart/".$info{TEMPLATE}."/".$info{SUBTEMPLATE};

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

  return 0;
}

sub sol10sparc_NewOS_2
{
 local($result)=&kickstart_NewOS_2("sol10sparc");
 return result;
}

sub sol10sparc_ImportOS
{
 local($result)=&kickstart_ImportOS("sol10sparc");
  return $result;
}

sub sol10sparc_ImportOS_DoIt
{
  local($actionid)=shift;

  local($kernellocation1)="/Solaris_10/Tools/Boot/usr/platform/sun4u/lib/fs/nfs/inetboot";
  local($kernellocation2)="/Solaris_10/Tools/Boot/usr/platform/sun4v/lib/fs/nfs/inetboot";
  local($kernellocation3)="/Solaris_10/Tools/Boot/usr/platform/sun4us/lib/fs/nfs/inetboot";

  local($kernellocation1a)="/Solaris_10/Tools/Boot/platform/sun4u/inetboot";
  local($kernellocation2a)="/Solaris_10/Tools/Boot/platform/sun4us/inetboot";
  local($kernellocation3a)="/Solaris_10/Tools/Boot/platform/sun4v/inetboot";

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
  $osinfo{OS}="sol10sparc";
  $osinfo{MOUNTFILE_1}=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{FILE1};
  if ($mountinfo{TYPE} eq "CDROM")
  {
    $osinfo{MOUNTFILE_1}=$mountinfo{SHARE};
  }
  $osinfo{MOUNTPOINT_1}="/solaris10sparc/$osinfo{FLAVOR}";
  $osinfo{FILE_1}="$TFTPDIR/inetboot.sun4u.$osinfo{OS}.$osinfo{FLAVOR}";
  $osinfo{FILE_2}="$TFTPDIR/inetboot.sun4v.$osinfo{OS}.$osinfo{FLAVOR}";
  $osinfo{FILE_3}="$TFTPDIR/inetboot.sun4us.$osinfo{OS}.$osinfo{FLAVOR}";
  $osinfo{MOUNTONBOOT}=$args{MOUNTONBOOT};
  $osinfo{NFSEXPORT_1}="/solaris10sparc/$osinfo{FLAVOR}";
  $osinfo{NFSEXPORTOPTIONS_1}="*(ro,nohide,insecure,no_root_squash,no_subtree_check,async)";

  local($kernel1)="$osinfo{MOUNTPOINT_1}$kernellocation1";
  local($kernel2)="$osinfo{MOUNTPOINT_1}$kernellocation2";
  local($kernel3)="$osinfo{MOUNTPOINT_1}$kernellocation3";

  local($kernel1a)="$osinfo{MOUNTPOINT_1}$kernellocation1a";
  local($kernel2a)="$osinfo{MOUNTPOINT_1}$kernellocation2a";
  local($kernel3a)="$osinfo{MOUNTPOINT_1}$kernellocation3a";

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

  local($result)=&ImportFile($kernel1,$osinfo{FILE_1});
  if ($result) 
  { 
    local($result)=&ImportFile($kernel1a,$osinfo{FILE_1});
    if ($result) 
    { 
      &UpdateActionProgress($actionid,-2,"Could not copy kernel inetboot for sun4u"); 
      return 5;
    }
  }
  &UpdateActionProgress($actionid,50,"Copied kernel inetboot for sun4u");

  local($result)=&ImportFile($kernel2,$osinfo{FILE_2});
  if ($result) 
  { 
    local($result)=&ImportFile($kernel2a,$osinfo{FILE_2});
    if ($result) 
    {
      &UpdateActionProgress($actionid,-2,"Could not copy kernel inetboot for sun4v"); 
      return 5;
    }
  }
  &UpdateActionProgress($actionid,70,"Copied kernel inetboot for sun4v");

  local($result)=&ImportFile($kernel3,$osinfo{FILE_3});
  if ($result) 
  { 
    local($result)=&ImportFile($kernel3a,$osinfo{FILE_3});
    if ($result) 
    {
      &UpdateActionProgress($actionid,-2,"Could not copy kernel inetboot for sun4us"); 
      return 5;
    }
  }
  &UpdateActionProgress($actionid,90,"Copied kernel inetboot for sun4us");


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
