#!/bin/bash

MODEL_DB="${model_db}"
TRANSFORM_DB="${transform_db}"
TRANSACTIONAL_DB="${transactional_db}"
VIEWS_TABLES_DB="${views_tables_db}"
METRICS_FILE_PATH=/var/log/hive/metrics.json
S3_LOCATION="${data_location}"
HIVE_METASTORE_LOCATION="${hive_metastore_location}"

(
    source /opt/emr/logging.sh
    # Import and execute resume step function
    source /opt/emr/resume_step.sh

    function log_wrapper_message() {
        log_pdm_message "$1" "row-count.sh" "$$" "Running as: $USER"
    }
    
    log_wrapper_message "Running row-count.sh file"

    db_names=("$TRANSFORM_DB" "$TRANSACTIONAL_DB" "$MODEL_DB" "$VIEWS_TABLES_DB")
    res1=$(aws s3 ls "$S3_LOCATION"/"$HIVE_METASTORE_LOCATION"/"$MODEL_DB".db/)
    res2=$(aws s3 ls" $S3_LOCATION"/"$HIVE_METASTORE_LOCATION"/"$TRANSACTIONAL_DB".db/)
    res3=$(aws s3 ls "$S3_LOCATION"/"$HIVE_METASTORE_LOCATION"/"$TRANSFORM_DB".db/)
    res4=$(aws s3 ls "$S3_LOCATION"/"$HIVE_METASTORE_LOCATION"/"$VIEWS_TABLES_DB".db/)

    tables_string="$res1 $res2 $res3 $res4"
    query_string1=""
    query_string2=""
    new_line=$'\n'

    for db_name in "${db_names[@]}"
      do
        db_row_count=0
        tb_names=$(hive -S -e "USE $db_name; SHOW TABLES;")
        for tb_name in "${tb_names[@]}"
        do
        if [[ "$tables_string" == *"$tb_name/"* ]]
        then
        query_string1="$query_string1""ANALYZE TABLE "$db_name"."$tb_name" COMPUTE STATISTICS;$new_line"
        query_string2="$query_string2""SELECT '"$db_name"."$tb_name"'; SHOW TBLPROPERTIES "$db_name"."$tb_name"('numRows');$new_line"
        fi
        done
        echo "$query_string1" | tee query_cs.hql
        echo "$query_string2" | tee query_sp.hql
        hive -S -f ./query_cs.hql
        outp=$(hive -S -f ./query_sp.hql)
        query_string1=""
        query_string2=""
        to_cloudwatch=$(echo "$outp" | while read TABLE_NAME COUNT; do echo $TABLE_NAME $COUNT; done)
        for i in "${to_cloudwatch[@]}"
          do
            echo "$i"
          done
        rows_in_db=$((0))
        separated=$(echo "$${outp}" | sed -e 's/ /\n/g')
        rows_in_tables=$(echo "$${separated}" | sed -e '/^[0-9]*$/!d')
        for j in "${rows_in_tables[@]}"
          do
            rows_in_db=$((rows_in_db+j))
          done
        gauge_name="rowcount_""$db_name"
        jq --argjson val "$rows_in_db" '.gauges += {"'"$gauge_name"'":{"value":$val}}' $METRICS_FILE_PATH > "tmp_dir" && sudo mv -f "tmp_dir" $METRICS_FILE_PATH
      done

    log_wrapper_message "Ending running row-count.sh file"

) >> /var/log/pdm/pdm_tables_row_count.log 2>&1
