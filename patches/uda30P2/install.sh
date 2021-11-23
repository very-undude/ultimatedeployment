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
BUILD=164
VERSIONFILE=/var/public/conf/version/uda_30_${BUILD}.dat
HTTPDCONF=/var/public/files/httpd.conf
DHCPDCONF=/var/public/files/dhcpd.conf
DHCPDCONFADD=$PATCHDIR/dhcpd.add

# do we need to install this patch?
if [ -f $VERSIONFILE ]
then
  echo Patch $PATCHNAME is already installed on this system
  exit 0
fi

systemctl stop httpd
systemctl stop dhcpd

# Copy old files out of the way
cp $HTTPDCONF $PATCHDIR/httpd.conf

tar -C / -xvzf $PATCHDIR/var.tgz 

tar -tzf $PATCHDIR/var.tgz | while read filename
do
  chown apache:apache /$filename
  DIRNAME=`dirname /$filename`
  chown apache:apache $DIRNAME
done

mkdir /var/public/www/ipxe/templates
mkdir /var/public/www/ipxe/mac
chown apache:apache /var/public/www/ipxe/templates
chown apache:apache /var/public/www/ipxe/mac
  

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

cp $PATCHDIR/httpd.conf $HTTPDCONF
sed -i -E '/\s*Options\s+Indexes\s+FollowSymLinks\s*$/a AddHandler cgi-script .cgi' $HTTPDCONF
sed -i -E 's/\s*Options\s+Indexes\s+FollowSymLinks\s*$/  Options Indexes FollowSymLinks ExecCGI/g' $HTTPDCONF

# Change current dhcpd add a new part for efi
cp $DHCPDCONF $DHCPDCONF.pre.$PATCHNAME
cp $DHCPDCONF $PATCHDIR/dhcpd.conf
IPADDR=`cat /etc/sysconfig/network-scripts/ifcfg-eth0 | grep IPADDR | cut -f2 -d=`
sed -i -E "s/\[UDA_IPADDR\]/$IPADDR/g" $DHCPDCONFADD
cat $DHCPDCONFADD > $DHCPDCONF
cat $PATCHDIR/dhcpd.conf | sed 's/PXEClient/DISABLED/g' >> $DHCPDCONF

echo VERSION=$PATCHNAME > $VERSIONFILE
systemctl start dhcpd
systemctl start httpd

