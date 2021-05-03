# interactive
text
install
url --url=http://[IPADDRESS]/rhel/rhel5/
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
clearpart --linux --all --drives=hda
part /boot --fstype ext3 --size=100 --asprimary --ondisk=hda
part swap --fstype swap --size=256 --grow --maxsize=512 --ondisk=hda
part / --fstype ext3 --size=1 --grow --asprimary --ondisk=hda
reboot

%pre

%packages
kernel
e2fsprogs
grub

%post
