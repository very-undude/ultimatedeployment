#!/bin/bash

if [ "$1" == "" ]
then
  echo ERROR: no OVA file specified
  exit 0
fi

OVANAME=$1

VMNAME=`basename $OVANAME .ova`

#### read settings.conf file
while read var
do
  key=`echo $var |   sed -E 's/^([^=]*)=(.*)/\1/g'`
  value=`echo $var | sed -E 's/^([^=]*)=(.*)/\2/g'`
  export $key="$value"
done < settings.conf


echo "INFO: Checking existence of VM with name $VMNAME"
VMID=`ssh esx "vim-cmd vmsvc/getallvms" |grep -E "^[0-9]+\s+$VMNAME\s+" | awk '{print $1}'`
if [ "$VMID" == "" ]
then
  echo INFO: No current VM found with that name, good
else
  echo INFO: destroying current VM with ID $$VMID 
  ssh esx "vim-cmd vmsvc/power.off $VMID"
  ssh esx "vim-cmd vmsvc/unregister $VMID"
fi

ovftool --overwrite -ds=$UDA_OVA_DATASTORE -dm=thin --net:"VM Network"="$UDA_OVA_VM_NETWORK" -n=$VMNAME $OVANAME vi://$UDA_OVA_VI_USERNAME:$UDA_OVA_VI_PASSWORD@$UDA_OVA_VI_IP/
