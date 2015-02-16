# -*- mode: ruby -*-
# vi: set ft=ruby :
require 'fileutils'


configfile = 'vsim.conf'
load configfile if File.exist?(configfile)

VAGRANTFILE_API_VERSION = "2"

# .3 is the expected host address to be assigned through DHCP, do not change
NODE_MGMT_IP ||= "10.0.207.3"
DEVSTACK_HOST_IP ||= "192.168.33.10"
DEVSTACK_MGMT_IP ||= NODE_MGMT_IP.rpartition(".")[0] + ".252"
ENV['OS_HOST_IP'] = DEVSTACK_HOST_IP
ENV['NODE_MGMT_IP'] = NODE_MGMT_IP
ENV['DEVSTACK_MGMT_IP']=DEVSTACK_MGMT_IP
ENV['CLUSTER_BASE_LICENSE'] ||= CLUSTER_BASE_LICENSE
VBOXNET_HOST_GW_IP ||= NODE_MGMT_IP.rpartition(".")[0] + ".254"
SERVICEVM_HOST_IP ||= NODE_MGMT_IP.rpartition(".")[0] + ".253"
BOX_NAME ||= "VSim"
BASE_IMAGE ||= "vsim_netapp-cm.tgz"
VAGRANT_MINVERSION = '1.7.2'

module VagrantPlugins
  module VSimPlugin
    class SendBootFlags
      def initialize(app, env)
        @app = app
      end

      def call(env)
        if env[:provision_enabled] && env[:machine].name.to_s == BOX_NAME.downcase
          env[:ui].info("Provisioning #{BOX_NAME}")

          # Wait 10 seconds for machine to come up
          sleep 10

          customizations = []

          #  send "?"
          customizations << ["controlvm", :id, "keyboardputscancode", "2a", "35", "b5", "aa", "1c", "9c"]

          #  send "setenv boot"
          customizations << ["controlvm", :id, "keyboardputscancode","1f","9f","12","92","14","94","12","92","31","b1","2f","af","39","b9","30","b0","18","98","18","98","14","94"]

          #  send "arg.vm."
          customizations << ["controlvm", :id, "keyboardputscancode","1e","9e","13","93","22","a2","34","b4","2f","af","32","b2","34","b4"]

          #  send "run_vmtools"
          customizations << ["controlvm", :id, "keyboardputscancode","13","93","16","96","31","b1","2a","0c","8c","aa","2f","af","32","b2","14","94","18","98","18","98","26","a6","1f","9f"]

          #  send " false<Enter>"
          customizations << ["controlvm", :id, "keyboardputscancode","39","b9","21","a1","1e","9e","26","a6","1f","9f","12","92","1c","9c"]

          #  send "set bootarg"
          customizations << ["controlvm", :id, "keyboardputscancode", "1f", "9f", "12", "92", "14", "94", "39", "b9", "30", "b0", "18", "98", "18", "98", "14", "94", "1e", "9e", "13", "93", "22", "a2"]

          #  send ".init.dhcp."
          customizations << ["controlvm", :id, "keyboardputscancode", "34", "b4", "17", "97", "31", "b1", "17", "97", "14", "94", "34", "b4", "20", "a0", "23", "a3", "2e", "ae", "19", "99", "34", "b4"]

          #  send "disable="
          customizations << ["controlvm", :id, "keyboardputscancode", "20", "a0", "17", "97", "1f", "9f", "1e", "9e", "30", "b0", "26", "a6", "12", "92", "0d", "8d"]

          #  send "false<ENTER>"
          customizations << ["controlvm", :id, "keyboardputscancode", "21", "a1", "1e", "9e", "26", "a6", "1f", "9f", "12", "92", "1c", "9c"]

          #  send "set bootarg"
          customizations << ["controlvm", :id, "keyboardputscancode", "1f", "9f", "12", "92", "14", "94", "39", "b9", "30", "b0", "18", "98", "18", "98", "14", "94", "1e", "9e", "13", "93", "22", "a2"]

          #  send ".bootmenu"
          customizations << ["controlvm", :id, "keyboardputscancode", "34", "b4", "30", "b0", "18", "98", "18", "98", "14", "94", "32", "b2", "12", "92", "31", "b1", "16", "96"]

          #  send ".selection"
          customizations << ["controlvm", :id, "keyboardputscancode", "34", "b4", "1f", "9f", "12", "92", "26", "a6", "12", "92", "2e", "ae", "14", "94", "17", "97", "18", "98", "31", "b1"]

          #  send "=4a<Enter>"
          customizations << ["controlvm", :id, "keyboardputscancode", "0d", "8d", "05", "85", "1e", "9e", "1c", "9c"]

          #  send "boot<Enter>"
          customizations << ["controlvm", :id, "keyboardputscancode","30","b0","18","98","18","98","14","94","1c","9c"]

          if !customizations.empty?
            env[:ui].info("Sending VSim boot flags")
            # Execute each customization command.
            customizations.each do |command|
              processed_command = command.collect do |arg|
              arg = env[:machine].id if arg == :id
              arg.to_s
            end
            begin
              env[:machine].provider.driver.execute_command(
              processed_command + [retryable: true])
              rescue Vagrant::Errors::VBoxManageError => e
                raise Vagrant::Errors::VMCustomizationFailed, {
                  command: command,
                  error: e.inspect
                }
              end
            end
          end
        end    
        @app.call(env)
      end
    end

    class Plugin < Vagrant.plugin("2")
      name "VSimPlugin"

      action_hook :send_flags, :machine_action_up do |hook|
        hook.after(VagrantPlugins::ProviderVirtualBox::Action::Boot, ::Vagrant::Action::Builder.new.tap do |b|
          b.use VagrantPlugins::VSimPlugin::SendBootFlags
        end)
      end

    end
  end
