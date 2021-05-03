#!/usr/bin/perl

require "kickstart.pl";

sub redhat4_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("redhat4");
 return $result;
}

sub redhat4_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub redhat4_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"redhat4");
  return ($result);
}

sub redhat4_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] ramdrive_size=8192";
  return $commandline;
}

sub redhat4_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub redhat4_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub redhat4_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub redhat4_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub redhat4_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("redhat4");
  return $result;
}

sub redhat4_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("redhat4",$template,$desttemplate,%info);
  return $result;
}

sub redhat4_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"redhat4");
  return $result;
}

sub redhat4_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("redhat4",$template,%config);
  return $result;
}

sub redhat4_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("redhat4",$template,%info);
  return $result;
}

sub redhat4_NewOS_2
{

 local($osflavor)=$formdata{OSFLAVOR};
 print "<CENTER>\n"; 
 print "<H2>New Operating System Wizard Step 2</H2>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=os>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=new>\n";
 print "<INPUT TYPE=HIDDEN NAME=step VALUE=2>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=redhat4>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<script language='javascript' src='/js/redhat4.js'></script>\n";
 # print "<script language='javascript' src='/js/kickstartnewos.js'></script>\n";
 # print "<script language='javascript' src='/js/newos.js'></script>\n";
 print "<script language='javascript' src='/js/validation.js'></script>\n";
 print "<script language='javascript' src='/js/tree_dir.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR><BR>\n";
 local(@mountlist)=&GetMountList();;
 &PrintJavascriptArray("mountsarray",@mountlist);
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<TABLE>\n";
 print "<TR><TD>Storage</TD><TD><SELECT NAME=MOUNT ID=MOUNT ONCHANGE=\"expand('/')\"></SELECT></TD></TR>\n";
 print "<TR><TD>Path</TD><TD><INPUT TYPE=TEXT NAME=PATH ID=\"PATH\" SIZE=60 VALUE='/' DISABLED></TD></TR>\n";
 print "<TR><TD>Directory</TD><TD><SELECT NAME=DIRECTORY ID=DIRECTORY ONCHANGE=\"expand(this.value);\"></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile 1</TD><TD><SELECT NAME=FILE1 ID=FILE1></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile 2</TD><TD><SELECT NAME=FILE2 ID=FILE2></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile 3</TD><TD><SELECT NAME=FILE3 ID=FILE3></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile 4</TD><TD><SELECT NAME=FILE4 ID=FILE4></SELECT></TD></TR>\n";
 # print "<TR><TD COLSPAN=2><DIV ID=browse_div></DIV></TD></TR>\n";
 print "<TR><TD>Mount on Boot</TD><TD><INPUT TYPE=CHECKBOX NAME=MOUNTONBOOT CHECKED></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "<script language='javascript'>\n";
 print "LoadValues(\"MOUNT\",mountsarray);\n";
 print "expand('/');\n";
 print "</script>\n";
 print "</CENTER>\n";

 return result;
}

sub redhat4_ImportOS
{
 # local($result)=&kickstart_ImportOS("redhat4");
 local($flavor)=$formdata{OSFLAVOR};
 local($mount)=$formdata{MOUNT};
 local($path)=$formdata{PATH};
 local($file1)=$formdata{FILE1};
 local($file2)=$formdata{FILE2};
 local($file3)=$formdata{FILE3};
 local($file4)=$formdata{FILE4};
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
  print "<TR><TD>Operating System</TD><TD>redhat4</TD></TR>\n";
  print "<TR><TD>Flavor Name</TD><TD>$flavor</TD></TR>\n";
  print "<TR><TD>Mount</TD><TD>$mount</TD></TR>\n";
  print "<TR><TD>Path</TD><TD>$path</TD></TR>\n";
  print "<TR><TD>File 1</TD><TD>$file1</TD></TR>\n";
  print "<TR><TD>File 2</TD><TD>$file2</TD></TR>\n";
  print "<TR><TD>File 3</TD><TD>$file3</TD></TR>\n";
  print "<TR><TD>File 4</TD><TD>$file4</TD></TR>\n";
  print "<TR><TD>Mount on boot</TD><TD>$mountonboot</TD></TR>\n";
  #print "<TR><TD>Action ID</TD><TD>$actionid</TD></TR>\n";
  print "<TR><TD>Action ID</TD><TD><A HREF='uda3.pl?module=system&action=actions&button=view&actionid=$actionid'>$actionid</A></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";

  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Import flavor $flavor (redhat4)","os/redhat4.pl","\&redhat4\_ImportOS_DoIt($actionid);");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";

  return 0;
}

