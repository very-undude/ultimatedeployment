#!/usr/bin/perl

require "kickstart.pl";

sub clonezilla_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("clonezilla");
 return $result;
}

sub clonezilla_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub clonezilla_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"clonezilla");
  return ($result);
}

sub clonezilla_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="initrd=initrd.[OS].[FLAVOR] boot=live union=aufs noswap noprompt vga=788 fetch=http://[UDA_IPADDR]/[OS]/[FLAVOR]/live/filesystem.squashfs";
  return $commandline;
}

sub clonezilla_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub clonezilla_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub clonezilla_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub clonezilla_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub clonezilla_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("clonezilla");
  return $result;
}

sub clonezilla_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("clonezilla",$template,$desttemplate,%info);
  return $result;
}

sub clonezilla_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"clonezilla");
  return $result;
}

sub clonezilla_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("clonezilla",$template,%config);
  return $result;
}

sub clonezilla_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("clonezilla",$template,%info);
  return $result;
}

sub clonezilla_NewOS_2
{
 local($result)=&kickstart_NewOS_2("clonezilla");
 return result;
}

sub clonezilla_ImportOS
{
 local($result)=&kickstart_ImportOS("clonezilla");
  return $result;
}

sub clonezilla_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/live/initrd1.img";
  local($kernellocation)="/live/vmlinuz1";
  local($result)=&kickstart_ImportOS_DoIt("clonezilla",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
