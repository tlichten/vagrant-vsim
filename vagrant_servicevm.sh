#!/usr/bin/env bash
# determine checkout folder
OS_USER=vagrant
PWD=$(su $OS_USER -c "cd && pwd")
TAPPER="$PWD/tapper"
# check if tapper is already there
if [ ! -d "$TAPPER" ]
then
	echo "Download tapper into $TAPPER"
	# clone tapper
	su $OS_USER -c "cd && git clone https://github.com/tlichten/vagrant-devstack-manila/tree/tapper $TAPPER"
fi

# start tapper servicvm provisioning
echo "Start Servicevm provisioning"
su $OS_USER -c "cd $TAPPER && ./service.sh"