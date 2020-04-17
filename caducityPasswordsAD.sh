#!/bin/bash

# We need to visit different Active Directories of our organization, retrieve data and send an email to all the users who will expire their password.
# We'll send this email 10 days before, 8 days before, 5 days before, 2 days before, the day before and the same day of expiration.

# Some stuff
CRED='<password_user_with_manager_role_activedirectory>'
CRED2='<password_user_with_manager_role_another_activedirectory>'
PASSWORD_MAX_DAYS=90 # Current expiration password policy in AD
PASSWORD_REMEMBER_DAYS=(10 8 5 2 1 0) # Days until expiration where we will send an email notification warning

function shouldSendEmail {
        local expiredate=$1
        TODAY=`date -d "" +%s`
        LastSet=$(($(($expiredate/10000000))-11644473600)); # Last time user changed his/her password.
        # Minus -11644473600 is mandatory in order to convert Windows NTtime (from AD) to Unix time (to this bash script)

        DAYS_TO_EXPIRE=$(( $PASSWORD_MAX_DAYS - (($TODAY - $LastSet) / (60*60*24)) ))
        for rememberDay in ${PASSWORD_REMEMBER_DAYS}; do
           if [[ ${DAYS_TO_EXPIRE} -eq ${rememberDay} ]]; then
           return 0
           fi
        done
        return 1
}

function sendEmail {
  local mail=$1
  local expiredate=$2
  EXPIRATION=$(($PASSWORD_MAX_DAYS - $DAYS_TO_EXPIRE))
  echo "Hello there.\n Your password is about to expire in $DAYS_TO_EXPIRE.\n Please, go to <your_password-changing-web application> and change it as soon as possible.\n Thanks in advance for your cooperation.\n Greetings." | mailx -S smtp="<your_smtp_server>:25" -r itdepartment@your_domain.net -b hidden_copy_for_you@your_domain.net -s "[ IT Dept Notification ] Your password is about to expire" -t $mail
  # We send notification mail via mailx. Check if your server got it, or install (heirloom-mailx package in Debian/Ubuntu servers)
}

# DCS=()
DCS+=("ou=People,DC=your_domain,DC=net;directory-server.your_domain.net;389;CN=ldapuser,OU=People,DC=your_domain,DC=net;ldapuser;$CRED")
DCS+=("ou=People,DC=your_domain,DC=net;directory-server2.your_domain.net;389;CN=ldapghost,OU=People,DC=your_domain,DC=net;ldapghost;$CRED2")

for dc in ${DCS[@]}; do
  baseDN=`echo $dc | awk -F";" '{print $1}'`
  server=`echo $dc | awk -F";" '{print $2}'`
  port=`echo $dc | awk -F";" '{print $3}'`
  bindDN=`echo $dc | awk -F";" '{print $4}'`
  user=`echo $dc | awk -F";" '{print $5}'`
  password=`echo $dc | awk -F";" '{print $6}'`

    # Check if ldapsearch command works. If not, maybe you'll have to install ldap-utils package (Debian / Ubuntu servers)
    # Visit Active Directory wanted tree/-s and retrieve password last set and user mail.
    for i in `ldapsearch -x -b $baseDN -h $server -LLL "(&(objectClass=User)(objectClass=person)(sAMAccountName=*)(mail=*))" -D $bindDN -w $password -S pwdLastSet pwdLastSet mail | grep -E "(pwdLastSet|mail)" | tr '\n' ' ' | sed "s/ pwdLastSet: /\n/g" | sed "s/ mail: /:/g"`; do

        expiredate=`echo $i | awk -F: '{print $1}'`
        mail=`echo $i | awk -F: '{print $2}'`
        if shouldSendEmail $expiredate ; then
                sendEmail $mail $expiredate
        fi
    done
done
