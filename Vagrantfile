require 'thread'
require 'net/http'
require 'fileutils'


configfile = 'vsim.conf'
load configfile if File.exist?(configfile)

ENV['CLUSTER_BASE_LICENSE'] ||= CLUSTER_BASE_LICENSE
NODE_MGMT_IP ||= "10.0.155.3"
VBOXNET_HOST_GW_IP ||= NODE_MGMT_IP.rpartition(".")[0] + ".254"
SERVICEVM_HOST_IP ||= NODE_MGMT_IP.rpartition(".")[0] + ".253"
BOX_NAME ||= "VSim"
BASE_IMAGE ||= "vsim_netapp-cm.tgz"

def add_vsim
  if !File.exists?(File.expand_path("../#{BASE_IMAGE}", __FILE__))
    puts "\n\n"
    puts "#{BOX_NAME} base image #{BASE_IMAGE} not found."
    puts "Download the Clustered-Ontap Simulator 8.2.1 for VMware Workstation, VMware Player, and VMware Fusion from"
    puts "http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/"
    puts "Save the dowloaded base image file #{BASE_IMAGE} in this directory and run 'vagrant up' again."
    return
  end

  puts "Preparing to add #{BOX_NAME} to vagrant. This may take a few minutes."
  template_dir = File.join("template", ".")
  tmp_dir = "tmp"
  FileUtils.mkdir tmp_dir
  FileUtils.cp_r template_dir, tmp_dir
  puts "Extracting #{BOX_NAME} base image to #{tmp_dir} directory"
  `tar zxvf #{BASE_IMAGE} --strip-components=1 --directory #{tmp_dir}`
  puts "Packaging #{BOX_NAME} box for vagrant"
  `cd #{tmp_dir} && tar cvzf #{BOX_NAME}.box *`
  puts "Adding #{BOX_NAME} box to vagrant"
  `cd #{tmp_dir} && vagrant box add #{BOX_NAME} #{BOX_NAME}.box`
  FileUtils.rm_rf tmp_dir
  puts "Done: #{BOX_NAME} box added to vagrant."
end

def ask_to_add_vsim_unless_exists
  if !File.exists?(File.expand_path("../#{BOX_NAME}.box.lock", __FILE__))
    FileUtils.touch "#{BOX_NAME}.box.lock"
    if ! `vagrant box list`.include? BOX_NAME
      while true
        puts "The vagrant #{BOX_NAME} box was not found."
        puts "You must import it in order to proceed which may take a few minutes. Would you like to import the vagrant box? [y/n]: "
        case STDIN.getc
          when 'Y', 'y', 'yes'
            add_vsim
            break
          when /\A[nN]o?\Z/ #n or no
            break
        end
      end
    end
    FileUtils.rm_rf "#{BOX_NAME}.box.lock"
  end
end


Vagrant::Config.run do |config|
  # https://stackoverflow.com/a/20860087
  if ! File.exists?(".vagrant/machines/vsim/virtualbox/id")
    ask_to_add_vsim_unless_exists

    if ENV['CLUSTER_BASE_LICENSE'].nil? || ENV['CLUSTER_BASE_LICENSE'].empty?
      puts "\n\n"
      puts "The cluster base license has not been specified."
      puts "Obtain the Clustered-Ontap Simulator 8.2.1 cluster base license from"
      puts "http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/"
      puts "Edit vsim.conf, at the top set CLUSTER_BASE_LICENSE accordingly."
      exit
    end
  end
end


