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

VERSION=3.0
PATCH=1
LOGFILE=$VERSION\_P$PATCH.$$.log

PUBLIC=/var/public
LOGDIR=/tmp
BINDIR=$PUBLIC/bin
CGIBINDIR=$PUBLIC/cgi-bin
CGIBINOSDIR=$PUBLIC/cgi-bin/os
CGIBINSVCDIR=$PUBLIC/cgi-bin/services
WWWDIR=$PUBLIC/www
ICONS=$WWWDIR/icon
JSDIR=$WWWDIR/js
TEMPLATES=$WWWDIR/templates
CONFDIR=$PUBLIC/conf
CONFMOUNTSDIR=$PUBLIC/conf/mounts
VERSIONDIR=$CONFDIR/version
TFTPROOT=$PUBLIC/tftproot
FILESDIR=$PUBLIC/files
PATCHTOPDIR=$PUBLIC/patches

if [ "$PATCHDIR" == "" ]
then
  PATCHDIR=$PATCHTOPDIR/patch.$VERSION.P$PATCH.$$
else
  cd $PATCHDIR
fi

log()
{
  TIMESTAMP=`date +%Y%m%d-%H%M%S`
  echo $*
  echo $TIMESTAMP $* >> $LOGDIR/$LOGFILE
}


################ copy actions #########################
copy_png_files()
{
  log Copying Icon files
  ls -1 files/www/icon | while read i
  do
     copy_file files/www/icon/$i $ICONS
   done
}

copy_template_files()
{
  log Copying Template files
  ls -1 files/www/templates | while read i
  do
     copy_file files/www/templates/$i $TEMPLATES
  done
}

copy_js_files()
{
  log Copying JS files
  ls -1 files/www/js | while read i
  do
     copy_file files/www/js/$i $JSDIR
  done
}

copy_bin_files()
{
  ls -1 files/bin | while read i
   do
     copy_file files/bin/$i $BINDIR
   done
}

copy_cgi_bin_files()
{
  ls -1A files/cgi-bin | while read i
  do
     if [ -f files/cgi-bin/$i ]
     then
       copy_file files/cgi-bin/$i $CGIBINDIR
     fi
  done
}

copy_cgi_bin_os_files()
{
  ls -1 files/cgi-bin/os | while read i
  do
     copy_file files/cgi-bin/os/$i $CGIBINOSDIR
  done
}

copy_cgi_bin_services_files()
{
  ls -1 files/cgi-bin/services | while read i
  do
     copy_file files/cgi-bin/services/$i $CGIBINSVCDIR
  done
}

copy_conf_files()
{
  ls -1 files/conf/mounts | while read i
  do
     copy_file files/conf/mounts/$i $CONFMOUNTSDIR
  done

  ls -1 files/conf | while read i
  do
     if [ -f files/conf/$i ]
     then
       copy_file files/conf/$i $CONFDIR
     fi
  done
}

copy_tftproot_files()
{
  ls -1 files/tftproot | while read i
  do
    copy_file files/tftproot/$i $TFTPROOT
  done
}

copy_files_files()
{
  ls -1 files/files | while read i
  do
     copy_file files/files/$i $FILESDIR
     chmod 755 $FILESDIR/$i
  done
}

copy_www_files()
{
  ls -1A files/www | while read i
  do
     if [ -f files/www/$i ]
     then
       copy_file files/www/$i $WWWDIR
     fi
  done
}

