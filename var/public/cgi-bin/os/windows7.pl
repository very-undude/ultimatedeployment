sub windows7_NewTemplate_3
{
 print "<CENTER>\n";
 print "<H2>New Template Wizard Step 3</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=templates>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=3>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=windows7>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MAC VALUE=\"$formdata{MAC}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=PUBLISH VALUE=\"$formdata{PUBLISH}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=DESCRIPTION VALUE=\"$formdata{DESCRIPTION}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=TEMPLATE VALUE=\"$formdata{TEMPLATENAME}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=IMAGEID VALUE=\"$formdata{IMAGEID}\">\n";
 print "<script language='javascript' src='/js/windows7.js'></script>\n";
 print "<script language='javascript' src='/js/newtemplate.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR>\n";
 print "<TABLE>\n";
 print "<TR><TD>Template Name</TD><TD>$formdata{TEMPLATENAME}</TD></TR>\n";
 print "<TR><TD>Operating System</TD><TD>windows7</TD></TR>\n";
 print "<TR><TD>Flavor</TD><TD>$formdata{OSFLAVOR}</TD></TR>\n";
 print "<TR><TD>Description</TD><TD>$formdata{DESCRIPTION}</TD></TR>\n";
 print "<TR><TD>MAC</TD><TD>$formdata{MAC}</TD></TR>\n";
 print "<TR><TD>Publish</TD><TD>$formdata{PUBLISH}</TD></TR>\n";
 print "<TR><TD>Image ID</TD><TD>$formdata{IMAGEID}</TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "</CENTER>\n";
}

sub windows7_NewTemplate_2
{
 print "<CENTER>\n";
 print "<H2>New Template Wizard Step 2</H2>\n";
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
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=windows7>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MAC VALUE=\"$formdata{MAC}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=PUBLISH VALUE=\"$publish\">\n";
 print "<INPUT TYPE=HIDDEN NAME=DESCRIPTION VALUE=\"$formdata{DESCRIPTION}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=TEMPLATE VALUE=\"$formdata{TEMPLATENAME}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=TEMPLATENAME VALUE=\"$formdata{TEMPLATENAME}\">\n";
 print "<script language='javascript' src='/js/validation.js'></script>\n";
 print "<script language='javascript' src='/js/windows7.js'></script>\n";
 print "<script language='javascript' src='/js/newtemplate.js'></script>\n";
 &PrintToolbar("Previous","Next","Cancel");
 print "<BR>\n";

 local(%config)=("FLAVOR",$formdata{OSFLAVOR});

 require "winpe.pl" ;
 print "<CENTER><H3>Supported Images</H3></CENTER>\n";
 &windows7_PrintImageInfoList(%config);

 print "<BR>\n";
 print "</FORM>\n";
 print "</CENTER>\n";
}

sub windows7_CopyTemplateFile1
{
  local($template)=shift;
  local($subos)=shift;
  local($destfile)=shift;
  $destfile =~ s/\[TEMPLATE\]/$template/g ;
  local($windows7_templatefile)=$TEMPLATEDIR."/$subos.tpl";
  local($result)=&ImportFile($windows7_templatefile,$destfile);
  if ($result != 0 ) { return $result};

  return 0;
}

sub windows7_CopyTemplateFile2
{
  local($template)=shift;
  local($os)=shift;
  local($destfile)=shift;
  $destfile =~ s/\[TEMPLATE\]/$template/g ;
  local($windows7_templatefile)=$TEMPLATEDIR."/$os\_cmd.tpl";
  local($result)=&ImportFile($windows7_templatefile,$destfile);
  if ($result != 0 ) { return $result};

  return 0;
}

sub windows7_GetDefaultKernel()
{
  local($template)=@_;
  local($cmdline)="pxelinux.cfg/templates/[TEMPLATE]/[SUBTEMPLATE]/wdsnbp.0";
  return $cmdline;
}

sub windows7_GetDefaultCommandLine()
{
  local($template)=@_;
  local($cmdline)="";
  return $cmdline;
}

sub windows7_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=$TEMPLATECONFDIR."/$template.cfg";
  return $configfile;
}

sub windows7_GetDefaultConfigFile2
{
  local($template)=@_;
  local($configfile)=$TEMPLATECONFDIR."/$template.cmd";
  return $configfile;
}

sub windows7_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=$TFTPDIR."/pxelinux.cfg/templates/$template/[SUBTEMPLATE].xml";
  return $publishfile;
}

sub windows7_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=$TFTPDIR."/pxelinux.cfg/templates/$template";
  return $publishdir;
}

sub windows7_CreateTemplate
{
  local($template)=$formdata{TEMPLATE};


  local($result)=&CheckTemplateName($template);
  if ($result)
  {
    return 1;
  }
  local($flavor)=$formdata{OSFLAVOR};
  local(%flavorinfo)=&GetOSInfo($flavor);

  local($os)=$formdata{OS};
  local($subos)=$flavorinfo{SUBOS};
  local($mac)=$formdata{MAC};
  local($description)=$formdata{DESCRIPTION};
  local($imageid)=$formdata{IMAGEID};
  local($publish)="ON";
  if (!defined($formdata{PUBLISH}))
  {
    $publish="OFF";
  }

  local(%config)=();
  $config{TEMPLATE}=$template;
  $config{KERNEL}=&windows7_GetDefaultKernel($template);
  $config{SUBOS}=$subos;
  $config{OS}=$os;
  $config{FLAVOR}=$flavor;
  $config{DESCRIPTION}=$description;
  $config{PUBLISH}=$publish;
  $config{LANGUAGE}=$flavorinfo{LANGUAGE};
  $config{MAC}=$mac;
  $config{CMDLINE}=&windows7_GetDefaultCommandLine($template);
  $config{CONFIGFILE1}=&windows7_GetDefaultConfigFile1($template);
  $config{CONFIGFILE2}=&windows7_GetDefaultConfigFile2($template);
  $config{PUBLISHDIR1}=&windows7_GetDefaultPublishDir($template);
  $config{PUBLISHFILE1}=&windows7_GetDefaultPublishFile($template);
  $config{IMAGEID}=$imageid;

  # print "<LI>Copy Template Configuration File\n";
  local($result)=&windows7_CopyTemplateFile1($template,$flavorinfo{SUBOS},$config{CONFIGFILE1});
  if ($result != 0 ) { return $result};

  # print "<LI>Copy prescript.cmd File\n";
  local($result)=&windows7_CopyTemplateFile2($template,$flavorinfo{SUBOS},$config{CONFIGFILE2});
  if ($result != 0 ) { return $result};

  # print "<LI>Write Config File";
  local($result)=&WriteTemplateInfo(%config);
  if ($result) 
  {
    &PrintError("Could not write template info for $template");
    return 1;
  } 

  # Create the publish directry for this template
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

    # Writing PXE configuration file
    local($result)=&WriteDefaultFile();
    if ($result) 
    {
     &PrintError("Could not write PXE default file");
     return 1;
    }    
  }

  &PrintSuccess("Created template $template");

  return 0;
}

