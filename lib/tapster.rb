# -*- mode: ruby -*-
# vi: set ft=ruby :
configfile = 'vsim.conf'
load configfile if File.exist?(configfile)

BASE_IMAGE ||= "vsim_netapp-cm.tgz"
BOX_NAME ||= "VSim"
CDOT_VERSION ||= "8.2.3"
VAGRANT_MINVERSION = '1.7.2'

Vagrant::Config.run do |config|
  if Gem::Version.new(Vagrant::VERSION) < Gem::Version.new(VAGRANT_MINVERSION)
      puts "Vagrant version #{Gem::Version.new(Vagrant::VERSION)} detected. But Vagrant version #{Gem::Version.new(VAGRANT_MINVERSION)} or greater is required. Please update Vagrant."
      exit
  end
end

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
            env[:ui].info("Sending #{BOX_NAME} boot flags")
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
        if CLUSTER_BASE_LICENSE.nil? || CLUSTER_BASE_LICENSE.empty?
          puts "\n\n"
          puts "The cluster base license has not been specified."
          puts "Obtain the Clustered-Ontap Simulator #{CDOT_VERSION} cluster base license from"
          puts "http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/"
          puts "Edit vsim.conf, at the top set CLUSTER_BASE_LICENSE accordingly."
          exit
        end
        ask_to_add_vsim_unless_exists(env)
        @app.call(env)
      end

      def ask_to_add_vsim_unless_exists(env)
        boxes = {}
        env[:box_collection].all.each do |n, v, p|
          boxes[n] ||= {}
        end
        box_found = boxes[BOX_NAME]

        if !box_found
          while true
            puts "The vagrant #{BOX_NAME} box was not found."
            puts "You must import it in order to proceed which may take a few minutes. Please do not quit Vagrant during this time. Would you like to import the Vagrant box? [y/n]: "
            case STDIN.getc
              when 'Y', 'y', 'yes'
                add_vsim(env)
                break
              when /\A[nN]o?\Z/ #n or no
                exit
            end
          end
        end
      end

      def add_vsim(env)
        if !File.exists?(BASE_IMAGE)
          puts "\n\n"
          puts "#{BOX_NAME} base image #{BASE_IMAGE} not found."
          puts "Download the Clustered-Ontap Simulator #{CDOT_VERSION} for VMware Workstation, VMware Player, and VMware Fusion from"
          puts "http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/"
          puts "Save the dowloaded base image file #{BASE_IMAGE} in this directory and run 'vagrant up' again."
          exit
        end

        if Dir.exist? "tmp"
          FileUtils.rm_rf "tmp"
        end
        puts "Preparing to add #{BOX_NAME} to vagrant. This may take a few minutes."
        tmp_dir = "tmp"
        FileUtils.mkdir tmp_dir 
        result = Vagrant::Util::Subprocess.execute("bsdtar", "-v", "-x", "-m", "-C", tmp_dir.to_s, "-f", BASE_IMAGE.to_s)
        vsim_dir = File.join(tmp_dir, "vsim_netapp-cm")
        template_dir = File.join(File.dirname(__FILE__) + "/../template", ".")
        FileUtils.cp_r template_dir, vsim_dir
        puts "Packaging #{BOX_NAME} box for vagrant"
        Vagrant::Util::SafeChdir.safe_chdir(vsim_dir) do
          files = Dir.glob(File.join(".", "*"))
          result = Vagrant::Util::Subprocess.execute("bsdtar", "-c", "-v", "-z","-f", "#{BOX_NAME}.box", *files)
        end 
        box_file = File.join(vsim_dir, "#{BOX_NAME}.box")
        FileUtils.mv(box_file, tmp_dir)
        FileUtils.rm_rf vsim_dir
        puts "Adding #{BOX_NAME} box to vagrant"
        env[:action_runner].run(Vagrant::Action.action_box_add, {
          :box_name => BOX_NAME,
          :box_provider => "virtualbox",
          :box_url => File.join(tmp_dir, "#{BOX_NAME}.box"),
          :box_force => true,
          :box_download_insecure => true,
        })
        FileUtils.rm_rf tmp_dir
        puts "Done: #{BOX_NAME} box added to vagrant."
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
