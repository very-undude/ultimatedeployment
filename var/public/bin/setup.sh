#!/bin/bash

COMMAND=$0
FIRSTBOOTFILE=/var/public/conf/firstboot.txt
BANNERFILE=/etc/issue
NETWORKFILE=/etc/sysconfig/network
ETH0FILE=/etc/sysconfig/network-scripts/ifcfg-eth0
SSHDCONFIG=/etc/ssh/sshd_config
RESOLV=/etc/resolv.conf
LOGFILE=/var/public/log/firstboot.log

#Initialisation
if [ -f $RESOLV ]
then
  rm -f $RESOLV
fi
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/test$$
trap "rm -f $tempfile" 0 1 2 5 15
passwordstatus=FIRST

# Default Values
HOSTNAME=`cat $ETH0FILE | grep HOSTNAME | awk '{print $2}' FS=\=`
IP=`cat $ETH0FILE | grep IPADDR | awk '{print $2}' FS=\=`
NETMASK=`cat $ETH0FILE | grep NETMASK | awk '{print $2}' FS=\=`
GATEWAY=`cat $NETWORKFILE | grep GATEWAY | awk '{print $2}' FS=\=`
PASSWORD=""
PASSWORD2=""
DHCP=OFF
NFS=ON
SAMBA=ON
TFTP=ON
HTTP=ON
BINL=ON
SSH=ON

# Text strings
BACKTITLE="Ultimate Deployment Appliance 3.0 Setup"
WELCOMETEXT="\nThis is the setup wizard for the Ultimate Deployment Appliance 3.0\n\nUntil you have comleted the wizard the UDA will not have a network connection. Once you are done with the wizard you can use the web-interface to change the settings you provided here. You can press ESC to leave the wizard, but you will have to manually configure the UDA then or rerun the wizard."
HOSTNAMETEXT="\nEnter the hostname for this appliance.\n\nOnly enter the hostname, not the domainname. You will be able to set the DNS settings from the web-interface once web-server is up and running after completion of this wizard."
IPTEXT="\nEnter the network IP configuration information\n\nUDA can currently only use a static IP-address"
DHCPTEXT="\nEnter the subnet that you want to be a DHCP server for.\nAlso enter the range of IP addresses that you want offer to systems requesting an address"
SERVICESTEXT="\nWhich services should be run on startup? DHCP is default off. Either enable the DHCP service on UDA or configure another DHCP server on your network to point to the UDA as a boot-server.\n\n"
NOMATCHTEXT="\nThe passwords you provided do not match, please try again."
EMPTYTEXT="\nThe password you provided is empty, please try again."
PASSWORD1TEXT="\nEnter the password to be used for the admin web user and the root user.\n\n When this wizard is completed you can use this password to login to the web interface with username 'admin'.\n\nYou can also login on the console login prompt with user 'root' with this password. If you enable SSH you can login as 'root' over the network with this password."
PASSWORD2TEXT="\nPlease retype the password to confirm.\n\n\n\n\n\n"
APPLYTEXT="\nDo you want to apply the changes?"
ESCAPETEXT1="You have not completed the setup wizard"
ESCAPETEXT2="you may rerun the wizard by entering $COMMAND"
DONETEXT1="\nThank you for using the Ultimate Deployment Appliance\n\nYou can now browse to\n\n         http://"
DONETEXT2="\n\nto see the Getting Started guide or login to the webinterface as 'admin' using the password you have just set with this wizard\n\nTo login at the console login promt use 'root' also with the same password you just provided\n\nHappy deploying!"
INVALIDIPTEXT="\nThe IP address you typed is not a valid IP address"
INVALIDNETMASKTEXT="\nThe netmask you typed is not a valid netmask"
INVALIDGATEWAYTEXT="\nThe gateway IP address you typed is not a valid IP address"
INVALIDDHCPSUBNET="\nThe subnet if not a valid subnet address"
INVALIDDHCPNETMASK="\nThe netmask is not a valid netmaks"
INVALIDDHCPRANGESTART="\nThe range start is not valid"
INVALIDDHCPRANGEEND="\nThe range end is not valid"

