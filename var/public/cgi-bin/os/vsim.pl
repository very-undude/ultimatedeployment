#!/usr/bin/perl

require "kickstart.pl";

sub vsim_NewTemplate_2
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
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=vsim>\n";
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

sub vsim_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub vsim_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  # print "<LI>$destfile\n";
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"vsim");
  return ($result);
}


sub vsim_CopyTemplateFile2
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

sub vsim_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="initrd=pxelinux.cfg/templates/[TEMPLATE]/[SUBTEMPLATE].img raw";
  return $commandline;
}

sub vsim_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub vsim_GetDefaultConfigFile2
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

sub vsim_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=$TFTPDIR."/pxelinux.cfg/templates/$template/[SUBTEMPLATE].img";
  return $publishfile;
}

sub vsim_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=$TFTPDIR."/pxelinux.cfg/templates/$template";
  return $publishdir;
}


sub vsim_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="memdisk";
  return $kernel;
}

sub vsim_CreateTemplate
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
  $config{PUBLISHDIR1}=$TFTPDIR."/vsim/".$flavor."/".$template;

  $config{KERNEL}=&vsim_GetDefaultKernel($template);
  $config{CMDLINE}=&vsim_GetDefaultCommandLine($template);
  $config{CONFIGFILE1}=&vsim_GetDefaultConfigFile1($template);
  $config{CONFIGFILE2}=&vsim_GetDefaultConfigFile2($template);
  $config{PUBLISHDIR1}=&vsim_GetDefaultPublishDir($template);
  $config{PUBLISHFILE1}=&vsim_GetDefaultPublishFile($template);

  #$config{CMDLINE}=$cmdline;
  #$config{KERNEL}=$kernel;

   # print "<LI>Copy AUTOEXEC.BAT File\n";
  local($result)=&vsim_CopyTemplateFile($template,$config{CONFIGFILE1});
  if ($result != 0 ) { return $result};

   # print "<LI>Copy Cluster mode XML file\n";
  local($result)=&vsim_CopyTemplateFile2($template,$config{CONFIGFILE2},$config{OS});
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
  

  local($result)=&{"vsim_WriteTemplatePXEMenu"}($template,%config);
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

sub vsim_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;

  local($orgfile)=$info{CONFIGFILE2};
  local($destfile)=&vsim_GetDefaultConfigFile2($desttemplate);

  local($result)=&RunCommand("cp $orgfile $destfile","Copying $orgfile to $destfile");
  if ($result)
  {
    &PrintError("Could not copy xml file");
    return 1;
  }

  $info{CONFIGFILE2}=$destfile;
  local($result)=&kickstart_CopyTemplate("vsim",$template,$desttemplate,%info);

  return $result;
}


sub vsim_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"vsim");
  return $result;
}

sub vsim_ConfigureTemplate
{
  local($template,%config)=@_;
  # local($result)=&kickstart_ConfigureTemplate("vsim",$template,%config);
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
  print "AUTOEXEC.BAT file<BR>\n";
  print "<TEXTAREA WRAP=OFF NAME=KICKSTARTFILE ROWS=20 COLS=60>";
  for $line (@autoexec)
  {
    print $line;
  }
  print "</TEXTAREA>\n";
  print "<BR><BR>\n";

  local(@xmlfile)=&GetConfigFile($config{CONFIGFILE2});
  print "VSA.XML file<BR>\n";
  print "<TEXTAREA WRAP=OFF NAME=XMLFILE ROWS=20 COLS=60>";
  for $line (@xmlfile)
  {
    print $line;
  }
  print "</TEXTAREA>\n";
  return 0;
}

sub vsim_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("vsim",$template,%info);

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

sub vsim_NewOS_2
{
 print "<CENTER>\n"; 
 print "<H2>New Operating System Wizard Step 2</H2>\n";
 print "<FORM NAME=WIZARDFORM ENCTYPE=\"multipart/form-data\" METHOD=\"POST\" ACTION=\"/cgi-bin/upload_vsim.cgi\">\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=vsim>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=CMDLINE VALUE=\"raw\">\n";
 print "<script language='javascript' src='/js/newos.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR><BR>\n";
 print "<LI>I will need a DOS floppy image to start hosting the VSIM autosetup files\n";
 print "<LI>You will have to import the ova file into vmware yourself. Make sure that you boot from the UDA at the very first boot of the VSIM\n";
 print "<LI>Better make a snapshot before you first boot the VSIM...\n";
 print "<LI>Upload an MSDOS floppy image when running the VSIM on ESX (freedos may not work!)\n";
 print "<LI>Upload a FREEDos floppy image when running the VSIM on VMware Workstation or Fusion (MSDOS may not work!)\n";
 print "<TABLE>\n";
 print "<TR><TD>Floppy Image</TD><TD><INPUT TYPE=FILE NAME=FLOPPYIMAGE></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "</CENTER>\n";
 return result;
}

