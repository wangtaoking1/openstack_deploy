#!/bin/bash
# Filename: run.sh
# This is a script to guide vinzor flat cluster deployment.
#####################################
#   Node type config

#   Device and IP config

#   Run the installment 

#####################################

## Written by wangtao
## Version: 2.0

if [ $USER != "root" ]; then
    echo "You must be root to run this script."
    exit 0
fi

clear
echo "#####################################################################################"
echo "Welcome to Vinzor flat cluster deployment "
echo "#####################################################################################"
echo "This deployment includes three Processes"
echo "1 Choosing node type"
echo "2 Setting devices, IP addresses and admin password"
echo "3 Executing installment"
echo "Notice: In Process 1 and 2, if you decide to abort the installment, please press ctrl+c to stop the installment process"
echo "        Process 3 can not be rolled back, so make sure the setting is correct before you start the process 3"
echo "######################################################################################"
echo " "


echo -n "Choose Node Type (0. Control Node; 1. Single Node 2. Compute Node): "
read node_type
if [ $node_type == "0" ] ; then
    node_type="Control"
elif [ $node_type == "1" ] ; then
    node_type="Single"
elif [ $node_type == "2" ] ; then
    node_type="Compute"
else
    echo "Wrong number."
    exit 0
fi

# Read configuration file
if [ -e ./localrc ] ; then
    source ./localrc
fi

# Edit the hostname
if [ ! $HOSTNAME ]; then
    read -p "Enter the hostname of this node:  " HOSTNAME
else
    echo "The host name is:" $HOSTNAME
fi

hostname $HOSTNAME
cat> /etc/hostname <<EOF
$HOSTNAME
EOF
sed -i "s/127.0.1.1.*/127.0.1.1\t$HOSTNAME/g" /etc/hosts


# Get an interface
function get_interface() {
    nic_num=$(ifconfig -a | grep eth | wc -l)
    # Create the notes for nics
    for a in $(seq 0 $(($nic_num - 1)))
    do
        if [ $a -eq 0 ]; then
            notes="0.eth0"
        else
            notes=$notes"\t"$a".eth"$a
        fi
    done
    echo -e "Please choose one interface for $1 network from ($notes)"
    read -p "Enter the number: " number
    while true
    do
        flag=0
        for a in $(seq 0 $(($nic_num - 1)))
        do
            if [ $number == "$a" ]; then
                flag=1
            fi
        done
        if [ $flag -eq 1 ]; then
            break
        fi
        read -p "The number isn't valid, enter the number again: " number
    done
    return $number
}

echo
echo "-------------Configuration for public network----------------"
get_interface "public"
PUBLIC_INTERFACE="eth"$?
echo "The interface for public network is: "$PUBLIC_INTERFACE

if [ ! $PUBLICIP ] ; then
    read -p "Enter the ip address: " PUBLICIP
else
    echo "The ip address is:" $PUBLICIP
fi
if [ ! $PUBLICIP_MASK ] ; then
    read -p "Enter the netmask: " PUBLICIP_MASK
else
    echo "The netmask is:" $PUBLICIP_MASK
fi
if [ ! $PUBLICIP_GATEWAY ] ; then
    read -p "Enter the gateway: " PUBLICIP_GATEWAY
else
    echo "The gateway is:" $PUBLICIP_GATEWAY
fi
if [ ! $PUBLIC_NETWORK ] ; then
    read -p "Enter the network: " PUBLIC_NETWORK
else
    echo "The network is:" $PUBLIC_NETWORK
fi
if [ ! $DNS_SERVER ] ; then
    read -p "Enter the dns server: " DNS_SERVER
else
    echo "The dns server is:" $DNS_SERVER
fi
if [ $node_type == "Compute" ] ; then
    if [ ! $CONTROLLER_PUBLICIP ] ; then
        read -p "Enter the public ip of the control node: " CONTROLLER_PUBLICIP
    else
        echo "The public ip of control node is:" $CONTROLLER_PUBLICIP
    fi
fi
echo "-------------------------------------------------------------"
echo

echo
echo "-------------Configuration for manage network----------------"
get_interface "manage"
MANAGE_INTERFACE="eth"$?
echo "The interface for manage network is: " $MANAGE_INTERFACE

if [ $MANAGE_INTERFACE == $PUBLIC_INTERFACE ]; then
    MANAGEIP=$PUBLICIP
    MANAGEIP_MASK=$PUBLICIP_MASK
    if [ $node_type == "Compute" ] ; then
        CONTROLLER_MANAGEIP=$CONTROLLER_PUBLICIP
    fi
