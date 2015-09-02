#!/usr/bin/env bash

. /vagrant/vsim.conf

if [ -n "$1" ]; then
  NODE_MGMT_IP=$1
fi

# Please use vsim.conf for configuration instead of this file
CLUSTER_BASE_LICENSE=$CLUSTER_BASE_LICENSE
export NODE_MGMT_IP=${NODE_MGMT_IP:-10.0.207.3}
BASEIP=`echo $NODE_MGMT_IP | cut -d"." -f1-3`
export CLUSTER_MGMT_IP="$BASEIP.4"
export CLUSTER_USERNAME=${CLUSTER_USERNAME:-vagrant}
export PASSWORD=${PASSWORD:-netapp123}
API_ENDPOINT_HOST_PATH="$NODE_MGMT_IP/servlets/netapp.servlets.admin.XMLrequest_filer"
API_ENDPOINT_INIT="http://admin@$API_ENDPOINT_HOST_PATH"
API_ENDPOINT="http://admin:$PASSWORD@$API_ENDPOINT_HOST_PATH"
sudo iptables -t nat -D PREROUTING -i eth1 -p tcp --dport 22222 -j REDIRECT --to-port 22 

sudo sh -c 'echo "1" > /proc/sys/net/ipv4/ip_forward'

sudo iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 22222 -j DNAT --to-destination $NODE_MGMT_IP:22

sudo iptables -t nat -A POSTROUTING -j MASQUERADE

sudo iptables-save > /dev/null

echo "Awaiting Pre-Cluster mode. This can take a few minutes ..."
rc=1; 
while [ $rc -ne 0 ]; do 
  /usr/bin/wget -O /dev/null -o /dev/null --no-proxy $NODE_MGMT_IP/na_admin  > /dev/null 2>&1
  rc=$?
  sleep 1  
  echo -n '.' 
done
echo "Pre-Cluster mode available"

read -d '' ADMIN_PASSWORD << EOF
<?xml version="1.0" encoding="UTF-8"?>

<netapp xmlns="http://www.netapp.com/filer/admin" version="1.20">
  <security-login-modify-password>
    <user-name>admin</user-name>
    <new-password>$PASSWORD</new-password>
  </security-login-modify-password>
</netapp>
EOF

read -d '' CLUSTER_SETUP << EOF
<?xml version="1.0" encoding="UTF-8"?>

<netapp xmlns="http://www.netapp.com/filer/admin" version="1.21">
  <cluster-create>
    <license>$CLUSTER_BASE_LICENSE</license>
    <cluster-name>VSIM</cluster-name>
  </cluster-create>
</netapp>
EOF

read -d '' SSH_ENABLE << EOF
<?xml version="1.0" encoding="UTF-8"?>

<netapp xmlns="http://www.netapp.com/filer/admin" version="1.21">
  <security-login-create>
    <vserver>VSIM</vserver>
    <user-name>$CLUSTER_USERNAME</user-name>
    <application>ssh</application>
    <authentication-method>password</authentication-method>
    <role-name>admin</role-name>
    <password>$PASSWORD</password>
  </security-login-create>
</netapp>
EOF

read -d '' SSH_ENABLE_PUBLICKEY << EOF
<?xml version="1.0" encoding="UTF-8"?>

<netapp xmlns="http://www.netapp.com/filer/admin" version="1.21">
  <security-login-create>
    <vserver>VSIM</vserver>
    <user-name>$CLUSTER_USERNAME</user-name>
    <application>ssh</application>
    <authentication-method>publickey</authentication-method>
    <role-name>admin</role-name>
  </security-login-create>
</netapp>
EOF

read -d '' DISK_ASSIGN << EOF
<?xml version="1.0" encoding="UTF-8"?>
<netapp xmlns="http://www.netapp.com/filer/admin" version="1.21">
  <disk-sanown-assign>
    <all>true</all>
    <node-name>VSIM-01</node-name>
  </disk-sanown-assign>
</netapp>
EOF

read -d '' ADD_LICENSES << EOF
<?xml version="1.0" encoding="UTF-8"?>

<netapp xmlns="http://www.netapp.com/filer/admin" version="1.21">
  <license-v2-add>
    <codes>
      <license-code-v2>$LICENSES</license-code-v2>
    </codes>
  </license-v2-add>
</netapp>
EOF

sleep 5
echo "Enabling password for setup on $NODE_MGMT_IP"
ADMIN_PASSWORD_RESULT=$(/usr/bin/curl -X POST -d "$ADMIN_PASSWORD"  -sS --noproxy $NODE_MGMT_IP $API_ENDPOINT_INIT)
echo $ADMIN_PASSWORD_RESULT
if [[ $ADMIN_PASSWORD_RESULT == *"13005"* ]]
then
  echo "security-login-modify-password API not supported, fallback to passwordless API calls";
  API_ENDPOINT=$API_ENDPOINT_INIT
fi
sleep 5
echo "Starting cluster setup on $NODE_MGMT_IP"
/usr/bin/curl -X POST -d "$CLUSTER_SETUP"  -sS --noproxy $NODE_MGMT_IP $API_ENDPOINT
sleep 60
echo "Enabling SSH access for $CLUSTER_USERNAME"
/usr/bin/curl -X POST -d "$SSH_ENABLE"  -sS --noproxy $NODE_MGMT_IP $API_ENDPOINT
sleep 10
echo "Enabling SSH public key auth"
/usr/bin/curl -X POST -d "$SSH_ENABLE_PUBLICKEY" -sS --noproxy $NODE_MGMT_IP $API_ENDPOINT
sleep 5
echo "Assigning disks"
/usr/bin/curl -X POST -d "$DISK_ASSIGN" -sS --noproxy $NODE_MGMT_IP $API_ENDPOINT
sleep 25

if [ -n "$LICENSES" ]; then
  echo "Adding additional licenses $LICENSES"
  /usr/bin/curl -X POST -d "$ADD_LICENSES" -sS --noproxy $NODE_MGMT_IP $API_ENDPOINT
  sleep 5
fi

echo "Enabling Ontapi access for admin user $CLUSTER_USERNAME"
sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $CLUSTER_USERNAME@$NODE_MGMT_IP -t "security login create -username $CLUSTER_USERNAME -application ontapi -authmethod password -role admin" 2>/dev/null

echo "Adding public key for $CLUSTER_USERNAME"
sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $CLUSTER_USERNAME@$NODE_MGMT_IP -t 'security login publickey create -username vagrant -index 0 -publickey "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ=="' 2>/dev/null


echo "Running chef recipes"
cd /home/vagrant/chef && chef-solo -c solo.rb -j web.json


echo "Running additional commands"
while read -u 3 p; do
  [[ -z "$p" ]] && continue
  echo $p
  [[ "$p" =~ ^#.*$ ]] && continue
  sshpass -p $PASSWORD ssh -o StrictHostKeyChecking=no $CLUSTER_USERNAME@$NODE_MGMT_IP -t "$p" 2>/dev/null
  sleep 15
done 3</vagrant/vsim.cmds


echo "SSH is available at $NODE_MGMT_IP. username $CLUSTER_USERNAME, password $PASSWORD"
echo "VSim ready. Run 'vagrant ssh vsim' for console access."