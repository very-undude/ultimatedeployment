#!/usr/bin/perl

sub UpdateActionProgress
{
 local($actionid)=shift;
 local($percentage)=shift;
 local($status)=shift; 
 local($actiondir)=$TEMPDIR."/action.".$actionid;
 local($progressfile)=$actiondir."/progress.dat";
 local($result)=open(PROGRESS,">$progressfile");
 print PROGRESS "$percentage/$status\n";
 close(PROGRESS);

 local($logfile)=$actiondir."/progress.log";
 local($result)=open (LOGFILE,">>$logfile");
 print LOGFILE "Progress: $percentage \% : $status\n";
 close (LOGFILE);

 return 0;
}

sub WriteActionArgs
{
  local($actionid)=shift;
  local($actiondir)=$TEMPDIR."/action.".$actionid;
  local($argumentsfile)=$actiondir."/arguments.dat";
  open(ARGS,">$argumentsfile");
  for $mykey (keys(%formdata))
  {
    print ARGS "$mykey=$formdata{$mykey}\n";
  }
  close ARGS;
  return 0;
}

sub WriteActionScript
{
  local($actionid)=shift;
  local($require)=shift;
  local($subcall)=shift;
  local($actiondir)=$TEMPDIR."/action.".$actionid;
  local($scriptfile)=$actiondir."/action.pl";
  local($result)=open(SCRIPT,">$scriptfile");
  print SCRIPT "\#!/usr/bin/perl\n";
  print SCRIPT "local(\$ACTIONID)=$actionid;\n";
  print SCRIPT "open(PIDFILE,\">$actiondir/action.pid\");\n";
  print SCRIPT "print PIDFILE \$\$ ;\n";
  print SCRIPT "close(PIDFILE);\n";
  print SCRIPT "unshift ( \@INC,\"/var/public/cgi-bin\");\n";
  print SCRIPT "require \"$require\" ;\n";
  print SCRIPT "$subcall\n";
  close(SCRIPT);

  `chmod 755 $scriptfile`;
  return 0;
}

sub WriteActionDescription
{
  local($actionid)=shift;
  local($description)=shift;
  local($actiondir)=$TEMPDIR."/action.".$actionid;
  local($descfile)=$actiondir."/action.desc";
  local($result)=open(DESC,">$descfile");
  print DESC "$description\n";
  close(DESC);
  return 0;
}

sub RunActionScript
{
  local($actionid)=shift;
  local($actiondir)=$TEMPDIR."/action.".$actionid ;
  local($scriptfile)=$actiondir."/action.pl";

 `echo \"$scriptfile \> $actiondir/action.out 2\>\&1\" | at now \>$actiondir/at.out 2\>\&1`;
  return 0;
}

sub RunAction
{
  local($actionid)=shift;
  local($description)=shift;
  local($require)=shift;
  local($subcall)=shift;

  local($actiondir)=$TEMPDIR."/action.".$actionid ;
  if ( -d $actiondir )
  {
    print "ERROR: Action Already exists";
  } else {

    mkdir($actiondir);
    &UpdateActionProgress($actionid,"0","Created Action Directory");

    &WriteActionDescription($actionid,$description);
    &UpdateActionProgress($actionid,"1","Wrote Action Description");

    &WriteActionArgs($actionid);
    &UpdateActionProgress($actionid,"2","Wrote Action Arguments");
    
    &WriteActionScript($actionid,$require,$subcall);
    &UpdateActionProgress($actionid,"3","Wrote Action Script");

    &RunActionScript($actionid);
    &UpdateActionProgress($actionid,"4","Started Action Script");
  }
}

sub ReadActionArgs
{
  local($actionid)=shift;
  # print "NOW Entering readActionArgs\n";
  local($actiondir)=$TEMPDIR."/action.".$actionid;
  local($argumentsfile)=$actiondir."/arguments.dat";
  local(%arguments);
  local($result)=open(ARGS,"<$argumentsfile");
  while(<ARGS>)
  {
    local($line)=$_;
    $line =~ s/\s*#.*//g;
    if($line =~ /\s*([^\=\s]+)\s*\=\s*(.*)/)
    {
      local($varname)=$1;
      local($value)=$2;
      print "arg name =|$varname| value = |$value|\n";
      $arguments{$varname}=$value;
    } else {
      print "Not matching line = |$line|\n";
    }
  }
  close(ARGS);
  return %arguments;
}

1;
