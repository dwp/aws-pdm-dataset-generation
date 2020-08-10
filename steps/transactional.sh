#!/bin/bash
###############
# Set Variables
###############

TRANSACTIONAL_DB="${transactional_db}"

TRANSACTIONAL_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/transactional

(
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "source_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_TRANSACTIONAL ......................"
    log_wrapper_message "start running transactional ......................."
    #####################
    # Run SQL Scripts
    #####################

    for f in $TRANSACTIONAL_DIR/*.sql
    do
        hive -f $f --hivevar transactional_database=$TRANSACTIONAL_DB
    done

    echo "FINISHED_RUNNING_TRANSACTIONAL......................"
    log_wrapper_message "finished running transactional......................."

) >> /var/log/pdm/transactional_sql.log 2>&1
