#!/bin/bash

# This script waits 

set -euo pipefail
(
    # Import the logging functions
    source /opt/emr/logging.sh
    
    function log_wrapper_message() {
        log_pdm_message "$1" "flush-s3.sh" "$$" "Running as: $USER"
    }

    sleep 180 # scrape interval is 60, scrape timeout is 10, 5 for the pot
    
    log_wrapper_message "Deleting PDM metrics file"

    aws s3 rm myjson.json "${pdm_metrics_path}"
    log_wrapper_message "Done deleting the PDM metrics file"
    
) >> /var/log/pdm/flush-s3.log 2>&1
