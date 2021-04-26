#!/bin/bash
set -euo pipefail

(

    CORRELATION_ID=$2
    S3_PREFIX=$4
    SNAPSHOT_TYPE=$6
    EXPORT_DATE=$8
    
    echo "$CORRELATION_ID" >>     /opt/emr/correlation_id.txt
    echo "$S3_PREFIX" >>          /opt/emr/s3_prefix.txt
    echo "$SNAPSHOT_TYPE" >>      /opt/emr/snapshot_type.txt
    echo "$EXPORT_DATE" >>        /opt/emr/export_date.txt

    ########################################################################################
    # Import the logging functions
    source /opt/emr/logging.sh
    # Import and execute resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_pdm_message "$1" "create-hive-dynamo-table.sh" "$$" "Running as: $USER"
    }

    log_wrapper_message "Creating external hive table"

    hive -e "CREATE DATABASE IF NOT EXISTS AUDIT; \
    DROP TABLE IF EXISTS AUDIT.data_pipeline_metadata_hive; \
    CREATE EXTERNAL TABLE IF NOT EXISTS AUDIT.data_pipeline_metadata_hive (Correlation_Id STRING, Run_Id BIGINT, \
    DataProduct STRING, DateProductRun STRING, Status STRING, CurrentStep STRING, Cluster_Id STRING, \
    S3_Prefix_Snapshots STRING, S3_Prefix_Analytical_DataSet STRING, Snapshot_Type STRING, Created_Date STRING) \
    STORED BY 'org.apache.hadoop.hive.dynamodb.DynamoDBStorageHandler' \
    TBLPROPERTIES ('dynamodb.table.name'='${dynamodb_table_name}', \
    'dynamodb.column.mapping' = 'Correlation_Id:Correlation_Id,Run_Id:Run_Id,DataProduct:DataProduct,DateProductRun:Date,Status:Status,CurrentStep:CurrentStep,Cluster_Id:Cluster_Id,S3_Prefix_Snapshots:S3_Prefix_Snapshots,S3_Prefix_Analytical_DataSet:S3_Prefix_Analytical_DataSet,Snapshot_Type:Snapshot_Type,Created_Date:Date','dynamodb.null.serialization' = 'true');"

    log_wrapper_message "Finished creating external hive table"

) >> /var/log/pdm/create-hive-dynamo-table.log 2>&1

