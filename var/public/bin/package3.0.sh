#!/bin/bash

# Copyright 2006-2018 Carl Thijssen

# This file is part of the Ultimate Deployment Appliance
#
# Ultimate Deployment Appliance is free software; you can redistribute
# it and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version
#
# Ultimate Deployment Appliance is distributed in the hope that it will
# be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>

export VERSION=3.0
export BUILD=1
export ARCHIVE=/tmp/uda-${VERSION}_build${BUILD}.tar
echo ARCHIVE=$ARCHIVE
rm $ARCHIVE
echo Tarring files

tar -uvf $ARCHIVE /var/public/cgi-bin/.htaccess
tar -uvf $ARCHIVE /var/public/cgi-bin/*.pl 
tar -uvf $ARCHIVE /var/public/cgi-bin/*.cgi 
tar -uvf $ARCHIVE /var/public/cgi-bin/os/*.pl 
tar -uvf $ARCHIVE /var/public/cgi-bin/services/*.pl 

tar -uvf $ARCHIVE /var/public/bin/*.py
tar -uvf $ARCHIVE /var/public/bin/*.pl
tar -uvf $ARCHIVE /var/public/bin/*.sh
tar -uvf $ARCHIVE /var/public/bin/fdapm.com
tar -uvf $ARCHIVE /var/public/bin/fdapm.txt
tar -uvf $ARCHIVE /var/public/bin/ks.cfg
tar -uvf $ARCHIVE /var/public/bin/sha1pass
tar -uvf $ARCHIVE /var/public/bin/updatewim
tar -uvf $ARCHIVE /var/public/bin/wimextract
tar -uvf $ARCHIVE /var/public/bin/wiminfo
tar -uvf $ARCHIVE /var/public/bin/wimxmlinfo
tar -uvf $ARCHIVE /var/public/bin/windows7.cmd
tar -uvf $ARCHIVE /var/public/bin/winpeshl.ini

tar -uvf $ARCHIVE /var/public/files/binl
tar -uvf $ARCHIVE /var/public/files/cabextract
tar -uvf $ARCHIVE /var/public/files/dhcpd.conf
tar -uvf $ARCHIVE /var/public/files/dhcpd.d.conf
tar -uvf $ARCHIVE /var/public/files/dhcpd.tpl
tar -uvf $ARCHIVE /var/public/files/exports.conf
tar -uvf $ARCHIVE /var/public/files/fdapm.com
tar -uvf $ARCHIVE /var/public/files/httpd.conf
tar -uvf $ARCHIVE /var/public/files/issue
tar -uvf $ARCHIVE /var/public/files/issue.tpl
tar -uvf $ARCHIVE /var/public/files/loop.conf
tar -uvf $ARCHIVE /var/public/files/smb
tar -uvf $ARCHIVE /var/public/files/smb.conf
tar -uvf $ARCHIVE /var/public/files/smb.conf
tar -uvf $ARCHIVE /var/public/files/smbpasswd.conf
tar -uvf $ARCHIVE /var/public/files/smbusers.conf
tar -uvf $ARCHIVE /var/public/files/sshd_config
tar -uvf $ARCHIVE /var/public/files/sudoers
tar -uvf $ARCHIVE /var/public/files/syslog.conf
tar -uvf $ARCHIVE /var/public/files/tftpd
tar -uvf $ARCHIVE /var/public/files/tftpd.conf
tar -uvf $ARCHIVE /var/public/files/winpeshl.ini

tar -uvf $ARCHIVE /var/public/conf/dhcpd.new 
tar -uvf $ARCHIVE /var/public/conf/general.new 
tar -uvf $ARCHIVE /var/public/conf/os.new 
tar -uvf $ARCHIVE /var/public/conf/passwd 
tar -uvf $ARCHIVE /var/public/conf/nfsexportheader.conf 
tar -uvf $ARCHIVE /var/public/conf/pxedefaultheader.new 
tar -uvf $ARCHIVE /var/public/conf/pxedefaultmenuitem.new 
tar -uvf $ARCHIVE /var/public/conf/pxedefaultsubmenuitem.new 
tar -uvf $ARCHIVE /var/public/conf/pxedefaultsubmenuheader.new 
tar -uvf $ARCHIVE /var/public/conf/mounts/local.dat 

tar -uvf $ARCHIVE /var/public/smbmount/local

tar -uvf $ARCHIVE /var/public/tftproot/message.hdr 
tar -uvf $ARCHIVE /var/public/tftproot/mboot.c32
tar -uvf $ARCHIVE /var/public/tftproot/help.txt 
tar -uvf $ARCHIVE /var/public/tftproot/pxelinux.0 
tar -uvf $ARCHIVE /var/public/tftproot/memdisk 
tar -uvf $ARCHIVE /var/public/tftproot/menu.c32 
tar -uvf $ARCHIVE /var/public/tftproot/vesamenu.c32 


tar -uvf $ARCHIVE /var/public/www/.htaccess
tar -uvf $ARCHIVE /var/public/www/default.css 
tar -uvf $ARCHIVE /var/public/www/icon/*.png 
tar -uvf $ARCHIVE /var/public/www/js/*.js 
tar -uvf $ARCHIVE /var/public/www/index.html 
tar -uvf $ARCHIVE /var/public/www/supportmatrix/index.html 
tar -uvf $ARCHIVE /var/public/www/supportmatrix/vmware/*.zip
tar -uvf $ARCHIVE /var/public/www/templates/*.tpl 
tar -uvf $ARCHIVE /var/public/www/uda.jpg 

gzip -9 $ARCHIVE
