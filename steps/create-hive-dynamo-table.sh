#!/bin/bash

set -euo pipefail
(

    CORRELATION_ID=$2
    echo $CORRELATION_ID >> /opt/emr/correlation_id.txt

    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$1" "create-hive-dynamo-table.sh" "$$" "Running as: $USER"
    }


    log_wrapper_message "Creating external hive table"

    hive -e "CREATE DATABASE IF NOT EXISTS AUDIT; \
    DROP TABLE IF EXISTS AUDIT.data_pipeline_metadata_hive; \
    CREATE EXTERNAL TABLE IF NOT EXISTS AUDIT.data_pipeline_metadata_hive (Correlation_Id STRING, Run_Id BIGINT, DataProduct STRING, DateProductRun STRING, Status STRING, CurrentStep STRING) \
    STORED BY 'org.apache.hadoop.hive.dynamodb.DynamoDBStorageHandler' \
    TBLPROPERTIES ('dynamodb.table.name'='${dynamodb_table_name}', \
    'dynamodb.column.mapping' = 'Correlation_Id:Correlation_Id,Run_Id:Run_Id,DataProduct:DataProduct,DateProductRun:Date,Status:Status,CurrentStep:CurrentStep','dynamodb.null.serialization' = 'true');"

    log_wrapper_message "Finished creating external hive table"

) >> /var/log/pdm/create-hive-dynamo-table.log 2>&1

