# TAPSTER

Use [Vagrant](https://www.vagrantup.com) to **experimentally** manage a Clustered Data Ontap simulator (cDot VSim) 

##### Credits
This project makes use of the excellent instructions on [how to simulate Data ONTAP 8.1.1. with Virtualbox by BOBSHOUSEOFCARDS](http://community.netapp.com/t5/Simulator-Discussions/Simulate-ONTAP-8-1-1-withVirtualBox/m-p/2227#M89)

##### Caution
This project is **experimental** and uses [Virtualbox](https://www.virtualbox.org) which is a **non-supported** configuration for the simulator. There are smaller *hacks* for making this work and it is not pretty. Use at own risk. Please see known issues at the bottom.

##### Goal
The goal of this project is to experimentally provide a largely automated, turn-key setup of a Clustered Data Ontap simulator using Vagrant in order to ease demos, speed up testing, and help become more familiar with cDot and its integration in projects like OpenStack.

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
 - Configure the the Cluster base license. **Important**: Use the **non-ESX build** license. Edit ```vsim.conf```, at the top set the 8.2.3 Cluster base license within ```CLUSTER_BASE_LICENSE``` accordingly. The license can be obtained from the [support site](http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/).
 - Optionally, edit  ```vsim.conf ``` and configure any additional licenses as a comma separated list within  ```LICENSES ``` accordingly. **Important**: Use the **non-ESX build licenses**. The additional licenses can be obtained from the [support site](http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/).
 - **Double check** you have added the **non-ESX build** licenses.
 
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
 - Occassionaly, ```vagrant destroy``` will error and can not delete all VM disks. Manual deletion is required.
 - The setup is limited to a single node cluster

```license
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```
