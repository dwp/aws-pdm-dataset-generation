#!/usr/bin/bash


source /opt/emr/retry.sh
source /opt/emr/logging.sh

SCRIPT_NAME=`echo $@ | sed 's/.*scripts//'`

function log_wrapper_message() {
    log_pdm_message "$${1}" "with_retry.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
}


log_wrapper_message "Starting processing $SCRIPT_NAME ............................"

SECONDS=0
retry::with_retries $@
DURATION=$SECONDS

log_wrapper_message "$SCRIPT_NAME took $SECONDS seconds to process"
