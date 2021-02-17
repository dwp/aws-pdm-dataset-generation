#!/bin/bash

# Import the logging functions
source /opt/emr/logging.sh

function log_wrapper_message() {
    log_pdm_message "$${1}" "initial_transactional_load.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
}

 # Import retry function
source /opt/emr/retry.sh
check_retry

while true
do
    if [ -f /var/log/hive/metrics.json ]
    then
        aws s3 cp /var/log/hive/metrics.json "${pdm_metrics_path}"
    fi
    sleep 5
done
