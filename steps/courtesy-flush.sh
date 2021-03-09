#!/bin/bash

# This script deletes PDMs metrics file is s3. The CLI call doesn't
# error if file file isn't present. 

set -euo pipefail
(
    # Import the logging functions
    source /opt/emr/logging.sh
    
    function log_wrapper_message() {
        log_pdm_message "$1" "courtesy-flush.sh" "$$" "Running as: $USER"
    }
    
    log_wrapper_message "Deleting PDM metrics file"

    aws s3 rm "${pdm_metrics_path}"
    log_wrapper_message "Done deleting the PDM metrics file"
    
) >> /var/log/pdm/flush-metrics.log 2>&1
