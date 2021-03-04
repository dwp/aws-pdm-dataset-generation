#!/usr/bin/bash

(

    source /opt/emr/retry.sh
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "with_retry.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    SECONDS=0
    retry::with_retries $@
    DURATION=$SECONDS

    SCRIPT_NAME=`echo $@ | sed 's/.*scripts//'`
    log_wrapper_message "$SCRIPT_NAME took $SECONDS seconds to process"

)  >> /var/log/pdm/time_taken.log 2>&1
