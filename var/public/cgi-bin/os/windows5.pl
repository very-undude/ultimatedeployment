

sub windows5_NewTemplate_2
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
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=windows5>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MAC VALUE=\"$formdata{MAC}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=PUBLISH VALUE=\"$publish\">\n";
 print "<INPUT TYPE=HIDDEN NAME=DESCRIPTION VALUE=\"$formdata{DESCRIPTION}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=TEMPLATE VALUE=\"$formdata{TEMPLATENAME}\">\n";
 print "<script language='javascript' src='/js/windows5.js'></script>\n";
 print "<script language='javascript' src='/js/newtemplate.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR>\n";
 print "<TABLE>\n";
 print "<TR><TD>Template Name</TD><TD>$formdata{TEMPLATENAME}</TD></TR>\n";
 print "<TR><TD>Operating System</TD><TD>windows5</TD></TR>\n";
 print "<TR><TD>Flavor</TD><TD>$formdata{OSFLAVOR}</TD></TR>\n";
 print "<TR><TD>Description</TD><TD>$formdata{DESCRIPTION}</TD></TR>\n";
 print "<TR><TD>MAC</TD><TD>$formdata{MAC}</TD></TR>\n";
 print "<TR><TD>Publish</TD><TD>$publish</TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "</CENTER>\n";
}

sub windows5_CopyTemplateFile
{
  local($template)=shift;
  local($subos)=shift;
  local($destfile)=shift;
  $destfile =~ s/\[TEMPLATE\]/$template/g ;
  local($windows5_templatefile)=$TEMPLATEDIR."/$subos.tpl";
  local($result)=&ImportFile($windows5_templatefile,$destfile);
  if ($result != 0 ) { return $result};

  return 0;
}

sub windows5_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=$TEMPLATECONFDIR."/$template.cfg";
  return $configfile;
}

sub windows5_GetDefaultPublishFile
{
  local($templateid)=@_;
  local($publishfile)=$TFTPDIR."/pxelinux.cfg/templates/$templateid/$templateid\[SUBTEMPLATEID\].sif";
  return $publishfile;
}

# sub windows5_GetDefaultLoader
# {
  # local($template)=@_;
  # local($publishdir)=$TFTPDIR."/pxelinux.cfg/templates/$template/[SUBTEMPLATE]";
  # return $publishdir;
# }

# sub windows5_GetDefaultDetect
# {
  # local($template)=@_;
  # local($publishdir)=$TFTPDIR."/pxelinux.cfg/templates/$template/ntd[SUBTEMPLATE].com";
   # return $publishdir;
# }

sub windows5_GetDefaultPublishDir
{
  local($templateid)=@_;
  local($publishdir)=$TFTPDIR."/pxelinux.cfg/templates/$templateid";
  return $publishdir;
}

sub windows5_CreateTemplate
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
  local($mac)=$formdata{MAC};
  local($description)=$formdata{DESCRIPTION};
  local($publish)="ON";
  if (!defined($formdata{PUBLISH}))
  {
    $publish="OFF";
  }

  local(%config)=();
  $config{TEMPLATE}=$template;
  $config{KERNEL}="pxelinux.cfg/templates/[TEMPLATEID]/[TEMPLATEID][SUBTEMPLATEID].0";
  $config{OS}=$os;
  $config{FLAVOR}=$flavor;
  $config{DESCRIPTION}=$description;
  $config{PUBLISH}=$publish;
  $config{MAC}=$mac;
  $config{TEMPLATEID}=&GetNewTemplateID();
  $config{CONFIGFILE1}=&windows5_GetDefaultConfigFile1($template);
  $config{PUBLISHDIR1}=&windows5_GetDefaultPublishDir($config{TEMPLATEID});
  $config{PUBLISHFILE1}=&windows5_GetDefaultPublishFile($config{TEMPLATEID});
  # $config{NTDETECT}=&windows5_GetDefaultDetect($template);
  # $config{NTLDR}=&windows5_GetDefaultLoader($template);
  $config{SUBTEMPLATEID}="000";

  # Copy Template Configuration File\n";
  local($result)=&windows5_CopyTemplateFile($template,$flavorinfo{SUBOS},$config{CONFIGFILE1});
  if ($result != 0 ) { return $result};

  # Write Config File
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

    #local($result)=&WriteTemplatePXEMenu($template);
    #if ($result) 
    #{
    # &PrintError("Could not write PXE menu for template $template");
    # return 1;
    #} 

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

