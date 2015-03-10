#!/bin/bash
# Filename: nova_compute.sh
# This is a script to install nova and configure it.
#####################################
#	1. Install nova-compute, nova-network, nova-compute-kvm, etc.
#	2. Configure nova-compute.conf
#	3. Configure dnsmasq.conf
#
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace


# Install nova
apt-get install -y nova-api nova-compute nova-compute-kvm nova-network python-nova python-keystone python-glance python-mysqldb python-novaclient


# Configure dnsmasq.conf
cat > /etc/nova/dnsmasq.conf << EOF
dhcp-option=option:router,$VM_GATEWAY
dhcp-option=6,$DNS_SERVER
EOF

#Configure nova.conf
cat > /etc/nova/nova.conf  <<EOF
[DEFAULT]
# LOGS/STATE
verbose=True
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/run/lock/nova


glance_host=$CONTROLLER_MANAGEIP
api_paste_config=/etc/nova/api-paste.ini
rpc_backend = rabbit
rabbit_host=$CONTROLLER_MANAGEIP
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
glance_api_servers=$CONTROLLER_MANAGEIP:9292
image_service=nova.image.glance.GlanceImageService

# APIS
osapi_compute_extension=nova.api.openstack.compute.contrib.standard_extensions
allow_admin_api=true
s3_host=$CONTROLLER_MANAGEIP
cc_host=$CONTROLLER_MANAGEIP

# VNC configuration
novnc_enabled=true
novncproxy_base_url=http://$CONTROLLER_PUBLICIP:6080/vnc_auto.html
vncserver_proxyclient_address=$PUBLICIP
vncserver_listen=0.0.0.0

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

dnsmasq_config_file=/etc/nova/dnsmasq.conf

# Compute
compute_driver=libvirt.LibvirtDriver
#libvirt_cpu_mode=host-passthrough

[database]
connection = mysql://$NOVA_USER:$NOVA_PASS@$CONTROLLER_MANAGEIP/nova

[keystone_authtoken]
auth_uri = http://$CONTROLLER_MANAGEIP:5000
auth_host = $CONTROLLER_MANAGEIP
auth_port = 35357
auth_protocol = http
admin_tenant_name = $SERVICE_TENANT_NAME
admin_user = nova
admin_password = $SERVICE_PASSWORD

EOF


chown -R nova:nova /etc/nova
chown -R nova:nova /var/lib/nova
chown -R nova:nova /var/log/nova


# 定时清除节点缓存
cat >> /etc/crontab <<EOF
*/10 * * * * root sync && echo 3 > /proc/sys/vm/drop_caches
EOF

