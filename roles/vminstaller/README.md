Ansible Role : VMINSTALLER
===========================

This ansible role is for installing virtual machines using ansible with libvirt.

The role presumes you have an hypervisor running Linux with KVM and Libvirt.
It uses virt-install to execute the installation of the VM.
The role can deply to multiple architectures and distributions.


### Variable Listing ###

The list of the variables that are used :

* __hyper__ (required)
    - The hypervisor the virtual machine will run on, this variable is the ansible host name as in the host file
* __distro__ (required)
    - The distribution name that the virtual machine need to be installed with
* __machinearch__ (required)
    - The machine architecture to use for the virtual machine
* __machinetype__ (optional) [ the machinetype used by qemu ]
    - The machine type of the virtual machine and refers to the machine type qemu will use, if none is given the default machine type will be used
* __virtualcputype__ (optional) [ whatever qemu can use ]
    - The cpu emulation type of the virtual machine that qemu can virtualize, if none is given the default qemu cputype is used
* __virtualcpus__ (required)
    - The number of vcpus to assing to the virtual machine (or the multiple of virtualsockets x virtualcores x virtualthreads)
* __virtualsockets__ (optional) [required if virtualcores and virtualthreads is used]
    - The number of sockets that the vcpus use
* __virtualcores__ (optional) [required if virtualcores and virtualthreads is used]
    - The number of cores the vcpu has per socket
* __virtualthreads__ (optional) [required if virtualcores and virtualthreads is used]
    - The number of threads a vcpu core has
* __ramsize__ (required)
    - The total RAM size of the virtual machine
* __vmwaittime__ (required)
    - The time to wait before polling if the virtual machine has completed installation
* __language__ (required)
    - The language the virtual machine wil be installed in
* __keyboard__ (required)
    - The keyboard of the virtual machine
* __timezone__ (required)
    - The timezone of the virtual machine
* __rootpwd__ (required) [ password that goes into the autoinstall file ]
    - The root password of the virtual machine
* __sshdrsakeylength__ (required) [_RHEL_][_CENTOS_][_SCIENTIFIC_][_POWEREL_][_UBUNTU_][_DEBIAN_]
    - The ssh rsa key length to regenerate
* __sshdecdsakeylength__ (required) [_RHEL_][_CENTOS_][_SCIENTIFIC_][_POWEREL_][_UBUNTU_][_DEBIAN_]
    - The ssh ecdsa key length to regenerate
* __locale__ (required)
    - The locale setting of the virtual machine
* __virtualfilespath__ (required)
    - The path used to store any temporary files
* __nics__ (required) [ each line is a nic in the guest with the link on the hypervisor ] { type: (required) , name: (required) , model: (required) , device: (required) , onboot: (required) , bootproto: (required) , ip: (required) , netmask: (required) , gateway: (required) , route: (required) , nameserver: (required) , network (optional) , broadcast: (optional) , mtu: (optional) }
    - The mapping of physical and virtual networking with all networking information for the networking card in the virtual machine
* __kickstartdevice__ (optional) [_RHEL_][_CENTOS_][_SCIENTIFIC_][_POWEREL_]
    - The network interface in the virtual machine to use for kickstarting the system
* __preseednic__ (optional) [_UBUNTU_][_DEBIAN_]
    - The network interface in the virtual machine to use for preseed the system
* __autoinstallnic__ (required) [_OPENBSD_]
    - The network interface in the virtual machine to use to run the autoinstall script
* __hostname__ (required)
    - The hostname of the virtual machine
* __disks__ { path: (required) , size: (required) , }
    - The disks that need to be created
* __iscsi__ (optional) [ creates iscsi initiator lun's for use in the installation process ] { iqnname: (required) , server: (required) , username: (required) , password: (required) }
    - The iscsi disk to setup in the virtual machine
* __iscsinic__ (required)
    - The network controller to use for the iscsi connection
*  __partitions__ (required) [_RHEL_][_CENTOS_][_SCIENTIFIC_][_POWEREL_][_UBUNTU_][_DEBIAN_]
    - The partition as the installer wants them seperate per line, on Red Hat based systems, kickstart partitions line, on Debian based systems preseed partitions line
* __bootloader__ (required) [_RHEL_][_CENTOS_][_SCIENTIFIC_][_POWEREL_]
    - The bootloader kickstart line that is required to install the bootloader of the installation, eg : "bootloader --location=mbr --driveorder=vda,vdb,vdc"
* __bootpartition__ (required) [_UBUNTU_][_DEBIAN_]
    - The device name of the MBR device
* __python_version__ (optional) [_OPENBSD_]
    - The python version to install so we can use ansible modules
* __users__ (optional) { name: (required) , id: (required) , sshpubkey: (required) )
    - The users to be created on the virtual machine, this is actually used by another role, but has been added here for future usage
* __webserver__ (required) [_UBUNTU_][_DEBIAN_]
    - The webserver name to be used for post-preseed commands as listed in the inventory
* __webpath__ (required) [_UBUNTU_][_DEBIAN_]
    - The path on the webserver where to place the post-preseed file
* __weburl__ (required) [_UBUNTU_][_DEBIAN_]
    - The url that the new vm can use to get the post-preseed file from the webserver
* __webuser__ (required) [_UBUNTU_][_DEBIAN_]
    - The user on the webserver that has access to the folder and that the webserver deamon can read from

### Examples ###

See the example folder

* Red Hat, CentOS, Scientific Linux, Oracle Unbreackable, PowerEL - version 7
    - examples/el7
* Ubuntu based distribution LTS 14.04, 16.04
    - examples/ubuntu
* OpenBSD based distribution 5.7 or higher
    - examples/openbsd


### Dependencies ###

*   Ansible (on the management node)
*   Libvirt with python modules including the virt-install tool
*   Access to the Linux Distribution Repositories (on the hypervisor)
*   qemu-img module for ansible


### Architectures ###

The role is currently supported for :
* x86_64
* powerpc (ppc64,ppc64le,ppc64el,powerpc)


### Distributions ###

Currently working distributions that have been tested (in a limited capacity):

* CentOS
    - CentOS7
    - CentOS6

* Red Hat
    - RHEL7
    - RHEL6

* PowerEL
    - PEL7
* Scientific Linux
    - SL7
    - SL6

* Debian :
    - debian8
    - debian7

* Ubuntu :
    - ubuntu 16.04 lts
    - ubuntu 14.04 lts

* OpenBSD
    - from 5.7 using autoinstall

* MS Windows
    - WinSrv2012(r2)
    - WinSrv2008(r2)



### Work In Progress ###

The role is being worked on for the following distros :

* FreeBSD (works in some cases)
* Windows Server 2016
* Windows 7 Pro / Windows 10 Pro (VDI, requires better graphics support)


### Authors ###

-   Toshaan Bharvani - <toshaan@vantosh.com> - (http://www.vantosh.com)

