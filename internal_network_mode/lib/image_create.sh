#!/bin/bash
# Filename: image_create.sh
# This is a script to create image.
#####################################
#
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace


# Download the Cirros Image for test
wget 222.200.185.40:8000/img/cirros-0.3.0-x86_64-disk.img
mv cirros-0.3.0-x86_64-disk.img ./packages/

# Create image
glance --os-username admin --os-password $ADMIN_PASSWORD --os-tenant-name admin --os-auth-url http://$MANAGEIP:5000/v2.0/ image-create --name='cirros' --public --container-format=ovf --disk-format=qcow2 < ./packages/cirros-0.3.0-x86_64-disk.img
