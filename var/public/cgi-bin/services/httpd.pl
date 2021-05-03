#!/usr/bin/perl

sub httpd_ConfigureService
{
  local($service)="httpd";
  local($configfilename)="/etc/httpd/conf/httpd.conf";

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

sub httpd_ApplyConfigureService
{
  local($service)="httpd";
  local($configfilename)="/etc/httpd/conf/httpd.conf";

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

  local($command)="/usr/bin/systemctl reload $service.service";
  local($result)=&RunCommand($command,"Reloading $service configuration");
  if ($result)
  {
    &PrintError("Could not reload $service configuration");
    return 1;
  }
  &PrintSuccess("Applied new $service configuration","And reloaded configuration");

  return 0;
}

sub httpd_DisplayLogFile
{
  local (@result)=`tail -50 $LOGDIR/httpd_access.log`;
  print "<CENTER><H4>Access</H4></CENTER>\n";
  print "<PRE>@result</PRE>\n";
  local (@result)=`tail -50 $LOGDIR/httpd_error.log`;
  print "<CENTER><H4>Errors</H4></CENTER>\n";
  print "<PRE>\n";
  print @result ;
  print "</PRE>\n";
  return 0;
}



1;
