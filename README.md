vagrant-vsim
============
**Credits**: This project makes use of the excellent instructions on how to simulate Data ONTAP 8.1.1. with Virtualbox by BOBSHOUSEOFCARDS: http://community.netapp.com/t5/Simulator-Discussions/Simulate-ONTAP-8-1-1-withVirtualBox/m-p/2227#M89

**Caution**: This project is in pre alpa state. This project uses Virtualbox which is a non supported configuration. There are smaller "hacks" for making this work and it is not pretty. Use at own risk. Please see known issues at the bottom.

**Goal**: The goal of this project is to create a largely automated setup of a Clustered Data Ontap simulator using vagrant in order to ease demos, speed up testing and help become more familiar with cDOT and its integration in projects like OpenStack.


System requirements
============
 - 8 GB Ram
 - 20 GB of free disk space
 - SSD 
 - Linux / Mac
 - Internet connection on first run

Install
============
 - Install Virtualbox if not already installed: https://www.virtualbox.org/wiki/Downloads
 - Install Vagrant if not already installed: https://www.vagrantup.com/downloads.html
 - Clone this repo
 - Download the Clustered Data Ontap 8.2.1 Simulator for VMware Workstation, VMware Player, and VMware Fusion from http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/
 - Save the downloaded file 'vsim_netapp-cm.tgz' to this project's root directory, e.g. ~/vagrant-vsim/vsim_netapp-cm.tgz
 - You need to add the Cluster base license first. **Important**: Use the **non-ESX build** license. Edit vsim.conf, at the top set the 8.2.1 Cluster base license within CLUSTER_BASE_LICENSE accordingly. The license can be obtained from http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/.
 - Optionally, edit vsim.conf and define any additional licenses as a comma separated list within LICENSES accordingly. **Important**: Use the **non-ESX build licenses**. The additional licenses can be obtained from http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/
 - Double check you have added the **non-ESX build** licenses.
 - Run 'vagrant up' from this directory, e.g. ~/vagrant-vsim/
 - You will be asked to import the Simulator as a Vagrant box. Press "y" to proceed and import. The import will take a few minutes
 - Wait until the VSim is ready. Once ready, you can use 'vagrant ssh vsim' to access the VSim console
 - When done, you can destroy the environment using 'vagrant destroy' and recreate with 'vagrant up'


Uninstall
============
 - Run 'vagrant destroy' from this directory, e.g. ~/vagrant-vsim/. 
 - Run 'vagrant box remove vsim'
 - Run 'vagrant box remove trusty'
 - If desired, uninstall Virtualbox and vagrant

Known issues
============
 - There is no error handling in place, please do not just abort the program when things take a while. At first start, please be patient, preparing the VSim vagrant box can take several minutes.
 - Windows is currently not working but may be possible in the future
 - Occassionaly, vagrant destroy will error can not delete all VM disks. Manual deletion is required.
 - The setup is limited to a single node cluster


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