sub redhat4_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";

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
  $osinfo{OS}="redhat4";
  $osinfo{MOUNTFILE_1}=$SMBMOUNTDIR."/".$args{MOUNT}.$args{PATH}."/".$args{FILE1};
  $osinfo{MOUNTFILE_2}=$SMBMOUNTDIR."/".$args{MOUNT}.$args{PATH}."/".$args{FILE2};
  $osinfo{MOUNTFILE_3}=$SMBMOUNTDIR."/".$args{MOUNT}.$args{PATH}."/".$args{FILE3};
  $osinfo{MOUNTFILE_4}=$SMBMOUNTDIR."/".$args{MOUNT}.$args{PATH}."/".$args{FILE4};
  if ($mountinfo{TYPE} eq "CDROM")
  {
    $osinfo{MOUNTFILE_1}=$mountinfo{SHARE};
  }
  $osinfo{MOUNTDIR_1}="$WWWDIR/$osinfo{OS}/$osinfo{FLAVOR}";
  $osinfo{MOUNTPOINT_1}="$WWWDIR/$osinfo{OS}/$osinfo{FLAVOR}/disc1";
  $osinfo{MOUNTPOINT_2}="$WWWDIR/$osinfo{OS}/$osinfo{FLAVOR}/disc2";
  $osinfo{MOUNTPOINT_3}="$WWWDIR/$osinfo{OS}/$osinfo{FLAVOR}/disc3";
  $osinfo{MOUNTPOINT_4}="$WWWDIR/$osinfo{OS}/$osinfo{FLAVOR}/disc4";

  $osinfo{FILE_1}="$TFTPDIR/vmlinuz.$osinfo{OS}.$osinfo{FLAVOR}";
  $osinfo{FILE_2}="$TFTPDIR/initrd.$osinfo{OS}.$osinfo{FLAVOR}";
  $osinfo{MOUNTONBOOT}=$args{MOUNTONBOOT};

  local($initrd)="$osinfo{MOUNTPOINT_1}$initrdlocation";
  local($vmlinuz)="$osinfo{MOUNTPOINT_1}$kernellocation";

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

  local($result)=&CreateDir($osinfo{MOUNTDIR_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not create flavor mount directory $osinfo{MOUNTDIR_1}");
    return 3;
  }
  &UpdateActionProgress($actionid,20,"Created flavor mount directory $osinfo{MOUNTDIR_1}");


  local($result)=&CreateDir($osinfo{MOUNTPOINT_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not create flavor mount directory $osinfo{MOUNTPOINT_1}");
    return 3;
  }
  &UpdateActionProgress($actionid,25,"Created flavor mount directory $osinfo{MOUNTPOINT_1}");

  local($result)=&MountIso($osinfo{MOUNTFILE_1},$osinfo{MOUNTPOINT_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not mount iso file $osinfo{MOUNTFILE_1} on $osinfo{MOUNTPOINT_1}");
    return 4;
  }
  &UpdateActionProgress($actionid,30,"Mounted iso file $osinfo{MOUNTFILE_1} on $osinfo{MOUNTPOINT_1}");


  local($result)=&CreateDir($osinfo{MOUNTPOINT_2});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not create flavor mount directory $osinfo{MOUNTPOINT_2}");
    return 3;
  }
  &UpdateActionProgress($actionid,35,"Created flavor mount directory $osinfo{MOUNTPOINT_2}");

  local($result)=&MountIso($osinfo{MOUNTFILE_2},$osinfo{MOUNTPOINT_2});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not mount iso file $osinfo{MOUNTFILE_2} on $osinfo{MOUNTPOINT_2}");
    return 4;
  }
  &UpdateActionProgress($actionid,40,"Mounted iso file $osinfo{MOUNTFILE_2} on $osinfo{MOUNTPOINT_2}");

  local($result)=&CreateDir($osinfo{MOUNTPOINT_3});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not create flavor mount directory $osinfo{MOUNTPOINT_3}");
    return 3;
  }
  &UpdateActionProgress($actionid,45,"Created flavor mount directory $osinfo{MOUNTPOINT_3}");

  local($result)=&MountIso($osinfo{MOUNTFILE_3},$osinfo{MOUNTPOINT_3});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not mount iso file $osinfo{MOUNTFILE_3} on $osinfo{MOUNTPOINT_3}");
    return 4;
  }
  &UpdateActionProgress($actionid,50,"Mounted iso file $osinfo{MOUNTFILE_3} on $osinfo{MOUNTPOINT_3}");

  local($result)=&CreateDir($osinfo{MOUNTPOINT_4});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not create flavor mount directory $osinfo{MOUNTPOINT_4}");
    return 3;
  }
  &UpdateActionProgress($actionid,55,"Created flavor mount directory $osinfo{MOUNTPOINT_4}");

  local($result)=&MountIso($osinfo{MOUNTFILE_4},$osinfo{MOUNTPOINT_4});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not mount iso file $osinfo{MOUNTFILE_4} on $osinfo{MOUNTPOINT_4}");
    return 4;
  }
  &UpdateActionProgress($actionid,60,"Mounted iso file $osinfo{MOUNTFILE_4} on $osinfo{MOUNTPOINT_4}");


  local($result)=&ImportFile($vmlinuz,$osinfo{FILE_1});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not copy vmlinuz $vmlinuz to $osinfo{FILE_1}");
    return 5;
  }
  &UpdateActionProgress($actionid,75,"Copied vmlinuz");

  local($result)=&ImportFile($initrd,$osinfo{FILE_2});
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not copy initrd $initrd to $osinfo{FILE_2}");
    return 6;
  }
  &UpdateActionProgress($actionid,90,"Copied initrd");

  local($result)=&WriteOSInfo(%osinfo);
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not write OS information to file");
    return 7;
  }
  &UpdateActionProgress($actionid,95,"Wrote OS information");

  &UpdateActionProgress($actionid,100,"Successfull");

  return 0;
}

1;
