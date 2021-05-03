#!/usr/bin/perl

require "kickstart.pl";

sub xen5_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("xen5");
 return $result;
}

sub xen5_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub xen5_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"xen5");
  return ($result);
}

sub xen5_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="[OS].[FLAVOR].xen.gz watchdog com1=115200,8n1 console=com1,tty --- vmlinuz.[OS].[FLAVOR] root=/dev/ram0 console=tty0 console=ttyS0,115200n8 ramdisk_size=32758 answerfile=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg install --- initrd.[OS].[FLAVOR]";

  return $commandline;
}

sub xen5_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub xen5_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub xen5_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub xen5_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="mboot.c32";
  return $kernel;
}

sub xen5_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("xen5");
  return $result;
}

sub xen5_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("xen5",$template,$desttemplate,%info);
  return $result;
}

sub xen5_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"xen5");
  return $result;
}

sub xen5_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("xen5",$template,%config);
  return $result;
}

sub xen5_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("xen5",$template,%info);
  return $result;
}

sub xen5_NewOS_2
{
 local($result)=&kickstart_NewOS_2("xen5");
 return result;
}

sub xen5_ImportOS
{
 local($result)=&kickstart_ImportOS("xen5");
  return $result;
}

sub xen5_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/install.img";
  local($kernellocation)="/boot/vmlinuz";
  local(@otherfiles)=("/boot/xen.gz");
  local($result)=&kickstart_ImportOS_DoIt("xen5",$kernellocation,$initrdlocation,$actionid,@otherfiles);
  return $result;
}

1;
