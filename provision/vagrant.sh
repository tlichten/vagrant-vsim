#!/usr/bin/env bash

# update system
export DEBIAN_FRONTEND noninteractive
sudo apt-get update
sudo apt-get install -qqy git

PROVISION=$1

# determine checkout folder
export OS_USER=vagrant
PWD=$(su $OS_USER -c "cd && pwd")
VAGRANT_VSIM="/vagrant"

if [ ! -d "$VAGRANT_VSIM/provision" ]; then
    VAGRANT_VSIM="/vagrant/lib/vagrant-vsim"
fi

# start vagrant-vsim provisioning
echo "Start $PROVISION provisioning"
PATH_PROVISION="$VAGRANT_VSIM/provision"
su $OS_USER -c "chmod +x $PATH_PROVISION/$PROVISION.sh"
su $OS_USER -c "cd $PATH_PROVISION && ./$PROVISION.sh"
