# TAPSTER

Use [Vagrant](https://www.vagrantup.com) to automatically create and configure an **experimental**, reproducible, and portable Clustered Data Ontap simulator environment

##### Credits
This project makes use of the excellent instructions on [how to simulate Data ONTAP 8.1.1. with Virtualbox by BOBSHOUSEOFCARDS](http://community.netapp.com/t5/Simulator-Discussions/Simulate-ONTAP-8-1-1-withVirtualBox/m-p/2227#M89)

##### Caution
This project is **experimental** and uses [Virtualbox](https://www.virtualbox.org) which is a **non-supported** configuration for the simulator. There are smaller *hacks* for making this work and it is not pretty. Use at own risk. Please see known issues at the bottom.

##### Goal
The goal of this project is to experimentally provide a largely automated, turn-key setup and configuration of a Clustered Data Ontap simulator using Vagrant in order to ease demos, speed up testing, and help become more familiar with cDot and its integration in projects like OpenStack. Experimental environments can automatically be created and configured, they are reproducible and portable.

## System requirements

 - 8 GB RAM
 - 15-20 GB of free disk space
 - SSD recommended
 - Linux / Mac / Windows
 - Internet connection

## Prerequisites

 - [Virtualbox](https://www.virtualbox.org/wiki/Downloads) installed
 - [Vagrant](https://www.vagrantup.com/downloads.html) installed
 - Access to the NetApp support site to download the cDot simulator. Site access may be limited to customers and partners.

## Installation

 - If you use [Git](http://git-scm.com/), clone this repo. If you don't use Git, [download](https://github.com/tlichten/tapster/archive/master.zip) the project and extract it.
 - Download [*Clustered Data Ontap 8.2.3 Simulator for VMware Workstation, VMware Player, and VMware Fusion*](http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/)
 - Save the downloaded file ```vsim_netapp-cm.tgz``` to this project's root directory, e.g. ```~/vagrant-vsim/vsim_netapp-cm.tgz```
 - Configure the Cluster base license.  
 Edit ```vsim.conf```, at the top set the 8.2.3 Cluster base license within ```CLUSTER_BASE_LICENSE``` accordingly. The license can be obtained from the [support site](http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/).  
`vsim.conf`: 
```bash
...
# Specify the Cluster Base License
# Important: Use the Cluster Base license for Clustered-Ontap Simulator 8.2.3 for
# VMware Workstation, VMware Player, and VMware Fusion
CLUSTER_BASE_LICENSE="SMKXXXXXXXXXXXXXXXXXXXXXXXXX"
...
```
**Important**: Use the **non-ESX build** license. 

## Usage

 - From this directory, e.g.  ```~/vagrant-vsim/```, run:
```bash
$ vagrant up
```
 - You will be asked to import the simulator as a Vagrant box on first run. Press ```y``` to proceed and import. The import will take a few minutes.
 - Wait until the VSim is ready. Once ready, to access the VSim console run:
```bash
$ vagrant ssh vsim
```
 - When done, you can destroy the entire environment. Run:
```bash
$ vagrant destroy
```

## Customization

##### Additional Licenses
Customize and configure any additional licenses like Flexclone or Snapmirror.  
The additional licenses can be obtained from the [support site](http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/).  
`vsim.conf`: 
```bash
...
# Define additional licenses,e.g. NFS, CIFS, as a comma seperated list without spaces
# Important: Use the licenses for the non-ESX build for the first node in a cluster
LICENSES="YVUXXXXXXXXXXXXXXXXXXXXXXXXX,SOHXXXXXXXXXXXXXXXXXXXXXXXXX,MBXXXXXXXXXXXXXXXXXXXXXXXXXX"
...
```
**Important**: Use the **non-ESX build** licenses. 

##### Networking  
The simulator will automatically be configured with a node-mgmt lif. You can customize the IP address of that lif to match your Vagrant networking setup.  
**Please note**: A dnsmasq process is used to offer the IP to the simulator. Please ensure you don't have a conflicting DHCP server on the same VBOXNet.  
`vsim.conf`: 
```ruby
...
# Host address for the VSim node auto mgmt lif which exposes ONTAPI
# Note: An additional service vm will deployed w/ the host address of x.x.x.253
NODE_MGMT_IP="10.0.207.3"
...
```

##### Customize the Clustered Data Ontap environment 

CLI commands and Chef can be used to customize the environment.

###### CLI commands  
You can customize any additional commands that will automatically be executed line-by-line once the simulator is running and the cluster is set up.  
`vsim.cmds`:
```bash
# Assigning all disks to node
disk assign -all true -node VSIM-01

# Cluster status
cluster show

# Add your own commands
```

###### Chef
You can customize the environment using the [NetApp cookbook for Chef](https://github.com/chef-partners/netapp-cookbook).  
Configure your resources in the file `/chef/cookbooks/tapster/recipes/default.rb`

```ruby
#include_recipe "netapp::aggregate"

netapp_aggregate "aggr1" do
	name "aggr1"
	disk_count 25
	action :create
end

# Add your own resources
```
The NetApp cookbook project provides [examples on the resources you can use](https://github.com/chef-partners/netapp-cookbook#netapp_user).

###### Ontapi
Though there is no convinience method provided, you can still manually use Ontapi. As an example, this project makes [use of ZAPI calls for the initial setup](https://github.com/tlichten/tapster/blob/master/provision/vsim.sh#L89).

## Uninstall

 - From this directory, e.g.  ```~/vagrant-vsim/```, run:
```bash
$ vagrant destroy
$ vagrant box remove VSim
$ vagrant box remove ubuntu/trusty64
```
 - Uninstall Virtualbox and Vagrant

## Known issues

 - There is **no error handling** in place, please do not just abort the program when things take a while. At first start, please be patient, preparing the VSim Vagrant box can take several minutes.
 - Occassionaly, ```vagrant destroy``` will error and can not delete all VM disks. These stale VMs may consume significant disk space. Manual deletion is required. Delete those VMs from your Virtualbox directory, e.g. `~\VirtualBox VMs`
 - The setup is currently limited to a single node cluster

```license
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
