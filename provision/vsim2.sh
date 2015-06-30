#!/usr/bin/env bash

. /vagrant/vsim.conf

if [ -n "$1" ]; then
  NODE_MGMT_IP=$1
fi

# Please use vsim.conf for configuration instead of this file
CLUSTER_BASE_LICENSE=$CLUSTER_BASE_LICENSE
export NODE_MGMT_IP=${NODE_MGMT_IP:-10.0.207.3}
BASEIP=`echo $NODE_MGMT_IP | cut -d"." -f1-3`
export NODE_MGMT_IP="$BASEIP.13"
export CLUSTER_MGMT_IP="$BASEIP.14"
export CLUSTER_IP="10.208.208.3"
export CLUSTER_USERNAME=${CLUSTER_USERNAME:-vagrant}
export PASSWORD=${PASSWORD:-netapp123}
API_ENDPOINT_HOST_PATH="$NODE_MGMT_IP/servlets/netapp.servlets.admin.XMLrequest_filer"
API_ENDPOINT_INIT="http://admin@$API_ENDPOINT_HOST_PATH"
API_ENDPOINT="http://admin:$PASSWORD@$API_ENDPOINT_HOST_PATH"
sudo iptables -t nat -D PREROUTING -i eth1 -p tcp --dport 22223 -j REDIRECT --to-port 22 

sudo sh -c 'echo "1" > /proc/sys/net/ipv4/ip_forward'

sudo iptables -t nat -A PREROUTING -i eth1 -p tcp --dport 22223 -j DNAT --to-destination $NODE_MGMT_IP:22

sudo iptables -t nat -A POSTROUTING -j MASQUERADE

sudo iptables-save > /dev/null

echo "Awaiting Pre-Cluster mode. This can take a few minutes ..."
rc=1; 
while [ $rc -ne 0 ]; do 
  /usr/bin/wget --no-proxy $NODE_MGMT_IP/na_admin > /dev/null 2>&1
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

read -d '' CLUSTER_LIF_CREATE << EOF
<?xml version="1.0" encoding="UTF-8"?>

<netapp xmlns="http://www.netapp.com/filer/admin" version="1.20">
  <net-interface-create>
    <vserver>Cluster</vserver>
    <interface-name>cluster2</interface-name>
    <role>cluster</role>
    <home-node>localhost</home-node>
    <home-port>e0b</home-port>
    <address>10.208.208.13</address>
    <netmask>255.255.255.0</netmask>
  </net-interface-create>
</netapp>
EOF

read -d '' CLUSTER_JOIN << EOF
<?xml version="1.0" encoding="UTF-8"?>

<netapp xmlns="http://www.netapp.com/filer/admin" version="1.20">
  <cluster-join>
    <cluster-ip-address>$CLUSTER_IP</cluster-ip-address>
  </cluster-join>
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
echo "Creating cluster lif"
/usr/bin/curl -X POST -d "$CLUSTER_LIF_CREATE"  -sS --noproxy $NODE_MGMT_IP $API_ENDPOINT
sleep 20
echo "Joining cluster"
/usr/bin/curl -X POST -d "$CLUSTER_JOIN"  -sS --noproxy $NODE_MGMT_IP $API_ENDPOINT
sleep 20


echo "SSH is available at $NODE_MGMT_IP. username $CLUSTER_USERNAME, password $PASSWORD"
echo "VSim ready. Run 'vagrant ssh vsim' for console access."