sub windows5_PublishTemplate
{
  local($template)=shift;

  local(%info)=&GetTemplateInfo($template);

  local(%subinfo)=&GetAllSubTemplateInfo($template);
  # %subinfo=&{$info{OS}."_ModifySubtemplatesBeforePublish"}(%subinfo);

  local($templateid)=$info{TEMPLATEID};
  # print "<H1>templateid =|$templateid|</H1>\n";

  local(@indexes)=keys(%subinfo);
  if ($#indexes<0)
  {
    # Copy the three initialising files to the publishdir
    local($templateidstring)=sprintf("%02d%03d",$templateid,0);

    local($kernel)=$info{PUBLISHDIR1}."/$templateidstring.0";
    local($result)=&ImportFile("/var/public/tftproot/windows5/$info{FLAVOR}_extra/STARTROM.N12",$kernel);

    local($command)="sed -i -e 's/NTLDR/$templateidstring/gi' $kernel";
    local($result)=&RunCommand($command,"Patching the kernel");

    local($ntdetect)=$info{PUBLISHDIR1}."/ntd$templateidstring.com";
    local($result)=&ImportFile("/var/public/tftproot/windows5/$info{FLAVOR}_extra/NTDETECT.COM",$ntdetect);
  
    local($ntldr)=$info{PUBLISHDIR1}."/$templateidstring";
    local($result)=&ImportFile("/var/public/tftproot/windows5/$info{FLAVOR}_extra/SETUPLDR.EXE",$ntldr);

    local($command)="sed -i -e 's/winnt.sif/$templateidstring.sif/gi' $ntldr";
    local($result)=&RunCommand($command,"Patching the detect file step 1");

    local($command)="sed -i -e 's/ntdetect.com/ntd$templateidstring.com/gi' $ntldr";
    local($result)=&RunCommand($command,"Patching the detect file step 2");

  } else {
    local($headerline)=$subinfo{__HEADER__};
      for $sub (keys(%subinfo))
      {
       if ($sub ne "__HEADER__")
       {
         # print "<LI>Publishsing subtemplate $sub\n";
         local(%subinfo)=&GetSubTemplateInfo($headerline,$subinfo{$sub},%info);

         local($templateidstring)=sprintf("%02d%03d",$templateid,$subinfo{SUBTEMPLATEID});
         local($kernel)=$info{PUBLISHDIR1}."/$templateidstring.0";
         local($result)=&ImportFile("/var/public/tftproot/windows5/$info{FLAVOR}_extra/STARTROM.N12",$kernel);

         local($command)="sed -i -e 's/NTLDR/$templateidstring/gi' $kernel";
         local($result)=&RunCommand($command,"Patching the kernel");

         local($ntdetect)=$info{PUBLISHDIR1}."/ntd$templateidstring.com";
         local($result)=&ImportFile("/var/public/tftproot/windows5/$info{FLAVOR}_extra/NTDETECT.COM",$ntdetect);
  
         local($ntldr)=$info{PUBLISHDIR1}."/$templateidstring";
         local($result)=&ImportFile("/var/public/tftproot/windows5/$info{FLAVOR}_extra/SETUPLDR.EXE",$ntldr);

         local($command)="sed -i -e 's/winnt.sif/$templateidstring.sif/gi' $ntldr";
         local($result)=&RunCommand($command,"Patching the detect file step 1");

         local($command)="sed -i -e 's/ntdetect.com/ntd$templateidstring.com/gi' $ntldr";
         local($result)=&RunCommand($command,"Patching the detect file step 2");
      }
    }
  }
}

sub windows5_CheckFlavorname
{
  local($name)=shift;
  if ($name =~ /\./)
  {
    if ($name =~ /^[A-Za-z0-9]{1,8}\.[A-Za-z0-9]{1,3}$/)
    {
      return 0;
    } else {
      return 1;
    }
  } else {
    if ($name =~ /^[A-Za-z0-9]{1,8}$/)
    {
      return 0;
    } else {
      return 1;
    }
  }
  return 0;
}


sub windows5_NewOS_2
{
 local($osflavor)=$formdata{OSFLAVOR};

 local($result)=&windows5_CheckFlavorname($osflavor);
 if ($result)
 {
    &PrintError("I'm sorry, flavor names for windows 2000, xp or 2003","can have at most 8 characters, please choose another name");
    return 1;
 }
 print "<CENTER>\n"; 
 print "<H2>New Operating System Wizard Step 2</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=windows5>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<script language='javascript' src='/js/windows5.js'></script>\n";
 # print "<script language='javascript' src='/js/newos.js'></script>\n";
 # print "<script language='javascript' src='/js/browse.js'></script>\n";
 print "<script language='javascript' src='/js/tree.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR><BR>\n";
 local(@mountlist)=&GetMountList();;
 &PrintJavascriptArray("mountsarray",@mountlist);
 &PrintJavascriptArray("subosarray","wi2ks;Windows 2000","winxp;Windows XP","wi2k3;Windows 2003 Server");
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<TABLE>\n";
 print "<TR><TD>Subtype</TD><TD><SELECT NAME=SUBOS ID=SUBOS></SELECT></TD></TR>\n";
 print "<TR><TD>Storage</TD><TD><SELECT NAME=MOUNT ID=MOUNT ONCHANGE=\"expand('/')\"></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile</TD><TD><INPUT TYPE=TEXT NAME=FILE1 ID=FILE1 SIZE=60 VALUE='/'></TD></TR>\n";
 print "<TR><TD COLSPAN=2><DIV ID=browse_div></DIV></TD></TR>\n";
 print "<TR><TD>Mount on Boot</TD><TD><INPUT TYPE=CHECKBOX NAME=MOUNTONBOOT CHECKED></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "<script language='javascript'>\n";
 print "LoadValues(\"MOUNT\",mountsarray);\n";
 print "LoadValues(\"SUBOS\",subosarray);\n";
 print "expand('/');\n";
 print "</script>\n";
 print "</CENTER>\n";
}

sub windows5_ImportOS
{
 local($flavor)=$formdata{OSFLAVOR};
 local($subos)=$formdata{SUBOS};
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
  print "<TR><TD>Operating System</TD><TD>windows5</TD></TR>\n";
  print "<TR><TD>Subtype</TD><TD>$subos</TD></TR>\n";
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
  &RunAction($actionid,"Import flavor $flavor (windows5)","os/windows5.pl","\&windows5_ImportOS_DoIt($actionid);");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";

}

sub windows5_GetInfFiles
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

sub windows5_GetSysFiles
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
           local($result)=&windows5_ConvertDirToLower($destdir);
           if ($result) { return $result };
           closedir(SD);
           if ( -f "$destdir/pcntpci5.sys" && ! -f "$destdir/pcntn5m.sys" )
           {
             local($command)="/bin/cp $destdir/pcntpci5.sys $destdir/pcntn5m.sys";
             local($result)=&RunCommand($command,"Copying pcnt driver");
             if ($result)
             {
                &UpdateActionProgress($actionid,23,"Error copying pcnt driver");
             } 
           }
           return 0;
        }
    }
  }
  closedir(SD);
  return 1; 
}

