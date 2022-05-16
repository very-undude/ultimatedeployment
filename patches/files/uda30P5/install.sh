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
PATCHNAME=uda30P4
BUILD=`cat $PATCHDIR/build.dat`
ASSERTFILE1=/var/public/conf/version/uda_30_143.dat
ASSERTFILE2=/var/public/conf/version/uda_30_164.dat
ASSERTFILE3=/var/public/conf/version/uda_30_165.dat
ASSERTFILE4=/var/public/conf/version/uda_30_166.dat
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

if [ ! -f $ASSERTFILE3 ]
then
  echo Patch $PATCHNAME can only be installed on build 165
  exit 0
fi

if [ ! -f $ASSERTFILE4 ]
then
  echo Patch $PATCHNAME can only be installed on build 166
  exit 0
fi

echo Checking if we need to install this patch
if [ -f $SIGNATURE ]
then
  echo Patch $PATCHNAME is already installed on this system
  exit 0
fi

echo Copying scripts into place

cp -p $PATCHDIR/files/kickstart.pl /var/public/cgi-bin/kickstart.pl
chmod 755 /var/public/cgi-bin/kickstart.pl
chown -h apache:apache /var/public/cgi-bin/kickstart.pl

cp -p $PATCHDIR/files/templates.pl /var/public/cgi-bin/templates.pl
chmod 755 /var/public/cgi-bin/templates.pl
chown -h apache:apache /var/public/cgi-bin/templates.pl

cp -p $PATCHDIR/files/config.pl /var/public/cgi-bin/config.pl
chmod 755 /var/public/cgi-bin/config.pl
chown -h apache:apache /var/public/cgi-bin/config.pl

cp -p $PATCHDIR/files/vsim.pl /var/public/cgi-bin/os/vsim.pl
chmod 755 /var/public/cgi-bin/os/vsim.pl
chown -h apache:apache /var/public/cgi-bin/os/vsim.pl

cp -p $PATCHDIR/files/vsim8.pl /var/public/cgi-bin/os/vsim8.pl
chmod 755 /var/public/cgi-bin/os/vsim8.pl
chown -h apache:apache /var/public/cgi-bin/os/vsim8.pl

cp -p $PATCHDIR/files/vsim9.pl /var/public/cgi-bin/os/vsim9.pl
chmod 755 /var/public/cgi-bin/os/vsim9.pl
chown -h apache:apache /var/public/cgi-bin/os/vsim9.pl

cp -p $PATCHDIR/files/windows5.pl /var/public/cgi-bin/os/windows5.pl
chmod 755 /var/public/cgi-bin/os/windows5.pl
chown -h apache:apache /var/public/cgi-bin/os/windows5.pl

cp -p $PATCHDIR/files/windows7.pl /var/public/cgi-bin/os/windows7.pl
chmod 755 /var/public/cgi-bin/os/windows7.pl
chown -h apache:apache /var/public/cgi-bin/os/windows7.pl

cp -p $PATCHDIR/files/bartpe.pl /var/public/cgi-bin/os/bartpe.pl
chmod 755 /var/public/cgi-bin/os/bartpe.pl
chown -h apache:apache /var/public/cgi-bin/os/bartpe.pl

echo Writing out the signature
echo VERSION=$PATCHNAME > $SIGNATURE

echo Done
