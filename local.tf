locals {
  emr_cluster_name                = "aws-pdm-dataset-generator"
  master_instance_type            = "m5.2xlarge"
  core_instance_type              = "m5.2xlarge"
  core_instance_count             = 1
  task_instance_type              = "m5.2xlarge"
  ebs_root_volume_size            = 100
  ebs_config_size                 = 250
  ebs_config_type                 = "gp2"
  ebs_config_volumes_per_instance = 1
  autoscaling_min_capacity        = 0
  autoscaling_max_capacity        = 5
  dks_port                        = 8443
  dynamo_meta_name                = "PDMGen-metadata"
  secret_name                     = "/concourse/dataworks/pdm"
  data_pipeline_metadata          = data.terraform_remote_state.internal_compute.outputs.data_pipeline_metadata_dynamo.name
  hive_metastore_location         = "data/uc"
  hive_data_location              = "data"
  common_tags = {
    Environment  = local.environment
    Application  = local.emr_cluster_name
    CreatedBy    = "terraform"
    Owner        = "dataworks platform"
    Persistence  = "Ignore"
    AutoShutdown = "False"
  }
  env_certificate_bucket = "dw-${local.environment}-public-certificates"
  mgt_certificate_bucket = "dw-${local.management_account[local.environment]}-public-certificates"
  dks_endpoint           = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]

  crypto_workspace = {
    management-dev = "management-dev"
    management     = "management"
  }

  management_account = {
    development = "management-dev"
    qa          = "management-dev"
    integration = "management-dev"
    preprod     = "management"
    production  = "management"
  }

  management_workspace = {
    management-dev = "default"
    management     = "management"
  }

  root_dns_name = {
    development = "dev.dataworks.dwp.gov.uk"
    qa          = "qa.dataworks.dwp.gov.uk"
    integration = "int.dataworks.dwp.gov.uk"
    preprod     = "pre.dataworks.dwp.gov.uk"
    production  = "dataworks.dwp.gov.uk"
  }

  pdm_emr_lambda_schedule = {
    development = "1 0 * * ? 2025"
    qa          = "1 0 * * ? 2025"
    integration = "15 17 1 Jul ? 2025" # trigger one off temp increase for DW-4437 testing
    preprod     = "1 0 * * ? 2025"
    production  = "1 0 * * ? 2025"
  }

  pdm_log_level = {
    development = "DEBUG"
    qa          = "DEBUG"
    integration = "DEBUG"
    preprod     = "INFO"
    production  = "INFO"
  }

  pdm_version = {
    development = "0.0.37"
    qa          = "0.0.37"
    integration = "0.0.37"
    preprod     = "0.0.37"
    production  = "0.0.37"
  }

  pdm_max_retry_count = {
    development = "0"
    qa          = "0"
    integration = "0"
    preprod     = "0"
    production  = "2"
  }

  amazon_region_domain = "${data.aws_region.current.name}.amazonaws.com"
  endpoint_services    = ["dynamodb", "ec2", "ec2messages", "glue", "kms", "logs", "monitoring", ".s3", "s3", "secretsmanager", "ssm", "ssmmessages"]
  no_proxy             = "169.254.169.254,${join(",", formatlist("%s.%s", local.endpoint_services, local.amazon_region_domain))}"

  ebs_emrfs_em = {
    EncryptionConfiguration = {
      EnableInTransitEncryption = false
      EnableAtRestEncryption    = true
      AtRestEncryptionConfiguration = {

        S3EncryptionConfiguration = {
          EncryptionMode             = "CSE-Custom"
          S3Object                   = "s3://${data.terraform_remote_state.management_artefact.outputs.artefact_bucket.id}/emr-encryption-materials-provider/encryption-materials-provider-all.jar"
          EncryptionKeyProviderClass = "uk.gov.dwp.dataworks.dks.encryptionmaterialsprovider.DKSEncryptionMaterialsProvider"
        }
        LocalDiskEncryptionConfiguration = {
          EnableEbsEncryption       = true
          EncryptionKeyProviderType = "AwsKms"
          AwsKmsKey                 = aws_kms_key.pdm_ebs_cmk.arn
        }
      }
    }
  }

  keep_cluster_alive = {
    development = true
    qa          = false
    integration = false
    preprod     = false
    production  = false
  }

  cw_agent_namespace                   = "/app/pdm_dataset_generator"
  cw_agent_log_group_name              = "/app/pdm_dataset_generator"
  cw_agent_bootstrap_loggrp_name       = "/app/pdm_dataset_generator/bootstrap_actions"
  cw_agent_steps_loggrp_name           = "/app/pdm_dataset_generator/step_logs"
  cw_agent_yarnspark_loggrp_name       = "/app/pdm_dataset_generator/yarn-spark_logs"
  cw_agent_hive_loggrp_name            = "/app/pdm_dataset_generator/hive-logs"
  cw_agent_tests_loggrp_name           = "/app/pdm_dataset_generator/tests_logs"
  cw_agent_metrics_collection_interval = 60

  s3_log_prefix = "emr/pdm_dataset_generator"

  source_db           = "uc_pdm_source"
  transform_db        = "uc_pdm_transform"
  model_db            = "uc_pdm_model"
  transactional_db    = "uc_pdm_transactional"
  uc_db               = "uc"
  data_location       = format("s3://%s", data.terraform_remote_state.common.outputs.published_bucket.id)
  dictionary_location = format("s3://%s/%s", data.terraform_remote_state.common.outputs.published_bucket.id, "common-model-inputs")
  views_db            = "uc_views_tables"
  views_tables_db     = "uc"
  serde               = "org.openx.data.jsonserde.JsonSerDe"

  initial_transactional_load = {
    development = "false"
    qa          = "false"
    integration = "false"
    preprod     = "false"
    production  = "false"
  }

  step_fail_action = {
    development = "CONTINUE"
    qa          = "TERMINATE_CLUSTER"
    integration = "TERMINATE_CLUSTER"
    preprod     = "TERMINATE_CLUSTER"
    production  = "TERMINATE_CLUSTER"
  }

  hive_compaction_threads = {
    development = "1"
    qa          = "1"
    integration = "1"
    preprod     = "1"
    production  = "12" # vCPU in the instance / 8
  }

  retry_max_attempts = {
    development = "10"
    qa          = "10"
    integration = "10"
    preprod     = "10"
    production  = "12"
  }

  retry_attempt_delay_seconds = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "5"
    production  = "5"
  }

  retry_enabled = {
    development = "true"
    qa          = "true"
    integration = "true"
    preprod     = "true"
    production  = "true"
  }

  model_processes = {
    development = "20"
    qa          = "20"
    integration = "10"
    preprod     = "10"
    production  = "20"
  }

  source_processes = {
    development = "20"
    qa          = "20"
    integration = "10"
    preprod     = "10"
    production  = "20"
  }

  transactional_processes = {
    development = "20"
    qa          = "20"
    integration = "10"
    preprod     = "10"
    production  = "20"
  }

  transform_processes = {
    development = "20"
    qa          = "20"
    integration = "10"
    preprod     = "10"
    production  = "20"
  }

  views_processes = {
    development = "20"
    qa          = "20"
    integration = "10"
    preprod     = "10"
    production  = "20"
  }

  views_tables_processes = {
    development = "20"
    qa          = "20"
    integration = "10"
    preprod     = "10"
    production  = "20"
  }

  pdm_alerts = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  hive_tez_container_size = {
    development = "4096"
    qa          = "4096"
    integration = "2688"
    preprod     = "2688"
    production  = "4096"
  }

  # 0.8 of hive_tez_container_size
  hive_tez_java_opts = {
    development = "-Xmx3276m"
    qa          = "-Xmx3276m"
    integration = "-Xmx2150m"
    preprod     = "-Xmx2150m"
    production  = "-Xmx3276m"
  }

  # 0.33 of hive_tez_container_size
  hive_auto_convert_join_noconditionaltask_size = {
    development = "1351"
    qa          = "1351"
    integration = "896"
    preprod     = "896"
    production  = "1351"
  }

  tez_am_resource_memory_mb = {
    development = "1024"
    qa          = "1024"
    integration = "1024"
    preprod     = "1024"
    production  = "1024"
  }

  tez_grouping_min_size = {
    development = "52428800"
    qa          = "52428800"
    integration = "1342177"
    preprod     = "1342177"
    production  = "52428800"
  }

  tez_grouping_max_size = {
    development = "1073741824"
    qa          = "1073741824"
    integration = "268435456"
    preprod     = "268435456"
    production  = "1073741824"
  }

  # 0.8 of hive_tez_container_size
  tez_task_resource_memory_mb = {
    development = "3276"
    qa          = "3276"
    integration = "1024"
    preprod     = "1024"
    production  = "3276"
  }

  # 0.8 of tez_am_resource_memory_mb
  tez_am_launch_cmd_opts = {
    development = "-Xmx6556m"
    qa          = "-Xmx6556m"
    integration = "-Xmx819m"
    preprod     = "-Xmx819m"
    production  = "-Xmx6556m"
  }

  tez_runtime_unordered_output_buffer_size_mb = {
    development = "2148"
    qa          = "2148"
    integration = "268"
    preprod     = "268"
    production  = "2148"
  }

  # 0.4 of hive_tez_container_size
  tez_runtime_io_sort_mb = {
    development = "1638"
    qa          = "1638"
    integration = "1075"
    preprod     = "1075"
    production  = "1638"
  }

  // This value should be the same as yarn.scheduler.maximum-allocation-mb
  llap_daemon_yarn_container_mb = {
    development = "385024"
    qa          = "385024"
    integration = "57344"
    preprod     = "57344"
    production  = "385024"
  }

  llap_number_of_instances = {
    development = "15"
    qa          = "15"
    integration = "5"
    preprod     = "5"
    production  = "15"
  }

  map_reduce_vcores_per_node = {
    development = "15"
    qa          = "15"
    integration = "10"
    preprod     = "10"
    production  = "15"
  }

  map_reduce_vcores_per_task = {
    development = "5"
    qa          = "5"
    integration = "2"
    preprod     = "2"
    production  = "5"
  }

  hive_max_reducers = {
    development = "3000"
    qa          = "3000"
    integration = "1099"
    preprod     = "1099"
    production  = "3000"
  }

  hive_tez_sessions_per_queue = {
    development = "20"
    qa          = "20"
    integration = "10"
    preprod     = "10"
    production  = "20"
  }

  hive_bytes_per_reducer = {
    development = "13421728"
    qa          = "13421728"
    integration = "13421728"
    preprod     = "13421728"
    production  = "13421728"
  }
}