sub windows7_PublishTemplate
{
  local($template)=shift;

  local(%info)=&GetTemplateInfo($template);

  local(%subinfo)=&GetAllSubTemplateInfo($template);


    local($tempdir)="$TMPDIR/action.$$";
    local($result)=&CreateDir($tempdir);
    if ($result) { &PrintError("Could not create tempdir $tempdir"); return 2 } 

    local($templatedir)="$TFTPDIR/pxelinux.cfg/templates/$template";
    local($result)=&CreateDir($templatedir);
    if ($result) { &PrintError("Could not create templatedir $templatedir"); return 2 } 

    local($filename)=$TEMPLATECONFDIR."/$template.sub";
    if ( -f $filename)
    {
      local($command)="cp -f $filename $templatedir/subtemplates.txt";
      local($result)=&RunCommand($command,"Copying $filename");
      if ($result) { &PrintError("Could not copy $filename"); return 2 } 
    }

    local($filename)="bootmgr.exe";
    local($command)="cp -f $TFTPDIR/$info{OS}/$info{FLAVOR}\_extra/$filename $templatedir/bootmgr.exe";
    local($result)=&RunCommand($command,"Copying $filename to $templatedir");
    if ($result) { &PrintError("Could not copy $filename"); return 2 } 

    local($filename)="pxeboot.n12";
    local($command)="cp -f $TFTPDIR/$info{OS}/$info{FLAVOR}\_extra/$filename $templatedir/pxeboot.com";
    local($result)=&RunCommand($command,"Copying $filename to $templatedir");
    if ($result) { &PrintError("Could not copy $filename"); return 2 } 

  local(@indexes)=keys(%subinfo);
  if ($#indexes<0)
  {
    # print("Publishing the main template $template\n");
    $info{SUBTEMPLATE}="default";

    local($srcfile)="$TEMPLATECONFDIR/$template.cmd";
    local($dstfile)=$TFTPDIR."/pxelinux.cfg/templates/$template/$info{SUBTEMPLATE}.cmd";
    open(SFILE,"<$srcfile") || &PrintError("Could not open $srcfile");
    open(DFILE,">$dstfile") || &PrintError("Could not open $dstfile");
    while (<SFILE>)
    {
       local($line)=$_;
       local($newline)=&FindAndReplace($line,%info);
       print DFILE $newline;
     }
     close(DFILE);
     close(SFILE);

    local($subtemplatedir)="$TFTPDIR/pxelinux.cfg/templates/$template/$info{SUBTEMPLATE}";
    local($result)=&CreateDir($subtemplatedir);
    if ($result) { &PrintError("Could not create templatedir $subtemplatedir"); return 2 } 

    local($filename)="wdsnbp.com";
    local($command)="cp -f $TFTPDIR/$info{OS}/$info{FLAVOR}\_extra/$filename $subtemplatedir/wdsnbp.0";
    local($result)=&RunCommand($command,"Copying $filename to $subtemplatedir");
    if ($result) { &PrintError("Could not copy $filename"); return 2 } 

    local($filename)="bcd";
    local($command)="cp -f $TFTPDIR/$info{OS}/$info{FLAVOR}\_extra/$filename $subtemplatedir/bcd";
    local($result)=&RunCommand($command,"Copying $filename to $subtemplatedir");
    if ($result) { &PrintError("Could not copy $filename"); return 2 } 

    local(%udaconfig)=GetSystemVariables();
    local($filename)="bcd";
    local($command)="$BINDIR/bcdedit.pl $subtemplatedir/bcd /windows7/$info{FLAVOR}_extra/winpe.wim /windows7/$info{FLAVOR}_extra/boot.sdi UDA=$udaconfig{UDA_IPADDR}:$template:$info{SUBTEMPLATE}:$info{WINPEDRIVER}";
    local($result)=&RunCommand($command,"Updating BCD file");
    if ($result) { &PrintError("Could not update BCD file"); return 2 } 

  } else {
    local($headerline)=$subinfo{__HEADER__};
      for $sub (keys(%subinfo))
      {
       if ($sub ne "__HEADER__")
       {
         # print "<LI>Skipping Publishsing subtemplate $sub not implemented yet\n";

         local(%mysubinfo)=&GetSubTemplateInfo($headerline,$subinfo{$sub},%info);

         local($srcfile)="$TEMPLATECONFDIR/$template.cmd";
         local($dstfile)=$TFTPDIR."/pxelinux.cfg/templates/$template/$mysubinfo{SUBTEMPLATE}.cmd";
         open(SFILE,"<$srcfile") || &PrintError("Could not open $srcfile");
         open(DFILE,">$dstfile") || &PrintError("Could not open $dstfile");
         while (<SFILE>)
         {
            local($line)=$_;
            local($newline)=&FindAndReplace($line,%mysubinfo);
            print DFILE $newline;
          }
          close(DFILE);
          close(SFILE);

          local($subtemplatedir)="$TFTPDIR/pxelinux.cfg/templates/$template/$mysubinfo{SUBTEMPLATE}";
          local($result)=&CreateDir($subtemplatedir);
          if ($result) { &PrintError("Could not create templatedir $subtemplatedir"); return 2 }
   
          local($filename)="wdsnbp.com";
          local($command)="cp -f $TFTPDIR/$mysubinfo{OS}/$mysubinfo{FLAVOR}\_extra/$filename $subtemplatedir/wdsnbp.0";
          local($result)=&RunCommand($command,"Copying $filename to $subtemplatedir");
          if ($result) 
          { 
            &PrintError("Could not copy $filename"); 
            return 2 
          }

          local($filename)="bcd";
          local($command)="cp -f $TFTPDIR/$mysubinfo{OS}/$mysubinfo{FLAVOR}\_extra/$filename $subtemplatedir/bcd";
          local($result)=&RunCommand($command,"Copying $filename to $subtemplatedir");
          if ($result) { &PrintError("Could not copy $filename"); return 2 }

          local(%udaconfig)=GetSystemVariables();
          local($filename)="bcd";
          local($command)="$BINDIR/bcdedit.pl $subtemplatedir/bcd /windows7/$mysubinfo{FLAVOR}_extra/winpe.wim /windows7/$mysubinfo{FLAVOR}_extra/boot.sdi UDA=$udaconfig{UDA_IPADDR}:$template:$mysubinfo{SUBTEMPLATE}:$mysubinfo{WINPEDRIVER}";
          local($result)=&RunCommand($command,"Updating BCD file");
          if ($result) { &PrintError("Could not update BCD file"); return 2 }

      }
    }
  }
}

sub windows7_CheckFlavorname
{
  local($name)=shift;
  # currently this is a dummy check
  return 0;
}


sub windows7_NewOS_2
{
 local($osflavor)=$formdata{OSFLAVOR};

 local($result)=&windows7_CheckFlavorname($osflavor);
 if ($result)
 {
    &PrintError("I'm sorry, invalid flavor name for Windows 7 ","please choose another name");
    return 1;
 }
 print "<CENTER>\n"; 
 print "<H2>New Operating System Wizard Step 2</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=windows7>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=activedrivers VALUE=\"\">\n";
 print "<INPUT TYPE=HIDDEN NAME=sorteddrivers VALUE=\"\">\n";
 print "<script language='javascript' src='/js/windows7.js'></script>\n";
 # print "<script language='javascript' src='/js/newos.js'></script>\n";
 # print "<script language='javascript' src='/js/browse.js'></script>\n";
 print "<script language='javascript' src='/js/validation.js'></script>\n";
 print "<script language='javascript' src='/js/tree.js'></script>\n";
 &PrintToolbar("Previous","Next","Cancel");
 print "<BR><BR>\n";
 local(@mountlist)=&GetMountList();;
 &PrintJavascriptArray("mountsarray",@mountlist);
 # &PrintJavascriptArray("subosarray","win6;Windows Vista","win7;Windows 7");
 # &PrintJavascriptArray("subosarray","windows7;Windows 7","windows7;Windows Server 2008","windows8;Windows 8","windows8;Windows Server 2012");
 #&PrintJavascriptArray("subosarray","windows7;Windows 7","windows7;Windows Server 2008","windows8;Windows 8","windows8;Windows Server 2012","windows8;Windows 10","windows8;Windows Server 2016");
 #&PrintJavascriptArray("subosarray","windows7;Windows 7","windows7;Windows Server 2008","windows8;Windows 8","windows8;Windows Server 2012","windows8;Windows 10","windows8;Windows Server 2016","windows8;Windows Server 2019");
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<TABLE>\n";
 ##print "<TR><TD>Subtype</TD><TD><SELECT NAME=SUBOS ID=SUBOS></SELECT></TD></TR>\n";
 print "<TR><TD>Storage</TD><TD><SELECT NAME=MOUNT ID=MOUNT ONCHANGE=\"expand('/')\"></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile</TD><TD><INPUT TYPE=TEXT NAME=FILE1 ID=FILE1 SIZE=60 VALUE='/'></TD></TR>\n";
 print "<TR><TD COLSPAN=2><DIV ID=browse_div></DIV></TD></TR>\n";
 print "<TR><TD>Mount on Boot</TD><TD><INPUT TYPE=CHECKBOX NAME=MOUNTONBOOT CHECKED></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "<script language='javascript'>\n";
 print "LoadValues(\"MOUNT\",mountsarray);\n";
 #print "LoadValues(\"SUBOS\",subosarray);\n";
 print "expand('/');\n";
 print "</script>\n";
 print "</CENTER>\n";
 return 0;
}

sub windows7_NewOS_3_disabled
{

 local($mountonboot)="FALSE";
 if(defined($formdata{MOUNTONBOOT}))
 {
   $mountonboot="TRUE";
 }

 print "<CENTER>\n";
 print "<H2>New Operating System Wizard Step 3</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=3>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=windows7>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 #print "<INPUT TYPE=HIDDEN NAME=SUBOS VALUE=\"$formdata{SUBOS}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MOUNT VALUE=\"$formdata{MOUNT}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=FILE1 VALUE=\"$formdata{FILE1}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MOUNTONBOOT VALUE=\"$mountonboot\">\n";
  
 print "<script language='javascript' src='/js/validation.js'></script>\n";
 print "<script language='javascript' src='/js/windows7.js'></script>\n";
 print "<script language='javascript' src='/js/winpetablesort.js'></script>\n";
 &PrintToolbar("Previous","Next","Cancel");
 print "<BR>\n";
 print "Enable the following Windows PE drivers for this flavor and order them as needed.<BR>";
 print "In most cases you can skip this step and just hit Finish<BR><BR>\n";
 require "winpe.pl";
 &WinPEPrintChecklist($formdata{OSFLAVOR},());
 print "</FORM>\n";
 print "</CENTER>\n";

  return 0;
}

sub windows7_EditDrivers
{

 local($flavor)=shift;
  
 local(%osinfo)=GetOSInfo($flavor);

 print "<CENTER>\n";
 print "<H2>Edit WinPE Drivers for $flavor</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=drivers>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=os VALUE=windows7>\n";
 print "<INPUT TYPE=HIDDEN NAME=flavor VALUE=\"$flavor\">\n";

 print "<script language='javascript' src='/js/windows7editdrivers.js'></script>\n";
 &PrintToolbar("Save","Cancel");
 print "<BR>\n";

 require "winpe.pl";
 &WinPEPrintChecklist($flavor,%osinfo);
 print "</FORM>\n";
 print "</CENTER>\n";

  return 0;
}


sub windows7_NewOS_3
{
 print "<CENTER>\n";
 print "<H2>New Operating System Wizard Step 3</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=4>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=windows7>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 #print "<INPUT TYPE=HIDDEN NAME=SUBOS VALUE=\"$formdata{SUBOS}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MOUNT VALUE=\"$formdata{MOUNT}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=FILE1 VALUE=\"$formdata{FILE1}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MOUNTONBOOT VALUE=\"$formdata{MOUNTONBOOT}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=ACTIVEDRIVERS VALUE=\"$formdata{activedrivers}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=SORTEDDRIVERS VALUE=\"$formdata{sorteddrivers}\">\n";

 print "<script language='javascript' src='/js/windows7.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR>\n";
 print "<TABLE>\n";
 print "  <TR><TD>OS:</TD><TD>$formdata{OS}</TD></TR>\n";
 print "  <TR><TD>Flavor:</TD><TD>$formdata{OSFLAVOR}</TD></TR>\n";
 #print "  <TR><TD>Subos:</TD><TD>$formdata{SUBOS}</TD></TR>\n";
 print "  <TR><TD>Mount:</TD><TD>$formdata{MOUNT}</TD></TR>\n";
 print "  <TR><TD>File:</TD><TD>$formdata{FILE1}</TD></TR>\n";
 print "  <TR><TD>Mount on boot:</TD><TD>$formdata{MOUNTONBOOT}</TD></TR>\n";
 #print "  <TR><TD>ACTIVE DRIVERS</TD><TD>$formdata{activedrivers}</TD></TR>\n";
 #print "  <TR><TD>SORTED DRIVERS</TD><TD>$formdata{sorteddrivers}</TD></TR>\n";
 print "</TABLE>\n";
 print "</FORM>\n";
 print "</CENTER>\n";

  return 0;

}

sub windows7_ImportOS
{
 local($flavor)=$formdata{OSFLAVOR};
 #local($subos)=$formdata{SUBOS};
 local($mount)=$formdata{MOUNT};
 local($file1)=$formdata{FILE1};
 local($activedrivers)=$formdata{activedrivers};
 local($sorteddrivers)=$formdata{sorteddrivers};
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
  print "<TR><TD>Operating System</TD><TD>windows7</TD></TR>\n";
  #print "<TR><TD>Subtype</TD><TD>$subos</TD></TR>\n";
  print "<TR><TD>Flavor Name</TD><TD>$flavor</TD></TR>\n";
  print "<TR><TD>Mount</TD><TD>$mount</TD></TR>\n";
  print "<TR><TD>File 1</TD><TD>$file1</TD></TR>\n";
  #print "<TR><TD>Active Drivers</TD><TD>$activedrivers</TD></TR>\n";
  #print "<TR><TD>Sorted Drivers</TD><TD>$sorteddrivers</TD></TR>\n";
  print "<TR><TD>Mount on boot</TD><TD>$mountonboot</TD></TR>\n";
  #print "<TR><TD>Action ID</TD><TD>$actionid</TD></TR>\n";
  print "<TR><TD>Action ID</TD><TD><A HREF='uda3.pl?module=system&action=actions&button=view&actionid=$actionid'>$actionid</A></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";
  
  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Import flavor $flavor (windows7)","os/windows7.pl","\&windows7_ImportOS_DoIt($actionid);");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";

}

sub windows7_GetInfFiles
{
  local($sourcedir,$destdir,$actionid)=@_;
  local($result)=opendir(SD,$sourcedir);
  while($fn=readdir(SD))
  {
    if (uc($fn) =~ /^NET.*\.IN_/)
    {
        local($command)="/usr/bin/cabextract -d $destdir -F *.inf $sourcedir/$fn";
        local($result)=&RunCommand($command,"Extracting $fn");
        if ($result)
        {
          &UpdateActionProgress($actionid,22,"Error extracting inf file $fn");
        } else {
          &UpdateActionProgress($actionid,22,"Imported inf file $fn");
       }
    }
  }
  close(SD);
}

sub windows7_GetSysFiles
{
  local($sourcedir,$destdir,$actionid)=@_;
  local($result)=opendir(SD,$sourcedir);
  while($fn=readdir(SD))
  {
    if (uc($fn) =~ /^DRIVER\.CAB/)
    {
       local($command)="/usr/bin/cabextract -d $destdir -F *.sys $sourcedir/$fn";
        local($result)=&RunCommand($command,"Extracting sys files from $fn");
        if ($result)
        {
          &UpdateActionProgress($actionid,22,"Error extracting sys files from file $fn");
        }  else {

           local($result)=&windows7_ConvertDirToLower($destdir);
           if ($result) { return $result };
           closedir(SD);
           return 0;
        }
    }
  }
  closedir(SD);
  return 1; 
}

sub windows7_ConvertDirToLower
{
  local($changedir)=shift;
  local($result)=opendir(CD,$changedir);
  while ($fn=readdir(CD))
  {
   if ($fn ne lc($fn))
   { 
     # print "<LI>Renaming $fn to ".lc($fn);
     rename($changedir."/".$fn,$changedir."/".lc($fn));
   }
  }
  closedir(CD);
  return 0;
}

sub windows7_GetOrExtractFile
{
  local($sourcedir,$sourcefile,$destdir,$destfile)=@_;
  local($compressedfile)=$sourcefile;
  $compressedfile =~ s/.$/_/g;
  # print "COMPFILE=$compressedfile\n";
  local($foundcompressed)=0;
  local($result)=opendir(SD,$sourcedir);
  local($foundfile)="";
  local($found)=0;
  while ($filename=readdir(SD))
  {
   # print "Checking filename $filename\n";
    if (uc($filename) eq uc($sourcefile))
    {
      # print "Found filename $filename";
      $foundfile=$filename;
    } elsif (uc($filename) eq  uc($compressedfile)) {
      $foundfile=$filename;
      # print "Found compressed filename $filename";
      $foundcompressed=1;
    } 
  }
  closedir(SD);
  if ($foundfile ne "")
  {
    local($command)="";
    if ($foundcompressed == 0)
    {
      $command="cp $sourcedir/$foundfile $destdir/$destfile";
    } else {
       $command="/usr/bin/cabextract -p $sourcedir/$foundfile > $destdir/$destfile";
    }
    # print "COMMAND |$command|";
    local($result)=&RunCommand($command,"Getting/Extracting $sourcedir/$foundfile to $destdir/$destfile");
    if ($result)
    {
      return($result);
    }
  } else {
    return 1;
  } 
  return 0;
}

sub windows7_DetermineLanguage
{
  local($inifile)=shift;
  local($language)="NOTFOUND";
  open(INFILE,"<$inifile") || return $language;
  while(<INFILE>)
  {
    local($line)=$_;
    chomp($line);
    if ($line =~ /^\s*([^\s]+)\s*=\s*3\s*$/)
    {
       $language=$1;
       return $language;
    }
  }
  close(INFILE);
  return $language;
}

sub windows7_ApplyEditDrivers
{

 local($flavor)=$formdata{flavor};
 local($activedrivers)=$formdata{activedrivers};
 local($sorteddrivers)=$formdata{sorteddrivers};


  # print("<LI>Now entering Apply Edit function\n");

 require "action.pl";

 print "<CENTER>\n";
 print "<H2>Apply new Windows PE driver settings</H2>\n";
 print "</CENTER>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 local($actionid)=$$;
 print "<INPUT TYPE=HIDDEN NAME=actionid ID=actionid VALUE=\"$actionid\">\n";

  print "<CENTER>\n";
  print "<TABLE>\n";
  print "<TR><TD>Operating System</TD><TD>windows7</TD></TR>\n";
  print "<TR><TD>Flavor Name</TD><TD>$flavor</TD></TR>\n";
  print "<TR><TD>Active Drivers</TD><TD>$activedrivers</TD></TR>\n";
  print "<TR><TD>Sorted Drivers</TD><TD>$sorteddrivers</TD></TR>\n";
  #print "<TR><TD>Action ID</TD><TD>$actionid</TD></TR>\n";
  print "<TR><TD>Action ID</TD><TD><A HREF='uda3.pl?module=system&action=actions&button=view&actionid=$actionid'>$actionid</A></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";

  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Applying new drivers for flavor $flavor (windows7)","os/windows7.pl","\&windows7_ApplyEditDrivers_DoIt($actionid);");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";
 return 0;
}


sub windows7_ApplyEditDrivers_DoIt
{
  local($actionid)=shift;
  require "general.pl";
  require "config.pl";
  require "action.pl";

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) { &UpdateActionProgress($actionid,-1,"Could not read arguments"); }

  local(%osinfo)=GetOSInfo($args{flavor});

  local($sourcedir)=$osinfo{MOUNTPOINT_1}."/sources";
  if (! -d $sourcedir)
  {
    $sourcedir=$osinfo{MOUNTPOINT_1}."/SOURCES";
    if (! -d $sourcedir)
    {
      &UpdateActionProgress($actionid,-2,"Could not find sources directory in $osinfo{MOUNTPOINT_1}");
      return 5;
    }
  }
  &UpdateActionProgress($actionid,16,"Found sourcedir $sourcedir");

  local($result)=&windows7_CreateWim($actionid,$sourcedir,$osinfo{DIR_1},$args{sorteddrivers},$args{activedrivers});
  if ($result)
  {
     &UpdateActionProgress($actionid,-3,"Could not create winpe.wim");
     return 5;
   }
   &UpdateActionProgress($actionid,80,"Createwim succesfull");


  $osinfo{ACTIVEDRIVERS}=$args{activedrivers};
  $osinfo{SORTEDDRIVERS}=$args{sorteddrivers};

  local($result)=&WriteOSInfo(%osinfo);
  if ($result)
  {
     &UpdateActionProgress($actionid,-2,"Could not write OS information to file");
     return 5;
  }
  &UpdateActionProgress($actionid,95,"Wrote OS information");

  &UpdateActionProgress($actionid,100,"Successfull");

  return 0;
}