function escape ()
{
  clear 
  echo
  echo $ESCAPETEXT1
  echo $ESCAPETEXT2
  echo
  exit
}

############################  WIZARD UI #########################
function welcome ()
{
  dialog --backtitle "$BACKTITLE" --title " Welcome " --msgbox  "$WELCOMETEXT" 18 60
  if [ $? -eq 255 ] ; then escape ; fi
  return 0
}

function dlghostname ()
{
  dialog --backtitle "$BACKTITLE" --title " Hostname " --inputbox  "$HOSTNAMETEXT" 18 60 "$HOSTNAME" 2> $tempfile
  retval=$?
  case $retval in
    0)
      HOSTNAME=`cat $tempfile`
      ;;
    1)
      button=CANCEL
      ;;
    255)
      escape
      ;;
  esac
  return 0
}

function isvalidip ()
{
  echo $1 | grep -E ^[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}\.[0-9]\{1,3}$ > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    PART1=`echo $1 | awk '{print $1}' FS=\.`
    PART2=`echo $1 | awk '{print $2}' FS=\.`
    PART3=`echo $1 | awk '{print $3}' FS=\.`
    PART4=`echo $1 | awk '{print $4}' FS=\.`
    if  [[ $PART1 -le 255 && $PART1 -ge 0  &&  $PART2 -le 255 && $PART2 -ge 0 &&  $PART3 -le 255 && $PART3 -ge 0 &&  $PART4 -le 255 && $PART4 -ge 0  ]]
    then
     echo OK
    else
      echo INVALIDRANGE
    fi
  else
    echo SYNTAXERROR
  fi
}



function ipconfig ()
{
  DONE=FALSE
  while [[ "$DONE" == "FALSE" ]]
  do
    exec 3>&1
    value=`dialog --backtitle "$BACKTITLE" --title " IP Configuration " --form "$IPTEXT" 18 60 10 \
		  "IP address" 2 3 "$IP" 2 20 15 15 \
		  "Netmask"    4 3 "$NETMASK"  4 20 15 15 \
		  "Gateway"    6 3 "$GATEWAY" 6 20 15 15 2>&1 1>&3`
    returncode=$?
    exec 3>&-
    if [ $returncode -eq 255 ] ; then escape ; fi

    show=`echo "$value" |sed -e 's/$/:/' | tr -d [:space:] `
    IP=`echo $show | awk '{print $1}' FS=:`
    NETMASK=`echo $show | awk '{print $2}' FS=:`
    GATEWAY=`echo $show | awk '{print $3}' FS=:`

    IPOK=$(isvalidip $IP)
    if [ "$IPOK" == "OK" ]
    then
      NETMASKOK=$(isvalidip $NETMASK)
      if [ "$NETMASKOK" == "OK" ]
      then
        GATEWAYOK=$(isvalidip $GATEWAY)
        if [[ "$GATEWAY" != "" && "$GATEWAYOK" != "OK" ]]
        then
          dialog --backtitle "$BACKTITLE" --colors --title " \Zb\Z1ERROR\Zn " --msgbox  "$INVALIDGATEWAYTEXT" 10 30
          if [ $? -eq 255 ] ; then escape ; fi
        else
          DONE=TRUE
        fi
      else
        dialog --backtitle "$BACKTITLE" --colors --title " \Zb\Z1ERROR\Zn " --msgbox  "$INVALIDNETMASKTEXT" 10 30
        if [ $? -eq 255 ] ; then escape ; fi
      fi
    else
      dialog --backtitle "$BACKTITLE" --colors --title " \Zb\Z1ERROR\Zn " --msgbox  "$INVALIDIPTEXT" 10 30
      if [ $? -eq 255 ] ; then escape ; fi
    fi
  done
  return 0
}

