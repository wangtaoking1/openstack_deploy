#!/bin/bash
# Filename: sources_update.sh
# This is a script to update software sources to Icehouse.
#####################################
#	1. Add local software source
#	2. Add Icehouse source
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace

# Add the local software source
cat > /etc/apt/sources.list <<EOF
deb http://222.200.185.40:8000/ubuntu/ precise main multiverse restricted universe 
deb http://222.200.185.40:8000/ubuntu/ precise-backports main multiverse restricted universe 
deb http://222.200.185.40:8000/ubuntu/ precise-proposed main multiverse restricted universe 
deb http://222.200.185.40:8000/ubuntu/ precise-security main multiverse restricted universe 
deb http://222.200.185.40:8000/ubuntu/ precise-updates main multiverse restricted universe 
deb-src http://222.200.185.40:8000/ubuntu/ precise main multiverse restricted universe 
deb-src http://222.200.185.40:8000/ubuntu/ precise-backports main multiverse restricted universe 
deb-src http://222.200.185.40:8000/ubuntu/ precise-proposed main multiverse restricted universe 
deb-src http://222.200.185.40:8000/ubuntu/ precise-security main multiverse restricted universe 
deb-src http://222.200.185.40:8000/ubuntu/ precise-updates main multiverse restricted universe
EOF

# Add the Icehouse source
cat > /etc/apt/sources.list.d/icehouse.list << EOF
deb http://222.200.185.40:8000/icehouse/ubuntu precise-updates/icehouse main
deb http://222.200.185.40:8000/icehouse/ubuntu precise-proposed/icehouse main
EOF

apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 5EDB1B62EC4926EA
apt-get install -y ubuntu-cloud-keyring
apt-get update -y