sub windows5_ConvertDirToLower
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

sub windows5_GetOrExtractFile
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

sub windows5_ImportOS_DoIt
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
  $osinfo{OS}="windows5";
  $osinfo{SUBOS}=$args{SUBOS};
  $osinfo{MOUNTFILE_1}=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{FILE1};
  $osinfo{MOUNTPOINT_1}="$TFTPDIR/$osinfo{OS}/$osinfo{FLAVOR}";
  $osinfo{MOUNTONBOOT}=$args{MOUNTONBOOT};

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

  local($infdir)=$flavordir."_inf";
  local($result)=&CreateDir($infdir);
  if ($result) { &UpdateActionProgress($actionid,-2,"Could not create inf dir $infdir"); }
  local($result)=&UpdateActionProgress($actionid,9,"Created inf dir $infdir");
  $osinfo{DIR_2}=$infdir;

  local($sysdir)=$flavordir."_sys";
  local($result)=&CreateDir($sysdir);
  if ($result) { &UpdateActionProgress($actionid,-2,"Could not create sys dir $sysdir"); }
  local($result)=&UpdateActionProgress($actionid,10,"Created sys dir $sysdir");
  $osinfo{DIR_3}=$sysdir;

  local($result)=&MountIso($osinfo{MOUNTFILE_1},$osinfo{MOUNTPOINT_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not mount iso file $osinfo{MOUNTFILE_1} on $osinfo{MOUNTPOINT_1}");
    return 4;
  }
  &UpdateActionProgress($actionid,15,"Mounted iso file $osinfo{MOUNTFILE_1} on $osinfo{MOUNTPOINT_1}");

  local($sourcedir)=$osinfo{MOUNTPOINT_1}."/I386";
  if (! -d $sourcedir)
  {
    $sourcedir=$osinfo{MOUNTPOINT_1}."/i386";
    if (! -d $sourcedir)
    {
      &UpdateActionProgress($actionid,-2,"Could not find i386 or I386 directory in $osinfo{MOUNTPOINT_1}");
      return 5;
    }
  }
  &UpdateActionProgress($actionid,16,"Found sourcedir $sourcedir");

  local($sourcefile)="startrom.n12";
  local($result)=&windows5_GetOrExtractFile($sourcedir,$sourcefile,$extradir,uc($sourcefile));
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get or extract $sourcefile");
      return 5;
  }
  &UpdateActionProgress($actionid,17,"Imported $sourcefile");

  local($sourcefile)="setupldr.exe";
  local($result)=&windows5_GetOrExtractFile($sourcedir,$sourcefile,$extradir,uc($sourcefile));
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get or extract $sourcefile");
      return 5;
  }
  &UpdateActionProgress($actionid,18,"Imported $sourcefile");

  local($sourcefile)="ntdetect.com";
  local($result)=&windows5_GetOrExtractFile($sourcedir,$sourcefile,$extradir,uc($sourcefile));
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get or extract $sourcefile");
      return 5;
  }
  &UpdateActionProgress($actionid,19,"Imported $sourcefile");

  local($result)=&windows5_GetInfFiles($sourcedir,$infdir,$actionid);
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get inf files from $sourcedir");
      return 5;
  }
  &UpdateActionProgress($actionid,25,"Imported inf files from $sourcedir");

  local($result)=&windows5_GetSysFiles($sourcedir,$sysdir,$actionid);
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get sys files from $sourcedir");
      return 5;
  }
  &UpdateActionProgress($actionid,30,"Imported sys files from driver.cab in $sourcedir");

  local(@sourcefilearray)= ("usbd.sys","pciidex.sys","usbport.sys","hidparse.sys",
                            "setupreg.hiv","1394bus.sys","usbport.sys","spddlang.sys",
                            "bootvid.dll","hidclass.sys",
                            "wmilib.sys","scsiport.sys","classpnp.sys","tdi.sys","videoprt.sys","ohci1394.sys");
  for $sourcefile (@sourcefilearray)
  {
    local($result)=&windows5_GetOrExtractFile($sourcedir,$sourcefile,$extradir,uc($sourcefile));
    if ($result)
    {
        &UpdateActionProgress($actionid,-2,"Could not get or extract $sourcefile");
        return 5;
    }
    &UpdateActionProgress($actionid,31,"Imported $sourcefile");
  }
  &UpdateActionProgress($actionid,35,"Imported filecase problems");

  if ($osinfo{SUBOS} ne "wi2ks")
 {
    local(@sourcefilearray)= ("kdcom.dll","oprghdlr.sys","bootvid.dll","setupreg.hiv","spddlang.sys",
                              "wmilib.sys","scsiport.sys","classpnp.sys","tdi.sys","videoprt.sys","ohci1394.sys");
    for $sourcefile (@sourcefilearray)
    {
      local($result)=&windows5_GetOrExtractFile($sourcedir,$sourcefile,$extradir,uc($sourcefile));
      if ($result)
      {
          &UpdateActionProgress($actionid,-2,"Could not get or extract $sourcefile");
          return 5;
      }
      &UpdateActionProgress($actionid,37,"Imported $sourcefile");
    }
    &UpdateActionProgress($actionid,40,"Imported filecase problems");
 }

  require "services.pl";

  local($result)=&StopService("binl");
  if ($result)
  {
    &UpdateActionProgress($actionid,50,"Could not stop binl service, assuming it has already stopped");
  } else {
    &UpdateActionProgress($actionid,50,"Stopped binl service");
  }

  require "services/binl.pl";
  local($result)=&binl_RebuildInfDb($osinfo{FLAVOR});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not rebuild inf driver database");
    return 2;
  } 
  &UpdateActionProgress($actionid,60,"Rebuilt inf driver database succesfully");

  local($result)=&StartService("binl");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not start binl service");
    return 2;
  } else {
    &UpdateActionProgress($actionid,75,"Started binl service");
  }

  local($result)=&WriteOSInfo(%osinfo);
  if ($result) { &UpdateActionProgress($actionid,-2,"Could not write OS information to file"); }
  &UpdateActionProgress($actionid,95,"Wrote OS information");

  &UpdateActionProgress($actionid,100,"Successfull");

  return 0;
}


