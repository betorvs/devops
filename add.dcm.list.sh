#!/bin/bash

file=$1

outputdcm=$2
outputpdns=$3

> $outputdcm
> $outputpdns

while IFS=',' read -r f1 f2 f3 f4
do
  HOSTNAME=`echo ${f1}.drac.infra`
  IFACE="console0"
  IP=`dcm.pl -r subnet_nextip subnet=console_2964 output=dotted`
  POS=$f3
  RACK=$f4
  echo "dcm.pl -r host_add host=$HOSTNAME type=2 ip=$IP name=$IFACE notes=IP_Acesso_as_Drac-${POS}_${RACK}" >> $outputdcm
  echo "pdnsadmin --add -t A -n $HOSTNAME -c $IP" >> $outputpdns
  echo "pdnsadmin --add -t PTR -n $IP -c $HOSTNAME -z 10.in-addr.arpa" >> $outputpdns
done < "$file"
