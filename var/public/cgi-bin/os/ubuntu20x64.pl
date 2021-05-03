#!/usr/bin/perl

require "kickstart.pl";

sub ubuntu20x64_NewTemplate_2
{
 local($result)=&kickstart_NewTemplate_Finish("ubuntu20x64");
 return $result;
}

sub ubuntu20x64_WriteTemplatePXEMenu
{
  local($template)=shift;
  local($result)=&WriteTemplatePXEMenu($template);
  return 0;
}

sub ubuntu20x64_CopyTemplateFile
{
  local($template)=shift;
  local($destfile)=shift;
  local($result)=&kickstart_CopyTemplateFile($template,$destfile,"ubuntu20x64");
  return ($result);
}

sub ubuntu20x64_GetDefaultCommandLine
{
  local($template)=@_;
  local($commandline)="initrd=initrd.[OS].[FLAVOR] root=/dev/ram0 ramdisk_size=1500000 ip=dhcp url=http://[UDA_IPADDR]//kickstart/[TEMPLATE]/[SUBTEMPLATE]/install.iso autoinstall ds=nocloud-net;s=http://[UDA_IPADDR]/kickstart/[TEMPLATE]/[SUBTEMPLATE]";
  return $commandline;
}

sub ubuntu20x64_GetDefaultConfigFile1
{
  local($template)=@_;
  local($configfile)=&kickstart_GetDefaultConfigFile1($template);
  return $configfile;
}

sub ubuntu20x64_GetDefaultPublishFile
{
  local($template)=@_;
  local($publishfile)=$WWWDIR."/kickstart/$template/[SUBTEMPLATE].cfg";
  return $publishfile;
}

sub ubuntu20x64_GetDefaultPublishDir
{
  local($template)=@_;
  local($publishdir)=$WWWDIR."/kickstart/$template/";
  return $publishdir;
}

sub ubuntu20x64_GetDefaultKernel
{
  local($template)=@_;
  local($kernel)="vmlinuz.[OS].[FLAVOR]";
  return $kernel;
}

sub ubuntu20x64_CreateTemplate
{
  local($result)=&kickstart_CreateTemplate("ubuntu20x64");
  return $result;
}

sub ubuntu20x64_CopyTemplate
{
  local($template,$desttemplate,%info)=@_;
  local($result)=&kickstart_CopyTemplate("ubuntu20x64",$template,$desttemplate,%info);
  return $result;
}

sub ubuntu20x64_DeleteTemplate
{
  local($template)=shift;
  local($result)=&kickstart_DeleteTemplate($template,"ubuntu20x64");
  return $result;
}

sub ubuntu20x64_ConfigureTemplate
{
  local($template,%config)=@_;
  local($result)=&kickstart_ConfigureTemplate("ubuntu20x64",$template,%config);
  return $result;
}

sub ubuntu20x64_ApplyConfigureTemplate
{
  local($template,%info)=@_;
  
  local($result)=&kickstart_ApplyConfigureTemplate("ubuntu20x64",$template,%info);
  return $result;
}

sub ubuntu20x64_NewOS_2
{
 local($result)=&kickstart_NewOS_2("ubuntu20x64");
 return result;
}

sub ubuntu20x64_ImportOS
{
 local($result)=&kickstart_ImportOS("ubuntu20x64");
  return $result;
}

sub ubuntu20x64_ImportOS_DoIt
{
  local($actionid)=shift;
  local($initrdlocation)="/casper/initrd";
  local($kernellocation)="/casper/vmlinuz";
  local($result)=&kickstart_ImportOS_DoIt("ubuntu20x64",$kernellocation,$initrdlocation,$actionid);
  return $result;
}

sub ubuntu20x64_PublishTemplate
{
  
  #create directories for subtemplates
  #create links user-data to cfg files one directory lower
  #create meta-data files
  #create link to iso

  local($template)=shift;
  local(%info)=&GetTemplateInfo($template);
  local(%osinfo)=&GetOSInfo($info{FLAVOR});
  local($isofile)=$osinfo{MOUNTFILE_1};

   # Create the publish directry for this template
   #local($result)=&CreateDir($info{PUBLISHDIR1});
   #if ($result)
   #{
   #  &PrintError("Could not create directory $info{PUBLISHDIR1}");
   #  return 1;
   #}

   local(%subinfo)=&GetAllSubTemplateInfo($template);
   local(@indexes)=keys(%subinfo);
   if ($#indexes<0)
   {
       # print "<LI>Publishsing default subtemplate for $template\n";
       $info{SUBTEMPLATE}="default";
       local($publishfile)=&FindAndReplace($info{PUBLISHFILE1},%info);
       local($subtemplatedir)=$info{PUBLISHDIR1}."/".$info{SUBTEMPLATE};
       local($result)=&CreateDir($subtemplatedir);
       if ($result)
       {
         &PrintError("Could not create directory $subtemplatedir");
         return 1;
       }
       `ln -sf $publishfile $subtemplatedir/user-data`;
       `echo instance-id: focal-autoinstall> $subtemplatedir/meta-data`;
       `ln -sf $isofile $subtemplatedir/install.iso`;

   } else  {
     local($headerline)=$subinfo{__HEADER__};
     for $sub (keys(%subinfo))
     {
       if ($sub ne "__HEADER__")
       {
         # print "<LI>Publishsing subtemplate $sub\n";
         local(%subinfo)=&GetSubTemplateInfo($headerline,$subinfo{$sub},%info);
         local($publishfile)=&FindAndReplace($subinfo{PUBLISHFILE1},%subinfo);
         local($subtemplatedir)=$info{PUBLISHDIR1}."/".$info{SUBTEMPLATE};
         local($result)=&CreateDir($subtemplatedir);
         if ($result)
         {
           &PrintError("Could not create directory $subtemplatedir");
           return 1;
         }
         `ln -sf $publishfile $subtemplatedir/user-data`;
         `echo instance-id: focal-autoinstall> $subtemplatedir/meta-data`;
         `ln -sf $isofile $subtemplatedir/install.iso`;
        }
     }
  }
  return 0;
}

1;