sub windows5_DeleteOSFlavor
{
  require "services.pl";
  local(%config)=@_;
  local($flavordir)=$TFTPDIR."/windows5/".$config{FLAVOR};
  local($extradir)=$TFTPDIR."/windows5/".$config{FLAVOR}."_extra";
  local($sysdir)=$TFTPDIR."/windows5/".$config{FLAVOR}."_sys";
  local($infdir)=$TFTPDIR."/windows5/".$config{FLAVOR}."_inf";

  local($result)=&RunCommand("rmdir $flavordir","Removing Flavor dir $flavordir");
  local($result)=&StopService("binl");
  local($result)=&RunCommand("rm -rf $extradir","Removing extra dir $extradir");
  local($result)=&StartService("binl");
  local($result)=&RunCommand("rm -rf $sysdir","Removing sys dir $sysdir");
  local($result)=&RunCommand("rm -rf $infdir","Removing inf dir $infdir");

  return 0;
}

sub windows5_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;

  # Copy the CONFIGFILE1
  local($orgfile)=$info{CONFIGFILE1};
  local($destfile)=&windows5_GetDefaultConfigFile1($desttemplate);

  local($result)=&RunCommand("cp $orgfile $destfile","Copying $orgfile to $destfile");
  if ($result)
  {
    &PrintError("Could not copy config file");
    return 1;
  }

  $info{CONFIGFILE1}=$destfile;
  $info{TEMPLATE}=$desttemplate;
  
  # Generate new information
  $info{PUBLISHFILE1}=&windows5_GetDefaultPublishFile($info{TEMPLATE});
  $info{PUBLISHDIR1}=&windows5_GetDefaultPublishDir($info{TEMPLATE});
  # $info{CMDLINE}=&windows5_GetDefaultCommandLine($info{TEMPLATE});
  # $info{KERNEL}=&windows5_GetDefaultKerel($info{TEMPLATE});

  local($result)=&WriteTemplateInfo(%info);
  if ($result)
  {
    &PrintError("Could not write template info");
    return 1;
  }
  return 0;
}