sub windows7_ImportOS_DoIt
{
  local($actionid)=shift;
  require "general.pl";
  require "config.pl";
  require "action.pl";

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) { &UpdateActionProgress($actionid,-1,"Could not read arguments"); }

  local(%osinfo)=();
  $osinfo{FLAVOR}=$args{"OSFLAVOR"};
  $osinfo{OS}="windows7";
  $osinfo{SUBOS}="windows8";
  $osinfo{MOUNTFILE_1}=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{FILE1};
  $osinfo{MOUNTPOINT_1}="$TFTPDIR/$osinfo{OS}/$osinfo{FLAVOR}";
  $osinfo{MOUNTTYPE_1}="udf";
  $osinfo{MOUNTONBOOT}=$args{MOUNTONBOOT};
  $osinfo{SORTEDDRIVERS}=$args{sorteddrivers};
  $osinfo{ACTIVEDRIVERS}=$args{activedrivers};

  local($osdir)="$TFTPDIR/$osinfo{OS}";
  local($result)=&CreateDir($osdir);
  if ($result) { &UpdateActionProgress($actionid,-2,"Could not create OS dir $osdir"); }
  local($result)=&UpdateActionProgress($actionid,6,"Created OS dir $osdir");

  local($flavordir)=$osinfo{MOUNTPOINT_1};
  local($result)=&CreateDir($flavordir);
  if ($result) { &UpdateActionProgress($actionid,-2,"Could not create flavor dir $flavordir"); }
  local($result)=&UpdateActionProgress($actionid,7,"Created flavor dir $flavordir");

  local($extradir)=$flavordir."_extra";
  local($result)=&CreateDir($extradir);
  if ($result) { &UpdateActionProgress($actionid,-2,"Could not create extra dir $extradir"); }
  local($result)=&UpdateActionProgress($actionid,8,"Created extra dir $extradir");
  $osinfo{DIR_1}=$extradir;

  local($result)=&MountIso($osinfo{MOUNTFILE_1},$osinfo{MOUNTPOINT_1},"udf");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not mount iso file $osinfo{MOUNTFILE_1} on $osinfo{MOUNTPOINT_1}");
    return 4;
  }
  &UpdateActionProgress($actionid,15,"Mounted iso file $osinfo{MOUNTFILE_1} on $osinfo{MOUNTPOINT_1}");

  local($sourcedir)=$osinfo{MOUNTPOINT_1}."/sources";
  if (! -d $sourcedir)
  {
    $sourcedir=$osinfo{MOUNTPOINT_1}."/SOURCES";
    if (! -d $sourcedir)
    {
      &UpdateActionProgress($actionid,-2,"Could not find sources directory in $osinfo{MOUNTPOINT_1}");
      return 5;
    }
  }
  &UpdateActionProgress($actionid,16,"Found sourcedir $sourcedir");

  local($bootdir)=$osinfo{MOUNTPOINT_1}."/boot";
  if (! -d $bootdir)
  {
    $bootdir=$osinfo{MOUNTPOINT_1}."/BOOT";
    if (! -d $bootdir)
    {
      &UpdateActionProgress($actionid,-2,"Could not find boot directory in $osinfo{MOUNTPOINT_1}");
      return 5;
    }
  }
  &UpdateActionProgress($actionid,16,"Found bootdir $bootdir");


  local($sourcefile)="boot.wim";
  local($result)=&windows7_GetOrExtractFile($sourcedir,$sourcefile,$extradir,$sourcefile);
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get or extract $sourcefile");
      return 5;
  }
  &UpdateActionProgress($actionid,17,"Imported $sourcefile");

  local(@result)=`/usr/bin/wiminfo $sourcedir/boot.wim`;
  my($bootindex)=0;
  for $line (@result)
  {
      if ($line =~ /^Boot Index:\s+([0-9]+)/)
      {
        $bootindex = $1;
      }
  }
  if ($bootindex == 0)
  {
    &UpdateActionProgress($actionid,-2,"Bootindex for boot.wim not found");
    return 5;
  }
  &UpdateActionProgress($actionid,17,"Bootindex for boot.wim found: $bootindex");

  local($extractfile)="bootmgr.exe";
  #local($result)=&RunCommand("cd $extradir ; $BINDIR/wimextract $sourcedir/boot.wim //Windows/Boot/PXE $extractfile","extracting $extractfile");
  local($result)=&RunCommand("/usr/bin/wimextract $sourcedir/boot.wim $bootindex /Windows/Boot/PXE/$extractfile --dest-dir=$extradir","extracting $extractfile");
  if ($result)
  {

      local($result)=&RunCommand("/usr/bin/wimextract $sourcedir/boot.wim $bootindex /windows/Boot/PXE/$extractfile --dest-dir=$extradir","extracting $extractfile");
      if ($result)
      {
        &UpdateActionProgress($actionid,-2,"Could not extract $extractfile from boot.wim");
        return 5;
      }
  }
  &UpdateActionProgress($actionid,17,"Extracted $extractfile from boot.wim");

  local($extractfile)="wdsnbp.com";
  #local($result)=&RunCommand("cd $extradir ; $BINDIR/wimextract $sourcedir/boot.wim //Windows/Boot/PXE $extractfile","extracting $extractfile");
  local($result)=&RunCommand("/usr/bin/wimextract $sourcedir/boot.wim $bootindex /Windows/Boot/PXE/$extractfile --dest-dir=$extradir","extracting $extractfile");
  if ($result)
  {
      local($result)=&RunCommand("/usr/bin/wimextract $sourcedir/boot.wim $bootindex /windows/Boot/PXE/$extractfile --dest-dir=$extradir","extracting $extractfile");
      if ($result)
      {
        &UpdateActionProgress($actionid,-2,"Could not extract $extractfile from boot.wim");
        return 5;
      }
  }
  &UpdateActionProgress($actionid,17,"Extracted $extractfile from boot.wim");

  local($extractfile)="pxeboot.n12";
  #local($result)=&RunCommand("cd $extradir ; $BINDIR/wimextract $sourcedir/boot.wim //Windows/Boot/PXE $extractfile","extracting $extractfile");
  local($result)=&RunCommand("/usr/bin/wimextract $sourcedir/boot.wim $bootindex /Windows/Boot/PXE/$extractfile --dest-dir=$extradir","extracting $extractfile");
  if ($result)
  {
      local($result)=&RunCommand("/usr/bin/wimextract $sourcedir/boot.wim $bootindex /windows/Boot/PXE/$extractfile --dest-dir=$extradir","extracting $extractfile");
      if($result)
      {
        &UpdateActionProgress($actionid,-2,"Could not extract $extractfile from boot.wim");
        return 5;
      }
  }
  &UpdateActionProgress($actionid,17,"Extracted $extractfile from boot.wim");


  local($sourcefile)="bcd";
  local($result)=&windows7_GetOrExtractFile($bootdir,$sourcefile,$extradir,$sourcefile);
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get $sourcefile");
      return 5;
  }
  &UpdateActionProgress($actionid,19,"Imported $sourcefile");

  local($sourcefile)="boot.sdi";
  local($result)=&windows7_GetOrExtractFile($bootdir,$sourcefile,$extradir,$sourcefile);
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get $sourcefile");
      return 5;
  }
  &UpdateActionProgress($actionid,19,"Imported $sourcefile");

  local($sourcefile)="ei.cfg";
  local($result)=&windows7_GetOrExtractFile($sourcedir,$sourcefile,$extradir,$sourcefile);
  if ($result)
  {
      &UpdateActionProgress($actionid,19,"Could not get $sourcefile, skipping");
      # return 5;
  }
  &UpdateActionProgress($actionid,19,"Imported $sourcefile");

  local($sourcefile)="lang.ini";
  local($result)=&windows7_GetOrExtractFile($sourcedir,$sourcefile,$extradir,$sourcefile);
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get $sourcefile");
      return 5;
  }
  &UpdateActionProgress($actionid,19,"Imported $sourcefile");


  local($inifile)="$extradir/lang.ini";
  local($language)=&windows7_DetermineLanguage($inifile);
  if ($language eq "NOTFOUND")
  {
      &UpdateActionProgress($actionid,-2,"Could not get language from $inifile");
      return 5;
  }
  &UpdateActionProgress($actionid,20,"Found proper language in $inifile ($language)");

  $osinfo{LANGUAGE}=lc($language);

  #local($result)=&RunCommand("$BINDIR/wimxmlinfo $sourcedir/install.wim | sed 's/\\(<\\/[A-Z]*>\\)/\\1\\n/g' | sed 's/></>\\n</g' > $extradir/install.xml","Getting XML data of install.wim for later use");
  local($result)=&RunCommand("/usr/bin/wiminfo $sourcedir/install.wim --extract-xml=$extradir/install.org","Getting XML data of install.wim for later use");
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get install.wim xml data");
      return 5;
  }
  &UpdateActionProgress($actionid,17,"Imported install.wim xml data");

  local($result)=&RunCommand("cat $extradir/install.org | sed 's/[^[:print:]]//g' | sed 's/\\(<\\/[A-Z]*>\\)/\\1\\n/g' | sed 's/></>\\n</g' > $extradir/install.xml","reformatting");
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not reformat install.wim xml data");
      return 5;
  }
  &UpdateActionProgress($actionid,17,"Reformatted install.wim xml data");

  local($result)=&RunCommand("grep 'MAJOR' $extradir/install.xml | grep '>6<'","Getting Major version");
  if (!$result)
  {
    &UpdateActionProgress($actionid,18,"Found major version 6");
    local($result)=&RunCommand("grep 'MINOR' $extradir/install.xml | grep '>1<'","Getting Minor version");
    if (!$result)
    {
      &UpdateActionProgress($actionid,19,"Found minor version 1, This may be Windows 7");
      local($result)=&RunCommand("grep -i 'EDITION' $extradir/install.xml | grep -i 'server'","Getting Minor version");
      if (!$result)
      {
        &UpdateActionProgress($actionid,20,"Found server edition , This is Windows Server 2008");
      } else {
        &UpdateActionProgress($actionid,20,"Found non-server edition, This is Windows 7");
        $osinfo{SUBOS}="windows7";
      }
    }
  }

  local($result)=&windows7_CreateWim($actionid,$sourcedir,$extradir,$osinfo{SORTEDDRIVERS},$osinfo{ACTIVEDRIVERS});
  if ($result)
  {
    &UpdateActionProgress($actionid,-3,"Could not create winpe.wim");
    return 5;
  }
  &UpdateActionProgress($actionid,80,"Createwim succesfull");


  local($result)=&WriteOSInfo(%osinfo);
  if ($result) 
  { 
     &UpdateActionProgress($actionid,-2,"Could not write OS information to file"); 
     return 5;
  }
  &UpdateActionProgress($actionid,95,"Wrote OS information");

  &UpdateActionProgress($actionid,100,"Successfull");

  return 0;
}

