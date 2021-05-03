#!/bin/bash -x

# Copyright 2006-2018 Carl Thijssen

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

export MAJORVERSION=3
export MINORVERSION=0
export BUILD=143
export VERSION=${MAJORVERSION}.${MINORVERSION}
export KERNEL=`uname -r`
export ARCH=`uname -m`

echo Post-Installscript Ultimate Deployment Appliance $VERSION

echo Creating guest user
useradd guest 

echo Creating Directory structure
mkdir /var/public
mkdir /var/public/log
mkdir /var/public/tmp
mkdir /var/public/bin
mkdir /var/public/cgi-bin
mkdir /var/public/cgi-bin/os
mkdir /var/public/cgi-bin/services
mkdir /var/public/smbmount
mkdir /var/public/www
mkdir /var/public/www/js
mkdir /var/public/www/icon
mkdir /var/public/www/kickstart
mkdir /var/public/www/autoyast
mkdir /var/public/www/jumpstart
mkdir /var/public/www/ova
mkdir /var/public/conf
mkdir /var/public/conf/os
mkdir /var/public/conf/templates
mkdir /var/public/conf/mounts
mkdir /var/public/conf/version
mkdir /var/public/conf/winpedrv
mkdir /var/public/conf/named
mkdir /var/public/tftproot
mkdir /var/public/tftproot/manual
mkdir /var/public/tftproot/windows5
mkdir /var/public/tftproot/pxelinux.cfg
mkdir /var/public/tftproot/pxelinux.cfg/templates
mkdir /var/public/files
mkdir /var/public/files/dhcpd.d
mkdir /var/public/www/templates
mkdir /var/public/samba
mkdir /var/public/samba/wg
mkdir /var/public/samba/wg/private
mkdir /var/public/samba/wg/etc
mkdir /var/public/samba/wg/bind-dns
mkdir /var/public/samba/wg/var
mkdir /var/public/samba/wg/var/cache
mkdir /var/public/samba/wg/var/lib
mkdir /var/public/samba/wg/var/lock
mkdir /var/public/samba/wg/var/locks
mkdir /var/public/samba/wg/var/run
mkdir /var/public/samba/ad
mkdir /var/public/samba/ad/private
mkdir /var/public/samba/ad/etc
mkdir /var/public/samba/ad/bind-dns
mkdir /var/public/samba/ad/var
mkdir /var/public/samba/ad/var/cache
mkdir /var/public/samba/ad/var/lib
mkdir /var/public/samba/ad/var/lock
mkdir /var/public/samba/ad/var/locks
mkdir /var/public/samba/ad/var/run
mkdir /local/ova
mkdir /local/ova/builtin

chmod 700 /var/public/samba/wg/private
chmod 700 /var/public/samba/ad/private

mkdir /var/lib/nfs/v4recovery
mkdir /solaris
mkdir /solaris10sparc
mkdir /solaris9sparc
mkdir /solaris9x86
mkdir /iso

echo Copying files
#tar -C / -xvzf /tmp/uda-$VERSION.tar.gz
echo Setup /etc/sudoers for passwordless sudo for wheel group
sed -r -i -c 's/^\%wheel/##%wheel/g' /etc/sudoers
sed -r -i -c 's/^# %wheel/%wheel/g' /etc/sudoers
sed -r -i -c "s/^Defaults\s*requiretty/#Defaults requiretty/g" /etc/sudoers

echo Link ova files 
ls -1 /var/public/www/ova | while read name
do
  mkdir /local/ova/builtin/$name
  chmod 755 /local/ova/builtin/$name
  ls -1 /var/public/www/ova/$name | while read ovafile
  do
    ln -sf /var/public/www/ova/$name/$ovafile /local/ova/builtin/$name/$ovafile
  done
done
chown -hR apache:apache /local/ova

echo Resetting Network config
echo DEVICE=eth0      > /etc/sysconfig/network-scripts/ifcfg-eth0
echo ONBOOT=no         >> /etc/sysconfig/network-scripts/ifcfg-eth0
nmcli con del "Wired connection 1"
rm -f /etc/sysconfig/network-scripts/ifcfg-ens*

echo Backup up files
cp -f -p /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.org
rm /usr/lib/systemd/system/tftp.socket
rm /usr/lib/systemd/system/tftp.service
rm /etc/xinetd.d/tftp
mv /etc/named.conf            /etc/named.conf.org
mv /var/named/named.loopback  /var/named/named.loopback.org
mv /var/named/named.localhost /var/named/named.localhost.org
mv /var/named/named.ca        /var/named/named.ca.org