sub windows5_DeleteTemplate
{
  local($template)=shift;

  # un-jpublish

  # delete cfg file

  # delete subfile
  
  # delete dat file

  return 0;
}

sub windows5_ConfigureTemplate
{
  local($template,%config)=@_;

  print "Template ID: $config{TEMPLATEID}<BR>\n";
  print "<BR>\n";
  print "Kernel<BR>\n";
  print "<INPUT TYPE=TEXT NAME=KERNEL SIZE=60 VALUE=\"$config{KERNEL}\"><BR>\n";
  print "<BR>\n";
  # print "Kernel option command-line<BR>\n";
  # print "<INPUT TYPE=TEXT NAME=CMDLINE SIZE=60 VALUE=\"$config{CMDLINE}\"><BR>\n";
  # print "<BR>\n";
  print "SIF Answer file<BR>\n";
  local(@kickstart)=&GetConfigFile($config{CONFIGFILE1});
  print "<INPUT TYPE=HIDDEN NAME=CONFIGFILE1 VALUE=\"$config{CONFIGFILE1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=PUBLISHFILE1 VALUE=\"$config{PUBLISHFILE1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=PUBLISHDIR1 VALUE=\"$config{PUBLISHDIR1}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=TEMPLATEID VALUE=\"$config{TEMPLATEID}\">\n";
  print "<TEXTAREA WRAP=OFF NAME=KICKSTARTFILE ROWS=20 COLS=60>";
  for $line (@kickstart)
  {
    print $line;
  }
  print "</TEXTAREA>\n";
  return 0;
}

