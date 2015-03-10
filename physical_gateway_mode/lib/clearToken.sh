#!/bin/bash
# Filename: clearToken.sh
# This is a script to clear token regularly.
#####################################
#	1. Clear token
#####################################

## Written by wangtao
## Version: 1.0

mysql_user=keystone
mysql_password=keystone
mysql_host=localhost
mysql=$(which mysql)

logger -t keystone-cleaner "Starting Keystone 'token' table cleanup"

logger -t keystone-cleaner "Starting token cleanup"
mysql -u${mysql_user} -p${mysql_password} -h${mysql_host} -e 'USE keystone ; DELETE FROM token WHERE NOT DATE_SUB(CURDATE(),INTERVAL 2 DAY) <= expires;'
valid_token=$($mysql -u${mysql_user} -p${mysql_password} -h${mysql_host} -e 'USE keystone ; SELECT * FROM token;' | wc -l)
logger -t keystone-cleaner "Finishing token cleanup, there is still $valid_token valid tokens..."

exit 0
