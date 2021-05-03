#!/usr/bin/perl 

sub AddLocalStorage
{
 local($device)=$formdata{device};
 local($volume)=$formdata{volume};

 require "action.pl";
 print "<CENTER>\n";
 print "<H2>Adding Local Storage</H2>\n";
 print "</CENTER>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 local($actionid)=$$;
  print "<INPUT TYPE=HIDDEN NAME=actionid ID=actionid VALUE=\"$actionid\">\n";
  print "<CENTER>\n";
  print "<TABLE>\n";
  print "<TR><TD>Volume</TD><TD>$volume</TD></TR>\n";
  print "<TR><TD>Device</TD><TD>$device</TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";

  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Add local $device to $volume","system.pl","\&AddLocalStorage_DoIt($actionid);");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";
}


sub AddLocalStorage_DoIt
{
  local($actionid)=shift;
  require "general.pl";
  require "config.pl";
  require "action.pl";

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) {
    &UpdateActionProgress($actionid,-1,"Could not read arguments");
    return 1;
  }

  #for $key (keys(%args))
  #{
  #  print "<LI>KEY $key -> $args{$key}\n";
  #}

  local($device)=$args{device};
  local($volume)=$args{volume};

  local(@pvstatus)=&GetPVStatusInfo($device);
  if ($pvstatus[1] ne "Unallocated" || $device =~ /\/dev\/sda/)
  {
     &UpdateActionProgress($actionid,-2,"Device is already assigned to a volume group, not adding");
     return 2;
  } else {
    &UpdateActionProgress($actionid,10,"Checked previous device allocation");

    local($command)="/usr/sbin/pvcreate $device";
    local($result)=&RunCommand($command,"Creating Physical device for $device");
    if ($result)
    {
      &UpdateActionProgress($actionid,-2,"Could not label the drive as lvm");
      return 1;
    }
    &UpdateActionProgress($actionid,20,"Checked previous device allocation");

    local($command)="/usr/sbin/vgextend udavg $device";
    local($result)=&RunCommand($command,"Extending udavg with $device");
    if ($result)
    {
      &UpdateActionProgress($actionid,-2,"Could not extend volume group udavg");
      return 1;
    }
    &UpdateActionProgress($actionid,30,"Extended volume group udavg");

    local($command)="/usr/sbin/lvextend -v /dev/udavg/$volume $device";
    local($result)=&RunCommand($command,"extending logical volume $volume");
    if ($result)
    {
      &UpdateActionProgress($actionid,-2,"Could not extend logical volume $volume");
      return 1;
    }
    &UpdateActionProgress($actionid,40,"Extended logical volume $volume");

    local($command)="/usr/sbin/xfs_growfs /dev/udavg/$volume";
    local($result)=&RunCommand($command,"Resizing filesystem");
    if ($result)
    {
      &UpdateActionProgress($actionid,100,"Could not resize the filesystem on volume $volume");
      return 1;
    }
  }
  &UpdateActionProgress($actionid,100,"Successfull");
  return 0;
}


sub GetLogicalVolumeStatus
{
  local(@result)=`df -h -P | grep udavg`;
  local(%status)=();
  for $line (@result)
  {
      local(@info)=split(/\s+/,$line);
      $info[0] =~ /\/dev\/mapper\/udavg-(.*)/ ;
      $status{$1}="$info[1];$info[2];$info[3];$info[4]";
  }
  return %status;
}

sub GetPVStatusInfo
{
  local($pv)=shift;
  local(@info)=`sudo pvs --segments $pv`;
  if ($? != 0)
  {
    local($partedsize)=`sudo /sbin/fdisk -l $pv print | grep ^Disk | awk '{print \$2}' FS=\: | awk '{print \$1}' FS=\,`;
    return ($pv,"Unallocated",$partedsize);
  }
  local(@myarray)=split(/\s+/,$info[1]);
  local($status)=$myarray[2];
  local($size)=$myarray[5];
  return ($pv,$status,$size);
}

sub LocalStorage
{
  print "<CENTER>\n";
  print "<H2>Local Storage</H2>\n";
  &PrintToolbar("Extend","Cancel");
  print "<script language='javascript' src='/js/table.js'></script>\n";
  print "<script language='javascript' src='/js/localstorage.js'></script>\n";
  print "<BR><BR>\n";
  print "<FORM NAME=LOCALSTORAGE ACTION='uda3.pl' METHOD=GET>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=system>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=localstorage>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
  print "<INPUT TYPE=HIDDEN NAME=volume VALUE=none>\n";
  print "</FORM>\n";

 local(%status)=&GetLogicalVolumeStatus();
  print "<TABLE BORDER=1>\n";
  print "<TR CLASS=tableheader><TD>Volume</TD><TD>Total</TD><TD>Used</TD><TD>Free</TD><TD>Usage</TD></TR>\n";
  for $volume (keys(%status))
  {
    local(@info)=split(";",$status{$volume});
    print "<TR onclick='SelectRow(this)' ID='$volume'><TD>$volume</TD><TD>$info[0]</TD><TD>$info[1]</TD><TD>$info[2]</TD><TD>$info[3]</TD></TR>\n";
  }
  print "</TABLE>\n";
  print "<TABLE BORDER=1>\n";

  return 0;
}

