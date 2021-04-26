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
    S3_LOCATION="${data_location}"
    HIVE_METASTORE_LOCATION="${hive_metastore_location}"

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
                $metric_name{component="PDM",snapshot_type="$SNAPSHOT_TYPE", export_date="$EXPORT_DATE", cluster_id="$CLUSTER_ID",correlation_id="$CORRELATION_ID"} metric_value
EOF

  }
    # count number of tables in views db
    TABLE_NAMES=$(hive -S -e "USE $UC_DB; SHOW TABLES;") >> tbls.txt
    WORD_COUNT=($(wc -w tbls.txt))
    TABLE_COUNT=${WORD_COUNT[0]}
    push_metric "pdm_views_table_count" $TABLE_COUNT


    # count number of rows in all views dbs
    
    res=$(aws s3 ls "$S3_LOCATION/$HIVE_METASTORE_LOCATION/$VIEWS_TABLES_DB".db/)

    query_string1=""
    query_string2=""
    new_line=$'\n'
    tb_names=$(hive -S -e "USE $UC_DB; SHOW TABLES;")
    for tb_name in "${tb_names[@]}"
      do
        if [[ "$tables_string" == *"$tb_name/"* ]]
        then
        query_string1="$query_string1" "ANALYZE TABLE ""$UC_DB"".""$tb_name"" COMPUTE STATISTICS;$new_line"
        query_string2="$query_string2" "SELECT '""$UC_DB"".""$tb_name""'; SHOW TBLPROPERTIES ""$UC_DB"".""$tb_name""('numRows');$new_line"
        fi
      done
    echo "$query_string1" | tee query_cs.hql
    echo "$query_string2" | tee query_sp.hql
    hive -S -f ./query_cs.hql
    outp=$(hive -S -f ./query_sp.hql)
    query_string1=""
    query_string2=""
    rows_in_db=$((0))
    separated=$(echo "${outp}" | sed -e 's/ /\n/g')
    rows_in_tables=$(echo "${separated}" | sed -e '/^[0-9]*$/!d')
    for j in "${rows_in_tables[@]}"
      do
        rows_in_db=$((rows_in_db+j))
      done
    gauge_name="rowcount_""$UC_DB"
    jq --argjson val "$rows_in_db" '.gauges += {"'"$gauge_name"'":{"value":$val}}' $METRICS_FILE_PATH > "tmp_dir" && sudo mv -f "tmp_dir" $METRICS_FILE_PATH

    # query for max date 
    MAX_DATES=$(hive -S -f ./query_max_dates.hql) #this file will be uploaded to s3

 

) >> /var/log/pdm/additional-metrics.log 2>&1
