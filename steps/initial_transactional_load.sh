#!/bin/bash
###############
# Set Variables
###############

TRANSACTIONAL_DB="${transactional_db}"
DICTIONARY_LOCATION="${dictionary_location}"

TRANSACTIONAL_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/initial_transactional_load

(
    # Import the logging functions
    source /opt/emr/logging.sh
    # Import and execute resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "initial_transactional_load.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_initial_transactional_load"
    log_wrapper_message "Running initial_transactional_load_sql.sh file"
    #####################
    # Run SQL Scripts
    #####################

    if [ "${initial_transactional_load}" == "true" ]
    then
         for n in {1..2}
         do
            for f in "$TRANSACTIONAL_DIR"/*$n".sql"
            do
                if [ -e "$f" ]
                then
                     echo "Executing $f"
                     hive -f "$f" --hivevar transactional_database="$TRANSACTIONAL_DB" --hivevar dictionary_path="$DICTIONARY_LOCATION"
                else
                     echo "This file is missing: $f"   >> /var/log/pdm/initial_transactional_load_sql.log 2>&1
                fi
             done
         done
    else
        echo "Skipping initial_transactional_load as flag is set to ${initial_transactional_load}"
    fi

    echo "FINISHED_RUNNING initial_transactional_load"
    log_wrapper_message "Finished initial_transactional_load_sql file "

) >> /var/log/pdm/initial_transactional_load_sql.log 2>&1
