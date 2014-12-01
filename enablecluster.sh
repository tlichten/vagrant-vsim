#!/bin/bash
if [ -n "$1" ]; then
  NODE_MGMT_IP=$1
fi

NODE_MGMT_IP=${NODE_MGMT_IP:-10.0.122.3}
CLUSTER_USERNAME=${CLUSTER_USERNAME:-admin}
PASSWORD=${PASSWORD:-netapp123}
API_ENDPOINT="http://$CLUSTER_USERNAME@$NODE_MGMT_IP/servlets/netapp.servlets.admin.XMLrequest_filer"

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

read -d '' DISK_ASSIGN << EOF
<?xml version="1.0" encoding="UTF-8"?>

<netapp xmlns="http://www.netapp.com/filer/admin" version="1.21">
  <disk-sanown-assign>
    <all>true</all>
    <node-name>VSIM-01</node-name>
  </disk-sanown-assign>
</netapp>
EOF


sleep 5
echo "Starting cluster setup on $NODE_MGMT_IP"
curl -X POST -d "$CLUSTER_SETUP" --noproxy $NODE_MGMT_IP $API_ENDPOINT
sleep 25
curl -X POST -d "$SSH_ENABLE" --noproxy $NODE_MGMT_IP $API_ENDPOINT
sleep 10
curl -X POST -d "$DISK_ASSIGN" --noproxy $NODE_MGMT_IP $API_ENDPOINT
sleep 5
echo "\n"
echo "SSH is available at $NODE_MGMT_IP. username $CLUSTER_USERNAME, password $PASSWORD"
