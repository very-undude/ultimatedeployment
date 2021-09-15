#!/usr/bin/perl

unshift(@INC,"/var/public/cgi-bin");
require "general.pl" ;
require "config.pl" ;
require "templates.pl" ;
my($SCRIPTNAME)="menu.cgi";

sub Log()
{
  my($message)=shift;
  my($timestamp)=`date`;
  chomp($timestamp);
  my($result)=open(LOGFILE,">>/var/public/log/ipxe.log");
  print LOGFILE "$timestamp $SCRIPTNAME: $message\n";
  close(LOGFILE);
}

&Log("Starting ipxe menu");

print "Content-type: text/html\n\n";
my(%data)=&GetFormData();
my($mac)=$data{'mac'};
&Log("Recorded mac address $mac");

my(@efitemplates)=();
my(@efimactemplates)=();
local(%templateconfig)=&GetTemplateHTMLConfig();
local(%templatesortorder)=&GetTemplateSortOrder();
for $curtemplateconfig (sort(keys(%templatesortorder)))
{
  if (defined($templateconfig{$templatesortorder{$curtemplateconfig}}))
  {
    local($macfile)="$WWWDIR/ipxe/templates/$templatesortorder{$curtemplateconfig}/macs/01-$mac.ipxe";
    &Log("Checking for mac file $macfile");
    if (-f $macfile)
    {
       &Log("Found mac file $macfile, returning its contents");
       local($result)=open(MACFILE,"<$macfile");
       while(<MACFILE>)
       {
         print $_;
       }
       close(MACFILE);
       exit 0;
    }
    &Log("Macfile not found, continuing");
    if (-f "$WWWDIR/ipxe/templates/$templatesortorder{$curtemplateconfig}/template.ipxe")
    {
      push(@efitemplates,$templatesortorder{$curtemplateconfig});
      delete($templateconfig{$templatesortorder{$curtemplateconfig}});
    }
  }
}

for $mytemplateconfig (sort(keys(%templateconfig)))
{
  local($macfile)="$WWWDIR/ipxe/templates/$mytemplateconfig/macs/01-$mac.ipxe";
  &Log("Checking for mac file $macfile");
  if (-f $macfile)
  {
     &Log("Found mac file $macfile, returning its contents");
     local($result)=open(MACFILE,"<$macfile");
     while(<MACFILE>)
     {
       print $_;
     }
     close(MACFILE);
     exit 0;
  }
  &Log("Macfile not found, continuing");

  if (-f "$WWWDIR/ipxe/templates/$mytemplateconfig/template.ipxe")
  {
    push(@efitemplates,$mytemplateconfig);
    local(%info)=&GetTemplateInfo($template);
  }
}

print <<EOF;
#!ipxe

# Some menu defaults
set menu-timeout 5000
set submenu-timeout \${menu-timeout}
isset \${menu-default} || set menu-default exit

# Figure out if client is 64-bit capable
cpuid --ext 29 && set arch x64 || set arch x86
cpuid --ext 29 && set archl amd64 || set archl i386

:start
menu UDA boot menu
EOF

for $efitemplate (@efitemplates)
{
  print "item $efitemplate $efitemplate\n";
}

print <<EOF;
item --gap --
item --key x exit         Exit iPXE and continue BIOS boot
choose --timeout \${menu-timeout} --default \${menu-default} selected || goto cancel
set menu-timeout 0
goto \${selected}

:cancel
echo You cancelled the menu, dropping you to a shell

:shell
echo Type 'exit' to get the back to the menu
shell
set menu-timeout 0
set submenu-timeout 0
goto start

:failed
echo Booting failed, dropping to shell
goto shell

:reboot
reboot

:exit
exit

:config
config
goto start

:back
set submenu-timeout 0
clear submenu-default
goto start

EOF

for $efitemplate (@efitemplates)
{
  print ":$efitemplate\n";
  print "chain /ipxe/templates/$efitemplate/template.ipxe\n";
  print "goto start\n\n";
}

&Log("End of menu");

exit 0;
