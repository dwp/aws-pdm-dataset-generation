#!/bin/bash
###############
# Set Variables
###############

TRANSFORM_DB="${transform_db}"
TRANSACTIONAL_DB="${transactional_db}"
MODEL_DB="${model_db}"

MODEL_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/model

########################
# Run Model Script
########################
(
    # Import the logging functions
    source /opt/emr/logging.sh
    # Import and execute resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "model_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_MODEL ......................"
    log_wrapper_message "start running model ......................."

    /opt/emr/with_retry.sh hive \
                           --hivevar model_database=$MODEL_DB \
                           --hivevar transform_database=$TRANSFORM_DB \
                           --hivevar transactional_database=$TRANSACTIONAL_DB -f $MODEL_DIR/site_dim.1.sql

    for n in {1..9}
    do
        find $MODEL_DIR -name "*$n.sql" | grep site_dim.1.sql \
            | xargs -r -n1 -P${processes} /opt/emr/with_retry.sh hive \
                    --hivevar model_database=$MODEL_DB \
                    --hivevar transform_database=$TRANSFORM_DB \
                    --hivevar transactional_database=$TRANSACTIONAL_DB -f
    done

    echo "FINISHED_RUNNING_MODEL ......................"
    log_wrapper_message "finished running model ......................."

) >> /var/log/pdm/model_sql.log 2>&1
