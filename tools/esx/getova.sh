#!/bin/bash

VMNAME=$1

if [ "$VMNAME" == "" ]
then
  echo "Error: No VM specified"
  echo "Usage:"
  echo "  $0 <vmname>"
  exit 1
fi

#### read settings.conf file
while read var
do
  key=`echo $var |   sed -E 's/^([^=]*)=(.*)/\1/g'`
  value=`echo $var | sed -E 's/^([^=]*)=(.*)/\2/g'`
  export $key="$value"
done < settings.conf

OVAFILE=${VMNAME}.ova

rm -f $OVAFILE

ovftool --X:logToConsole --X:logLevel=error --targetType=OVA vi://${UDA_OVA_VI_USERNAME}:${UDA_OVA_VI_PASSWORD}@${UDA_OVA_VI_IP}/${VMNAME} $OVAFILE
if [ $? -ne 0 ]
then
  exit 1
fi

chmod 644 $OVAFILE

ovftool $OVAFILE | grep -i "${UDA_OVA_VM_NETWORK}" > /dev/null
if [ $? -eq 0 ]
then
  echo WARNING: "${UDA_OVA_VM_NETWORK}" found, you may want to change that to "VM Network"
fi

