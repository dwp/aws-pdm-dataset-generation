#!/bin/bash
###############
# Set Variables
###############

VIEWS_DB="${views_db}"
VIEWS_TABLES_DB="${views_tables_db}"
SOURCE_DIR=/opt/emr/sql/extracted/src/main/resources/scripts

(
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "create_views_tables.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    echo "START_RUNNING_SOURCE ......................"
    log_wrapper_message "Start running create_pii_csv_files.sh Shell"
    statements_file=$SOURCE_DIR/create_mt_from_vv.sql
    touch $statements_file
    tb_names=$(hive -S -e "USE $VIEWS_DB; SHOW TABLES;")
    declare -a tb_names
    for i in $${tb_names[@]}
      do
        echo "DROP TABLE "$VIEWS_TABLES_DB"."$i";"$'\n'"CREATE TABLE "$VIEWS_TABLES_DB"."$i" AS SELECT * FROM "$VIEWS_DB"."$i";" >> $statements_file
      done
    hive --hiveconf hive.cli.errors.ignore=true -f $statements_file
    echo "FINISHED_RUNNING_SOURCE......................"
    log_wrapper_message "Finished running create_views_tables.sh"

) >> /var/log/pdm/create_views_tables.log 2>&1
