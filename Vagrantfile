Vagrant.configure("2") do |config|

  config.vm.define "primary.vm" do |primary|
    primary.vm.box = "ubuntu/jammy64" # version 22
    primary.vm.hostname = "primary.vm"
    primary.vm.provision "shell", path: "scripts/primarybootstrapubu.sh"
    primary.vm.network "private_network", ip: "192.168.50.4"
    primary.vm.provider "virtualbox" do |v|
      v.memory = 8192
      v.cpus = 2
    end
  end 
  
  config.vm.define "replica.vm" do |replica|
    replica.vm.box = "ubuntu/jammy64" # version 22
    replica.vm.hostname = "replica.vm"
    replica.vm.provision "shell", path: "scripts/replicabootstrapubu.sh"
    replica.vm.network "private_network", ip: "192.168.50.41"
    replica.vm.provider "virtualbox" do |v|
      v.memory = 8192
      v.cpus = 2
    end
  end

  config.vm.define "windows.vm" do |windows|
    windows.vm.box = "gusztavvargadr/windows-server"
    windows.vm.communicator = "winrm"
    windows.vm.hostname = "windows"
    windows.vm.provision "shell", path: "scripts/windows_agent.ps1"
    windows.vm.network "private_network", ip: "192.168.50.5"
    windows.vm.provider "virtualbox" do |v|
      v.memory = 2048
    end
  end

  config.vm.define "ubuntu.vm" do |ubuntu|
    ubuntu.vm.box = "ubuntu/jammy64"
    ubuntu.vm.hostname = "ubuntu.vm"
    ubuntu.vm.network "private_network", ip: "192.168.50.6"
    ubuntu.vm.provision "shell", path: "scripts/ubuntu_agent.sh"
    ubuntu.vm.provider "virtualbox" do |v|
      v.memory = 2048
    end
  end   # of |ubuntu|
  
  config.vm.define "gitlab.vm" do |gitlab|
    gitlab.vm.box = "ubuntu/jammy64" # version 22
    gitlab.vm.hostname = "gitlab.vm"
    gitlab.vm.network "forwarded_port", guest: 8000, host: 8000
    gitlab.vm.network "private_network", ip: "192.168.50.7"
    gitlab.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update
      sudo apt-get upgrade -y
      sudo apt-get install -y ca-certificates curl openssh-server
      # we skip postfix, and don't want emails sent # https://computingforgeeks.com/configure-postfix-send-only-smtp-server-on-ubuntu/
      curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
      sudo apt-get -y install gitlab-ce
      sudo apt-get update
      # set gitlab config as follows:
      sudo sed -ri "s/^external_url 'http:.*'/external_url 'http:\\/\\/192.168.50.7'/g" /etc/gitlab/gitlab.rb
      sudo sed -ri "s/^\# gitlab_rails\\['initial_root_password'\\] = \\"password\\"/gitlab_rails\\['initial_root_password'\\] = \\"puppetlabs\\"/g" /etc/gitlab/gitlab.rb
      sudo gitlab-ctl reconfigure
      echo "."
      echo "."
      echo "."
      echo "You now can login to http://192.168.50.7 using root/puppetlabs credetials!"
    SHELL
    gitlab.vm.provider "virtualbox" do |vb|
      vb.memory = 6144
      vb.cpus = 2
    end
  end   # of |gitlab|

  config.vm.define "ldap.vm" do |ldap|
    ldap.vm.box = "ubuntu/bionic64"
    ldap.vm.hostname = "ldap.vm"
    ldap.vm.network "private_network", ip: "192.168.50.8"
    ldap.vm.provision "shell", inline: <<-SHELL
      sudo apt-get update -y
      sudo apt-get upgrade -y
    SHELL
    ldap.vm.provider "virtualbox" do |vb|
      vb.memory = 2048
      vb.cpus = 1
    end
  end   # of |ldap|
end
