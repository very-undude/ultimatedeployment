#!/usr/bin/perl

require "kickstart.pl";

sub fedora_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("fedora");
 return $result;
}

sub fedora_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub fedora_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"fedora");
  return ($result);
}

sub fedora_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] ramdrive_size=8192";
  return $commandline;
}

sub fedora_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub fedora_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub fedora_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub fedora_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub fedora_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("fedora");
  return $result;
}

sub fedora_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("fedora",$template,$desttemplate,%info);
  return $result;
}

sub fedora_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"fedora");
  return $result;
}

sub fedora_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("fedora",$template,%config);
  return $result;
}

sub fedora_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("fedora",$template,%info);
  return $result;
}

sub fedora_NewOS_2
{
 local($result)=&kickstart_NewOS_2("fedora");
 return result;
}

sub fedora_ImportOS
{
 local($result)=&kickstart_ImportOS("fedora");
  return $result;
}

sub fedora_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("fedora",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
