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

    function log_wrapper_message() {
        log_pdm_message "$${1}" "views_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_VIEWS .............................."
    log_wrapper_message "start running views scripts........"
    #####################
    # Run SQL Scripts
    #####################

    for f in $VIEWS_DIR/*.sql
    do
        hive -f $f --hivevar views_database=$VIEWS_DB --hivevar model_database=$MODEL_DB --hivevar transactional_database=$TRANSACTIONAL_DB --hivevar transform_database=$TRANSFORM_DB
    done

    echo "FINISHED_RUNNING_VIEW......................"
    log_wrapper_message "finished running views......................"

) >> /var/log/pdm/views_sql.log 2>&1