sub ExtendVolume
{
  local($volume)=$formdata{volume};
  print "<FORM NAME=LOCALSTORAGE ACTION='uda3.pl' METHOD=GET>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=system>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=localstorage>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
  print "<INPUT TYPE=HIDDEN NAME=volume VALUE='$volume'>\n";
  print "<INPUT TYPE=HIDDEN NAME=device VALUE=none>\n";
  print "</FORM>\n";

  print "<script language='javascript' src='/js/table.js'></script>\n";
  print "<script language='javascript' src='/js/extendvolume.js'></script>\n";
  print "<CENTER>\n";
  print "<H2>Extending volume $volume</H2>\n";
  &PrintToolbar("Apply","Cancel");
  print "<BR>\n";
  local(@result)=`echo "echo \'- - -\' \> /sys/class/scsi_host/host0/scan" | sudo su -`;
  #print "<PRE>@result</PRE>";

  local($command)="ls -1 /dev/sd* | grep -v \/dev\/sda";
  # local($command)="ls -1 /dev/sd*";
  local(@devices)=`sudo $command`;

  if ($#devices<0)
  {
    print "No devices found to extend the volume with";
  } else {
  print "<TABLE BORDER=1>\n";
 print "<TR CLASS=tableheader><TD>Device</TD><TD>Status</TD><TD>Size</TD></TR>\n";
  for $device (@devices)
  {
    chomp($device);
    local(@info)=GetPVStatusInfo($device);
    if ($info[1] eq "Unallocated")
    {
    print "<TR onclick='SelectRow(this)' ID='$device'><TD>$device</TD><TD>$info[1]</TD><TD>$info[2]</TD></TR>\n";
    }
  }
  print "</TABLE>\n";
  }
  print "</CENTER>\n";

}



sub Network
{
  local(%config)=&GetSystemVariables();

  print "<CENTER>\n";
  print "<H2>Network Settings</H2>\n";
  &PrintToolbar("Apply","Cancel");
  print "<script language='javascript' src='/js/network.js'></script>\n";
  print "<BR>\n";
  print "<FORM NAME=NETWORKFORM METHOD=POST ACTION='uda3.pl'>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE='system'>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE='applynetwork'>\n";
  print "<TABLE>\n";
  print "<TR><TD>Hostname</TD><TD><INPUT TYPE=TEXT NAME=HOSTNAME VALUE='$config{UDA_HOSTNAME}'></TD></TR>\n";
  print "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>\n";
  print "<TR><TD>IP Address</TD><TD><INPUT TYPE=TEXT NAME=IPADDRESS  VALUE='$config{UDA_IPADDR}'></TD></TR>\n";
  print "<TR><TD>Netmask</TD><TD><INPUT TYPE=TEXT NAME=NETMASK VALUE='$config{UDA_NETMASK}'></TD></TR>\n";
  print "<TR><TD>Gateway</TD><TD><INPUT TYPE=TEXT NAME=GATEWAY  VALUE='$config{UDA_GATEWAY}'></TD></TR>\n";
  print "<TR><TD>&nbsp;</TD><TD>&nbsp;</TD></TR>\n";
  local($counter)=1;
  while (defined($config{'UDA_DNS_'.$counter}))
  {
      print "<TR><TD>DNS Server $counter</TD><TD><INPUT TYPE=TEXT NAME=UDA_DNS_$counter VALUE='".$config{'UDA_DNS_'.$counter}."'></TD></TR>\n";
    $counter++;
  }
  #for $item (keys(%config))
  #{
  #  if ($item =~ /UDA_DNS_([0-9]+)/)
  #  {
  #    print "<TR><TD>DNS Server $counter</TD><TD><INPUT TYPE=TEXT NAME=UDA_DNS_$counter VALUE='$config{$item}'></TD></TR>\n";
  #    $counter++;
  #  }
  #}
  print "<TR><TD>DNS Server $counter</TD><TD><INPUT TYPE=TEXT NAME=UDA_DNS_$counter></TD></TR>\n";
  print "<TR><TD>DNS search order</TD><TD><INPUT TYPE=TEXT NAME=DNSSEARCH VALUE='$config{UDA_DNS_SEARCH_PATH}'></TD></TR>\n";
  print "</TABLE>\n";
  print "</FORM>\n";
  print "</CENTER>\n";
  return 0;
}

sub ApplyNetwork
{
  print "<CENTER>\n";
  print "<H3>Applying network configuration</H3>\n";

  local($hostname)=$formdata{HOSTNAME};
  local($gateway)=$formdata{GATEWAY};
  local($netmask)=$formdata{NETMASK};
  local($ipaddr)=$formdata{IPADDRESS};
  local($dnssearch)=$formdata{DNSSEARCH};
  local($tempeth0file)=$TEMPDIR."/ifcfg-eth0.$$";

  local(%config)=&GetSystemVariables();
  if  ($ipaddr ne $config{UDA_IPADDR})
  {
    print "You have changed the IP-address of the UDA<BR>\n";
    print "The browser will stop responding after in few moments\n";
    print "Please follow the link below to the<BR><BR>\n";
    print "<A HREF='http://$ipaddr/cgi-bin/uda3.pl'>New location of UDA</A><BR>\n";
   print "</CENTER>\n";
  }

  local($result)=open(ETH0FILE,">$tempeth0file");
  print ETH0FILE "DEVICE=eth0\n";
  print ETH0FILE "BOOTPROTO=static\n";
  print ETH0FILE "ONBOOT=yes\n";
  print ETH0FILE "IPADDR=$ipaddr\n";
  if ($netmask ne "")
  {
    print ETH0FILE "NETMASK=$netmask\n";
  }
  close (ETH0FILE);
 
  local($tempnetworkfile)=$TEMPDIR."/network.$$";
  local($result)=open(NETWORK,">$tempnetworkfile");
  print NETWORK "NETWORKING=yes\n";
  print NETWORK "NETWORKING_IPV6=no\n";
  #if($hostname ne "")
  #{
  #  print NETWORK "HOSTNAME=$hostname\n";
  #}
  if ($gateway ne "")
  {
    print NETWORK "GATEWAY=$gateway\n";
  }
  close (NETWORK);
  
  # print "<LI>DNS Settings in /etc/resolv.conf\n";
  local($tempresolvfile)=$TEMPDIR."/resolv.conf.$$";
  local($result)=open(RESOLV,">$tempresolvfile");
  if ($dnssearch ne "")
  {
    print RESOLV "search $dnssearch\n";
  }
  for $item (keys(%formdata))
  {
    if ($item =~ /^UDA_DNS_[0-9]+/)
    {
      if ($formdata{$item} ne "")
      {
        print RESOLV "nameserver $formdata{$item}\n";
      }
    }
  }
  close(RESOLV);

  local($savedhcpfile)=$TEMPDIR."/dhcpd.conf.ok.$$";
  local($dhcpdconf)=$TEMPDIR."/dhcpd.conf.new.$$";
  local($original)="/etc/dhcp/dhcpd.conf";
  local($command)="cp $original $dhcpdconf";
  local($result)=&RunCommand($command,"Making $original copy to edit in $dhcpdconf");
  local($command)="cp $original $savedhcpfile";
  local($result)=&RunCommand($command,"Making $original safecopy in $savedhcpfile");

  # print "<LI>New UDA IP in /etc/dhcp/dhcpd.conf\n";

  local($command)="sed -i -e 's/next-server\\s*$config{UDA_IPADDR}/next-server $ipaddr/gi' $dhcpdconf";
  local($result)=&RunCommand($command,"Adjusting next-server entry in $dhcpdconf");
  
  local($command)="sed -i -e 's/domain-name-servers\\s+$config{UDA_IPADDR}/domain-name-servers $ipaddr/gi' $dhcpdconf";
  local($result)=&RunCommand($command,"Adjusting domain-name-servers  entry in $dhcpdconf");
 
  local($command)="sed -i -e 's/routers\\s+$config{UDA_IPADDR}/routers $ipaddr/gi' $dhcpdconf";
  local($result)=&RunCommand($command,"Adjusting routers entry in $dhcpdconf");

  #### Commit changes

  # TODO Republish all templates

  #print "<LI>setting hostname\n";
  if($hostname ne "")
  {
    local($command)="/usr/bin/hostnamectl set-hostname $hostname";
    local($result)=&RunCommand($command,"Setting hostname");
    if ($result)
    {
      &PrintError("Could not write network file");
      return 1;
    }
  }

  # Copy resolv.conf
  local($command)="cp $tempresolvfile /etc/resolv.conf";
  local($result)=&RunCommand($command,"Writing resolv.conf");
  if ($result)
  {
    &PrintError("Could not write resolv.conf file");
    return 1;
  }
  # Copy network
  local($command)="cp $tempnetworkfile /etc/sysconfig/network";
  local($result)=&RunCommand($command,"Writing network file");
  if ($result)
  {
    &PrintError("Could not write network file");
    return 1;
  }
  # Copy ifcfg-eth0
  local($command)="cp $tempeth0file /etc/sysconfig/network-scripts/ifcfg-eth0";
  local($result)=&RunCommand($command,"Writing eth0 file");
  if ($result)
  {
    &PrintError("Could not write eth0 interface  file");
    return 1;
  }
  # Copy dhcpd.conf
  local($command)="cp $dhcpdconf /etc/dhcp/dhcpd.conf";
  local($result)=&RunCommand($command,"Writing dhcpd file");
  if ($result)
  {
    &PrintError("Could not write dhcpd file");
    return 1;
  }

  require "templates.pl";
  local($result)=&PublishAllTemplates();
  if ($result)
  {
    &PrintError("Could not publish all templates");
    return 1;
  }
  # Restart network
  local($command)="/sbin/service network restart";
  local($result)=&RunCommand($command,"Restarting network");
  if ($result)
  {
    &PrintError("Could not restart network");
    return 1;
  }
  # Restart dhcp
  local($command)="/sbin/service dhcpd restart";
  local($result)=&RunCommand($command,"Restarting dhcpd");
  if ($result)
  {
    &PrintError("Could not restart dhcpd");
    return 1;
  }
  
  &PrintSuccess("Succesfully changed network configuration");
}

sub Storage
{
  print "<H2>Local Storage</H2>\n";

  return 0;
}

sub Password
{
  print "<CENTER>\n";
  print "<H2>Change Password</H2>\n";
  &PrintToolbar("Apply","Cancel");
  print "<script language='javascript' src='/js/password.js'></script>\n";
  print "<BR>\n";
  print "<FORM NAME=PASSWORDFORM METHOD=POST ACTION='uda3.pl'>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE='system'>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE='applypassword'>\n";
  print "<TABLE>\n";
  print "<TR><TD>Old Password</TD><TD><INPUT TYPE=PASSWORD NAME=OLDPASSWORD></TD></TR>\n";
  print "<TR><TD>New Password</TD><TD><INPUT TYPE=PASSWORD NAME=NEWPASSWORD1></TD></TR>\n";
  print "<TR><TD>Confirm new password</TD><TD><INPUT TYPE=PASSWORD NAME=NEWPASSWORD2></TD></TR>\n";
  print "</TABLE>\n";
  print "</FORM>\n";
  print "</CENTER>\n";
  return 0;
}

sub ApplyPassword
{
  local($old,$new1,$new2)=@_;
  
  if ($new1 ne $new2)
  {
    &PrintError("New passwords do not match");
    return 1;
  } 

  local($hash)=`sudo cat /etc/shadow | grep "^root:" | awk '{print \$2}' FS=\:`;
  chomp($hash);
  local(@pwdarray)=split(/\$/,$hash);
  local($salt)=$pwdarray[2];
  
  local($md5option)="-1";
  if ($salt eq "")
  {
    $md5option="";
    $salt=$hash;
    $salt=~ s/^(..).*/\1/g;
  } 
  #local($checkhash)=`echo $old | openssl passwd $md5option -stdin -salt "$salt"`;
  local($checkhash)=crypt("$old","\$6\$$salt\$");

  chomp($checkhash);
  if ($checkhash ne $hash)
  {
    &PrintError("Current password failed!");
    return 1;
  }

  local($command)="/usr/bin/htpasswd -c -b /var/public/conf/passwd admin $new1";
  local($result)=&RunCommand($command,"Setting new admin webuser password");
  if ($result) 
  { 
    &PrintError("Could not set the password for the web admin user",
    "I will try to change the root user's password");
    return 1;
  }

  local($command)="echo $new1 | passwd root --stdin";
  local($result)=&RunCommand($command,"Setting new OS root user password");
  if ($result) 
  { 
    &PrintError("Could not set the password for the root user",
    "Caution: I have aready changed the password for the webuser!");
    return $result 
  }

  &PrintSuccess("The passwords for the web admin user and the root user",
                "have been updated succesfully!");
   return 0;
}

sub Shutdown
{
  print "<CENTER>\n";
  print "<H2>Shutdown</H2>\n";
  print "</CENTER>\n";
  &PrintToolbar("Shutdown","Reboot","Cancel");
  print "<script language='javascript' src='/js/shutdown.js'></script>\n";
  print "<FORM NAME=SHUTDOWNFORM METHOD=POST ACTION='uda3.pl'>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE='system'>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE='status'>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE='unknown'>\n";
  print "</FORM>\n";
  return 0;
}

sub SaveGlobalVariables
{
  # print "<H1>Saving Global variables</H1>";

  local($conffile)=$CONFDIR."/general.conf";

  local($tmpfile)=$CONFDIR."/general.conf.$$";
  local($result)=open(TEMPFILE,">$tmpfile");
  print TEMPFILE $formdata{GLOBALS};
  close(TEMPFILE);

  local($command)="/usr/bin/dos2unix $tmpfile";
  local($result)=&RunCommand($command,"Forcing unix file format");

  local($result)=&RunCommand("cp $tmpfile $conffile","Copying temporary file |$tmpfile| to |$conffile|\n");
  if ($result)
  {
    &PrintError("Could not copy temporary file $tmpfile","to pxe config file $conffile");
    return 1;
  }
  unlink($tmpfile);

  return 0;
}


sub EditGlobalVariables
{
  print "<CENTER>\n";
  print "<H2>Edit Global Variables</H2>\n";
  &PrintToolbar("Apply","Cancel");
  local(@lines)=GetConfigFile("$CONFDIR/general.conf");
  print "<script language='javascript' src='/js/editvars.js'></script>\n";
  print "<FORM NAME=EDITVARSFORM METHOD=POST ACTION='uda3.pl'>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE='system'>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE='systemvars'>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE='unknown'>\n";
  print "<TEXTAREA ROWS=25 COLS=60 NAME=GLOBALS>";
  print @lines;
  print "</TEXTAREA>";
  print "</FORM>\n";
  return 0;
}

sub DisplaySystemVariables
{
  print "<CENTER>\n";
  print "<H2>System Variables</H2>\n";

  local(%config)=&GetOnlySystemVariables();
  print " <TABLE BORDER=1>\n";
  print "<TR CLASS=tableheader><TD>Variable name</TD><TD>Value</TD></TR>\n";

  for $item (keys(%config))
  {
    print "<TR><TD>$item</TD><TD>$config{$item}</TD></TR>\n";
  }
  print "</TABLE>\n";
  print "<H2>Global Variables</H2>\n";
  &PrintToolbar("Edit");
  print "<script language='javascript' src='/js/showvars.js'></script>\n";
  print "<FORM NAME=SHOWVARSFORM METHOD=POST ACTION='uda3.pl'>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE='system'>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE='systemvars'>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE='unknown'>\n";
  print "</FORM>\n";
  local(%config)=&GetGeneralConfig();
  print " <TABLE BORDER=1>\n";
  print "<TR CLASS=tableheader><TD>Variable name</TD><TD>Value</TD></TR>\n";
  for $item (keys(%config))
  {
    print "<TR><TD>$item</TD><TD>$config{$item}</TD></TR>\n";
  }
  print "</TABLE>\n";
  print "</CENTER>\n";
  return 0;
}

sub ApplyShutdown
{
  print "<CENTER>\n";
  print "<H3>Shutting Down system</H3>\n";
  print "</CENTER>\n";
  local($command)="/sbin/shutdown -h now";
  local($result)=&RunCommand($command,"Shutdown system");
  return 0;
}

sub ApplyReboot
{
  print "<CENTER>\n";
  print "<H3>Rebooting system</H3>\n";
  print "</CENTER>\n";
  local($command)="/sbin/shutdown -r now";
  local($result)=&RunCommand($command,"Reboot system");
  return 0;

}

sub SystemStatus
{
  print "<CENTER>\n";
  print "<H2>System</H2>\n";
  print "<FORM NAME=SYSTEMFORM ACION='uda3.pl' METHOD=POST>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=system>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=none>\n";
  print "<H4>Configuration</H4>\n";
  &PrintToolbar("Network","Password","Diskspace","PXE","Shutdown");
  print "<H4>Tools</H4>\n";
  &PrintToolbar("Upload","Upgrade","PowerShell","WinPE");
  print "<H4>VMware</H4>\n";
  &PrintToolbar("Esx4NoSan","VMTools","OvfTool");
  print "<H4>Information</H4>\n";
  &PrintToolbar("Actions","Variables","Version","Help");
  print "<script language='javascript' src='/js/system.js'></script>\n";
  print "</FORM>\n";

  print "</CENTER>\n";
  return 0;
}

sub Upload
{

local($freespace)=`df -hP /local | tail -1 | awk '{print \$4}'`;
print "<CENTER>\n";
print "<script language='javascript' src='/js/upload.js'></script>\n";
local($html)=<<EOT;
<H2>Upload</H2>
<DIV ID=upload_div STYLE="display: block">
The file will be uploaded to the local storage of the UDA. <BR>
Current Free space is: $freespace<BR><BR>
<iframe name="my_iframe" src="about:blank" width="500" height="200" style="display: none"></iframe>
<FORM NAME="upload" ENCTYPE="multipart/form-data" METHOD="POST" ACTION="/cgi-bin/upload.cgi?uploadid=$$" TARGET="my_iframe">
<INPUT TYPE=HIDDEN NAME=uploadid VALUE=$$><BR><BR>
Select File to upload<BR><BR><INPUT TYPE=FILE NAME=upload_file><BR><BR>
<INPUT TYPE=BUTTON VALUE=Upload ONCLICK='ClickUploadButton();'>
</FORM>
</DIV>
<DIV ID=progress_div STYLE="display:none">
<TABLE>
<TR><TD>Filename:&nbsp;&nbsp;&nbsp;</TD><TD>
<DIV ID=filename_div STYLE="display: none">Unknown</DIV>
</TD></TR>
<TR><TD>Size:&nbsp;&nbsp;&nbsp;</TD><TD>
<DIV ID=size_div STYLE="display: none">Unknown (bytes)</DIV>
</TD></TR>
<TR><TD>Progress:&nbsp;&nbsp;&nbsp;</TD><TD>
<DIV ID=total_div STYLE="display: none">Unknown (bytes)</DIV>
</TD></TR>
</TABLE>
<BR><BR>
<div id="empty3" style="background-color:#cccccc;border:1px solid black;height:30px;width:300px;padding:0px;" align="left">
<div id="d6" style="position:relative;top:0px;left:0px;background-color:#1111cc;height:30px;width:0px;padding-top:5px;padding:0px;">
<div id="d5" style="position:relative;top:0px;left:0px;color:#f0ffff;height:30px;text-align:center;font:bold;padding:0px;padding-top:5px;">
</div></div> </div>
<DIV ID=UPLOADRESULT STYLE="display: none">Starting upload</DIV>
</DIV>
EOT

 print $html;

}

sub Version
{
  print "<CENTER>\n";
  print "<H2>Version Information</H2>\n";

  local(%config)=&GetVersionList();
  print " <TABLE BORDER=1>\n";
  print "<TR CLASS=tableheader><TD>Module</TD><TD>Version</TD></TR>\n";

  for $item (keys(%config))
  {
    print "<TR><TD>$item</TD><TD>$config{$item}</TD></TR>\n";
  }
  print "</TABLE>\n";
  print "</CENTER>\n";
  return 0;
}

sub Upgrade
{
 print "<CENTER>\n"; 
 print "<H2>Upgrade UDA</H2>\n";
 print "<FORM NAME='WIZARDFORM' ENCTYPE='multipart/form-data' METHOD='POST' ACTION='/cgi-bin/upload_upgrade.cgi'>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=system>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=upgrade>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<script language='javascript' src='/js/upgrade.js'></script>\n";
 &PrintToolbar("Apply","Cancel"); 
 print "<BR><BR>\n";
 print "<FONT COLOR=RED>BACKUP your UDA or make a snapshot before you do this!!!</FONT>\n";
 print "<BR><BR>\n";
 print "Choose the .tgz file with the patch\n";
 print "<BR><BR>\n";
 print "<TABLE>\n";
 print "<TR><TD>Upgrade file</TD><TD><INPUT TYPE=FILE NAME=UPGRADEFILE></TD></TR>\n";
 print "</CENTER>\n";
 print "</FORM>\n";
}

sub ApplyUpgrade
{
 local($fullfilename)=shift;
 require "action.pl";
 print "<CENTER>\n";
 print "<H2>Applying upgrade</H2>\n";
 print "</CENTER>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 local($actionid)=$$;
 print "<INPUT TYPE=HIDDEN NAME=actionid ID=actionid VALUE=\"$actionid\">\n";
  print "<CENTER>\n";
  print "<TABLE>\n";
  print "<TR><TD>Filename</TD><TD>$fullfilename</TD></TR>\n";
  #print "<TR><TD>Action ID</TD><TD>$actionid</TD></TR>\n";
  print "<TR><TD>Action ID</TD><TD><A HREF='uda3.pl?module=system&action=actions&button=view&actionid=$actionid'>$actionid</A></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";
 
  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Upgrade UDA","system.pl","\&ApplyUpgrade_DoIt($actionid,\"$fullfilename\");");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";
}
 
sub ApplyUpgrade_DoIt
{
  local($actionid)=shift;
  local($filename)=shift;
  require "general.pl";
  require "config.pl";
  require "action.pl";

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) {
    &UpdateActionProgress($actionid,-1,"Could not read arguments");
    return 1;
  }

  #for $key (keys(%args))
  #{
  #  print "<LI>KEY $key -> $args{$key}\n";
  #}

  local($upgradefile)=$filename;
  local($patchdir)="$TMPDIR/action.$actionid/patch";
  
  local($result)=&CreateDir("$patchdir");
  if ($result)
  {
     &UpdateActionProgress($actionid,-2,"Could not create $patchdir");
     return 2;
  }
  &UpdateActionProgress($actionid,30,"Created patch directory $patchdir");

  local($command)="tar -xvzf $upgradefile -C $patchdir";
  local($result)=&RunCommand($command);
  if ($result)
  {
     &UpdateActionProgress($actionid,-2,"Failed to unpack the patch $upgradefile");
     return 2;
  }
  &UpdateActionProgress($actionid,40,"Unpacked the patch succesfully");

  local($command)="chmod -R 644 $patchdir";
  local($result)=&RunCommand($command);
  if ($result)
  {
     &UpdateActionProgress($actionid,-2,"Failed to set permissions on unpacked files");
     return 2;
  }
  &UpdateActionProgress($actionid,50,"Set permissions on unpacked files");

  local($command)="chmod -R 755 $patchdir/install.sh";
  local($result)=&RunCommand($command);
  if ($result)
  {
     &UpdateActionProgress($actionid,-2,"Failed to set permissions on install script");
     return 2;
  }
  &UpdateActionProgress($actionid,60,"Set permissions on install script");

  local($command)="$patchdir/install.sh $patchdir > $TMPDIR/action.$actionid/action.out";
  local($result)=&RunCommand($command);
  if ($result)
  {
     &UpdateActionProgress($actionid,-2,"Upgrade failed");
     return 2;
  }
  &UpdateActionProgress($actionid,100,"Patch installed succesfully");

  return 0;
}

