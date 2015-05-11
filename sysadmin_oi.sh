#!/bin/bash
#
# script versão 1.0 - roberto.scudeller
#
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

# use: validate $MAC $VLAN $HOSTNAME
validate(){

MAC=$1
VLAN=$2

echo $MAC |grep -q "^\([0-9A-Fa-f]\{2\}:\)\{5\}[0-9A-Fa-f]\{2\}$" || exit 5
dcm.pl -r interface_display interface=$MAC 1>/dev/null
if [ $? = 0 ]; then
 echo "$MAC in use!"
 exit 5
fi

##Se a vlan nao existe, para por aqui
dcm.pl -r subnet_display subnet=$VLAN 1>/dev/null
if [ $? = 2 ] ; then
        echo "VLAN NAO EXISTE. Verifique o nome correto!"
        exit 2
fi

}

newhost() {

if [ "$#" -eq "5" ]; then
 VLAN=$1
 HOSTNAME=$2
 IFACE=$3
 MAC=$4
 TYPE=$5
else 

echo "Defina VLAN:"
read VLAN

echo "Defina o HOSTNAME (Use FQDN!):"
read HOSTNAME

echo "Entre com a interface (ex. eth0):"
read IFACE

echo "Entre o MAC da interface:"
read MAC

echo "Type(use 10 if you dont knows): "
read TYPE

fi

if [ -z $TYPE ]; then
 TYPE="10"
fi

validate $MAC $VLAN
dcm.pl -r host_display host=$HOSTNAME 1>/dev/null
if [ $? = 0 ] ; then
 echo "$HOSTNAME Existe"
 exit 2
fi

# Lista proximo ip disponivel
IP_FREE=`dcm.pl -r subnet_nextip subnet=$VLAN  output=dotted`
#Adiciona o host e aloca ip na vlan
echo "add $HOSTNAME na VLAN $VLAN"
 echo "dcm.pl -r host_add host=$HOSTNAME type=$TYPE ip=$IP_FREE mac=$MAC name=$IFACE notes=https://puppetmaster.oi.infra/hosts/$HOSTNAME"
if [ $? = 0 ] ; then
 echo "add DNS A record"
 #echo " /usr/sbin/pdnsadmin --add -t A -n $HOSTNAME -c $IP_FREE"
 /usr/sbin/pdnsadmin --add -t A -n $HOSTNAME -c $IP_FREE
 echo "add DNS PTR record"
 #echo " /usr/sbin/pdnsadmin --add -t PTR -n $IP_FREE -c $HOSTNAME -z 10.in-addr.arpa"
 /usr/sbin/pdnsadmin --add -t PTR -n $IP_FREE -c $HOSTNAME -z 10.in-addr.arpa
else
 echo "Dont create DNS records because command dcm.pl host_add with problems"
fi 

}

newinterface() {

if [ "$#" -eq "5" ]; then
 VLAN=$1
 HOSTNAME=$2
 IFACE=$3
 MAC=$4
 TYPE=$5
else

echo "Defina VLAN:"
read VLAN

echo "Defina o HOSTNAME (Use FQDN!):"
read HOSTNAME

echo "Entre com a interface (ex. eth0):"
read IFACE

echo "Entre o MAC da interface:"
read MAC

echo "Type(use 10 if you dont knows): "
read TYPE

fi

if [ -z $TYPE ]; then
 TYPE="10"
fi

validate $MAC $VLAN
dcm.pl -r host_display host=$HOSTNAME 1>/dev/null
if [ $? = 2 ] ; then
 echo "Dont find this hostname: $HOSTNAME !"
 exit 2
fi
IP_FREE=`dcm.pl -r subnet_nextip subnet=$VLAN  output=dotted`
echo "add interface=$IFACE on $HOSTNAME with $IP_FREE "
#echo "dcm.pl -r interface_add host=$HOSTNAME type=$TYPE ip=$IP_FREE name=$IFACE mac=$MAC"
dcm.pl -r interface_add host=$HOSTNAME type=$TYPE ip=$IP_FREE name=$IFACE mac=$MAC

}

deletehost() {

if [ -z $1 ]; then
 echo "Enter Hostname to DELETE!:"
 read HOSTNAME
else
 HOSTNAME=$1
fi

dcm.pl -r host_display host=$HOSTNAME 1>/dev/null
if [ $? = 2 ] ; then
 echo "Dont find this hostname: $HOSTNAME !"
 exit 2
fi

IPS=`dcm.pl -r host_display host=$HOSTNAME| grep "ip_addr " |awk '{ print $2}'`
for ip in $IPS; do
 IP_FREE=`echo $ip`
 #echo "/usr/sbin/pdnsadmin --remove -t A -n $HOSTNAME -c $IP_FREE"
 /usr/sbin/pdnsadmin --remove -t A -n $HOSTNAME -c $IP_FREE
 #echo "/usr/sbin/pdnsadmin --remove -t PTR -n $IP_FREE -c $HOSTNAME"
 /usr/sbin/pdnsadmin --remove -t PTR -n $IP_FREE -c $HOSTNAME
done 
 #echo "dcm.pl -r host_del host=$HOSTNAME"
 dcm.pl -r host_del host=$HOSTNAME

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
		newhost $2 $3 $4 $5 $6;
		;;
	addif)
		newinterface $2 $3 $4 $5 $6;
		;;
	del)
		deletehost $2;
		;;
		
	*)
		echo "Usage: $0 (install|search|new|add)"
		echo ""
		echo "Usage: $0 install -> Use to install packages pdnsadmin and dcm.pl"
		echo ""
		echo "Usage: $0 search HOSTNAME -> Use to search a name in ipmgmt and dns. If you dont set a hostname, it ask you!"
		echo ""
		echo "Usage: $0 new -> To create a new hostname in ipmgmt and dns"
		echo "Attention!!! You need a MAC Address to config a hostname in ipmgmt.oi.infra"
		echo "For interface type \"(VMware, vm - Centos (server)\" = 10"
		echo "For interface type \"(Juniper, Juniper (router))\" = 11"
		echo "For interface type \"(Dell, R610 (server))\" = 9"
		echo ""
		echo "Usage: $0 new VLAN HOSTNAME INTERFACE MAC-ADDRESS TYPE"
		echo ""
		echo "Usage: $0 addif -> To add new interface in ipmgmt.oi.infra"
		echo ""
		echo "Usage: $0 del -> To delete a hostname in ipmgmt.oi.infra and dns"
		echo ""
		;;
esac
