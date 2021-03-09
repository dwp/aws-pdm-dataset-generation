#!/bin/bash

set -euo pipefail
(
    # Import the logging functions
    source /opt/emr/logging.sh
    
    function log_wrapper_message() {
        log_pdm_message "$1" "courtesy-flush.sh" "$$" "Running as: $USER"
    }
    
    log_wrapper_message "Deleting PDM metrics file"

    aws s3 rm myjson.json "${pdm_metrics_path}"
    log_wrapper_message "Done deleting the PDM metrics file"
    
) >> /var/log/pdm/flush-metrics.log 2>&1
