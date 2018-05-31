#!/bin/bash
# Control script for MySQL "Seconds behind master" of BI Amazon's database
# Variables definition
HOST=bbdd5.ctcv0u4fmknr.eu-west-1.rds.amazonaws.com
PORT=3306
USER=master
PASSWD=<ask_for_it_to_any_sysadmin>
LOG=/var/log/sortida_bbdd_BI_amazon.log
SUBJECT='AMAZON_BI_BBDD_LAG_SLAVE_STATUS'
EMAIL='daniel.roijals@atrapalo.com,xavier.rodriguez@atrapalo.com,ivo.sandoval@atrapalo.com'

# Purge log
rm /var/log/sortida_bbdd_BI_amazon.log

# Adding date + command result at log
date > $LOG
/var/lib/shinken/libexec/check_mysql_slavestatus.sh -H $HOST -P $PORT -u $USER -p $PASSWD >> $LOG

OK=$(cat $LOG | grep -c "delay=0s")

if [ $OK != 1 ]; then
   # If we've got delay (or an error) send an email
   mailx -s $SUBJECT $EMAIL < $LOG
   echo "";
else
 # No delay, no party
   echo "";
fi
