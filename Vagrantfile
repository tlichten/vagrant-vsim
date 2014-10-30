def control_vm(vm_id)
  system('echo','Starting vm with funtion ' + vm_id )
  #sleep(10)
  # system('sleep', '10')
end  

def ensure_box(name)
  if !File.exists?(File.expand_path("../#{name}.box.tmp", __FILE__))
    # you could raise or do other ruby magic, or shell out (for a bash script)
    system('echo', 'Creating box for ' + name)
    system('touch', name + '.box.tmp')
    system('vagrant', 'package', '--base', name, '--output', name + '.box')
    system('vagrant', 'box', 'add', name, name + '.box')
   end
end

#ensure_box('VSim')

Vagrant.configure(2) do |config|

  config.vm.box = "VSim"
	config.vm.hostname = "VSim"
  config.vm.network "private_network", ip: "10.0.100.100"
	config.vm.provider "virtualbox" do |p|
     p.gui = true
     # p.customize ["startvm", :id, "--type", "gui"]
     #p.customize ["modifyvm", :id, "--name", "VSim"]
     #control_vm('VSim')
     # send "?"
 
     p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "10000"]
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

		
		 # send "boot<Enter>"
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode","30","b0","18","98","18","98","14","94","1c","9c"]

		 p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "10000"]

		 # Ctrl-C
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "1d", "2e", "9d", "ae"]
     
		 p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "45000"]

		 # 4<Enter>
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "05", "85", "1c", "9c"]

		 p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "20000"]

		 # y<Enter>
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "15", "95", "1c", "9c"]
     
		 p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "1000"]
			
     # y<Enter>
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "15", "95", "1c", "9c"]
		 # wait for reboot and disk cleaning
		 p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "240000"]
		 
		 # new? create<Enter>
   		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "2e","ae","13","93","12","92","1e","9e","14","94","12","92","1c","9c"]
		 p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "1000"]
		 # single node? yes<Enter>	
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "15","95","12","92","1f","9f","1c","9c"]

		 p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "5000"]
		 # cluster name? VSim<Enter>	
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "2a","2f","af","aa","2a","1f","9f","aa","17","97","32","b2","1c","9c"]
		 p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "2000"]
  		 # base license? 		SMKQROW
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "2a", "1f", "9f", "aa", "2a", "32", "b2", "aa", "2a", "25", "a5", "aa", "2a", "10", "90", "aa", "2a", "13", "93", "aa", "2a", "18", "98", "aa", "2a", "11", "91", "aa"] 
     # JNQYQSDAA
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "2a", "24", "a4", "aa", "2a", "31", "b1", "aa", "2a", "10", "90", "aa", "2a", "15", "95", "aa", "2a", "10", "90", "aa", "2a", "1f", "9f", "aa", "2a", "20", "a0", "aa", "2a", "1e", "9e", "aa", "2a", "1e", "9e", "aa"] 
     #AAAAAA
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "2a", "1e", "9e", "aa", "2a", "1e", "9e", "aa", "2a", "1e", "9e", "aa", "2a", "1e", "9e", "aa", "2a", "1e", "9e", "aa", "2a", "1e", "9e", "aa"] 

     #AAAAAA
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "2a", "1e", "9e", "aa", "2a", "1e", "9e", "aa", "2a", "1e", "9e", "aa", "2a", "1e", "9e", "aa", "2a", "1e", "9e", "aa", "2a", "1e", "9e", "aa"]   

		# <Enter>	
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "1c","9c"]


		 p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "35000"]

		 # additional license? <Enter>	
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "1c","9c"]

		 p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "5000"]

		 # password? netapp123<Enter>	
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "31","b1","12","92","14","94","1e","9e","19","99","19","99","02","82","03","83","04","84","1c","9c"]
	  
     p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "5000"]
 
     # retype password? netapp123<Enter>	
		 p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "31","b1","12","92","14","94","1e","9e","19","99","19","99","02","82","03","83","04","84","1c","9c"]

     p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "2000"]

     # cluster mgmt port e0a? <Enter> 
     p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "1c","9c"]
     #p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "12", "92", "0b", "8b", "30", "b0", "1c", "9c"]
		
		 p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "2000"]

     # cluster mgmt ip? 10.0.100.100<Enter>
     p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "02","82","0b","8b","34","b4","0b","8b","34","b4","02","82","0b","8b","0b","8b","34","b4","02","82","0b","8b","0b","8b","1c","9c"]
     p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "1000"]
     # netmask? 255.255.255.0<Enter>
     p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "03","83","06","86","06","86","34","b4","03","83","06","86","06","86","34","b4","03","83","06","86","06","86","34","b4","0b","8b","1c","9c"]
      p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "1000"]

		 # gateway? 10.0.100.1<Enter>
     p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "02","82","0b","8b","34","b4","0b","8b","34","b4","02","82","0b","8b","0b","8b","34","b4","02","82","1c","9c"]
     p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "1000"] 

     # dns domain names? <Enter>
     p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "1c","9c"]
     p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "1000"] 

     #located? VSim<Enter>
     p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "2a","2f","af","aa","2a","1f","9f","aa","17","97","32","b2","1c","9c"]
     p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "1000"] 

     # node mgmt port e0a? <Enter> 
     p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "1c","9c"]
     #p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "12", "92", "0b", "8b", "30", "b0", "1c", "9c"]

		 p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "1000"]

		 # node mgmt ip? 10.0.100.100<Enter>
     p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "02","82","0b","8b","34","b4","0b","8b","34","b4","02","82","0b","8b","0b","8b","34","b4","0a","8a","02","82","1c","9c"]
     p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "1000"]
     # netmask? 255.255.255.0<Enter>
     p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "03","83","06","86","06","86","34","b4","03","83","06","86","06","86","34","b4","03","83","06","86","06","86","34","b4","0b","8b","1c","9c"]
      p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "1000"]

		 # gateway? 10.0.100.1<Enter>
     p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "02","82","0b","8b","34","b4","0b","8b","34","b4","02","82","0b","8b","0b","8b","34","b4","02","82","1c","9c"]
     p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "1000"] 

		 #backup? <Enter>
     p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "1c","9c"]
     p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "1000"] 

     #asup? <Enter>
     p.customize "post-boot", ["controlvm", :id, "keyboardputscancode", "1c","9c"]
     p.customize "post-boot", ["guestproperty", "wait", :id, "what", "--timeout", "2000"] 
     p.customize "post-boot", ["guestproperty", "set", :id, "what", "1"]
  end

end
