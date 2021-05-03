sub bartpe_NewTemplate_2
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
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=bartpe>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MAC VALUE=\"$formdata{MAC}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=PUBLISH VALUE=\"$publish\">\n";
 print "<INPUT TYPE=HIDDEN NAME=DESCRIPTION VALUE=\"$formdata{DESCRIPTION}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=TEMPLATE VALUE=\"$formdata{TEMPLATENAME}\">\n";
 print "<script language='javascript' src='/js/bartpe.js'></script>\n";
 print "<script language='javascript' src='/js/newtemplate.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR>\n";
 print "<TABLE>\n";
 print "<TR><TD>Template Name</TD><TD>$formdata{TEMPLATENAME}</TD></TR>\n";
 print "<TR><TD>Operating System</TD><TD>bartpe</TD></TR>\n";
 print "<TR><TD>Flavor</TD><TD>$formdata{OSFLAVOR}</TD></TR>\n";
 print "<TR><TD>Description</TD><TD>$formdata{DESCRIPTION}</TD></TR>\n";
 print "<TR><TD>MAC</TD><TD>$formdata{MAC}</TD></TR>\n";
 print "<TR><TD>Publish</TD><TD>$publish</TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "</CENTER>\n";
}

sub bartpe_CopyTemplateFile
{
  local($template)=shift;
  local($subos)=shift;
  local($destfile)=shift;
  $destfile =~ s/\[TEMPLATE\]/$template/g ;
  local($bartpe_templatefile)=$TEMPLATEDIR."/$subos.tpl";
  local($result)=&ImportFile($bartpe_templatefile,$destfile);
  if ($result != 0 ) { return $result};

  return 0;
}

sub bartpe_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=$TEMPLATECONFDIR."/$template.cfg";
  return $configfile;
}

sub bartpe_GetDefaultPublishFile
{
  local($templateid)=@_;
  local($publishfile)=$TFTPDIR."/pxelinux.cfg/templates/$templateid/$templateid\[SUBTEMPLATEID\].sif";
  return $publishfile;
}

sub bartpe_GetDefaultPublishDir
{
  local($templateid)=@_;
  local($publishdir)=$TFTPDIR."/pxelinux.cfg/templates/$templateid";
  return $publishdir;
}

sub bartpe_CreateTemplate
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
  $config{CONFIGFILE1}=&bartpe_GetDefaultConfigFile1($template);
  $config{PUBLISHDIR1}=&bartpe_GetDefaultPublishDir($config{TEMPLATEID});
  $config{PUBLISHFILE1}=&bartpe_GetDefaultPublishFile($config{TEMPLATEID});
  $config{SUBTEMPLATEID}="000";
  $config{BARTPEISO}=$flavorinfo{BARTPEISO};

  # Copy Template Configuration File\n";
  local($result)=&bartpe_CopyTemplateFile($template,"bartpe",$config{CONFIGFILE1});
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

sub bartpe_PublishTemplate
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
    local($result)=&ImportFile("/var/public/tftproot/bartpe/$info{FLAVOR}_extra/STARTROM.N12",$kernel);

    local($command)="sed -i -e 's/NTLDR/$templateidstring/gi' $kernel";
    local($result)=&RunCommand($command,"Patching the kernel");

    local($ntdetect)=$info{PUBLISHDIR1}."/ntd$templateidstring.com";
    local($result)=&ImportFile("/var/public/tftproot/bartpe/$info{FLAVOR}_extra/NTDETECT.COM",$ntdetect);
  
    local($ntldr)=$info{PUBLISHDIR1}."/$templateidstring";
    local($result)=&ImportFile("/var/public/tftproot/bartpe/$info{FLAVOR}_extra/SETUPLDR.EXE",$ntldr);

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
         local($result)=&ImportFile("/var/public/tftproot/bartpe/$info{FLAVOR}_extra/STARTROM.N12",$kernel);

         local($command)="sed -i -e 's/NTLDR/$templateidstring/gi' $kernel";
         local($result)=&RunCommand($command,"Patching the kernel");

         local($ntdetect)=$info{PUBLISHDIR1}."/ntd$templateidstring.com";
         local($result)=&ImportFile("/var/public/tftproot/bartpe/$info{FLAVOR}_extra/NTDETECT.COM",$ntdetect);
  
         local($ntldr)=$info{PUBLISHDIR1}."/$templateidstring";
         local($result)=&ImportFile("/var/public/tftproot/bartpe/$info{FLAVOR}_extra/SETUPLDR.EXE",$ntldr);

         local($command)="sed -i -e 's/winnt.sif/$templateidstring.sif/gi' $ntldr";
         local($result)=&RunCommand($command,"Patching the detect file step 1");

         local($command)="sed -i -e 's/ntdetect.com/ntd$templateidstring.com/gi' $ntldr";
         local($result)=&RunCommand($command,"Patching the detect file step 2");
      }
    }
  }
}

