#!/bin/bash

set -Eeuo pipefail

cwa_metrics_collection_interval="$1"
cwa_namespace="$2"
cwa_log_group_name="$3"
cwa_bootstrap_loggrp_name="$5"
cwa_steps_loggrp_name="$6"
cwa_yarnspark_loggrp_name="$7"

export AWS_DEFAULT_REGION="${4}"

# Create config file required for CloudWatch Agent
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CWAGENTCONFIG
{
  "agent": {
    "metrics_collection_interval": ${cwa_metrics_collection_interval},
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "amazon-cloudwatch-agent.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "messages",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-secure",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-cloud-init-output.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/acm-cert-retriever.log",
            "log_group_name": "${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "acm-cert-retriever.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/nohup.log",
            "log_group_name": "${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "nohup.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/install-pycrypto.log",
            "log_group_name": "${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "install-pycrypto.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/install-requests.log",
            "log_group_name": "${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "install-requests.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/install-boto3.log",
            "log_group_name": "${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "install-boto3.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/hive-tables-creation.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "hive-tables-creation.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/create-hive-tables.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "create-hive-tables.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/generate-pdm-dataset.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "generate-pdm-dataset.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hadoop-yarn/containers/application_*/container_*/stdout**",
            "log_group_name": "${cwa_yarnspark_loggrp_name}",
            "log_stream_name": "spark-stdout.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hadoop-yarn/containers/application_*/container_*/stderr**",
            "log_group_name": "${cwa_yarnspark_loggrp_name}",
            "log_stream_name": "spark-stderror.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hadoop-yarn/yarn-yarn-nodemanager**.log",
            "log_group_name": "${cwa_yarnspark_loggrp_name}",
            "log_stream_name": "yarn_nodemanager.log",
            "timezone": "UTC"
          },        
          {
            "file_path": "/var/log/pdm/download_unzip_sql.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "download_unzip_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/download_sql.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "download_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/missing_model_sql.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "missing_model_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/model_sql.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "model_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/transform_sql.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "transform_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/source_sql.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "source_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/transactional_sql.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "transactional_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/views_sql.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "views_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/materialised_views_sql.log",
            "log_group_name": "${cwa_steps_loggrp_name}",
            "log_stream_name": "materialised_views_sql.log",
            "timezone": "UTC"
          }
        ]
      }
    },
    "log_stream_name": "${cwa_namespace}",
    "force_flush_interval" : 15
  }
}
CWAGENTCONFIG

# Download and install CloudWatch Agent
curl https://s3.${AWS_DEFAULT_REGION}.amazonaws.com/amazoncloudwatch-agent-${AWS_DEFAULT_REGION}/centos/amd64/latest/amazon-cloudwatch-agent.rpm -O
rpm -U ./amazon-cloudwatch-agent.rpm
# To maintain CIS compliance
usermod -s /sbin/nologin cwagent

start amazon-cloudwatch-agent
