#!/bin/bash

BASEDIR=~/uda/ultimatedeployment
BUILDDIR=$BASEDIR/tools/build
TMPDIR=$BUILDDIR/tmp

#### read global settings.conf file
while read var
do
  key=`echo $var |   sed -E 's/^([^=]*)=(.*)/\1/g'`
  value=`echo $var | sed -E 's/^([^=]*)=(.*)/\2/g'`
  export $key="$value"
done < $BUILDDIR/settings.conf

VMNAME=uda30
VMXDIR=/vmfs/volumes/datastore01/uda30
VMXFILE=$VMXDIR/uda30.vmx
VMDKFILE=$VMXDIR/uda30.vmdk
VM_STATIC_MAC=10:0c:29:53:41:c7

function step1()
{
  echo Step 1 change build number
  UPGRADESCRIPT=$BASEDIR/var/public/bin/upgrade3.0.sh
  TMPUPGRADESCRIPT=$TMPDIR/upgradescript.tmp.$$
  echo "  DEBUG: using $UPGRADESCRIPT"
  CURRENTBUILD=`cat $UPGRADESCRIPT | grep 'export BUILD=' 2>/dev/null | awk '{print $2}' FS==`
  echo "  DEBUG: CURRENTBUILD=$CURRENTBUILD"
  NEWBUILD=`echo " $CURRENTBUILD + 1" | bc` 
  echo "  DEBUG: NEWBUILD=$NEWBUILD"
  echo "  INFO:  Changing build number in $UPGRADESCRIPT"
  sed "s/export BUILD=.*/export BUILD=$NEWBUILD/g" $UPGRADESCRIPT > $TMPUPGRADESCRIPT
  if [ $? -ne 0 ]
  then
    echo "  ERROR!: Could not change the buildnumber in $UPGRADESCRIPT"
    exit 1
  else
    echo "  DEBUG: Created temporary upgradescript $TMPUPGRADESCRIPT with build number $NEWBUILD"
    mv $TMPUPGRADESCRIPT $UPGRADESCRIPT
    if [ $? -ne 0 ]
    then
      echo "  ERROR: Could not move temporary upgrade script $TMPUPGRADESCRIPT to final location $UPGRADESCRIPT"
      exit 2
    fi
  fi
  chmod 755 $UPGRADESCRIPT
  echo "  INFO:  Changed builnumber in $UPGRADESCRIPT to $NEWBUILD succesfully"
}

function step2()
{
  echo Step 2 Building package
  PACKAGE=$TMPDIR/uda30.tgz
  echo "  DEBUG: PACKAGE=$PACKAGE"
  echo "  INFO: Removing current zip packages with ova templates"
  WWWDIR=$BASEDIR/var/public/www
  ESXZIP=$WWWDIR/esxova.zip
  VBOXZIP=$WWWDIR/vboxova.zip
  rm -f $ESXZIP
  rm -f $VBOXZIP
  echo "  INFO: Createing new zip packages with ova templates"
  cd $WWWDIR
  zip -r $ESXZIP esx/ >$TMPDIR/esxzip.out 2>$TMPDIR/esxzip.err
  if [ $? -ne 0 ]
  then
    echo "  ERROR: Could not create a zipfile $ESXZIP"
    cd - >/dev/null
    exit 5
  fi
  zip -r $VBOXZIP vbox/ >$TMPDIR/vboxzip.out 2>$TMPDIR/vboxzip.err
  if [ $? -ne 0 ]
  then
    echo "  ERROR: Could not create a zipfile $VBOXZIP"
    cd - >/dev/null
    exit 5
  fi
  cd - >/dev/null
  echo "  INFO:  Created ova zipfiles $ESXZIP and $VBOXZIP succesfully"
  echo "  INFO:  Createing new build package file"
  tar -C $BASEDIR -cvzf $PACKAGE var/ >$TMPDIR/tar.out 2>$TMPDIR/tar.err
  if [ $? -ne 0 ]
  then
    echo "  ERROR: Could not create tar file $PACKAGE"
    exit 3
  fi
  echo "  INFO:  Created $PACKAGE succesfully"
  
  echo "TODO: Change this to an upload to /local on the UDA and publish it via a link in www dir"
  scp $PACKAGE uda:/var/public/www/ >$TMPDIR/scp_to_uda.out 2>$TMPDIR/scp_to_uda.err
  if [ $? -ne 0 ]
  then
    echo "  ERROR: Could not publish package $PACKAGE to the UDA"
    exit 12
  fi
  
}