sub vsim_ImportOS
{
 local($result)=&kickstart_ImportOS("vsim");
  return $result;
}

sub vsim_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("vsim",$kernellocation,$initrdlocation,$actionid);
  return $result;
}


sub vsim_PublishTemplate
{
local($template)=shift;

  local(%info)=&GetTemplateInfo($template);

  local(%subinfo)=&GetAllSubTemplateInfo($template);
  
  local($templatedir)="$TFTPDIR/pxelinux.cfg/templates/$template";
  if (! -d $templatedir)
  {
    local($result)=&CreateDir($templatedir);
    if ($result) { &PrintError("Could not create templatedir $templatedir"); return 2 }
  }

 local(@indexes)=keys(%subinfo);
 if ($#indexes<0)
  {
    # print("<LI>Publishing the main template $template\n");
    $info{SUBTEMPLATE}="default";

    local($filename)="floppy.img";
    local($subtemplateimage)="$templatedir/$info{SUBTEMPLATE}.img";
    local($command)="cp -f $TFTPDIR/$info{OS}/$info{FLAVOR}/$filename $subtemplateimage";
    local($result)=&RunCommand($command,"Copying $filename to $subtemplateimage");
    if ($result) { &PrintError("Could not copy $filename"); return 2 }

    local($subtemplatedir)="$TFTPDIR/pxelinux.cfg/templates/$template/$info{SUBTEMPLATE}";
    if ( ! -d  $subtemplatedir)
    {
      local($result)=&CreateDir($subtemplatedir);
      if ($result) { &PrintError("Could not create templatedir $subtemplatedir"); return 2 }
    }

    # print "<LI>Mounting $subtemplateimage on $subtemplatedir";
    local($command)="mount -t msdos -o loop $subtemplateimage $subtemplatedir";
    # print "<LI>Running command |$command|\n";
    local($result)=&RunCommand($command,"Mounting $subtemplateimage on $subtemplatedir");
    if ($result) { &PrintError("Could not run command $command"); return 2 }

    local($srcfile)="$TEMPLATECONFDIR/$template.cfg";
    local($dstfile)="$templatedir/$info{SUBTEMPLATE}.bat";
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

    local($command)="/usr/bin/unix2dos $dstfile";
    local($result)=&RunCommand($command,"Unix to dos for $dstfile");
    if ($result) { &PrintError("Could not run command $command"); return 2 }

    local($command)="chown apache:apache $dstfile";
    local($result)=&RunCommand($command,"Unix to dos for $dstfile");
    if ($result) { &PrintError("Could not run command $command"); return 2 }

    local($command)="cp -f $dstfile $subtemplatedir/autoexec.bat";
    local($result)=&RunCommand($command,"Copying $dstfile to $subtemplatedir/autoexec.bat");
    if ($result) { &PrintError("Could not copy $dstfile"); return 2 }

    local($srcfile)="$TEMPLATECONFDIR/$template.xml";
    local($dstfile)="$templatedir/$info{SUBTEMPLATE}.xml";
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


   if ( -f "$subtemplatedir/fdconfig.sys" )
   {
     local($command)="mv $subtemplatedir/fdconfig.sys $subtemplatedir/fdconfig.old";
     local($result)=&RunCommand($command,"Moving $subtemplatedir/fdconfig.sys to $subtemplatedir/fdconfig.old");
     if ($result) { &PrintError("Could not move fdconfig.sys to fdconfig.old"); return 2 }
   } 

   if ( -f "$subtemplatedir/config.sys" )
   {
     local($command)="mv $subtemplatedir/config.sys $subtemplatedir/config.old";
     local($result)=&RunCommand($command,"Moving $subtemplatedir/config.sys to $subtemplatedir/config.old");
     if ($result) { &PrintError("Could not move config.sys to config.old"); return 2 }
   }

    local($command)="cp -f $dstfile $subtemplatedir/VSA.XML";
    local($result)=&RunCommand($command,"Copying $dstfile to $subtemplatedir/vsa.xml");
    if ($result) { &PrintError("Could not copy $dstfile"); return 2 }

    local($fdapm)="$FILESDIR/fdapm.com";
    local($command)="cp -f $fdapm $subtemplatedir/fdapm.com";
    local($result)=&RunCommand($command,"Copying $fdapm to $subtemplatedir/fdapm.com");
    if ($result) { &PrintError("Could not copy $fdapm"); return 2 }

    local($command)="umount $subtemplatedir";
    local($result)=&RunCommand($command,"Unmounting $subtemplatedir");
    if ($result) { &PrintError("Could not run command $command"); return 2 }

  } else {
    # print("<LI>Publishing sbtemplates $template\n");
      local($headerline)=$subinfo{__HEADER__};
      for $sub (keys(%subinfo))
      {
       if ($sub ne "__HEADER__")
       {
         # print "<LI>Skipping Publishsing subtemplate $sub not implemented yet\n";

         local(%mysubinfo)=&GetSubTemplateInfo($headerline,$subinfo{$sub},%info);
         $mysubinfo{SUBTEMPLATE}=$sub;

         #print "<LI>Publishsing key $sub for subtemplate $mysubinfo{SUBTEMPLATE}\n";
         local($filename)="floppy.img";
         local($subtemplateimage)="$templatedir/$mysubinfo{SUBTEMPLATE}.img";
         local($command)="cp -f $TFTPDIR/$info{OS}/$info{FLAVOR}/$filename $subtemplateimage";
         local($result)=&RunCommand($command,"Copying $filename to $subtemplateimage");
         if ($result) { &PrintError("Could not copy $filename"); return 2 }

         local($subtemplatedir)="$TFTPDIR/pxelinux.cfg/templates/$template/$mysubinfo{SUBTEMPLATE}";
         local($result)=&CreateDir($subtemplatedir);
         if ($result) { &PrintError("Could not create templatedir $subtemplatedir"); return 2 }

         #print "<LI>Mounting $subtemplateimage on $subtemplatedir";
         local($command)="mount -t msdos -o loop $subtemplateimage $subtemplatedir";
         #print "<LI>Running command |$command|\n";
         local($result)=&RunCommand($command,"Mounting $subtemplateimage on $subtemplatedir");
         if ($result) { &PrintError("Could not run command $command"); return 2 }

         local($srcfile)="$TEMPLATECONFDIR/$template.cfg";
         local($dstfile)="$templatedir/$mysubinfo{SUBTEMPLATE}.bat";
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

         local($command)="/usr/bin/unix2dos $dstfile";
         local($result)=&RunCommand($command,"Unix to dos for $dstfile");
         if ($result) { &PrintError("Could not run command $command"); return 2 }

         local($command)="chown apache:apache $dstfile";
         local($result)=&RunCommand($command,"Unix to dos for $dstfile");
         if ($result) { &PrintError("Could not run command $command"); return 2 }

         local($command)="cp -f $dstfile $subtemplatedir/autoexec.bat";
         local($result)=&RunCommand($command,"Copying $dstfile to $subtemplatedir/autoexec.bat");
         if ($result) { &PrintError("Could not copy $dstfile"); return 2 }
         
         #print "SUBINFO=\n";
         #for $key (keys(%subinfo)) { print "<LI>$key -> $subinfo{$key}\n"; }

         #print "MYSUBINFO=$subinfo{$sub}\n";
         #for $key (keys(%mysubinfo)) { print "<LI>$key -> $mysubinfo{$key}\n"; }

         local($srcfile)="$TEMPLATECONFDIR/$template.xml";
         #print "<LI>SRCFILE = |$srcfile|\n";
         local($dstfile)="$templatedir/$mysubinfo{SUBTEMPLATE}.xml";
         #print "<LI>DSTFILE = |$dstfile|\n";
         open(SFILE,"<$srcfile") || &PrintError("Could not open source file $srcfile");
         open(DFILE,">$dstfile") || &PrintError("Could not open target file $dstfile");
         while (<SFILE>)
         {
            my($line)=$_;
            #print "<LI>OLD =|$line|\n";
            my($newline)=&FindAndReplace($line,%mysubinfo);
            #print "<LI>NEW = |$newline|\n";
            print DFILE $newline;
          }
          close(DFILE);
          close(SFILE);

         if ( -f "$subtemplatedir/fdconfig.sys" )
         {
           local($command)="mv $subtemplatedir/fdconfig.sys $subtemplatedir/fdconfig.old";
           local($result)=&RunCommand($command,"Moving $subtemplatedir/fdconfig.sys to $subtemplatedir/fdconfig.old");
           if ($result) { &PrintError("Could not move fdconfig.sys to fdconfig.old"); return 2 }
         }

         if ( -f "$subtemplatedir/config.sys" )
         {
           local($command)="mv $subtemplatedir/config.sys $subtemplatedir/config.old";
           local($result)=&RunCommand($command,"Moving $subtemplatedir/config.sys to $subtemplatedir/config.old");
           if ($result) { &PrintError("Could not move config.sys to config.old"); return 2 }
         }

         local($command)="cp -f $dstfile $subtemplatedir/VSA.XML";
         local($result)=&RunCommand($command,"Copying $dstfile to $subtemplatedir/vsa.xml");
         if ($result) { &PrintError("Could not copy $dstfile"); return 2 }

         local($fdapm)="$FILESDIR/fdapm.com";
         local($command)="cp -f $fdapm $subtemplatedir/fdapm.com";
         local($result)=&RunCommand($command,"Copying $fdapm to $subtemplatedir/fdapm.com");
         if ($result) { &PrintError("Could not copy $fdapm"); return 2 }

         local($command)="umount $subtemplatedir";
         local($result)=&RunCommand($command,"Unmounting $subtemplatedir");
         if ($result) { &PrintError("Could not run command $command"); return 2 }
       }
     }
  }
}


1;
