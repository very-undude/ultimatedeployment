#!/bin/bash

# Check if we need to run the firstboot script
if [ -f /var/public/conf/firstboot.txt ]
then
  chvt 2
  /var/public/bin/setup.sh
  /usr/bin/systemctl restart getty@tty1.service
  chvt 1
fi

# Load the current network config into the /etc/issue
IPADDR=`cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep IPADDR= | awk '{print $2}' FS=\=`
cat /var/public/files/issue.tpl | sed "s/\[IPADDRESS\]/$IPADDR/g" > /var/public/files/issue

# Scan the current CD devices
/var/public/bin/scancd.pl

# Mount the mounts that are configured for on boot mounting
/var/public/bin/mountboottime.pl