function services ()
{
  exec 3>&1
  servicestring=`dialog --backtitle "$BACKTITLE" --title " Services " --checklist "$SERVICESTEXT" 18 60 7  \
		DHCP "(For PXE booting)" $DHCP \
		TFTP "(For PXE booting) " $TFTP \
		HTTP "(For webinterface and kickstart)" $HTTP \
		SAMBA "(For hosting windows WDS files)" $SAMBA  \
		BINL "(For WDS queries)" $BINL  \
		NFS "(For hosting Solaris Jumpstart files)" $NFS \
		SSH "(For logging in remotely to the UDA)" $SSH 2>&1 1>&3`
  returncode=$?
  exec 3>&-
  if [ $returncode -eq 255 ] ; then escape ; fi

  echo $servicestring | grep DHCP >/dev/null; if [ $? -eq 0 ] ; then DHCP=ON ;  else DHCP=OFF ; fi
  echo $servicestring | grep TFTP >/dev/null; if [ $? -eq 0 ] ; then TFTP=ON ; else TFTP=OFF ; fi
  echo $servicestring | grep HTTP >/dev/null; if [ $? -eq 0 ] ; then HTTP=ON ; else HTTP=OFF ; fi
  echo $servicestring | grep SAMBA >/dev/null; if [ $? -eq 0 ] ; then SAMBA=ON ; else SAMBA=OFF ; fi
  echo $servicestring | grep NFS >/dev/null; if [ $? -eq 0 ] ; then NFS=ON ; else NFS=OFF ; fi
  echo $servicestring | grep SSH >/dev/null; if [ $? -eq 0 ] ; then SSH=ON ; else SSH=OFF ; fi
  echo $servicestring | grep BINL >/dev/null; if [ $? -eq 0 ] ; then BINL=ON ; else BINL=OFF ; fi
  return 0
}


