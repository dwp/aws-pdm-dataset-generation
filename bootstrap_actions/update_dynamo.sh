#!/bin/bash

STEP_DETAILS_DIR=/mnt/var/lib/info/steps/
CORRELATION_ID_FILE=/opt/emr/correlation_id.txt
RUN_ID=1
DATE=$(date '+%Y-%m-%d')
STATUS="In-Progress"
CURRENT_STEP=""
DATA_PRODUCT="PDM"

while [ ! -f $CORRELATION_ID_FILE ]
do
  sleep 5
done

if [[ -f "$CORRELATION_ID_FILE" ]]; then
    echo "$CORRELATION_ID_FILE exists."
    CORRELATION_ID=`cat $CORRELATION_ID_FILE`
fi

JSON_STRING=`cat dynamo_schema.json`
jq '.Correlation_Id.S = "'$CORRELATION_ID'"'<<<$JSON_STRING
jq '.Date.S = "'$DATE'"'<<<$JSON_STRING
jq '.Run_Id.N = "'$RUN_ID'"'<<<$JSON_STRING
jq '.Status.S = "'$STATUS'"'<<<$JSON_STRING

#Check if row for this correlation ID already exists - in which case we need to increment it rather than create a new row
response=`aws dynamodb get-item --table-name data_pipeline_metadata --key '{"Correlation_Id": {"S": "'$CORRELATION_ID'"}, "DataProduct": {"S": "'$DATA_PRODUCT'"}}'`
if [[ -z $response ]]; then
  aws dynamodb put-item  --table-name data_pipeline_metadata --item $JSON_STRING
else
  RUN_ID=`echo $response | jq -r .'Item.Run_Id.N'`
  RUN_ID=$((RUN_ID+1))
  jq '.Run_Id.N = "'$RUN_ID'"'<<<$JSON_STRING
  aws dynamodb put-item  --table-name data_pipeline_metadata --item $JSON_STRING
fi




keep_looking=true

#endless loop to keep updating dynamo every 30s with current step info
while [ $keep_looking ]; do
  for step_file in $STEP_DEATILS_DIR*.json; do
    state=""
    while [[ "$state" != "COMPLETED" || "$state" != "FAILED" ]]; do
      CURRENT_STEP=$(echo "$step_file" | sed 's:.*/::' | cut -f 1 -d '.')
      state=$(jq -r '.state' $step_file)
      jq '.CurrentStep.S = "'$CURRENT_STEP'"'<<<$JSON_STRING
      if [[ "$state" == "FAILED" ]]; then
        jq '.Status.S = "'$state'"'<<<$JSON_STRING
      fi
      aws dynamodb put-item  --table-name data_pipeline_metadata --item $JSON_STRING
      sleep 30

    done
  done
done


