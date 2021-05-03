#!/usr/bin/perl

require "kickstart.pl";

sub centos7_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("centos7");
 return $result;
}

sub centos7_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub centos7_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"centos7");
  return ($result);
}

sub centos7_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="append inst.stage2=http://[UDA_IPADDR]/[OS]/[FLAVOR]/ inst.ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] text bootproto=dhcp";
  return $commandline;
}

sub centos7_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub centos7_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub centos7_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub centos7_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub centos7_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("centos7");
  return $result;
}

sub centos7_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("centos7",$template,$desttemplate,%info);
  return $result;
}

sub centos7_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"centos7");
  return $result;
}

sub centos7_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("centos7",$template,%config);
  return $result;
}

sub centos7_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("centos7",$template,%info);
  return $result;
}

sub centos7_NewOS_2
{
 local($result)=&kickstart_NewOS_2("centos7");
 return result;
}

sub centos7_ImportOS
{
 local($result)=&kickstart_ImportOS("centos7");
  return $result;
}

sub centos7_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("centos7",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
