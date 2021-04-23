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
    TABLE_NAMES=$(hive -S -e "USE $uc_views_tables; SHOW TABLES;") >> tbls.txt
    WORD_COUNT=($(wc -w tbls.txt))
    TABLE_COUNT=${WORD_COUNT[0]}
    push_metric "pdm_views_table_count" $TABLE_COUNT


    # count number of rows in all views dbs
    

    # query for max date 
    MAX_DATES=$(hive -S -f ./query_max_dates.hql) #this file will be uploaded to s3

 

) >> /var/log/pdm/additional-metrics.log 2>&1