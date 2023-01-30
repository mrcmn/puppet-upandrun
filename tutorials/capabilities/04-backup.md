# (4) Backup and Restore

__Create a Backup, destroy the primary, and recover to a working state.__

__Time to execute__: approx. 45 minutes to 90 minutes (depending on performance)

---
## Synopsis

__Backup__ and __Restore__ are two very important things every Puppet Enterprise admin must do! If the primary server gets lost and there is no backup then this can be a huge mess! It does not help to just have a reliable git repository to not lose the code. For example the certificates of the encrypted connection between the agent and the puppet primary server can not easily be recovered. This especially is more than true if you don't have other than the agent (PXP) access to your nodes, for example if you manage you nodes with deactivated SSH or deactivated WinRM protocols - which is widely used because it can improve the security setup of the infrastructure. It is a very good idea and strongly recommended to practice backup __and__ recovery to understand what is neccessary. For a hands-on experience git, vagrant and virtualbox are required to be installed as a prerequisite. Full internet access (no proxy) and a powerful laptop or desktop pc are required.

---
## Start of the virtual machines

In your laptop terminal window execute the following:

```
cd ~
git clone https://github.com/mrcmn/puppet-upandrun
cd puppet-upandrun
```

The following commands will start the machines and install Puppet Enterprise with one linux node (please wait for the primary to complete before starting the linux node):

```
vagrant up primary.vm
vagrant up linux.vm
```

After successful installation your Puppet Enterprise instance is available here: [https://192.168.50.4 (admin/puppetlabs)](https://192.168.50.4/) __Note__: Please be aware that we use self-signed certificates here. You have to include https in the browser address field and accept security warnings.

After installing the linux node make sure it had few agent runs that it appears with status __green__ in the Console UI.

---
## Steps to Backup and Restore

Some steps need to be done to run this:

1. [Create some example configuration](#1-create-some-example-configuration)
2. [Backup the environment](#2-backup-the-environment)
3. [Destroy the primary](#3-destroy-the-primary)
4. [Recover from Backup](#4-recover-from-backup)

### 1. Create some example configuration

For this example it is not mandatory to create any additional configuration. This example is mainly about the certificates and keys. But go ahead to configure whatever is interesting.

### 2. Backup the environment

We have a running Puppet Enterprise with one linux node. Connect to the primary:

```
vagrant ssh primary.vm
sudo bash
cd ~
```

On the primary as root execute the following:

```
puppet-backup create --dir=/var/puppetlabs/backups
```

__Note__: The directory /var/puppetlabs/backups is the default directory and will be used below. There are more command options in the [Puppet documentation](https://www.puppet.com/docs/pe/2021.7/backing_up_and_restoring_pe.html). After the backup has been created a message will be displayed that there are additional steps required. The private keys need to be saved:

```
cd /
tar -czvf var/puppetlabs/backups/console-services-keys.tar etc/puppetlabs/console-services/conf.d/secrets
tar -czvf var/puppetlabs/backups/orchestration-services-keys.tar etc/puppetlabs/orchestration-services/conf.d/secrets
ls -la var/puppetlabs/backups
```

Now we have all neccessary files in the backup directory. Of course we should save them in a different place! Let's put all files into one archive:

```
tar -czvf /vagrant/backup.tar /var/puppetlabs/backups/*
```

Exit from the primary vm ...

```
exit
```

... and get the files. In the ~/puppet-upandrun on the hosting machine (or at some other location) we do the following (if you use MacOS:

```
scp -i .vagrant/machines/primary.vm/virtualbox/private_key vagrant@192.168.50.4:/vagrant/backup.tar .
```

__Note__: __Windows__ users can use pscp instead of scp. pscp is part of the __PuTTY toolset__, but is probably not included in the PATH environment variable.

Now the backup is done and saved!

### 3. Destroy the primary

Now we simulate an event that destroys the primary:

```
vagrant destroy primary.vm
```

If you don't have a backup at this point you would have to reinstall Puppet Enterprise primary server. After that you have to connect to all nodes separately to force them to generate a new signing request to our new server.

__Note__: If you have created some example configs that are in use by the agent, you can now see that the agent is still enforcing the desired state while puppet primary is lost.

### 4. Recover from Backup

To recover first a new puppet primary is needed. Execute the following:

```
vagrant up primary.vm
```

Login to the primary:

```
vagrant ssh primary.vm
sudo bash
cd /
```

In this case vagrant has automatically synced the backup into this machine to the /vagrant/ directory. Because we kept the file structure during the tar process, we can now easily do:

```
tar xvf vagrant/backup.tar
```

After that we extract our keys:

```
tar xvf var/puppetlabs/backups/orchestration-services-keys.tar
tar xvf var/puppetlabs/backups/console-services-keys.tar
```

... and start the restore command. Be aware that the filename in your environment is different!

```
puppet-backup restore var/puppetlabs/backups/pe_backup-2022-08-22_14.54.44_UTC.tgz
```

After the restore command finishes, execute an agent run on the primary and after that on a linux node. That will happen automatically, but if we don't want to wait:

```
puppet agent -t
exit 
```
```
vagrant ssh linux.vm
sudo bash
cd ~
puppet agent -t
exit
```

Now the console shows that both agents are connected successfully. Configurations now can be managed by the puppet server again. Done!

__Few notes__:
* Further actions are needed if the hostname of the primary server has changed. See docs for details.
* For code-manager a new access token has to be created. The webhook for git repos would need to be updated.
* It is recommended to store the backup together with the Puppet Enterprise installer, if the backup is kept for longer time periods.

---
## Summary

Verified:

* Created a backup and restored the primary server via puppet commands.
* Restore avoids the manual process of connecting to all nodes to recreate the certificates.
* Agent enforcement of desired state configuration is active during the loss of the Puppet primary server.

---
## Additional information

- [www.puppet.com](https://www.puppet.com)

---
## Cleanup

You can now delete this environment after you finished any additional testings by executing the following commands:

```
vagrant destroy primary.vm
vagrant destroy linux.vm
```

You can now delete the puppet-upandrun directory and its content.
