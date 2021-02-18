#!/bin/bash

set -euo pipefail

(
# Import the logging functions
source /opt/emr/logging.sh
 # Import resume step function
    source /opt/emr/resume_step.sh
    resume_from_step

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
  step_script_name=$(jq -r '.args[0]' $i)
  step_name=$(echo "$step_script_name" | sed 's:.*/::' | cut -f 1 -d '.')
  gauge_name=runtime_step_$step_id$step_name
  end_time=$(jq -r '.endDateTime' $i);
  completion_ms=$(( $end_time - $start_time ));
  completion_min=$((completion_ms / 60000));
  state=$(jq -r '.state' $i);
  if [[ "$state" == "COMPLETED" ]]; then
     state=$((0))
  elif [[ "$state" == "FAILED" ]]; then
     state=$((1))
  elif [[ "$state" == "RUNNING" ]]; then
     state=$((2))
  elif [[ "$state" == "CANCELLED" ]]; then
     state=$((3))
  else
     state=$((4))
  fi
  gauge_name2=state_step_$step_id$step_name
  value_entry=$(jq -n --argjson value $completion_min '{value:$value}');
  jq --argjson val $completion_min '.gauges += {"'"$gauge_name"'":{"value":$val}}' $METRICS_FILE_PATH > "tmp" && sudo mv -f -b "tmp" $METRICS_FILE_PATH
  jq --argjson val2 $state '.gauges += {"'"$gauge_name2"'":{"value":$val2}}' $METRICS_FILE_PATH > "tmp" && sudo mv -f -b "tmp" $METRICS_FILE_PATH
  done

log_wrapper_message "Finished creating metrics file"

) >> /var/log/pdm/collect-metrics.log 2>&1
