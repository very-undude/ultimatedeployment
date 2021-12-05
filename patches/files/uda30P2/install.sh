#!/bin/bash

# Copyright 2006-2021 Carl Thijssen

# This file is part of the Ultimate Deployment Appliance.
#
# Ultimate Deployment Appliance is free software; you can redistribute
# it and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# Ultimate Deployment Appliance is distributed in the hope that it will
# be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

PATCHDIR=$1
PATCHNAME=uda30P2
BUILD=`cat $PATCHDIR/build.dat`
ASSERTFILE1=/var/public/conf/version/uda_30_143.dat
SIGNATURE=/var/public/conf/version/uda_30_${BUILD}.dat
HTTPDCONF=/var/public/files/httpd.conf
DHCPDCONF=/var/public/files/dhcpd.conf
DHCPDCONFADD=$PATCHDIR/dhcpd.add

echo Checking if we can install this patch
if [ ! -f $ASSERTFILE1 ]
then
  echo Patch $PATCHNAME can only be installed on build 143
  exit 0
fi

echo Checking if we need to install this patch
if [ -f $SIGNATURE ]
then
  echo Patch $PATCHNAME is already installed on this system
  exit 0
fi

echo Stopping services
systemctl stop httpd
systemctl stop dhcpd

echo Installing new packages
rpm -ivh $PATCHDIR/patch-2.7.1-10.el7_5.x86_64.rpm

echo Untarring the new files
tar -C / -xvzf $PATCHDIR/var.tgz --exclude httpd.conf

# Changing ownerships to the untarred files and directories
tar -tzf $PATCHDIR/var.tgz | while read filename
do
  chown apache:apache /$filename
  DIRNAME=`dirname /$filename`
  chown -v apache:apache $DIRNAME
done

echo Creating new directories
mkdir /var/public/www/ipxe/templates
mkdir /var/public/www/ipxe/mac
chown apache:apache /var/public/www/ipxe/templates
chown apache:apache /var/public/www/ipxe/mac
  
echo Making links to the ova files
ls -1 /var/public/www/ova | while read name
do
  mkdir /local/ova/builtin/$name
  chmod 755 /local/ova/builtin/$name
  ls -1 /var/public/www/ova/$name | while read ovafile
  do
    if [ -L /local/ova/builtin/$name/$ovafile ]
    then
      rm -f /local/ova/builtin/$name/$ovafile
    fi
    ln -sf /var/public/www/ova/$name/$ovafile /local/ova/builtin/$name/$ovafile
  done
done
chown -hR apache:apache /local/ova

echo Making changes to the httpd.conf
cp $HTTPDCONF $PATCHDIR/httpd.conf
sed -i -E '/\s*Options\s+Indexes\s+FollowSymLinks\s*$/a\ \ \ \ AddHandler cgi-script .cgi' $PATCHDIR/httpd.conf
sed -i -E 's/\s*Options\s+Indexes\s+FollowSymLinks\s*$/    Options Indexes FollowSymLinks ExecCGI/g' $PATCHDIR/httpd.conf
echo These are the changes made to $HTTPDCONF
echo ===
diff -u $PATCHDIR/httpd.conf $HTTPDCONF | tee $PATCHDIR/httpd.patch
echo ===
echo Run the following command to undo changes to the httpd.conf:
echo patch -u $HTTPDCONF $PATCHDIR/httpd.patch
cp $PATCHDIR/httpd.conf $HTTPDCONF

echo Making changes to the dhcpd.conf
cat $DHCPDCONFADD > $PATCHDIR/dhcpd.conf
IPADDR=`cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep IPADDR | cut -f2 -d=`
sed -i -E "s/\[UDA_IPADDR\]/$IPADDR/g" $PATCHDIR/dhcpd.conf
cat $DHCPDCONF >> $PATCHDIR/dhcpd.conf
sed -i 's/PXEClient/DISABLED/g' $PATCHDIR/dhcpd.conf
echo These are the changes made to the $DHCPDCONF
echo ===
diff -u $PATCHDIR/dhcpd.conf $DHCPDCONF | tee $PATCHDIR/dhcpd.patch
echo ===
echo Run the following command to undo changes to the dhcpd.conf:
echo patch -u $DHCPDCONF $PATCHDIR/dhcpd.patch
cp $PATCHDIR/dhcpd.conf $DHCPDCONF

echo Writing out the signature
echo VERSION=$PATCHNAME > $SIGNATURE

echo  Starting up services
systemctl start dhcpd
systemctl start httpd

echo Adding efi information to template files
grep -L PUBLISHEFI /var/public/conf/templates/*.dat | while read template
do
  
  echo Changing ESX7 templates
  grep -l -e "^OS=esx7$" -e "^OS=esx6$" -e "^OS=esx5$" $template | while read ostemplate
  do
    echo Adding EFI parameters to template config $ostemplate
    cat $PATCHDIR/esx7.efi >> $ostemplate
  done

  echo Changing Windows templates
  grep -l "^OS=windows7$" $template | while read ostemplate
  do
    echo Adding EFI parameters to template config $ostemplate
    cat $PATCHDIR/windows7.efi >> $ostemplate
    TEMPLATE=`grep "^TEMPLATE=" $ostemplate | awk '{print $2}' FS=\=`
    FLAVOR=`grep "^FLAVOR=" $ostemplate | awk '{print $2}' FS=\=`
    echo Flavor = $FLAVOR
    EXTRADIR=`grep "^DIR_1=" /var/public/conf/os/$FLAVOR.dat | awk '{print $2}' FS=\=`
    echo extradir = $EXTRADIR
    grep -i "windows 11" $EXTRADIR/install.xml > /dev/null
    if [ $? -eq 0 ]
    then
      echo Found windows 11 template, changing template config file
      sed -i "/ProtectYourPC/a \ \ \ \ \ \ \ \ \ \ \ <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>\n" /var/public/conf/templates/$TEMPLATE.cfg
    fi
  done

  echo Changing Centos and Redhat templates
  grep -l -e "^OS=centos7$" -e "^OS=centos8$" -e "^OS=redhat7$" -e "^OS=redhat8$" $template | while read ostemplate
  do
    echo Adding EFI parameters to template config $ostemplate
    cat $PATCHDIR/centos7.efi >> $ostemplate
  done

done

echo Republishing all templates
chmod 755 $PATCHDIR/republish.pl
$PATCHDIR/republish.pl
echo Rebuilding windows wim files
chmod 755 $PATCHDIR/rebuildwim.pl
$PATCHDIR/rebuildwim.pl

echo Done
