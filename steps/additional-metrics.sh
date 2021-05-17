#!/bin/bash

set -euo pipefail

(
    # Import the logging functions
    source /opt/emr/logging.sh
    # Import and execute resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
    log_pdm_message "$1" "additional-metrics.sh" "$$" "Running as: $USER"
    }
    UC_DB="${uc_db}"

    # get the data needed for metrics labels
    CORRELATION_ID_FILE=/opt/emr/correlation_id.txt
    SNAPSHOT_TYPE_FILE=/opt/emr/snapshot_type.txt
    EXPORT_DATE_FILE=/opt/emr/export_date.txt

    CORRELATION_ID=$(cat $CORRELATION_ID_FILE)
    SNAPSHOT_TYPE=$(cat $SNAPSHOT_TYPE_FILE)
    EXPORT_DATE=$(cat $EXPORT_DATE_FILE)

      push_metric() {
          metric_name=$1
          metric_value=$2

    cat << EOF | curl --data-binary @- "http://${pdm_pushgateway_hostname}:9091/metrics/job/pdm"
                $metric_name{component="PDM",snapshot_type="$SNAPSHOT_TYPE", export_date="$EXPORT_DATE", cluster_id="$CLUSTER_ID",correlation_id="$CORRELATION_ID"} $metric_value
EOF
  }

    setup_virtual_conf(){
      aws secretsmanager get-secret-value --secret-id metadata-store-v2-adg-reader --output text --query SecretString | jq -r '"[client]\npassword=" + .password + "\nuser=" + .username + "\nhost=" + .host + "\nport=" + (.port|tostring) + "\ndatabase=" + .dbInstanceIdentifier'
    }

    execute_metastore_query(){
        mysql --defaults-file=<(setup_virtual_conf) -e"$${1}"
    }

    # count number of tables in views db
    TABLE_COUNT=$(hive -S -e "USE $UC_DB; SHOW TABLES;" | wc -w)
    push_metric "pdm_views_table_count" "$${TABLE_COUNT}"

    # count number of rows in all views dbs
    ROW_COUNT=$(execute_metastore_query "select sum(param.PARAM_VALUE) FROM TABLE_PARAMS param JOIN TBLS tbl on tbl.TBL_ID = param.TBL_ID JOIN DBS db ON db.DB_ID = tbl.DB_ID WHERE db.NAME = 'uc' and param.PARAM_KEY = 'numRows';" | awk '{print $2}')

    if [[ -z "$ROW_COUNT" ]]; then
      ROW_COUNT=0
    fi

    push_metric "pdm_views_row_count" "$${ROW_COUNT}"

    # query for max date
    # Get all tables that contain a relevant timestamp column from uc_db
    tbls_data=$(execute_metastore_query "SELECT t.TBL_NAME, c.COLUMN_NAME FROM TBLS t
       JOIN DBS d
       ON t.DB_ID = d.DB_ID
       JOIN SDS s
       ON t.SD_ID = s.SD_ID
       JOIN COLUMNS_V2 c
       ON s.CD_ID = c.CD_ID
       WHERE d.NAME='${uc_db}'
       AND COLUMN_NAME in ('created_ts', 'registration_ts');"
    )

    if [[ -z "$tbls_data" ]]; then
      MAX_DATE=0
    else
      full_array=( $${tbls_data} )
      tbls_array=( $${full_array[@]:2} )
      res_column_name="$${tbls_array[1]}"
      # Create a query to union all ts columns into one column, sort in descending order and get first (max date)
      query_str=""

      #shellcheck disable=SC2066 # SC2066 - quoted array loop runs fine but shellcheck has issues with $$
      for i in "$${!tbls_array[@]}"; do
        if [[ $((i % 2)) -eq 0 ]]; then
          table_name="$${tbls_array[$i]}"
          column_name="$${tbls_array[$((i+1))]}"
          query_str="$query_str SELECT $column_name FROM uc.$table_name UNION "
        fi
      done

      query_str="$${query_str::-7} ORDER By $res_column_name DESC LIMIT 1"

      # Run query in Hive
      hive_date=$(hive -S -e "$query_str")

      if [[ "$hive_date" == "NULL" ]]; then
        MAX_DATE=0
      else
        MAX_DATE=$(date -d "$hive_date" +%s)
      fi
    fi

    push_metric "pdm_views_max_date" "$${MAX_DATE}"

) >> /var/log/pdm/additional-metrics.log 2>&1
