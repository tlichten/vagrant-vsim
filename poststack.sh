#!/usr/bin/env bash

. devstack/functions
sudo ip addr del $DEVSTACK_MGMT_IP/24 dev eth2
sudo ovs-vsctl add-port br-ex eth2
sudo ip link set eth2 up
sudo ip link set eth2 promisc on
sudo ip addr add $DEVSTACK_MGMT_IP/24 dev br-ex

. devstack/openrc admin
DEMO_TENANT_ID=$(keystone tenant-list | grep " demo" | get_field 1)
neutron net-create p-m --provider:network_type vlan --provider:physical_network default --provider:segmentation_id 500 --tenant-id $DEMO_TENANT_ID
. devstack/openrc demo

NEUTRON_NET_ID=$(neutron net-list | grep p-m | get_field 1)
neutron subnet-create --name p-m-0 p-m 10.58.22.0/24
neutron router-interface-add router1 p-m-0
neutron security-group-rule-create --protocol icmp default
neutron security-group-rule-create --protocol tcp --port-range-min 22 --port-range-max 22 default
NEUTRON_SUBNET_ID=$(neutron subnet-list | grep p-m-0 | get_field 1)
manila share-network-create --neutron-net-id $NEUTRON_NET_ID --neutron-subnet-id $NEUTRON_SUBNET_ID --name p-s
sleep 30
manila create --share-network p-s --name share NFS 1
sleep 30
NEUTRON_NET_ID=$(neutron net-list | grep p-m | get_field 1)

nova boot --poll --flavor manila-service-flavor --image ubuntu_1204_nfs_cifs --nic net-id=$NEUTRON_NET_ID demo-vm0
MANILA_NET_ID=$(manila list | grep share | get_field 1)
INSTANCE_IP=$(nova list | grep demo-vm0 | get_field 6 | grep -oE '[0-9.]+')
manila access-allow $MANILA_NET_ID ip $INSTANCE_IP

nova floating-ip-create public

FLOATING_IP=$(nova floating-ip-list | grep public | get_field 1)
nova add-floating-ip demo-vm0 $FLOATING_IP
BOOT_TIMEOUT=360
if ! timeout $BOOT_TIMEOUT sh -c "while ! ping -c1 -w1 $FLOATING_IP; do sleep 1; done"; then
        echo "Couldn't ping server"
        exit 1
fi

# If you installed Horizon on this server you should be able
# to access the site using your browser.
if is_service_enabled horizon; then
echo "Horizon is now available at http://$OS_HOST_IP/"
fi
# If Keystone is present you can point ``nova`` cli to this server
if is_service_enabled key; then
echo "Examples on using novaclient command line is in exercise.sh"
echo "The default users are: admin and demo"
echo "The password: $ADMIN_PASSWORD"
echo "Devstack VM console available running: vagrant ssh devstackvm"
echo "VSim available running: vagrant ssh vsim"
fi
