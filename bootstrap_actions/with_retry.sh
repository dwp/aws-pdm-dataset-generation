#!/usr/bin/bash


source /opt/emr/retry.sh

SECONDS=0
retry::with_retries $@
DURATION=$SECONDS

SCRIPT_NAME=`echo $@ | sed 's/.*scripts//'`
log_wrapper_message "$SCRIPT_NAME took $SECONDS seconds to process"
