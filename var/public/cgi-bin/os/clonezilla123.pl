#!/usr/bin/perl

require "kickstart.pl";

sub clonezilla123_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("clonezilla123");
 return $result;
}

sub clonezilla123_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub clonezilla123_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"clonezilla123");
  return ($result);
}

sub clonezilla123_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="initrd=initrd.[OS].[FLAVOR] boot=live live-config union=aufs noswap noprompt vga=788 fetch=http://[UDA_IPADDR]/[OS]/[FLAVOR]/live/filesystem.squashfs";
  return $commandline;
}

sub clonezilla123_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub clonezilla123_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub clonezilla123_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub clonezilla123_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub clonezilla123_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("clonezilla123");
  return $result;
}

sub clonezilla123_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("clonezilla123",$template,$desttemplate,%info);
  return $result;
}

sub clonezilla123_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"clonezilla123");
  return $result;
}

sub clonezilla123_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("clonezilla123",$template,%config);
  return $result;
}

sub clonezilla123_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("clonezilla123",$template,%info);
  return $result;
}

sub clonezilla123_NewOS_2
{
 local($result)=&kickstart_NewOS_2("clonezilla123");
 return result;
}

sub clonezilla123_ImportOS
{
 local($result)=&kickstart_ImportOS("clonezilla123");
  return $result;
}

sub clonezilla123_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/live/initrd.img";
  local($kernellocation)="/live/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("clonezilla123",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
