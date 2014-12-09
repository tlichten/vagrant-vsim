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
sudo yum updateinfo
sudo yum install -y git mysql-devel
sudo yum install -y epel-release
sudo yum install -y python-pip
#sudo pip install mysql-python
sudo pip install tox

# openvswitch
# there is no openvswitch package avaialble. So we have to build it..
OVS_VERSION=2.3.0
sudo yum -y install wget openssl-devel kernel-devel rpm-build
sudo yum -y groupinstall "Development Tools"
mkdir -p ~/rpmbuild/SOURCES
cd ~/rpmbuild/SOURCES
wget http://openvswitch.org/releases/openvswitch-$OVS_VERSION.tar.gz
cd ~
tar xfz ~/rpmbuild/SOURCES/openvswitch-$OVS_VERSION.tar.gz
sed 's/openvswitch-kmod, //g' openvswitch-$OVS_VERSION/rhel/openvswitch.spec > openvswitch-$OVS_VERSION/rhel/openvswitch_no_kmod.spec
rpmbuild -bb --without check ~/openvswitch-$OVS_VERSION/rhel/openvswitch_no_kmod.spec
yum localinstall -y ~/rpmbuild/RPMS/x86_64/openvswitch-$OVS_VERSION-1.x86_64.rpm

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

  # copy local.conf settings (source: devstack/samples/local.conf)
  echo "copy config from $BASHPATH/config/local.conf to $DEVSTACK/local.conf"
  cp $BASHPATH/config/local.conf $DEVSTACK/local.conf
  chown $OS_USER:$OS_USER $DEVSTACK/local.conf

fi

MANILA=$PWD/manila
# check if manila is already there
if [ ! -d "$MANILA" ]
then
  echo "Download manila into $MANILA"

  # clone manila
  su $OS_USER -c "cd && git clone -b $MANILA_BRANCH https://github.com/openstack/manila.git $MANILA"

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