function step3()
{
  echo Step 3 Starting setup
  echo "  INFO:  Cleaning up previous build"
  
  VMID=`ssh esx "vim-cmd vmsvc/getallvms" |grep -E "^[0-9]+\s+$VMNAME\s+" | awk '{print $1}'`
  if [ "$VMID" == "" ]
  then
    echo "  INFO: Could not get current VMID for $VMNAME, assuming it is not there and continuing..."
  else
    echo "  INFO: Found current VM $VMNAME with id =$VMID="
    ssh esx "vim-cmd vmsvc/power.off $VMID" >$TMPDIR/poweroff_old_build.out 2>$TMPDIR/poweroff_old_build.err
    ssh esx "vim-cmd vmsvc/destroy $VMID" >$TMPDIR/destroy_old_build.out 2>$TMPDIR/destroy_old_build.err
    if [ $? -ne 0 ]
    then
      echo "  ERROR: Could not power off and/or destroy $VMNAME"
      exit 6
    else
      echo "  INFO:  shutdown and destroyed old vm $VMNAME" 
    fi
    echo "  INFO: Purging VM directory $VMXDIR"
    ssh esx "rm -rf $VMXDIR" 
  fi
  
  echo "  INFO:  Deploying new empty ova file"
  ovftool -ds=$UDA_OVA_DATASTORE -dm=thin --net:"Testlab1Portgroup1"="$UDA_OVA_VM_NETWORK" -n=uda30 $BUILDDIR/uda30.ova vi://$UDA_OVA_VI_USERNAME:$UDA_OVA_VI_PASSWORD@$UDA_OVA_VI_IP/ >$TMPDIR/deploy_$VMNAME.out 2>$TMPDIR/deploy_$VMNAME.err
  
  NEWVMID=`ssh esx "vim-cmd vmsvc/getallvms" |grep -E "^[0-9]+\s+$VMNAME\s+" | awk '{print $1}'`
  if [ "$NEWVMID" == "" ]
  then
    echo "  ERROR: Could not get the VMID for the new VM $VMNAME"
    exit 7
  else
    echo "  INFO: Found new VM $VMNAME with id =$NEWVMID="
  fi
  
  echo "  INFO:  Changing MAC address to make sure the installation is automatically picked up"
  ssh esx "vim-cmd vmsvc/unregister $NEWVMID"
  ssh esx "sed -i -E -e 's/^ethernet0.addressType = \\\"[^\\\"]+\\\"/ethernet0.addressType = \\\"static\\\"/g' $VMXFILE"
  ssh esx "echo ethernet0.address = \\\"$VM_STATIC_MAC\\\" >> $VMXFILE"
  ssh esx "vim-cmd solo/registervm $VMXFILE" >$TMPDIR/register_with_new_mac.out 2>$TMPDIR/register_with_new_mac.err
  if [ $? -ne 0 ]
  then
    echo "  ERROR: Could not register VM with vmx file $VMXFILE"
    exit 8
  fi
  echo "  INFO:  Registered the VM $VMNAME with new MAC address $VM_STATIC_MAC succesfully"
  
}

