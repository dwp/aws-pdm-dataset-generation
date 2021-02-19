#!/usr/bin/bash

source /opt/emr/retry.sh

retry::with_retries $@
