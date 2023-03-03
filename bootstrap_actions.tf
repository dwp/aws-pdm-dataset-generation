resource "aws_s3_bucket_object" "emr_setup_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/emr-setup.sh"
  content = templatefile("${path.module}/bootstrap_actions/emr-setup.sh",
    {
      PDM_LOG_LEVEL                   = local.pdm_log_level[local.environment]
      RESUME_STEP_SHELL               = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.resume_step_script.key)
      S3_RETRY_UTILITY                = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.retry_utility.key)
      S3_RETRY_SCRIPT                 = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.retry_script.key)
      aws_default_region              = "eu-west-2"
      full_proxy                      = data.terraform_remote_state.internal_compute.outputs.internet_proxy.url
      full_no_proxy                   = local.no_proxy
      acm_cert_arn                    = aws_acm_certificate.pdm-dataset-generator.arn
      private_key_alias               = "private_key"
      truststore_aliases              = join(",", var.truststore_aliases)
      truststore_certs                = "s3://${local.env_certificate_bucket}/ca_certificates/dataworks/dataworks_root_ca.pem,s3://${data.terraform_remote_state.mgmt_ca.outputs.public_cert_bucket.id}/ca_certificates/dataworks/dataworks_root_ca.pem"
      dks_endpoint                    = data.terraform_remote_state.crypto.outputs.dks_endpoint[local.environment]
      cwa_metrics_collection_interval = local.cw_agent_metrics_collection_interval
      cwa_namespace                   = local.cw_agent_namespace
      cwa_log_group_name              = aws_cloudwatch_log_group.pdm_dataset_generator.name
      S3_CLOUDWATCH_SHELL             = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.cloudwatch_sh.key)
      cwa_bootstrap_loggrp_name       = aws_cloudwatch_log_group.pdm_cw_bootstrap_loggroup.name
      cwa_steps_loggrp_name           = aws_cloudwatch_log_group.pdm_cw_steps_loggroup.name
      cwa_tests_loggrp_name           = aws_cloudwatch_log_group.pdm_cw_tests_loggroup.name
      cwa_yarnspark_loggrp_name       = aws_cloudwatch_log_group.pdm_cw_yarnspark_loggroup.name
      cwa_hive_loggrp_name            = aws_cloudwatch_log_group.pdm_cw_hive_loggroup.name
      name                            = local.emr_cluster_name
      update_dynamo_sh                = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.update_dynamo_sh.key)
      dynamo_schema_json              = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.dynamo_json_file.key)
  })
  tags = {
    Name = "emr_setup_sh"
  }
}

resource "aws_s3_bucket_object" "ssm_script" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "component/pdm-dataset-generation/start_ssm.sh"
  content = file("${path.module}/bootstrap_actions/start_ssm.sh")
  tags = {
    Name = "ssm_script"
  }
}

resource "aws_s3_bucket_object" "installer_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/installer.sh"
  content = templatefile("${path.module}/bootstrap_actions/installer.sh",
    {
      full_proxy    = data.terraform_remote_state.internal_compute.outputs.internet_proxy.url
      full_no_proxy = local.no_proxy
    }
  )
  tags = {
    Name = "installer_sh"
  }
}

resource "aws_s3_bucket_object" "status_metrics_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/status_metrics.sh"
  content = templatefile("${path.module}/bootstrap_actions/status_metrics.sh",
    {
      pdm_pushgateway_hostname = local.pdm_pushgateway_hostname
    }
  )
  tags = {
    Name = "status_metrics_sh"
  }
}

resource "aws_s3_bucket_object" "retry_utility" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/retry.sh"
  content = templatefile("${path.module}/bootstrap_actions/retry.sh",
    {
      retry_max_attempts          = local.retry_max_attempts[local.environment]
      retry_attempt_delay_seconds = local.retry_attempt_delay_seconds[local.environment]
      retry_enabled               = local.retry_enabled[local.environment]
    }
  )
  tags = {
    Name = "retry_utility"
  }
}

resource "aws_s3_bucket_object" "retry_script" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/with_retry.sh"
  content = templatefile("${path.module}/bootstrap_actions/with_retry.sh",
    {
    }
  )
  tags = {
    Name = "retry_script"
  }
}

resource "aws_s3_bucket_object" "logging_script" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "component/pdm-dataset-generation/logging.sh"
  content = file("${path.module}/bootstrap_actions/logging.sh")
  tags = {
    Name = "logging_script"
  }
}

resource "aws_s3_bucket_object" "resume_step_script" {
  bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
  key     = "component/pdm-dataset-generation/resume_step.sh"
  content = file("${path.module}/bootstrap_actions/resume_step.sh")
  tags = {
    Name = "resume_step_script"
  }
}

resource "aws_cloudwatch_log_group" "pdm_dataset_generator" {
  name              = local.cw_agent_log_group_name
  retention_in_days = 180
  tags = {
    Name = "pdm_dataset_generator"
  }
}

resource "aws_cloudwatch_log_group" "pdm_cw_bootstrap_loggroup" {
  name              = local.cw_agent_bootstrap_loggrp_name
  retention_in_days = 180
  tags = {
    Name = "pdm_cw_bootstrap_loggroup"
  }
}

