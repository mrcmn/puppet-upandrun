#!/bin/bash
set -ex
ufw disable
hostnamectl set-hostname primary.vm
sed -ri "s/127.0.2.1 .*/192.168.50.4 primary.vm primary/g" /etc/hosts
echo '192.168.50.41 replica.vm replica' >> /etc/hosts
echo '192.168.50.7 gitlab.vm gitlab' >> /etc/hosts
echo '192.168.50.8 ldap.vm ldap' >> /etc/hosts
mkdir -p /etc/puppetlabs/puppet
echo '*' > /etc/puppetlabs/puppet/autosign.conf
# curl -Lo pe.archive 'https://pm.puppetlabs.com/puppet-enterprise/2023.8.1/puppet-enterprise-2023.8.1-ubuntu-22.04-amd64.tar.gz'
curl -Lo pe.archive 'https://pm.puppetlabs.com/puppet-enterprise/2025.8.0/puppet-enterprise-2025.8.0-ubuntu-22.04-amd64.tar.gz'
tar -xf pe.archive
cat > pe.conf <<-EOF
{
  "console_admin_password": "Puppetlabs+1"
  "puppet_enterprise::puppet_master_host": "%{::trusted.certname}"
  "puppet_enterprise::use_application_services": true
  "puppet_enterprise::profile::master::check_for_updates": false
  "puppet_enterprise::send_analytics_data": false
}
EOF
./puppet-enterprise-*-ubuntu-22.04-amd64/puppet-enterprise-installer -c pe.conf
/opt/puppetlabs/bin/puppet agent -t || true
/opt/puppetlabs/bin/puppet agent -t || true
