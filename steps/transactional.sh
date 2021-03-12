#!/bin/bash
###############
# Set Variables
###############

TRANSACTIONAL_DB="${transactional_db}"

TRANSACTIONAL_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/transactional

(
    # Import the logging functions
    source /opt/emr/logging.sh
    # Import and execute resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "transactional_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_TRANSACTIONAL ......................"
    log_wrapper_message "start running transactional ......................."
    #####################
    # Run SQL Scripts
    #####################

    if ! find $TRANSACTIONAL_DIR -name '*.sql' \
        | xargs -n1 -P${processes} /opt/emr/with_retry.sh hive \
                --hivevar transactional_database=$TRANSACTIONAL_DB -f; then
        echo transactional stage failed
        exit 1
    fi

    echo "FINISHED_RUNNING_TRANSACTIONAL......................"
    log_wrapper_message "finished running transactional......................."

) >> /var/log/pdm/transactional_sql.log 2>&1