else
    if [ ! $MANAGEIP ] ; then
        read -p "Enter the ip address: " MANAGEIP
    else
        echo "The ip address is:" $MANAGEIP
    fi
    if [ ! $MANAGEIP_MASK ] ; then
        read -p "Enter the netmask: " MANAGEIP_MASK
    else
        echo "The netmask is:" $MANAGEIP_MASK
    fi
    if [ $node_type == "Compute" ] ; then
        if [ ! $CONTROLLER_MANAGEIP ] ; then
            read -p "Enter the manage ip of the control node: " CONTROLLER_MANAGEIP
        else
            echo "The manage ip of control node is:" $CONTROLLER_MANAGEIP
        fi
    fi
fi

echo "-------------------------------------------------------------"
echo

echo
echo "-------------Configuration for data network------------------"
if [ $node_type == "Single" ]; then
    FLAT_INTERFACE=$PUBLIC_INTERFACE
    echo "The interface for data network must be: "$FLAT_INTERFACE
else
    get_interface "data"
    FLAT_INTERFACE="eth"$?
    echo "The interface for data network is: "$FLAT_INTERFACE
    if [ $PUBLIC_INTERFACE != $MANAGE_INTERFACE ] && [ $MANAGE_INTERFACE == $FLAT_INTERFACE ]; then
        echo "Flat interface can't be the same with the manage interface."
        exit 0
    fi
fi

if [ ! $FIXED_RANGE ] ; then
    read -p "Enter the fixed_range: " FIXED_RANGE
else
    echo "The fixed_range is:" $FIXED_RANGE
fi
if [ ! $VM_GATEWAY ] ; then
    read -p "Enter the gateway of instances: " VM_GATEWAY
else
    echo "The gateway of instances is:" $VM_GATEWAY
fi
if [ ! $VM_NETWORK_SIZE ] ; then
    read -p "Enter the network size: " VM_NETWORK_SIZE
else
    echo "The network size is:" $VM_NETWORK_SIZE
fi

# For creating network
if [ $node_type == "Control" ] || [ $node_type == "Single" ]; then
    if [ ! $VM_NETWORK ] ; then
        read -p "Enter the network of instances: " VM_NETWORK
    else
        echo "The network of instances is:" $VM_NETWORK
    fi
    if [ ! $VM_NETMASK ] ; then
        read -p "Enter the netmask of instances: " VM_NETMASK
    else
        echo "The netmask of instances is:" $VM_NETMASK
    fi
    if [ ! $VM_BROADCAST ] ; then
        read -p "Enter the broadcast of instances: " VM_BROADCAST
    else
        echo "The broadcast of instances is:" $VM_BROADCAST
    fi
fi
echo "-------------------------------------------------------------"
echo

echo
echo "-------------Configuration services password----------------"
if [ ! $ADMIN_PASSWORD ] ; then
    read -p "Enter the password for admin user: " ADMIN_PASSWORD
else
    echo "The password for admin user is:" $ADMIN_PASSWORD
fi

MYSQL_PASSWORD=${MYSQL_PASSWORD:-"sysumysql"}
RABBIT_PASSWORD=${RABBIT_PASSWORD:-"guest"}
SERVICE_PASSWORD=${SERVICE_PASSWORD:-"sysuservice"}
ADMIN_TOKEN=${ADMIN_TOKEN:-"SYSUADMIN"}
SERVICE_TOKEN=${SERVICE_TOKEN:-"SYSUADMIN"}

SERVICE_TENANT_NAME=${SERVICE_TENANT_NAME:-"service"}
KEYSTONE_USER=${KEYSTONE_USER:-"keystone"}
KEYSTONE_PASS=${KEYSTONE_PASS:-"keystone"}

GLANCE_USER=${GLANCE_USER:-"glance"}
GLANCE_PASS=${GLANCE_PASS:-"glance"}

NOVA_USER=${NOVA_USER:-"nova"}
NOVA_PASS=${NOVA_PASS:-"nova"}
echo "-------------------------------------------------------------"
echo 

read -p "Do you Confirm the above settings [[y/n]] : " confirm

if [ $confirm != "y" ] && [ $confirm != "Y" ] ; then
    exit 0
fi

# Export all arguments
# For all nodes
for arg in node_type PUBLIC_INTERFACE PUBLICIP PUBLICIP_MASK PUBLICIP_GATEWAY PUBLIC_NETWORK DNS_SERVER MANAGE_INTERFACE MANAGEIP MANAGEIP_MASK FLAT_INTERFACE FIXED_RANGE VM_GATEWAY VM_NETWORK_SIZE RABBIT_PASSWORD ADMIN_PASSWORD SERVICE_PASSWORD ADMIN_TOKEN SERVICE_TOKEN SERVICE_TENANT_NAME KEYSTONE_USER KEYSTONE_PASS GLANCE_USER GLANCE_PASS NOVA_USER NOVA_PASS
do
    export $arg
