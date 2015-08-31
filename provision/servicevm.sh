#!/usr/bin/env bash
. /vagrant/vsim.conf
sudo apt-get -y update
sudo apt-get -y install dnsmasq sshpass git unzip
BASEIP=`echo $NODE_MGMT_IP | cut -d"." -f1-3`
sudo sh -c "cat <<EOF >> /etc/dnsmasq.conf
dhcp-range=$BASEIP.60,$BASEIP.62,12h
dhcp-host=08:00:DE:AD:AC:1D,vsim,$NODE_MGMT_IP,infinite
log-dhcp
EOF"
sudo /etc/init.d/dnsmasq restart

sudo iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 22222 -j REDIRECT --to-port 22

echo "Preparing Chef"
sudo su $OS_USER -c "cp -R /vagrant/chef /home/vagrant/"
sudo su $OS_USER -c "cd /home/vagrant/chef/cookbooks && git clone https://github.com/chef-partners/netapp-cookbook.git netapp"

sudo su $OS_USER -c "cd && unzip /vagrant/netapp-manageability-sdk*.zip && cp netapp-manageability-sdk*/lib/ruby/NetApp/* /home/vagrant/chef/cookbooks/netapp/libraries && rm -Rf netapp-manageability-sdk*"
sudo su $OS_USER -c "sed -i \"s/require 'NaElement/require File.dirname(__FILE__) + '\/NaElement/g\" /home/vagrant/chef/cookbooks/netapp/libraries/NaServer.rb"
chown $OS_USER:$OS_USER /home/vagrant/chef/cookbooks/netapp/libraries/*
