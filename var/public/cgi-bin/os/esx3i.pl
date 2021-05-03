#!/usr/bin/perl

require "kickstart.pl";

sub esx3i_NewTemplate_2
{
  local($result)=&kickstart_NewTemplate_Finish("esx3i");
  return $result;
}

sub esx3i_NewTemplate_Finish
{
 local($result)=&kickstart_NewTemplate_Finish("esx3i");
 return $result;
}

sub esx3i_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub esx3i_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"esx3i");
  return ($result);
}

sub esx3i_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="[OS].[FLAVOR].vmkernel.gz --- [OS].[FLAVOR].binmod.tgz --- [OS].[FLAVOR].ienviron.tgz --- [OS].[FLAVOR].cim.tgz --- [OS].[FLAVOR].oem.tgz --- [OS].[FLAVOR].license.tgz --- [OS].[FLAVOR].install.tgz";
  return $commandline;
}

sub esx3i_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub esx3i_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub esx3i_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub esx3i_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="[OS].[FLAVOR].mboot.c32";
  return $kernel;
}

sub esx3i_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("esx3i");
  return $result;
}

sub esx3i_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("esx3i",$template,$desttemplate,%info);
  return $result;
}

sub esx3i_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"esx3i");
  return $result;
}

sub esx3i_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("esx3i",$template,%config);
  return $result;
}

sub esx3i_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("esx3i",$template,%info);
  return $result;
}

sub esx3i_NewOS_2
{
 local($result)=&kickstart_NewOS_2("esx3i");
 return result;
}

sub esx3i_ImportOS
{
 local($result)=&kickstart_ImportOS("esx3i");
  return $result;
}

sub esx3i_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/vmkernel.gz";
  local($kernellocation)="/mboot.c32";
  local(@otherfiles)=("mboot.c32","vmkernel.gz","binmod.tgz","ienviron.tgz","cim.tgz","oem.tgz","license.tgz","install.tgz");
  local($result)=&kickstart_ImportOS_DoIt("esx3i",$kernellocation,$initrdlocation,$actionid,@otherfiles);
  return $result;
}

1;
