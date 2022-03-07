#!/bin/bash

source /opt/emr/logging.sh
source /opt/emr/resume_step.sh
source /opt/emr/retry.sh

main() {
    TABLES_LIST_DIR=/opt/emr/sql/extracted/src/main/resources/scripts/pdm_tables/pdm_table_names.txt
    log_wrapper_message "Unlocking existing tables"
    unlock_existing_tables
    log_wrapper_message "Dropping existing tables"
    retry::with_retries drop_existing_tables
    log_wrapper_message "Creating new tables"
    retry::with_retries create_tables
    log_wrapper_message "Generating report"
    retry::with_retries tables_report
    log_wrapper_message "Dropping source views"
    retry::with_retries drop_views
    log_wrapper_message "Finished"
}

unlock_existing_tables() {
 parallelised_statements <(existing_table_names | unlock_existing_table_statements)
}

drop_existing_tables() {
    parallelised_statements <(existing_table_names | drop_existing_table_statements)
}

create_tables() {
    parallelised_statements <(views_table_names | create_table_statements)
}

drop_views() {
    parallelised_statements <(views_table_names | drop_view_statements)
}

tables_report() {
    no_table_created_value=$(no_table_created)
    local no_table="$no_table_created_value"
    if [[ -n $no_table ]]; then
        echo WARN: The following tables were not created: "$no_table"
    fi

    no_source_view_value=$(no_source_view)
    local no_view="$no_source_view_value"

    if [[ -n $no_view ]]; then
        echo WARN: the following tables were not sourced from the views: "$no_view"
    fi

    existing_table_names_value=$(existing_table_names | wc -l)
    local table_count="$existing_table_names_value"
    echo "$table_count" tables created.
}

parallelised_statements() {
    #shellcheck disable=SC1083
    #shellcheck disable=SC2125
    local input_file=$${1:?}
    #shellcheck disable=SC2001
    xargs -d '\n' -a "$input_file" -r -P"${processes}" -n1 hive -e
}

unlock_existing_table_statements() {
    while read -r table_name; do
        hive -e "set hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DummyTxnManager\;UNLOCK TABLE "$(views_tables_db)"."$table_name";"
    done
}

drop_existing_table_statements() {
    while read -r table_name; do
      echo \"use $(views_tables_db); SHOW TABLES\;\" | grep -w $table_name
      if [ $? -eq 0 ]; then
        echo \"use $(views_tables_db); set hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DummyTxnManager\;\"
        echo \"UNLOCK TABLE "$(views_tables_db)"."$table_name"\;\"
        retVal=$?
        if [ $retVal -ne 0 ]; then
          echo \"DROP TABLE IF EXISTS "$(views_tables_db)"."$table_name"\;\"
          continue
        else
          echo \"DROP TABLE IF EXISTS "$(views_tables_db)"."$table_name"\;\"
        fi
      else
        continue
      fi
    done
}

create_table_statements() {
    while read -r table_name; do
        echo \"CREATE TABLE "$(views_tables_db)"."$table_name" STORED AS ORC AS SELECT \* FROM "$(views_db)"."$table_name"\;\"
    done
}

drop_view_statements() {
    while read -r view_name; do
        echo \"DROP VIEW "$(views_db)"."$view_name"\;\"
    done
}

existing_table_names() {
    table_names "$(views_tables_db)"
}

views_table_names() {
    table_names "$(views_db)"
}

table_names() {
    #shellcheck disable=SC1083
    #shellcheck disable=SC2125
    cat "$TABLES_LIST_DIR"
}

no_table_created() {
    comm -23 <(views_table_names) <(existing_table_names)
}

no_source_view() {
    comm -13 <(views_table_names) <(existing_table_names)
}

log_wrapper_message() {
    log_pdm_message "$${1}" "create-views-tables.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
}

views_db() {
    echo "${views_db}"
}

views_tables_db() {
    echo "${views_tables_db}"
}


main &> /var/log/pdm/create_views_tables.log
