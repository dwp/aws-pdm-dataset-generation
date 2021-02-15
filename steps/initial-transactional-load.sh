#!/bin/bash
###############
# Set Variables
###############

TRANSACTIONAL_DB="${transactional_db}"
DICTIONARY_LOCATION="${dictionary_location}"

TRANSACTIONAL_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/initial-transactional-load

(
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "initial-transactional-load.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_initial-transactional-load"
    log_wrapper_message "Running initial-transactional-load-sql.sh file"
    #####################
    # Run SQL Scripts
    #####################

    if [ "${intial_transactioanl_load}" == "true" ]
    then
         for n in {1..2}
         do
            for f in "$TRANSACTIONAL_DIR"/*$n".sql"
            do
                if [ -e "$f" ]
                then
                     echo "Executing $f"
                     hive -f $f --hivevar transactional_database=$TRANSACTIONAL_DB --hivevar dictionary_path=$DICTIONARY_LOCATION
                else
                     echo "This file is missing: $f"   >> /var/log/pdm/initial-transactional-load-sql.log 2>&1
                fi
             done
         done
    else
        echo "Skipping intial_transactioanl_load as flag is set to ${intial_transactioanl_load}"
    fi

    echo "FINISHED_RUNNING initial-transactional-load"
    log_wrapper_message "Finished initial-transactional-load-sql file "

) >> /var/log/pdm/initial-transactional-load-sql.log 2>&1
