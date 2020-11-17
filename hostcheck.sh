#!/bin/sh
HOST=$1
TIMESTAMP=$(date +%Y-%m-%dT%H:%M:%S%z)

alias sendmail=/usr/sbin/sendmail

if [ -z "$1" ]
then
	echo "Missing argument 1" 1>&2
	exit 1
fi

if [ -z "$2" ]
then
	echo "Missing argument 2" 1>&2
	exit 2
fi

if [-z "$3" ]
then
	echo "Missing argument 3" 1>&2
	exit 3
fi

cd $2 2>/dev/null
RET=$?

if [ $RET -ne 0 ]
then
	echo "Error changing to directory: $2" 1>&2	
	exit 3
fi

if fping -t 50 $1 > /dev/null
then
	STATUS_SHORT="UP"
	STATUS="UP,$1,$?"
else
	STATUS_SHORT="NO RESPONSE"
	STATUS="NR,$1,$?"
fi

LAST="$(cat H$1_LAST 2>/dev/null)"

if [ "$STATUS" != "$LAST" ]
then
	printf "Subject: Status change $1 now $STATUS_SHORT\r\n\r\nHost $1:\r\n\tLast reported status: $LAST\r\n\tNew reported status: $STATUS" | sendmail "$3" 
	echo $STATUS > "H$1_LAST"
fi

echo "$TIMESTAMP,$STATUS" >> host_check.log

