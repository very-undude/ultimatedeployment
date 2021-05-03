#!/usr/bin/perl

require "kickstart.pl";

sub redhat7_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("redhat7");
 return $result;
}

sub redhat7_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub redhat7_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"redhat7");
  return ($result);
}

sub redhat7_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="append inst.stage2=http://[UDA_IPADDR]/[OS]/[FLAVOR]/ inst.ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] text bootproto=dhcp";
  return $commandline;
}

sub redhat7_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub redhat7_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub redhat7_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub redhat7_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub redhat7_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("redhat7");
  return $result;
}

sub redhat7_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("redhat7",$template,$desttemplate,%info);
  return $result;
}

sub redhat7_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"redhat7");
  return $result;
}

sub redhat7_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("redhat7",$template,%config);
  return $result;
}

sub redhat7_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("redhat7",$template,%info);
  return $result;
}

sub redhat7_NewOS_2
{
 local($result)=&kickstart_NewOS_2("redhat7");
 return result;
}

sub redhat7_ImportOS
{
 local($result)=&kickstart_ImportOS("redhat7");
  return $result;
}

sub redhat7_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("redhat7",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