function dhcpconfig
{
  # Safe assumptions for DHCP settings
  DHCPNETMASK=$NETMASK
  NW=`ipcalc -n $IP $NETMASK | cut -f2 -d=`
  DHCPSUBNET=$NW
  NW1=`echo $NW | cut -f1 -d.` ; NW2=`echo $NW | cut -f2 -d.` ; NW3=`echo $NW | cut -f3 -d.` ;  NW4=`echo $NW | cut -f4 -d.`
  BNEXTIPNW=`echo "obase=2 ; ibase=10 ; 256 * 256 * 256 * $NW1 + 256 * 256 * $NW2 + 256 * $NW3 + $NW4 + 1" | bc`
  NEXTIPNW4=`echo "obase=10 ; ibase=2 ; $BNEXTIPNW % 100000000" | bc`
  NEXTIPNW3=`echo "obase=10 ; ibase=2 ; ( $BNEXTIPNW % 10000000000000000 ) / 100000000 " | bc`
  NEXTIPNW2=`echo "obase=10 ; ibase=2 ; ( $BNEXTIPNW % 1000000000000000000000000 ) / 10000000000000000 " | bc`
  NEXTIPNW1=`echo "obase=10 ; ibase=2 ; ( $BNEXTIPNW ) / 1000000000000000000000000 " | bc`
  DHCPRANGESTART=$NEXTIPNW1.$NEXTIPNW2.$NEXTIPNW3.$NEXTIPNW4

  BC=`ipcalc -b $IP $NETMASK | cut -f2 -d=`
  BC1=`echo $BC | cut -f1 -d.` ; BC2=`echo $BC | cut -f2 -d.` ; BC3=`echo $BC | cut -f3 -d.` ; BC4=`echo $BC | cut -f4 -d.`
  BNEXTIPBC=`echo "obase=2 ; ibase=10 ; 256 * 256 * 256 * $BC1 + 256 * 256 * $BC2 + 256 * $BC3 + $BC4 - 1" | bc`
  NEXTIPBC4=`echo "obase=10 ; ibase=2 ; $BNEXTIPBC % 100000000" | bc`
  NEXTIPBC3=`echo "obase=10 ; ibase=2 ; ( $BNEXTIPBC % 10000000000000000 ) / 100000000 " | bc`
  NEXTIPBC2=`echo "obase=10 ; ibase=2 ; ( $BNEXTIPBC % 1000000000000000000000000 ) / 10000000000000000 " | bc`
  NEXTIPBC1=`echo "obase=10 ; ibase=2 ; ( $BNEXTIPBC ) / 1000000000000000000000000 " | bc`
  DHCPRANGEEND=$NEXTIPBC1.$NEXTIPBC2.$NEXTIPBC3.$NEXTIPBC4

  if [[ "$DHCP" == "ON" ]]
  then

  DONE=FALSE

  while [[ "$DONE" == "FALSE" ]]
  do
    exec 3>&1
    value=`dialog --backtitle "$BACKTITLE" --title " DHCP Configuration " --form "$DHCPTEXT" 18 60 10 \
                  "Subnet" 2 3 "$DHCPSUBNET" 2 15 15 15 \
                  "Netmask"    4 3 "$DHCPNETMASK"  4 15 15 15 \
                  "Range Start"  6 3 "$DHCPRANGESTART" 6 15 15 15 \
                  "        End"  8 3  "$DHCPRANGEEND" 8 15 15 15 \
				2>&1 1>&3`
    returncode=$?
    exec 3>&-
    if [ $returncode -eq 255 ] ; then escape ; fi
    show=`echo "$value" |sed -e 's/$/:/' | tr -d [:space:] `
    DHCPSUBNET=`echo $show | awk '{print $1}' FS=:`
    DHCPNETMASK=`echo $show | awk '{print $2}' FS=:`
    DHCPRANGESTART=`echo $show | awk '{print $3}' FS=:`
    DHCPRANGEEND=`echo $show | awk '{print $4}' FS=:`

    DHCPSUBNETOK=$(isvalidip $DHCPSUBNET)
    if [ "$DHCPSUBNETOK" == "OK" ]
    then
      DHCPNETMASKOK=$(isvalidip $DHCPNETMASK)
      if [ "$DHCPNETMASKOK" == "OK" ]
      then
        DHCPRANGESTARTOK=$(isvalidip $DHCPRANGESTART)
        if [[ "$DHCPRANGESTARTOK" == "OK" ]]
        then
          DHCPRANGEENDOK=$(isvalidip $DHCPRANGEEND)
          if [[ "$DHCPRANGEENDOK" == "OK" ]]
          then
            DONE=TRUE
          else
            dialog --backtitle "$BACKTITLE" --colors --title " \Zb\Z1ERROR\Zn " --msgbox  "$INVALIDDHCPRANGEEND" 10 30
            if [ $? -eq 255 ] ; then escape ; fi
          fi
        else
          dialog --backtitle "$BACKTITLE" --colors --title " \Zb\Z1ERROR\Zn " --msgbox  "$INVALIDDHCPRANGESTART" 10 30
          if [ $? -eq 255 ] ; then escape ; fi
        fi
      else
        dialog --backtitle "$BACKTITLE" --colors --title " \Zb\Z1ERROR\Zn " --msgbox  "$INVALIDDHCPNETMASK" 10 30
        if [ $? -eq 255 ] ; then escape ; fi
      fi
    else
      dialog --backtitle "$BACKTITLE" --colors --title " \Zb\Z1ERROR\Zn " --msgbox  "$INVALIDDHCPSUBNET" 10 30
      if [ $? -eq 255 ] ; then escape ; fi
    fi
  done

  fi

  return 0
}

