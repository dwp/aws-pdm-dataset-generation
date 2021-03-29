resource "aws_emr_security_configuration" "ebs_emrfs_em" {
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
      emr_release_label      = var.emr_release[local.environment]
    }
  )
}

resource "aws_s3_bucket_object" "instances" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/pdm/instances.yaml"
  content = templatefile("${path.module}/cluster_config/instances.yaml.tpl",
    {
      keep_cluster_alive       = local.keep_cluster_alive[local.environment]
      add_master_sg            = aws_security_group.pdm_common.id
      add_slave_sg             = aws_security_group.pdm_common.id
      subnet_ids               = join(",", data.terraform_remote_state.internal_compute.outputs.pdm_subnet_new.ids)
      master_sg                = aws_security_group.pdm_master.id
      slave_sg                 = aws_security_group.pdm_slave.id
      service_access_sg        = aws_security_group.pdm_emr_service.id
      instance_type_master     = var.emr_instance_type_master[local.environment]
      instance_type_core_one   = var.emr_instance_type_core_one[local.environment]
      instance_type_core_two   = var.emr_instance_type_core_two[local.environment]
      instance_type_core_three = var.emr_instance_type_core_three[local.environment]
      core_instance_count      = var.emr_core_instance_count[local.environment]
    }
  )
}

resource "aws_s3_bucket_object" "steps" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/pdm/steps.yaml"
  content = templatefile("${path.module}/cluster_config/steps.yaml.tpl",
    {
      s3_config_bucket  = data.terraform_remote_state.common.outputs.config_bucket.id
      s3_publish_bucket = data.terraform_remote_state.common.outputs.published_bucket.id
      action_on_failure = local.step_fail_action[local.environment]
    }
  )
}

data "aws_secretsmanager_secret" "rds_aurora_secrets" {
  provider = aws
  name     = "metadata-store-v2-pdm-writer"
}

resource "aws_s3_bucket_object" "configurations" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "emr/pdm/configurations.yaml"
  content = templatefile("${path.module}/cluster_config/configurations.yaml.tpl",
    {
      s3_log_bucket                                 = data.terraform_remote_state.security-tools.outputs.logstore_bucket.id
      s3_log_prefix                                 = local.s3_log_prefix
      s3_published_bucket                           = data.terraform_remote_state.common.outputs.published_bucket.id
      proxy_no_proxy                                = replace(replace(local.no_proxy, ",", "|"), ".s3", "*.s3")
      proxy_http_host                               = data.terraform_remote_state.internal_compute.outputs.internet_proxy.host
      proxy_http_port                               = data.terraform_remote_state.internal_compute.outputs.internet_proxy.port
      proxy_https_host                              = data.terraform_remote_state.internal_compute.outputs.internet_proxy.host
      proxy_https_port                              = data.terraform_remote_state.internal_compute.outputs.internet_proxy.port
      hive_metastore_username                       = var.metadata_store_pdm_writer_username
      hive_metastore_pwd                            = data.terraform_remote_state.internal_compute.outputs.metadata_store_users.pdm_writer.secret_name
      hive_metastore_endpoint                       = data.terraform_remote_state.internal_compute.outputs.hive_metastore_v2.endpoint
      hive_metastore_database_name                  = data.terraform_remote_state.internal_compute.outputs.hive_metastore_v2.database_name
      hive_compaction_threads                       = local.hive_compaction_threads[local.environment]
      hive_metastore_location                       = local.hive_metastore_location
      hive_tez_container_size                       = local.hive_tez_container_size[local.environment]
      hive_tez_java_opts                            = local.hive_tez_java_opts[local.environment]
      tez_grouping_min_size                         = local.tez_grouping_min_size[local.environment]
      tez_grouping_max_size                         = local.tez_grouping_max_size[local.environment]
      tez_am_resource_memory_mb                     = local.tez_am_resource_memory_mb[local.environment]
      tez_am_launch_cmd_opts                        = local.tez_am_launch_cmd_opts[local.environment]
      tez_task_resource_memory_mb                   = local.tez_task_resource_memory_mb[local.environment]
      hive_auto_convert_join_noconditionaltask_size = local.hive_auto_convert_join_noconditionaltask_size[local.environment]
      tez_runtime_io_sort_mb                        = local.tez_runtime_io_sort_mb[local.environment]
      tez_runtime_unordered_output_buffer_size_mb   = local.tez_runtime_unordered_output_buffer_size_mb[local.environment]
      llap_daemon_yarn_container_mb                 = local.llap_daemon_yarn_container_mb[local.environment]
      llap_number_of_instances                      = local.llap_number_of_instances[local.environment]
      hive_max_reducers                             = local.hive_max_reducers[local.environment]
      map_reduce_vcores_per_task                    = local.map_reduce_vcores_per_task[local.environment]
      map_reduce_vcores_per_node                    = local.map_reduce_vcores_per_node[local.environment]
      hive_tez_sessions_per_queue                   = local.hive_tez_sessions_per_queue[local.environment]
    }
  )
}

