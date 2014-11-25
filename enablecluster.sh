#!/bin/bash
sleep 5
echo "Trying VSIM cluster setup on $1"
curl -X POST -d @cluster_setup "http://admin@$1/servlets/netapp.servlets.admin.XMLrequest_filer"
sleep 15
curl -X POST -d @ssh_enable "http://admin@$1/servlets/netapp.servlets.admin.XMLrequest_filer"
sleep 2
curl -X POST -d @ssh_enable_publickey "http://admin@$1/servlets/netapp.servlets.admin.XMLrequest_filer"
sleep 5
echo "\n"
echo "SSH is available at Cluster Node Management ip $1. Username admin, password netapp123"




