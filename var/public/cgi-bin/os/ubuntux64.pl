#!/usr/bin/perl

require "kickstart.pl";

sub ubuntux64_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("ubuntux64");
 return $result;
}

sub ubuntux64_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub ubuntux64_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"ubuntux64");
  return ($result);
}

sub ubuntux64_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="ramdisk_size=14984 vga=normal netcfg/get_hostname= interface=auto url=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE].cfg initrd=initrd.[OS].[FLAVOR] auto=true priority=critical -- ";
  return $commandline;
}

sub ubuntux64_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub ubuntux64_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=&kickstart_GetDefaultPublishFile($template);
  return $publishfile;
}

sub ubuntux64_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=&kickstart_GetDefaultPublishDir($template);
  return $publishdir;
}

sub ubuntux64_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub ubuntux64_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("ubuntux64");
  return $result;
}

sub ubuntux64_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("ubuntux64",$template,$desttemplate,%info);
  return $result;
}

sub ubuntux64_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"ubuntux64");
  return $result;
}

sub ubuntux64_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("ubuntux64",$template,%config);
  return $result;
}

sub ubuntux64_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("ubuntux64",$template,%info);
  return $result;
}

sub ubuntux64_NewOS_2
{
 local($result)=&kickstart_NewOS_2("ubuntux64");
 return result;
}

sub ubuntux64_ImportOS
{
 local($result)=&kickstart_ImportOS("ubuntux64");
  return $result;
}

sub ubuntux64_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/install/netboot/ubuntu-installer/amd64/initrd.gz";
  local($kernellocation)="/install/netboot/ubuntu-installer/amd64/linux";
  local($result)=&kickstart_ImportOS_DoIt("ubuntux64",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

1;
