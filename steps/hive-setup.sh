#!/bin/bash
set -euo pipefail
(
    # Import the logging functions
    source /opt/emr/logging.sh
    
    function log_wrapper_message() {
        log_pdm_message "$1" "hive-setup.sh" "$$" "Running as: $USER"
    }
    
    log_wrapper_message "Copying create-hive-tables.py files from s3 to local"
    
    aws s3 cp "${hive-scripts-path}" /opt/emr/.
    
    aws s3 cp "${python_logger}" /opt/emr/.
    aws s3 cp "${generate_pdm_dataset}" /opt/emr/.
    
    log_wrapper_message "Creating hive tables"
    
    /usr/bin/python3.6 /opt/emr/create-hive-tables.py >> /var/log/pdm/create-hive-tables.log 2>&1
    
    log_wrapper_message "Completed the hive-setup.sh step of the EMR Cluster"
    
) >> /var/log/pdm/nohup.log 2>&1


