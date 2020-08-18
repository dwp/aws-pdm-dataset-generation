#!/bin/bash
###############
# Set Variables
###############

VIEWS_DB="${views_db}"
MATERIALISED_VIEWS_DB="${materialised_views_db}"
MODEL_DB="${model_db}"
TRANSFORM_DB="${transform_db}"
TRANSACTIONAL_DB="${transactional_db}"


MATERIALISED_VIEWS_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/materialised_views

(
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "materialised_views" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_MATERIALISED_VIEWS .............................."
    log_wrapper_message "start running materialised views scripts........"
    #####################
    # Run SQL Scripts
    #####################

    for f in MATERIALISED_VIEWS_DIR/*.sql
    do
        hive -f $f --hivevar materialised=$MATERIALISED_VIEWS_DB --hivevar views_database=$VIEWS_DB --hivevar model_database=$MODEL_DB --hivevar transactional_database=$TRANSACTIONAL_DB --hivevar transform_database=$TRANSFORM_DB
    done

    echo "FINISHED_RUNNING_MATERIALISED_VIEWS......................"
    log_wrapper_message "finished running materialised views......................"

) >> /var/log/pdm/materialised_views_sql.log 2>&1

