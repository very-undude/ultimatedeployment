#!/usr/bin/perl

require "kickstart.pl";

sub vsim8_NewTemplate_2
{

 print "<CENTER>\n";
 print "<H2>New Template Wizard Confirm</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 local($publish)="ON";
 if (!defined($formdata{PUBLISH})) 
 { 
  $publish = "OFF" ;
 }

 local(%flavorinfo)=&GetOSInfo($formdata{OSFLAVOR});

 print "<INPUT TYPE=HIDDEN NAME=module VALUE=templates>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=vsim8>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MAC VALUE=\"$formdata{MAC}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=PUBLISH VALUE=\"$publish\">\n";
 print "<INPUT TYPE=HIDDEN NAME=DESCRIPTION VALUE=\"$formdata{DESCRIPTION}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=TEMPLATE VALUE=\"$formdata{TEMPLATENAME}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=KERNEL VALUE=\"$flavorinfo{KERNEL}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=CMDLINE VALUE=\"$flavorinfo{CMDLINE}\">\n";
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
 print "<TR><TD>Kernel</TD><TD>$flavorinfo{KERNEL}</TD></TR>\n";
 print "<TR><TD>Command line options</TD><TD>$flavorinfo{CMDLINE}</TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "</CENTER>\n";
}

sub vsim8_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub vsim8_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  #print "<LI>$destfile\n";
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"vsim8");
  return ($result);
}


sub vsim8_CopyTemplateFile2
{
  local($template)=shift;
  local($destfile)=shift;
  local($kickstartos)=shift;
  $destfile =~ s/\[TEMPLATE\]/$template/g ;
  local($kickstart_templatefile)=$TEMPLATEDIR."/$kickstartos\_cm.tpl";
  local($result)=&ImportFile($kickstart_templatefile,$destfile);
  if ($result != 0 ) { return $result};
  return 0;
}

sub vsim8_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="initrd=pxelinux.cfg/templates/[TEMPLATE]/[SUBTEMPLATE].iso iso";
  return $commandline;
}

sub vsim8_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub vsim8_GetDefaultConfigFile2
{
  local($template)=@_;
  local($configfile)=$TEMPLATECONFDIR."/$template.xml";
  return $configfile;
}

sub windows7_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=$TFTPDIR."/pxelinux.cfg/templates/$template";
  return $publishdir;
}

sub vsim8_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=$TFTPDIR."/pxelinux.cfg/templates/$template/[SUBTEMPLATE].iso";
  return $publishfile;
}

sub vsim8_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=$TFTPDIR."/pxelinux.cfg/templates/$template";
  return $publishdir;
}


sub vsim8_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="memdisk2";
  return $kernel;
}

sub vsim8_CreateTemplate
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
  #local($cmdline)=$formdata{CMDLINE};
  local($kernel)=$formdata{KERNEL};
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
  $config{PUBLISHDIR1}=$TFTPDIR."/$os/".$flavor."/".$template;

  $config{KERNEL}=&vsim8_GetDefaultKernel($template);
  $config{CMDLINE}=&vsim8_GetDefaultCommandLine($template);
  $config{CONFIGFILE1}=&vsim8_GetDefaultConfigFile1($template);
  $config{CONFIGFILE2}=&vsim8_GetDefaultConfigFile2($template);
  $config{PUBLISHDIR1}=&vsim8_GetDefaultPublishDir($template);
  $config{PUBLISHFILE1}=&vsim8_GetDefaultPublishFile($template);

  #$config{CMDLINE}=$cmdline;
  #$config{KERNEL}=$kernel;

  local($result)=&vsim8_CopyTemplateFile($template,$config{CONFIGFILE1});
  if ($result) 
  { 
    &PrintError("Could not copy boot file for $template");
    return $result ;
  }

  local($result)=&vsim8_CopyTemplateFile2($template,$config{CONFIGFILE2},$config{OS});
  #if ($result != 0 ) { return $result};
  if ($result) 
  { 
    &PrintError("Could not copy autosetup config file for $template");
    return $result ;
  }

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

  local($result)=&{"vsim8_WriteTemplatePXEMenu"}($template,%config);
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

sub vsim8_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;

  local($orgfile)=$info{CONFIGFILE2};
  local($destfile)=&vsim8_GetDefaultConfigFile2($desttemplate);

  local($result)=&RunCommand("cp $orgfile $destfile","Copying $orgfile to $destfile");
  if ($result)
  {
    &PrintError("Could not copy xml file");
    return 1;
  }

  $info{CONFIGFILE2}=$destfile;
  local($result)=&kickstart_CopyTemplate("vsim8",$template,$desttemplate,%info);

  return $result;
}