sub Help
{
 print "<CENTER>\n";
 print "<H2>Help</H2>\n";
 print "<H4>This is the great stuff that ties the UDA together</H4>";
 print "<TABLE><TR><TD>\n";
 print "<LI><A HREF='http://www.centos.org'>Centos 7</A>";
 print "<LI><A HREF='http://syslinux.zytor.com/pxe.php'>Pxelinux</A>\n";
 print "<LI>tftp-server";
 print "<LI><A HREF='http://www.kyz.uklinux.net/cabextract.php'>Cabextract</A>\n";
 print "<LI><A HREF='http://oss.netfarm.it/guides/pxe.php'>RIS for linux package</A>\n";
 print "<LI><A HREF='https://www.isc.org'>in.dhcpd</A>\n";
 print "<LI>nfs server\n";
 print "<LI><A HREF='http://www.samba.org'>samba</A>\n";
 print "<LI><A HREF='https://wimlib.net'>wimlib</A>\n";
 print "<LI><A HREF='http://www.perl.org/'>perl</A>\n";
 print "<LI><A HREF='http://www.python.org/'>python</A>\n";
 print "<LI><A HREF='http://www.apache.org'>apache</A>\n";
 print "<LI><A HREF='http://www.famfamfam.com/lab/icons/silk/'>famfamfam silk icons</A>\n";
 print "</TD></TR></TABLE>\n";
 print "<BR><BR>\n";
 print "For more information go to<BR>\n";
 print "<A HREF='http://www.ultimatedeployment.org'>www.ultimatedeployment.org</A>\n";
 print "<BR><BR>\n";
 print "Thanks to all the people on the forum!!!!\n";
 print "</CENTER>\n";

}

