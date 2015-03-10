#!/bin/bash
# Filename: network_create.sh
# This is a script to create data network
#####################################
#	1. Create networks
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace


# Create networks
nova-manage network create test-net --fixed_range_v4=$FIXED_RANGE --num_networks=1 --bridge=br100 --bridge_interface=$FLAT_INTERFACE --dns1=$DNS_SERVER --network_size=$VM_NETWORK_SIZE --multi_host=T


# Edit the networks and fixed_ips table
mysql -uroot -p$MYSQL_PASSWORD <<EOF
use nova;
update networks set cidr="$VM_NETWORK", netmask="$VM_NETMASK", broadcast="$VM_BROADCAST", gateway="$VM_GATEWAY";
flush privileges;
EOF

