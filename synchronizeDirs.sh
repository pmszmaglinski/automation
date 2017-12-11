#!/bin/bash

# Synchronize directories using public keys

RSYNC=$(which rsync)
SSH=$(which ssh)
REMOTE_HOST='10.10.10.10'
REMOTE_USER='root'
REMOTE_DIR='/someDir'
LOCAL_DIR='/someDir'

${RSYNC} -rtvua -e "${SSH} -i /${LOGNAME}/.ssh/id_rsa" --delete ${LOCAL_DIR}/ ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_DIR}/
