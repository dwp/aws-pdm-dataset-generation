#!/bin/bash
###############
# Set Variables
###############

SOURCE_DB="${source_db}"
TRANSFORM_DB="${transform_db}"
DICTIONARY_LOCATION="${dictionary_location}"

SOURCE_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/transform

(
    # Import the logging functions
    source /opt/emr/logging.sh

    # Import and execute resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "transform_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_TRANSFORM ......................"
    log_wrapper_message "start running transform ......................."
    #####################
    # Run SQL Scripts
    #####################

    find $SOURCE_DIR -name '*.sql' \
        | xargs -n1 -P${processes} /opt/emr/with_retry.sh hive \
                --hivevar source_database=$SOURCE_DB \
                --hivevar transform_database=$TRANSFORM_DB \
                --hivevar dictionary_path=$DICTIONARY_LOCATION -f

    echo "FINISHED_RUNNING_TRANFORM ......................"
    log_wrapper_message "finished running transform......................."

) >> /var/log/pdm/transform_sql.log 2>&1
