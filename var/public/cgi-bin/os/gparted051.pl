#!/usr/bin/perl

require "kickstart.pl";

sub gparted051_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("gparted051");
 return $result;
}

sub gparted051_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub gparted051_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"gparted051");
  return ($result);
}

sub gparted051_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="initrd=initrd.[OS].[FLAVOR] boot=live live-config union=aufs noswap noprompt vga=788 fetch=http://[UDA_IPADDR]/[OS]/[FLAVOR]/live/filesystem.squashfs";
  return $commandline;
}

sub gparted051_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub gparted051_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub gparted051_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub gparted051_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub gparted051_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("gparted051");
  return $result;
}

sub gparted051_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("gparted051",$template,$desttemplate,%info);
  return $result;
}

sub gparted051_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"gparted051");
  return $result;
}

sub gparted051_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("gparted051",$template,%config);
  return $result;
}

sub gparted051_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("gparted051",$template,%info);
  return $result;
}

sub gparted051_NewOS_2
{
 local($result)=&kickstart_NewOS_2("gparted051");
 return result;
}

sub gparted051_ImportOS
{
 local($result)=&kickstart_ImportOS("gparted051");
  return $result;
}

sub gparted051_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/live/initrd.img";
  local($kernellocation)="/live/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("gparted051",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
