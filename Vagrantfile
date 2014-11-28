# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  if Vagrant.has_plugin?("vagrant-proxyconf")
    ENV["no_proxy"] ||= "localhost,127.0.0.1,.example.com,192.168.33.10,10.0.122.253,10.0.122.3,10.0.2.15"
    if ENV["http_proxy"]
      config.proxy.http     = ENV["http_proxy"]
    end
    if ENV["https_proxy"]
      config.proxy.https    = ENV["https_proxy"]
    end
    if ENV["no_proxy"]
      config.proxy.no_proxy = ENV["no_proxy"]
    end
  end

  config.vm.box = "chef/centos-7.0"

  config.vm.hostname = "devstack"

  config.vm.provider "virtualbox" do |vb|
     vb.customize ["modifyvm", :id, "--memory", "4096"]
     vb.customize ["modifyvm", :id, "--cpus", "3"]
  end
 
  config.vm.network "private_network", ip: "192.168.33.10"
     config.vm.network :private_network, ip: "10.0.122.253"

  config.vm.provision :shell, :path => "vagrant.sh"

	if Vagrant.has_plugin?("vagrant-cachier")
    config.cache.scope = :box
  end

end
