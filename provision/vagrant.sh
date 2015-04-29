#!/usr/bin/env bash

# update system
export DEBIAN_FRONTEND noninteractive
sudo rm -Rf /var/lib/apt/lists/* -vf
sudo apt-get update
sudo apt-get install -qqy git

PROVISION=$1

# determine checkout folder
export OS_USER=vagrant
PWD=$(su $OS_USER -c "cd && pwd")
VAGRANT_VSIM="$PWD/vagrant-vsim"
# check if vagrant-vsim is already there
if [ ! -d "$VAGRANT_VSIM" ]
then
	echo "Download vagrant-vsim into $VAGRANT_VSIM"
	# clone vagrant-vsim
	su $OS_USER -c "cd && git clone https://github.com/tlichten/vagrant-vsim.git $VAGRANT_VSIM"
fi

# start vagrant-vsim provisioning
echo "Start $PROVISION provisioning"
PATH_PROVISION="$VAGRANT_VSIM/provision"
su $OS_USER -c "chmod +x $PATH_PROVISION/$PROVISION.sh"
su $OS_USER -c "cd $PATH_PROVISION && ./$PROVISION.sh"
