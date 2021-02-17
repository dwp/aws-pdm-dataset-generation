#!/bin/bash

function check_retry() {
    if [[ -f /opt/emr/step_to_start_from.txt ]]; then
        log_wrapper_message "Previous step file found"
        STEP=`cat $STEP_TO_START_FROM_FILE`
        CURRENT_FILE_NAME=`basename "$0"`
        FILE_NAME_NO_EXT="${CURRENT_FILE_NAME%.*}"

        if [[ $STEP != $FILE_NAME_NO_EXT]]; then
            log_wrapper_message "Current step name $FILE_NAME_NO_EXT doesn't match previously failed step $STEP, exiting"
            exit 0
        else
            log_wrapper_message "Current step name $FILE_NAME_NO_EXT matches previously failed step $STEP, deleting file"
            rm -f $STEP_TO_START_FROM_FILE
        fi
    fi
}