copy_file()
{
  FILE=$1
  DSTDIR=$2
  BASEFILE=`basename $FILE`
  log Copying file $FILE to $DSTDIR
  echo -n "  $FILE in $DSTDIR"
  diff $FILE $DSTDIR/$FILE > /dev/null 2>&1
  if [ $? -eq 0 ]
  then
    log Keeping Current version
    echo " OK! (current version of $FILE is ok)"
  else 
    log Backing up file to $PATCHDIR/before/$BASEFILE
    cp -f -p $DSTDIR/$FILE $PATCHDIR/before/$BASEFILE
    log Replacing $DSTDIR/$BASEFILE for new version $FILE
    cp -f -p $FILE $DSTDIR/$BASEFILE
    if [ $? -ne 0 ]
    then
      log ERROR: Replace Failed
      if [ ! -d $DSTDIR ]
      then
        log ERROR: $DSTDIR does not exist
        echo "FAILED! (Destination dir $DSTDIR does not exist)"
      else
        if [ ! -f $FILE ]
        then
          log ERROR: Source file $FILE does not exist
          echo "FAILED! (Source file $FILE does not exist)"
        else
          log ERROR: Unknown error
          echo "FAILED!"
        fi
      fi
    else
      log OK: Copied $FILE to $DSTDIR/$BASEFILE
      cp -f -p $DSTDIR/$FILE $PATCHDIR/after/$BASEFILE
      log Copied $FILE to $PATCHDIR/after/$BASEFILE
    fi
  fi
}

update_conf_files()
{
  log Updating Conf Files
  for conffile in \
      os \
      pxedefaultheader \
      pxedefaultmenuitem \
      pxedefaultsubmenuheader \
      pxedefaultsubmenuitem
   do
     if [ -f $CONFDIR/$conffile.conf ]
     then
      log Found current config file $conffile, keeping
     else
       log Not found current config file $conffile, creating
       cp -f -p $CONFDIR/$conffile.new $CONFDIR/$conffile.conf
       if [ $? -eq 0 ]
       then
         log OK: Copied $conffile.conf succesfully
       else
         log ERROR: Could not copy $conffile.conf
       fi
     fi
   done
}

overwrite_conf_files()
{
  log Overwrite conf files
  for file in \
      os.conf \
      pxedefaultheader.new \
      pxedefaultheader.conf
  do
     if [ -f $CONFDIR/$file ]
     then
      BACKUP=$file.$VERSION.P$PATCH.backup.$$
      log Found current file $file, backing it up
      cp -f -p $CONFDIR/$file $CONFDIR/$BACKUP
      cp -f -p $CONFDIR/$file $PATCHDIR/before/$BACKUP
     fi
     log Overwriting $file
     cp -f -p $CONFDIR/$file.overwrite $CONFDIR/$file
     if [ $? -eq 0 ]
     then
       log OK replaced $file
       cp -f -p $CONFDIR/$file $PATCHDIR/after/$BACKUP
       if [ $? -eq 0 ] 
       then
         log Removing .overwrite file
         rm $CONFDIR/$file.overwrite
       fi
     else
       log FAILED to replace file $CONFDIR/$file with $CONFDIR/$file.overwrite
     fi
  done
}

overwrite_files_files()
{
  log Overwrite files files
  for file in \
      smb \
      tftpd \
      binl \
      issue.tpl \
      dhcpd.tpl \
      cabextract
  do
     if [ -f $FILESDIR/$file ]
     then
      BACKUP=$file.$VERSION.P$PATCH.backup.$$
      log Found current file $file, backing it up
      cp -f -p $FILESDIR/$file $FILESDIR/$BACKUP
      cp -f -p $FILESDIR/$file $PATCHDIR/before/$BACKUP
     fi
     log Overwriting $file
     cp -f -p files/files/$file.overwrite $FILESDIR/$file
     if [ $? -eq 0 ]
     then
       log OK replaced $file
       cp -f -p $FILESDIR/$file $PATCHDIR/after/$BACKUP
       if [ $? -eq 0 ] 
       then
         log Removing .overwrite file
         rm $FILESDIR/$file.overwrite
       fi
     fi
  done
}

