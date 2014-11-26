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
 - Download the Clustered Data Ontap 8.2.1 Simulator from http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/
 - Save the downloaded file 'vsim_netapp-cm.tgz' to this project's root directory, e.g. ./vagrant-vsim/vsim_netapp-cm.tgz
 - Edit the file 'cluster_setup' and enter the 8.2.1 Cluster base licencse into the &lt;license&gt;&lt;/license&gt; tag. The license can be obtained at the url above.
 - Run 'vagrant up' from this directory. The setup will take a few minutes to complete.
 
