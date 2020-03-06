#!/bin/bash

YEAR=2020

echo "Rides from month (2-digit format): " ; read MONTH

# Calling cyclinganalytics.com API (webapp linked with Strava for extracting its data) and dump on a /tmp file
THE_CALLING=`curl -s https://www.cyclinganalytics.com/user/3152812/list | grep "var rides" | grep -Po '"distance":.*?[^\\\]",' | grep "$YEAR-$MONTH" | awk '{ print $1, $2, $20 }' | sed 's/.$//' > /tmp/bici_rides`

# To improve output, let's add some returns of carriage
PARSE=`/bin/cat /tmp/bici_rides | sed 's/,/\n/g'`

clear
echo -e "Strava Rides on 2020-$MONTH"
echo -e "- - - - - - - - - - - -"
/bin/cat /tmp/bici_rides

# Summatory for monthly total distance
SUMMUM=`awk '{s+=$2} END {print s}' /tmp/bici_rides`

echo ""
echo -e "Total distance on $YEAR-$MONTH: $SUMMUM"
