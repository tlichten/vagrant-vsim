#include_recipe "netapp::feature"
#include_recipe "netapp::aggregate"


netapp_aggregate "aggr1" do
  name "aggr1"
  disk_count 25
  action :create
end

