resource "aws_emr_security_configuration" "ebs_emrfs_em" {glu
  name          = "pdm_ebs_emrfs"
  configuration = jsonencode(local.ebs_emrfs_em)
}

resource "aws_s3_bucket_object" "cluster" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/pdm/cluster.yaml"
  content = templatefile("${path.module}/cluster_config/cluster.yaml.tpl",
    {
      s3_log_bucket          = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
      s3_log_prefix          = local.s3_log_prefix
      ami_id                 = var.emr_ami_id
      service_role           = aws_iam_role.pdm_emr_service.arn
      instance_profile       = aws_iam_instance_profile.pdm_dataset_generator.arn
      security_configuration = aws_emr_security_configuration.ebs_emrfs_em.id
    }
  )
}

resource "aws_s3_bucket_object" "instances" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/pdm/instances.yaml"
  content = templatefile("${path.module}/cluster_config/instances.yaml.tpl",
    {
      keep_cluster_alive = local.keep_cluster_alive[local.environment]
      add_master_sg      = aws_security_group.pdm_common.id
      add_slave_sg       = aws_security_group.pdm_common.id
      subnet_ids         = join(",", data.terraform_remote_state.internal_compute.outputs.pdm_subnet.ids)
      master_sg          = aws_security_group.pdm_master.id
      slave_sg           = aws_security_group.pdm_slave.id
      service_access_sg  = aws_security_group.pdm_emr_service.id
      instance_type      = var.emr_instance_type[local.environment]
    }
  )
}

resource "aws_s3_bucket_object" "steps" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/pdm/steps.yaml"
  content = templatefile("${path.module}/cluster_config/steps.yaml.tpl",
    {
      s3_config_bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
      s3_publish_bucket = data.terraform_remote_state.adg.outputs.published_bucket.id
    }
  )
}

data "aws_secretsmanager_secret_version" "rds_aurora_secrets" {
  provider  = aws
  secret_id = "metadata-store-pdm-writer"
}

resource "aws_s3_bucket_object" "configurations" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/pdm/configurations.yaml"
  content = templatefile("${path.module}/cluster_config/configurations.yaml.tpl",
    {
      s3_log_bucket            = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
      s3_log_prefix            = local.s3_log_prefix
      s3_published_bucket      = data.terraform_remote_state.adg.outputs.published_bucket.id
      proxy_no_proxy           = replace(replace(local.no_proxy, ",", "|"), ".s3", "*.s3")
      proxy_http_host          = data.terraform_remote_state.internal_compute.outputs.internet_proxy.host
      proxy_http_port          = data.terraform_remote_state.internal_compute.outputs.internet_proxy.port
      proxy_https_host         = data.terraform_remote_state.internal_compute.outputs.internet_proxy.host
      proxy_https_port         = data.terraform_remote_state.internal_compute.outputs.internet_proxy.port
      emrfs_metadata_tablename = local.emrfs_metadata_tablename
      hive_metastore_fqdn      = data.terraform_remote_state.aws_analytical_dataset_generation.outputs.hive_metastore.rds_cluster.endpoint
      hive_metsatore_username             = var.metadata_store_pdm_writer_username
      hive_metastore_pwd                  = jsondecode(data.aws_secretsmanager_secret_version.rds_aurora_secrets.secret_string)["password"]
      hive_metastore_endpoint             = aws_rds_cluster.hive_metastore.endpoint
    }
  )
}
