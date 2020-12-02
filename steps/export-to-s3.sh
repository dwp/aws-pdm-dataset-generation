#!/bin/bash

while true
do
    if [ -f /var/log/hive/metrics.json ]
    then
        aws s3 cp /var/log/hive/metrics.json "${pdm_metrics_path}"
    fi

    if [ -f /var/log/pdm/metrics-second.json ]
    then
        aws s3 cp /var/log/pdm/metrics-second.json "${pdm_metrics_second_path}"
    fi
    sleep 5
done
