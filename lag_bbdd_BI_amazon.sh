#####
#
# Data: 20180530
# Author: Daniel Roijals
# E-mail: daniel.roijals@atrapalo.com
#
# Control script for MySQL "Seconds behind master" of BI Amazon's database
#
# Aquest script es troba al cron del nagios, i executa cada 2 hores una consulta per veure si tenim lag i/o
# errors a una bbdd que els companys de BI tenen a Amazon. Si tenim lag i/o errors ens envïa un mail als 
# sysadmins per tal que actúem.
#
#####

#!/bin/bash

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
