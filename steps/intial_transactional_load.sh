#!/bin/bash
###############
# Set Variables
###############

TRANSACTIONAL_DB="${transactional_db}"

TRANSACTIONAL_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/intial_transactional_load

(
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "intial_transactional_load.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_INTIAL_TRANSACTIONAL_LOAD"
    log_wrapper_message "Running intial_transactional_load_sql.sh file"
    #####################
    # Run SQL Scripts
    #####################

    if ["${intial_transactioanl_load}" == "true"]
    then
         for n in {1..2}
         do
            for f in "$TRANSACTIONAL_DIR"/*$n".sql"
            do
                if [ -e "$f" ]
                then
                     echo "Executing $f"
                     hive -f $f --hivevar transactional_database=$TRANSACTIONAL_DB
                else
                     echo "This file is missing: $f"   >> /var/log/pdm/intial_transactional_load_sql.log 2>&1
                fi
             done
         done
    else
        echo "Skipping intial_transactioanl_load as flag is set to ${intial_transactioanl_load}"

    echo "FINISHED_RUNNING INTIAL_TRANSACTIONAL_LOAD"
    log_wrapper_message "Finished intial_transactional_load_sql file "

) >> /var/log/pdm/intial_transactional_load_sql.log 2>&1