sub windows7_CreateWim
{

  local($actionid,$srcdir,$dstdir,$winpesorteddrivers,$winpeactivedrivers)=@_;

  print "Active drivers = $winpeactivedrivers\n";
  print "Sorted drivers = $winpesorteddrivers\n";

  local($wimdir)="$dstdir/wim.$$";
  local($result)=&CreateDir($wimdir);
  if ($result) { &PrintError("Could not copy $filename"); return 2 }
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not create $wimdir");
      return 5;
  }
  &UpdateActionProgress($actionid,17,"Created $wimdir succesfully");

  local($filename)="winpeshl.ini";
  local($command)="cp -f $BINDIR/$filename $wimdir/$filename";
  local($result)=&RunCommand($command,"Copying $filename");
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not copy $filename to $wimdir");
      return 5;
  }
  &UpdateActionProgress($actionid,17,"Copied $filename to $wimdir succesfully");

  local($filename)="windows7.cmd";
  local($command)="cp -f $BINDIR/$filename $wimdir/$filename";
  local($result)=&RunCommand($command,"Copying $filename");
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not copy $filename to $wimdir");
      return 5;
  }
  &UpdateActionProgress($actionid,17,"Copied $filename to $wimdir succesfully");

  open(ACTION,">$wimdir/actionfile.txt");    
  #print ACTION ("rename //setup.exe setup.uda\n");
  print ACTION ("rename /setup.exe /setup.uda\n");
  #print ACTION ("rename //sources/setup.exe setup.uda\n");
  print ACTION ("rename /sources/setup.exe /sources/setup.uda\n");
  #print ACTION ("add winpeshl.ini //windows/system32\n");
  #print ACTION ("add $wimdir/winpeshl.ini /windows/system32/winpeshl.ini\n");
  print ACTION ("rename /windows /Windows\n");
  print ACTION ("rename /Windows/system32 /Windows/System32\n");
  print ACTION ("add $BINDIR/winpeshl.ini /Windows/System32/winpeshl.ini\n");
  #print ACTION ("mkdir uda //sources\n");
  #print ACTION ("add windows7.cmd //sources/uda\n");

  require "winpe.pl";
  local(%winpeconfig)=&GetWinPEConfig();
  local(%activedrivers)=();
  local(@activedriverlist)=split(";",$winpeactivedrivers);
  for $adrv (@activedriverlist)
  {
      print "Adding active driver $adrv\n";
      $activedrivers{$adrv}=TRUE;
  }
  local(@sorteddrivers)=split(";",$winpesorteddrivers);
  open(DRIVERS,">$wimdir/drivers.txt");
  for $sorteddriver (@sorteddrivers)
  {
    print "Checking sorted driver $sorteddriver\n";
    if (defined($activedrivers{$sorteddriver}))
    {
     print "  driver $sorteddriver is active!\n";
     if ($sorteddriver =~ /^WINPEDRV_(.*)/)
     {
      local($driver)=$1;
      
      print "Adding driver $driver\n";

      print DRIVERS "$driver ENABLED $winpeconfig{$driver}{FILE1} $winpeconfig{$driver}{FILE2} $winpeconfig{$driver}{DRVLOAD}\n";

      local($filename)=$winpeconfig{$driver}{FILE1};
      local($command)="cp -f $WINPECONFDIR/$driver/$filename $wimdir/$filename";
      local($result)=&RunCommand($command,"Copying $filename");
      if ($result) 
      { 
        &UpdateActionProgress($actionid,-2,"Could not copy $filename");
        return 5;
      }
      &UpdateActionProgress($actionid,20,"Copied $filename to $wimdir");
      #print ACTION ("add $filename //sources/uda\n");

      local($filename)=$winpeconfig{$driver}{FILE2};
      local($command)="cp -f $WINPECONFDIR/$driver/$filename $wimdir/$filename";
      local($result)=&RunCommand($command,"Copying $filename");
      if ($result) 
      { 
        &UpdateActionProgress($actionid,-2,"Could not copy $filename");
        return 5;
      }
      &UpdateActionProgress($actionid,20,"Copied $filename to $wimdir");
      #print ACTION ("add $filename //sources/uda\n");

      local($filename)=$winpeconfig{$driver}{DRVLOAD};
      local($command)="cp -f $WINPECONFDIR/$driver/$filename $wimdir/$filename";
      local($result)=&RunCommand($command,"Copying $filename");
      if ($result) 
      { 
        &UpdateActionProgress($actionid,-2,"Could not copy $filename");
        return 5;
      }
      &UpdateActionProgress($actionid,20,"Copied $filename to $wimdir");
      #print ACTION ("add $filename //sources/uda\n");
    }
   }
  }
  close(DRIVERS);

  #print ACTION ("add drivers.txt //sources/uda\n");

  print ACTION ("add $wimdir //sources/uda\n");

  close(ACTION);
  &UpdateActionProgress($actionid,17,"Copied driver files to $wimdir succesfully");

  local($command)="cp $srcdir/boot.wim $dstdir/winpe.wim";
  local($result)=&RunCommand($command,"Copying wim file: |$command|");
  if ($result) 
  { 
    &UpdateActionProgress($actionid,-2,"Copy wimfile failed: $dstdir/winpe.wim");
    return 5;
  }
  &UpdateActionProgress($actionid,17,"Copied wimfile $dstdir/winpe.wim succesful");

  local(@result)=`/usr/bin/wiminfo $dstdir/winpe.wim`;
  my($bootindex)=0;
  for $line (@result)
  {
      if ($line =~ /^Boot Index:\s+([0-9]+)/)
      {
        $bootindex = $1;
      }
  }
  if ($bootindex == 0)
  {
    &UpdateActionProgress($actionid,-2,"Bootindex for winpe.wim not found");
    return 5;
  }
  &UpdateActionProgress($actionid,17,"Bootindex for winpe.wim found: $bootindex");
 
  #local($command)="cd $wimdir ; $BINDIR/updatewim $srcdir/boot.wim $dstdir/winpe.wim $wimdir/actionfile.txt";
  #local($command)="/usr/bin/wimupdate $dstdir/winpe.wim $bootindex < $wimdir/actionfile.txt";
  local($command)="export WIMLIB_IMAGEX_IGNORE_CASE=1;/usr/bin/wimupdate $dstdir/winpe.wim $bootindex < $wimdir/actionfile.txt";
  local($result)=&RunCommand($command,"Updating wim file: |$command|");
  if ($result) 
  { 
    &UpdateActionProgress($actionid,-2,"Update wimfile failed: $dstdir/winpe.wim");
    return 5;
  }
  &UpdateActionProgress($actionid,17,"Update wimfile $dstdir/winpe.wim succesful");
 
  local($command)="rm -rf $wimdir";
  local($result)=&RunCommand($command," Removing temporaty publish dir $tempdir");
  if ($result) 
  { 
    &UpdateActionProgress($actionid,-2,"Removing temporary directory failed: $wimdir");
    return 5;
  }
  &UpdateActionProgress($actionid,17,"Removing temporary directory $wimdir succesful");

}

