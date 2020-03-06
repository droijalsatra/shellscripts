#!/bin/bash

YEAR=2020

echo "Rides from month (2-digit format): " ; read MONTH

# Calling cyclinganalytics.com API (webapp linked with Strava for extracting its data) and dump on a /tmp file
# Obviously I've hidden my athlete_ID (I am the worst athlete in the world)
THE_CALLING=`curl -s https://www.cyclinganalytics.com/user/<ATHLETE_ID>/list | grep "var rides" | grep -Po '"distance":.*?[^\\\]",' | grep "$YEAR-$MONTH" | awk '{ print $1, $2, $20 }' | sed 's/.$//' > /tmp/bike_rides`

# To improve output, let's add some returns of carriage
PARSE=`/bin/cat /tmp/bike_rides | sed 's/,/\n/g'`

clear
echo -e "Strava Rides on 2020-$MONTH"
echo -e "- - - - - - - - - - - -"
/bin/cat /tmp/bike_rides

# Summatory for monthly total distance
SUMMUM=`awk '{s+=$2} END {print s}' /tmp/bike_rides`

echo ""
echo -e "Total distance on $YEAR-$MONTH: $SUMMUM"