sub Esx3NoSan
{
 print "<CENTER>\n"; 
 print "<H2>Remove ESX3 San Drivers</H2>\n";
 print "<FORM NAME=SYSTEMFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=system>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=applyesx3nosan>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<script language='javascript' src='/js/esx3nosan.js'></script>\n";
 &PrintToolbar("Apply","Cancel");
 print "<BR><BR>\n";
 local(@mountlist)=&GetMountList();;
 &PrintJavascriptArray("mountsarray",@mountlist);
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<script language='javascript' src='/js/tree.js'></script>\n";
 print "Show me the esx3 iso file<BR>and I'll create an iso file next to it without the san drivers<BR><BR>";
 print "<TABLE>\n";
 print "<TR><TD>Storage</TD><TD><SELECT NAME=MOUNT ID=MOUNT ONCHANGE=\"expand('/')\"></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile</TD><TD><INPUT TYPE=TEXT NAME=FILE1 ID=FILE1 SIZE=60 VALUE='/'></TD></TR>\n";
 print "<TR><TD COLSPAN=2><DIV ID=browse_div></DIV></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "<script language='javascript'>\n";
 print "LoadValues(\"MOUNT\",mountsarray);\n";
 print "expand('/');\n";
 print "</script>\n";
 print "</CENTER>\n";
}

sub ApplyEsx3NoSan
{
 local($mount)=$formdata{MOUNT};
 local($file1)=$formdata{FILE1};

 require "action.pl";

 print "<CENTER>\n";
 print "<H2>Creating ESX3 iso image without SAN drivers</H2>\n";
 print "</CENTER>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 local($actionid)=$$;
 print "<INPUT TYPE=HIDDEN NAME=actionid ID=actionid VALUE=\"$actionid\">\n";

  print "<CENTER>\n";
  print "<TABLE>\n";
  print "<TR><TD>Mount</TD><TD>$mount</TD></TR>\n";
  print "<TR><TD>File 1</TD><TD>$file1</TD></TR>\n";
  #print "<TR><TD>Action ID</TD><TD>$actionid</TD></TR>\n";
  print "<TR><TD>Action ID</TD><TD><A HREF='uda3.pl?module=system&action=actions&button=view&actionid=$actionid'>$actionid</A></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";

  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Removing ESX3 HBA Drivers","system.pl","\&ApplyEsx3NoSan_DoIt($actionid);");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";
}

sub ApplyEsx3NoSan_DoIt
{
  local($actionid)=shift;
 
  require "general.pl";
  require "config.pl";
  require "action.pl";
 
  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) {
    &UpdateActionProgress($actionid,-1,"Could not read arguments");
    return 1;
  } 

  local(%mountinfo)=&GetMountInfo($args{MOUNT});
  local($isofile)=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{FILE1};
  if ($mountinfo{TYPE} eq "CDROM")
  {
    $isofile=$mountinfo{SHARE};
  }
 
  local($workspace)=$isofile.".workdir.".$actionid;
  local($result)=&CreateDir($workspace);
  if ($result) 
  {
     &UpdateActionProgress($actionid,-2,"Could not create workspace directory $workspace");
     return 2;
  }
  &UpdateActionProgress($actionid,10,"Created workspace directory $workspace");


  local($initrddir)=$workspace."/initrd";
  local($result)=&CreateDir($initrddir);
  if ($result) 
  {
     &UpdateActionProgress($actionid,-2,"Could not create initrd directory $initrddir");
     return 2;
  }
  &UpdateActionProgress($actionid,15,"Created initrd directory $initrddir");


  my($tempdir)="$TMPDIR/action.$actionid/mountiso";
  local($result)=&CreateDir($tempdir);
  if ($result) 
  {
     &UpdateActionProgress($actionid,-2,"Could not create temporary directory $tempdir");
     return 2;
  }
  &UpdateActionProgress($actionid,20,"Created/checked temporary directory $tempdir");

  local($result)=&MountIso($isofile,$tempdir);
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not mount iso file $isofile on $tempdir");
    return 4;
  }
  &UpdateActionProgress($actionid,30,"Mounted iso file $isofile on $tempdir");

  local($srcinitrd)="$tempdir/images/pexboot/initrd.img";
  local($dstinitrd)="$workspace/initrd/initrd.img.gz";

  local($result)=&ImportFile($srcinitrd,$dstinitrd);
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not copy initrd $srcinitrd to $dstinitrd");
    return 4;
  }
  &UpdateActionProgress($actionid,35,"Imported Initrd to $dstinitrd");

  local($command)="gunzip $dstinitrd";
  local($result)=&RunCommand($command,"Unzipping the current initrd");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not unzip $dstinitrd");
    return 4;
  }
  &UpdateActionProgress($actionid,35,"Unzipped Initrd $dstinitrd");

  local($initrdunzipped)="$workspace/initrd/initrd.img";

  local($command)="cd $workspace/initrd && cpio -idvm --file $initrdunzipped";
  local($result)=&RunCommand($command,"Unarchiving the unzipped initrd");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not unarchive $initrdunzipped");
    return 4;
  }
  &UpdateActionProgress($actionid,40,"Unarchived Initrd $initrdunzipped");

  local($qladrivers)="$workspace/initrd/usr/lib/vmware/vkmod/qla*";
  local($lpfdirvers)="$workspace/initrd/usr/lib/vmware/vkmod/lpf*";
  local($qlaids)="$workspace/initrd/usr/share/hwdata/pciids/qla*";
  local($lpfids)="$workspace/initrd/usr/share/hwdata/pciids/lpf*";

  local($command)="rm -f $dstinitrd $initrdunzipped $qladrivers $lpfdrivers $qlaids $lpfids";
  local($result)=&RunCommand($command,"Removing the drivers");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not remove the drivers");
    return 4;
  }
  &UpdateActionProgress($actionid,50,"Removed the drivers");

  local($command)="cd $workspace/initrd && find . | cpio --create --format='newc' > $workspace/initrd.new";
  local($result)=&RunCommand($command,"Archiving the new initrd");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not archive the new initrd");
    return 4;
  }
  &UpdateActionProgress($actionid,55,"Archived new initrd");

  local($command)="gzip --best $workspace/initrd.new";
  local($result)=&RunCommand($command,"Compressing the new initrd");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not compress the new initrd");
    return 4;
  }
  &UpdateActionProgress($actionid,60,"Compressed the new initrd");

  local($command)="cp -r $tempdir $workspace";
  local($result)=&RunCommand($command,"Copying the files from the orignal iso");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not copy the files from the original iso");
    return 4;
  }
  &UpdateActionProgress($actionid,80,"File copy succesfully");

  local($command)="/bin/umount $tempdir";
  local($result)=&RunCommand($command,"Unmounting ISO file") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not unmount ISO File");
    return 5;
  }
  &UpdateActionProgress($actionid,82,"Unmounted ISO file");

  local($command)="/bin/rmdir $tempdir";
  local($result)=&RunCommand($command,"Removing temporary directory $tempdir") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not remove tempdir $tempdir");
    return 5;
  }
  &UpdateActionProgress($actionid,84,"Removed tempdir $tempdir");

  local($srcinitrd)="$workspace/initrd.new.gz";
  local($dstinitrd)="$workspace/mountiso/isolinux/initrd.img";
  local($result)=&ImportFile("$srcinitrd","$dstinitrd");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not import the new initrd file from $srcinitrd to $dstinitrd");
    return 4;
  }
  &UpdateActionProgress($actionid,85,"New Initrd imported sucesfully");

  local($command)="cd $workspace/mountiso && mkisofs -l -J -R -r -T -o $isofile.nosan.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table ./";
  local($result)=&RunCommand($command,"Creating New ISO file");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not create the new iso file");
    return 4;
  }
  &UpdateActionProgress($actionid,90,"Created new iso file succesfully");

  local($command)="rm -rf $workspace";
  local($result)=&RunCommand($command,"Removing temporary workspace");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not remove the workspace");
    return 4;
  }
  &UpdateActionProgress($actionid,95,"Workspace removed succesfully");

  &UpdateActionProgress($actionid,100,"Success, Created ESX4 iso without SAN drivers");

  return 0;
}