sub windows7_DeleteOSFlavor
{
  require "services.pl";
  local(%config)=@_;
  local($flavordir)=$TFTPDIR."/windows7/".$config{FLAVOR};
  local($extradir)=$TFTPDIR."/windows7/".$config{FLAVOR}."_extra";
  local($sysdir)=$TFTPDIR."/windows7/".$config{FLAVOR}."_sys";
  local($infdir)=$TFTPDIR."/windows7/".$config{FLAVOR}."_inf";

  local($result)=&RunCommand("rmdir $flavordir","Removing Flavor dir $flavordir");
  local($result)=&StopService("binl");
  local($result)=&RunCommand("rm -rf $extradir","Removing extra dir $extradir");
  local($result)=&StartService("binl");
  local($result)=&RunCommand("rm -rf $sysdir","Removing sys dir $sysdir");
  local($result)=&RunCommand("rm -rf $infdir","Removing inf dir $infdir");

  return 0;
}

sub windows7_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;

  # Copy the CONFIGFILE1
  local($orgfile)=$info{CONFIGFILE1};
  local($destfile)=&windows7_GetDefaultConfigFile1($desttemplate);

  local($result)=&RunCommand("cp $orgfile $destfile","Copying $orgfile to $destfile");
  if ($result)
  {
    &PrintError("Could not copy config file");
    return 1;
  }
  $info{CONFIGFILE1}=$destfile;

  # Copy the CONFIGFILE2
  local($orgfile)=$info{CONFIGFILE2};
  local($destfile)=&windows7_GetDefaultConfigFile2($desttemplate);

  local($result)=&RunCommand("cp $orgfile $destfile","Copying $orgfile to $destfile");
  if ($result)
  {
    &PrintError("Could not copy config file");
    return 1;
  }
  $info{CONFIGFILE2}=$destfile;


  $info{TEMPLATE}=$desttemplate;
  
  # Generate new information
  $info{PUBLISHFILE1}=&windows7_GetDefaultPublishFile($info{TEMPLATE});
  $info{PUBLISHDIR1}=&windows7_GetDefaultPublishDir($info{TEMPLATE});
  $info{CMDLINE}=&windows7_GetDefaultCommandLine($info{TEMPLATE});
  $info{KERNEL}=&windows7_GetDefaultKernel($info{TEMPLATE});

  local($result)=&WriteTemplateInfo(%info);
  if ($result)
  {
    &PrintError("Could not write template info");
    return 1;
  }
  return 0;
}

