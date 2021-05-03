#!/usr/bin/perl

sub kickstart_NewTemplate_Finish
{
 local($kickstartos)=shift;

 print "<CENTER>\n";
 print "<H2>New Template Wizard Confirm</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 local($publish)="ON";
 if (!defined($formdata{PUBLISH})) 
 { 
  $publish = "OFF" ;
 }
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=templates>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=$kickstartos>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MAC VALUE=\"$formdata{MAC}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=PUBLISH VALUE=\"$publish\">\n";
 print "<INPUT TYPE=HIDDEN NAME=DESCRIPTION VALUE=\"$formdata{DESCRIPTION}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=TEMPLATE VALUE=\"$formdata{TEMPLATENAME}\">\n";
 for $item (keys(%formdata))
 {
   if ($item =~ /^KICKSTART_(.+)/)
   {
      print "<INPUT TYPE=HIDDEN NAME=$item VALUE=\"$formdata{$item}\">\n";
   }
 }
 print "<script language='javascript' src='/js/$kickstartos.js'></script>\n";
 print "<script language='javascript' src='/js/newtemplate.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR>\n";
 print "<TABLE>\n";
 print "<TR><TD>Template Name</TD><TD>$formdata{TEMPLATENAME}</TD></TR>\n";
 print "<TR><TD>Operating System</TD><TD>$kickstartos</TD></TR>\n";
 print "<TR><TD>Flavor</TD><TD>$formdata{OSFLAVOR}</TD></TR>\n";
 print "<TR><TD>Description</TD><TD>$formdata{DESCRIPTION}</TD></TR>\n";
 print "<TR><TD>MAC</TD><TD>$formdata{MAC}</TD></TR>\n";
 print "<TR><TD>Publish</TD><TD>$publish</TD></TR>\n";
 for $item (keys(%formdata))
 {
   if ($item =~ /^KICKSTART_(.+)/)
   {
      local($displayname)=$1;
      print "<TR><TD>$displayname</TD><TD>$formdata{$item}</TD></TR>\n";
   }
 }
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "</CENTER>\n";
}

sub kickstart_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($kickstartos)=shift;
  $destfile =~ s/\[TEMPLATE\]/$template/g ;
  local($kickstart_templatefile)=$TEMPLATEDIR."/$kickstartos.tpl";
  local($result)=&ImportFile($kickstart_templatefile,$destfile);
  if ($result != 0 ) { return $result};
  return 0;
}

sub kickstart_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] ramdrive_size=8192";
  return $commandline;
}

sub kickstart_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=$TEMPLATECONFDIR."/$template.cfg";
  return $configfile;
}

sub kickstart_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=$WWWDIR."/kickstart/$template/[SUBTEMPLATE].cfg";
  return $publishfile;
}

sub kickstart_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=$WWWDIR."/kickstart/$template";
  return $publishdir;
}

