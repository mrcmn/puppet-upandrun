#!/bin/bash
set -ex
ufw disable
hostnamectl set-hostname replica.vm
echo '192.168.50.4 primary.vm primary' >> /etc/hosts
echo '192.168.50.41 replica.vm replica' >> /etc/hosts
echo '192.168.50.8 ldap.vm ldap' >> /etc/hosts
curl -k https://primary.vm:8140/packages/current/install.bash | bash