done
# For Control node
if [ $node_type == "Control" ] || [ $node_type == "Single" ]; then
    for arg in VM_NETWORK VM_NETMASK VM_BROADCAST MYSQL_PASSWORD
    do
        export $arg
    done
fi
# For Compute node
if [ $node_type == "Compute" ] ; then
    for arg in CONTROLLER_PUBLICIP CONTROLLER_MANAGEIP
    do
        export $arg
    done
fi

mkdir /var/log/openstack

if [ $node_type == "Control" ] ; then
    set -o xtrace
    echo "--------------------------Installing Control Node----------------------"
    bash ./lib/network_conf.sh > /var/log/openstack/network_conf.log 2>&1
    bash ./lib/sources_update.sh > /var/log/openstack/sources_update.log 2>&1
    bash ./lib/mysql.sh > /var/log/openstack/mysql.log 2>&1
    bash ./lib/rabbitmq.sh > /var/log/openstack/rabbitmq.log 2>&1
    bash ./lib/ntp.sh > /var/log/openstack/ntp.log 2>&1
    bash ./lib/keystone.sh > /var/log/openstack/keystone.log 2>&1
    bash ./lib/novarc.sh > /var/log/openstack/novarc.log 2>&1
    bash ./lib/glance.sh > /var/log/openstack/glance.log 2>&1
    bash ./lib/nova_control.sh > /var/log/openstack/nova.log 2>&1
    bash ./lib/horizon.sh > /var/log/openstack/horizon.log 2>&1
    
    bash ./lib/nova_restart.sh > /var/log/openstack/nova_restart.log 2>&1
    
    bash ./lib/image_create.sh > /var/log/openstack/image_create.log 2>&1
    bash ./lib/network_create.sh > /var/log/openstack/network_create.log 2>&1
    bash ./lib/security-group.sh > /var/log/openstack/security-group.log 2>&1
    set +o xtrace
fi

if [ $node_type == "Single" ] ; then
    set -o xtrace
    echo "--------------------------Installing Single Node----------------------"
    bash ./lib/network_conf.sh > /var/log/openstack/network_conf.log 2>&1
    bash ./lib/sources_update.sh > /var/log/openstack/sources_update.log 2>&1
    bash ./lib/mysql.sh > /var/log/openstack/mysql.log 2>&1
    bash ./lib/rabbitmq.sh > /var/log/openstack/rabbitmq.log 2>&1
    bash ./lib/ntp.sh > /var/log/openstack/ntp.log 2>&1
    bash ./lib/keystone.sh > /var/log/openstack/keystone.log 2>&1
    bash ./lib/novarc.sh > /var/log/openstack/novarc.log 2>&1
    bash ./lib/glance.sh > /var/log/openstack/glance.log 2>&1
    bash ./lib/nova_single.sh > /var/log/openstack/nova.log 2>&1
    bash ./lib/horizon.sh > /var/log/openstack/horizon.log 2>&1
    
    bash ./lib/nova_restart.sh > /var/log/openstack/nova_restart.log 2>&1
    
    bash ./lib/image_create.sh > /var/log/openstack/image_create.log 2>&1
    bash ./lib/network_create.sh > /var/log/openstack/network_create.log 2>&1
    bash ./lib/security-group.sh > /var/log/openstack/security-group.log 2>&1
    set +o xtrace
fi

if [ $node_type == "Compute" ] ; then
    set -o xtrace
    echo "--------------------------Installing Compute Node----------------------"
    bash ./lib/network_conf.sh > /var/log/openstack/network_conf.log 2>&1
    bash ./lib/sources_update.sh  > /var/log/openstack/sources_update.log 2>&1
    #bash ./lib/linux_bridge.sh > /var/log/openstack/linux_bridge.log 2>&1
    bash ./lib/ntp.sh > /var/log/openstack/ntp.log 2>&1
    bash ./lib/novarc.sh > /var/log/openstack/novarc.log 2>&1
    bash ./lib/nova_compute.sh > /var/log/openstack/nova.log 2>&1
    
    bash ./lib/nova_restart.sh > /var/log/openstack/nova_restart.log 2>&1
    set +o xtrace
fi

echo "--------------------------Instalment finished!!!----------------------"
echo

echo
read -p "The vinzor system can only be used after reboot, reboot? [[y/n]]: " confirm2
if [ $confirm2 == "y" ] || [ $confirm2 == "Y" ]; then
    reboot
else
    echo "You should reboot by yourself."
fi

