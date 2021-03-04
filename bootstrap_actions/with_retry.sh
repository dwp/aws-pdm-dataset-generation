#!/usr/bin/bash

source /opt/emr/retry.sh
source /opt/emr/logging.sh

function log_wrapper_message() {
    log_pdm_message "$${1}" "update_dynamo.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
}



SECONDS=0
time retry::with_retries $@
DURATION=$SECONDS
echo time1-time2 $@

log_wrapper_message "$@ took $SECONDS seconds to process"