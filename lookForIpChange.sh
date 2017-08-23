#!/bin/bash

# IP address we're looking for in dns server
IP_ADDRESS=''

# Domainname we're looking for in dns server
DOMAIN_NAME=''

# DNS server address we look for change
DNS_SERVER=''

PID=$$
NOTIFY_MAIL=''

while [[ $(host ${DOMAIN_NAME} ${DNS_SERVER}|grep address |cut -f 4 -d ' ') == ${IP_ADDRESS} ]]; do
        echo "Nic sie nie zmienilo"
        sleep 5
done

if [[ $(host ${DOMAIN_NAME} ${DNS_SERVER}|grep address |cut -f 4 -d ' ') != ${IP_ADDRESS} ]]; then

        RECORD=$(host ${DOMAIN_NAME} ${DNS_SERVER})
        echo "Zmiana IP" | mail -s 'Zmieniony rekord na SECONDARY DNS' <<< "${RECORD}" ${NOTIFY_MAIL}
fi
kill $$