sub kickstart_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub kickstart_CreateTemplate
{
  local($kickstartos)=shift;

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
  $config{OS}=$os;
  $config{FLAVOR}=$flavor;
  $config{DESCRIPTION}=$description;
  $config{PUBLISH}=$publish;
  $config{MAC}=$mac;
  $config{CONFIGFILE1}=&{$kickstartos."_GetDefaultConfigFile1"}($template);
  $config{PUBLISHFILE1}=&{$kickstartos."_GetDefaultPublishFile"}($template);
  $config{PUBLISHDIR1}=&{$kickstartos."_GetDefaultPublishDir"}($template);
  $config{CMDLINE}=&{$kickstartos."_GetDefaultCommandLine"}($template);
  $config{KERNEL}=&{$kickstartos."_GetDefaultKernel"}($template);
  for $item (keys(%formdata))
  {
    if ($item =~ /^KICKSTART_(.+)/)
    {
      $config{$item}=$formdata{$item};
    }
  }

  local($requirefile)=$OSDIR."/".$config{OS}.".pl";
  if ( -f $requirefile)
  {
    require $requirefile ; 
  }

  if(defined(&{$config{OS}."_ExtraConfiguration"}))
  {
     local(%extrainfo)=&{$config{OS}."_ExtraConfiguration"}();
     for $thekey (keys(%extrainfo))
     {
       $config{$thekey}=$extrainfo{$thekey};
     }
  }

  # Copy Template Configuration File\n";
  local($result)=&{$kickstartos."_CopyTemplateFile"}($template,$config{CONFIGFILE1});
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
  

  local($result)=&{$kickstartos."_WriteTemplatePXEMenu"}($template,%config);
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

sub kickstart_CopyTemplate
{
  local($kickstartos,$template,$desttemplate,%info)=@_;

  # Copy the CONFIGFILE1
  local($orgfile)=$info{CONFIGFILE1};
  local($destfile)=&{$kickstartos."_GetDefaultConfigFile1"}($desttemplate);

  local($result)=&RunCommand("cp $orgfile $destfile","Copying $orgfile to $destfile");
  if ($result)
  {
    &PrintError("Could not copy kickstart file");
    return 1;
  }

  $info{CONFIGFILE1}=$destfile;
  $info{TEMPLATE}=$desttemplate;
  
  # Generate new information
  $info{PUBLISHFILE1}=&{$kickstartos."_GetDefaultPublishFile"}($info{TEMPLATE});
  $info{PUBLISHDIR1}=&{$kickstartos."_GetDefaultPublishDir"}($info{TEMPLATE});

  local($result)=&WriteTemplateInfo(%info);
  if ($result)
  {
    &PrintError("Could not write template info");
    return 1;
  }
  return 0;
}

sub kickstart_DeleteTemplate
{
  local($template)=shift;
  local($kickstartos)=shift;

  # do some kickstart stuff here when needed

  return 0;
}

sub kickstart_ConfigureTemplate
{
  local($kickstartos,$template,%config)=@_;

  print "Kernel<BR>\n";
  print "<INPUT TYPE=TEXT NAME=KERNEL SIZE=20 VALUE=\"$config{KERNEL}\"><BR>\n";
  print "<BR>\n";
  print "Kernel option command-line<BR>\n";
  print "<INPUT TYPE=TEXT NAME=CMDLINE SIZE=60 VALUE=\"$config{CMDLINE}\"><BR>\n";
  print "<BR>\n";
   
  for $item (keys(%config))
  {
    # print "<LI>$item\n";
    if ($item =~ /^KICKSTART_(.*)/)
    {
      local($name)=$1;
      print "$name<BR>\n";
      print "<INPUT TYPE=TEXT NAME=$item SIZE=60 VALUE=\"$config{$item}\"><BR>\n";
      print "<BR>\n";
    }
  }

  print "Kickstart File<BR>\n";
  local(@kickstart)=&GetConfigFile($config{CONFIGFILE1});
  print "<INPUT TYPE=HIDDEN NAME=CONFIGFILE1 VALUE=\"$config{CONFIGFILE1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=PUBLISHFILE1 VALUE=\"$config{PUBLISHFILE1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=PUBLISHDIR1 VALUE=\"$config{PUBLISHDIR1}\">\n";
  print "<TEXTAREA WRAP=OFF NAME=KICKSTARTFILE ROWS=20 COLS=60>";
  for $line (@kickstart)
  {
    print $line;
  }
  print "</TEXTAREA>\n";
  return 0;
}

sub kickstart_ApplyConfigureTemplate
{
  local($kickstartos,$template,%info)=@_;

  local($orgtemplate)=$formdata{template};
  local($newtemplate)=$formdata{NEWTEMPLATE};
  
  if ($orgtemplate ne $newtemplate)
  {
    local($newconfigfile)=&{$info{OS}."_GetDefaultConfigFile1"}($newtemplate);
    local($command)="cp $info{CONFIGFILE1} $newconfigfile";
    local($result)=&RunCommand($command,"Copying configuration file $info{CONFIGFILE1} to $newconfigfile");
    $info{CONFIGFILE1}=$newconfigfile;
    $info{PUBLISHFILE1}=&{$info{OS}."_GetDefaultPublishFile"}($newtemplate);
    $info{PUBLISHDIR1}=&{$info{OS}."_GetDefaultPublishDir"}($newtemplate);
  } else {
    $info{CONFIGFILE1}=$formdata{CONFIGFILE1};
    $info{PUBLISHFILE1}=$formdata{PUBLISHFILE1};
    $info{PUBLISHDIR1}=$formdata{PUBLISHDIR1};
  }

  $info{CMDLINE}=$formdata{CMDLINE};
  $info{KERNEL}=$formdata{KERNEL};

  for $item (keys(%formdata))
  {
    if ($item =~ /KICKSTART_(.*)/)
    {
      $info{$item}=$formdata{$item};
    }
  }

  &WriteTemplateInfo(%info);

  local($kickstartfile)=$formdata{KICKSTARTFILE};
  local($tmpfile)=$TEMPDIR."/$template.cfg.$$";
  local($result)=open(SUBFILE,">$tmpfile");
  print SUBFILE $kickstartfile;
  close(SUBFILE);

  local($command)="/usr/bin/dos2unix $tmpfile";
  local($result)=&RunCommand($command,"Forcing unix file format");

  &RunCommand("cp $tmpfile $formdata{CONFIGFILE1}","Copying temporary file |$tmpfile| to |$formdata{CONFIGFILE1}|\n");
  unlink($tmpfile);

  return 0;
}


sub kickstart_NewOS_2
{
 local($kickstartos)=shift;

 local($osflavor)=$formdata{OSFLAVOR};
 print "<CENTER>\n"; 
 print "<H2>New Operating System Wizard Step 2</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=$kickstartos>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<script language='javascript' src='/js/$kickstartos.js'></script>\n";
 print "<script language='javascript' src='/js/kickstartnewos.js'></script>\n";
 print "<script language='javascript' src='/js/newos.js'></script>\n";
 print "<script language='javascript' src='/js/validation.js'></script>\n";
 print "<script language='javascript' src='/js/tree.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR><BR>\n";
 local(@mountlist)=&GetMountList();;
 &PrintJavascriptArray("mountsarray",@mountlist);
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<TABLE>\n";
 print "<TR><TD>Storage</TD><TD><SELECT NAME=MOUNT ID=MOUNT ONCHANGE=\"expand('/')\"></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile</TD><TD><INPUT TYPE=TEXT NAME=FILE1 ID=FILE1 SIZE=60 VALUE='/'></TD></TR>\n";
 print "<TR><TD COLSPAN=2><DIV ID=browse_div></DIV></TD></TR>\n";
 print "<TR><TD>Mount on Boot</TD><TD><INPUT TYPE=CHECKBOX NAME=MOUNTONBOOT CHECKED></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "<script language='javascript'>\n";
 print "LoadValues(\"MOUNT\",mountsarray);\n";
 print "expand('/');\n";
 print "</script>\n";
 print "</CENTER>\n";
}

sub kickstart_ImportOS
{
 local($kickstartos)=shift;

 local($flavor)=$formdata{OSFLAVOR};
 local($mount)=$formdata{MOUNT};
 local($file1)=$formdata{FILE1};
 if (defined($formdata{MOUNTONBOOT}))
 {
    $formdata{MOUNTONBOOT}="TRUE";
 } else {
   $formdata{MOUNTONBOOT}=FALSE;
 }
 local($mountonboot)=$formdata{MOUNTONBOOT};

 require "action.pl";

 print "<CENTER>\n";
 print "<H2>New Operating System Import</H2>\n";
 print "</CENTER>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 local($actionid)=$$;
 print "<INPUT TYPE=HIDDEN NAME=actionid ID=actionid VALUE=\"$actionid\">\n";
 
  print "<CENTER>\n";
  print "<TABLE>\n";
  print "<TR><TD>Operating System</TD><TD>$kickstartos</TD></TR>\n";
  print "<TR><TD>Flavor Name</TD><TD>$flavor</TD></TR>\n";
  print "<TR><TD>Mount</TD><TD>$mount</TD></TR>\n";
  print "<TR><TD>File 1</TD><TD>$file1</TD></TR>\n";
  print "<TR><TD>Mount on boot</TD><TD>$mountonboot</TD></TR>\n";
  #print "<TR><TD>Action ID</TD><TD>$actionid</TD></TR>\n";
  print "<TR><TD>Action ID</TD><TD><A HREF='uda3.pl?module=system&action=actions&button=view&actionid=$actionid'>$actionid</A></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";
  
  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Import flavor $flavor ($kickstartos)","os/$kickstartos.pl","\&$kickstartos\_ImportOS_DoIt($actionid);");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";

}

sub basename 
{
  my $file = shift;
  if ($file =~  /\//)
  {
    $file =~ s/.*\/([^\/]+)$/$1/g;
  }
  return $file;
}

sub kickstart_ImportOS_DoIt
{
  local($kickstartos)=shift;
  local($kernellocation)=shift;
  local($initrdlocation)=shift;
  local($actionid)=shift;
  local(@otherfiles)=@_;

  require "general.pl";
  require "config.pl";
  require "action.pl";

  local(@kernellocations)=split(";",$kernellocation);
  local(@initrdlocations)=split(";",$initrdlocation);

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) { 
    &UpdateActionProgress($actionid,-1,"Could not read arguments"); 
    return 1;
  }

  local(%mountinfo)=&GetMountInfo($args{MOUNT});
  local(%osinfo)=();
  $osinfo{FLAVOR}=$args{"OSFLAVOR"};
  $osinfo{OS}=$kickstartos;
  $osinfo{MOUNTFILE_1}=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{FILE1};
  if ($mountinfo{TYPE} eq "CDROM")
  {
    $osinfo{MOUNTFILE_1}=$mountinfo{SHARE};
  }
  $osinfo{MOUNTPOINT_1}="$WWWDIR/$osinfo{OS}/$osinfo{FLAVOR}";
  $osinfo{FILE_1}="$TFTPDIR/vmlinuz.$osinfo{OS}.$osinfo{FLAVOR}";
  $osinfo{FILE_2}="$TFTPDIR/initrd.$osinfo{OS}.$osinfo{FLAVOR}";
  $osinfo{MOUNTONBOOT}=$args{MOUNTONBOOT};

  local($result)=&CreateDir("$WWWDIR/$osinfo{OS}");
  if ($result) 
  { 
     &UpdateActionProgress($actionid,-2,"Could not create $WWWDIR/$osinfo{OS}"); 
     return 2;
  }
  &UpdateActionProgress($actionid,10,"Created/checked os directory $WWWDIR/$osinfo{OS}");

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

   
  local($initrd)="$osinfo{MOUNTPOINT_1}$initrdlocation";
  for $checkinitrdlocation (@initrdlocations)
  {
    if (-e "$osinfo{MOUNTPOINT_1}$checkinitrdlocation")
    {
      $initrd="$osinfo{MOUNTPOINT_1}$checkinitrdlocation";
    }
  }

  local($vmlinuz)="$osinfo{MOUNTPOINT_1}$kernellocation";
  for $checkkernellocation (@kernellocations)
  {
    if (-e "$osinfo{MOUNTPOINT_1}$checkkernellocation")
    {
      $vmlinuz="$osinfo{MOUNTPOINT_1}$checkkernellocation";
    }
  }

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

  local($filenum)=3;
  for $file (@otherfiles)
  {
     local($filestring)=sprintf("FILE_%d",$filenum);
     local($basename)=&basename($file);
     $osinfo{$filestring}="$TFTPDIR/$osinfo{OS}.$osinfo{FLAVOR}.$basename";
     local($result)=&ImportFile($osinfo{MOUNTPOINT_1}."/".$file,$osinfo{$filestring});
     if ($result) 
     { 
       &UpdateActionProgress($actionid,-2,"Could not copy file $file to $osinfo{$filestring}"); 
       return 6;
     }
     &UpdateActionProgress($actionid,70+$filenum,"Copied $file");
     $filenum++;
  }
  local($result)=&WriteOSInfo(%osinfo);
  if ($result) 
  { 
    &UpdateActionProgress($actionid,-2,"Could not rite OS information to file"); 
    return 7;
  }
  &UpdateActionProgress($actionid,95,"Wrote OS information");

  &UpdateActionProgress($actionid,100,"Successfull");

  return 0;
}

1;

