#!/usr/bin/perl

require "kickstart.pl";

sub esx41i_NewTemplate_2
{
  local($result)=&kickstart_NewTemplate_Finish("esx41i");
  return $result;
}

sub esx41i_NewTemplate_Finish
{
 local($result)=&kickstart_NewTemplate_Finish("esx41i");
 return $result;
}

sub esx41i_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub esx41i_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"esx41i");
  return ($result);
}

sub esx41i_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="[OS].[FLAVOR].vmkboot.gz ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg --- [OS].[FLAVOR].vmkernel.gz --- [OS].[FLAVOR].sys.vgz --- [OS].[FLAVOR].cim.vgz --- [OS].[FLAVOR].ienviron.vgz --- [OS].[FLAVOR].install.vgz";
  return $commandline;
}

sub esx41i_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub esx41i_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub esx41i_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub esx41i_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="[OS].[FLAVOR].mboot.c32";
  return $kernel;
}

sub esx41i_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("esx41i");
  return $result;
}

sub esx41i_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("esx41i",$template,$desttemplate,%info);
  return $result;
}

sub esx41i_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"esx41i");
  return $result;
}

sub esx41i_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("esx41i",$template,%config);
  return $result;
}

sub esx41i_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("esx41i",$template,%info);
  return $result;
}

sub esx41i_NewOS_2
{
 local($result)=&kickstart_NewOS_2("esx41i");
 return result;
}

sub esx41i_ImportOS
{
 local($result)=&kickstart_ImportOS("esx41i");
  return $result;
}

sub esx41i_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/vmkboot.gz";
  local($kernellocation)="/mboot.c32";
  local(@otherfiles)=("vmkboot.gz","mboot.c32","vmkernel.gz","sys.vgz","cim.vgz","ienviron.vgz","install.vgz");
  local($result)=&kickstart_ImportOS_DoIt("esx41i",$kernellocation,$initrdlocation,$actionid,@otherfiles);
  return $result;
}

1;
