#!/usr/bin/perl

require "kickstart.pl";

sub gparted_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("gparted");
 return $result;
}

sub gparted_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub gparted_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"gparted");
  return ($result);
}

sub gparted_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="initrd=initrd.[OS].[FLAVOR] boot=live union=aufs noswap noprompt vga=788 fetch=http://[UDA_IPADDR]/[OS]/[FLAVOR]/live/filesystem.squashfs";
  return $commandline;
}

sub gparted_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub gparted_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub gparted_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub gparted_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub gparted_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("gparted");
  return $result;
}

sub gparted_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("gparted",$template,$desttemplate,%info);
  return $result;
}

sub gparted_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"gparted");
  return $result;
}

sub gparted_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("gparted",$template,%config);
  return $result;
}

sub gparted_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("gparted",$template,%info);
  return $result;
}

sub gparted_NewOS_2
{
 local($result)=&kickstart_NewOS_2("gparted");
 return result;
}

sub gparted_ImportOS
{
 local($result)=&kickstart_ImportOS("gparted");
  return $result;
}

sub gparted_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/live/initrd1.img";
  local($kernellocation)="/live/vmlinuz1";
  local($result)=&kickstart_ImportOS_DoIt("gparted",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
