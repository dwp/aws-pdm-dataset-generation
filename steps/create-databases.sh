#!/bin/bash
###############
# Set Variables
###############


(
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "create-databases-sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_create_databases ......................"
    log_wrapper_message "start running create db ......................."
    #####################
    # Run SQL Scripts
    #####################

    hive -f /opt/emr/sql/extracted/src/main/resources/scripts/db/create_databases.sql
 
    echo "FINISHED_RUNNING_create_databases......................"
    log_wrapper_message "finished running create db ......................."

) >> /var/log/pdm/create_databases_sql.log 2>&1

