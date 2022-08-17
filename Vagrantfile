Vagrant.configure("2") do |config|

  config.vm.define "primary.vm" do |primary|
    primary.vm.box = "centos/7"
    primary.vm.hostname = "primary.vm"
    primary.vm.provision "shell", path: "scripts/primarybootstrap.sh"
    primary.vm.network "private_network", ip: "192.168.50.4"
    primary.vm.provider "virtualbox" do |v|
      v.memory = 4096
      v.cpus = 2
    end
  end 
  
  config.vm.define "replica.vm" do |replica|
    replica.vm.box = "centos/7"
    replica.vm.hostname = "replica.vm"
    replica.vm.provision "shell", path: "scripts/replicabootstrap.sh"
    replica.vm.network "private_network", ip: "192.168.50.41"
    replica.vm.provider "virtualbox" do |v|
      v.memory = 4096
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

  config.vm.define "linux.vm" do |linux|
    linux.vm.box = "centos/7"
    linux.vm.hostname = "linux.vm"
    linux.vm.network "private_network", ip: "192.168.50.6"
    linux.vm.provision "shell", path: "scripts/linux_agent.sh"
    linux.vm.provider "virtualbox" do |v|
      v.memory = 2048
    end
  end
  
  config.vm.define "gitlab.vm" do |gitlab|
    gitlab.vm.box = "ubuntu/bionic64"
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
      vb.memory = 4096
      vb.cpus = 2
    end
  end   # of |gitlab|
end