echo Linking files
ln -sf /var/public/files/sshd_config  /etc/ssh/sshd_config
ln -sf /var/public/files/tftpd        /etc/init.d/tftpd
ln -sf /var/public/files/smb          /etc/init.d/smb
ln -sf /var/public/files/binl         /etc/init.d/binl
ln -sf /var/public/files/exports.conf /etc/exports
ln -sf /var/public/files/dhcpd.conf   /etc/dhcp/dhcpd.conf
ln -sf /var/public/files/syslog.conf  /etc/rsyslog.d/uda.conf
ln -sf /var/public/files/httpd.conf   /etc/httpd/conf/httpd.conf
ln -sf /var/public/files/tftpd.conf   /etc/tftpd.conf
ln -sf /var/public/files/issue        /etc/issue
ln -sf /var/public/files/loop         /etc/modprobe.d/loop

echo Linking named configuration files
ln -sfT /var/public/conf/named/named.conf         /etc/named.conf
ln -sfT /var/public/conf/named/named.ca           /var/named/named.ca
ln -sfT /var/public/conf/named/named.loopback     /var/named/named.loopback
ln -sfT /var/public/conf/named/named.localhost    /var/named/named.localhost
ln -sfT /var/public/conf/named/uda.zone           /var/named/uda.zone
ln -sfT /var/public/conf/named/uda_reverse.zone   /var/named/uda_reverse.zone

echo Copying templates to usable files
cat /var/public/conf/os.new | grep -v "^#"       > /var/public/conf/os.conf
cp -p /var/public/conf/pxedefaultheader.new        /var/public/conf/pxedefaultheader.conf
cp -p /var/public/conf/pxedefaultmenuitem.new      /var/public/conf/pxedefaultmenuitem.conf
cp -p /var/public/conf/pxedefaultsubmenuheader.new /var/public/conf/pxedefaultsubmenuheader.conf
cp -p /var/public/conf/pxedefaultsubmenuitem.new   /var/public/conf/pxedefaultsubmenuitem.conf
cp -p /var/public/conf/general.new                 /var/public/conf/general.conf

echo Setting Up temporary directory for file upload
mv /var/tmp /var/tmp.old
ln -sf /local /var/tmp
ln -sf /local /var/public/smbmount/local

echo Intitalising Logfiles and config files
touch /var/log/lastlog
touch /var/public/log/dhcpd.log
touch /var/public/log/tftpd.log
touch /var/public/files/dhcpd.d.conf

echo Initialising binl cache
/var/public/bin/infparser.py

echo Changing permissions on public directory
chown -hR apache.apache /local
chown -hR apache.apache /var/public
chown -hR apache.apache /solaris
chmod 0440 /etc/sudoers
chown root:root /etc/sudoers

echo Adding apache user to wheel group for sudoers
usermod -a -G wheel apache
usermod --shell /bin/bash apache

echo Installing Active Directory Domain Controller service
cp -p /var/public/files/samba-ad-dc.service /usr/lib/systemd/system/
chown -h root:root /usr/lib/systemd/system/samba-ad-dc.service
chmod 644 /usr/lib/systemd/system/samba-ad-dc.service

echo Installing UDA boot service and enabling firstboot
cp -p /var/public/files/udaboot.service /usr/lib/systemd/system/
chown -h root:root /usr/lib/systemd/system/udaboot.service
chmod 644 /usr/lib/systemd/system/udaboot.service
touch /var/public/conf/firstboot.txt

echo Change https service PrivateTmp setting to prevent mount namespaces
#sed -i 's/PrivateTmp=true/PrivateTmp=false/g' /etc/systemd/system/multi-user.target.wants/httpd.service
#systemctl daemon-reload
mkdir /etc/systemd/system/httpd.service.d
echo "[Service]"         > /etc/systemd/system/httpd.service.d/nopt.conf
echo "PrivateTmp=false" >> /etc/systemd/system/httpd.service.d/nopt.conf

echo Deactivating nescessary services
systemctl disable binl.service
systemctl disable tftpd.service
systemctl disable dhcpd.service
systemctl disable smb.service
systemctl disable samba-ad-dc.service
systemctl disable sshd.service
systemctl disable httpd.service
systemctl disable xinetd.service
systemctl disable named.service
systemctl disable irqbalance.service
systemctl disable rpcbind
systemctl disable nfs-server
systemctl disable nfs-lock
systemctl disable nfs-idmap
systemctl disable network
systemctl disable NetworkManager.service

echo Activating nescessary services
systemctl enable atd.service
systemctl enable udaboot.service

