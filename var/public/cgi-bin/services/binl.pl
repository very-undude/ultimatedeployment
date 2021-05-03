#!/usr/bin/perl


sub binl_RebuildInfDb
{
  local($flavor)=shift;

  local($command)="$BINDIR/infparser2.py $flavor";

  local($result)=&RunCommand($command,"Rebuilding inf database");
  if ($result)
  {
    return $result;
  }

  return 0;
}


sub binl_GetWindows5FlavorHTML
{
  local(%htmlinfo)=();
  local(@flavorlist)=&GetOSFlavorList();
  for $myflavor (@flavorlist)
  {
   local($os,$flavor)=split(";",$myflavor);
   local(%info)=&GetOSInfo($flavor);
    # print "<LI>Checking Flavor $flavor\n";
    if ($os eq "windows5")
    {
       local($drivercount)=&binl_GetDriverCount($info{FLAVOR});
       $htmlinfo{$info{FLAVOR}}="<TD>$info{FLAVOR}</TD><TD>$info{SUBOS}</TD><TD>$drivercount</TD>";
    }
  }
  return(%htmlinfo);
}

sub binl_GetDriverCount
{
  local($flavor)=shift;
  local($count)="Unknown";
  local($countfilename)="$TFTPDIR/windows5/$flavor\_extra/devlist.count";
  local($result)=open(FF,"<$countfilename");
  while(<FF>)
  {
    local($line)=$_;
    if ($line =~ /^DEVCOUNT=([0-9]+)/)
    {
      $count=$1;
    }
  }
  close(FF);
  return($count);
}

sub binl_ConfigureService
{
  local($service)="binl";
  local(%flavorhtml)=&binl_GetWindows5FlavorHTML();
  local($mode)="";
  if (&GetServiceMode($service) eq "Automatic")
  {
    $mode="CHECKED";
  }
  print "<CENTER>\n";
  print "<H2>Service properties for $service</H2>\n";
  &PrintToolbar("Save","Cancel","Database","Add Driver");
  print "<script language='javascript' src='/js/configurebinl.js'></script>\n";
  print "<script language='javascript' src='/js/table.js'></script>\n";
  print "<FORM NAME=SERVICEFORM ACTION='uda3.pl' METHOD=POST>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=services>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=configure>\n";
  print "<INPUT TYPE=HIDDEN NAME=service VALUE=$service>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
  print "<INPUT TYPE=HIDDEN NAME=flavor VALUE=none>\n";
  print "<BR>\n";
  print " <TABLE>\n";
  print " <TR><TD VALIGN=TOP>Start on boot</TD><TD><INPUT TYPE=CHECKBOX NAME=STARTONBOOT $mode></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";
  print "<TABLE BORDER=1>\n";
  print "<TR CLASS=tableheader><TD>Flavor</TD><TD>OS Type</TD><TD># Drivers</TD></TR>\n";
  for $item (keys(%flavorhtml))
  {
    print "<TR ONCLICK='SelectRow(this)' ID=$item>$flavorhtml{$item}</TR>\n";
  }
  print "</TABLE>\n";
  print "</FORM>\n";
  print "</CENTER>\n";
}

sub binl_ConfigureService_database
{
 local($flavor)=$formdata{flavor};
 print "<CENTER>\n";
 print "<H2>Binl Database for $flavor</H2>\n";
 local(@result)=`/var/public/bin/dumpcache2.py /var/public/tftproot/windows5/$flavor\_extra/devlist.cache`;
 print @result;
 print "</CENTER>\n";
 return 0;
}

sub binl_ConfigureService_adddriver
{
  local($flavor)=$formdata{flavor};
  print "<CENTER>\n";
  print "<H2>Add driver to binl database for $flavor</H2>\n";
  &PrintToolbar("Apply","Cancel");
  print "<script language='javascript' src='/js/binladddriver.js'></script>\n";
  print "<FORM NAME=DRIVERFORM METHOD=POST ACTION='upload_driver.cgi' ENCTYPE='multipart/form-data'>\n";
  print "<INPUT TYPE=HIDDEN NAME=flavor VALUE=$flavor>\n";
  print "<BR><BR>\n";
  print "<TABLE>\n";
  print "<TR><TD>Inf File</TD><TD><INPUT TYPE=FILE NAME=upload_file1></TD></TR>\n";
  print "<TR><TD>Sys File</TD><TD><INPUT TYPE=FILE NAME=upload_file2></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";
  print "</FORM>\n";
  return 0;
}

sub binl_ConfigureService_applyadddriver
{
  local($flavor)=$formdata{flavor};
  local($mount)=$formdata{MOUNT};
  local($zipfile)=$formdata{FILE1};

  print "<LI>Adding drivers in zip file $zipfile\n";
  print "<LI>located zipfile on mount $mount\n";
  print "<LI>Adding drivers to flavor $flavor\n";

 local(@result)=`unzip -CL /var/public/smbmount/$mount/$zipfile "*.sys" -d /var/public/tftproot/windows5/$flavor\_sys`;
 if ($? ne 0)
 {
    &PrintError("Could not unzip .sys files from $zipfile ");
    print "<PRE>@result</PRE>'n";
 }

 local(@result)=`unzip -CL /var/public/smbmount/$mount/$zipfile "*.inf" -d /var/public/tftproot/windows5/$flavor\_inf`;
 if ($? ne 0)
 {
    &PrintError("Could not unzip .inf files from $zipfile ");
    print "<PRE>@result</PRE>'n";
 }
 
  local($result)=&StopService('binl');
  if ($result)
  {
    &PrintError("Could not stop binl service");
  }

  require "os/windows5.pl";
  local($result)=&windows5_RebuildInfDb($flavor);
  if ($result)
  {
    &PrintError("Could not rebuild binl database for flavor $flavor");
  }

  local($result)=&StartService('binl');
  if ($result)
  {
    &PrintError("Could not start binl service");
  }

  return 0;
}

sub binl_ApplyConfigureService
{
  local($service)="binl";
  # local($configfilename)="/etc/binl.conf";

  if (defined($formdata{STARTONBOOT}))
  {
   local($command)="/usr/bin/systemctl enable $service.service";
   local($result)=&RunCommand($command,"Turning on Automatic startup at boot for $service");
   if ($result)
   {
     &PrintError("Could not set automatic startup for $service");
     return 1;
   }
  } else {
   local($command)="/usr/bin/systemctl disable $service.service";
   local($result)=&RunCommand($command,"Turning off Automatic startup at boot for $service");
   if ($result)
   {
     &PrintError("Could not set manual startup for $service");
     return 1;
   }
  }

  #local($result)=&PutConfigFile($configfilename,$formdata{CONF});
  #if ($result)
  #{
  #   &PrintError("Could not write $service configuration file",$configfilename);
  #   return 1;
  #}

   #local($command)="/usr/bin/systemctl stop $service.service";
   #local($result)=&RunCommand($command,"Stopping $service");
   #if ($result)
   #{
   #  &PrintError("Could not stop $service");
   #  return 1;
   #}

   #local($command)="/usr/bin/systemctl start $service.service";
   #local($result)=&RunCommand($command,"Starting $service");
   #if ($result)
   #{
   #  &PrintError("Could not start $service");
   #  return 1;
   #}

  &PrintSuccess("Applied new $service configuration");
  return 0;
}

1;
