#!/usr/bin/perl

require "kickstart.pl";

sub fedora16_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("fedora16");
 return $result;
}

sub fedora16_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub fedora16_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"fedora16");
  return ($result);
}

sub fedora16_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] ramdrive_size=8192";
  return $commandline;
}

sub fedora16_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub fedora16_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub fedora16_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub fedora16_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub fedora16_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("fedora16");
  return $result;
}

sub fedora16_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("fedora16",$template,$desttemplate,%info);
  return $result;
}

sub fedora16_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"fedora16");
  return $result;
}

sub fedora16_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("fedora16",$template,%config);
  return $result;
}

sub fedora16_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("fedora16",$template,%info);
  return $result;
}

sub fedora16_NewOS_2
{
 local($result)=&kickstart_NewOS_2("fedora16");
 return result;
}

sub fedora16_ImportOS
{
 local($result)=&kickstart_ImportOS("fedora16");
  return $result;
}

sub fedora16_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("fedora16",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
