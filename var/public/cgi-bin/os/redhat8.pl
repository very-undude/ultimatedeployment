#!/usr/bin/perl

require "kickstart.pl";

sub redhat8_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("redhat8");
 return $result;
}

sub redhat8_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub redhat8_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"redhat8");
  return ($result);
}

sub redhat8_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="append inst.stage2=http://[UDA_IPADDR]/[OS]/[FLAVOR]/ inst.ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] text bootproto=dhcp";
  return $commandline;
}

sub redhat8_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub redhat8_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub redhat8_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub redhat8_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub redhat8_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("redhat8");
  return $result;
}

sub redhat8_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("redhat8",$template,$desttemplate,%info);
  return $result;
}

sub redhat8_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"redhat8");
  return $result;
}

sub redhat8_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("redhat8",$template,%config);
  return $result;
}

sub redhat8_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("redhat8",$template,%info);
  return $result;
}

sub redhat8_NewOS_2
{
 local($result)=&kickstart_NewOS_2("redhat8");
 return result;
}

sub redhat8_ImportOS
{
 local($result)=&kickstart_ImportOS("redhat8");
  return $result;
}

sub redhat8_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("redhat8",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