echo Resetting root password and admin web password
echo admin | passwd root --stdin > /dev/null
ADMINPWDHASH=`echo admin | openssl passwd -stdin`
echo admin:$ADMINPWDHASH > /var/public/conf/passwd

echo Deactivating console messages from journald
sed -r -i -c 's/#ForwardToConsole/ForwardToConsole/g' /etc/systemd/journald.conf

echo Setting grub config
sed -r -i -c 's/CentOS Linux.*el7.*\(Core\)/Ultimate Deployment Appliance 3/g' /boot/grub2/grub.cfg
sed -r -i -c 's/CentOS Linux.*rescue.*\(Core\)/Ultimate Deployment Appliance 3 \(rescue\)/g' /boot/grub2/grub.cfg
sed -r -i -c 's/rhgb/rhgb quiet net.ifnames=0/g' /boot/grub2/grub.cfg
sed -r -i -c 's/console=tty0//g' /boot/grub2/grub.cfg

echo Installing additional rpms
yum -y localinstall /var/public/rpm/*.rpm
yum -y erase NetworkManager

echo Unpacking custom built samba
tar -C /usr/local -xvzf /var/public/software/samba.tgz
rm -rf /usr/local/samba/share/man
ln -sfT /var/public/files/smb.conf  /var/public/samba/wg/etc/smb.conf

echo Set default Workgroup config to active
rm -rf /usr/local/samba/var
rm -rf /usr/local/samba/etc
rm -rf /usr/local/samba/private
rm -rf /usr/local/samba/bind-dns
ln -sfT /var/public/samba/wg/var /usr/local/samba/var
ln -sfT /var/public/samba/wg/etc /usr/local/samba/etc
ln -sfT /var/public/samba/wg/private /usr/local/samba/private
ln -sfT /var/public/samba/wg/bind-dns /usr/local/samba/bind-dns

echo Link winbind libraries
ln -s /usr/local/samba/lib/libnss_winbind.so.2 /lib64/
ln -s /lib64/libnss_winbind.so.2 /lib64/libnss_winbind.so
ldconfig

echo Delete unneeded files
rm -rf /tmp/*
rm /var/log/acpid
rm /var/log/anaconda.log
rm /var/log/anaconda.syslog
rm /var/log/boot.log
rm /var/log/btmp
rm /var/log/dmesg
rm /var/log/faillog
rm /var/log/maillog
rm /var/log/secure
rm /var/log/spooler
rm /var/log/tallylog
rm /var/log/wtmp
rm /var/log/yum.log
rm /var/log/audit/audit.log
rm /var/log/lastlog
rmdir /var/opt
rmdir /var/yp
rmdir /var/nis
rmdir /var/games
rmdir /var/local
rm -rf /root/.ssh
rm -f /root/install.log
rm -f /root/install.log.syslog
rm -f /root/.bash_history
rm -f /root/.lesshst
rm -f /root/.cshrc
rm -f /root/.tcshrc
rm -f /tmp/install.out

echo Removing local files
rm -f /etc/yum.repos.d/uda.repo
rm -f /local/local
rm -rf /var/public/rpm
rm -rf /var/public/software

echo Overwriting initramfs with rescue image
KERNELVER=`rpm -q kernel | sed 's/kernel-//g'`
mv /boot/initramfs-${KERNELVER}.img /boot/initramfs-${KERNELVER}.org
cp /boot/initramfs-0-rescue* /boot/initramfs-${KERNELVER}.img

echo === Writing zeroes to swap ===
TMPDIR=/root/tmpdir1
SWAPDEV=/dev/dm-1
swapoff $SWAPDEV
mkfs.ext4 $SWAPDEV
mkdir $TMPDIR
mount -t ext4 $SWAPDEV $TMPDIR
cat /dev/zero > $TMPDIR/zero.txt
rm $TMPDIR/zero.txt
umount $TMPDIR
rmdir $TMPDIR
mkswap $SWAPDEV

echo === Writing zeroes to sytem partition ===
cat /dev/zero > /zero.txt
rm /zero.txt

echo === Writing zeroes to local partition ===
cat /dev/zero > /local/zero.txt
rm /local/zero.txt

echo Creating versioninfo
echo VERSION=${MAJORVERSION}${MINORVERSION}\_Build${BUILD} > /var/public/conf/version/uda_${MAJORVERSION}${MINORVERSION}_${BUILD}.dat

echo Removing DNS setup
rm /etc/resolv.conf
touch /etc/resolv.conf

echo Remove myself
rm -f /tmp/upgrade.sh
