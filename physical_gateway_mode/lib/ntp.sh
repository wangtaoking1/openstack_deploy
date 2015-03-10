#!/bin/bash
# Filename: ntp.sh
# This is a script to install ntp and configure it.
#####################################
#	1. Install ntp and configure it
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace


# Install ntp
apt-get install -y --force-yes ntp

# Configure ntp
sed -i "s/server ntp.ubuntu.com/server ntp.ubuntu.com\nserver 127.127.1.0\nfudge 127.127.1.0 stratum 10/g" /etc/ntp.conf

service ntp restart