sub vsim8_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"vsim8");
  return $result;
}

sub vsim8_ConfigureTemplate
{
  local($template,%config)=@_;
  # local($result)=&kickstart_ConfigureTemplate("vsim8",$template,%config);
  print "<INPUT TYPE=HIDDEN NAME=CONFIGFILE1 VALUE=\"$config{CONFIGFILE1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=CONFIGFILE2 VALUE=\"$config{CONFIGFILE2}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=PUBLISHFILE1 VALUE=\"$config{PUBLISHFILE1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=PUBLISHDIR1 VALUE=\"$config{PUBLISHDIR1}\">\n";
  print "Kernel<BR>\n";
  print "<INPUT TYPE=TEXT NAME=KERNEL SIZE=20 VALUE=\"$config{KERNEL}\"><BR>\n";
  print "<BR>\n";
  print "Kernel command-line<BR>\n";
  print "<INPUT TYPE=TEXT NAME=CMDLINE SIZE=60 VALUE=\"$config{CMDLINE}\"><BR>\n";
  print "<BR>\n";
  local(@autoexec)=&GetConfigFile($config{CONFIGFILE1});
  print "UDA init file<BR>\n";
  print "<TEXTAREA WRAP=OFF NAME=KICKSTARTFILE ROWS=20 COLS=60>";
  for $line (@autoexec)
  {
    print $line;
  }
  print "</TEXTAREA>\n";
  print "<BR><BR>\n";

  local(@xmlfile)=&GetConfigFile($config{CONFIGFILE2});
  print "vsa.xml file<BR>\n";
  print "<TEXTAREA WRAP=OFF NAME=XMLFILE ROWS=20 COLS=60>";
  for $line (@xmlfile)
  {
    print $line;
  }
  print "</TEXTAREA>\n";
  return 0;
}

sub vsim8_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("vsim8",$template,%info);

  local($kickstartfile)=$formdata{XMLFILE};
  local($tmpfile)=$TEMPDIR."/$template.cfg.$$";
  local($result)=open(XML,">$tmpfile");
  print XML $kickstartfile;
  close(XML);

  local($command)="/usr/bin/dos2unix $tmpfile";
  local($result)=&RunCommand($command,"Forcing unix file format");

  &RunCommand("cp $tmpfile $formdata{CONFIGFILE2}","Copying temporary file |$tmpfile| to |$formdata{CONFIGFILE2}|\n");
  unlink($tmpfile);

  return $result;
}

sub vsim8_NewOS_2
{
 print "<CENTER>\n"; 
 print "<H2>New Operating System Wizard Step 2</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=vsim8>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=CMDLINE VALUE=\"iso\">\n";
 print "<script language='javascript' src='/js/newos.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR><BR>\n";
 print "<TABLE>\n";
 print "<TR><TD>OS</TD><TD>vsim8</TD></TR>\n";
 print "<TR><TD>Flavor</TD><TD>$formdata{OSFLAVOR}</TD></TR>\n";
 print "</TABLE>\n";
 print "</FORM>\n";
 print "</CENTER>\n";
 return result;
}

sub vsim8_ImportOS
{
  local($result)=&kickstart_ImportOS("vsim8");
  return $result;
}

