#!/bin/sh

# environment variables
OPENSTACK_BRANCH=master
OPENSTACK_ADM_PASSWORD=devstack
MANILA_BRANCH=master

# determine own script path
BASHPATH="`dirname \"$0\"`"              # relative
BASHPATH="`( cd \"$BASHPATH\" && pwd )`"  # absolutized and normalized
echo "run script from $BASHPATH"

export OPENSTACK_BRANCH=$OPENSTACK_BRANCH
export MANILA_BRANCH=$MANILA_BRANCH
export OPENSTACK_ADM_PASSWORD=$OPENSTACK_ADM_PASSWORD

# update system
export DEBIAN_FRONTEND noninteractive
sudo apt-get update
sudo apt-get install -qqy git
sudo apt-get -y install vim-gtk libxml2-dev libxslt1-dev libpq-dev python-pip libsqlite3-dev && sudo apt-get -y build-dep python-mysqldb && sudo pip install git-review tox


# determine checkout folder

PWD=$(su $OS_USER -c "cd && pwd")
DEVSTACK=$PWD/devstack

# check if devstack is already there
if [ ! -d "$DEVSTACK" ]
then
  echo "Download devstack into $DEVSTACK"

  # clone devstack
  su $OS_USER -c "cd && git clone -b $OPENSTACK_BRANCH https://github.com/openstack-dev/devstack.git $DEVSTACK"

  echo "Copy configuration"

  # copy localrc settings (source: devstack/samples/localrc)
  echo "copy config from $BASHPATH/config/localrc to $DEVSTACK/localrc"
  cp $BASHPATH/config/localrc $DEVSTACK/localrc
  chown $OS_USER:$OS_USER $DEVSTACK/localrc

fi

MANILA=$PWD/manila
# check if manila is already there
if [ ! -d "$MANILA" ]
then
  echo "Download manila into $MANILA"

  # clone manila
  su $OS_USER -c "cd && git clone -b $MANILA_BRANCH https://github.com/stackforge/manila.git $MANILA"

  echo "Copy configuration"

  # copy manila install and start script
  echo "copy config from $MANILA/contrib/devstack/lib/manila to $DEVSTACK/lib"
  cp $MANILA/contrib/devstack/lib/manila $DEVSTACK/lib

  # copy manila extras script
  echo "copy extras script from $MANILA/contrib/devstack/extras.d/70-manila.sh to $DEVSTACK/extras.d"
  cp $MANILA/contrib/devstack/extras.d/70-manila.sh $DEVSTACK/extras.d

fi


# start devstack
echo "Start Devstack"
su $OS_USER -c "cd $DEVSTACK && ./stack.sh"
