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
PATCHNAME=uda30P3
BUILD=`cat $PATCHDIR/build.dat`
ASSERTFILE1=/var/public/conf/version/uda_30_143.dat
ASSERTFILE2=/var/public/conf/version/uda_30_164.dat
SIGNATURE=/var/public/conf/version/uda_30_${BUILD}.dat

echo Checking if we can install this patch
if [ ! -f $ASSERTFILE1 ]
then
  echo Patch $PATCHNAME can only be installed on build 143
  exit 0
fi

if [ ! -f $ASSERTFILE2 ]
then
  echo Patch $PATCHNAME can only be installed on build 164
  exit 0
fi

echo Checking if we need to install this patch
if [ -f $SIGNATURE ]
then
  echo Patch $PATCHNAME is already installed on this system
  exit 0
fi

echo Copying config files for subtemplates
cp /var/public/conf/ipxedefaultsubmenufooter.new /var/public/conf/ipxedefaultsubmenufooter.conf
chown apache:apache /var/public/conf/ipxedefaultsubmenufooter.conf
cp /var/public/conf/ipxedefaultsubmenuheader.new /var/public/conf/ipxedefaultsubmenuheader.conf
chown apache:apache /var/public/conf/ipxedefaultsubmenuheader.conf

echo Copying scripts
cp $PATCHDIR/files/menu.cgi /var/public/www/ipxe/scripts/menu.cgi
chown apache:apache /var/public/www/ipxe/scripts/menu.cgi
cp $PATCHDIR/files/templates.pl /var/public/cgi-bin/templates.pl
chown apache:apache /var/public/cgi-bin/templates.pl

echo Writing out the signature
echo VERSION=$PATCHNAME > $SIGNATURE

echo Republishing all templates
chmod 755 $PATCHDIR/republish.pl
$PATCHDIR/republish.pl

echo Done
