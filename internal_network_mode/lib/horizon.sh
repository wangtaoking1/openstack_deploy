#!/bin/bash
# Filename: horizon.sh
# This is a script to install horizon.
#####################################
#	1. Install openstack-dashboard and memcached
#####################################

## Written by wangtao
## Version: 1.0

# Install Horizon
apt-get install -y openstack-dashboard memcached libapache2-mod-wsgi
mv /etc/openstack-dashboard/ubuntu_theme.py /etc/openstack-dashboard/ubuntu_theme.py.bak

/etc/init.d/memcached restart
/etc/init.d/apache2 restart

