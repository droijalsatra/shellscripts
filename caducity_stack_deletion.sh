#!/bin/bash

STACK_ID=`docker stack ls | grep -v master | grep -v traefik | grep -v portainer | awk '{print$1}' | grep -v "NAME"`
CONTAINER_MAX_DAYS="7 days" # Older than 7 days will be removed

for i in $STACK_ID; do
                CURRENT_STATE=`docker stack ps $i | awk '{print$1 " " $6 " " $7 " " $8 " " $9}' | grep -v "ID" | grep "$CONTAINER_MAX_DAYS"`
                if [ -z "$CURRENT_STATE" ]; then :
                else
                        echo "Stack ID: $i"
                        printf "$CURRENT_STATE\n"

                        # Copy affected stacks to external file for attaching on an info mail
                        echo "$i" >> /tmp/scripts/file.txt

                        # Delete affected stack
                        /usr/bin/docker stack rm $i

                fi
done

# email ONLY if there's something to email to people ;-)
if [ -s /tmp/scripts/file.txt ]; then
        /usr/bin/mailx -s "Stacks with containers older than 7 days" interested_manager@gmail.com < /tmp/scripts/file.txt
        rm /tmp/scripts/file.txt
else
        echo
fi
