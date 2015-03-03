#!/usr/bin/env bash

# update system
export DEBIAN_FRONTEND noninteractive
sudo apt-get update
sudo apt-get install -qqy git

PROVISION=$1

# determine checkout folder
OS_USER=vagrant
PWD=$(su $OS_USER -c "cd && pwd")
TAPSTER="$PWD/tapster"
# check if tapster is already there
if [ ! -d "$TAPSTER" ]
then
	echo "Download tapster into $TAPSTER"
	# clone tapster
	su $OS_USER -c "cd && git clone -b tapper https://github.com/tlichten/vagrant-devstack-manila.git $TAPSTER"
fi

# start tapster provisioning
echo "Start $PROVISION provisioning"
PATH_PROVISION ="$TAPSTER/provision"
su $OS_USER -c "chmod +x $PATH_PROVISION/$PROVISION.sh"
su $OS_USER -c "cd $PATH_PROVISION && ./$PROVISION.sh"