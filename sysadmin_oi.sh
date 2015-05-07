#!/bin/bash

instalar() {

mkdir -p /etc/dcm
chmod 700 /etc/dcm
wget http://repo.oi.infra/Centos/pub/dcm.conf -O /etc/dcm/dcm.conf
wget http://repo.oi.infra/Centos/pub/dcm.pl -O /usr/sbin/dcm.pl
chmod 700 /usr/sbin/dcm.pl

### Correcao e instalacao do python2.7
rm -rf /usr/lib/python2.7/site-packages
ln -s /usr/lib/python2.7/dist-packages /usr/lib/python2.7/site-packages
#
apt-get -y install python2.7 python2.7-minimal
####Faz o cadastro de dns via pdnsadmin
apt-get install -y python-ipaddr python-mysql.connector python-ldap python-dns python-mysqldb
cd /tmp
wget http://repo.oi.infra/Centos/pub/python-pydns_2.3.6-2_all.deb -O /tmp/python-pydns_2.3.6-2_all.deb
dpkg -i /tmp/python-pydns_2.3.6-2_all.deb
#
mkdir /tmp/pdns && cd /tmp/pdns
wget http://repo.oi.infra/Centos/pub/pdns.tar
wget http://repo.oi.infra/Centos/pub/py-pdns-plugins.tar
wget http://repo.oi.infra/Centos/pub/py-pdns.cfg
wget http://repo.oi.infra/Centos/pub/pdnsadmin2.7
cd /usr/lib/python2.7/site-packages/ && tar xvf /tmp/pdns/pdns.tar
cd /usr/lib/ && tar xvf /tmp/pdns/py-pdns-plugins.tar
cp /tmp/pdns/py-pdns.cfg /etc/
cp /tmp/pdns/pdnsadmin2.7 /usr/sbin/pdnsadmin && chmod +x /usr/sbin/pdnsadmin

}

newhost() {

echo "Defina VLAN:"
read VLAN

echo "Defina o HOSTNAME:"
read HOSTNAME

echo "Entre com a interface (ex. eth0):"
read IFACE

echo "Entre o MAC da interface:"
read MAC

echo $MAC |grep -q "^\([0-9A-Fa-f]\{2\}:\)\{5\}[0-9A-Fa-f]\{2\}$" || exit 2

#Se a vlan nao existe, para por aqui
dcm.pl -r subnet_display subnet=$VLAN 1>/dev/null
if [ $? = 2 ] ; then
        echo "VLAN NAO EXISTE. Verifique o nome correto!"
        exit 2
fi

dcm.pl -r host_display host=$HOSTNAME 1>/dev/null
if [ $? = 0 ] ; then
 echo "$HOSTNAME Existe"
 exit 2
fi

# Lista proximo ip disponivel
IP_FREE=`dcm.pl -r subnet_nextip subnet=$VLAN  output=dotted`
#Adiciona o host e aloca ip na vlan
echo "add $HOSTNAME na VLAN $VLAN"
dcm.pl -r host_add host=$HOSTNAME type=10 ip=$IP_FREE mac=$MAC name=$IFACE notes=https://puppetmaster.oi.infra/hosts/$HOSTNAME
if [ $? = 0 ] ; then
 echo "add DNS A record"
 /usr/sbin/pdnsadmin --add -t A -n $HOSTNAME -c $IP_FREE
 echo "add DNS PTR record"
 /usr/sbin/pdnsadmin --add -t PTR -n $IP_FREE -c $HOSTNAME -z 10.in-addr.arpa 
else
 echo "Dont create DNS records because command dcm.pl host_add with problems"
fi 

}

search() {

if [ -z $1 ]; then
 echo "Defina o HOSTNAME:"
 read HOSTNAME
 else 
 HOSTNAME=$1
fi

echo "searching $HOSTNAME in ipmgmt.oi.infra"
dcm.pl -r host_display host=$HOSTNAME

echo "searching $HOSTNAME in DNS records"
/usr/sbin/pdnsadmin --list -z oi.infra |grep $HOSTNAME
/usr/sbin/pdnsadmin --list -z 10.in-addr.arpa |grep $HOSTNAME

}

case $1 in
	install)
		instalar;
		;;
	search)
		search $2;
		;;
	new)
		newhost;
		;;
		
	*)
		echo "Usage: $0 (install|new|search)"
		echo ""
		echo "Usage: $0 install -> Use to install packages pdnsadmin and dcm.pl"
		echo ""
		echo "Usage: $0 search HOSTNAME -> Use to search a name in ipmgmt and dns. If you dont set a hostname, it ask you!"
		echo ""
		echo "Usage: $0 new -> To create a new hostname in ipmgmt and dns, with interface type \"(VMware, vm - Centos (server)\""
		echo "Attention!!! You need a MAC Address to config a hostname in ipmgmt.oi.infra"
		echo ""
		;;
esac
