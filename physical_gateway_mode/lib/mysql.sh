#!/bin/bash
# Filename: mysql.sh
# This is a script to install mysql and configure it.
#####################################
#	1. Install mysql and configure it
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace


# Install database: mysql
cat <<EOF | debconf-set-selections
mysql-server-5.1 mysql-server/root_password password $MYSQL_PASSWORD
mysql-server-5.1 mysql-server/root_password_again password $MYSQL_PASSWORD
mysql-server-5.1 mysql-server/start_on_boot boolean true
EOF

apt-get install -y --force-yes mysql-server python-mysqldb

# Edit mysql conf, allow access from anywhere
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/my.cnf
sed -i '44 i skip-name-resolve' /etc/mysql/my.cnf
sed -i "s/\[mysqldb\]/\[mysqldb\]\ndefault-storage-engine = innodb\ncollation-server = utf8_general_ci\ninit-connect = 'SET NAMES utf8'\ncharacter-set-server = utf8 \n/g" /etc/mysql/my.cnf
/etc/init.d/mysql restart

