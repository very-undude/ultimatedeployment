#!/usr/bin/perl

require "kickstart.pl";

sub ubuntu8_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("ubuntu8");
 return $result;
}

sub ubuntu8_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub ubuntu8_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"ubuntu8");
  return ($result);
}

sub ubuntu8_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ramdisk_size=14984 vga=normal console-setup/modelcode=skip netcfg/get_hostname= interface=auto url=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] auto=true priority=critical -- ";
  return $commandline;
}

sub ubuntu8_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub ubuntu8_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub ubuntu8_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub ubuntu8_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub ubuntu8_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("ubuntu8");
  return $result;
}

sub ubuntu8_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("ubuntu8",$template,$desttemplate,%info);
  return $result;
}

sub ubuntu8_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"ubuntu8");
  return $result;
}

sub ubuntu8_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("ubuntu8",$template,%config);
  return $result;
}

sub ubuntu8_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("ubuntu8",$template,%info);
  return $result;
}

sub ubuntu8_NewOS_2
{
 local($result)=&kickstart_NewOS_2("ubuntu8");
 return result;
}

sub ubuntu8_ImportOS
{
 local($result)=&kickstart_ImportOS("ubuntu8");
  return $result;
}

sub ubuntu8_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/install/netboot/ubuntu-installer/i386/initrd.gz";
  local($kernellocation)="/install/netboot/ubuntu-installer/i386/linux";
  local($result)=&kickstart_ImportOS_DoIt("ubuntu8",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
