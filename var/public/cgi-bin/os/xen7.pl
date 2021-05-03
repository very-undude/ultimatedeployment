#!/usr/bin/perl

require "kickstart.pl";

sub xen7_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("xen7");
 return $result;
}

sub xen7_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub xen7_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"xen7");
  return ($result);
}

sub xen7_GetDefaultCommandLine
{
  local($template)=@_;
  #local($commandline)="[OS].[FLAVOR].xen.gz watchdog com1=115200,8n1 console=com1,tty --- vmlinuz.[OS].[FLAVOR] root=/dev/ram0 console=tty0 console=ttyS0,115200n8 ramdisk_size=32758 answerfile=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg install --- initrd.[OS].[FLAVOR]";
  local($commandline)="[OS].[FLAVOR].xen.gz dom0_max_vcpus=1 dom0_mem=1024M,max:1024M com1=115200,8n1 console=com1,vga --- vmlinuz.[OS].[FLAVOR] xencons=hvc console=hvc0 console=tty0 answerfile=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg install --- initrd.[OS].[FLAVOR]";
  return $commandline;
}

sub xen7_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub xen7_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub xen7_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub xen7_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="mboot.c32";
  return $kernel;
}

sub xen7_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("xen7");
  return $result;
}

sub xen7_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("xen7",$template,$desttemplate,%info);
  return $result;
}

sub xen7_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"xen7");
  return $result;
}

sub xen7_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("xen7",$template,%config);
  return $result;
}

sub xen7_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("xen7",$template,%info);
  return $result;
}

sub xen7_NewOS_2
{
 local($result)=&kickstart_NewOS_2("xen7");
 return result;
}

sub xen7_ImportOS
{
 local($result)=&kickstart_ImportOS("xen7");
  return $result;
}

sub xen7_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/install.img";
  local($kernellocation)="/boot/vmlinuz";
  local(@otherfiles)=("/boot/xen.gz");
  local($result)=&kickstart_ImportOS_DoIt("xen7",$kernellocation,$initrdlocation,$actionid,@otherfiles);
  return $result;
}

1;
