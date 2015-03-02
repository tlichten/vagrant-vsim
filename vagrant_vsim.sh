#!/usr/bin/env bash

# update system
export DEBIAN_FRONTEND noninteractive
sudo apt-get update
sudo apt-get install -qqy git


# determine checkout folder
OS_USER=vagrant
PWD=$(su $OS_USER -c "cd && pwd")
TAPPER="$PWD/tapper"
# check if tapper is already there
if [ ! -d "$TAPPER" ]
then
	echo "Download tapper into $TAPPER"
	# clone tapper
	su $OS_USER -c "cd && git clone -b tapper https://github.com/tlichten/vagrant-devstack-manila.git $TAPPER"
fi

# start tapper servicvm provisioning
echo "Start VSim provisioning"
su $OS_USER -c "chmod +x $TAPPER/vsim.sh"
su $OS_USER -c "cd $TAPPER && ./vsim.sh"