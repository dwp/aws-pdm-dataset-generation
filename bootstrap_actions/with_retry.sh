#!/usr/bin/bash


source /opt/emr/retry.sh
source /opt/emr/logging.sh

#shellcheck disable=SC2001
SCRIPT_NAME=$(echo "$@" | sed 's/.*scripts//') #Shellcheck wants to not use sed for POSIX compliance but is ok here as it works

function log_wrapper_message() {
    log_pdm_message "$${1}" "with_retry.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
}


log_wrapper_message "Starting processing $SCRIPT_NAME ............................"

SECONDS=0
retry::with_retries "$@"
exit_code=$?

log_wrapper_message "$SCRIPT_NAME took $SECONDS seconds to process" "exit_code,$exit_code"

exit "$exit_code"
