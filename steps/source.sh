#!/bin/bash
###############
# Set Variables
###############

SOURCE_DB=$1
DATA_DIR=$2
SERDE=$3
DICTIONARY_DIR=$4
SOURCE_DIR=$5

(
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "source_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_SOURCE ......................"
    log_wrapper_message "start running source ......................."
    #####################
    # Run SQL Scripts
    #####################

    for f in $SOURCE_DIR/*.sql
    do
        hive -f $f --hivevar source_database=$SOURCE_DB --hivevar data_path=$DATA_DIR --hivevar serde=$SERDE --hivevar dictionary_path=$DICTIONARY_DIR
    done

    echo "FINISHED_RUNNING_SOURCE......................"
    log_wrapper_message "finished running source......................."

) >> /var/log/pdm/transform_sql.log 2>&1
