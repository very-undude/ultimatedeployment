#!/usr/bin/perl

require "kickstart.pl";

sub esx4i_NewTemplate_2
{
  local($result)=&kickstart_NewTemplate_Finish("esx4i");
  return $result;
}

sub esx4i_NewTemplate_Finish
{
 local($result)=&kickstart_NewTemplate_Finish("esx4i");
 return $result;
}

sub esx4i_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub esx4i_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"esx4i");
  return ($result);
}

sub esx4i_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="[OS].[FLAVOR].vmkboot.gz --- [OS].[FLAVOR].vmkernel.gz --- [OS].[FLAVOR].sys.vgz --- [OS].[FLAVOR].cim.vgz --- [OS].[FLAVOR].ienviron.tgz --- [OS].[FLAVOR].image.tgz --- [OS].[FLAVOR].install.tgz";
  return $commandline;
}

sub esx4i_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub esx4i_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub esx4i_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub esx4i_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="[OS].[FLAVOR].mboot.c32";
  return $kernel;
}

sub esx4i_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("esx4i");
  return $result;
}

sub esx4i_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("esx4i",$template,$desttemplate,%info);
  return $result;
}

sub esx4i_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"esx4i");
  return $result;
}

sub esx4i_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("esx4i",$template,%config);
  return $result;
}

sub esx4i_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("esx4i",$template,%info);
  return $result;
}

sub esx4i_NewOS_2
{
 local($result)=&kickstart_NewOS_2("esx4i");
 return result;
}

sub esx4i_ImportOS
{
 local($result)=&kickstart_ImportOS("esx4i");
  return $result;
}

sub esx4i_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/vmkboot.gz";
  local($kernellocation)="/mboot.c32";
  local(@otherfiles)=("vmkboot.gz","mboot.c32","vmkernel.gz","sys.vgz","cim.vgz","ienviron.tgz","image.tgz","install.tgz");
  local($result)=&kickstart_ImportOS_DoIt("esx4i",$kernellocation,$initrdlocation,$actionid,@otherfiles);
  return $result;
}

1;
