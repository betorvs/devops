#!/bin/bash

DIR="/mnt/docker"

DIRP="$DIR/$2"
PORT="$3"

base(){

DIRP="$1"

if [ -n "$DIRP" ] ;then

mkdir -p "$DIRP" && echo "Diretorio: $DIRP"

mkdir -p $DIRP/yum.repos.d/
cp /etc/yum.repos.d/* $DIRP/yum.repos.d/
cp -r /opt/puppet $DIRP/

echo "Montando diretorio em: /vol"
echo "Salve seus arquivos em /vol antes de sair do docker/Matar a instancia"
echo "Execute: /vol/puppet/install-oirepo.sh"
echo ""

fi

}

common(){

 echo "docker run --rm -t -v $DIRP:/vol -i centos:centos6 /bin/bash"
 docker run --rm -t -v $DIRP:/vol -i centos:centos6 /bin/bash

}

network(){
DIRP="$1"
PORT="$2"
if [ -n $PORT ] ; then

 HOST=`ifconfig eth0 |grep "inet addr" |awk '{print $2}'|cut -f2 -d":"`
 echo "docker run --rm -t -p $PORT:$PORT -h $HOST -v $DIRP:/vol -i centos:centos6 /bin/bash"
 docker run --rm -t -p $PORT:$PORT -h $HOST -v $DIRP:/vol -i centos:centos6 /bin/bash
fi
}

case $1 in
	run)
		base $DIRP;
		common $DIRP;
		;;
	net)
		base $DIRP;
		network $DIRP $PORT;
		;;

	*)
	echo "USE: $0 run DIRETORIOLOCAL"
	echo "USE: $0 net DIRETORIOLOCAL PORTATCP"
	;;

esac


