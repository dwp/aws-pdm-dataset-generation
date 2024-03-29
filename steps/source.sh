#!/bin/bash
###############
# Set Variables
###############

SOURCE_DB="${source_db}"
DATA_LOCATION="${data_location}/$4" #reading s3_prefix as command line argument (4th argument)
DICTIONARY_LOCATION="${dictionary_location}"
SERDE="${serde}"

SOURCE_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/source


(
    # Import the logging functions
    source /opt/emr/logging.sh
    # Import resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "source_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_SOURCE ......................"
    log_wrapper_message "start running source ......................."
    #####################
    # Run SQL Scripts
    #####################

    #shellcheck disable=SC2038
    # here we are finding SQL files and don't have any non-alphanumeric filenames
    if ! find $SOURCE_DIR -name '*.sql' \
        | xargs -n1 -P"${processes}" /opt/emr/with_retry.sh hive \
                --hivevar source_database="$SOURCE_DB" \
                --hivevar data_path="$DATA_LOCATION" \
                --hivevar serde="$SERDE" \
                --hivevar dictionary_path="$DICTIONARY_LOCATION" -f; then
        echo source stage failed >&2
        exit 1
    fi

    echo "FINISHED_RUNNING_SOURCE......................"
    log_wrapper_message "finished running source......................."

) >> /var/log/pdm/source_sql.log 2>&1
