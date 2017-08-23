#!/bin/bash

# IP address we're looking for in dns server
IP_ADDRESS=''

# Domainname we're looking for in dns server
DOMAIN_NAME=''

# DNS server address we look for change
DNS_SERVER=''

CHECK_INTERVAL='300'
PID=$$
NOTIFY_MAIL=''

# If no serwer error = var is set
if [[  -n $(host ${DOMAIN_NAME} ${DNS_SERVER}|grep address |cut -f 4 -d ' ') ]] && [[ $(host ${DOMAIN_NAME} ${DNS_SERVER}|grep address |cut -f 4 -d ' ') != ${IP_ADDRESS} ]]; then

        RECORD=$(host ${DOMAIN_NAME} ${DNS_SERVER})
        echo "Zmiana IP" | mail -s 'Zmieniony rekord na SECONDARY DNS' <<< "${RECORD}" ${NOTIFY_MAIL}

else
        # Problem with getting ip address variable (connection to dns server?, no record returned?)
        RECORD=$(host ${DOMAIN_NAME} ${DNS_SERVER})
        mail -s 'Error with DNS server. Exiting.' <<< "${RECORD}" ${NOTIFY_MAIL}

fi

kill $$
