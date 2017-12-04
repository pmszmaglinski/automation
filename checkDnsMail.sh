#!/bin/bash

# Skrypt do sprawdzenia nieprawidlowosci w rozwiazywaniu nazwy dns serwera
# Gdy rozwiazanie jest nieprawidlowe wysyla maila z informacja debugujaca
# Odpalany z crona

IFS=$'\t\n'
HOST_BIN=$(which host)
GREP_BIN=$(which grep)
INTERNAL_MAIL_IP_ADDR=172.16.0.2
SERVER_FQDN=server.domain.com
ADMIN_MAIL=it@domain.com

# Is resolv OK ?
${HOST_BIN} $SERVER_FQDN | ${GREP_BIN} ${INTERNAL_MAIL_IP_ADDR} > /dev/null

EXIT_STATUS=$?

# DNS error
if [ ${EXIT_STATUS} != 0 ]; then
 /etc/init.d/bind9 restart > /dev/null
 EXIT_STATUS=$?
 if [ ${EXIT_STATUS} == 0 ]; then
  lookup=$(host -v $SERVER_FQDN)
  mail -s "DNS problem. Service restarted." $ADMIN_MAIL <<<"${lookup}"
 else
  mail -s "DNS problem. Service reboot FAILED !" $ADMIN_MAIL
 fi
fi
