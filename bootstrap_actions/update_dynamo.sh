#!/bin/bash
(
    source /opt/emr/logging.sh

    function log_wrapper_message() {
        log_pdm_message "$${1}" "update_dynamo.sh" "$${PID}" "$${@:2}" "Running as: ,$USER"
    }

  log_wrapper_message "Start running update_dynamo.s Shell"

  STEP_DETAILS_DIR=/mnt/var/lib/info/steps
  CORRELATION_ID_FILE=/opt/emr/correlation_id.txt
  RUN_ID=1
  DATE=$(date '+%Y-%m-%d')
  STATUS="In-Progress"
  CURRENT_STEP=""
  DATA_PRODUCT="PDM"

  FINAL_STEP_NAME="collect-metrics"

  while [ ! -f $CORRELATION_ID_FILE ]
  do
    sleep 5
  done

  if [[ -f "$CORRELATION_ID_FILE" ]]; then
      CORRELATION_ID=`cat $CORRELATION_ID_FILE`
  fi

  while [ ! -f $STEP_DEATILS_DIR/*.json ]
  do
    sleep 5
  done

  JSON_STRING=`cat /opt/emr/dynamo_schema.json`
  JSON_STRING=`jq '.Correlation_Id.S = "'$CORRELATION_ID'"'<<<$JSON_STRING`
  JSON_STRING=`jq '.Date.S = "'$DATE'"'<<<$JSON_STRING`
  JSON_STRING=`jq '.Run_Id.N = "'$RUN_ID'"'<<<$JSON_STRING`
  JSON_STRING=`jq '.Status.S = "'$STATUS'"'<<<$JSON_STRING`

  #Check if row for this correlation ID already exists - in which case we need to increment the Run_Id
  response=`aws dynamodb get-item --table-name ${dynamodb_table_name} --key '{"Correlation_Id": {"S": "'$CORRELATION_ID'"}, "DataProduct": {"S": "'$DATA_PRODUCT'"}}'`
  if [[ -z $response ]]; then
    aws dynamodb put-item  --table-name ${dynamodb_table_name} --item "$JSON_STRING"
  else
    RUN_ID=`echo $response | jq -r .'Item.Run_Id.N'`
    RUN_ID=$((RUN_ID+1))
    JSON_STRING=`jq '.Run_Id.N = "'$RUN_ID'"'<<<$JSON_STRING`
    aws dynamodb put-item  --table-name ${dynamodb_table_name} --item "$JSON_STRING"
  fi
  log_wrapper_message "Updating DynamoDB with CORRELATION_ID: $CORRELATION_ID and RUN_ID: $RUN_ID"

  keep_looking=true
  PREVIOUS_STEP=""
  PREVIOUS_STATE=""
  #endless loop to keep updating dynamo every 30s with current step info
  cd $STEP_DETAILS_DIR
  while [ $keep_looking ]; do
    for i in $STEP_DETAILS_DIR/*.json; do
      state=""
      while [[ "$state" != "COMPLETED" ]]; do
        step_script_name=$(jq -r '.args[0]' $i)
        CURRENT_STEP=$(echo "$step_script_name" | sed 's:.*/::' | cut -f 1 -d '.')
        state=$(jq -r '.state' $i)
        JSON_STRING=`jq '.CurrentStep.S = "'$CURRENT_STEP'"'<<<$JSON_STRING`
        if [[ "$state" == "FAILED" ]]; then
          JSON_STRING=`jq '.Status.S = "'$state'"'<<<$JSON_STRING`
        fi
        if [[ "$step_script_name" == "$FINAL_STEP_NAME" ]] && [[ "$state" == "COMPLETED" ]]; then
          JSON_STRING=`jq '.Status.S = "'$state'"'<<<$JSON_STRING`
          keep_looking=false
        fi
        if [[ $PREVIOUS_STATE != $state ]] && [[ $PREVIOUS_STEP != $CURRENT_STEP ]]; then
          aws dynamodb put-item  --table-name ${dynamodb_table_name} --item "$JSON_STRING"
          log_wrapper_message "Updating DynamoDB with step: $CURRENT_STEP"
        else
          sleep 30
        fi
        PREVIOUS_STATE=$state
        PREVIOUS_STEP=$CURRENT_STEP
      done
    done
  done

) >> /var/log/pdm/update_dynamo_sh.log 2>&1