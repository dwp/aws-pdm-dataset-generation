#!/bin/bash

set -Eeuo pipefail

cwa_metrics_collection_interval="$1"
cwa_namespace="$2"
cwa_log_group_name="$3"
cwa_bootstrap_loggrp_name="$5"
cwa_steps_loggrp_name="$6"
cwa_yarnspark_loggrp_name="$7"
cwa_hive_loggrp_name="$8"
cwa_tests_loggrp_name="$9"


export AWS_DEFAULT_REGION="$${4}"

# Create config file required for CloudWatch Agent
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<CWAGENTCONFIG
{
  "agent": {
    "metrics_collection_interval": $${cwa_metrics_collection_interval},
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
            "log_group_name": "$${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-amazon-cloudwatch-agent.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "$${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-messages",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "$${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-secure",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/cloud-init-output.log",
            "log_group_name": "$${cwa_log_group_name}",
            "log_stream_name": "{instance_id}-cloud-init-output.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/acm-cert-retriever.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-acm-cert-retriever.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/download_scripts.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-download_scripts.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/installer.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-installer.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/emr_setup.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-emr_setup.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/update_dynamo_sh.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-update_dynamo_sh.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/download_sql.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-download_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/application_metrics.log",
            "log_group_name": "$${cwa_bootstrap_loggrp_name}",
            "log_stream_name": "{instance_id}-application_metrics.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hadoop-yarn/yarn-yarn-nodemanager**.log",
            "log_group_name": "$${cwa_yarnspark_loggrp_name}",
            "log_stream_name": "{instance_id}-yarn_nodemanager.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hive/hive-server2.log",
            "log_group_name": "$${cwa_hive_loggrp_name}",
            "log_stream_name": "{instance_id}-hive_server2.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hive/user/hive/hive.log",
            "log_group_name": "$${cwa_hive_loggrp_name}",
            "log_stream_name": "{instance_id}-query_related_hive_user.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hive/user/hadoop/hive.log",
            "log_group_name": "$${cwa_hive_loggrp_name}",
            "log_stream_name": "{instance_id}-query_related_hadoop_user.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/hive/user/root/hive.log",
            "log_group_name": "$${cwa_hive_loggrp_name}",
            "log_stream_name": "{instance_id}-query_related_root_user.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/download_unzip_sql.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-download_unzip_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/missing_model_sql.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-missing_model_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/model_sql.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-model_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/metrics-setup.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-metrics-setup.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/transform_sql.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-transform_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/source_sql.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-source_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/transactional_sql.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-transactional_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/views_sql.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-views_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/clean_dictionary_data.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-clean_dictionary_data.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/create_databases_sql.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-create_databases_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/create_views_tables.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-create_views_tables.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/initial_transactional_load_sql.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-initial_transactional_load_sql.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/create-hive-dynamo-table.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-create-hive-dynamo-table.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/collect-metrics.log",
            "log_group_name": "$${cwa_steps_loggrp_name}",
            "log_stream_name": "{instance_id}-collect-metrics.log",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/pdm/e2e.log",
            "log_group_name": "$${cwa_tests_loggrp_name}",
            "log_stream_name": "{instance_id}-e2e.log",
            "timezone": "UTC"
          }
        ]
      }
    },
    "log_stream_name": "$${cwa_namespace}",
    "force_flush_interval" : 15
  }
}
CWAGENTCONFIG

%{ if emr_release == "5.29.0" ~}
# Download and install CloudWatch Agent
curl https://s3.$${AWS_DEFAULT_REGION}.amazonaws.com/amazoncloudwatch-agent-$${AWS_DEFAULT_REGION}/centos/amd64/latest/amazon-cloudwatch-agent.rpm -O
rpm -U ./amazon-cloudwatch-agent.rpm
# To maintain CIS compliance
usermod -s /sbin/nologin cwagent

start amazon-cloudwatch-agent
%{ else ~}
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
sudo systemctl start amazon-cloudwatch-agent
%{ endif ~}
