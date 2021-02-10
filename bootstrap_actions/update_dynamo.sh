#!/bin/bash


STEP_DETAILS_DIR=/mnt/var/lib/info/steps/
CORRELATION_ID_FILE=/opt/emr/correlation_id.txt
RUN_ID=1
DATE=$(date '+%Y-%m-%d')
STATUS="In-Progress"
CURRENT_STEP=""

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


#keep reading each file until it says success or an additional file comes up
for i in $STEP_DEATILS_DIR*.json; do
  CURRENT_STEP=$(echo "$step_script_name" | sed 's:.*/::' | cut -f 1 -d '.')
  jq '.CurrentStep.S = "'$CURRENT_STEP'"'<<<$JSON_STRING
  state=$(jq -r '.state' $i)
  while [ "$state" != "COMPLETED" ]
  do
    jq '.CurrentStep.S = "'$CURRENT_STEP'"'<<<$JSON_STRING
    if [ "$state" == "FAILED" ]; then
      jq '.Status.S = "'$state'"'<<<$JSON_STRING
    fi
    aws dynamodb put-item  --table-name data_pipeline_metadata --item $JSON_STRING
    sleep 1
  done






response=`aws dynamodb get-item --table-name data_pipeline_metadata --key '{"Correlation_Id": {"S": "'$CORRELATION_ID'"}, "Run_Id": {"N": "1"}}'`

aws dynamodb get-item --table-name data_pipeline_metadata --key '{"Correlation_Id": {"S": "'$CORRELATION_ID'"}, "Run_Id": {"N": "1"},}'

#PUT STATUS OF PDM FOR CORRELATION_ID