#!/bin/bash
LATEST=`ls -1 files | grep uda30P | sed 's/uda30P//g' | sort -n | tail -1`
tar -C files -cvzf uda30P${LATEST}.tgz .
if [ -L latest ]
then
  rm latest
fi
ln -sf uda30P${LATEST}.tgz latest
