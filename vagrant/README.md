# SlamData Vagrantfile #

[Vagrant](https://www.vagrantup.com/) is a fantastic tool for creating virtual machines (VMs) in a scripted fashion.  It 
has become a ubiquitous tool among those embracing the DevOps approach. 

The example Vagrantfile in this folder can be used to provision, via Vagrant, an Ubuntu 15.10 Desktop VM with SlamData 
installed.


## Prerequisites ##
* [VirtualBox](https://www.virtualbox.org/) 5.0.16 or later.
* [Vagrant](https://www.vagrantup.com/) 1.8.1 or later.


## Usage ##
1. Clone this repository to your computer.
2. Open a terminal window and navigate to the folder with the Vagrantfile.
3. Launch the VM with the ```vagrant up``` command:

    vagrant up

The first time the VM is launched, Vagrant will pull down the base box and run the provisioning script. Be sure to 
review the Notes section below. 

Allow the provisioning script to fully complete before using the VM.  Once provisioned, it's a good idea to keep the
VM updated with the latest OS updates.

As is common with Vagrant-generated VMs, the default username and password are both ```vagrant```, and the 
```\vagrant``` folder on the VM is shared via VirtualBox to the folder containing the Vagrantfile.

Once the VM is provisioned, you can launch SlamData by clicking the Search button and typing SlamData, or by launching
Firefox and navigating to http://localhost:20223/slamdata/index.html .


## Notes ##
At the time this example was authored, Canonical had not posted an official Ubuntu 15.10 Desktop base box on Vagrant 
Atlas.  As a result, this Vagrantfile is based on a box uploaded by 
[kevinmellott91](https://atlas.hashicorp.com/kevinmellott91/boxes/ubuntu-15.10-desktop-amd64).  It has been observed 
that this base box can generate a few error messages on startup.  These generally clear up after additional OS updates 
have been applied and the VM has been rebooted.  You should evaluate whether this base box is suitable for your 
environment.  A different base box can be easily substituted in the Vagrantfile. 

The example is configured with default Vagrant networking.  In order to connect to an external MongoDB instance, you
will likely need to configure additional network settings in the Vagrantfile.  Alternatively, for simple testing, 
you can install a local MongoDB instance on the VM itself and connect to that.





