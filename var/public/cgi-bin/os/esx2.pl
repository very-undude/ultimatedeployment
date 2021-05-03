#!/usr/bin/perl

require "kickstart.pl";

sub esx2_NewTemplate_2
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
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=esx2>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MAC VALUE=\"$formdata{MAC}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=PUBLISH VALUE=\"$publish\">\n";
 print "<INPUT TYPE=HIDDEN NAME=DESCRIPTION VALUE=\"$formdata{DESCRIPTION}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=TEMPLATE VALUE=\"$formdata{TEMPLATENAME}\">\n";
 &PrintJavascriptArray("disktypearray","/dev/cciss/c0d0;HP (cciss/c0d0)","/dev/sda;IBM (sda)","/dev/sda;Dell (sda)","/dev/sda;Generic SCSI (sda)");
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<script language='javascript' src='/js/newtemplate.js'></script>\n";
 &PrintToolbar("Previous","Finish","Cancel");
 print "<BR>\n";
 print "<TABLE>\n";
 print "<TR><TD>Hardware Type</TD><TD><SELECT NAME=KICKSTART_DISKTYPE ID=DISKTYPE></SELECT></TD></TR>\n";
 print "</TABLE>\n";
 print "<script language='javascript'>\n";
 print "LoadValues(\"DISKTYPE\",disktypearray);\n";
 print "</script>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "</CENTER>\n";

}

sub esx2_NewTemplate_Finish
{
 local($result)=&kickstart_NewTemplate_Finish("esx2");
 return $result;
}

sub esx2_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub esx2_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"esx2");
  return ($result);
}

sub esx2_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ip=dhcp ksdevice=eth0 load_ramdisk=1 ramdisk_size=10240 initrd=initrd.[OS].[FLAVOR] network ks=nfs:[UDA_IPADDR]:/var/public/www/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg";
  return $commandline;
}

sub esx2_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub esx2_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub esx2_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=$WWWDIR."/kickstart/$template";
  return $publishdir;
}

sub esx2_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub esx2_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("esx2");
  return $result;
}

sub esx2_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("esx2",$template,$desttemplate,%info);
  return $result;
}

sub esx2_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"esx2");
  return $result;
}

sub esx2_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("esx2",$template,%config);
  return $result;
}

sub esx2_ApplyConfigureTemplate
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
    $info{PUBLISHFILE1}=&{$info{OS}."_GetDefaultPublishFile"}($newtemplate);
    $info{PUBLISHDIR1}=&{$info{OS}."_GetDefaultPublishDir"}($newtemplate);
  } else {
    $info{CONFIGFILE1}=$formdata{CONFIGFILE1};
    $info{PUBLISHFILE1}=$formdata{PUBLISHFILE1};
    $info{PUBLISHDIR1}=$formdata{PUBLISHDIR1};
  }

  $info{KERNEL}=$formdata{KERNEL};
  $info{NFSEXPORT_1}=$info{PUBLISHDIR1};
  $info{NFSEXPORTOPTIONS_1}="*(ro,nohide,insecure,no_root_squash,no_subtree_check,async)";

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
  &RunCommand("cp $tmpfile $formdata{CONFIGFILE1}","Copying temporary file |$tmpfile| to |$formdata{CONFIGFILE1}|\n");
  unlink($tmpfile);

  return 0;
}

sub esx2_NewOS_2
{
 local($result)=&kickstart_NewOS_2("esx2");
 return result;
}

sub esx2_ImportOS
{
 local($result)=&kickstart_ImportOS("esx2");
  return $result;
}

sub esx2_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("esx2",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

sub esx2_PublishTemplate
{
  local($template)=shift;

  local(%info)=&GetTemplateInfo($template);

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

1;
