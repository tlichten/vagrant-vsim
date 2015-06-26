#include_recipe "netapp::aggregate"
#include_recipe "netapp::lif"

netapp_aggregate "aggr1" do
  name "aggr1"
  disk_count 25
  action :create
end

netapp_lif 'cluster_mgmt' do
  svm 'VSIM'
  role 'cluster_mgmt'
  home_node 'VSIM-01'
  home_port 'e0c'
  address ENV["CLUSTER_MGMT_IP"]
  netmask '255.255.255.0'
  action :create
end

netapp_lif 'cluster1' do
  svm 'VSIM-01'
  role 'cluster'
  home_node 'VSIM-01'
  home_port 'e0b'
  address '10.208.208.3'
  netmask '255.255.255.0'
  action :create
end