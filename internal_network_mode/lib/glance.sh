#!/bin/bash
# Filename: glance.sh
# This is a script to install glance and configure it.
#####################################
#	1. Install glance and configure it
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace


# Install glance
apt-get install -y --force-yes glance python-glanceclient

mysql -uroot -p$MYSQL_PASSWORD <<EOF
create database glance default character set utf8;
grant all on glance.* to '$GLANCE_USER'@'%' identified by '$GLANCE_PASS';
flush privileges;
EOF

sed -i -e "s/sqlite_db = \/var\/lib\/glance\/glance.sqlite/connection = mysql:\/\/$GLANCE_USER:$GLANCE_PASS@$MANAGEIP\/glance/g" /etc/glance/glance-api.conf

sed -i -e "s/sqlite_db = \/var\/lib\/glance\/glance.sqlite/connection = mysql:\/\/$GLANCE_USER:$GLANCE_PASS@$MANAGEIP\/glance/g" /etc/glance/glance-registry.conf

sed -i -e 's/#verbose = False/verbose = True/g;s/#debug = False/debug = True/g;s/workers = 1/workers = 4/g;s/# notifier_strategy = default/notifier_strategy = rabbit/g' /etc/glance/glance-api.conf
sed -i -e "s/registry_host = 0.0.0.0/registry_host = $MANAGEIP/g;s/rabbit_host = localhost/rabbit_host = $MANAGEIP/g;s/rabbit_password = guest/rabbit_password = $RABBIT_PASSWORD/g" /etc/glance/glance-api.conf
sed -i -e "s/auth_host = 127.0.0.1/auth_host = $MANAGEIP/g;s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT_NAME/g;s/%SERVICE_USER%/glance/g;s/%SERVICE_PASSWORD%/$SERVICE_PASSWORD/g;" /etc/glance/glance-api.conf
sed -i -e "s/auth_host = 127.0.0.1/auth_host = $MANAGEIP/g;s/%SERVICE_TENANT_NAME%/$SERVICE_TENANT_NAME/g;s/%SERVICE_USER%/glance/g;s/%SERVICE_PASSWORD%/$SERVICE_PASSWORD/g;" /etc/glance/glance-registry.conf
sed -i "s/#flavor=/flavor=keystone/g" /etc/glance/glance-api.conf
sed -i "s/#flavor=/flavor=keystone/g" /etc/glance/glance-registry.conf


# Restart the glance-api and glance-registry, then sync db
/etc/init.d/glance-api restart
/etc/init.d/glance-registry restart
glance-manage db_version_control
glance-manage db_sync