end


module VagrantPlugins
  module VSimPlugin
    class ValidateBox
      def initialize(app, env)
        @app = app
      end

      def call(env)
        # https://stackoverflow.com/a/20860087
        if ! File.exists?(".vagrant/machines/vsim/virtualbox/id")
          if ENV['CLUSTER_BASE_LICENSE'].nil? || ENV['CLUSTER_BASE_LICENSE'].empty?
            puts "\n\n"
            puts "The cluster base license has not been specified."
            puts "Obtain the Clustered-Ontap Simulator 8.2.2 cluster base license from"
            puts "http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/"
            puts "Edit vsim.conf, at the top set CLUSTER_BASE_LICENSE accordingly."
            exit
          end
          ask_to_add_vsim_unless_exists
        end
        @app.call(env)
      end

      def add_vsim
        if !File.exists?(File.expand_path("../#{BASE_IMAGE}", __FILE__))
          puts "\n\n"
          puts "#{BOX_NAME} base image #{BASE_IMAGE} not found."
          puts "Download the Clustered-Ontap Simulator 8.2.2P1 for VMware Workstation, VMware Player, and VMware Fusion from"
          puts "http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/"
          puts "Save the dowloaded base image file #{BASE_IMAGE} in this directory and run 'vagrant up' again."
          FileUtils.rm_rf "#{BOX_NAME}.box.lock"
          exit
        end

        puts "Preparing to add #{BOX_NAME} to vagrant. This may take a few minutes."
        template_dir = File.join("template", ".")
        tmp_dir = "tmp"
        FileUtils.mkdir tmp_dir 
        result = Vagrant::Util::Subprocess.execute("bsdtar", "-v", "-x", "-m", "-C", tmp_dir.to_s, "-f", BASE_IMAGE.to_s)
        vsim_dir = File.join(tmp_dir, "vsim_netapp-cm")
        FileUtils.cp_r template_dir, vsim_dir
        puts "Packaging #{BOX_NAME} box for vagrant"
        
        box_target = File.join(tmp_dir, "#{BOX_NAME}.box")
        Vagrant::Util::SafeChdir.safe_chdir(vsim_dir) do
        files = Dir.glob(File.join(".", "*"))
        result = Vagrant::Util::Subprocess.execute("bsdtar", "-c", "-v", "-z","-f", "#{BOX_NAME}.box", *files)
        end 
        box_file = File.join(vsim_dir, "#{BOX_NAME}.box")
        FileUtils.mv(box_file, tmp_dir)
        FileUtils.rm_rf vsim_dir
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
              puts "You must import it in order to proceed which may take a few minutes. Please do not quit Vagrant during this time. Would you like to import the Vagrant box? [y/n]: "
              case STDIN.getc
                when 'Y', 'y', 'yes'
                  add_vsim
                  break
                when /\A[nN]o?\Z/ #n or no
                  FileUtils.rm_rf "#{BOX_NAME}.box.lock"
                  exit
              end
            end
          end
          FileUtils.rm_rf "#{BOX_NAME}.box.lock"
        end
      end
    end

    class Plugin < Vagrant.plugin("2")
      name "ValidateBox"

      action_hook :send_flags, :machine_action_up do |hook|
        hook.before(Vagrant::Action::Builtin::HandleBox, ::Vagrant::Action::Builder.new.tap do |b|
          b.use VagrantPlugins::VSimPlugin::ValidateBox
        end)
      end
    end
  end
end


Vagrant::Config.run do |config|
  if Gem::Version.new(Vagrant::VERSION) < Gem::Version.new(VAGRANT_MINVERSION)
      puts "Vagrant version #{Gem::Version.new(Vagrant::VERSION)} detected. But Vagrant version #{VAGRANT_MINVERSION} or greater is required. Please update Vagrant."
      exit
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define "servicevm" do |servicevm|
    servicevm.vm.box = "ubuntu/trusty64"
    servicevm.vm.hostname = "servicevm"
  servicevm.ssh.insert_key = false
    servicevm.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "128"]
      vb.customize ["modifyvm", :id, "--cpus", "1"]
    end
    servicevm.vm.network "private_network", ip: SERVICEVM_HOST_IP
    servicevm.vm.provision :shell, :path => "service.sh"
    if Vagrant.has_plugin?("vagrant-cachier")
      servicevm.cache.scope = :box
    end
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
  end

  config.vm.define BOX_NAME.downcase do |vsim|
    vsim.vm.box = BOX_NAME
    vsim.ssh.host = SERVICEVM_HOST_IP
    vsim.ssh.insert_key = false
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
    #  p.gui = true
    end
  end

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

  config.vm.define "devstackvm" do |devstackvm|
    devstackvm.vm.box = "ubuntu/trusty64"
    devstackvm.vm.hostname = "devstack"

    devstackvm.vm.provider "virtualbox" do |vb|
      vb.customize ["modifyvm", :id, "--memory", "4096"]
      vb.customize ["modifyvm", :id, "--cpus", "3"]
      vb.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
    end

    devstackvm.vm.network "private_network", ip: DEVSTACK_HOST_IP
    devstackvm.vm.network "private_network", ip: DEVSTACK_MGMT_IP

    devstackvm.vm.provision :shell, :path => "vagrant.sh"

    if Vagrant.has_plugin?("vagrant-cachier")
      devstackvm.cache.scope = :box
      # setup PIP cache
      devstackvm.cache.enable :generic, { "pip" => { :cache_dir => "/var/cache/pip" } }
      devstackvm.vm.provision "file", source: "pip.conf", destination: "/home/vagrant/.pip/pip.conf"
    end
  end
end