sub vsim8_ImportOS_DoIt
{
  local($actionid)=shift;

  require "general.pl";
  require "config.pl";
  require "action.pl";

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) { &UpdateActionProgress($actionid,-1,"Could not read arguments"); }

  local(%osinfo)=();
  $osinfo{CMDLINE}=$args{CMDLINE};
  $osinfo{OS}=$args{OS};
  $osinfo{FLAVOR}=$args{OSFLAVOR};
  $osinfo{KERNEL}="memdisk2";
  $osinfo{MOUNTONBOOT}="TRUE";
  local($osdir)="$TFTPDIR/$osinfo{OS}";
  local($flavordir)="$osdir/$osinfo{FLAVOR}";
  $osinfo{MOUNTFILE_1}="$flavordir/tinycore.iso";
  $osinfo{MOUNTPOINT_1}="$flavordir/iso";

  local($osdir)="$TFTPDIR/$osinfo{OS}";
  local($result)=&CreateDir($osdir);
  if ($result)
  {
    &UpdateActionProgress($actionid,-1,"Could not create directory $osdir");
    return 4;
  }
  &UpdateActionProgress($actionid,30,"Created OS dir $osdir");

  local($result)=&CreateDir($flavordir);
  if ($result)
  {
    &UpdateActionProgress($actionid,-1,"Could not create directory $flavordir");
    return 4;
  }
  &UpdateActionProgress($actionid,60,"Created Flavor dir $flavordir");

  local($result)=&CreateDir($osinfo{MOUNTPOINT_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-1,"Could not create directory $osinfo{MOUNTPOINT_1}");
    return 4;
  }
  &UpdateActionProgress($actionid,60,"Created dir $osinfo{MOUNTPOINT_1}");

  local($cmdline)="cp $FILESDIR/TinyCore-current.iso $osinfo{MOUNTFILE_1}";
  local($result)=&RunCommand($cmdline,"Importing boot ISO file to $flavordir");
  if ($result)
  {
    &UpdateActionProgress($actionid,-1,"Could not import TinyCore ISO image to $flavordir");
    return 4;
  }
  &UpdateActionProgress($actionid,80,"Imported cd image to $osinfo{MOUNTFILE_1}");

  #local($result)=&MountIso($osinfo{MOUNTFILE_1},$osinfo{MOUNTPOINT_1},"iso9660");
  #if ($result)
  #{
  #  &UpdateActionProgress($actionid,-2,"Could not mount iso file $osinfo{MOUNTFILE_1} on $osinfo{MOUNTPOINT_1}");
  #  return 4;
  #}
  #&UpdateActionProgress($actionid,90,"Mounted iso file $osinfo{MOUNTFILE_1} on $osinfo{MOUNTPOINT_1}");

  local($result)=&WriteOSInfo(%osinfo);
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not write OS configuration");
    return 4;
  }
  &UpdateActionProgress($actionid,99,"OS config written");

  &UpdateActionProgress($actionid,100,"Imported flavor $osinfo{FLAVOR} for os $osinfo{OS} succesfully");

  return $result;
}


