#!/usr/bin/perl

require "kickstart.pl";

sub centos8_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("centos8");
 return $result;
}

sub centos8_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub centos8_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"centos8");
  return ($result);
}

sub centos8_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="append inst.stage2=http://[UDA_IPADDR]/[OS]/[FLAVOR]/ inst.ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] text bootproto=dhcp";
  return $commandline;
}

sub centos8_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub centos8_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub centos8_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub centos8_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub centos8_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("centos8");
  return $result;
}

sub centos8_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("centos8",$template,$desttemplate,%info);
  return $result;
}

sub centos8_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"centos8");
  return $result;
}

sub centos8_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("centos8",$template,%config);
  return $result;
}

sub centos8_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("centos8",$template,%info);
  return $result;
}

sub centos8_NewOS_2
{
 local($result)=&kickstart_NewOS_2("centos8");
 return result;
}

sub centos8_ImportOS
{
 local($result)=&kickstart_ImportOS("centos8");
  return $result;
}

sub centos8_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("centos8",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
