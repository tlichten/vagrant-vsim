# -*- mode: ruby -*-
# vi: set ft=ruby :

require 'fileutils'

vagrant_vsimfile =  File.dirname(__FILE__) + '/lib/vagrant_vsim.rb'
load vagrant_vsimfile

VAGRANTFILE_API_VERSION = "2"

# .3 is the expected host address to be assigned through DHCP, do not change
NODE_MGMT_IP ||= "10.0.207.3"
SERVICEVM_HOST_IP ||= NODE_MGMT_IP.rpartition(".")[0] + ".253"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if Vagrant.has_plugin?("vagrant-proxyconf")
    if ENV["http_proxy"]
      config.proxy.http = ENV["http_proxy"]
    end
    if ENV["https_proxy"]
      config.proxy.https = ENV["https_proxy"]
    end
    if ENV["no_proxy"]
      config.proxy.no_proxy = "localhost,127.0.0.1,10.0.2.15"
    end
  end

  config.vm.define "servicevm" do |servicevm|
    servicevm.vm.box = "ubuntu/trusty64"
    servicevm.vm.hostname = "servicevm"
    servicevm.ssh.insert_key = false
    servicevm.vm.provider "virtualbox" do |v|
      v.memory = 512
      v.cpus = 1
    end
    servicevm.vm.network "private_network", ip: SERVICEVM_HOST_IP
    servicevm.vm.provision :shell, :path => File.dirname(__FILE__) + "/provision/vagrant.sh", :args => "servicevm"

    if Vagrant.has_plugin?("vagrant-cachier")
      servicevm.cache.scope = :box
    end
  end

  config.vm.define VSIM_NAME do |vsim|
    vsim.vm.box = BOX_NAME
    vsim.ssh.host = SERVICEVM_HOST_IP
    vsim.ssh.insert_key = false
    vsim.ssh.forward_agent = true
    vsim.ssh.port = "22222"
    vsim.vm.boot_timeout = 800
    vsim.vm.synced_folder '.', '/vagrant', disabled: true
    vsim.vm.provider "virtualbox" do |v|
      v.memory = 5120
    end
    # NODE_MGMT_IP is used below to ensure the nics will be on the same VBOXNET as the servicevm.
    # The nic ips are not configured by vagrant as the auto_config param is set to false, instead a dnsmasq 
    # process in the servicevm will offer the NODE_MGMT_IP for the nic which has the magic mac.

    vsim.vm.network "private_network", ip: NODE_MGMT_IP, auto_config: false
    vsim.vm.network "private_network", ip: NODE_MGMT_IP, auto_config: false
    vsim.vm.network "private_network", ip: NODE_MGMT_IP, auto_config: false, :mac => "0800DEADAC1D"
    vsim.vm.network "private_network", ip: NODE_MGMT_IP, auto_config: false

    vsim.vm.provision :shell, :path => File.dirname(__FILE__) + "/provision/vagrant.sh", :args => "vsim"
    vsim.vm.provider "virtualbox" do |v|
    #  v.gui = true
    end
  end
end