sub vsim8_PublishTemplate
{
    local($template)=shift;

    local($filename)="tinycore.iso";

    local(%info)=&GetTemplateInfo($template);

    local(%subinfo)=&GetAllSubTemplateInfo($template);
  
    local($templatedir)="$TFTPDIR/pxelinux.cfg/templates/$template";
    if (! -d $templatedir)
    {
      local($result)=&CreateDir($templatedir);
      if ($result) { &PrintError("Could not create templatedir $templatedir"); return 2 }
    }

    local($command)="cp $TFTPDIR/$info{OS}/$info{FLAVOR}/$filename $templatedir/$$.$filename";
    local($result)=&RunCommand($command,"Copying flavor iso file to template directory");
    if ($result) { &PrintError("Could not run command $command"); return 2 }

    local($subtemplateimagemountdir)=$templatedir."/mountiso";
    if (! -d $subtemplateimagemountdir)
    {
      local($result)=&CreateDir($subtemplateimagemountdir);
      if ($result) { &PrintError("Could not create template image mount dir $subtemplateimagemountdir"); return 2 }
    }
    
    local($command)="mount -o loop,ro $templatedir/$$.$filename $subtemplateimagemountdir";
    local($result)=&RunCommand($command,"Mounting $subtemplateimage on $subtemplateimagemountdir");
    if ($result) { &PrintError("Could not run command $command"); return 2 }

    local($subtemplateextractdir)=$templatedir."/extract";
    if (! -d $subtemplateextractdir)
    {
      local($result)=&CreateDir($subtemplateextractdir);
      if ($result) { &PrintError("Could not create subtemplate extract $subtemplateextractdir"); return 2 }
    }

    local($command)="cd $subtemplateextractdir ; zcat $subtemplateimagemountdir/boot/core.gz | cpio -i -H newc -d";
    local($result)=&RunCommand($command,"Extracting core.gz to $subtemplateextractdir");
    if ($result) { &PrintError("Could not extract core.gz contents to $subtemplateetractdir"); return 2 }

    local($subtemplatenewisodir)=$templatedir."/newiso";
    if (! -d $subtemplatenewisodir)
    {
      local($result)=&CreateDir($subtemplatenewisodir);
      if ($result) { &PrintError("Could not create subtemplate extract $subtemplatenewisodir"); return 2 }
    }

    local($command)="cp -a $subtemplateimagemountdir/* $subtemplatenewisodir";
    local($result)=&RunCommand($command,"Copying iso contents to new directory to $subtemplatenewisodir");
    if ($result) { &PrintError("Could not copy iso contents to $subtemplatenewisodir"); return 2 }

    my($isolinuxdir)="$subtemplatenewisodir/boot/isolinux";
    my($isolinuxcfg)="$subtemplatenewisodir/boot/isolinux/isolinux.cfg";
    my($isolinuxorg)="$subtemplatenewisodir/boot/isolinux/isolinux.org";

    local($command)="mv $isolinuxcfg $isolinuxorg";
    $result=&RunCommand($command,"Moving $isolinuxcfg out of the way");
    if ($result) { &PrintError("Could not run command $command"); return 2 }

    local($command)="chmod 777 $isolinuxdir";
    $result=&RunCommand($command,"Changing mode of isolinux directory");
    if ($result) { &PrintError("Could not change mode of isolinux  directory"); return 2 }

    open(ISOLINUXCFG,">$isolinuxcfg") ||  &PrintError("Could not open isolinux.cfg for writing");
    print ISOLINUXCFG "DEFAULT uda\n";
    print ISOLINUXCFG "LABEL uda\n";
    print ISOLINUXCFG "KERNEL /boot/vmlinuz\n";
    print ISOLINUXCFG "INITRD /boot/core.gz\n";
    print ISOLINUXCFG "APPEND loglevel=1\n";
    close(ISOLINUXCFG);

    local($command)="chmod 555 $isolinuxdir";
    $result=&RunCommand($command,"Changing mode of isolinux directory");
    if ($result) { &PrintError("Could not change mode of isolinux  directory"); return 2 }

    local($command)="chmod 777 $subtemplateextractdir/etc/init.d/tc-config";
    $result=&RunCommand($command,"Changing mode of startup init script");
    if ($result) { &PrintError("Could not change mode of startup init script"); return 2 }

    local($dstfile)="$subtemplateextractdir/etc/init.d/tc-config";
    open(DFILE,">>$dstfile") || &PrintError("Could not open target file $dstfile");
    print DFILE "\n/etc/udaboot.sh\n";
    close (DFILE);

    local($command)="chmod 755 $subtemplateextractdir/etc/init.d/tc-config";
    $result=&RunCommand($command,"Changing mode of startup init script");
    if ($result) { &PrintError("Could not change mode of startup init script"); return 2 }

    local(@indexes)=keys(%subinfo);
    if ($#indexes<0)
    {
       # print("<LI>Publishing the main template $template\n");
       $info{SUBTEMPLATE}="default";
       local($subtemplateimage)="$templatedir/$info{SUBTEMPLATE}.iso";
   
       local($command)="chmod 777 $subtemplateextractdir/etc";
       $result=&RunCommand($command,"Changing mode of /etc directory");
       if ($result) { &PrintError("Could not change mode of /etc directory"); return 2 }

       local($srcfile)="$TEMPLATECONFDIR/$template.cfg";
       local($dstfile)="$subtemplateextractdir/etc/udaboot.sh";
       open(SFILE,"<$srcfile") || &PrintError("Could not open source file $srcfile");
       open(DFILE,">$dstfile") || &PrintError("Could not open target file $dstfile");
       while (<SFILE>)
       {
          local($line)=$_;
          local($newline)=&FindAndReplace($line,%info);
          print DFILE $newline;
        }
        close(DFILE);
        close(SFILE);
   
       local($command)="chmod 777 $subtemplateextractdir/etc/udaboot.sh";
       $result=&RunCommand($command,"Changing mode of /etc/udaboot.sh directory");
       if ($result) { &PrintError("Could not change mode of /etc/udaboot.sh file"); return 2 }

       local($srcfile)="$TEMPLATECONFDIR/$template.xml";
       local($dstfile)="$subtemplateextractdir/etc/vsa.xml";
       open(SFILE,"<$srcfile") || &PrintError("Could not open source file $srcfile");
       open(DFILE,">$dstfile") || &PrintError("Could not open target file $dstfile");
       while (<SFILE>)
       {
          local($line)=$_;
          local($newline)=&FindAndReplace($line,%info);
          print DFILE $newline;
        }
        close(DFILE);
        close(SFILE);

       local($command)="chmod 755 $subtemplateextractdir/etc";
       $result=&RunCommand($command,"Changing mode of /etc directory");
       if ($result) { &PrintError("Could not change mode of /etc directory"); return 2 }

       local($command)="cd $subtemplateextractdir ; find | cpio -o -H newc | gzip -2 > $subtemplatenewisodir/boot/core.gz";
       $result=&RunCommand($command,"Writing new core.gz file");
       if ($result) { &PrintError("Could not write new core.gz file"); return 2 }
  
       local($command)="mkisofs -input-charset utf-8 -r -l -J -R -V TC-custom -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -o $subtemplateimage $subtemplatenewisodir";
       $result=&RunCommand($command,"Creating new iso");
       if ($result) { &PrintError("Could not create new iso $subtemplateimage"); return 2 }
    } else {

      #print("<LI>Publishing subtemplates for $template\n");
      local($headerline)=$subinfo{__HEADER__};
      for $sub (keys(%subinfo))
      {
       if ($sub ne "__HEADER__")
       {
         local(%mysubinfo)=&GetSubTemplateInfo($headerline,$subinfo{$sub},%info);
         $mysubinfo{SUBTEMPLATE}=$sub;
         #print "<LI>Publishsing key $sub for subtemplate $mysubinfo{SUBTEMPLATE}\n";

         local($filename)="tinycore.iso";
         local($subtemplateimage)="$templatedir/$sub.iso";

         local($command)="chmod 777 $subtemplateextractdir/etc";
         $result=&RunCommand($command,"Changing mode of /etc directory");
         if ($result) { &PrintError("Could not change mode of /etc directory"); return 2 }

         local($command)="rm -f $subtemplateextractdir/etc/udaboot.sh";
         $result=&RunCommand($command,"removing /etc/udaboot.sh");
         if ($result) { &PrintError("Removing /etc/udaboot.sh file"); return 2 }

         local($srcfile)="$TEMPLATECONFDIR/$template.cfg";
         local($dstfile)="$subtemplateextractdir/etc/udaboot.sh";
         open(SFILE,"<$srcfile") || &PrintError("Could not open source file $srcfile");
         open(DFILE,">$dstfile") || &PrintError("Could not open target file $dstfile");
         while (<SFILE>)
         {
            local($line)=$_;
            local($newline)=&FindAndReplace($line,%mysubinfo);
            print DFILE $newline;
          }
          close(DFILE);
          close(SFILE);

         local($command)="chmod 777 $subtemplateextractdir/etc/udaboot.sh";
         $result=&RunCommand($command,"Changing mode of /etc/udaboot.sh directory");
         if ($result) { &PrintError("Could not change mode of /etc/udaboot.sh file"); return 2 }

         local($srcfile)="$TEMPLATECONFDIR/$template.xml";
         local($dstfile)="$subtemplateextractdir/etc/vsa.xml";
         open(SFILE,"<$srcfile") || &PrintError("Could not open source file $srcfile");
         open(DFILE,">$dstfile") || &PrintError("Could not open target file $dstfile");
         while (<SFILE>)
         {
            local($line)=$_;
            local($newline)=&FindAndReplace($line,%mysubinfo);
            print DFILE $newline;
          }
          close(DFILE);
          close(SFILE);
  
         local($command)="cd $subtemplateextractdir ; find | cpio -o -H newc | gzip -2 > $subtemplatenewisodir/boot/core.gz";
         $result=&RunCommand($command,"Writing new core.gz file");
         if ($result) { &PrintError("Could not write new core.gz file"); return 2 }
  
         local($command)="mkisofs -input-charset utf-8 -r -l -J -R -V TC-custom -no-emul-boot -boot-load-size 4 -boot-info-table -b boot/isolinux/isolinux.bin -c boot/isolinux/boot.cat -o $subtemplateimage $subtemplatenewisodir";
         $result=&RunCommand($command,"Creating new iso");
         if ($result) { &PrintError("Could not create new iso $subtemplateimage"); return 2 }

        }
      }
    }

    local($command)="umount $subtemplateimagemountdir";
    $result=&RunCommand($command,"Unmounting $subtemplateimagemountdir");
    if ($result) { &PrintError("Could not run command $command"); return 2 }

    #local($command)="rm -rf $subtemplateimagemountdir";
    #$result=&RunCommand($command,"Deleting $subtemplateimagemountdir");
    #if ($result) { &PrintError("Could not run command $command"); return 2 }

    local($command)="rm -rf $subtemplateextractdir";
    $result=&RunCommand($command,"Deleting $subtemplateextractdir");
    if ($result) { &PrintError("Could not run command $command"); return 2 }

    local($command)="rm -rf $subtemplatenewisodir";
    $result=&RunCommand($command,"Deleting $subtemplatenewisodir");
    if ($result) { &PrintError("Could not run command $command"); return 2 }

}


1;
