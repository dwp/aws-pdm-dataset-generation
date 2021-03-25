#!/bin/bash
###############
# Set Variables
###############

VIEWS_DB="${views_db}"
MODEL_DB="${model_db}"
TRANSFORM_DB="${transform_db}"
TRANSACTIONAL_DB="${transactional_db}"
VIEWS_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/views

(
    # Import the logging functions
    source /opt/emr/logging.sh
    # Import and execute resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "views_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_VIEWS .............................."
    log_wrapper_message "start running views scripts........"
    #####################
    # Run SQL Scripts
    #####################

    #shellcheck disable=SC2038
    # here we are finding SQL files and don't have any non-alphanumeric filenames
    if ! find $VIEWS_DIR -name '*.sql' \
        | xargs -n1 -P"${processes}" /opt/emr/with_retry.sh hive \
            --hivevar views_database="$VIEWS_DB" \
            --hivevar model_database="$MODEL_DB" \
            --hivevar transactional_database="$TRANSACTIONAL_DB" \
            --hivevar transform_database="$TRANSFORM_DB" -f; then
        echo view stage failed, exiting. >&2
        exit 1
    fi

    echo "FINISHED_RUNNING_VIEW......................"
    log_wrapper_message "finished running views......................"

) >> /var/log/pdm/views_sql.log 2>&1
