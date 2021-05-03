# interactive
text
install
url --url=http://[UDA_IPADDR]/[OS]/[FLAVOR]
key --skip
lang en_US.UTF-8
langsupport --default=en_US.UTF-8 en_US.UTF-8
keyboard us
skipx
network --device eth0 --bootproto dhcp
rootpw secret
firewall --disabled
selinux --disabled
authconfig --enableshadow --enablemd5
timezone Europe/Amsterdam
zerombr
bootloader --location=mbr 
clearpart --linux --all --drives=sda
part /boot --fstype ext3 --size=100 --asprimary --ondisk=sda
part swap --fstype swap --size=256 --grow --maxsize=512 --ondisk=sda
part / --fstype ext3 --size=1 --grow --asprimary --ondisk=sda
reboot

%pre

%packages
kernel
e2fsprogs
grub

%post
