#!/bin/bash

file=$1

while IFS=',' read -r f1 f2 f3 f4
do
  HOSTNAME=`echo ${f1}.drac.infra`
  IFACE=$f2
  IP=$f3
  MAC=$f4
  echo "dcm.pl -r host_add host=$HOSTNAME type=2 ip=$IP mac=$MAC name=$IFACE notes=IP_Acesso_as_Drac"
done < "$file"
