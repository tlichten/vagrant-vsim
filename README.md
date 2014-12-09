vagrant-vsim
============
Caution: This project is in pre alpa state.

System requirements
============
 - 8 GB Ram
 - 20 GB of free disk space
 - Linux / Mac
 - Virtualbox installed
 - Vagrant installed

Installation
============
 - Clone this repo
 - Download the Clustered Data Ontap 8.2.1 Simulator for VMware Workstation, VMware Player, and VMware Fusion from http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/
 - Save the downloaded file 'vsim_netapp-cm.tgz' to this project's root directory, e.g. ~/vagrant-vsim/vsim_netapp-cm.tgz
 - You need to add the base license first. Important: Use the non-ESX build license. Edit Vagrantfile, at the top set the 8.2.1 Cluster base license within ENV['CLUSTER_BASE_LICENSE'] accordingly. The license can be obtained from http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/.
 - In the Vagrantfile, define any additional licenses as a comma separated list within ENV['LICENSES'] accordingly. Important: Use the non-ESX build licenses. The additional licenses can be obtained from http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/
 - Run 'vagrant up' from this directory, e.g. ~/vagrant-vsim/. The setup will take a few minutes to complete.
