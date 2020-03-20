#!/bin/bash

### Put this knowledge on a Nagios custom check: 
### https://community.letsencrypt.org/t/it-there-a-command-to-show-how-many-days-certificate-you-have/11351/3

### This command downloads a *.pem file from our DWtC (desired-web-to-check :-P )
### openssl s_client -servername desired-web-to-check -connect desired-web-to-check:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > ./expected_file.pem

### This one extracts expiration date from codified expected_file.pem
### openssl x509 -enddate -noout -in expected_file.pem

### LET'S BEGIN

### Present day (in seconds)
TODAY=$(date +%s)

### Extracts Expiration Date
COMMAND2=`openssl x509 -enddate -noout -in ./expected_file.pem | awk '{ print $2 " " $1 " " $4 }' | sed 's/notAfter=//g'`
### Format Expiration Date (in seconds)
EXPIRATION_DATE=$(date -d "$COMMAND2" +%s)

###  ExpirationDate - PresentDay = Number of days to Expiration
DATES_DIFFERENCE_SECONDS=$(($EXPIRATION_DATE - $TODAY))

### Number of days until Expiration (format in days)
COMMAND=`echo "$DATES_DIFFERENCE_SECONDS / 86400" | bc`

### Nagios Thresholds (>60 days OK / <60 days Warning / <30 days CRITICAL)
if [ $COMMAND -gt 59 ] ; then
   echo -e "OK Certificate will expire / renew on $COMMAND days."
   exit 0
fi

if [ $COMMAND -lt 30 ] ; then
   echo -e "CRITICAL. Certificate will expire or renew on $COMMAND days."
   exit 2
else
   if [ $COMMAND -lt 60 ] ; then
      echo -e "WARNING. Certificate will expire on $COMMAND days."
      exit 1
   fi
fi