sub Esx4NoSan
{
 print "<CENTER>\n"; 
 print "<H2>Remove ESX4 San Drivers</H2>\n";
 print "<FORM NAME=SYSTEMFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=system>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=applyesx4nosan>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<script language='javascript' src='/js/esx4nosan.js'></script>\n";
 &PrintToolbar("Apply","Cancel");
 print "<BR><BR>\n";
 local(@mountlist)=&GetMountList();;
 &PrintJavascriptArray("mountsarray",@mountlist);
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<script language='javascript' src='/js/tree.js'></script>\n";
 print "Show me the esx4 iso file<BR>and I'll create an iso file next to it without the san drivers<BR><BR>";
 print "<TABLE>\n";
 print "<TR><TD>Storage</TD><TD><SELECT NAME=MOUNT ID=MOUNT ONCHANGE=\"expand('/')\"></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile</TD><TD><INPUT TYPE=TEXT NAME=FILE1 ID=FILE1 SIZE=60 VALUE='/'></TD></TR>\n";
 print "<TR><TD COLSPAN=2><DIV ID=browse_div></DIV></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "<script language='javascript'>\n";
 print "LoadValues(\"MOUNT\",mountsarray);\n";
 print "expand('/');\n";
 print "</script>\n";
 print "</CENTER>\n";
}

sub ApplyEsx4NoSan
{
 local($mount)=$formdata{MOUNT};
 local($file1)=$formdata{FILE1};

 require "action.pl";

 print "<CENTER>\n";
 print "<H2>Creating ESX4 iso image without SAN drivers</H2>\n";
 print "</CENTER>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 local($actionid)=$$;
 print "<INPUT TYPE=HIDDEN NAME=actionid ID=actionid VALUE=\"$actionid\">\n";

  print "<CENTER>\n";
  print "<TABLE>\n";
  print "<TR><TD>Mount</TD><TD>$mount</TD></TR>\n";
  print "<TR><TD>File 1</TD><TD>$file1</TD></TR>\n";
  #print "<TR><TD>Action ID</TD><TD>$actionid</TD></TR>\n";
  print "<TR><TD>Action ID</TD><TD><A HREF='uda3.pl?module=system&action=actions&button=view&actionid=$actionid'>$actionid</A></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";

  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Removing ESX4 HBA Drivers","system.pl","\&ApplyEsx4NoSan_DoIt($actionid);");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";

}

sub ApplyEsx4NoSan_DoIt
{
  local($actionid)=shift;
 
  require "general.pl";
  require "config.pl";
  require "action.pl";
 
  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) {
    &UpdateActionProgress($actionid,-1,"Could not read arguments");
    return 1;
  } 

  local(%mountinfo)=&GetMountInfo($args{MOUNT});
  local($isofile)=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{FILE1};
  if ($mountinfo{TYPE} eq "CDROM")
  {
    $isofile=$mountinfo{SHARE};
  }
 
  local($workspace)=$isofile.".workdir.".$actionid;
  local($result)=&CreateDir($workspace);
  if ($result) 
  {
     &UpdateActionProgress($actionid,-2,"Could not create workspace directory $workspace");
     return 2;
  }
  &UpdateActionProgress($actionid,10,"Created workspace directory $workspace");


  local($initrddir)=$workspace."/initrd";
  local($result)=&CreateDir($initrddir);
  if ($result) 
  {
     &UpdateActionProgress($actionid,-2,"Could not create initrd directory $initrddir");
     return 2;
  }
  &UpdateActionProgress($actionid,15,"Created initrd directory $initrddir");


  my($tempdir)="$TMPDIR/action.$actionid/mountiso";
  local($result)=&CreateDir($tempdir);
  if ($result) 
  {
     &UpdateActionProgress($actionid,-2,"Could not create temporary directory $tempdir");
     return 2;
  }
  &UpdateActionProgress($actionid,20,"Created/checked temporary directory $tempdir");

  local($result)=&MountIso($isofile,$tempdir);
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not mount iso file $isofile on $tempdir");
    return 4;
  }
  &UpdateActionProgress($actionid,30,"Mounted iso file $isofile on $tempdir");

  local($srcinitrd)="$tempdir/isolinux/initrd.img";
  local($dstinitrd)="$workspace/initrd/initrd.img.gz";

  local($result)=&ImportFile($srcinitrd,$dstinitrd);
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not copy initrd $srcinitrd to $dstinitrd");
    return 4;
  }
  &UpdateActionProgress($actionid,35,"Imported Initrd to $dstinitrd");

  local($command)="gunzip $dstinitrd";
  local($result)=&RunCommand($command,"Unzipping the current initrd");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not unzip $dstinitrd");
    return 4;
  }
  &UpdateActionProgress($actionid,35,"Unzipped Initrd $dstinitrd");

  local($initrdunzipped)="$workspace/initrd/initrd.img";

  local($command)="cd $workspace/initrd && cpio -idvm --file $initrdunzipped";
  local($result)=&RunCommand($command,"Unarchiving the unzipped initrd");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not unarchive $initrdunzipped");
    return 4;
  }
  &UpdateActionProgress($actionid,40,"Unarchived Initrd $initrdunzipped");

  local($qladrivers)="$workspace/initrd/usr/lib/vmware/vkmod/qla*";
  local($lpfdirvers)="$workspace/initrd/usr/lib/vmware/vkmod/lpf*";
  local($qlaids)="$workspace/initrd/usr/share/hwdata/pciids/qla*";
  local($lpfids)="$workspace/initrd/usr/share/hwdata/pciids/lpf*";

  local($command)="rm -f $dstinitrd $initrdunzipped $qladrivers $lpfdrivers $qlaids $lpfids";
  local($result)=&RunCommand($command,"Removing the drivers");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not remove the drivers");
    return 4;
  }
  &UpdateActionProgress($actionid,50,"Removed the drivers");

  local($command)="cd $workspace/initrd && find . | cpio --create --format='newc' > $workspace/initrd.new";
  local($result)=&RunCommand($command,"Archiving the new initrd");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not archive the new initrd");
    return 4;
  }
  &UpdateActionProgress($actionid,55,"Archived new initrd");

  local($command)="gzip --best $workspace/initrd.new";
  local($result)=&RunCommand($command,"Compressing the new initrd");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not compress the new initrd");
    return 4;
  }
  &UpdateActionProgress($actionid,60,"Compressed the new initrd");

  local($command)="cp -r $tempdir $workspace";
  local($result)=&RunCommand($command,"Copying the files from the orignal iso");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not copy the files from the original iso");
    return 4;
  }
  &UpdateActionProgress($actionid,80,"File copy succesfully");

  local($command)="/bin/umount $tempdir";
  local($result)=&RunCommand($command,"Unmounting ISO file") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not unmount ISO File");
    return 5;
  }
  &UpdateActionProgress($actionid,82,"Unmounted ISO file");

  local($command)="/bin/rmdir $tempdir";
  local($result)=&RunCommand($command,"Removing temporary directory $tempdir") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not remove tempdir $tempdir");
    return 5;
  }
  &UpdateActionProgress($actionid,84,"Removed tempdir $tempdir");

  local($srcinitrd)="$workspace/initrd.new.gz";
  local($dstinitrd)="$workspace/mountiso/isolinux/initrd.img";
  local($result)=&ImportFile("$srcinitrd","$dstinitrd");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not import the new initrd file from $srcinitrd to $dstinitrd");
    return 4;
  }
  &UpdateActionProgress($actionid,85,"New Initrd imported sucesfully");

  local($command)="cd $workspace/mountiso && mkisofs -l -J -R -r -T -o $isofile.nosan.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table ./";
  local($result)=&RunCommand($command,"Creating New ISO file");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not create the new iso file");
    return 4;
  }
  &UpdateActionProgress($actionid,90,"Created new iso file succesfully");

  local($command)="rm -rf $workspace";
  local($result)=&RunCommand($command,"Removing temporary workspace");
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not remove the workspace");
    return 4;
  }
  &UpdateActionProgress($actionid,95,"Workspace removed succesfully");

  &UpdateActionProgress($actionid,100,"Success, Created ESX4 iso without SAN drivers");

  return 0;
}

sub InstallOvfTool
{
 print "<CENTER>\n"; 
 print "<H2>Install VMware Ovftool</H2>\n";
 print "<FORM NAME=SYSTEMFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=system>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=applyinstallovftool>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<script language='javascript' src='/js/installovftool.js'></script>\n";
 &PrintToolbar("Apply","Cancel");
 print "<BR><BR>\n";
 local(@mountlist)=&GetMountList();;
 &PrintJavascriptArray("mountsarray",@mountlist);
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<script language='javascript' src='/js/tree.js'></script>\n";
 if ($OVFTOOLINSTALLED)
 {
   print "The ovftool is already installed, but you can try to reinstall it if you like<BR>\n";
   local($ovfversion)=`/usr/bin/ovftool --version`;
   print "Current version: $ovfversion<BR><BR>\n";
 } 

 print "You can download the zip package with sample ova files<BR>\n";
 print "<LI>For VirtualBox <A HREF=\"/vboxova.zip\">here</A><BR>\n";
 print "<LI>For ESX <A HREF=\"/esxova.zip\">here</A><BR><BR>\n";

 print "Show me the ovftool bundle and I'll install it...<BR><BR>";
 print "The filename would look something like this:<BR>VMware-ovftool-4.3.0-7948156-lin.x86_64.bundle<BR><BR>";
 print "<TABLE>\n";
 print "<TR><TD>Storage</TD><TD><SELECT NAME=MOUNT ID=MOUNT ONCHANGE=\"expand('/')\"></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile</TD><TD><INPUT TYPE=TEXT NAME=FILE1 ID=FILE1 SIZE=60 VALUE='/'></TD></TR>\n";
 print "<TR><TD COLSPAN=2><DIV ID=browse_div></DIV></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "<script language='javascript'>\n";
 print "LoadValues(\"MOUNT\",mountsarray);\n";
 print "expand('/');\n";
 print "</script>\n";
 print "</CENTER>\n";
}