step4()
{
  echo "  TODO: Change this to a curl command to the UDA"
  echo "  INFO:  Starting DHCP on the UDA"
  ssh uda service dhcpd start >$TMPDIR/start_dhcp.out 2>$TMPDIR/start_dhcp.err

  echo "  INFO:  Finding the VMID of the vm to build"
  VMID=`ssh esx "vim-cmd vmsvc/getallvms" |grep -E "^[0-9]+\s+$VMNAME\s+" | awk '{print $1}'`
  if [ "$VMID" == "" ]
  then
    echo "  ERROR: Could not get the VMID for the new VM $VMNAME"
    exit 7
  else
    echo "  INFO: Found new VM $VMNAME with id =$VMID="
  fi
  echo "  INFO:  Powering on VM"
  ssh esx "vim-cmd vmsvc/power.on $VMID" >$TMPDIR/boot_for_pxe_install.out 2>$TMPDIR/boot_for_pxe_install.err
  if [ $? -ne 0 ]
  then
    echo "ERROR:  Could not power on VM"
    exit 9
  fi
  sleep 5
  ssh esx "vim-cmd vmsvc/power.getstate $VMID" | grep Powered\ on > /dev/null
  if [ $? -eq 0 ]
  then
    echo "  INFO:  The VM is powered on, lets wait until it powers off again"
  fi
  SLEEPSEC=5
  ITERATIONS=200
  seq 1 $ITERATIONS | while read loopnr
  do
    # echo Loop $loopnr of $ITERATIONS sleeping for $SLEEPSEC seconds
    sleep $SLEEPSEC
    ssh -n esx "vim-cmd vmsvc/power.getstate $VMID" | grep Powered\ off > /dev/null
    if [ $? -eq 0 ]
    then
      echo "  INFO: (loop $loopnr of $ITERATIONS) The system is powered off, lets continue"
      break
    else
      echo "  INFO:  (loop $loopnr of $ITERATIONS) The system is still powered on"
    fi
  done
  if [ "$seq" == "$ITERATIONS" ]
  then
    echo "ERROR: Timeout waiting for system to go down"
    exit 9
  fi
  echo "  INFO:  The system was installed succesfully"
  ssh esx "vim-cmd vmsvc/unregister $VMID"
  if [ $? -ne 0 ]
  then
    echo "  ERROR: Could not unregister the VM"
    exit 10
  fi
  echo "  INFO:  unregistered succesfully"
}


step5()
{

  echo Step 5 Start VM and wait for firstboot script to turn the VM off again

  ssh esx "sed -i -E -e 's/^ethernet0.address = \\\"[^\\\"]+\\\"/ethernet0.generatedAddress = \\\"00:0c:29:53:41:c7\\\"/g' $VMXFILE"
  ssh esx "sed -i -E -e 's/^ethernet0.addressType = \\\"[^\\\"]+\\\"/ethernet0.addressType = \\\"generated\\\"/g' $VMXFILE"
  ssh esx "vim-cmd solo/registervm $VMXFILE" >$TMPDIR/register_after_post_script.out 2>$TMPDIR/register_after_post_script.err

  echo "  INFO:  Finding the VMID of the vm to build"
  VMID=`ssh esx "vim-cmd vmsvc/getallvms" |grep -E "^[0-9]+\s+$VMNAME\s+" | awk '{print $1}'`
  if [ "$VMID" == "" ]
  then
    echo "  ERROR: Could not get the VMID for the new VM $VMNAME"
    exit 7
  else
    echo "  INFO: Found new VM $VMNAME with id =$VMID="
  fi

  echo "  INFO:  Powering on VM and waiting for shutdown"
  ssh esx "vim-cmd vmsvc/power.on $VMID" >$TMPDIR/poweron_firstboot.out 2>$TMPDIR/poweron_firstboot.err
  sleep 5
  ssh esx "vim-cmd vmsvc/power.getstate $VMID" | grep Powered\ on > /dev/null
  if [ $? -eq 0 ]
  then
    echo "  INFO: The system is powered on starting wait until it powers off again"
  else 
    echo "  ERROR: the system did not get powered on for firstboot"
    exit 11
  fi

  SLEEPSEC=5
  ITERATIONS=400
  seq 1 $ITERATIONS | while read loopnr
  do
    sleep $SLEEPSEC
    ssh -n esx "vim-cmd vmsvc/power.getstate $VMID" | grep Powered\ off > /dev/null
    if [ $? -eq 0 ]
    then
      echo "  INFO:  $loopnr of $ITERATIONS: System has powered off"
      break
    else 
      if [ $loopnr -eq $ITERATIONS ]
      then
        echo "  ERROR: The system is still powered on quitting"
        exit 11
      else
        echo "  INFO:  $loopnr of $ITERATIONS: Waiting for system to shut down"
      fi
    fi
  done
  
}