resource "aws_cloudwatch_log_group" "pdm_cw_steps_loggroup" {
  name              = local.cw_agent_steps_loggrp_name
  retention_in_days = 180
  tags = {
    Name = "pdm_cw_steps_loggroup"
  }
}

resource "aws_cloudwatch_log_group" "pdm_cw_yarnspark_loggroup" {
  name              = local.cw_agent_yarnspark_loggrp_name
  retention_in_days = 180
  tags = {
    Name = "pdm_cw_yarnspark_loggroup"
  }
}

resource "aws_cloudwatch_log_group" "pdm_cw_hive_loggroup" {
  name              = local.cw_agent_hive_loggrp_name
  retention_in_days = 180
  tags = {
    Name = "pdm_cw_hive_loggroup"
  }
}

resource "aws_cloudwatch_log_group" "pdm_cw_tests_loggroup" {
  name              = local.cw_agent_tests_loggrp_name
  retention_in_days = 180
  tags = {
    Name = "pdm_cw_tests_loggroup"
  }
}

resource "aws_s3_bucket_object" "cloudwatch_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/cloudwatch.sh"
  content = templatefile("${path.module}/bootstrap_actions/cloudwatch.sh",
    {
      emr_release = var.emr_release[local.environment]
    }
  )
  tags = {
    Name = "cloudwatch_sh"
  }
}

resource "aws_s3_bucket_object" "download_scripts_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/download_scripts.sh"
  content = templatefile("${path.module}/bootstrap_actions/download_scripts.sh",
    {
      scripts_location = format(
        "s3://%s/%s",
        data.terraform_remote_state.common.outputs.config_bucket.id,
        "component/pdm-dataset-generation"
      )
      metrics_scripts_location = format(
        "s3://%s/%s",
        data.terraform_remote_state.common.outputs.config_bucket.id,
        "component/pdm-dataset-generation/metrics"
      )
      VERSION                 = local.pdm_version[local.environment]
      PDM_LOG_LEVEL           = local.pdm_log_level[local.environment]
      ENVIRONMENT_NAME        = local.environment
      S3_LOGGING_SHELL        = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.logging_script.key)
      S3_COMMON_LOGGING_SHELL = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, data.terraform_remote_state.common.outputs.application_logging_common_file.s3_id)
    }
  )
  tags = {
    Name = "download_scripts_sh"
  }
}

resource "aws_s3_bucket_object" "download_sql_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/download_sql.sh"
  content = templatefile("${path.module}/bootstrap_actions/download_sql.sh",
    {
      version               = local.pdm_version[local.environment]
      s3_artefact_bucket_id = data.terraform_remote_state.management_artefact.outputs.artefact_bucket.id
      s3_config_bucket_id   = format("s3://%s", data.terraform_remote_state.common.outputs.config_bucket.id)
      pdm_log_level         = local.pdm_log_level[local.environment]
      environment_name      = local.environment
    }
  )
  tags = {
    Name = "download_sql_sh"
  }
}

resource "aws_s3_bucket_object" "application_metrics" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/application-metrics-setup.sh"
  content = templatefile("${path.module}/bootstrap_actions/application-metrics-setup.sh",
    {
      proxy_url             = data.terraform_remote_state.internal_compute.outputs.internet_proxy.url
      metrics_pom           = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.metrics_pom.key)
      prometheus_config     = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.prometheus_config.key)
      maven_binary_location = format("s3://%s", data.terraform_remote_state.common.outputs.config_bucket.id)
    }
  )
  tags = {
    Name = "application_metrics"
  }
}

resource "aws_s3_bucket_object" "metrics_pom" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/pdm-dataset-generation/metrics_config/pom.xml"
  content    = file("${path.module}/bootstrap_actions/metrics_config/pom.xml")
  tags = {
    Name = "metrics_pom"
  }
}

resource "aws_s3_bucket_object" "prometheus_config" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/pdm-dataset-generation/metrics_config/prometheus_config.yml"
  content    = file("${path.module}/bootstrap_actions/metrics_config/prometheus_config.yml")
  tags = {
    Name = "prometheus_config"
  }
}

resource "aws_s3_bucket_object" "dynamo_json_file" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/pdm-dataset-generation/dynamo_schema.json"
  content    = file("${path.module}/bootstrap_actions/dynamo_schema.json")
  tags = {
    Name = "dynamo_json_file"
  }
}

resource "aws_s3_bucket_object" "update_dynamo_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/pdm-dataset-generation/update_dynamo.sh"
  content = templatefile("${path.module}/bootstrap_actions/update_dynamo.sh",
    {
      dynamodb_table_name = local.data_pipeline_metadata
    }
  )
  tags = {
    Name = "update_dynamo_sh"
  }
}

resource "aws_s3_bucket_object" "replace_rpms_hive_sh" {
  bucket     = data.terraform_remote_state.common.outputs.config_bucket.id
  kms_key_id = data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
  key        = "component/pdm-dataset-generation/replace-rpms-hive.sh"
  content = templatefile("${path.module}/bootstrap_actions/replace-rpms-hive.sh",
    {
      hive_scratch_dir_s3_prefix = "s3://${data.terraform_remote_state.management_artefact.outputs.artefact_bucket.id}/${local.hive_scratch_dir_patch_files_s3_prefix}"
    }
  )
}