sub windows7_DeleteTemplate
{
  local($template)=shift;

  # un-jpublish

  # delete cfg file

  # delete subfile
  
  # delete dat file

  return 0;
}

sub windows7_ConfigureTemplate
{
  local($template,%config)=@_;

  print "Kernel<BR>\n";
  print "<INPUT TYPE=TEXT NAME=KERNEL SIZE=60 VALUE=\"$config{KERNEL}\"><BR>\n";
  print "<INPUT TYPE=HIDDEN NAME=CMDLINE SIZE=60 VALUE=\"\"><BR>\n";
  print "<BR>\n";
  print "<INPUT TYPE=HIDDEN NAME=CONFIGFILE1 VALUE=\"$config{CONFIGFILE1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=CONFIGFILE2 VALUE=\"$config{CONFIGFILE2}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=PUBLISHFILE1 VALUE=\"$config{PUBLISHFILE1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=PUBLISHDIR1 VALUE=\"$config{PUBLISHDIR1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=TEMPLATEID VALUE=\"$config{TEMPLATEID}\">\n";

  local(@kickstart)=&GetConfigFile($config{CONFIGFILE1});
  print "Unattend.xml file<BR>\n";
  print "<TEXTAREA WRAP=OFF NAME=KICKSTARTFILE ROWS=20 COLS=60>";
  for $line (@kickstart)
  {
    print $line;
  }
  print "</TEXTAREA>\n";
  print "<BR><BR>\n";

  local(@udacmd)=&GetConfigFile($config{CONFIGFILE2});
  print "prescript.cmd file<BR>\n";
  print "<TEXTAREA WRAP=OFF NAME=UDACMDFILE ROWS=20 COLS=60>";
  for $line (@udacmd)
  {
    print $line;
  }
  print "</TEXTAREA>\n";
  return 0;
}