sub InstallPowerShell
{
 print "<CENTER>\n"; 
 print "<H2>Install Powershell</H2>\n";
 print "<FORM NAME=SYSTEMFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=system>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=applyinstallpowershell>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<script language='javascript' src='/js/installpowershell.js'></script>\n";
 &PrintToolbar("Apply","Cancel");
 print "<BR><BR>\n";
 local(@mountlist)=&GetMountList();;
 &PrintJavascriptArray("mountsarray",@mountlist);
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<script language='javascript' src='/js/tree.js'></script>\n";
 if ($PWSHINSTALLED)
 {
   print "Powershell is already installed, but you can try to reinstall it if you like<BR>\n";
   local($pwshversion)=`/usr/bin/pwsh --version`;
   print "Current version: $pwshversion<BR><BR>\n";
 }
 print "Show me the Powershell RPM and I'll install it...<BR><BR>";
 print "<TABLE>\n";
 print "<TR><TD>Storage</TD><TD><SELECT NAME=MOUNT ID=MOUNT ONCHANGE=\"expand('/')\"></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile</TD><TD><INPUT TYPE=TEXT NAME=FILE1 ID=FILE1 SIZE=60 VALUE='/'></TD></TR>\n";
 print "<TR><TD COLSPAN=2><DIV ID=browse_div></DIV></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "<script language='javascript'>\n";
 print "LoadValues(\"MOUNT\",mountsarray);\n";
 print "expand('/');\n";
 print "</script>\n";
 print "</CENTER>\n";
}


sub InstallVMWareTools
{
 print "<CENTER>\n"; 
 print "<H2>Install VMWare Tools</H2>\n";
 print "<FORM NAME=SYSTEMFORM>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=system>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=applyinstallvmwaretools>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<script language='javascript' src='/js/installvmwaretools.js'></script>\n";
 &PrintToolbar("Apply","Cancel");
 print "<BR><BR>\n";
 local(@mountlist)=&GetMountList();;
 &PrintJavascriptArray("mountsarray",@mountlist);
 print "<script language='javascript' src='/js/loadvalues.js'></script>\n";
 print "<script language='javascript' src='/js/tree.js'></script>\n";
 if ($VMTOOLSINSTALLED)
 {
   print "VMWare tools is already installed, but you can try to reinstall it if you like<BR>\n";
   local($vmtoolsversion)=`/usr/bin/vmtoolsd --version`;
   print "Current version: $vmtoolsversion<BR><BR>\n";
 }
 print "Show me the linux.iso file that is in your VMWare distribution<BR>and I'll install the tar.gz that's in it...<BR><BR>";
 print "<TABLE>\n";
 print "<TR><TD>Storage</TD><TD><SELECT NAME=MOUNT ID=MOUNT ONCHANGE=\"expand('/')\"></SELECT></TD></TR>\n";
 print "<TR><TD>ImageFile</TD><TD><INPUT TYPE=TEXT NAME=FILE1 ID=FILE1 SIZE=60 VALUE='/'></TD></TR>\n";
 print "<TR><TD COLSPAN=2><DIV ID=browse_div></DIV></TD></TR>\n";
 print "</TABLE>\n";
 print "<BR>\n";
 print "</FORM>\n";
 print "<script language='javascript'>\n";
 print "LoadValues(\"MOUNT\",mountsarray);\n";
 print "expand('/');\n";
 print "</script>\n";
 print "</CENTER>\n";
}

sub ApplyInstallOvfTool
{
 local($mount)=$formdata{MOUNT};
 local($file1)=$formdata{FILE1};

 require "action.pl";

 print "<CENTER>\n";
 print "<H2>Now installing ovftool</H2>\n";
 print "</CENTER>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 local($actionid)=$$;
 print "<INPUT TYPE=HIDDEN NAME=actionid ID=actionid VALUE=\"$actionid\">\n";
  print "<CENTER>\n";
  print "<TABLE>\n";
  print "<TR><TD>Mount</TD><TD>$mount</TD></TR>\n";
  print "<TR><TD>File 1</TD><TD>$file1</TD></TR>\n";
  #print "<TR><TD>Action ID</TD><TD>$actionid</TD></TR>\n";
  print "<TR><TD>Action ID</TD><TD><A HREF='uda3.pl?module=system&action=actions&button=view&actionid=$actionid'>$actionid</A></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";

  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Install VMWare Ovftool","system.pl","\&ApplyInstallOvfTool_DoIt($actionid);");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";
}

sub ApplyInstallPowerShell
{
 local($mount)=$formdata{MOUNT};
 local($file1)=$formdata{FILE1};

 require "action.pl";

 print "<CENTER>\n";
 print "<H2>Now instaling Powershell</H2>\n";
 print "</CENTER>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 local($actionid)=$$;
 print "<INPUT TYPE=HIDDEN NAME=actionid ID=actionid VALUE=\"$actionid\">\n";

  print "<CENTER>\n";
  print "<TABLE>\n";
  print "<TR><TD>Mount</TD><TD>$mount</TD></TR>\n";
  print "<TR><TD>File 1</TD><TD>$file1</TD></TR>\n";
  #print "<TR><TD>Action ID</TD><TD>$actionid</TD></TR>\n";
  print "<TR><TD>Action ID</TD><TD><A HREF='uda3.pl?module=system&action=actions&button=view&actionid=$actionid'>$actionid</A></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";

  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Install Powershell","system.pl","\&ApplyInstallPowerShell_DoIt($actionid);");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";
}

sub ApplyInstallVMWareTools
{
 local($mount)=$formdata{MOUNT};
 local($file1)=$formdata{FILE1};

 require "action.pl";

 print "<CENTER>\n";
 print "<H2>Now instaling VMWare Tools</H2>\n";
 print "</CENTER>\n";
 print "<FORM NAME=WIZARDFORM>\n";
 local($actionid)=$$;
 print "<INPUT TYPE=HIDDEN NAME=actionid ID=actionid VALUE=\"$actionid\">\n";

  print "<CENTER>\n";
  print "<TABLE>\n";
  print "<TR><TD>Mount</TD><TD>$mount</TD></TR>\n";
  print "<TR><TD>File 1</TD><TD>$file1</TD></TR>\n";
  #print "<TR><TD>Action ID</TD><TD>$actionid</TD></TR>\n";
  print "<TR><TD>Action ID</TD><TD><A HREF='uda3.pl?module=system&action=actions&button=view&actionid=$actionid'>$actionid</A></TD></TR>\n";
  print "</TABLE>\n";
  print "<BR>\n";

  &PrintProgressBar();
  print "<BR>\n";
  &PrintStatusDiv();
  print "</CENTER>\n";
  &RunAction($actionid,"Install VMWare Tools","system.pl","\&ApplyInstallVMWareTools_DoIt($actionid);");

 print "<script language='javascript' src='/js/progress.js'></script>\n";
 print "<script language='javascript'>\n";
 print "Update($actionid);\n";
 print "</script>\n";


}

sub ApplyInstallOvfTool_DoIt
{
  local($actionid)=shift;

  require "general.pl";
  require "config.pl";
  require "action.pl";

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) {
    &UpdateActionProgress($actionid,-1,"Could not read arguments");
    return 1;
  }


  local(%mountinfo)=&GetMountInfo($args{MOUNT});
  local($isofile)=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{FILE1};
  if ($mountinfo{TYPE} eq "CDROM")
  {
    $isofile=$mountinfo{SHARE};
  }

  local($basefilename)=$args{FILE1};
  $basefilename =~ s/.*\/([^\/]+)$/\1/g;

  local($actiondir)=$TMPDIR."/action.".$actionid;
  local($command)="cp $isofile $actiondir/$basefilename";
  local($result)=&RunCommand($command,"Copying $isofile to temporary place") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not copy $isofile");
    return 5;
  }
  &UpdateActionProgress($actionid,20,"Copied file $isofile");
  

  local($command)="chmod 755 $actiondir/$basefilename";
  local($result)=&RunCommand($command,"Changing file mode for $actiondir/$basefilename") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not change file mode for $actiondir/$basefilename");
    return 5;
  }
  &UpdateActionProgress($actionid,20,"Changed file mode for $actiondir/$basefilename");

  local($command)="$actiondir/$basefilename --eulas-agreed --required";
  local($result)=&RunCommand($command,"Installing ovftool bundle") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not install ovftool bundle $actiondir/$basefilename");
    local($command)="rm -f $actiondir/$basefilename";
    &RunCommand($command,"Removing OVF Tool bundle") ;
    return 5;
  }
  &UpdateActionProgress($actionid,90,"Installed ovftool bundle");

  local($command)="rm -f $actiondir/$basefilename";
  local($result)=&RunCommand($command,"Removing ovf bundle $actiondir/$basefilename") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not remove OVF bundle $actiondir/$basefilename");
    return 5;
  }
  &UpdateActionProgress($actionid,95,"Removed ovf bundle $actiondir/$basefilename");

  &RunCommand($command,"Removing OVF Tool bundle") ;
  &UpdateActionProgress($actionid,100,"Success, installed OvfTool");

 return 0;
}

