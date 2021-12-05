#!/bin/bash

PATCHDIR=$1
echo Installing Patch Cluster
echo PATCHDIR=$PATCHDIR
ls -1 $PATCHDIR | grep uda30P | while read patch
do
  echo Installing patch $patch
  chmod 755 $PATCHDIR/$patch/install.sh
  $PATCHDIR/$patch/install.sh $PATCHDIR/$patch
done

