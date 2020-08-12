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
  common_tags = {
    Environment  = local.environment
    Application  = local.emr_cluster_name
    CreatedBy    = "terraform"
    Owner        = "dataworks platform"
    Persistence  = "Ignore"
    AutoShutdown = "False"
  }
  env_certificate_bucket = "dw-${local.environment}-public-certificates"
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
    development = "0.0.7"
    qa          = "0.0.7"
    integration = "0.0.7"
    preprod     = "0.0.7"
    production  = "0.0.7"
  }

  amazon_region_domain = "${data.aws_region.current.name}.amazonaws.com"
  endpoint_services    = ["autoscaling", "dynamodb", "ec2", "ec2messages", "ecr.dkr", "glue", "kms", "logs", "monitoring", ".s3", "s3", "secretsmanager", "sns", "sqs", "ssm", "ssmmessages"]
  no_proxy             = "169.254.169.254,${join(",", formatlist("%s.%s", local.endpoint_services, local.amazon_region_domain))},${data.terraform_remote_state.metrics_infrastructure.outputs.adg_pushgateway_hostname}"

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
  cw_agent_metrics_collection_interval = 60

  s3_log_prefix            = "emr/pdm_dataset_generator"
  emrfs_metadata_tablename = "pdm_Dataset_Generation_Metadata"

  source_db           = "uc_pdm_source"
  transform_db        = "uc_pdm_transform"
  model_db            = "uc_pdm_model"
  transactional_db    = "uc_pdm_transactional"
  uc_db               = "uc"
  data_location       = format("s3://%s/%s", data.terraform_remote_state.adg.outputs.published_bucket.id, "analytical_dataset")
  dictionary_location = format("s3://%s/%s", data.terraform_remote_state.adg.outputs.published_bucket.id, "common-model-inputs")
  serde               = "org.openx.data.jsonserde.JsonSerDe"
}

