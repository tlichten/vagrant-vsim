#!/usr/bin/env bash
. /vagrant/vsim.conf

cd /tmp && wget https://apt.puppetlabs.com/puppetlabs-release-trusty.deb && sudo dpkg -i puppetlabs-release-trusty.deb

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y install dnsmasq sshpass git unzip puppet puppetmaster
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

echo "Preparing Puppet"
sudo cp -R /vagrant/puppet/device.conf /etc/puppet/device.conf
sudo cp -R /vagrant/puppet/site.pp /etc/puppet/manifests/site.pp
sudo git clone https://github.com/puppetlabs/puppetlabs-netapp.git /etc/puppet/modules/netapp
sudo su $OS_USER -c "cd && unzip /vagrant/netapp-manageability-sdk*.zip && sudo cp netapp-manageability-sdk*/lib/ruby/NetApp/*.rb /etc/puppet/modules/netapp/lib/puppet/netapp_sdk/ && rm -Rf netapp-manageability-sdk*"
sudo su -c "echo '127.0.1.1 puppet.example.com puppet' >> /etc/hosts"
sudo su -c "echo '127.0.1.1 servicevm.example.com servicevm' >> /etc/hosts"
sudo su -c "echo '10.0.207.3 vsim-01.example.com vsim-01' >> /etc/hosts"
sudo sed -i 's/.*\[main\].*/&\ndns_alt_names = puppet,puppet.example.com/' /etc/puppet/puppet.conf
sudo /etc/init.d/puppetmaster stop
sudo timeout 10s puppet master --verbose --no-daemonize
sudo /etc/init.d/puppetmaster start