Vagrant.configure(2) do |config|

  config.vm.define "servicevm" do |servicevm|
    servicevm.vm.box = "trusty"
    servicevm.vm.box_url = "https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box"
    servicevm.vm.hostname = "servicevm"
    servicevm.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "128"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end
    servicevm.vm.network "private_network", ip: SERVICEVM_HOST_IP
    servicevm.vm.provision :shell, :path => "service.sh"
    if Vagrant.has_plugin?("vagrant-cachier")
      servicevm.cache.scope = :box
    end
  end

  config.vm.define "vsim" do |vsim|
    vsim.vm.box = BOX_NAME
    if Gem::Version.new(Vagrant::VERSION) >= Gem::Version.new('1.5.0')
    end
    vsim.ssh.host = SERVICEVM_HOST_IP
    vsim.ssh.forward_agent = true
    vsim.ssh.port = "22222"
    vsim.vm.boot_timeout = 800
    vsim.vm.synced_folder '.', '/vagrant', disabled: true

    vsim.vm.network "private_network", ip: VBOXNET_HOST_GW_IP, auto_config: false
    vsim.vm.network "private_network", ip: VBOXNET_HOST_GW_IP, auto_config: false
    vsim.vm.network "private_network", ip: VBOXNET_HOST_GW_IP, auto_config: false, :mac => "0800DEADAC1D"
    vsim.vm.network "private_network", ip: VBOXNET_HOST_GW_IP, auto_config: false

    vsim.vm.provision :shell, :path => "vsim.sh"

    vsim.vm.provider "virtualbox" do |p|
      # p.gui = true

      # https://stackoverflow.com/a/20860087
      if ! File.exists?(".vagrant/machines/vsim/virtualbox/id")

        # wait at boot
        p.customize "post-boot", ["guestproperty", "wait", :id, "foobar", "--timeout", "10000"]
        # send "?"
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "2a", "35", "b5", "aa", "1c", "9c"]

        # send "setenv boot"
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode","1f","9f","12","92","14","94","12","92","31","b1","2f","af","39","b9","30","b0","18","98","18","98","14","94"]

        # send "arg.vm."
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode","1e","9e","13","93","22","a2","34","b4","2f","af","32","b2","34","b4"]

        # send "run_vmtools"
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode","13","93","16","96","31","b1","2a","0c","8c","aa","2f","af","32","b2","14","94","18","98","18","98","26","a6","1f","9f"]

        # send " false<Enter>"
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode","39","b9","21","a1","1e","9e","26","a6","1f","9f","12","92","1c","9c"]

        p.customize "post-boot", ["guestproperty", "wait", :id, "foobar", "--timeout", "2000"]

        # send "set bootarg"
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "1f", "9f", "12", "92", "14", "94", "39", "b9", "30", "b0", "18", "98", "18", "98", "14", "94", "1e", "9e", "13", "93", "22", "a2"]

        # send ".init.dhcp."
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "34", "b4", "17", "97", "31", "b1", "17", "97", "14", "94", "34", "b4", "20", "a0", "23", "a3", "2e", "ae", "19", "99", "34", "b4"]

        # send "disable="
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "20", "a0", "17", "97", "1f", "9f", "1e", "9e", "30", "b0", "26", "a6", "12", "92", "0d", "8d"]

        # send "false<ENTER>"
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "21", "a1", "1e", "9e", "26", "a6", "1f", "9f", "12", "92", "1c", "9c"]

        p.customize "post-boot", ["guestproperty", "wait", :id, "foobar", "--timeout", "2000"]

        # send "set bootarg"
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "1f", "9f", "12", "92", "14", "94", "39", "b9", "30", "b0", "18", "98", "18", "98", "14", "94", "1e", "9e", "13", "93", "22", "a2"]

        # send ".bootmenu"
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "34", "b4", "30", "b0", "18", "98", "18", "98", "14", "94", "32", "b2", "12", "92", "31", "b1", "16", "96"]


        # send ".selection"
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "34", "b4", "1f", "9f", "12", "92", "26", "a6", "12", "92", "2e", "ae", "14", "94", "17", "97", "18", "98", "31", "b1"]

        # send "=4a<Enter>"
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "0d", "8d", "05", "85", "1e", "9e", "1c", "9c"]

        p.customize "post-boot", ["guestproperty", "wait", :id, "foobar", "--timeout", "2000"]

        # send "boot<Enter>"
        p.customize "post-boot", ["controlvm", :id, "keyboardputscancode","30","b0","18","98","18","98","14","94","1c","9c"]
      end
    end
  end
end
