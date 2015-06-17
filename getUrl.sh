#!/bin/bash

URL="$1"
GREP="$2"
TIME="$3"

if [ "$#" -lt "3" ]; then
 echo "Use: $0 URL STRING TIMES"
 exit 1
fi


date
for a in `seq 1 $TIME`; do
 curl "$URL" 2>/dev/null |grep "$GREP" >/dev/null && echo "tentativa N $a : [  OK  ]"
 sleep 1
done
date
