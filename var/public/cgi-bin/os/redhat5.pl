#!/usr/bin/perl

require "kickstart.pl";

sub redhat5_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("redhat5");
 return $result;
}

sub redhat5_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub redhat5_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"redhat5");
  return ($result);
}

sub redhat5_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ks=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] ramdrive_size=8192";
  return $commandline;
}

sub redhat5_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub redhat5_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub redhat5_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub redhat5_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub redhat5_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("redhat5");
  return $result;
}

sub redhat5_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("redhat5",$template,$desttemplate,%info);
  return $result;
}

sub redhat5_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"redhat5");
  return $result;
}

sub redhat5_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("redhat5",$template,%config);
  return $result;
}

sub redhat5_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("redhat5",$template,%info);
  return $result;
}

sub redhat5_NewOS_2
{
 local($result)=&kickstart_NewOS_2("redhat5");
 return result;
}

sub redhat5_ImportOS
{
 local($result)=&kickstart_ImportOS("redhat5");
  return $result;
}

sub redhat5_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/images/pxeboot/initrd.img";
  local($kernellocation)="/images/pxeboot/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("redhat5",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
