#!/usr/bin/perl

require "kickstart.pl";

sub esx3_NewTemplate_2
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
 print "<INPUT TYPE=HIDDEN NAME=OS VALUE=esx3>\n";
 print "<INPUT TYPE=HIDDEN NAME=OSFLAVOR VALUE=\"$formdata{OSFLAVOR}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=MAC VALUE=\"$formdata{MAC}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=PUBLISH VALUE=\"$publish\">\n";
 print "<INPUT TYPE=HIDDEN NAME=DESCRIPTION VALUE=\"$formdata{DESCRIPTION}\">\n";
 print "<INPUT TYPE=HIDDEN NAME=TEMPLATE VALUE=\"$formdata{TEMPLATENAME}\">\n";
 &PrintJavascriptArray("disktypearray","cciss/c0d0;HP (cciss/c0d0)","sda;IBM (sda)","sda;Dell (sda)","sda;Generic SCSI (sda)");
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

sub esx3_NewTemplate_Finish
{
 local($result)=&kickstart_NewTemplate_Finish("esx3");
 return $result;
}

sub esx3_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub esx3_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"esx3");
  return ($result);
}

sub esx3_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] ramdrive_size=8192";
  return $commandline;
}

sub esx3_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub esx3_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub esx3_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub esx3_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub esx3_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("esx3");
  return $result;
}

sub esx3_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("esx3",$template,$desttemplate,%info);
  return $result;
}

sub esx3_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"esx3");
  return $result;
}

sub esx3_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("esx3",$template,%config);
  return $result;
}

sub esx3_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("esx3",$template,%info);
  return $result;
}

sub esx3_NewOS_2
{
 local($result)=&kickstart_NewOS_2("esx3");
 return result;
}

sub esx3_ImportOS
{
 local($result)=&kickstart_ImportOS("esx3");
  return $result;
}

sub esx3_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("esx3",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
