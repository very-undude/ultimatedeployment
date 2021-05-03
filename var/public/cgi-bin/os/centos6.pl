#!/usr/bin/perl

require "kickstart.pl";

sub centos6_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("centos6");
 return $result;
}

sub centos6_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub centos6_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"centos6");
  return ($result);
}

sub centos6_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] ramdrive_size=8192";
  return $commandline;
}

sub centos6_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub centos6_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub centos6_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub centos6_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub centos6_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("centos6");
  return $result;
}

sub centos6_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("centos6",$template,$desttemplate,%info);
  return $result;
}

sub centos6_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"centos6");
  return $result;
}

sub centos6_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("centos6",$template,%config);
  return $result;
}

sub centos6_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("centos6",$template,%info);
  return $result;
}

sub centos6_NewOS_2
{
 local($result)=&kickstart_NewOS_2("centos6");
 return result;
}

sub centos6_ImportOS
{
 local($result)=&kickstart_ImportOS("centos6");
  return $result;
}

sub centos6_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("centos6",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
