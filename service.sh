#!/usr/bin/env bash
. /vagrant/vsim.conf
sudo apt-get -y update
sudo apt-get -y install dnsmasq sshpass
BASEIP=`echo $NODE_MGMT_IP | cut -d"." -f1-3`
cat <<EOF >> /etc/dnsmasq.conf
dhcp-range=$BASEIP.60,$BASEIP.62,12h
dhcp-host=08:00:DE:AD:AC:1D,vsim,$NODE_MGMT_IP,infinite
log-dhcp
EOF
sudo /etc/init.d/dnsmasq restart

sudo iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 22222 -j REDIRECT --to-port 22
