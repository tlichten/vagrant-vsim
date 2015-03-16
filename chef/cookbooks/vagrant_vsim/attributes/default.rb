default['netapp']['url'] = "http://" + ENV['CLUSTER_USERNAME'] + ":" + ENV['PASSWORD'] + "@"+ ENV['NODE_MGMT_IP'] +"/"
default['netapp']['api']['timeout'] = 60

