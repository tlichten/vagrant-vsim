#!/usr/bin/env bash

. /vagrant/vsim.conf

export OS_USER=vagrant
BASEIP=`echo $NODE_MGMT_IP | cut -d"." -f1-3`
export DEVSTACK_MGMT_IP="$BASEIP.252"
export NODE_MGMT_IP=$NODE_MGMT_IP
export OS_HOST_IP=$OS_HOST_IP
# run script
sh /vagrant/devstack.sh
