#!/bin/bash
# Filename: keystone.sh
# This is a script to create admin environment.
#####################################
#
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace


# Set the environment 
cat > /root/novarc <<EOF
export OS_TENANT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASSWORD
export OS_AUTH_URL=http://$MANAGEIP:5000/v2.0/
export OS_REGION_NAME=RegionOne
export SERVICE_TOKEN=$ADMIN_TOKEN
export SERVICE_ENDPOINT=http://$MANAGEIP:35357/v2.0/
EOF

echo "source /root/novarc" >> /root/.bashrc
source /root/novarc
