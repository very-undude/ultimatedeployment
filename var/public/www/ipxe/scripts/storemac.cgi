#!/usr/bin/perl

unshift(@INC,"/var/public/cgi-bin");
require "general.pl" ;
require "config.pl" ;
require "templates.pl" ;
my($SCRIPTNAME)="storemac.cgi";

sub Log()
{
  my($message)=shift;
  my($timestamp)=`date`;
  chomp($timestamp);
  my($result)=open(LOGFILE,">>/var/public/log/ipxe.log");
  print LOGFILE "$timestamp $SCRIPTNAME: $message\n";
  close(LOGFILE);
}

&Log("Starting procedure to store the template/subtemplate choice made by this mac");

print "Content-type: text/html\n\n";

my($timestamp)=`date +%s`;
my(%data)=&GetFormData();

&Log("The mac address $data{'mac'} made the choice for template $data{'template'} and subtemplate $data{'subtemplate'}");

my($macfilename)="/var/public/www/ipxe/mac/01-$data{'mac'}.dat";
my($result)=open(MACFILE,">$macfilename");
print MACFILE ("MAC=$data{'mac'}\n");
print MACFILE ("TEMPLATE=$data{'template'}\n");
print MACFILE ("SUBTEMPLATE=$data{'subtemplate'}\n");
print MACFILE ("TIMESTAMP=$timestamp\n");
close(MACFILE);

&Log("Wrote choice file $macfilename with timestamp $timestamp");

# this is how we test that the macfile was written more than 10 seconds ago
# sleep 12;

my($chainfile)="/ipxe/templates/$data{template}/$data{subtemplate}.ipxe";
&Log("Returning chain to the subtemplate: $chainfile");
print<<EOF;
#!ipxe
chain $chainfile
EOF
