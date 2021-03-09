#!/bin/bash

# This script waits for a fixed period to give the metrics scraper enough
# time to collect PDMs metrics. It then deletes all of PDMs metrics so that
# the scraper doesn't continually gather stale metrics long past PDM's termination.

set -euo pipefail
(
    # Import the logging functions
    source /opt/emr/logging.sh
    
    function log_wrapper_message() {
        log_adg_message "$${1}" "flush-pushgateway.sh" "Running as: ,$USER"
    }
    
    log_wrapper_message "Sleeping for 3m"
    
    sleep 180 # scrape interval is 60, scrape timeout is 10, 5 for the pot
    
    log_wrapper_message "Flushing the PDM pushgateway"
    aws s3 rm myjson.json
    log_wrapper_message "Done flushing the PDM pushgateway"
    
) >> /var/log/adg/flush-s3.log 2>&1
