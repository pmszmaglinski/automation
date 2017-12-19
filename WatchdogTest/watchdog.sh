#!/bin/bash
# Assumption that system is using systemctl service management

# SCRIPT VARS
LOG_FILE='/var/log/watchdogd.log'
SERVICE_STATUS='DOWN'
SERVICE_BRINGUP_FAILED='NO'

# CHECK FOR SOME DEPS
PS=$(which ps) || ERROR="|ps"
GREP=$(which grep) || ERRORS=${ERRORS}"|grep"
SEQ=$(which seq) || ERRORS=${ERRORS}"|seq"
SYSTEMCTL=$(which systemctl) || ERRORS=${ERRORS}"|systemctl"
TEE=$(which tee) || ERRORS=${ERRORS}"|tee"
DATE='date +%Y-%m-%d,%H:%M:%S' || ERRORS=${ERRORS}"|date"

# DEPS NOT FOUND
if [ ${ERRORS} ]; then
        echo -e "$(${EVAL} ${DATE}) -> Configuration problem. Couldn't find : ${ERRORS}" >> ${LOG_FILE} && exit 1
fi

# Load configuration file
CONFIG_FILE=/etc/watchdogd.cfg

# Does config exists ?
if [ ! -f ${CONFIG_FILE} ]; then
        echo "$(${EVAL} ${DATE}) -> Couldn't find configuration file : ${CONFIG_FILE}" >> ${LOG_FILE}
        exit 1
else
        source ${CONFIG_FILE}
fi

# Check for user vars settings
if [[ -z ${SERVICE_NAME} || -z ${TRY_INTERVAL} || -z ${RESTART_INTERVAL} || -z ${RESTART_ATTEMPTS} || -z ${NOTIFY_EMAIL} ]]; then
        echo "Some vars are not set. Recheck your configuration file please" >> ${LOG_FILE}
        exit 1
fi

# Notify logs that watchdog is starting
echo "$(${EVAL} ${DATE}) -> Starting WATCHDOG" >> ${LOG_FILE}


# Main loop
while true; do

# Is the process we watching running ?
if ${PS} -e | grep -v 'grep' | grep ${SERVICE_NAME} >/dev/null; then

        # Notify restart after failed (service fixed by hand restart)
        if [ ${SERVICE_BRINGUP_FAILED} == 'YES' ]; then
                echo "$(${EVAL} ${DATE}) -> Service ${SERVICE_NAME} has beed restored" >> ${LOG_FILE}
        fi

        # All fine, wait untill next check
        SERVICE_STATUS='UP' && SERVICE_BRINGUP_FAILED='NO'
        sleep ${TRY_INTERVAL}

else
        # Service is not running
        SERVICE_STATUS='DOWN'
fi

# Let's try to bring it up and send some notifications
if [ ${SERVICE_STATUS} == 'DOWN' ] && [ ${SERVICE_BRINGUP_FAILED} == 'NO' ]; then
        echo "$(${EVAL} ${DATE}) -> Service ${SERVICE_NAME} is DOWN" | ${TEE} -a  ${LOG_FILE} | mail -s "WATCHDOG" ${NOTIFY_EMAIL}

        for i in $(${SEQ} ${RESTART_ATTEMPTS}); do
                echo -n "$(${EVAL} ${DATE}) -> Server ${SERVICE_NAME} restart attempt no. ${i} : " >> ${LOG_FILE}
                # Get UP !
                if ${SYSTEMCTL} restart ${SERVICE_NAME} &>/dev/null; then
                        # Is UP
                        echo "SUCCESS" >> ${LOG_FILE}
                        echo "$(${EVAL} ${DATE}) -> Service ${SERVICE_NAME} has been restarted after ${i} attempts" | mail -s "WATCHDOG" ${NOTIFY_EMAIL}
                        # Set status flags and get out of that loop
                        SERVICE_STATUS='UP' && SERVICE_BRINGUP_FAILED='NO'
                        break
                fi
                # Is DOWN ! Notify and try again
                echo "FAILED" >> ${LOG_FILE}
                sleep ${RESTART_INTERVAL}
        done

        # Service is DOWN - max try limit reached
        if [ ${SERVICE_STATUS} == 'DOWN' ]; then
                echo "$(${EVAL} ${DATE}) -> Couldn't restart server ${SERVICE_NAME} for ${RESTART_ATTEMPTS} times." >> ${LOG_FILE}
                echo "$(${EVAL} ${DATE}) -> Service ${SERVICE_NAME} can't be started after ${RESTART_ATTEMPTS} attempts" | mail -s "WATCHDOG" ${NOTIFY_EMAIL}

                # Set bringup failed flag not to send another
                # notifications until the service is restored other way (by hand)
                SERVICE_BRINGUP_FAILED='YES'
        fi

        # Try anyway in usual interval even if service is not up
        sleep ${TRY_INTERVAL}

fi
done
