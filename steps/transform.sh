#!/bin/bash
###############
# Set Variables
###############

SOURCE_DB=$1
TRANSFORM_DB=$2
DICTIONARY_DIR=$3
SOURCE_DIR=$4

(
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "transform_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_TRANSFORM ......................"
    log_wrapper_message "start running transform ......................."
    #####################
    # Run SQL Scripts
    #####################

    for f in $SOURCE_DIR/*.sql
    do
        hive -f $f --hivevar source_database=$SOURCE_DB --hivevar transform_database=$TRANSFORM_DB --hivevar dictionary_path=$DICTIONARY_DIR
    done

    echo "FINISHED_RUNNING_TRANFORM ......................"
    log_wrapper_message "finished running transform......................."

) >> /var/log/pdm/transform_sql.log 2>&1

