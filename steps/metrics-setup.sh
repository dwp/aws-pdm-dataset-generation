#!/bin/bash
set -euo pipefail
(
    exit 0 # TEMP TO RUN ONLY THE VIEWS
    # Import the logging functions
    source /opt/emr/logging.sh
    
    function log_wrapper_message() {
        log_pdm_message "$1" "hive-setup.sh" "$$" "Running as: $USER"
    }

    log_wrapper_message "Setting up metrics exporter"

    aws s3 cp "${metrics_export_to_s3}" /opt/emr/metrics/export-to-s3.sh
    chmod +x /opt/emr/metrics/export-to-s3.sh
    /opt/emr/metrics/export-to-s3.sh &
    
) >> /var/log/pdm/nohup.log 2>&1