function password ()
{
  while [[ "$passwordstatus" == "FIRST"  ||  "$PASSWORD" != "$PASSWORD2" || "$PASSWORD" == "" ]]
  do

    if [[ "$passwordstatus" != "FIRST" && "$PASSWORD" != "" ]]
    then
      dialog --backtitle "$BACKTITLE" --colors --title " \Zb\Z1ERROR\Zn " --msgbox  "$NOMATCHTEXT" 10 30
      if [ $? -eq 255 ] ; then escape ; fi
    fi
    passwordstatus=NOTFIRST

    dialog --backtitle "$BACKTITLE" --title " Password " --insecure --passwordbox  "$PASSWORD1TEXT" 18 60 "" 2>$tempfile
    retval=$?
    case $retval in
      0)
        PASSWORD=`cat $tempfile`
        ;;
      1)
        ;;
      255)
        escape
        ;;
    esac

    if [ "$PASSWORD" == "" ]
    then
      dialog --backtitle "$BACKTITLE" --colors --title " \Zb\Z1ERROR\Zn " --msgbox  "$EMPTYTEXT" 10 30
      if [ $? -eq 255 ] ; then escape ; fi
    else
        dialog --backtitle "$BACKTITLE" --title " Confirm password " --insecure --passwordbox  "$PASSWORD2TEXT" 18 60 "" 2>$tempfile
        retval=$?
        case $retval in
          0)
            PASSWORD2=`cat $tempfile`
            ;;
          1)
            ;;
          255)
            escape
           ;;
        esac
    fi
  done
  return 0
}

function applyyesno ()
{
  GATEWAYDISPLAYTEXT="[EMPTY]"
  if [ "$GATEWAY" != "" ]
  then
    GATEWAYDISPLAYTEXT=$GATEWAY
  fi
  PASSWORDDISPLAYTEXT=`echo $PASSWORD | tr [:print:] \*`

  APPLYTEXT="$APPLYTEXT\n\n\
           Hostname:            $HOSTNAME\n\
           IP-address:          $IP\n\
           Netmask:             $NETMASK\n\
           Gateway:             $GATEWAYDISPLAYTEXT\n\
           root/admin password: $PASSWORDDISPLAYTEXT\n\
           Services:\n
           DHCP:   $DHCP\n\
           TFTP:   $TFTP        SSH:   $SSH\n\
           HTTP:   $HTTP        NFS:   $NFS\n\
           BINL:   $BINL        SAMBA: $SAMBA\n"


  dialog --backtitle "$BACKTITLE" --title " Apply " --yesno  "$APPLYTEXT" 18 60
  case $? in
    0)
      # Yes chosen do nothing and continue after the case
    ;;
    1)
      escape
    ;;
    255)
      escape
    ;;
  esac
 return 0
}

