#!/bin/sh
ENVFILE=/mnt/tmp/env/env

echo UDA Startup script 
mkdir /mnt/tmp
mount -o loop /dev/sda2 /mnt/tmp

echo Adding general boot options to env file $ENVFILE
echo setenv SYS_SERIAL_NUM 1111111111          >> $ENVFILE
echo setenv bootarg.nvram.sysid 1111111-11-1   >> $ENVFILE
echo setenv bootarg.bootmenu.selection 4a      >> $ENVFILE
echo setenv bootarg.vm.sim.vdevinit \"36:14:0,36:14:1,36:14:2,36:14:3\" >> $ENVFILE
echo setenv bootarg.sim.vdevinit \"36:14:0,36:14:1,36:14:2,36:14:3\" >> $ENVFILE

echo Adding Cluster mode boot options to env file $ENVFILE
echo setenv bootarg.setup.auto true >> $ENVFILE
echo setenv bootarg.setup.auto.file \"/cfcard/setup.ngsh\" >> $ENVFILE
cp /etc/setup.ngsh /mnt/tmp/setup.ngsh

umount /mnt/tmp
sleep 5
reboot
