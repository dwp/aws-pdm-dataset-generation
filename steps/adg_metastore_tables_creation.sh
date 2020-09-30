#!/bin/bash
###############
# Set Variables
###############

PUBLISHED_DATABASE_NAME="${published_database_name}"
ADG_CSV_FILE_LOCATION="${adg_csv_file_location}"

(
 # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "source_sql.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

echo "Downloading analytical-dataset-hive-tables-metadata.csv"
log_wrapper_message "Downloading analytical-dataset-hive-tables-metadata.csv"
aws s3 cp $ADG_CSV_FILE_LOCATION /opt/emr/analytical-dataset-hive-tables-metadata.csv

ADG_HIVE_TABLES_METADATA=/opt/emr/analytical-dataset-hive-tables-metadata.csv

echo "Creating ADG Published database"
log_wrapper_message "Creating ADG Published database"
hive -e "CREATE DATABASE IF NOT EXISTS $PUBLISHED_DATABASE_NAME;"


echo "Creating ADG tables in Published database"
log_wrapper_message "Creating ADG tables in Published database"
OLDIFS=$IFS
IFS=','
[ ! -f $ADG_HIVE_TABLES_METADATA ] && { echo "$ADG_HIVE_TABLES_METADATA file not found"; exit 99; }
while read table_name s3_prefix
do
	log_wrapper_message "Creating ADG $table_name in Published database"
	hive -e "CREATE EXTERNAL TABLE IF NOT EXISTS  $PUBLISHED_DATABASE_NAME.$table_name  (val STRING) STORED AS TEXTFILE LOCATION  '$s3_prefix';"
done < $ADG_HIVE_TABLES_METADATA
IFS=$OLDIFS

log_wrapper_message "Completed execution of script adg_metastore_tables_creation.sh"

) >> /var/log/pdm/adg_metastore_tables_creation.log 2>&1
