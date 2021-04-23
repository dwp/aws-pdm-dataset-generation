#!/bin/bash

set -euo pipefail

(
    # Import the logging functions
    source /opt/emr/logging.sh
    # Import and execute resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
    log_pdm_message "$1" "additional-metrics.sh" "$$" "Running as: $USER"
    }

    # count number of tables in views db
    TABLE_NAMES=$(hive -S -e "USE $uc_views_tables; SHOW TABLES;") >> tbls.txt
    WORD_COUNT=($(wc -w tbls.txt))
    TABLE_COUNT=${WORD_COUNT[0]}

    # count number of rows in all views dbs

) >> /var/log/pdm/additional-metrics.log 2>&1