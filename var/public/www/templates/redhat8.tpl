eula --agreed
#auth  --enableshadow  --passalgo=sha512
zerombr
clearpart --all --initlabel
text
firewall --disabled
firstboot --disable
keyboard us
lang en_US.UTF-8
#key --skip
logging --level=info
url --url=http://[UDA_IPADDR]/[OS]/[FLAVOR]
network --bootproto=static --hostname=myhost --device=eth0
bootloader --location=mbr --driveorder=sda --append="rhgb novga  console=ttyS0,9600 console=tty0 crashkernel=showopts panic=1 numa=off noht"
clearpart --all --initlabel
#autostep
autopart --type=lvm --fstype=xfs
rootpw --plaintext secret
selinux --disabled
skipx
services --disabled kdump
timezone --utc Europe/Amsterdam
install
reboot

%packages 
@Core
@Base
%end

%post --log=/var/log/kickstart_post.log
echo "Installation Completed" > /tmp/install.out
date >> /tmp/install.out
%end