sub windows7_GetDefaultISOFlavor
{
  local($flavor)=shift;
  local(%imageinfo)=@_;
  local($default)=-1;
  local(%ei)=();
  local($cfgfilename)=$TFTPDIR."/windows7/$flavor\_extra/ei.cfg";
  local($result)=open(CFG,"<$cfgfilename") || return $default;
  local($varname)="";
  while(<CFG>)
  {
    local($line)=$_;
    chomp($line);
    if ($line =~ /^\[([^\]]+)\]/)
    {
      $varname=lc($1);
    } elsif( $line =~ /^([A-Za-z0-9]+)/ ) {
      $ei{$varname}=lc($1);
      # print("<LI>varname $varname has value |$ei{$varname}|\n");
    } else {
      # print "<LI>Unknown line found\n";
    }
  }
  close(CFG);

  for $id (keys(%imageinfo))
  {
    local($shortname)=lc($imageinfo{$id}{DISPLAYNAME});
    $shortname =~ s/\s//g;
    # print("<LI>Checking |$shortname|");
    if($shortname =~ /$ei{editionid}/)
    {
      $default=$id;
      # print "<LI>Found $ei{editionid} in $shortname\n";
    }
  }
  # print "Returning default id |$default|\n";

  return $default;
}

sub windows7_GetImageInfo
{
  local($flavor)=shift;

  local($xmlfilename)=$TFTPDIR."/windows7/$flavor\_extra/install.xml";
  local($result)=open(XML,"<$xmlfilename");
  local(%imageinfo)=();
  local($curindex)=-1;
  while(<XML>)
  {
    local($line)=$_;
    if ($line =~ /<IMAGE\s+INDEX\s*=\s*"\s*([0-9]+)\s*"/)
    {
      $curindex=$1;
      # print("<LI>Found index $curindex\n");
    }
    if ($line =~ /<DISPLAYNAME>([^<]+)<\/DISPLAYNAME>/)
    {
      $displayname=$1;
      # print("<LI>Found name $displayname\n");
      $imageinfo{$curindex}{DISPLAYNAME}=$displayname;
    }
    if ($line =~ /<DISPLAYDESCRIPTION>([^<]+)<\/DISPLAYDESCRIPTION>/)
    {
      $displaydesc=$1;
      # print("<LI>Found description $displaydesc\n");
      $imageinfo{$curindex}{DISPLAYDESCRIPTION}=$displaydesc;
    }
  }
  close(XML);
  return %imageinfo;
}

