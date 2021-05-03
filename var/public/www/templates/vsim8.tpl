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

echo Adding 7 mode boot options to env file $ENVFILE
echo setenv bootarg.setup.auto true            >> $ENVFILE
echo setenv bootarg.setup.hostname vsim        >> $ENVFILE
echo setenv bootarg.setup.nic_e0a \"192.168.145.171\;255.255.255.0\;auto\;full\;n\" >> $ENVFILE
echo setenv bootarg.setup.default_gateway 192.168.145.1 >> $ENVFILE
echo setenv bootarg.setup.admin_password netapp01 >> $ENVFILE
echo setenv bootarg.setup.tmz GMT >> $ENVFILE
echo setenv bootarg.setup.filer_location MyLocation >> $ENVFILE
echo setenv bootarg.setup.sas_mgmt n >> $ENVFILE
echo setenv bootarg.setup.admin_host 192.168.145.7 >> $ENVFILE
echo setenv bootarg.setup.run_dns n >> $ENVFILE
echo setenv bootarg.setup.dns_info \"mydomain.local\;192.168.145.4\" >> $ENVFILE
echo setenv bootarg.setup.run_nis n >> $ENVFILE
echo setenv bootarg.setup.nis_info \"mynisdomain\;192.168.145.6\" >> $ENVFILE
echo setenv bootarg.setup.interface_groups n >> $ENVFILE
echo setenv bootarg.setup.interface_groups_count 1 >> $ENVFILE
echo setenv bootarg.setup.interface_groups_info test >> $ENVFILE

echo Adding Cluster mode boot options to env file $ENVFILE
echo setenv bootarg.setup.auto true >> $ENVFILE
echo setenv bootarg.setup.auto.file \"/cfcard/vsa.xml\" >> $ENVFILE
cp /etc/vsa.xml /mnt/tmp/vsa.xml

umount /mnt/tmp
sleep 5
reboot
