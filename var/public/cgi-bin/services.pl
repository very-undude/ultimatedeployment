#!/usr/bin/perl

sub ConfigureService
{
  local($service)=shift;
  local($button)=shift;
  local($requirefile)="services/$service.pl";
  require $requirefile;
  if ($button ne "")
  {
    &{$service."_ConfigureService_".$button}();
  } else {
    &{$service."_ConfigureService"}();
  }
}

sub ApplyConfigureService
{
  local($service)=@_;
  local($requirefile)="services/$service.pl";
  require $requirefile;
  &{$service."_ApplyConfigureService"}();
}

sub GetServiceMode
{
  local($service)=@_;
  local($result)=`/usr/sbin/chkconfig --list $service`;
  if ($result =~ /3\:on/)
  {
    return "Automatic";
  } else {
    $result=`/usr/bin/systemctl show $service | grep -i UnitFileState | awk '{print \$2}' FS=\=` ;
    chomp($result);
    if($result eq "enabled")
    {
      return "Automatic";
    } else {
      return "Manual";
    }
  }
}

sub GetServicePID
{
  local($service)=@_;
  local($result)=`ps -ef | grep $service | grep  -v grep | grep "^root"`;
  if ($result =~ /^root\s+([0-9]+)\s+/)
  {
    return $1;
  } else {
    local($result)=`/usr/bin/systemctl show $service | grep "^MainPID" | awk '{print \$2}' FS=\=`;
    if ($result eq "0")
    {
      return "Not Running";
    } else {
      return $result;
    }

  }
}

sub StopService
{
  local($service)=@_;
  local(@result)=`sudo /sbin/service $service stop`;
  if ($? != 0)
  {
    print "<FONT COLOR=RED>Error: Could not stop service $service ($?)</FONT><BR>\n";
  }
}

sub StartService
{
  local($service)=@_;
  local(@result)=`sudo /sbin/service $service start`;
  if ($? != 0)
  {
    print "<FONT COLOR=RED>Error: Could not start service $service ($?)</FONT><BR>\n";
  }
}

sub RestartService
{
  local($service)=@_;

  local(@result)=`sudo /sbin/service $service stop`;
  #if ($? != 0)
  #{
  #  print "<FONT COLOR=RED>Error: Could not stop service $service ($?)</FONT><BR>\n";
  #}

  local(@result)=`sudo /sbin/service $service start`;
  if ($? != 0)
  {
    print "<FONT COLOR=RED>Error: Could not start service $service ($?)</FONT><BR>\n";
  }

}


sub DisplayServiceList
{
  print "<CENTER>\n";
  print "<H2>Services</H2>\n";
  &PrintToolbar("Stop","Start","Restart","Configure","Logfile");
  print "<BR><BR>\n";
  print "<script language='javascript' src='/js/table.js'></script>\n";
  print "<script language='javascript' src='/js/services.js'></script>\n";
  print " <TABLE BORDER=1>\n";
  print "<TR CLASS=tableheader><TD>Service</TD><TD>PID</TD><TD>Mode</TD><TD>Description</TD></TR>\n";
  for $service (keys(%SERVICES))
  {
    local($pid)=&GetServicePID($service);
    if ($pid == 0)
    {
      $pid="Not Running";
    }
    local($mode)=&GetServiceMode($service);
    print "<TR onclick='SelectRow(this)' ID=$service><TD>$service</TD><TD>$pid</TD><TD>$mode</TD><TD>$SERVICES{$service}</TD></TR>\n";
  }
  print "</TABLE>\n";
  print "</CENTER>\n";
}


sub DisplayLogFile
{
  local($service)=shift;
  print "<CENTER>\n";
  print "<H2>Log of service $service</H2>\n";
  print "</CENTER>\n";

  local($requirefile)="services/$service.pl";
  require $requirefile;
  if(defined(&{$service."_DisplayLogFile"}))
  {
     &{$service."_DisplayLogFile"};
  } else {
    local($logfile)="$LOGDIR/$service.log";
    if(defined(&{$service."_GetLogfileName"}))
    {
      $logfile=&{$service."_GetLogfileName"}();
    }
    local(@result)=`tail -50 $logfile`;
    print "<PRE>\n";
    print @result;
    print "</PRE>\n";
  }

  return 0;
}


1;
