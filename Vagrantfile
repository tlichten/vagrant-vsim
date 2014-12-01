# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

# .3 is the expected host address to be assigned through DHCP, do not change
NODE_MGMT_IP ||= "10.0.122.3"
DEVSTACK_HOST_IP ||= "192.168.33.10"
DEVSTACK_MGMT_IP ||= NODE_MGMT_IP.rpartition(".")[0] + ".253"
ENV['OS_HOST_IP'] = DEVSTACK_HOST_IP

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if Vagrant.has_plugin?("vagrant-proxyconf")
    if ENV["http_proxy"]
      config.proxy.http     = ENV["http_proxy"]
    end
    if ENV["https_proxy"]
      config.proxy.https    = ENV["https_proxy"]
    end
    if ENV["no_proxy"]
      config.proxy.no_proxy = "localhost,127.0.0.1,#{DEVSTACK_HOST_IP},#{DEVSTACK_MGMT_IP},#{NODE_MGMT_IP},10.0.2.15"
    end
  end

  config.vm.box = "chef/centos-7.0"

  config.vm.hostname = "devstack"

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--memory", "4096"]
    vb.customize ["modifyvm", :id, "--cpus", "3"]
  end

  config.vm.network "private_network", ip: DEVSTACK_HOST_IP
  config.vm.network "private_network", ip: DEVSTACK_MGMT_IP

  config.vm.provision :shell, :path => "vagrant.sh"

	if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end
end
