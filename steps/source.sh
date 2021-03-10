#!/bin/bash
###############
# Set Variables
###############

SOURCE_DB="${source_db}"
DATA_LOCATION="${data_location}/$4" #reading s3_prefix as command line argument (4th argument)
DICTIONARY_LOCATION="${dictionary_location}"
SERDE="${serde}"

SOURCE_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/source


(
    # Import the logging functions
    source /opt/emr/logging.sh
    # Import resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "source_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_SOURCE ......................"
    log_wrapper_message "start running source ......................."
    #####################
    # Run SQL Scripts
    #####################

    find $SOURCE_DIR -name 'youth_obligation_details.sql' \
        | xargs -n1 -P${processes} /opt/emr/with_retry.sh hive \
                --hiveconf hive.root.logger=DEBUG,console \
                --hivevar source_database=$SOURCE_DB \
                --hivevar data_path=$DATA_LOCATION \
                --hivevar serde=$SERDE \
                --hivevar dictionary_path=$DICTIONARY_LOCATION -f

    echo "FINISHED_RUNNING_SOURCE......................"
    log_wrapper_message "finished running source......................."

) >> /var/log/pdm/source_sql.log 2>&1
