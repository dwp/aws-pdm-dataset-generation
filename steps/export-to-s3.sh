#!/bin/bash

while true
do
    if [ -f /var/log/hive/metrics.json ]
    then
        aws s3 cp /var/log/hive/metrics.json "${pdm_metrics_path}"
    fi
    sleep 5
done
