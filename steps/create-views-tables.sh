#!/bin/bash

VIEWS_DB="${views_db}"
VIEWS_TABLES_DB="${views_tables_db}"
TEMP_DIR=/opt/emr/sql/extracted/src/main/resources/scripts

(
    source /opt/emr/logging.sh
    # Import and execute resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "create-views-tables.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

    log_wrapper_message "Start running create-views-tables.sh Shell"

    statements_file=$TEMP_DIR/create_views_tables.sql
    touch $statements_file
    tb_names=$(hive -S -e "USE $VIEWS_DB; SHOW TABLES;")
    tb_names_views_tables_previous_iteration=$(hive -S -e "USE $VIEWS_TABLES_DB; SHOW TABLES;")
    declare -a $tb_names
    declare -a $tb_names_views_tables_previous_iteration
    # Clean up views_tables database
    for i in $${tb_names_views_tables_previous_iteration[@]}
      do
        echo "DROP TABLE "$VIEWS_TABLES_DB"."$i";" >> $statements_file
      done
    # Create new tables from views
    for i in $${tb_names[@]}
      do
        echo "CREATE TABLE "$VIEWS_TABLES_DB"."$i" AS SELECT * FROM "$VIEWS_DB"."$i";" >> $statements_file
      done
    # Clean up views database
    for i in $${tb_names[@]}
      do
        echo "DROP VIEW "$VIEWS_DB"."$i";" >> $statements_file
      done
    hive --hiveconf hive.cli.errors.ignore=true -f $statements_file
    tb_names_views_tables=$(hive -S -e "USE $VIEWS_TABLES_DB; SHOW TABLES;")
    sudo rm -f $statements_file
    declare -a $tb_names_views_tables
    count=0
    for i in $${tb_names_views_tables[@]}
      do
        (( count ++ ))
      done
    echo "$count views were replaced by tables"

    if [[ $tb_names != $tb_names_views_tables ]]
      then
        echo "WARN. There was a problem creating tables from:"
        echo $${tb_names[@]} $${tb_names_views_tables[@]} | tr ' ' '\n' | sort | uniq -u
    fi

    log_wrapper_message "Finished running create_views_tables.sh"

) >> /var/log/pdm/create_views_tables.log 2>&1
