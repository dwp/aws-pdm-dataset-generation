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
    source /opt/emr/retry.sh
 # Import resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "model_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_MODEL ......................"
    log_wrapper_message "start running model ......................."

    for n in {1..9}
    do
        for f in "$MODEL_DIR"/*$n".sql"
        do
            if [ -e "$f" ]
            then
                echo "Executing $f"
                retry::with_retries hive -f $f \
                                    --hivevar model_database=$MODEL_DB \
                                    --hivevar transform_database=$TRANSFORM_DB \
                                    --hivevar transactional_database=$TRANSACTIONAL_DB
            else
                echo "This file is missing: $f"   >> /var/log/pdm/missing_model_sql.log 2>&1
            fi
        done
    done

    echo "FINISHED_RUNNING_MODEL ......................"
    log_wrapper_message "finished running model ......................."
) >> /var/log/pdm/model_sql.log 2>&1
