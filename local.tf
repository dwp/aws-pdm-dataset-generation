locals {
  persistence_tag_value = {
    development = "Ignore"
    qa          = "Ignore"
    integration = "Ignore"
    preprod     = "Ignore"
    production  = "Ignore"
  }

  auto_shutdown_tag_value = {
    development = "False"
    qa          = "False"
    integration = "False"
    preprod     = "False"
    production  = "False"
  }

  overridden_tags = {
    Role         = "pdm_dataset_generation"
    Owner        = "aws-pdm-dataset-generation"
    Persistence  = local.persistence_tag_value[local.environment]
    AutoShutdown = local.auto_shutdown_tag_value[local.environment]
  }

  common_repo_tags = merge(module.dataworks_common.common_tags, local.overridden_tags)

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
  metastore_reader_secret_name    = "metadata-store-v2-adg-reader"
  env_certificate_bucket          = "dw-${local.environment}-public-certificates"
  mgt_certificate_bucket          = "dw-${local.management_account[local.environment]}-public-certificates"
  dks_endpoint                    = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]

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

  pdm_log_level = {
    development = "DEBUG"
    qa          = "DEBUG"
    integration = "DEBUG"
    preprod     = "INFO"
    production  = "INFO"
  }

  pdm_version = {
    development = "0.0.80"
    qa          = "0.0.80"
    integration = "0.0.80"
    preprod     = "0.0.80"
    production  = "0.0.79"
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
  no_proxy             = "169.254.169.254,${local.pdm_pushgateway_hostname},${join(",", formatlist("%s.%s", local.endpoint_services, local.amazon_region_domain))}"

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
    development = false
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
    development = "true"
    qa          = "true"
    integration = "true"
    preprod     = "true"
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
    preprod     = "12"
    production  = "12" # vCPU in the instance / 8
  }

  retry_max_attempts = {
    development = "10"
    qa          = "10"
    integration = "10"
    preprod     = "12"
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
    preprod     = "20"
    production  = "30"
  }

  source_processes = {
    development = "20"
    qa          = "20"
    integration = "10"
    preprod     = "20"
    production  = "30"
  }

  transactional_processes = {
    development = "20"
    qa          = "20"
    integration = "10"
    preprod     = "20"
    production  = "20"
  }

  transform_processes = {
    development = "20"
    qa          = "20"
    integration = "10"
    preprod     = "20"
    production  = "30"
  }

  views_processes = {
    development = "20"
    qa          = "20"
    integration = "10"
    preprod     = "20"
    production  = "30"
  }

  views_tables_processes = {
    development = "20"
    qa          = "20"
    integration = "10"
    preprod     = "20"
    production  = "30"
  }

  pdm_alerts = {
    development = false
    qa          = false
    integration = false
    preprod     = true
    production  = true
  }
# default 100, set to 10% hive.tez.container.size
  tez_runtime_unordered_output_buffer_size_mb = {
    development = "268"
    qa          = "268"
    integration = "268"
    preprod     = "2148"
    production  = "2148"
  }

  # 0.4 of hive_tez_container_size
  tez_runtime_io_sort_mb = {
    development = "1075"
    qa          = "1075"
    integration = "1075"
    preprod     = "1075"
    production  = "1075"
  }

  tez_grouping_min_size = {
    development = "1342177"
    qa          = "1342177"
    integration = "1342177"
    preprod     = "52428800"
    production  = "52428800"
  }

  tez_grouping_max_size = {
    development = "268435456"
    qa          = "268435456"
    integration = "268435456"
    preprod     = "1073741824"
    production  = "1073741824"
  }

  tez_am_resource_memory_mb = {
    development = "1024"
    qa          = "1024"
    integration = "1024"
    preprod     = "18560"
    production  = "18560"
  }

  # 0.8 of hive_tez_container_size
  tez_task_resource_memory_mb = {
    development = "1024"
    qa          = "1024"
    integration = "1024"
    preprod     = "1024"
    production  = "1024"
  }

  # 0.8 of tez_am_resource_memory_mb
  tez_am_launch_cmd_opts = {
    development = "-Xmx819m"
    qa          = "-Xmx819m"
    integration = "-Xmx819m"
    preprod     = "-Xmx14848m "
    production  = "-Xmx14848m"
  }

  hive_tez_sessions_per_queue = {
    development = "10"
    qa          = "10"
    integration = "10"
    preprod     = "35"
    production  = "35"
  }

  map_reduce_vcores_per_node = {
    development = "5"
    qa          = "5"
    integration = "5"
    preprod     = "15"
    production  = "15"
  }

  map_reduce_vcores_per_task = {
    development = "1"
    qa          = "1"
    integration = "1"
    preprod     = "5"
    production  = "5"
  }

  hive_tez_container_size = {
    development = "2688"
    qa          = "2688"
    integration = "2688"
    preprod     = "18560"
    production  = "18560"
  }

  # 0.33 of hive_tez_container_size
  hive_auto_convert_join_noconditionaltask_size = {
    development = "896"
    qa          = "896"
    integration = "896"
    preprod     = "896"
    production  = "896"
  }

  hive_bytes_per_reducer = {
    development = "13421728"
    qa          = "13421728"
    integration = "13421728"
    preprod     = "13421728"
    production  = "13421728"
  }

  yarn_mapreduce_am_resourcemb = {
    development = "6144"
    qa          = "6144"
    integration = "6144"
    preprod     = "23808"
    production  = "23808"
  }

  hive_max_reducers = {
    development = "1099"
    qa          = "1099"
    integration = "1099"
    preprod     = "2000"
    production  = "2000"
  }

  hive_blobstore_opts_enabled = {
    development = true
    qa          = true
    integration = true
    preprod     = false
    production  = true
  }

  hive_blobstore_as_scratchdir = {
    development = true
    qa          = true
    integration = true
    preprod     = false
    production  = true
  }

  emr_capacity_reservation_preference = local.use_capacity_reservation[local.environment] == true ? "open" : "none"

  emr_capacity_reservation_usage_strategy = local.use_capacity_reservation[local.environment] == true ? "use-capacity-reservations-first" : ""

  use_capacity_reservation = {
    development = false
    qa          = false
    integration = false
    preprod     = false
    production  = true
  }

  emr_subnet_non_capacity_reserved_environments = data.terraform_remote_state.common.outputs.aws_ec2_non_capacity_reservation_region

  data_classification = {
    config_bucket  = data.terraform_remote_state.common.outputs.config_bucket
    config_prefix  = data.terraform_remote_state.aws_s3_object_tagger.outputs.pdm_object_tagger_data_classification.config_prefix
    data_s3_prefix = data.terraform_remote_state.aws_s3_object_tagger.outputs.pdm_object_tagger_data_classification.data_s3_prefix
  }

  pdm_pushgateway_hostname = "${aws_service_discovery_service.pdm_services.name}.${aws_service_discovery_private_dns_namespace.pdm_services.name}"

  hive_scratch_dir_patch_files_s3_prefix = "non_source_control_large_files/emr_patches/hive_scratch_dir/"
}
