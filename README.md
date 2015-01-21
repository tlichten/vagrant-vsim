vagrant-vsim
============
**Caution**: This project is in pre alpa state. This project uses Virtualbox which is not supported. Use at own risk. Please see known issues at the bottom.

**The goal of this project is to create a largely automated setup of a Clustered Data Ontap simulator using vagrant in order to ease demos, speed up testing and help become more familiar with cDOT and its integration in projects like OpenStack.** 


System requirements
============
 - 8 GB Ram
 - 20 GB of free disk space
 - SSD 
 - Linux / Mac

Install
============
 - Install Virtualbox if not already installed: https://www.virtualbox.org/wiki/Downloads
 - Install Vagrant if not already installed: https://www.vagrantup.com/downloads.html
 - Clone this repo
 - Download the Clustered Data Ontap 8.2.1 Simulator for VMware Workstation, VMware Player, and VMware Fusion from http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/
 - Save the downloaded file 'vsim_netapp-cm.tgz' to this project's root directory, e.g. ~/vagrant-vsim/vsim_netapp-cm.tgz
 - You need to add the Cluster base license first. Important: Use the non-ESX build license. Edit vsim.conf, at the top set the 8.2.1 Cluster base license within CLUSTER_BASE_LICENSE accordingly. The license can be obtained from http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/.
 - **Make sure you have added the base license for the non-ESX build**
 - Optionally, edit vsim.conf and define any additional licenses as a comma separated list within LICENSES accordingly. Important: Use the non-ESX build licenses. The additional licenses can be obtained from http://mysupport.netapp.com/NOW/download/tools/simulator/ontap/8.X/
 - **For any additonal licenses, make sure you have added the non-ESX build one for the first node**
 - Run 'vagrant up' from this directory, e.g. ~/vagrant-vsim/
 - You will be asked to import the Simulator as a Vagrant box. Press "y" to proceed and import. The import will take a few minutes
 - Wait until the VSim is ready. Once ready, you can use 'vagrant ssh vsim' to access the VSim console


Uninstall
============
 - Run 'vagrant destroy' from this directory, e.g. ~/vagrant-vsim/. 
 - Run 'vagrant box remove vsim'
 - Run 'vagrant box remove trusty'
 - Optionally, uninstall Virtualbox and vagrant

Known issues
============
 - There is no error handling in place, please do not just abort the program when things take a while. At first start, please be patient, preparing the VSim vagrant box can take several minutes.
 - Windows is currently not supported
 - Occassionaly, vagrant destroy will error can not delete all VM disks. Manual deletion is required.
 - The setup is limited to a single node cluster


THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
