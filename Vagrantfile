# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "trusty"

  config.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"

  config.vm.hostname = "devstack"

  config.vm.provider "virtualbox" do |vb|
     vb.customize ["modifyvm", :id, "--memory", "4096"]
  end
 
  config.vm.network "private_network", ip: "192.168.33.10"
	config.vm.network :private_network, ip: "172.23.4.10"

  config.vm.provision :shell, :path => "vagrant.sh"

	if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

end
