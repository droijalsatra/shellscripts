#!/bin/bash

for certif in /etc/ssl/certs/*.pem; do
   printf '%s: %s\n' \
      "$(date --date="$(openssl x509 -enddate -noout -in "$certif"|cut -d= -f 2)" --iso-8601)" \
      "$certif"
done | sort