sub windows5_ApplyConfigureTemplate
{
  local($template,%info)=@_;

  $info{CMDLINE}=$formdata{CMDLINE};

  local($orgtemplate)=$formdata{template};
  local($newtemplate)=$formdata{NEWTEMPLATE};

  if ($orgtemplate ne $newtemplate)
  {
    local($newconfigfile)=&{$info{OS}."_GetDefaultConfigFile1"}($newtemplate);
    local($command)="cp $info{CONFIGFILE1} $newconfigfile";
    local($result)=&RunCommand($command,"Copying configuration file $info{CONFIGFILE1} to $newconfigfile");
    $info{CONFIGFILE1}=$newconfigfile;
    $info{PUBLISHFILE1}=&{$info{OS}."_GetDefaultPublishFile"}($formdata{TEMPLATEID});
    $info{PUBLISHDIR1}=&{$info{OS}."_GetDefaultPublishDir"}($formdata{TEMPLATEID});
  } else {
    $info{CONFIGFILE1}=$formdata{CONFIGFILE1};
    $info{PUBLISHFILE1}=$formdata{PUBLISHFILE1};
    $info{PUBLISHDIR1}=$formdata{PUBLISHDIR1};
  }

  $info{KERNEL}=$formdata{KERNEL};
  $info{TEMPLATEID}=$formdata{TEMPLATEID};
  $info{SUBTEMPLATEID}="000";

  &WriteTemplateInfo(%info);

  local($kickstartfile)=$formdata{KICKSTARTFILE};
  local($tmpfile)=$TEMPDIR."/$template.cfg.$$";
  local($result)=open(SUBFILE,">$tmpfile");
  print SUBFILE $kickstartfile;
  close(SUBFILE);
  &RunCommand("cp $tmpfile $formdata{CONFIGFILE1}","Copying temporary file |$tmpfile| to |$formdata{CONFIGFILE1}|\n");
  unlink($tmpfile);

  return 0;
}

1;
