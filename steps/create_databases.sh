#!/bin/bash
###############
# Set Variables
###############

set -euo pipefail

(
 # Import the logging functions
    source /opt/emr/resume_step.sh
 # Import resume step function
    source /opt/emr/resume_step.sh
    resume_from_step

    function log_wrapper_message() {
        log_pdm_message "$${1}" "create_databases_sql.sh" "$$" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_create_databases ......................"
    log_wrapper_message "start running create db ......................."
    #####################
    # Run SQL Scripts
    #####################

    hive -f /opt/emr/sql/extracted/src/main/resources/scripts/db/create_db.sql
 
    echo "FINISHED_RUNNING_create_databases......................"
    log_wrapper_message "finished running create db ......................."

) >> /var/log/pdm/create_databases_sql.log 2>&1

