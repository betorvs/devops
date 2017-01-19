#!/bin/bash

DIR="$PWD/$1"

case $2 in 
  centos7)
    SO="centos:centos7"
    ;;
  centos6)
    SO="centos:centos6"
    ;;
  centos5)
    SO="centos:centos5"
    ;;
  debian)
    SO="debian:wheezy"
   ;;
  *)
    SO="centos:centos6"
   ;;

esac
echo "docker run --rm -t -v $DIR:/vol -i $SO /bin/bash"
docker run --rm -t -v $DIR:/vol -i $SO /bin/bash
