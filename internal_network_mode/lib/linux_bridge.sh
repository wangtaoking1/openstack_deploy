#!/bin/bash
# Filename: linux_bridge.sh
# This is a script to install linux bridge.
#####################################
#	1. Install linux bridge
#####################################

## Written by wangtao
## Version: 1.0

set -o xtrace


# Install Bridge
apt-get -y --force-yes install bridge-utils

