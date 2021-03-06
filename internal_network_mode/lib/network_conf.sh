#!/bin/bash
# Filename: network_conf.sh
# This is a script to configure network.
#####################################
#	1. Configure network
#	2. Enable ip-forward
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace

# Configure NICs
cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto $PUBLIC_INTERFACE
iface $PUBLIC_INTERFACE inet static
	address $PUBLICIP
	netmask $PUBLICIP_MASK
	gateway $PUBLICIP_GATEWAY
	dns-nameservers $DNS_SERVER

EOF

if [ $PUBLIC_INTERFACE != $MANAGE_INTERFACE ]; then
cat >> /etc/network/interfaces <<EOF
auto $MANAGE_INTERFACE
iface $MANAGE_INTERFACE inet static
    address $MANAGEIP
    netmask $MANAGEIP_MASK

EOF
fi

/etc/init.d/networking stop
/etc/init.d/networking start
echo "nameserver $DNS_SERVER" > /etc/resolv.conf

# Enable the ip-forward
sed -i "s/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g" /etc/sysctl.conf
sysctl -p
