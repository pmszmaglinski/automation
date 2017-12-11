#!/bin/bash

#
# Variables
INTERNAL_DNS='172.31.0.2'
INTERNAL_EFS='172.31.16.5'
INTERNAL_DHCP='172.31.16.1'
HES_SERVER='192.168.100.2'
LICENSE_SERVER='172.31.22.10'
LDAP_IPA='172.31.27.139'


# iptables example configuration script
#
# Flush all current rules from iptables
#
 iptables -F
#
# Allow SSH connections on tcp port 22
# This is essential when working on remote servers via SSH to prevent locking yourself out of the system
#

# SSH SERVER
 iptables -A INPUT -m state --state NEW -m tcp -p tcp --dport 22 -j ACCEPT
 iptables -A OUTPUT -o eth0 -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT

# SSH TO HS
 iptables -A OUTPUT -o eth0 -p tcp -d ${HES_SERVER} --dport 22 -m state --state NEW,ESTABLISHED -j ACCEPT

# Ping to HS
 iptables -A OUTPUT -o eth0 -p icmp --icmp-type 8 -d ${HES_SERVER} -m state --state NEW,ESTABLISHED -j ACCEPT

# Allow internal DNS
 iptables -A OUTPUT -o eth0 -p udp -d ${INTERNAL_DNS} --dport 53 -m state --state NEW -j ACCEPT

# Allow DHCP
 iptables -A OUTPUT -o eth0 -p udp -d ${INTERNAL_DHCP} --dport 67 -m state --state NEW -j ACCEPT

# Allow EFS
 iptables -A OUTPUT -o eth0 -p tcp -d ${INTERNAL_EFS} --dport 2049 -m state --state NEW,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -o eth0 -p udp -d ${INTERNAL_EFS} --dport 2049 -m state --state NEW,ESTABLISHED -j ACCEPT

# Allow outgoing LDAP (IPA)
 iptables -A OUTPUT -o eth0 -p tcp -d ${LDAP_IPA} --dport 389 -m state --state NEW,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -o eth0 -p udp -d ${LDAP_IPA} --dport 389 -m state --state NEW,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -o eth0 -p tcp -d ${LDAP_IPA} --dport 636 -m state --state NEW,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -o eth0 -p udp -d ${LDAP_IPA} --dport 636 -m state --state NEW,ESTABLISHED -j ACCEPT
 iptables -A OUTPUT -o eth0 -p tcp -d ${LDAP_IPA} --dport 88 -m state --state NEW,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -o eth0 -p udp -d ${LDAP_IPA} --dport 88 -m state --state NEW -j ACCEPT
# iptables -A OUTPUT -o eth0 -p tcp -d ${LDAP_IPA} --dport 464 -m state --state NEW,ESTABLISHED -j ACCEPT
# iptables -A OUTPUT -o eth0 -p udp -d ${LDAP_IPA} --dport 464 -m state --state NEW -j ACCEPT
# iptables -A OUTPUT -o eth0 -p tcp -d ${LDAP_IPA} --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
 iptables -A OUTPUT -o eth0 -p udp -d ${LDAP_IPA} --dport 53 -m state --state NEW -j ACCEPT

# Allow NTP for LDAP
 iptables -A OUTPUT -o eth0 -p udp -d ${LDAP_IPA} --dport 123 -m state --state NEW,ESTABLISHED -j ACCEPT

# Allow S3 and HTTP
 iptables -A OUTPUT -o eth0 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT

# Allow HTTPS
 iptables -A OUTPUT -o eth0 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT

#
# Accept packets belonging to established and related connections
#
 iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

#
# Set access for localhost
#
 iptables -A INPUT -i lo -j ACCEPT
 iptables -A OUTPUT -o lo -j ACCEPT


# LOGGING
 iptables -N LOGGING
 iptables -A OUTPUT -j LOGGING
 iptables -A INPUT -j LOGGING
 iptables -A LOGGING -m limit --limit 2/min -j LOG --log-prefix "iptables: " --log-level 7
 iptables -A LOGGING -j DROP


#
# Set default policies for INPUT, FORWARD and OUTPUT chains
#
 iptables -P INPUT DROP
 iptables -P FORWARD DROP
 iptables -P OUTPUT DROP

#
# Save settings
#
 #/sbin/service iptables save
#
# List rules
#
 iptables -L -v
