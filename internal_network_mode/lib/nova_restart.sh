#!/bin/bash
# Filename: nova_restart.sh
# This is a script to restart all nova service.
#####################################
#	1. Restart nova services
#####################################

## Written by wangtao
## Version: 1.0

# restart nova services
for service in /etc/init.d/nova-*
do
	$service restart
done
