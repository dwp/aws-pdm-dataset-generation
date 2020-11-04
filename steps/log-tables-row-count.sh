#!/bin/bash

set -euo pipefail

#VIEWS_DB="${views_db}"
#MODEL_DB="${model_db}"
#TRANSFORM_DB="${transform_db}"
#TRANSACTIONAL_DB="${transactional_db}"
TRANSFORM_DB="uc_pdm_transform"
TRANSACTIONAL_DB="uc_pdm_transactional"
(
    # Import the logging functions
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$1" "log-tables-row-count.sh" "$$" "Running as: $USER"
    }

    log_wrapper_message "Running log-tables-row-count.sh file"
    db_names=($VIEWS_DB $MODEL_DB $TRANSFORM_DB $TRANSACTIONAL_DB)

    for db_name in ${db_names[@]}; do table_names=$(hive -S -e "use $db_name; show tables;"); declare -a $table_names;
      for table_name in ${table_names[@]}; do row_count=$(hive -S -e "select count(*) from $db_name.$table_name"); echo "$db_name, $table_name, $row_count"
      done
    done
    log_wrapper_message "Ending running log-tables-row-count.sh file"

) >> /var/log/pdm/pdm_tables_row_count.log 2>&1