sub bartpe_CheckFlavorname
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


sub bartpe_NewOS_2
{
 local($osflavor)=$formdata{OSFLAVOR};

 local($result)=&bartpe_CheckFlavorname($osflavor);
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
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=bartpe>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<script language='javascript' src='/js/bartpe.js'></script>\n";
 print "<script language='javascript' src='/js/tree_dir_pe.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR><BR>\n";
 local(@mountlist)=&GetMountList();;
 &PrintJavascriptArray("mountsarray",@mountlist);
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<TABLE>\n";
 print "<TR><TD>Storage</TD><TD><SELECT NAME=MOUNT ID=MOUNT ONCHANGE=\"expand('/')\"></SELECT></TD></TR>\n";
 print "<TR><TD>Path</TD><TD><INPUT TYPE=TEXT NAME=PATH ID=\"PATH\" SIZE=60 VALUE='/' DISABLED></TD></TR>\n";
 print "<TR><TD>Directory</TD><TD><SELECT NAME=DIRECTORY ID=DIRECTORY ONCHANGE=\"expand(this.value);\"></SELECT></TD></TR>\n";
 print "<TR><TD>BartPE ISO</TD><TD><SELECT NAME=FILE1 ID=FILE1></SELECT></TD></TR>\n";
 print "<TR><TD>Windows 2003 SP2 iso</TD><TD><SELECT NAME=FILE2 ID=FILE2></SELECT></TD></TR>\n";
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

sub bartpe_ImportOS
{
 local($flavor)=$formdata{OSFLAVOR};
 local($mount)=$formdata{MOUNT};
 local($file1)="$formdata{PATH}/$formdata{FILE1}";
 local($file2)="$formdata{FILE2}";
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
  print "<TR><TD>Operating System</TD><TD>bartpe</TD></TR>\n";
  print "<TR><TD>Flavor Name</TD><TD>$flavor</TD></TR>\n";
  print "<TR><TD>Mount</TD><TD>$mount</TD></TR>\n";
  print "<TR><TD>BartPE Iso</TD><TD>$file1</TD></TR>\n";
  print "<TR><TD>Windows 2003 SP2 Iso</TD><TD>$file2</TD></TR>\n";
  print "<TR><TD>Mount on boot</TD><TD>$mountonboot</TD></TR>\n";
  #print "<TR><TD>Action ID</TD><TD>$actionid</TD></TR>\n";
  print "<TR><TD>Action ID</TD><TD><A HREF='uda3.pl?module=system&action=actions&button=view&actionid=$actionid'>$actionid</A></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";
  
  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Import flavor $flavor (bartpe)","os/bartpe.pl","\&bartpe_ImportOS_DoIt($actionid);");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";

}

sub bartpe_GetInfFiles
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

sub bartpe_GetSysFiles
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

           local($result)=&bartpe_ConvertDirToLower($destdir);
           if ($result) { return $result };
           closedir(SD);
           return 0;
        }
    }
  }
  closedir(SD);
  return 1; 
}

sub bartpe_ConvertDirToLower
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

sub bartpe_GetOrExtractFile
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