sub ApplyInstallPowerShell_DoIt
{
  local($actionid)=shift;

  require "general.pl";
  require "config.pl";
  require "action.pl";

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) {
    &UpdateActionProgress($actionid,-1,"Could not read arguments");
    return 1;
  }

  local(%mountinfo)=&GetMountInfo($args{MOUNT});
  local($isofile)=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{FILE1};
  if ($mountinfo{TYPE} eq "CDROM")
  {
    $isofile=$mountinfo{SHARE};
  }

  local($command)="/bin/rpm -Uvh $isofile";
  local($result)=&RunCommand($command,"Installing Powershell rpm") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not install Powershell rpm $isofile");
    return 5;
  }
  &UpdateActionProgress($actionid,50,"Installed Powershell RPM");

  &UpdateActionProgress($actionid,100,"Success, installed PowerShell");

 return 0;
}

sub ApplyInstallVMWareTools_DoIt
{
  local($actionid)=shift;

  require "general.pl";
  require "config.pl";
  require "action.pl";

  local(%args)=&ReadActionArgs($actionid);
  local($result)=&UpdateActionProgress($actionid,5,"Read Action Arguments");
  if ($result) {
    &UpdateActionProgress($actionid,-1,"Could not read arguments");
    return 1;
  }

  local(%mountinfo)=&GetMountInfo($args{MOUNT});
  local($isofile)=$SMBMOUNTDIR."/".$args{MOUNT}."/".$args{FILE1};
  if ($mountinfo{TYPE} eq "CDROM")
  {
    $isofile=$mountinfo{SHARE};
  }

  local($tempdir)=$TMPDIR."/tempmount.$$";
  local($unpackdir)=$TMPDIR."/unpackdir.$$";

  local($result)=&CreateDir($tempdir);
  if ($result)
  {
     &UpdateActionProgress($actionid,-2,"Could not create temporary directory $tempdir");
     return 2;
  }
  &UpdateActionProgress($actionid,10,"Created/checked temporary directory $tempdir");

  local($result)=&CreateDir($unpackdir);
  if ($result)
  {
     &UpdateActionProgress($actionid,-2,"Could not create temporary directory $unpackdir");
     return 2;
  }
  &UpdateActionProgress($actionid,10,"Created/checked temporary directory $tempdir");

  local($result)=&MountIso($isofile,$tempdir);
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not mount iso file $isofile on $tempdir");
    return 4;
  }
  &UpdateActionProgress($actionid,30,"Mounted iso file $isofile on $tempdir");

  #local($command)="/bin/rpm -Uvh $tempdir/VM*.rpm";
  #local($result)=&RunCommand($command,"Installing VMWare Tools rpm") ;
  #if ($result)
  #{
  #  &UpdateActionProgress($actionid,-2,"Could not install VMWareTools rpm");
  #  return 5;
  #}
  #&UpdateActionProgress($actionid,60,"Installed VMWareTools RPM");

  local($command)="tar -C $unpackdir -xvzf $tempdir/VM*gz";
  local($result)=&RunCommand($command,"Unpacking VMWare Tools") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not unpack VMWareTools tar.gz");
    return 5;
  }
  &UpdateActionProgress($actionid,60,"Unpacked VMWareTools tar.gz");

  local($command)="$unpackdir/vmware-tools-distrib/vmware-install.pl default";
  local($result)=&RunCommand($command,"Installing VMWare Tools") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not install VMWareTools tar.gz");
    return 5;
  }
  &UpdateActionProgress($actionid,65,"Installed VMWareTools tar.gz");


  local($command)="/bin/umount $tempdir";
  local($result)=&RunCommand($command,"Unmounting ISO file") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not unmount ISO File");
    return 5;
  }
  &UpdateActionProgress($actionid,70,"Unmounted ISO file");

  local($command)="rmdir $tempdir";
  local($result)=&RunCommand($command,"Removing tempdir $tempdir") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Could not remove tempdir $tempdir");
    return 5;
  }
  &UpdateActionProgress($actionid,80,"Removed tempdir $tempdir");

  #local($command)="/usr/bin/vmware-config-tools.pl --default";
  #local($result)=&RunCommand($command,"Configuring VMWare Tools with defaults") ;
  #if ($result)
  #{
  #  &UpdateActionProgress($actionid,-2,"Configured VMWare Tools");
  #  return 5;
  #}
  #&UpdateActionProgress($actionid,90,"Configured VMWareTools RPM");

  local($command)="rm -rf $unpackdir";
  local($result)=&RunCommand($command,"Removing vmware tools distribution") ;
  if ($result)
  {
    &UpdateActionProgress($actionid,-2,"Failed Removing VMWare Tools distribution files");
    return 5;
  }
  &UpdateActionProgress($actionid,90,"Removed VMWareTools Distribution files");

  &UpdateActionProgress($actionid,100,"Success, installed VMWare Tools");

 return 0;
}

sub GetActionInfo
{
  local($actionid)=shift;
  local(%info)=();
  $info{ACTIONID}=$actionid;
  local($actiondir)=$TMPDIR."/action.".$actionid;
  $info{PROGRESS}=0;
  $info{STATUS}="Unknown";
  $info{DESCRIPTION}="Unknown";
  $info{PID}=$actionid;
  if ( -f $actiondir."/action.desc")
  {
     $info{DESCRIPTION}=`cat $actiondir/action.desc`;
  }
  if ( -f $actiondir."/action.pid")
  {
    $info{PID}=`cat $actiondir/action.pid`;
  }
  local($progressfile)=$actiondir."/progress.dat";
  local($progressstring)=`cat $progressfile`;

  if ($progressstring =~ /([0-9]+)\/(.*)/)
  {
    $info{PROGRESS}=$1;
    $info{STATUS}=$2;
  }
  $info{RUNSTATUS}="Running";
  local(@result)=`ps -p $info{PID}`;
  if ($? ne 0)
  {
    $info{RUNSTATUS}="Not Running";
  }
  if ($info{PROGRESS} == 100)
  {
    $info{RUNSTATUS}="Completed";
  }
  local($atfile)=$actiondir."/at.out";
  local($atstatus)=`cat $atfile`;
  $info{TIME}="Unknown";
  $info{DATE}="Unknown";
  $info{TIMESTAMP}="Unknown";
  if ($atstatus =~ /job [0-9]+ at ([A-Za-z]+) ([A-Za-z]+) ([0-9]+) ([0-9\:]+) (.*)/)
  {
    %mon2num = qw(
      jan 01  feb 02  mar 03  apr 04 may 05 jun 06
      jul 07  aug 08  sep 09  oct 10 nov 11 dec 12
    );
    $info{DATE}=$5."-".$mon2num{lc($2)}."-".$3;
    $info{TIME}=$4;
    $info{TIMESTAMP}=$info{DATE}.".".$info{TIME};
  }
  
  return %info;
}

sub GetAllActionInfo
{
  local(%allactions)=();
  local($result)=opendir(DIR,$TMPDIR);
  while ($fn=readdir(DIR) )
  {
    if ($fn =~ /action.([0-9]+)/)
    {
      local($actionid)=$1;
      local(%info)=&GetActionInfo($actionid);
      $allactions{$info{TIMESTAMP}.".".$actionid}="$info{ACTIONID};$info{DESCRIPTION};$info{PROGRESS};$info{STATUS};$info{RUNSTATUS};$info{DATE};$info{TIME};$info{TIMESTAMP}";
    }
  }
  closedir(DIR);
  return %allactions;
}

sub DisplayActionList
{
  local(%actioninfo)=&GetAllActionInfo();
  print "<CENTER>\n";
  print "<H2>Action List</H2>";
  &PrintToolbar("View","Delete","Cleanup");
  print "<BR><BR>\n";
  print "<FORM NAME=ACTIONFORM>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=system>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=actions>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE=unknown>\n";
  print "<INPUT TYPE=HIDDEN NAME=actionid VALUE=unknown>\n";
  print "</FORM>\n";
  print "<script language='javascript' src='/js/table.js'></script>\n";
  print "<script language='javascript' src='/js/actionlist.js'></script>\n";
  print " <TABLE BORDER=1>\n";
  print "<TR CLASS=tableheader><TD>Action</TD><TD>Description</TD><TD>Progress</TD><TD>Status</TD><TD>Run status</TD><TD>Start Date</TD><TD>Start Time</TD></TR>\n";
  for $action (reverse(sort(keys(%actioninfo))))
  {
    local(@myinfo)=split(";",$actioninfo{$action});
    print "<TR onclick='SelectRow(this)' ID=$myinfo[0]>";
    print "<TD>$myinfo[0]</TD>\n";
    print "<TD>$myinfo[1]</TD>\n";
    print "<TD>$myinfo[2] %</TD>\n";
    print "<TD>$myinfo[3]</TD>\n";
    print "<TD>$myinfo[4]</TD>\n";
    print "<TD>$myinfo[5]</TD>\n";
    print "<TD>$myinfo[6]</TD>\n";
    #print "<TD>$myinfo[7]</TD>\n";
    print "</TR>\n";
  }
  print "</TABLE>\n";
  print "</CENTER>\n";
  
}

sub DeleteAction
{
  local($actionid)=shift;
  local($actiondir)=$TMPDIR."/action.".$actionid;
  local(%info)=&GetActionInfo($actionid);
  if ($info{RUNSTATUS} eq "Running")
  {
    &PrintError("Can not delete this action it is still running","Choose View and then Kill to stop the action first");
    return 0;
  } else {
    local($command)="rm -rf $actiondir";
    local($result)=&RunCommand($command,"Removing actiondir $actiondir");
    if ($result)
    {
      &PrintError("Could not delete action with id $actionid");
      return 0;
    } else {
      &DisplayActionList();
    }
  }
}


