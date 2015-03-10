#!/bin/bash
# Filename: ntp.sh
# This is a script to install rqbbitmq and configure it.
#####################################
#	1. Install rabbitmq and configure it
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace


# Install rabbitmq
apt-get install -y --force-yes rabbitmq-server

rabbitmqctl change_password guest $RABBIT_PASSWORD