function step6()
{
  echo Step 6 Create build from Installed VM
  ssh uda service dhcpd stop >$TMPDIR/uda_stop_dhcp.out 2>$TMPDIR/uda_stop_dhcp.err

  echo "  INFO:  Finding the VMID of the vm to build"
  VMID=`ssh esx "vim-cmd vmsvc/getallvms" |grep -E "^[0-9]+\s+$VMNAME\s+" | awk '{print $1}'`
  if [ "$VMID" == "" ]
  then
    echo "  ERROR: Could not get the VMID for the new VM $VMNAME"
    exit 7
  else
    echo "  INFO: Found new VM $VMNAME with id =$VMID="
  fi

  echo "  INFO:  Unregistering VM"
  ssh esx "vim-cmd vmsvc/unregister $VMID" >/dev/null

  echo "  INFO:  Adjusting VM memory"
  ssh esx sed -i -E -e 's/memSize\ =\ \"2048\"/memSize\ =\ \"512\"/g' $VMXFILE

  echo "  INFO:  Adjusting VM network"
  ssh esx "sed -i -E -e 's/ethernet0.networkName\ =\ \"Install Network\"/ethernet0.networkName\ =\ \"VM Network\"/g' $VMXFILE"

  echo "  INFO:  Registering VM"
  ssh esx "vim-cmd solo/registervm $VMXFILE" >$TMPDIR/register_vm_pre_export.out 2>$TMPDIR/register_vm_pre_export.err

  echo "  INFO:  Punching holes"
  ssh esx vmkfstools -K $VMDKFILE >$TMPDIR/punching_holes.out 2>$TMPDIR/punching_holes.err

  BUILDFILE=$TMPDIR/uda30build${NEWBUILD}.ova

  echo "  INFO:  Exporting OVA file "
  ovftool --net:"Install Network"="VM Network" --targetType=OVA vi://$UDA_OVA_VI_USERNAME:$UDA_OVA_VI_PASSWORD@$UDA_OVA_VI_IP/uda30 $BUILDFILE
  
}

function step7()
{

  echo Step 7 Reconfigure the VM network for autoconfig and start

  echo "  INFO:  Finding the VMID of the vm to build"
  VMID=`ssh esx "vim-cmd vmsvc/getallvms" |grep -E "^[0-9]+\s+$VMNAME\s+" | awk '{print $1}'`
  if [ "$VMID" == "" ]
  then
    echo "  ERROR: Could not get the VMID for the new VM $VMNAME"
    exit 7
  else
    echo "  INFO: Found new VM $VMNAME with id =$VMID="
  fi

  ssh esx "vim-cmd vmsvc/unregister $VMID"

  ssh esx "sed -i -E -e 's/ethernet0.networkName\ =\ \"VM Network\"/ethernet0.networkName\ =\ \"Install Network\"/g' $VMXFILE"
  ssh esx "echo 'ide0:0.deviceType = \"cdrom-image\"' >> $VMXFILE"
  ssh esx "echo 'ide0:0.fileName = \"/vmfs/volumes/datastore01/udaesx.iso\"' >> $VMXFILE"
  ssh esx "echo 'ide0:0.present = \"TRUE\"' >> $VMXFILE"
  ssh esx "vim-cmd solo/registervm $VMXFILE" >$TMPDIR/register_vm_for_autosetup.out 2>$TMPDIR/register_vm_for_autosetup.err

  echo "  INFO:  Finding the VMID of the vm to build"
  VMID=`ssh esx "vim-cmd vmsvc/getallvms" |grep -E "^[0-9]+\s+$VMNAME\s+" | awk '{print $1}'`
  if [ "$VMID" == "" ]
  then
    echo "  ERROR: Could not get the VMID for the new VM $VMNAME"
    exit 7
  else
    echo "  INFO: Found new VM $VMNAME with id =$VMID="
  fi

  ssh esx "vim-cmd vmsvc/power.on $VMID" > $TMPDIR/final_poweron.out 2>$TMPDIR/final_poweron.err

}

step1
step2
step3
step4
step5
step6
step7
echo Created build $NEWBUILD succesfully: $BUILDFILE
exit 0
