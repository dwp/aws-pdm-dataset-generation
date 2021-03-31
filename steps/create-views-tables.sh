#!/bin/bash

source /opt/emr/logging.sh
source /opt/emr/resume_step.sh

main() {
    log_wrapper_message "Dropping existing tables"
    drop_existing_tables
    log_wrapper_message "Creating new tables"
    create_tables
    log_wrapper_message "Generating report"
    tables_report
    log_wrapper_message "Dropping source views"
    drop_views
    log_wrapper_message "Finished"
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
    local input_file="($${1:?})"
    #shellcheck disable=SC2001
    xargs -d '\n' -a "$input_file" -r -P"${processes}" -n1 hive -e
}

drop_existing_table_statements() {
    while read -r table_name; do
        echo \"DROP TABLE IF EXISTS "$(views_tables_db)"."$table_name"\;\"
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
    local database=$${1:?}
    hive -S -e "USE $database; SHOW TABLES;" | sort | uniq
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