update_files_files()
{
  log Updating Service Conf Files
  for conffile in \
      httpd \
      smb \
      loop \
      syslog \
      smbpasswd \
      exports \
      smbusers \
      tftpd
   do
     if [ -f $FILESDIR/$conffile.conf ]
     then
      log Found current config file $conffile, keeping
     else
       log Not found current config file $conffile, creating
       cp -f -p $FILESDIR/$conffile.new $FILESDIR/$conffile.conf
       if [ $? -eq 0 ]
       then
         log OK: Copied $conffile.conf succesfully, removing $conffile.new 
         rm $FILESDIR/$conffile.new
       else
         log ERROR: Could not copy $conffile.conf
       fi
     fi
   done
}


create_directory_structure()
{
  log Creating Directory Structure
  for dir in \
     /var/public \
     /var/public/log \
     /var/public/tmp \
     /var/public/bin \
     /var/public/cgi-bin \
     /var/public/cgi-bin/os \
     /var/public/cgi-bin/services \
     /var/public/smbmount \
     /var/public/www \
     /var/public/www/js \
     /var/public/www/icon \
     /var/public/www/kickstart \
     /var/public/www/autoyast \
     /var/public/www/jumpstart \
     /var/public/conf \
     /var/public/conf/os \
     /var/public/conf/templates \
     /var/public/conf/mounts \
     /var/public/conf/version \
     /var/public/conf/winpedrv \
     /var/public/tftproot \
     /var/public/tftproot/manual \
     /var/public/tftproot/windows5 \
     /var/public/tftproot/pxelinux.cfg \
     /var/public/tftproot/pxelinux.cfg/templates \
     /var/public/patches \
     /var/public/files \
     /var/public/files/dhpcd.d \
     /var/public/www/templates
    do
    if [ ! -d $dir ]
    then
       log Creating directory $dir
       mkdir $dir
    else
       log Directory $dir already exists
    fi
    done

}

backup_system_files()
{
  log Backing up system files
  mv /etc/syslog.conf /etc/syslog.conf.org
  mv /etc/init.d/smb /etc/init.d/smb.org
}

create_file_links()
{
  log Creating File links
  ln -sf /var/public/files/sshd_config  /etc/ssh/sshd_config
  ln -sf /var/public/files/binl         /etc/init.d/binl
  ln -sf /var/public/files/tftpd        /etc/init.d/tftpd
  ln -sf /var/public/files/smb          /etc/init.d/smb
  ln -sf /var/public/files/exports.conf /etc/exports
  ln -sf /var/public/files/issue        /etc/issue
  ln -sf /var/public/files/cabextract   /usr/bin/cabextract
  ln -sf /var/public/files/loop.conf    /etc/modprobe.d/loop
  ln -sf /var/public/files/dhcpd.conf   /etc/dhcpd.conf
  ln -sf /var/public/files/syslog.conf  /etc/syslog.conf
  ln -sf /var/public/files/httpd.conf   /etc/httpd/conf/httpd.conf
  ln -sf /var/public/files/smb.conf     /etc/samba/smb.conf
  ln -sf /var/public/files/smbusers.conf /etc/samba/smbusers
  ln -sf /var/public/files/smbpasswd.conf /etc/samba/smbpasswd
  ln -sf /var/public/files/tftpd.conf   /etc/tftpd.conf
}

initialise_binl_cache()
{
  log Initialising binl cache
  /var/public/bin/infparser2.py
}


change_file_permissions()
{
  log Changing permissions on public directory
  chmod -R 755 /var/public/bin
  chown -hR apache.apache /var/public/cgi-bin
  chmod -R 755 /var/public/cgi-bin
  chown -hR apache.apache /var/public/www
  chown -hR apache.apache /var/public/conf
  chown -hR apache.apache /var/public/tmp
  chown -h apache.apache /var/public/tftproot
  chown -hR apache.apache /var/public/tftproot/pxelinux.cfg
}

