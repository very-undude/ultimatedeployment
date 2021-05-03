#!/usr/bin/perl

require "kickstart.pl";

sub redhat6_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("redhat6");
 return $result;
}

sub redhat6_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub redhat6_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"redhat6");
  return ($result);
}

sub redhat6_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] ramdrive_size=8192";
  return $commandline;
}

sub redhat6_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub redhat6_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub redhat6_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub redhat6_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub redhat6_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("redhat6");
  return $result;
}

sub redhat6_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("redhat6",$template,$desttemplate,%info);
  return $result;
}

sub redhat6_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"redhat6");
  return $result;
}

sub redhat6_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("redhat6",$template,%config);
  return $result;
}

sub redhat6_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("redhat6",$template,%info);
  return $result;
}

sub redhat6_NewOS_2
{
 local($result)=&kickstart_NewOS_2("redhat6");
 return result;
}

sub redhat6_ImportOS
{
 local($result)=&kickstart_ImportOS("redhat6");
  return $result;
}

sub redhat6_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("redhat6",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
