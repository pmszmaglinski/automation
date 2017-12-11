#!/bin/bash

#-e - exit on non zero exit status of any command
#-u - exit on non definded variable
#-o pipefail - prevents errors in a pipeline from being masked

set -euo pipefail
IFS=$'\n\t'

FIND=$(which find)
RM=$(which rm)
XILINX_DIR=/eda/Xilinx/
#MORE_THEN_DAYS_OLD="666"

${FIND} ${XILINX_DIR}* -type d -mtime +${MORE_THEN_DAYS_OLD} -exec $RM -rf {} \;
