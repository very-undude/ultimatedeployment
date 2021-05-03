# VMware ESX4 template Kickstart file

# Installation Method
install url http://[UDA_IPADDR]/[OS]/[FLAVOR]

# root Password
rootpw secret

# Authconfig
auth --enableshadow --enablemd5

# BootLoader ( The user has to use grub by default )
bootloader --location=mbr 

# Timezone
timezone Europe/London

# Network install type
network --bootproto=dhcp --device=vmnic0
# network --device=vmnic0 --bootproto=static --ip=192.168.2.103 --netmask=255.255.255.0 --gateway=192.168.2.199 --nameserver=192.168.2.200 --hostname=esx1.vi4book.com

# Keyboard
keyboard us

# Reboot after install ?
reboot

# Firewall settings
firewall --disabled

# Clear Partitions
clearpart --drives=[DISKTYPE] --overwritevmfs

# Either choose autopartitioning 
# autopart --disk=[DISKTYPE]

# Or do the partitioning yourself
part /boot --fstype=ext3 --size=250 --ondisk=[DISKTYPE]
part cos --fstype=vmfs3 --size=9000 --ondisk=[DISKTYPE]
part None --fstype=vmkcore --size=250 --ondisk=[DISKTYPE]
virtualdisk vd1 --size=7500 --onvmfs=cos
part / --fstype=ext3 --size=3000 --onvirtualdisk=vd1 --grow
part swap --fstype=swap --size=1000 --onvirtualdisk=vd1
part /opt --fstype=ext3 --size=1000 --onvirtualdisk=vd1
part /tmp --fstype=ext3 --size=1000 --onvirtualdisk=vd1
part /home --fstype=ext3 --size=1000 --onvirtualdisk=vd1

# VMware Specific Commands
vmaccepteula

%packages

%post --interpreter=bash

