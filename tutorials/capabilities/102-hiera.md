# (102) Hiera

__Let's run through an example using hiera. This will be exactly the same as [(101) Roles and Profiles](https://github.com/mrcmn/puppet-upandrun/blob/main/tutorials/capabilities/101-roles-profiles.md) but this time with Hiera. The following example is taken from [puppet-enterprise-guide.com](https://puppet-enterprise-guide.com/theory/hiera-overview.html) that previsously has been written by colleagues at Puppet. And also here we have a Puppet instance to try it!__

__Time to execute__: approx. 2 hours (depending on performance)

---
## Synopsis

This tutorial runs through some hiera examples using the content from the Roles and Profiles example. Two things happen here now: 1) The paramaters from this provious example move to hiera and 2) the node classification will also happen via hiera and not in the node groups.

In the following we spin up a new Puppet environment by running through the [(2) Code Manager tutorial](https://github.com/mrcmn/puppet-upandrun/blob/main/tutorials/capabilities/02-codemanager-config.md) and without the Cleanup in the end of that tutorial, we proceed here. 

__Note__: We will work with four VMs here, so you need some resources (RAM and CPU) to be available on your laptop.

---
## Prepare the environment

If you don't already have an environment with Gitlab instance, then use the following now: [(2) Code Manager tutorial](https://github.com/mrcmn/puppet-upandrun/blob/main/tutorials/capabilities/02-codemanager-config.md). So don't destroy the environment in the end, but come back here to run through the following below.

__Note__: Yes, instead of creating everything from scratch, you can reuse the previous environment, but make sure you take out or delete the classification made in the Node Groups, destroy the linux.vm and the windows.vm, and then execute as root on the primary.vm `puppet node purge linux.vm` and `puppet node purge windows.vm` to delete node data and certificate info from the primary server. And: We replace the site.pp. If you have some settings done in your instance - make a backup copy!

---
## Hiera

1. [Overview about the example](#1-overview)
2. [Create Profiles](#2-create-the-profiles)
3. [Create Roles](#3-create-the-roles)
4. [Create Hiera classification](#4-create-the-classification)
5. [See the results](#5-see-the-results)

### 1. Overview

If you have already the primary.vm and the gitlab.vm running, then you need to spin up the linux.vm and the windows.vm but running these commands:

```
vagrant up linux.vm
vagrant up windows.vm
```

Give both machines some time to connect to Puppet Enterprise and be visible in the Status page of the Console.

After that we have four machines running and ready for the following. We are going to install an Apache driven "Hello World" webpage on Linux and an IIS driven one on the Windows machine.

This is the structure we are going to create. If you want to know the theory behind it, please refer to the [Puppet Enterprise Guide](https://puppet-enterprise-guide.com/theory/roles-and-profiles-overview.html) or the official documentation ([see below](#additional-information)). 

```
Role lin_webserver.pp     - a role that has everything for the webserver on Linux
└── profiles
    ├── apache.pp         - the apache webserver
    ├── lin_firewall.pp   - firewall settings
    └── lin_webpage.pp    - the example web application

Role win_webserver.pp     - a role that has everything for the webserver on Windows
└── profiles
    ├── iis.pp
    ├── win_firewall.pp
    └── win_webpage.pp
```

First we create all needed six profiles, after that we create the two roles. 

We will also create our hiera definitions and edit the 
* `manifests/site.pp`
* `data/nodes/linux.vm.yaml`
* `data/nodes/windows.vm.yaml`

And then we run it.

Make sure you are here, then you can run through the below by just copy&paste the command blocks to the primary.vm:

```
[root@primary control-repo]# pwd
/root/repo/control-repo
[root@primary control-repo]#
```

The following assumes that you do not reuse the previous environment.

### 2. Create the Profiles

First we have to update the Puppetfile to make the modules from the forge available here:

```
cat <<EOF >> Puppetfile
mod 'puppetlabs-firewall',                    :latest
mod 'puppetlabs-apache',                      :latest
mod 'puppetlabs-stdlib',                      :latest

mod 'puppetlabs-pwshlib',                     :latest
mod 'puppetlabs-registry',                    :latest
mod 'puppetlabs-iis',                         :latest
mod 'puppet-windows_firewall',                :latest

mod 'puppetlabs/concat',                      :latest
EOF
```

#### Webservers

Create the apache profile:

```
cat <<EOF > site-modules/profile/manifests/apache.pp
# Profile to install a basic apache webserver
class profile::apache {
    class { 'apache':}
}
EOF
```
Create the iis profile:

```
cat <<EOF > site-modules/profile/manifests/iis.pp
# Profile to install a basic IIS webserver
class profile::iis (
  Array $iis_feature_list,
) {
  $iis_features = $iis_feature_list

     iis_feature { $iis_features:
       ensure => 'present',
     }
}
```

The above contains the first variable `$iis_feature_list` which needs to be added to hiera:

```
cat <<EOF >> data/nodes/windows.vm.yaml
profile::iis::iis_feature_list: ['Web-WebServer','Web-Scripting-Tools']
```

__Note__: It is probably not the most sophisticated way to apply these settings to specific nodes. It would be best practice to use another fact (instead of the node) to group together all similar webservers. But for now we leave it this way to just show the idea.

#### Firewalls

Create the firewall settings for Linux. Firewall is probably not needed here in the local environment. But still a good example.

```
cat <<EOF > site-modules/profile/manifests/lin_firewall.pp
# Profile to open ports for HTTP/HTTPS access
class profile::lin_firewall(
  String $fw_web_action,
  String $fw_web_proto,
  Array $fw_web_port_list,
  String $fw_web_description
) {
  
  firewall { $fw_web_description:
    dport  => $fw_web_port_list,
    proto  => $fw_web_proto,
    action => $fw_web_action,
  }
}
EOF
```

Now we need to set data in hiera:

```
cat <<EOF >> data/nodes/linux.vm.yaml
profile::lin_firewall::fw_web_action: accept
profile::lin_firewall::fw_web_proto: tcp
profile::lin_firewall::fw_web_port_list: [80, 443]
profile::lin_firewall::fw_web_description: 100 allow http and https access
```

Create the firewall settings for Windows.

```
cat <<EOF > site-modules/profile/manifests/win_firewall.pp
class profile::win_firewall (
  String $win_fw_name, 
  String $win_fw_ensure,
  String $win_fw_exception, 
  String $win_fw_exception_ensure, 
  String $win_fw_direction, 
  String $win_fw_action, 
  Boolean $win_fw_enabled,
  String $win_fw_protocol, 
  String $win_fw_local_port, 
  String $win_fw_remote_port, 
  String $win_fw_display_name,
  String $win_fw_description 
) 
{

  class { $win_fw_name:
    ensure => $win_fw_ensure,
  }

  windows_firewall::exception { $win_fw_exception:
    ensure       => $win_fw_exception_ensure,
    direction    => $win_fw_direction,
    action       => $win_fw_action,
    enabled      => $win_fw_enabled,
    protocol     => $win_fw_protocol,
    local_port   => $win_fw_local_port,
    remote_port  => $win_fw_remote_port,
    display_name => $win_fw_display_name,
    description  => $win_fw_description,
  }
}
EOF
```

Now we need to set data in hiera:

```
cat <<EOF >> data/nodes/windows.vm.yaml
profile::win_firewall::win_fw_name: windows_firewall
profile::win_firewall::win_fw_ensure: running
profile::win_firewall::win_fw_exception: HTTP/HTTPS
profile::win_firewall::win_fw_exception_ensure: present
profile::win_firewall::win_fw_direction: in
profile::win_firewall::win_fw_action: allow
profile::win_firewall::win_fw_enabled: true
profile::win_firewall::win_fw_protocol: TCP
profile::win_firewall::win_fw_local_port: "80,443"
profile::win_firewall::win_fw_remote_port: any
profile::win_firewall::win_fw_display_name: IIS Webserver access HTTP/HTTPS
profile::win_firewall::win_fw_description: Puppet Inbound rule for an IIS Webserver via HTTP/HTTPS [TCP 80,443]
```

#### Webpages

Finally we want a webpage. Let it be a "Hello World" at this point.

For Linux:

```
cat <<EOF > site-modules/profile/manifests/lin_webpage.pp
# Profile to add custom webserver content
class profile::lin_webpage (
  String $webcontent,
  String $weblocation
) {

  file { $weblocation:
    ensure  => file,
    content => $webcontent,
  }
}
EOF
```

Now we need to set data in hiera:

```
cat <<EOF >> data/nodes/linux.vm.yaml
profile::lin_webpage::webcontent: Hello World! This page was generated using data from the linux nodes data layer in Hiera and is specific to only this node!
profile::lin_webpage::weblocation: /var/www/html/index.html
```

And we add content for Windows:

```
cat <<EOF > site-modules/profile/manifests/win_webpage.pp
# Profile to add custom webserver content
class profile::win_webpage (
  String $webcontent,
  String $weblocation
) {

  file { $weblocation:
    ensure  => file,
    content => $webcontent,
  }
}
EOF
```

Now we need to set data in hiera:

```
cat <<EOF >> data/nodes/windows.vm.yaml
profile::win_webpage::webcontent: Hello World! This page was generated using data from the windows nodes data layer in Hiera and is specific to only this node!
profile::win_webpage::weblocation: C:\Inetpub\wwwroot\index.html
```

### 3. Create the Roles

The roles now combine several profiles together. Usually they just contain include statements. Here the roles are the same as in the previous example, because we don't assign any data values in the roles.

```
cat <<EOF > site-modules/role/manifests/lin_webserver.pp
class role::lin_webserver {
  include profile::lin_firewall
  include profile::apache
  include profile::lin_webpage
}
EOF
```

```
cat <<EOF > site-modules/role/manifests/win_webserver.pp
class role::win_webserver {
  include profile::win_firewall
  include profile::iis
  include profile::win_webpage
}
EOF
```

Now we have all files created. We need to push the changes to the control-repo on the gitlab.vm:

```
eval `ssh-agent -s`
ssh-add /etc/puppetlabs/puppetserver/ssh/id-control_repo.rsa
```

And then:

```
[root@primary control-repo]# git add .
[root@primary control-repo]# git commit -m "added webpages"
[root@primary control-repo]# git push origin production
```

After few moments you should be able to see both roles `role::win_webserver` and `role::lin_webserver` selectable in the classes field of the Node Group configuration page. But this time we don't classify the nodes via the Console UI. We could do that, but I want to highlight one method of classifying nodes with hiera.

### 4. Create the Classification

The hiera classification is configured in the site.pp:

```
cat <<EOF > manifests/site.pp
File { backup => false }
node default {
  lookup( {
    'name'          => 'classes',
    'value_type'    => Array,
    'default_value' => [],
    'merge'         => {
      'strategy' => 'unique',
    },
  } ).each | $c | {
    include $c
  }
}
EOF
```

The above simply tells Puppet to look into hiera for classes to apply to nodes. It uses the lookup-function and here we tell this function to look for Array definitions in hiera. Now depending on the facts hiera looks for files in the data directory and takes the content definition from there. I our case it is the node name, so for windows.vm we put the classes-Array into the windows.vm.yaml ...

```
cat <<EOF >> data/nodes/windows.vm.yaml
classes:
  - role::win_webserver
```

... and for the linux.vm we do it into the linux.vm.yaml.

```
cat <<EOF >> data/nodes/linux.vm.yaml
classes:
  - role::lin_webserver
```

We need to push the changes again to the control-repo on the gitlab.vm:

```
[root@primary control-repo]# git add .
[root@primary control-repo]# git commit -m "added classification"
[root@primary control-repo]# git push origin production
```

It now needs agent runs to get the web examples installed and available.

### 5. See the Results

If you haven't done the following on this puppet instance before, you need to run this only once:

```
[root@primary control-repo]# puppet access login --lifetime 360d
Enter your Puppet Enterprise credentials.
Username: admin
Password: puppetlabs

Access token saved to: /root/.puppetlabs/token
[root@primary control-repo]#
```

Then you can trigger an agent run on all agents:

```
puppet job run --no-enforce-environment --query 'nodes {deactivated is null and expired is null}'
```

See the webpage on the Linux server: 

[http://192.168.50.6/](http://192.168.50.6/)

And on the Windows server:

[http://192.168.50.5/](http://192.168.50.5/)

Done!

---
## Summary

Verified:

* Created a basic Roles and Profiles structure.
* Created variables via hiera.
* Used hiera to classify the nodes.
* Checked for the "Hello World" application on both servers: linux.vm and windows.vm!

---
## Additional information

- [Puppet Documentation](https://www.puppet.com/docs/pe/latest/)
- [Separating data (Hiera)](https://www.puppet.com/docs/puppet/7/hiera.html)
- [Puppet Enterprise Guide](https://puppet-enterprise-guide.com/)
- [Modern Puppet node classification](https://dev.to/betadots/modern-puppet-node-classification-3ngk)
- [Removing nodes](https://support.puppet.com/hc/en-us/articles/1500010845362-Removing-nodes-Understanding-puppet-node-purge-node-ttl-and-node-purge-ttl-in-Puppet-Enterprise)

---
## Cleanup

You can now do more things with this environment or halt this environment (shut down) if you want to use it again in the future. Or delete this environment after you finished any additional testings.
