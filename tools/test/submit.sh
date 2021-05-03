#!/bin/bash
DATADIR=$1
TIMEOUT=$2

if [ "$DATADIR" == "" ]
then
  echo 'Usage: $0 <datadir>'
  exit 1
fi

if [ "$TIMEOUT" == "" ]
then
  TIMEOUT=60
fi

echo Submitting $DATADIR

URLPATH=/cgi-bin/uda3.pl
PARAMDATA="--data-urlencode"
PARAMFILE="--data-urlencode"

#### read global settings.conf file
while read var
do
  key=`echo $var |   sed -E 's/^([^=]*)=(.*)/\1/g'`
  value=`echo $var | sed -E 's/^([^=]*)=(.*)/\2/g'`
  export $key="$value"
done < settings.conf

if [ -f $DATADIR/settings.conf ]
then
  while read var
  do
    key=`echo $var |   sed -E 's/^([^=]*)=(.*)/\1/g'`
    value=`echo $var | sed -E 's/^([^=]*)=(.*)/\2/g'`
    export $key="$value"
  done < $DATADIR/settings.conf
fi

UDAURL=http://$UDA_IP$URLPATH
PROGRESSURL=http://$UDA_IP/cgi-bin/progress.cgi
CURLCMD="curl -s -u $UDA_USER:$UDA_PASSWORD $UDAURL"

###### add url encoded file for e.g. KICKSTARTFILE
while read filename
do
  param=`basename -s .dat $filename`
  CURLCMD=$CURLCMD\ $PARAMFILE\ $param@$DATADIR/$param.dat
done < <(ls -1 $DATADIR/*.dat 2>/dev/null)

###### add file for upload
while read binfilename
do
  param=`basename -s .bin $binfilename`
  linktarget=`readlink $binfilename`
  CURLCMD=$CURLCMD\ $PARAMFILE\ "$param=@$DATADIR/$linktarget"
done < <(ls -1 $DATADIR/*.bin 2>/dev/null)

#### read defaults from data directory
while read data
do
  key=`echo $data |   sed -E 's/^([^=]*)=(.*)/\1/g'`
  value=`echo $data | sed -E 's/^([^=]*)=(.*)/\2/g'`
  CURLCMD=$CURLCMD\ $PARAMDATA\ $key=\"$value\"
done < $DATADIR/default.conf

#echo $CURLCMD
#exit 1
#eval "$CURLCMD"

ACTIONLINEID=`eval "$CURLCMD" | tee out/submit.out | grep -i 'Update'`
if [ "$ACTIONLINEID" == "" ]
then
  echo SUCCESS
  exit 0
fi
ACTIONID=`echo $ACTIONLINEID | sed 's/[^0-9]//g'`

while true
do
  PROGRESSCMD="curl -s -u $UDA_USER:$UDA_PASSWORD $PROGRESSURL --data actionid=$ACTIONID"
  STATUS=`$PROGRESSCMD`
  PERCENT=`echo $STATUS|awk '{print $1}' FS=\/`
  STATUSTEXT=`echo $STATUS | sed -E 's/^([^\/]*)\/(.*)/\2/g'`
  echo Action $ACTIONID Cycle $TIMEOUT: Progress $PERCENT\% Status: $STATUSTEXT
  TIMEOUT=`echo $TIMEOUT -1 | bc`
  if [ $PERCENT == 100 ]
  then
    echo SUCCESS
    exit 0
  fi
  if [ $PERCENT -lt 0 ]
  then
    echo FAILED
    exit 1
  fi
  if [ $TIMEOUT -lt 1 ]
  then
    echo TIMEOUT
    exit 2
  fi
  sleep 2
done

exit 1