sub windows7_PrintImageInfoList
{
  local(%config)=@_;
  local($flavor)=$config{FLAVOR};
  local(%imageinfo)=&windows7_GetImageInfo($flavor);
  
  local($curselected)=1;
  if (defined($config{IMAGEID}))
  {
    $curselected=$config{IMAGEID};
  } else {
    local($result)=&windows7_GetDefaultISOFlavor($flavor,%imageinfo);
    if ($result > 0)
    {
      $curselected=$result;
    }
  }
  # print("<LI>Current Selected image = $curselected\n");
  print "<CENTER>\n";
  # print "<script language='javascript' src='/js/table.js'></script>\n";
  print " <TABLE BORDER=1 WIDTH=500>\n";
  print "<TR CLASS=tableheader><TD></TD><TD>Image ID</TD><TD>Name</TD><TD>Description</TD></TR>\n";
  for $image (sort(keys(%imageinfo)))
  {
    local($checked)="";
    if($curselected == $image)
    {
      $checked="CHECKED";
      # print "<LI>Selecting image |$image| with name |$imageinfo{$image}{DISPLAYNAME}|\n";
    }
    print "<TR><TD><INPUT TYPE=RADIO NAME=IMAGEID VALUE=$image $checked></TD><TD>$image</TD><TD>$imageinfo{$image}{DISPLAYNAME}</TD><TD>$imageinfo{$image}{DISPLAYDESCRIPTION}</TD></TR>\n";
  }
  print " </TABLE>\n";
  print "</CENTER>\n";
  
}

sub windows7_ConfigureTemplate2
{
  local($template,%config)=@_;
  require "winpe.pl" ;
  print "<CENTER><H3>Supported Images</H3></CENTER>\n";
  &windows7_PrintImageInfoList(%config);
  return 0;
}

sub windows7_ApplyConfigureTemplate
{
  local($template,%info)=@_;

  $info{CMDLINE}=$formdata{CMDLINE};
  $info{IMAGEID}=$formdata{IMAGEID};

  local($orgtemplate)=$formdata{template};
  local($newtemplate)=$formdata{NEWTEMPLATE};

  if ($orgtemplate ne $newtemplate)
  {
    local($newconfigfile)=&{$info{OS}."_GetDefaultConfigFile1"}($newtemplate);
    local($command)="cp $info{CONFIGFILE1} $newconfigfile";
    local($result)=&RunCommand($command,"Copying configuration file $info{CONFIGFILE1} to $newconfigfile");
    $info{CONFIGFILE1}=$newconfigfile;

    local($newconfigfile)=&{$info{OS}."_GetDefaultConfigFile2"}($newtemplate);
    local($command)="cp $info{CONFIGFILE2} $newconfigfile";
    local($result)=&RunCommand($command,"Copying configuration file $info{CONFIGFILE2} to $newconfigfile");
    $info{CONFIGFILE2}=$newconfigfile;

    $info{PUBLISHFILE1}=&{$info{OS}."_GetDefaultPublishFile"}($formdata{TEMPLATE});
    $info{PUBLISHDIR1}=&{$info{OS}."_GetDefaultPublishDir"}($formdata{TEMPLATE});
  } else {
    $info{CONFIGFILE1}=$formdata{CONFIGFILE1};
    $info{CONFIGFILE2}=$formdata{CONFIGFILE2};
    $info{PUBLISHFILE1}=$formdata{PUBLISHFILE1};
    $info{PUBLISHDIR1}=$formdata{PUBLISHDIR1};
  }

  $info{KERNEL}=$formdata{KERNEL};
  # $info{WINPEDRIVERSORT}=$formdata{sorteddrivers};
  # $info{WINPEDRIVERACTIVE}=$formdata{activedrivers};

  &WriteTemplateInfo(%info);

  local($kickstartfile)=$formdata{KICKSTARTFILE};
  local($tmpfile)=$TEMPDIR."/$template.cfg.$$";
  local($result)=open(SUBFILE,">$tmpfile");
  print SUBFILE $kickstartfile;
  close(SUBFILE);
  &RunCommand("cp $tmpfile $formdata{CONFIGFILE1}","Copying temporary file |$tmpfile| to |$formdata{CONFIGFILE1}|\n");
  unlink($tmpfile);

  local($udacmdfile)=$formdata{UDACMDFILE};
  local($tmpfile)=$TEMPDIR."/$template.cfg.$$";
  local($result)=open(SUBFILE,">$tmpfile");
  print SUBFILE $udacmdfile;
  close(SUBFILE);
  &RunCommand("cp $tmpfile $formdata{CONFIGFILE2}","Copying temporary file |$tmpfile| to |$formdata{CONFIGFILE2}|\n");
  unlink($tmpfile);

   

  return 0;
}

1;
