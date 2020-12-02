#!/bin/bash

(
# Import the logging functions
source /opt/emr/logging.sh

function log_wrapper_message() {
    log_pdm_message "$1" "collect-metrics.sh" "$$" "Running as: $USER"
}

log_wrapper_message "Creating metrics file"

METRICS_FILE_PATH=/var/log/hive/metrics.json
STEP_DETAILS_DIR=/mnt/var/lib/info/steps/

cd $STEP_DETAILS_DIR

for i in $STEP_DEATILS_DIR*.json; do
  start_time=$(jq -r '.startDateTime' $i);
  step_id=$(jq -r '.id' $i)
  gauge_name=completion_min_step_$step_id
  end_time=$(jq -r '.endDateTime' $i);
  completion_ms=$(( $end_time - $start_time ));
  completion_min=$((completion_ms / 60000));
  value_entry=$(jq -n --argjson value $completion_min '{value:$value}');
  jq --argjson val $completion_min '.gauges += {"'"$gauge_name"'":{"value":$val}}' $METRICS_FILE_PATH > "tmp" && mv -f "tmp" $METRICS_FILE_PATH
  done

log_wrapper_message "Finished creating metrics file"

) >> /var/log/pdm/collect-metrics.log 2>&1