sub bartpe_ImportOS_DoIt
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
  $osinfo{OS}="bartpe";
  $osinfo{SUBOS}=$args{SUBOS};
  $osinfo{MOUNTFILE_1}=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{PATH}."/".$args{FILE2};
  $osinfo{MOUNTPOINT_1}="$TFTPDIR/$osinfo{OS}/$osinfo{FLAVOR}";
  $osinfo{MOUNTONBOOT}=$args{MOUNTONBOOT};
  $osinfo{BARTPEISO}=$args{FILE1};

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
  local($result)=&bartpe_GetOrExtractFile($sourcedir,$sourcefile,$extradir,uc($sourcefile));
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get or extract $sourcefile");
      return 5;
  }
  &UpdateActionProgress($actionid,17,"Imported $sourcefile");

  local($sourcefile)="setupldr.exe";
  local($result)=&bartpe_GetOrExtractFile($sourcedir,$sourcefile,$extradir,uc($sourcefile));
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get or extract $sourcefile");
      return 5;
  }
  &UpdateActionProgress($actionid,18,"Imported $sourcefile");

  local($sourcefile)="ntdetect.com";
  local($result)=&bartpe_GetOrExtractFile($sourcedir,$sourcefile,$extradir,uc($sourcefile));
  if ($result)
  {
      &UpdateActionProgress($actionid,-2,"Could not get or extract $sourcefile");
      return 5;
  }
  &UpdateActionProgress($actionid,19,"Imported $sourcefile");

  local($command)="umount $osinfo{MOUNTPOINT_1}";
  local($result)=&RunCommand($command,"Unmounting $osinfo{MOUNTPOINT_1}");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not unmount windows 2003 iso file $osinfo{MOUNTFILE_1}");
    return 4;
  }
  &UpdateActionProgress($actionid,20,"Unmounted windows 2003 iso file $osinfo{MOUNTFILE_1} from $osinfo{MOUNTPOINT_1}");

  $osinfo{MOUNTFILE_1}=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{PATH};
  $osinfo{MOUNTTYPE_1}="rbind";

  local($command)="mount --rbind \\\"$osinfo{MOUNTFILE_1}\\\" \\\"$osinfo{MOUNTPOINT_1}\\\"";
  local($result)=&RunCommand($command,"Binding $osinfo{MOUNTFILE_1} to $osinfo{MOUNTPOINT_1}");
  # local($result)=&MountDir($osinfo{MOUNTFILE_1},$osinfo{MOUNTPOINT_1},$osinfo{MOUNTOPTIONS_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not mount directory $osinfo{MOUNTFILE_1} with BARTPE iso file on $osinfo{MOUNTPOINT_1}");
    return 4;
  }
  &UpdateActionProgress($actionid,25,"Could not mount directory $osinfo{MOUNTFILE_1} with BartPE iso on $osinfo{MOUNTPOINT_1}");

  local($result)=&WriteOSInfo(%osinfo);
  if ($result) { &UpdateActionProgress($actionid,-2,"Could not write OS information to file"); }
  &UpdateActionProgress($actionid,95,"Wrote OS information");

  &UpdateActionProgress($actionid,100,"Successfull");

  return 0;
}


sub bartpe_DeleteOSFlavor
{
  require "services.pl";
  local(%config)=@_;
  local($flavordir)=$TFTPDIR."/bartpe/".$config{FLAVOR};
  local($extradir)=$TFTPDIR."/bartpe/".$config{FLAVOR}."_extra";
  #local($sysdir)=$TFTPDIR."/bartpe/".$config{FLAVOR}."_sys";
  #local($infdir)=$TFTPDIR."/bartpe/".$config{FLAVOR}."_inf";

  #local($result)=&RunCommand("rmdir $flavordir","Removing Flavor dir $flavordir");
  #local($result)=&StopService("binl");
  #local($result)=&RunCommand("rm -rf $extradir","Removing extra dir $extradir");
  #local($result)=&StartService("binl");
  #local($result)=&RunCommand("rm -rf $sysdir","Removing sys dir $sysdir");
  #local($result)=&RunCommand("rm -rf $infdir","Removing inf dir $infdir");

  return 0;
}

sub bartpe_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;

  # Copy the CONFIGFILE1
  local($orgfile)=$info{CONFIGFILE1};
  local($destfile)=&bartpe_GetDefaultConfigFile1($desttemplate);

  local($result)=&RunCommand("cp $orgfile $destfile","Copying $orgfile to $destfile");
  if ($result)
  {
    &PrintError("Could not copy config file");
    return 1;
  }

  $info{CONFIGFILE1}=$destfile;
  $info{TEMPLATE}=$desttemplate;
  
  # Generate new information
  $info{PUBLISHFILE1}=&bartpe_GetDefaultPublishFile($info{TEMPLATE});
  $info{PUBLISHDIR1}=&bartpe_GetDefaultPublishDir($info{TEMPLATE});
  # $info{CMDLINE}=&bartpe_GetDefaultCommandLine($info{TEMPLATE});
  # $info{KERNEL}=&bartpe_GetDefaultKerel($info{TEMPLATE});

  local($result)=&WriteTemplateInfo(%info);
  if ($result)
  {
    &PrintError("Could not write template info");
    return 1;
  }
  return 0;
}

sub bartpe_DeleteTemplate
{
  local($template)=shift;

  # un-jpublish

  # delete cfg file

  # delete subfile
  
  # delete dat file

  return 0;
}

sub bartpe_ConfigureTemplate
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
  print "<INPUT TYPE=HIDDEN NAME=BARTPEISO VALUE=\"$config{BARTPEISO}\">\n";
  print "<INPUT TYPE=HIDDEN NAME=TEMPLATEID VALUE=\"$config{TEMPLATEID}\">\n";
  print "<TEXTAREA WRAP=OFF NAME=KICKSTARTFILE ROWS=20 COLS=60>";
  for $line (@kickstart)
  {
    print $line;
  }
  print "</TEXTAREA>\n";
  return 0;
}

sub bartpe_ApplyConfigureTemplate
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
  $info{BARTPEISO}=$formdata{BARTPEISO};

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
