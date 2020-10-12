#!/bin/bash
###############
# Set Variables
###############

VIEWS_DB="${views_db}"
PII_DATA_LOCATION="${pii_data_location}"

SOURCE_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/create_csv_files

(
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "create_pii_csv_files.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_SOURCE ......................"
    log_wrapper_message "Start running create_pii_csv_files.sh Shell"
    #####################
    # Run SQL Scripts
    #####################

    hive -f $SOURCE_DIR/create_pii_csv.sql --hivevar views_database=$VIEWS_DB --hivevar data_path=$PII_DATA_LOCATION

    echo "FINISHED_RUNNING_SOURCE......................"
    log_wrapper_message "Finished running create_pii_csv_files.sh"

) >> /var/log/pdm/create_pii_csv_files.log 2>&1
