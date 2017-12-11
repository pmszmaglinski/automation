#!/bin/bash

# Exaple configuration for setting reverse ssh tunnel

###############
# Server side #
###############
# Create tunnel for reverse ssh on IPA server
REMOTE_SERVER=10.10.10.10
REMOTE_USERNAME=someUser
REMOTE_SSH_PORT=6666
LOCAL_SSH_PORT=22
ssh -f -N -T -R $REMOTE_SSH_PORT:localhost:$LOCAL_SSH_PORT  $REMOTE_USERNAME@$REMOTE_SERVER

######################
# Client side script #
# (remote endpoint)  #
######################
REVERSE_SSH_PORT=6666
# Download example
scp -P $REVERSE_SSH_PORT -r someUser@someHost:~/somePath/file /path1/path2/
