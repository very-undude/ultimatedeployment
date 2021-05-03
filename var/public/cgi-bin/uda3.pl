#!/usr/bin/perl
# Copyright 2006-2008 Carl Thijssen

# This file is part of the Ultimate Deployment Appliance.
#
# Ultimate Deployment Appliance is free software; you can redistribute
# it and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Ultimate Deployment Appliance is distributed in the hope that it will
# be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

unshift(@INC,"/var/public/cgi-bin");
require "general.pl" ;
require "config.pl" ;

local(%formdata)=&GetFormData();
&PrintHeader();
# Main Routine

if ($formdata{module} eq "os")
{
  require "os.pl" ;
  if ($formdata{action} eq "list")
  {
    &DisplayOSList();
  }
  if ($formdata{action} eq "unmount")
  {
    &UnmountOSFlavor($formdata{flavor});
    &DisplayOSList();
  }
  if ($formdata{action} eq "mount")
  {
    &MountOSFlavor($formdata{flavor});
    &DisplayOSList();
  }

  if ($formdata{action} eq "drivers")
  {

     if ($formdata{button} eq "cancel")
     {
       &DisplayOSList();
     }

     if ($formdata{button} eq "edit")
     {

       local($requirefile)=$OSDIR."/$formdata{os}.pl";

       require "$requirefile";

       if (defined(&{$formdata{os}."_EditDrivers"}))
       {
          local($result)=&{$formdata{os}."_EditDrivers"}($formdata{flavor});
          if ($result) { return $result };
       } else {
          &DisplayOSList();
       }
     }
     if ($formdata{button} eq "save")
     {
        local($requirefile)=$OSDIR."/$formdata{os}.pl";

        require "$requirefile";

        if (defined(&{$formdata{os}."_ApplyEditDrivers"}))
        {
           local($result)=&{$formdata{os}."_ApplyEditDrivers"}($formdata{flavor});
           if ($result) { return $result };
        } else {
           &DisplayOSList();
        }
     }
  }


  if ($formdata{action} eq "delete")
  {
    &UnmountOSFlavor($formdata{flavor});
    &DeleteOSFlavor($formdata{flavor});
    # &DisplayOSList();
  }
  if ($formdata{action} eq "new")
  {
    if ($formdata{button} eq "cancel")
    {
      &DisplayOSList();
    } else{
     if ($formdata{button} eq "finish")
     {
       local($requirefile)=$OSDIR."/".$formdata{OS}.".pl";
       require $requirefile;
       &{$formdata{OS}."_ImportOS"}();
     } else {
      if (!defined($formdata{OS}))
      {
        &NewOS();
      } else {
        if ($formdata{step} eq "2" && $formdata{button} eq "previous")
        {
          &NewOS();
        } else {
          local($step)=1;
          local($requirefile)=$OSDIR."/".$formdata{OS}.".pl";
          # print "require=|$requirefile|\n";
          if ($formdata{step} >= 2 && $formdata{button} eq "previous")
          {
            $step = $formdata{step} - 1 ;
            if ( -f $requirefile )
            {
              require $requirefile;
              &{$formdata{OS}."_NewOS_".$step}();
            } else {
              &NewOS();
              print "OS specific implementation for $formdata{OS} not found\n";
            }
          } elsif ($formdata{step} >= 1 && $formdata{button} eq "next") {
            if ($formdata{step} == 1)
            {
              local($result)=&FlavorExists($formdata{OSFLAVOR});
              if ($result == 1)
              {
                &PrintError("Flavor with this name already exists");
                return 0;
              }
            }
            $step = $formdata{step} + 1 ;
            if ( -f $requirefile )
            {
              require $requirefile;
              &{$formdata{OS}."_NewOS_".$step}();
            } else {
              &NewOS();
              print "OS specific implementation for $formdata{OS} not found\n";
            }
          } else {
            &NewOS();
          }
        }
     } 
    }
   }
  }

} elsif ($formdata{module} eq "mounts") {
  require "mounts.pl" ;
  if ($formdata{action} eq "list")
  {
    &DisplayMountList();
  }
  if ($formdata{action} eq "new")
  {
    &NewMount();
  }
  if ($formdata{action} eq "applynew")
  {
    local($mountname)=$formdata{MOUNTNAME};
    local($mounttype)=$formdata{MOUNTTYPE};
    local($hostname)=$formdata{HOSTTNAME};
    local($sharename)=$formdata{SHARENAME};
    local($username)=$formdata{USERNAME};
    local($password)=$formdata{PASSWORD};
    local($domain)=$formdata{DOMAIN};
    local($result)=&ApplyNewMount($mountname,$mounttype,$hostname,$sharename,$username,$password,$domain);
    if ($result == 0)
    {
      &DisplayMountList();
    }
  }

  local($mount)=$formdata{mount};
  if ($formdata{action} eq "delete")
  {
    &DeleteMount($mount);
    &DisplayMountList();
  }
  if ($formdata{action} eq "mount")
  {
    &MountMount($mount);
    &DisplayMountList();
  }
  if ($formdata{action} eq "unmount")
  {
    &UnmountMount($mount);
    &DisplayMountList();
  }
  if ($formdata{action} eq "configure")
  {
    &ConfigureMount($mount);
  }
  if ($formdata{action} eq "applyconfigure")
  {
    local($mountname)=$formdata{MOUNT};
    local($mounttype)=$formdata{MOUNTTYPE};
    local($hostname)=$formdata{HOSTTNAME};
    local($sharename)=$formdata{SHARENAME};
    local($username)=$formdata{USERNAME};
    local($password)=$formdata{PASSWORD};
    local($domain)=$formdata{DOMAIN};
    local($result)=&ApplyConfigureMount($mountname,$mounttype,$hostname,$sharename,$username,$password,$domain);
    if ($result == 0)
    {
      &DisplayMountList();
    }
  }

} elsif ($formdata{module} eq "services") {
  require "services.pl" ;
  if ($formdata{action} eq "list" || $formdata{action} eq "cancel" )
  {
    &DisplayServiceList();
  }
  if ($formdata{action} eq "start" || $formdata{action}  eq "stop" || $formdata{action} eq "restart" || $formdata{action} eq "configure" || $formdata{action} eq "logfile" )
  {
    if (defined($SERVICES{$formdata{service}}))
    {
      if ($formdata{action} eq "stop" )
      {
        &StopService($formdata{service});
        &DisplayServiceList();
      }
      if ($formdata{action} eq "start")
      {
        &StartService($formdata{service});
        &DisplayServiceList();
      }
      if ($formdata{action} eq "logfile")
      {
       &DisplayLogFile($formdata{service});
      }
      if ($formdata{action} eq "restart")
      {
       &RestartService($formdata{service});
       &DisplayServiceList();
      }
      if ($formdata{action} eq "configure")
      {
        if (defined($formdata{button}) && $formdata{button} eq "save")
        {
          &ApplyConfigureService($formdata{service});
        } elsif (defined($formdata{button}) && $formdata{button} eq "cancel") {
          &DisplayServiceList();
        } else {
          &ConfigureService($formdata{service},$formdata{button});
        }
      }
    } else {
      print "<FONT COLOR=RED>Error: service $formdata{service} not configured for $formdata{action} in UDA</FONT>\n";
    }
  }

} elsif ($formdata{module} eq "templates") {
  require "templates.pl" ;
  if ($formdata{action} eq "list")
  {
    &DisplayTemplateList();
  }

  if ($formdata{action} eq "sort")
  {
    if ($formdata{button} eq "save")
    {
      &ApplySortTemplateList();
    } elsif ($formdata{button} eq "cancel") { 
      &DisplayTemplateList();
    } else {
      &SortTemplateList();
    }
  }

  if ($formdata{action} eq "copy")
  {
    if ($formdata{button} eq "cancel")
    {
      &DisplayTemplateList();
    } elsif ($formdata{button} eq "save") {
      &ApplyCopyTemplate($formdata{template});
      # &DisplayTemplateList();
    } else {
      &CopyTemplate($formdata{template});
    }
  }
  if ($formdata{action} eq "delete")
  {
    &DeleteTemplate($formdata{template});
    &DisplayTemplateList();
  }
  if ($formdata{action} eq "configure")
  {
    &ConfigureTemplate($formdata{template});
  }
  if ($formdata{action} eq "advanced")
  {
    &ConfigureTemplateAdvanced($formdata{template});
  }
  if ($formdata{action} eq "save")
  {
    &ApplyEditTemplate($formdata{$template});
    &DisplayTemplateList();
  }
  if ($formdata{action} eq "subtemplate")
  {
    if ($formdata{button} eq "download") {
      &DownloadSubTemplates($formdata{template});
    } elsif ($formdata{button} eq "back") {
      &ConfigureTemplate($formdata{template});
    } elsif ($formdata{button} eq "save") {
      &SaveSubTemplates($formdata{template});
      &ConfigureTemplate($formdata{template});
    } elsif ($formdata{button} eq "cancel") {
      &ConfigureTemplate($formdata{template});
    } elsif ($formdata{button} eq "edit") {
      &ViewSubTemplates($formdata{template});
    } else {
      &ViewSubTemplates($formdata{template});
    }
  }
  if ($formdata{action} eq "deploy")
  {
    &DeployTemplate($formdata{template});
  }
  if ($formdata{action} eq "new")
  {
    if ($formdata{button} eq "cancel")
    {
      &DisplayTemplateList();
    } else{
     if ($formdata{button} eq "finish")
     {
       local($requirefile)=$OSDIR."/".$formdata{OS}.".pl";
       require $requirefile;
       &{$formdata{OS}."_CreateTemplate"}();
       # &DisplayTemplateList();
     } else {
      if (!defined($formdata{OS}))
      {
        &NewTemplate();
      } else {
        if ($formdata{step} eq "2" && $formdata{button} eq "previous")
        {
          &NewTemplate();
        } else {
          local($step)=1;
          local($requirefile)=$OSDIR."/".$formdata{OS}.".pl";
          # print "require=|$requirefile|\n";
          if ($formdata{step} >= 2 && $formdata{button} eq "previous")
          {
            $step = $formdata{step} - 1 ;
            if ( -f $requirefile )
            {
              require $requirefile;
              &{$formdata{OS}."_NewTemplate_".$step}();
            } else {
              &NewOS();
              print "OS specific implementation for $formdata{OS} not found\n";
            }
          } elsif ($formdata{step} >= 1 && $formdata{button} eq "next") {
            $step = $formdata{step} + 1 ;
            if ( -f $requirefile )
            {
              require $requirefile;
              &{$formdata{OS}."_NewTemplate_".$step}();
              
            } else {
              &NewTemplate();
              print "OS specific implementation for $formdata{OS} not found\n";
            }
          } else {
            &NewTemplate();
          }
        }
     }
    }
   }
  }
} elsif ($formdata{module} eq "system") {
  require "system.pl" ;
  if ($formdata{action} eq "localstorage")
  {
    if ($formdata{button} eq "cancel")
    {
      &SystemStatus();
    } elsif ($formdata{button} eq "extend") {
      &ExtendVolume();
    } elsif ($formdata{button} eq "add") {
      &AddLocalStorage();
    } else {
      &LocalStorage();
    }
  }
  if ($formdata{action} eq "winpe" ) {
      require "winpe.pl" ;
      &WinPE();
  }
  if ($formdata{action} eq "addwinpedrv" ) {
      require "winpe.pl" ;
      &AddWinPEDriver();
  }
  if ($formdata{action} eq "delwinpedrv" ) {
      require "winpe.pl" ;
      &DeleteWinPEDriver();
  }
  if ($formdata{action} eq "editwinpedrv" ) {
      require "winpe.pl" ;
      &EditWinPEDriver();
  }
  if ($formdata{action} eq "esx3nosan" ) {
      &Esx3NoSan();
  }
  if ($formdata{action} eq "applyesx3nosan" ) {
      &ApplyEsx3NoSan();
  }
  if ($formdata{action} eq "esx4nosan" ) {
      &Esx4NoSan();
  }
  if ($formdata{action} eq "applyesx4nosan" ) {
      &ApplyEsx4NoSan();
  }
  if ($formdata{action} eq "upload" ) {
      &Upload();
  }
  if ($formdata{action} eq "pxeconfig" ) {
     if ($formdata{button} eq "apply")
     {
       local($result)=&ApplyPXEConfig();
       if ($result == 0)
       {
         &SystemStatus();
       }
     } elsif ($formdata{button} eq "cancel") {
       &SystemStatus();
     } else {
       &PXEConfig();
     }
  }
  if ($formdata{action} eq "upgrade" ) {
    if ($formdata{button} eq "apply")
    {
      &ApplyUpgrade();
    } else {
      &Upgrade();
    }
  }
  if ($formdata{action} eq "installovftool")
  {
    &InstallOvfTool();
  }
  if ($formdata{action} eq "installpowershell")
  {
    &InstallPowerShell();
  }
  if ($formdata{action} eq "installvmwaretools")
  {
    &InstallVMWareTools();
  }
  if ($formdata{action} eq "applyinstallovftool")
  {
    &ApplyInstallOvfTool();
  }
  if ($formdata{action} eq "applyinstallpowershell")
  {
    &ApplyInstallPowerShell();
  }
  if ($formdata{action} eq "applyinstallvmwaretools")
  {
    &ApplyInstallVMWareTools();
  }
  if ($formdata{action} eq "version")
  {
    &Version();
  }
  if ($formdata{action} eq "help")
  {
    &Help();
  }
  if ($formdata{action} eq "network")
  {
    &Network();
  }
  if ($formdata{action} eq "applynetwork")
  {
    local($hostname)=$formdata{HOSTNAME};
    local($ip)=$formdata{IPADDRESS};
    local($netmask)=$formdata{NETMASK};
    local($gateway)=$formdata{GATEWAY};
    local($dns1)=$formdata{DNS1};
    local($dns2)=$formdata{DNS2};
    local($dnssearch)=$formdata{DNSSEARCH};
    &ApplyNetwork($hostname,$ip,$netmask,$gateway,$dns1,$dns2,$dnssearch);
  }
  if ($formdata{action} eq "storage")
  {
    &Storage();
  }
  if ($formdata{action} eq "password")
  {
    &Password();
  }
  if ($formdata{action} eq "applypassword")
  {
    local($oldpassword)=$formdata{OLDPASSWORD};
    local($newpassword1)=$formdata{NEWPASSWORD1};
    local($newpassword2)=$formdata{NEWPASSWORD2};
    local($resut)=&ApplyPassword($oldpassword,$newpassword1,$newpassword2);
  }
  if ($formdata{action} eq "shutdown")
  {
    &Shutdown();
  }
  if ($formdata{action} eq "applyshutdown")
  {
    &ApplyShutdown();
  }
  if ($formdata{action} eq "applyreboot")
  {
    &ApplyReboot();
  }
  if ($formdata{action} eq "systemvars")
  {
    if ($formdata{button} eq "edit")
    {
      &EditGlobalVariables();
    } elsif ($formdata{button} eq "apply") {
      &SaveGlobalVariables();
      &DisplaySystemVariables();
    } else {
      &DisplaySystemVariables();
    }
  }
  if ($formdata{action} eq "actions")
  {
    if ($formdata{button} eq "view")
    {
      &ViewAction($formdata{actionid});
    } elsif ($formdata{button} eq "delete") {
      &DeleteAction($formdata{actionid});
    } elsif ($formdata{button} eq "kill") {
      &KillAction($formdata{actionid});
    } elsif ($formdata{button} eq "cleanup") {
      &CleanupActions();
    } else {
      &DisplayActionList();
    }
  }
  if ($formdata{action} eq "status")
  {
    &SystemStatus();
  }

} else {
  &Home();
}

&PrintFooter();

