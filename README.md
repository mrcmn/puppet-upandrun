# upandrun

A very simple vagrant environment for getting up and running with Puppet Enterprise. 

This repo provides you with a complete, yet simple environment that consists of a Primary Puppet Enterprise server (CentOS7), as well as a Replica Linux server node, a "normal" Linux agent node (CentOS7), a Windows agent VM, and an Ubuntu Gitlab instance. If you run this on your local computer, make sure that you have 16 GB RAM minimum (better 32 GB or more if you want to use all machines at the same time).

This is not meant to be a working, fully configured production environment. This repo contains virtual machines for training and demo purposes only!

## Basic usage instructions

Before cloning this repo, you'll have to install both [Vagrant](https://www.vagrantup.com/) and [VirtualBox](https://www.virtualbox.org/wiki/Downloads). (In a proxy environment, you probably have to figure out how downloading the installer works, and then the following might help you to figure out how to download images and vagrant plugin, and how to configure the Vagrantfile: [Stackoverflow: How to use vagrant in a proxy environment](https://stackoverflow.com/questions/19872591/how-to-use-vagrant-in-a-proxy-environment). The following assumes that you have no proxy.)

Once both are installed, you'll be able to do the following steps from your CLI:

```
git clone https://github.com/mrcmn/puppet-upandrun

cd puppet-upandrun
```
**vagrant up each vm separately, wait for the previous vm to load fully before bringing up the next one** 

```
vagrant up primary.vm

vagrant up linux.vm

vagrant up windows.vm

vagrant status
```

Additionaly start the following if required:

```
vagrant up gitlab.vm

vagrant up replica.vm
```

**ssh into each box individually**

```
vagrant ssh primary.vm
vagrant ssh replica.vm
vagrant ssh linux.vm
vagrant ssh gitlab.vm
```

In order to get into your boxes, you can either ssh in from your command line, or you can use the VirtualBox interface. Use Remote Desktop for Windows, user and password is 'vagrant' You can read more on Vagrant commands in their [docs](https://www.vagrantup.com/docs/cli/). 

You can also see your console in the browser by going to 'https://192.168.50.4' (admin/puppetlabs). This should give you a view of the GUI for continued management of your nodes. The gitlab instance uses 'http://192.168.50.7' (root/puppetlabs).

## Tutorials

Here are a few tutorials to try out few Puppet Enterprise features with this repository:

* [Puppet Enterprise hands-on Tutorials](tutorials/README.md)