sub KillAction
{
  local($actionid)=shift;
  local($actiondir)=$TMPDIR."/action.".$actionid;
  local(%info)=&GetActionInfo($actionid);
  if ($info{RUNSTATUS} eq "Running")
  {
   local($command)="kill -9 $actionid";
   local($result)=&RunCommand($command,"Killing action with pid $actionid");
   if ($result)
   {
     &PrintError("Could not kill action $actionid");
   } else {
     &DisplayActionList();
   }
  } else {
   &DisplayActionList();
  }
}


sub ViewAction
{
  local($actionid)=shift;
  local($actiondir)=$TMPDIR."/action.".$actionid;
  print "<CENTER>\n";
  print "<H2>Action Information for $actionid</H2>";
  &PrintToolbar("Actionlist","Delete","Kill");
  print "<BR><BR>\n";
  print "<FORM NAME=ACTIONFORM>\n";
  print "<INPUT TYPE=HIDDEN NAME=module VALUE=system>\n";
  print "<INPUT TYPE=HIDDEN NAME=action VALUE=actions>\n";
  print "<INPUT TYPE=HIDDEN NAME=button VALUE=unknown>\n";
  print "<INPUT TYPE=HIDDEN NAME=actionid VALUE=$actionid>\n";
  print "</FORM>\n";
  print "<script language='javascript' src='/js/table.js'></script>\n";
  print "<script language='javascript' src='/js/viewaction.js'></script>\n";
  local(%info)=&GetActionInfo($actionid);
  print " <TABLE BORDER>\n";
  print "<TR><TD>Action ID</TD><TD>$info{ACTIONID}</TD>\n";
  print "<TR><TD>Description</TD><TD>$info{DESCRIPTION}</TD>\n";
  print "<TR><TD>Date</TD><TD>$info{DATE}</TD>\n";
  print "<TR><TD>Time</TD><TD>$info{TIME}</TD>\n";
  print "<TR><TD>Progress</TD><TD>$info{PROGRESS} %</TD>\n";
  print "<TR><TD>Status</TD><TD>$info{STATUS}</TD>\n";
  print "<TR><TD>Run Status</TD><TD>$info{RUNSTATUS}</TD>\n";
  print "<TR><TD>Progess Report</TD><TD><PRE>\n";
  local(@result)=`cat $actiondir/progress.log`;
  print @result;
  print "</PRE></TD></TR>\n";
  print "<TR><TD>Action Output</TD><TD><PRE>\n";
  local(@result)=`cat $actiondir/action.out`;
  print @result;
  print "</PRE></TD></TR>\n";
  print "<TR><TD>Arguments</TD><TD><PRE>\n";
  local(@result)=`cat $actiondir/arguments.dat`;
  print @result;
  print "</PRE></TD></TR>\n";
  print "<TR><TD>Perl script</TD><TD><PRE>\n";
  local(@result)=`cat $actiondir/action.pl`;
  print @result;
  print "</PRE></TD></TR>\n";
  print "</TABLE>\n";
  print "</CENTER>\n";

  return 0;
}

sub CleanupActions
{
  local(%allactions)=();
  local($result)=opendir(DIR,$TMPDIR);
  while ($fn=readdir(DIR) )
  {
    if ($fn =~ /action.([0-9]+)/)
    {
      local($actionid)=$1;
      local(%info)=&GetActionInfo($actionid);
      if ($info{RUNSTATUS} ne "Running")
      {
         local($actiondir)=$TMPDIR."/action.".$actionid;
         local($command)="rm -rf $actiondir";
         local($result)=&RunCommand($command,"Removing Action Directory $actiondir");
      }
    }
  }
  closedir(DIR);
  &DisplayActionList();
  return 0;
}

sub PXEConfig
{
 require "config.pl";

 local(@header)=&GetConfigFile($PXEHEADER);
 local(@menuitem)=&GetConfigFile($PXEMENUITEM);
 local(@submenuitem)=&GetConfigFile($PXESUBMENUITEM);
 local(@submenuheader)=&GetConfigFile($PXESUBMENUHEADER);

 print "<CENTER>\n";
 print "<H2>PXE Configuration</H2>\n";
 print "<FORM NAME='WIZARDFORM' METHOD='POST'>\n";
 print "<INPUT TYPE=HIDDEN NAME=module VALUE=system>\n";
 print "<INPUT TYPE=HIDDEN NAME=action VALUE=pxeconfig>\n";
 print "<INPUT TYPE=HIDDEN NAME=button VALUE=none>\n";
 print "<script language='javascript' src='/js/pxeconfig.js'></script>\n";
 &PrintToolbar("Apply","Cancel");
 print "<BR><BR>\n";
 print "<TABLE>\n";
 print "<TR><TD COLSPAN=3><H3>Header</H3>\n";
 print "<TR><TD COLSPAN=3><TEXTAREA ROWS=25 COLS=60 NAME=PXEHEADER>\n";
 print @header;
 print "</TEXTAREA></TD></TR>\n";
 print "<TR><TD COLSPAN=3><H3>Template Menu Item</H3>\n";
 print "<TR><TD COLSPAN=3><TEXTAREA ROWS=7 COLS=60 NAME=PXEMENUITEM>\n";
 print @menuitem;
 print "</TEXTAREA></TD></TR>\n";
 print "<TR><TD COLSPAN=3><H3>Subtemplate Menu Header</H3>\n";
 print "<TR><TD COLSPAN=3><TEXTAREA ROWS=7 COLS=60 NAME=PXESUBMENUHEADER>\n";
 print @submenuheader;
 print "</TEXTAREA></TD></TR>\n";
 print "<TR><TD COLSPAN=3><H3>Subtemplate Menu Item</H3>\n";
 print "<TR><TD COLSPAN=3><TEXTAREA ROWS=7 COLS=60 NAME=PXESUBMENUITEM>\n";
 print @submenuitem;
 print "</TEXTAREA></TD></TR>\n";
 print "<TR><TD COLSPAN=3><BR>SHA1 Password encoder</TD></TR>\n";
 print "<TR><TD><INPUT TYPE=TEXT SIZE=15 ID=PWD> <INPUT TYPE=BUTTON VALUE='encode ->' ONCLICK='Encode();'>\n";
 print "<INPUT TYPE=TEXT SIZE=40 ID=EPWD></TD></TR>\n";
 print "</TABLE>\n";
 print "</CENTER>\n";
 print "</FORM>\n";

}

sub ApplyPXEConfig
{

  local($tmpfile)=$TEMPDIR."/pxeheader.conf.$$";
  local($result)=open(PXEFILE,">$tmpfile");
  print PXEFILE $formdata{PXEHEADER};
  close(PXEFILE);

  local($command)="/usr/bin/dos2unix $tmpfile";
  local($result)=&RunCommand($command,"Forcing unix file format");

  local($result)=&RunCommand("cp $tmpfile $PXEHEADER","Copying temporary file |$tmpfile| to |$PXEHEADER|\n");
  if ($result)
  {
    &PrintError("Could not copy temporary file $tmpfile","to pxe config file $PXEHEADER");
    return 1;
  }
  unlink($tmpfile);

  local($tmpfile2)=$TEMPDIR."/pxemenuitem.conf.$$";
  local($result)=open(PXEMENUITEMFILE,">$tmpfile2");
  print PXEMENUITEMFILE $formdata{PXEMENUITEM};
  close(PXEMENUITEMFILE);

  local($command)="/usr/bin/dos2unix $tmpfile2";
  local($result)=&RunCommand($command,"Forcing unix file format");

  local($result)=&RunCommand("cp $tmpfile2 $PXEMENUITEM","Copying temporary file |$tmpfile2| to |$PXEMENUITEM|\n");
  if ($result)
  {
    &PrintError("Could not copy temporary file $tmpfile2","to pxe config file $PXEMENUITEM");
    return 1;
  }
  unlink($tmpfile2);

  local($tmpfile3)=$TEMPDIR."/pxesubmenuitem.conf.$$";
  local($result)=open(PXESUBMENUITEMFILE,">$tmpfile3");
  print PXESUBMENUITEMFILE $formdata{PXESUBMENUITEM};
  close(PXESUBMENUITEMFILE);

  local($command)="/usr/bin/dos2unix $tmpfile3";
  local($result)=&RunCommand($command,"Forcing unix file format");

  local($result)=&RunCommand("cp $tmpfile3 $PXESUBMENUITEM","Copying temporary file |$tmpfile3| to |$PXESUBMENUITEM|\n");
  if ($result)
  {
    &PrintError("Could not copy temporary file $tmpfile3","to pxe config file $PXESUBMENUITEM");
    return 1;
  }
  unlink($tmpfile3);

  local($tmpfile4)=$TEMPDIR."/pxesubmenuheader.conf.$$";
  local($result)=open(PXESUBMENUHEADERFILE,">$tmpfile4");
  print PXESUBMENUHEADERFILE $formdata{PXESUBMENUHEADER};
  close(PXESUBMENUHEADERFILE);

  local($command)="/usr/bin/dos2unix $tmpfile4";
  local($result)=&RunCommand($command,"Forcing unix file format");

  local($result)=&RunCommand("cp $tmpfile4 $PXESUBMENUHEADER","Copying temporary file |$tmpfile4| to |$PXESUBMENUHEADER|\n");
  if ($result)
  {
    &PrintError("Could not copy temporary file $tmpfile4","to pxe config file $PXESUBMENUHEADER");
    return 1;
  }
  unlink($tmpfile4);

  #local($result)=&WriteDefaultFile();
  require "templates.pl";
  local($result)=&PublishAllTemplates();
  if ($result)
  {
    &PrintError("Could not write PXE default file");
    return 1;
  }

  return 0;
}

1;
