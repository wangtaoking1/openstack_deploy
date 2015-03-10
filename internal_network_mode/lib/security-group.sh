#!/bin/bash
# Filename: security-group.sh
# This is a script to edit security group.
#####################################
#	1. Edit security group
#####################################

## Written by wangtao
## Version: 1.0

source /root/novarc

# Add security-group
nova --os-tenant-name=admin secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova --os-tenant-name=admin secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova --os-tenant-name=admin secgroup-add-rule default tcp 8080 8080 0.0.0.0/0
nova --os-tenant-name=admin secgroup-add-rule default tcp 3389 3389 0.0.0.0/0
nova --os-tenant-name=admin secgroup-add-rule default udp 43278 43279 0.0.0.0/0

nova --os-tenant-name=demo secgroup-add-rule default tcp 22 22 0.0.0.0/0
nova --os-tenant-name=demo secgroup-add-rule default icmp -1 -1 0.0.0.0/0
nova --os-tenant-name=demo secgroup-add-rule default tcp 8080 8080 0.0.0.0/0
nova --os-tenant-name=demo secgroup-add-rule default tcp 3389 3389 0.0.0.0/0
nova --os-tenant-name=demo secgroup-add-rule default udp 43278 43279 0.0.0.0/0
