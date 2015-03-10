#!/bin/bash
# Filename: nova.sh
# This is a script to install nova and configure it.
#####################################
#	1. Install nova and configure it
#	2. Create nova database
#	3. Create nova.conf
#	4. Create database tables
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace


# Install nova
apt-get install -y nova-api nova-cert nova-common nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient nova-ajax-console-proxy novnc


# Create nova database on control node
mysql -uroot -p$MYSQL_PASSWORD <<EOF
create database nova default character set utf8;;
grant all on nova.* to '$NOVA_USER'@'%' identified by '$NOVA_PASS';
flush privileges;
EOF


#Configure nova.conf
cat > /etc/nova/nova.conf  <<EOF
[DEFAULT]
# LOGS/STATE
verbose=True
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/run/lock/nova


glance_host=$MANAGEIP
api_paste_config=/etc/nova/api-paste.ini
rpc_backend = rabbit
rabbit_host=$MANAGEIP
rabbit_userid=guest
rabbit_password=$RABBIT_PASSWORD

# SCHEDULER
compute_scheduler_driver=nova.scheduler.simple.SimpleScheduler

# QUOTA
quota_instances=-1
quota_cores=-1
quota_ram=-1

# VOLUMES
volume_api_class = nova.volume.cinder.API

# Auth
use_deprecated_auth=false
auth_strategy=keystone
root_helper=sudo nova-rootwrap /etc/nova/rootwrap.conf

# Imaging service
glance_api_servers=$MANAGEIP:9292
image_service=nova.image.glance.GlanceImageService

# APIS
osapi_compute_extension=nova.api.openstack.compute.contrib.standard_extensions
allow_admin_api=true
s3_host=$MANAGEIP
cc_host=$MANAGEIP


# VNC configuration
novnc_enabled=true
novncproxy_base_url=http://$PUBLICIP:6080/vnc_auto.html
novncproxy_port=6080


# Network
network_api_class = nova.network.api.API
security_group_api = nova
network_manager=nova.network.manager.FlatDHCPManager
force_dhcp_release=True
dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
firewall_driver=nova.virt.libvirt.firewall.IptablesFirewallDriver
public_interface=$PUBLIC_INTERFACE
flat_interface=$FLAT_INTERFACE
flat_network_bridge=br100
fixed_range=$FIXED_RANGE
network_size=$VM_NETWORK_SIZE
connection_type=libvirt
multi_host=True

#dnsmasq_config_file=/etc/nova/dnsmasq.conf

# Compute
compute_driver=libvirt.LibvirtDriver
#libvirt_cpu_mode=host-passthrough

[database]
connection = mysql://$NOVA_USER:$NOVA_PASS@$MANAGEIP/nova


[keystone_authtoken]
auth_uri = http://$MANAGEIP:5000
auth_host = $PUBLICIP
auth_port = 35357
auth_protocol = http
admin_tenant_name = $SERVICE_TENANT_NAME
admin_user = nova
admin_password = $SERVICE_PASSWORD

EOF


chown -R nova:nova /etc/nova
chown -R nova:nova /var/lib/nova
chown -R nova:nova /var/log/nova

nova-manage db sync

# 定时清除节点缓存
cat >> /etc/crontab <<EOF
*/10 * * * * root sync && echo 3 > /proc/sys/vm/drop_caches
EOF

