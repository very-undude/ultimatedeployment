#!/usr/bin/perl

unshift(@INC,"/var/public/cgi-bin");
require "general.pl" ;
require "config.pl" ;
require "templates.pl" ;
my($SCRIPTNAME)="get_config.cgi";

print "Content-type: text/html\n\n";

sub Log()
{
  my($message)=shift;
  my($timestamp)=`date`;
  chomp($timestamp);
  my($result)=open(LOGFILE,">>/var/public/log/ipxe.log");
  print LOGFILE "$timestamp $SCRIPTNAME: $message\n";
  close(LOGFILE);
}

&Log("Starting ESX7 boot.cfg generation");

my($timestamp)=`date +%s`;
chomp($timestamp);
my(%data)=&GetFormData();
my($mac)=$data{mac};

&Log("Found MAC Address $mac");


my($macfilename)="/var/public/www/ipxe/mac/$data{'mac'}.dat";
&Log("Checking for mac address file:$macfilename");
if(-f $macfilename)
{
  &Log("Found file for mac address: $macfilename");
  my(%config)=();
  my($result)=open(MACFILE,"$macfilename");
  while(<MACFILE>)
  {
    my($line)=$_;
    if ($line =~ /^\s*([A-Za-z0-9_]+)\s*=\s*(.*)$/)
    {
      $config{$1}=$2;
    }
  }
  close(MACFILE);

  &Log("The file suggests the template $config{'TEMPLATE'} and the subtemplate $config{'SUBTEMPLATE'}");
  my($subtemplatefile)="/var/public/www/ipxe/templates/$config{'TEMPLATE'}/$config{'SUBTEMPLATE'}.cfg";

  my($mactimestamp)=$config{'TIMESTAMP'};
  &Log("The comparing current timestamp $timestamp with the timestamp in the macfile $mactimestamp");
  if ($timestamp lt ($mactimestamp) + 10)
  {
    &Log("OK we are within 10 seconds");
    if (-f $subtemplatefile)
    {
      &Log("Found the subtemplate file $subtemplatefile for template writing it out to client");
      my($result)=open(CFGFILE,"<$subtemplatefile");
      while(<CFGFILE>)
      {
        print $_;
      }
      close(CFGFILE);
    } else {
      &Log("Could not find the configfile for this subtemplate: $subtemplate");
      print "echo Could not find the config file for template $config{'TEMPLATE'} with subtemplate $config{'SUBTEMPLATE'}";
    }
  } else {
    &Log("We have exceeded the 10 seconds");
    print "echo we have exceeded 10 seconds, not booting\n";
  }
} else {
    &Log("Not found file for mac address: $macfilename");
    print "echo We could not find the mac address file for mac $mac\n";
}

&Log("Done");
