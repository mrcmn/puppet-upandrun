#!/bin/bash
set -ex
hostname primary.vm
echo '192.168.50.4 primary.vm primary' >> /etc/hosts
echo '192.168.50.41 replica.vm replica' >> /etc/hosts
echo '192.168.50.8 ldap.vm ldap' >> /etc/hosts
mkdir -p /etc/puppetlabs/puppet
echo '*' > /etc/puppetlabs/puppet/autosign.conf
# curl -Lo pe.archive 'https://pm.puppetlabs.com/puppet-enterprise/2019.8.8/puppet-enterprise-2019.8.8-el-7-x86_64.tar.gz'
curl -Lo pe.archive 'https://pm.puppetlabs.com/puppet-enterprise/2021.7.1/puppet-enterprise-2021.7.1-el-7-x86_64.tar.gz'
tar -xf pe.archive
cat > pe.conf <<-EOF
{
  "console_admin_password": "puppetlabs"
  "puppet_enterprise::puppet_master_host": "%{::trusted.certname}"
  "puppet_enterprise::use_application_services": true
  "puppet_enterprise::profile::master::check_for_updates": false
  "puppet_enterprise::send_analytics_data": false
}
EOF
./puppet-enterprise-*-el-7-x86_64/puppet-enterprise-installer -c pe.conf
/opt/puppetlabs/bin/puppet agent -t || true
/opt/puppetlabs/bin/puppet agent -t || true
systemctl stop firewalld
systemctl disable firewalld
