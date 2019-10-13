#!/bin/bash

# Monitoring check for elastic search

HOSTNAME=$1
WARNING=80
CRITICAL=85

CRIDA=`curl -s http://$HOSTNAME:9200/_cat/allocation?h=disk.percent,host | awk {'print$1'} | cut -d$'\n' -f1`

if [[ $CRIDA > $WARNING ]]; then
   if [[ $CRIDA > $CRITICAL ]]; then echo -e "$CRIDA - CRITICAL"
   else echo -e "$CRIDA - WARNING"
   fi
else
   echo -e "$CRIDA - OK"
fi
