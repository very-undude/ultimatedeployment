accepteula
rootpw secret
autopart --firstdisk --overwritevmfs
install url http://[UDA_IPADDR]/[OS]/[FLAVOR]
# network --bootproto=static --ip=192.168.178.200 --gateway=192.168.178.1 --nameserver=192.168.178.1 --netmask=255.255.255.0 --hostname=esx41i --addvmportgroup=0
network --bootproto=dhcp --addvmportgroup=0
reboot
