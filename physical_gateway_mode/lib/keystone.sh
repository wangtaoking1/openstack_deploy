#!/bin/bash
# Filename: keystone.sh
# This is a script to install keystone and configure it.
#####################################
#	1. Install keystone and configure it
#   2. Add the script that clear token regularly
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace


# Install the keystone service
apt-get install -y --force-yes keystone

# Create the database
mysql -uroot -p$MYSQL_PASSWORD <<EOF
create database keystone default character set utf8;
grant all on keystone.* to '$KEYSTONE_USER'@'%' identified by '$KEYSTONE_PASS';
flush privileges;
EOF

# keystone configuration
sed -i -e " s/#admin_token=ADMIN/admin_token=$ADMIN_TOKEN/g;s/#verbose=false/verbose=true/g;s/#debug=false/debug=true/g;s/#token_format=<None>/token_format = UUID/g" /etc/keystone/keystone.conf
sed -i '/connection = .*/{s|sqlite:///.*|mysql://'"$KEYSTONE_USER"':'"$KEYSTONE_PASS"'@'"$MANAGEIP"'/keystone|g}' /etc/keystone/keystone.conf

# restart the keystone and sync db
/etc/init.d/keystone restart
keystone-manage db_sync


# keystone basic configuration
sed -i -e "s/HOST_IP=10.10.10.51/HOST_IP=$MANAGEIP/g"  ./lib/keystone_basic.sh
sed -i -e "s/EXT_HOST_IP=192.168.100.51/EXT_HOST_IP=$PUBLICIP/g" ./lib/keystone_basic.sh
sed -i  -e "s/export SERVICE_TOKEN=\"ADMIN\"/export SERVICE_TOKEN=\"${ADMIN_TOKEN}\"/g" ./lib/keystone_basic.sh
sed -i -e "s/SERVICE_TENANT_NAME=\${SERVICE_TENANT_NAME:-service}/SERVICE_TENANT_NAME=\${SERVICE_TENANT_NAME:-$SERVICE_TENANT_NAME}/" ./lib/keystone_basic.sh
sed -i -e "s/SERVICE_PASSWORD=\${SERVICE_PASSWORD:-service_pass}/SERVICE_PASSWORD=\${SERVICE_PASSWORD:-$SERVICE_PASSWORD}/" ./lib/keystone_basic.sh
sed -i -e "s/ADMIN_PASSWORD=\${ADMIN_PASSWORD:-admin_pass}/ADMIN_PASSWORD=\${ADMIN_PASSWORD:-$ADMIN_PASSWORD}/" ./lib/keystone_basic.sh

sed -i -e "s/HOST_IP=10.10.10.51/HOST_IP=$MANAGEIP/g"  ./lib/keystone_endpoints_basic.sh
sed -i -e "s/EXT_HOST_IP=192.168.100.51/EXT_HOST_IP=$PUBLICIP/g" ./lib/keystone_endpoints_basic.sh
sed -i  -e "s/export SERVICE_TOKEN=\"ADMIN\"/export SERVICE_TOKEN=\"${ADMIN_TOKEN}\"/g" ./lib/keystone_endpoints_basic.sh

chmod +x ./lib/keystone_basic.sh
chmod +x ./lib/keystone_endpoints_basic.sh

./lib/keystone_basic.sh
./lib/keystone_endpoints_basic.sh


# Add the script that clear the token regularly
sed -i -e "s/mysql_user=keystone/mysql_user=${KEYSTONE_USER}/" ./lib/clearToken.sh
sed -i -e "s/mysql_password=keystone/mysql_password=${KEYSTONE_PASS}/" ./lib/clearToken.sh

cp ./lib/clearToken.sh /var/lib/keystone/clearToken.sh
chmod +x /var/lib/keystone/clearToken.sh

cat >> /etc/crontab << EOF
0 1 * * * root /var/lib/keystone/clearToken.sh
EOF


