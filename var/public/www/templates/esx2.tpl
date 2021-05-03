lang en_US
text
langsupport  en_US  --default=en_US
keyboard us
mouse none
reboot
install
rootpw test
timezone Europe/Amsterdam
auth --enableshadow --enablemd5
url --url=http://[UDA_IPADDR]/[OS]/[FLAVOR]
network --bootproto=dhcp --device=eth0
# network --device eth0 --bootproto static --ip 10.0.0.110 --netmask 255.0.0.0 --gateway 10.0.0.138 --nameserver 10.0.0.2 --hostname ESX252S1
#bootloader --location=mbr
bootloader --useLilo
skipx
firewall --disabled
zerombr yes
clearpart --all --initlabel --drives=sda
part /boot     --fstype ext3    --size 100   --ondisk sda --asprimary
part /         --fstype ext3    --size 4096  --ondisk sda --asprimary
part swap                       --size 2048  --ondisk sda --asprimary
part /var      --fstype ext3    --size 1024  --ondisk sda
part /tmp      --fstype ext3    --size 512   --ondisk sda
part /opt      --fstype ext3    --size 512   --ondisk sda
part /home     --fstype ext3    --size 1024  --ondisk sda
part /vmimages --fstype ext3    --size 10240 --ondisk sda
part vmkcore   --fstype vmkcore --size 100   --ondisk sda
part local     --fstype vmfs2   --size 1 --grow --ondisk sda


# VMware Specific Commands

# VMKswap
# create 8G VMkernel swapfile and place on "local" partition 
# volume and size are changeable, the name not:
#
#vmswap --volume="local" --size="8192" --name "SwapFile.vswp"

# Memory for Console OS
# 192 = max 8 vmsessions
# 272 = max 16 vmsessions
# 384 = max 32 vmsessions
# 512 = max >32 vmsessions
# 800 = maximum amount to reserve for the Console.

vmservconmem --reserved=128

# Assign all PCI devices ( All of these device IDs can be obtained by looking at /etc/vmware/hwconfig )
# Check /etc/vmware/devnamed.conf
#
# 2/4/0 scsi = vmhba0 (shared) Onboard RAID controller
# 3/6/0 nic  = vmnic0 (shared) First onboard GigE NIC
# 3/6/1 nic  = vmnic1 (vm) Second onboard GigE NIC
# 6/4/0 nic  = vmnic2 (vm) Intel 1000MT NIC Port 1
# 6/4/1 nic  = vmnic3 (vm) Intel 1000MT NIC Port 2
# 6/6/0 nic  = vmnic4 (vm) Intel 1000MT NIC Port 3
# 6/6/1 nic  = vmnic5 (vm) Intel 1000MT NIC Port 4
# 7/9/0 fc   = vmhba1 (vm) Qlogic 2340 Fibre HBA
# uncomment below with the table above:
#
#vmpcidivy --shared=2/4/0 --shared=3/6/0 --vms=3/6/1 --vms=6/4/0 --vms=6/4/1 --vms=6/6/0 --vms=6/6/1 --vms=7/9/0
vmpcidivy --auto

# Set up virtual switches. example:
# example: 3 virtual switches= vmotion, dmz1 and dmz2 with vmnic assigned
#          internal has 2 vmnics with bonded config
#          and 5 seperate VLANs on the internal
#          one internal only vSwitch (vmxnet) is "private_network" 
#          and no vmnics are assigned to it.
#
#vmnetswitch --name="vmotion"  --vmnic=vmnic0
#vmnetswitch --name="internal" --vmnic=vmnic1 --vmnic=vmnic2
#vmnetswitch --name="vlan_1"   --vmnic="internal.1" 
#vmnetswitch --name="vlan_2"   --vmnic="internal.2" 
#vmnetswitch --name="vlan_3"   --vmnic="internal.3" 
#vmnetswitch --name="vlan_4"   --vmnic="internal.4" 
#vmnetswitch --name="vlan_5"   --vmnic="internal.5" 
#vmnetswitch --name="dmz1"     --vmnic=vmnic4
#vmnetswitch --name="dmz2"     --vmnic=vmnic5
#vmnetswitch --name="private_network"

# VMware license: 
#
vmaccepteula
#vmlicense --mode=server --server=27000@licenseserver.domain.name --edition=esxFull
#vmlicense --mode=file --edition=esxFull
vmserialnum --esx=XXXXX-XXXXX-XXXXX-XXXXX --esxsmp=XXXXX-XXXXX-XXXXX-XXXXX

%packages
@ESX Server
kernel-smp
 
#%vmlicense_text
 
%post --nochroot

