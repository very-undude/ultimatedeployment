#!/bin/sh

IPADDR=$1
MACADDR=$2

LOGFILE=/var/public/log/tftpd.log

NEWMAC=`echo $MACADDR | sed 's/\:/-/g' | /bin/cut -c 1-17`

PREVIP=`tail -1000 $LOGFILE | grep $NEWMAC | grep RRQ | tail -1 | awk '{print $8}'`

OUTPUT=`tail -1000 $LOGFILE | \
  grep "RRQ from $PREVIP " | \
  grep wdsnbp.0 | \
  tail -1 | \
  awk '{print $3 " " $4}' FS=\/`

echo $OUTPUT UNKNOWN UNKNOWN

