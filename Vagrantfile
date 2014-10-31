# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "chef/centos-7.0"

  config.vm.hostname = "devstack"

  config.vm.provider "virtualbox" do |vb|
     vb.customize ["modifyvm", :id, "--memory", "4096"]
     vb.customize ["modifyvm", :id, "--cpus", "3"]
  end
 
  config.vm.network "private_network", ip: "192.168.33.10"
	config.vm.network :private_network, ip: "172.23.4.10"

  config.vm.provision :shell, :path => "vagrant.sh"

	if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

end
