#!/usr/bin/perl

require "kickstart.pl";

sub ubuntu8x64_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("ubuntu8x64");
 return $result;
}

sub ubuntu8x64_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub ubuntu8x64_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"ubuntu8x64");
  return ($result);
}

sub ubuntu8x64_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ramdisk_size=14984 vga=normal netcfg/get_hostname= interface=auto url=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] auto=true priority=critical -- ";
  return $commandline;
}

sub ubuntu8x64_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub ubuntu8x64_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub ubuntu8x64_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub ubuntu8x64_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub ubuntu8x64_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("ubuntu8x64");
  return $result;
}

sub ubuntu8x64_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("ubuntu8x64",$template,$desttemplate,%info);
  return $result;
}

sub ubuntu8x64_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"ubuntu8x64");
  return $result;
}

sub ubuntu8x64_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("ubuntu8x64",$template,%config);
  return $result;
}

sub ubuntu8x64_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("ubuntu8x64",$template,%info);
  return $result;
}

sub ubuntu8x64_NewOS_2
{
 local($result)=&kickstart_NewOS_2("ubuntu8x64");
 return result;
}

sub ubuntu8x64_ImportOS
{
 local($result)=&kickstart_ImportOS("ubuntu8x64");
  return $result;
}

sub ubuntu8x64_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/install/netboot/ubuntu-installer/amd64/initrd.gz";
  local($kernellocation)="/install/netboot/ubuntu-installer/amd64/linux";
  local($result)=&kickstart_ImportOS_DoIt("ubuntu8x64",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
