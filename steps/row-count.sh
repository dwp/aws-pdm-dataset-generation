#!/bin/bash

VIEWS_DB="${views_db}"
MODEL_DB="${model_db}"
TRANSFORM_DB="${transform_db}"
TRANSACTIONAL_DB="${transactional_db}"
METRICS_FILE_PATH=/var/log/hive/metrics.json
S3_LOCATION="${data_location}"

(
    source /opt/emr/logging.sh
    function log_wrapper_message() {
        log_pdm_message "$1" "row-count.sh" "$$" "Running as: $USER"
    }
    log_wrapper_message "Running row-count.sh file"

    db_names=($TRANSFORM_DB $TRANSACTIONAL_DB $MODEL_DB)
    res1=$(aws s3 ls $S3_LOCATION/pdm-dataset/hive/external/$MODEL_DB.db/)
    res2=$(aws s3 ls $S3_LOCATION/pdm-dataset/hive/external/$TRANSACTIONAL_DB.db/)
    res3=$(aws s3 ls $S3_LOCATION/pdm-dataset/hive/external/$TRANSFORM_DB.db/)
    tables_string="$res1 $res2 $res3"
    query_string1=""
    query_string2=""
    new_line=$'\n'

    for db_name in $${db_names[@]}
      do
        db_row_count=0
        tb_names=$(hive -S -e "USE $db_name; SHOW TABLES;")
        declare -a $tb_names
        for tb_name in $${tb_names[@]}
        do
        if [[ "$tables_string" == *"$tb_name/"* ]]
        then
        query_string1=$query_string1"ANALYZE TABLE "$db_name"."$tb_name" COMPUTE STATISTICS;$new_line"
        query_string2=$query_string2"SELECT '"$db_name"."$tb_name"'; SHOW TBLPROPERTIES "$db_name"."$tb_name"('numRows');$new_line"
        fi
        done
        echo $query_string1 | tee query_cs.hql
        echo $query_string2 | tee query_sp.hql
        hive -S -f ./query_cs.hql
        outp=$(hive -S -f ./query_sp.hql)
        query_string1=""
        query_string2=""
        to_cloudwatch=$(echo "$outp" | while read TABLE_NAME COUNT; do echo $TABLE_NAME $COUNT; done)
        for i in $${to_cloudwatch[@]}
          do
            echo $i
          done
        rows_in_db=$((0))
        separated=$(echo $${outp} | sed -e 's/ /\n/g')
        rows_in_tables=$(echo "$${separated}" | sed -e '/^[0-9]*$/!d')
        for j in $${rows_in_tables[@]}
          do
            rows_in_db=$((rows_in_db+j))
          done
        gauge_name="rowcount_"$db_name
        jq --argjson val $rows_in_db '.gauges += {"'"$gauge_name"'":{"value":$val}}' $METRICS_FILE_PATH > "tmp_dir" && sudo mv -f "tmp_dir" $METRICS_FILE_PATH
      done
    table_names=$(hive -S -e "USE $VIEWS_DB; SHOW TABLES;")
    row_count_tot=$((0))
    declare -a $table_names
    for table_name in $${table_names[@]}
    do
      row_count=$(hive -S -e "select count(*) from $VIEWS_DB.$table_name")
      if ! [[ -z $row_count ]]; then
      row_count=$((row_count+0))
      row_count_tot=$((row_count+row_count_tot))
      echo $VIEWS_DB.$table_name
      echo $row_count
      fi
    done
    gauge_name="rowcount_"$VIEWS_DB
    jq --argjson val $row_count_tot '.gauges += {"'"$gauge_name"'":{"value":$val}}' $METRICS_FILE_PATH > "tmp_dir" && sudo mv -f "tmp_dir" $METRICS_FILE_PATH

    log_wrapper_message "Ending running row-count.sh file"

) >> /var/log/pdm/pdm_tables_row_count.log 2>&1
