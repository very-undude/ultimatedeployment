#!/usr/bin/perl

require "kickstart.pl";

sub ubuntu_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("ubuntu");
 return $result;
}

sub ubuntu_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub ubuntu_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"ubuntu");
  return ($result);
}

sub ubuntu_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ramdisk_size=14984 vga=normal netcfg/get_hostname= interface=auto url=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] auto=true priority=critical -- ";
  return $commandline;
}

sub ubuntu_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub ubuntu_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub ubuntu_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub ubuntu_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub ubuntu_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("ubuntu");
  return $result;
}

sub ubuntu_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("ubuntu",$template,$desttemplate,%info);
  return $result;
}

sub ubuntu_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"ubuntu");
  return $result;
}

sub ubuntu_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("ubuntu",$template,%config);
  return $result;
}

sub ubuntu_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("ubuntu",$template,%info);
  return $result;
}

sub ubuntu_NewOS_2
{
 local($result)=&kickstart_NewOS_2("ubuntu");
 return result;
}

sub ubuntu_ImportOS
{
 local($result)=&kickstart_ImportOS("ubuntu");
  return $result;
}

sub ubuntu_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/install/netboot/ubuntu-installer/i386/initrd.gz";
  local($kernellocation)="/install/netboot/ubuntu-installer/i386/linux";
  local($result)=&kickstart_ImportOS_DoIt("ubuntu",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