function apply ()
{
  echo 5 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nConfiguring interface eth0 " 18 60 
  echo DEVICE=eth0          > $ETH0FILE
  echo BOOTPROTO=static     >> $ETH0FILE
  echo ONBOOT=yes           >> $ETH0FILE
  echo NETMASK=$NETMASK     >> $ETH0FILE
  echo IPADDR=$IP           >> $ETH0FILE

  echo NETWORKING=yes       > $NETWORKFILE
  echo NETWORKING_IPV6=yes  >> $NETWORKFILE
  echo HOSTNAME=$HOSTNAME   >> $NETWORKFILE
  echo GATEWAY=$GATEWAY     >> $NETWORKFILE

  echo 10 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nStarting network " 18 60
  systemctl enable network >> $LOGFILE 2>&1
  /etc/init.d/network stop >> $LOGFILE 2>&1
  # /etc/init.d/vmware-tools restart >/dev/null
  /etc/init.d/network start >> $LOGFILE 2>&1

  echo 15 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nSetting hostname " 18 60
  hostname $HOSTNAME  >> $LOGFILE 2>&1

  echo 20 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nSetting root password" 18 60
  echo $PASSWORD | passwd root --stdin > /dev/null

  echo 25 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nSetting webuser admin password" 18 60
  WEBPWDHASH=`echo $PASSWORD | openssl passwd -stdin`
  echo admin:$WEBPWDHASH > /var/public/conf/passwd 
  chown apache:apache /var/public/conf/passwd > /dev/null

  echo 27 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nCreating GPG key" 18 60
  rngd -r /dev/urandom > /dev/null 2>&1
  gpg --batch --gen-key /var/public/files/gpgkey.info > /var/public/log/gpgkey.log 2>&1
  
  echo 30 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nWriting initial DHCP configuration" 18 60
  cat /var/public/files/dhcpd.tpl | sed -e "s/\[UDA_IPADDR\]/$IP/g" > /var/public/tmp/dhcpd.conf.1
  cat /var/public/tmp/dhcpd.conf.1 | sed -e "s/\[UDA_DHCPSUBNET\]/$DHCPSUBNET/g" > /var/public/tmp/dhcpd.conf.2
  cat /var/public/tmp/dhcpd.conf.2 | sed -e "s/\[UDA_DHCPNETMASK\]/$DHCPNETMASK/g" > /var/public/tmp/dhcpd.conf.3
  cat /var/public/tmp/dhcpd.conf.3 | sed -e "s/\[UDA_DHCPRANGESTART\]/$DHCPRANGESTART/g" > /var/public/tmp/dhcpd.conf.4
  cat /var/public/tmp/dhcpd.conf.4 | sed -e "s/\[UDA_DHCPRANGEEND\]/$DHCPRANGEEND/g" > /var/public/files/dhcpd.conf
  rm /var/public/tmp/dhcpd.conf.1
  rm /var/public/tmp/dhcpd.conf.2
  rm /var/public/tmp/dhcpd.conf.3
  rm /var/public/tmp/dhcpd.conf.4

  if [ "$DHCP" == "ON" ]
  then
    echo 30 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nConfiguring DHCP service" 18 60
    /usr/sbin/chkconfig --level 3 dhcpd on >> $LOGFILE 2>&1
    echo 35 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nStarting DHCP service" 18 60

    /usr/sbin/service dhcpd start >> $LOGFILE 2>&1
  else
    echo 35 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nDisabling DHCP service" 18 60
    /usr/sbin/chkconfig --level 3 dhcpd off >> $LOGFILE 2>&1
  fi

  if [ "$NFS" == "ON" ]
  then
    echo 40 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nConfiguring NFS service" 18 60
    systemctl enable rpcbind >> $LOGFILE 2>&1
    systemctl enable nfs-server >> $LOGFILE 2>&1
    systemctl enable nfs-lock >> $LOGFILE 2>&1
    systemctl enable nfs-idmap >> $LOGFILE 2>&1

    echo 45 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nStarting NFS service" 18 60
    systemctl start rpcbind >> $LOGFILE 2>&1
    systemctl start nfs-server >> $LOGFILE 2>&1
    systemctl start nfs-lock >> $LOGFILE 2>&1
    systemctl start nfs-idmap >> $LOGFILE 2>&1
  else
    echo 45 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nDisabling NFS service" 18 60
    systemctl disable rpcbind >> $LOGFILE 2>&1
    systemctl disable nfs-server >> $LOGFILE 2>&1
    systemctl disable nfs-lock >> $LOGFILE 2>&1
    systemctl disable nfs-idmap >> $LOGFILE 2>&1
  fi

  if [ "$TFTP" == "ON" ]
  then
    echo 50 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nConfiguring TFTP service" 18 60
    systemctl enable tftpd >> $LOGFILE 2>&1
    echo 55 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nStarting TFTP service" 18 60
    systemctl start tftpd >> $LOGFILE 2>&1
  else
    echo 55 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nDisabling TFTP service" 18 60
    systemctl disable tftpd >> $LOGFILE 2>&1
  fi

  if [ "$HTTP" == "ON" ]
  then
    echo 60 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nConfiguring HTTP service" 18 60 
    /usr/sbin/chkconfig --level 3 httpd on >> $LOGFILE 2>&1
    echo 65 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nStarting HTTP service" 18 60
    /usr/sbin/service httpd start >> $LOGFILE 2>&1
  else
    echo 65 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nDisabling HTTP service" 18 60
    /usr/sbin/chkconfig --level 3 httpd off >> $LOGFILE 2>&1
  fi

  if [ "$SAMBA" == "ON" ]
  then
    echo 70 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nConfiguring SAMBA service" 18 60 
    /usr/sbin/chkconfig --level 3 smb on >> $LOGFILE 2>&1
    echo 75 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nStarting SAMBA service" 18 60 
    /usr/sbin/service smb start  >> $LOGFILE 2>&1
  else
    echo 75 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nDisabling SAMBA service" 18 60 
    /usr/sbin/chkconfig --level 3 smb off >> $LOGFILE 2>&1
  fi

  echo 77 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nWriting the new banner"  18 60 
  echo Welcome to the Ultimate Deployment Appliance 3.0   > $BANNERFILE
  echo You can access the web interface at:               >> $BANNERFILE
  echo http://$IP                                         >> $BANNERFILE
  echo                                                    >> $BANNERFILE
  
  echo 79 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nModifying SSH banner"  18 60 
  grep -v Banner $SSHDCONFIG > $SSHDCONFIG
  echo Banner $BANNERFILE >> $SSHDCONFIG

  if [ "$SSH" == "ON" ]
  then
    echo 80 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nConfiguring SSH service" 18 60
    /usr/sbin/chkconfig --level 2345 sshd on >> $LOGFILE 2>&1
    echo 85 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nStarting SSH service" 18 60
    /usr/sbin/service sshd start >> $LOGFILE 2>&1 
  else
    echo 85 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nDisabling SSH service" 18 60 
    /usr/sbin/chkconfig --level 2345 sshd off >> $LOGFILE 2>&1
  fi

  if [ "$BINL" == "ON" ]
  then
    echo 80 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nConfiguring BINL service" 18 60
    /usr/sbin/chkconfig --level 2345 binl on >> $LOGFILE 2>&1
    echo 85 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nStarting BINL service" 18 60
    /usr/sbin/service binl start >> $LOGFILE 2>&1
  else
    echo 85 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nDisabling BINL service" 18 60 
    /usr/sbin/chkconfig --level 2345 binl off >> $LOGFILE 2>&1
  fi

  echo 95 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nCreating loop devices" 18 60 
  seq 0 255 | while read loopnum
  do
    if [ ! -b /dev/loop$loopnum ]
    then
      mknod /dev/loop$loopnum b 7 $loopnum -m640 >> $LOGFILE 2>&1
    fi
  done

  echo 98 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nRe-enabling console logging during boot" 18 60 
  sed -r -i -c 's/console=ttyS0/console=tty0 console=ttyS0/g' /boot/grub2/grub.cfg

  echo 99 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nRemoving firstboot tag" 18 60 
  if [ -f $FIRSTBOOTFILE ]
  then
   /bin/rm $FIRSTBOOTFILE 
  fi

  # echo 100 | dialog --backtitle "$BACKTITLE" --title " Progress " --gauge "\nRemoving autologin for root" 18 60 

  return 0
}

function thankyou ()
{
  clear
  dialog --clear
  DONETEXT=$DONETEXT1$IP$DONETEXT2
  dialog --backtitle "$BACKTITLE" --title " Done " --msgbox "$DONETEXT" 18 60
  clear
  return 0
}

### find autoconfig
AUTOCONFIG=OFF
mkdir /mnt/setup_cdrom
mount -t iso9660 /dev/cdrom /mnt/setup_cdrom
if [ -f /mnt/setup_cdrom/setupuda.txt ]
then
  . /mnt/setup_cdrom/setupuda.txt
fi
umount /mnt/setup_cdrom
rmdir /mnt/setup_cdrom

if [ "$AUTOCONFIG" != "ON" ]
then
  welcome
  dlghostname
  ipconfig
  services
  dhcpconfig
  password
  applyyesno
  apply
  thankyou
else
  apply
fi

exit 0
