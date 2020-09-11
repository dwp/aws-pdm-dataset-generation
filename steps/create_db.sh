#!/bin/bash
###############
# Set Variables
###############


(
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "create_db_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_CREATE_DB ......................"
    log_wrapper_message "start running create db ......................."
    #####################
    # Run SQL Scripts
    #####################

    hive -f /opt/emr/sql/extracted/src/main/resources/scripts/db/create_db.sql
 
    echo "FINISHED_RUNNING_CREATE_DB......................"
    log_wrapper_message "finished running create db ......................."

) >> /var/log/pdm/create_db_sql.log 2>&1

