#!/usr/bin/perl

sub nfs_ConfigureService
{
  local($service)="nfs";
  local($configfilename)=$NFSEXPORTS;

  local(@conffile)=&GetConfigFile($configfilename);
  local($mode)="";
  if (&GetServiceMode($service) eq "Automatic")
  {
    $mode="CHECKED";
  }

  print "<CENTER>\n";
  print "<H2>Service properties for $service</H2>\n";
  &PrintToolbar("Save","Cancel");
  print "<script language='javascript' src='/js/configureservice.js'></script>\n";
  print "<FORM NAME=SERVICEFORM ACTION='uda3.pl' METHOD=POST>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=services>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=configure>\n";
  print "<INPUT TYPE=HIDDEN NAME=service VALUE=$service>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
  print " <TABLE>\n";
  print " <TR><TD VALIGN=TOP>Start on boot</TD><TD><INPUT TYPE=CHECKBOX NAME=STARTONBOOT $mode></TD></TR>\n";
  print " <TR><TD VALIGN=TOP>Configuration</TD><TD><TEXTAREA WRAP=OFF NAME=CONF COLS=80 ROWS=20>";
  print @conffile;
  print "</TEXTAREA></TD></TR>\n";
  print "</TABLE>\n";
  print "</FORM>\n";
  print "</CENTER>\n";
}

sub nfs_ApplyConfigureService
{
  local($service)="nfs";
  local($configfilename)=$NFSEXPORTS;

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

  local($result)=&PutConfigFile($configfilename,$formdata{CONF});
  if ($result)
  {
     &PrintError("Could not write $service configuration file",$configfilename);
     return 1;
  }


   local($pid)=&GetServicePID($service);
   if ($pid =~ /^[0-9]+$/)
   {
 
     local($command)="/usr/bin/systemctl stop $service.service";
     local($result)=&RunCommand($command,"Stopping $service");
     if ($result)
     {
       &PrintError("Could not stop $service");
       return 1;
     }

     local($command)="/usr/bin/systemctl start $service.service";
     local($result)=&RunCommand($command,"Starting $service");
     if ($result)
     {
       &PrintError("Could not start $service");
       return 1;
     }
    &PrintSuccess("Applied new $service configuration","And Restarted the $service daemon");
   } else {
    &PrintSuccess("Applied new $service configuration");
   }

  return 0;
}

sub nfs_DisplayLogFile
{
  print "<CENTER>Not implemented</CENTER>\n";
  return 0;
}



1;