############################   Main routines ########################
prepare_upgrade()
{
  log Preparing upgrade...

  mkdir -p $PATCHDIR
  if [ $? -eq 0 ]
  then
    log OK: Created patchdir $PATCHDIR
    cd $PATCHDIR
  else
    log ERROR: Could not create patchdir $PATCHDIR
    exit 2
  fi

  for newdir in $PATCHDIR/before $PATCHDIR/after $PATCHDIR/version
  do
    log Creating directory $newdir
    mkdir $newdir
    if [ $? -eq 0 ]
    then
      log OK: Created directory $newdir
    else
      log ERROR: Could not create $newdir
      exit 1
    fi
  done

}

determine_current_versions()
{
  log Determining current version
  ls -1 $VERSIONDIR/*.dat | while read filename
  do
    log Found version file $filename
    cp -f $filename $PATCHDIR/version 
    if [ $? -eq 0 ]
    then
      log Copied version file $filename to $PATCHDIR/version
    else
      log Could not copy version file $filename to $PATCHDIR/version
    fi
  done
}

stop_services()
{
  log Stopping services if needed
  mkdir $PATCHDIR/restart

  ps -ef | grep binlsrv2.py | grep -v grep > /dev/null
  if [ $? -eq 0 ]
  then
    log Found binl service running, stopping for now
    /sbin/service binl stop
    if [ $? -eq 0 ]
    then
       touch $PATCHDIR/restart/binl
       log Stopped binl service succesfully
    else
       log ERROR: Failed to stop binl service
    fi
  else
    log binlservice not running,
  fi

  ps -ef | grep in.tftpd | grep -v grep > /dev/null
  if [ $? -eq 0 ]
  then
    log Found tftpd service running, stopping for now
    /sbin/service tftpd stop
    if [ $? -eq 0 ]
    then
       touch $PATCHDIR/restart/tftpd
       log Stopped tftpd service succesfully
    else
       log ERROR: Failed to stop tftpd service
    fi
  else
    log  tftpd service not running,
  fi


}

start_services()
{
  ls -1 $PATCHDIR/restart | while read service
  do
    log Starting service $service
    /sbin/service $service start
    if [ $? -eq 0 ]
    then
      log Started service $service succesfully
    else
      log ERROR: Could not start service $service 
    fi
  done
}


install_packages()
{
 log Installing Packages
 rpm -ivh rpm/*.rpm
 if [ $? -eq 0 ]
 then
   log Install of packages succesfully
 else
   log Failed to install packages
 fi
}


copy_files()
{
  log Copying Files
  copy_png_files
  copy_template_files
  copy_js_files
  copy_bin_files
  copy_cgi_bin_files
  copy_cgi_bin_os_files
  # copy_cgi_bin_services_files
  copy_conf_files
  copy_tftproot_files
  copy_files_files
  copy_www_files
}

create_version_info()
{
  log Creating Versioninfo 
  VERSIONFILE=$VERSIONDIR/uda_${VERSION/./}\_P$PATCH.dat
  echo VERSION=$VERSION\_P$PATCH > $VERSIONFILE
  log Wrote $VERSIONFILE
}

wrapup()
{
  WRAPUP=$PATCHTOPDIR/patch.$VERSION.P$PATCH.$$.tgz
  log Wrapping up the results to $WRAPUP
  log Copying logfile to $PATCHDIR
  cp -f $LOGDIR/$LOGFILE $PATCHDIR
  tar -czf $WRAPUP $PATCHDIR
  rm -rf $PATCHDIR
  log For logfile see $LOGDIR/$LOGFILE
}

############################   Main loop ########################

log ======== Initialize ==========
prepare_upgrade
determine_current_versions

log ======== Pre Copy Actions =======
#create_directory_structure
#backup_system_files
#stop_services

log ======== Copy Files =======
#copy_files

log ======== Post Copy Actions =======
#create_file_links
#update_conf_files
#overwrite_conf_files
#update_files_files
#overwrite_files_files
#change_file_permissions
#install_packages
#start_services

log ======= Finalize =======
create_version_info
wrapup
