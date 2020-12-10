# upandrun #

A very simple vagrant environment for getting up and running with Puppet Enterprise. 

This repo provides you with a complete, yet simple environment that consists of a master (CentOS7), as well as a Linux (CentOS7) and Windows VM. 

## Steps ##

Before cloning this repo, you'll have to install both [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads). 

Once both are installed, you'll be able to do the following steps from your CLI:

```
git clone https://github.com/mrcmn/puppet-upandrun

cd puppet-upandrun
```
**vagrant up each vm separately, wait for the previous vm to load fully before bringing up the next one** 

```
vagrant up master.vm

vagrant up linux.vm

vagrant up windows.vm

vagrant status
```
**ssh into each box individually**

```
vagrant ssh master.vm
vagrant ssh linux.vm
vagrant ssh windows.vm

```

In order to get into your boxes, you can either ssh in from your command line, or you can use the VirtualBox interface. Windows user and password is 'vagrant' You can read more on Vagrant commands in their [docs](https://www.vagrantup.com/docs/cli/). 

You can also see your console in the browser by going to 'https://192.168.50.4'. This should give you a view of the GUI for continued management of your nodes.
