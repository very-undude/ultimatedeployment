#!/usr/bin/perl

require "kickstart.pl";

sub centos5_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("centos5");
 return $result;
}

sub centos5_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub centos5_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"centos5");
  return ($result);
}

sub centos5_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] ramdrive_size=8192";
  return $commandline;
}

sub centos5_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub centos5_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub centos5_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub centos5_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub centos5_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("centos5");
  return $result;
}

sub centos5_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("centos5",$template,$desttemplate,%info);
  return $result;
}

sub centos5_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"centos5");
  return $result;
}

sub centos5_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("centos5",$template,%config);
  return $result;
}

sub centos5_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("centos5",$template,%info);
  return $result;
}

sub centos5_NewOS_2
{
 local($result)=&kickstart_NewOS_2("centos5");
 return result;
}

sub centos5_ImportOS
{
 local($result)=&kickstart_ImportOS("centos5");
  return $result;
}

sub centos5_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("centos5",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
