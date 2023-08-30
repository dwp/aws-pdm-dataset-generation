resource "aws_s3_object" "metrics_setup_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/metrics/metrics-setup.sh"
  content = templatefile("${path.module}/steps/metrics-setup.sh",
    {
      metrics_export_to_s3 = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_object.export_to_s3_sh.key)
    }
  )
  tags = {
    Name = "metrics_setup_sh"
  }
}

resource "aws_s3_object" "export_to_s3_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/metrics/export-to-s3.sh"
  content = templatefile("${path.module}/steps/export-to-s3.sh",
    {
      pdm_metrics_path = format("s3://%s/%s", data.terraform_remote_state.common.outputs.published_bucket.id, "metrics/pdm-metrics.json")
    }
  )
  tags = {
    Name = "export_to_s3_sh"
  }
}

resource "aws_s3_object" "source_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/source.sh"
  content = templatefile("${path.module}/steps/source.sh",
    {
      source_db           = local.source_db
      data_location       = local.data_location
      dictionary_location = local.dictionary_location
      serde               = local.serde
      processes           = local.source_processes[local.environment]
    }
  )
  tags = {
    Name = "source_sh"
  }
}

resource "aws_s3_object" "transform_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/transform.sh"
  content = templatefile("${path.module}/steps/transform.sh",
    {
      source_db           = local.source_db
      transform_db        = local.transform_db
      dictionary_location = local.dictionary_location
      processes           = local.transform_processes[local.environment]
    }
  )
  tags = {
    Name = "transform_sh"
  }
}

resource "aws_s3_object" "model_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/model.sh"
  content = templatefile("${path.module}/steps/model.sh",
    {
      transform_db     = local.transform_db
      transactional_db = local.transactional_db
      model_db         = local.model_db
      processes        = local.model_processes[local.environment]
    }
  )
  tags = {
    Name = "model_sh"
  }
}

resource "aws_s3_object" "views_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/views.sh"
  content = templatefile("${path.module}/steps/views.sh",
    {
      transform_db     = local.transform_db
      transactional_db = local.transactional_db
      model_db         = local.model_db
      views_db         = local.views_db
      processes        = local.views_processes[local.environment]
    }
  )
  tags = {
    Name = "views_sh"
  }
}

resource "aws_s3_object" "transactional_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/transactional.sh"
  content = templatefile("${path.module}/steps/transactional.sh",
    {
      transactional_db = local.transactional_db
      processes        = local.transactional_processes[local.environment]
    }
  )
  tags = {
    Name = "transactional_sh"
  }
}

resource "aws_s3_object" "clean_dictionary_data_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/clean_dictionary_data.sh"
  content = templatefile("${path.module}/steps/clean_dictionary_data.sh",
    {
      dictionary_location = local.dictionary_location
    }
  )
  tags = {
    Name = "clean_dictionary_data_sh"
  }
}

resource "aws_s3_object" "create_databases_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/create_databases.sh"
  content = templatefile("${path.module}/steps/create_databases.sh",
    {
    }
  )
  tags = {
    Name = "create_databases_sh"
  }
}

resource "aws_s3_object" "create_hive_dynamo_table" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/create-hive-dynamo-table.sh"
  content = templatefile("${path.module}/steps/create-hive-dynamo-table.sh",
    {
      dynamodb_table_name = local.data_pipeline_metadata
    }
  )
  tags = {
    Name = "create_hive_dynamo_table"
  }
}

resource "aws_s3_object" "create_views_tables" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/create-views-tables.sh"
  content = templatefile("${path.module}/steps/create-views-tables.sh",
    {
      views_db        = local.views_db
      views_tables_db = local.views_tables_db
      processes       = local.views_tables_processes[local.environment]
    }
  )
  tags = {
    Name = "create_views_tables"
  }
}

resource "aws_s3_object" "initial_transactional_load_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/initial_transactional_load.sh"
  content = templatefile("${path.module}/steps/initial_transactional_load.sh",
    {
      transactional_db           = local.transactional_db
      dictionary_location        = local.dictionary_location
      initial_transactional_load = local.initial_transactional_load[local.environment]
    }
  )
  tags = {
    Name = "initial_transactional_load_sh"
  }
}

resource "aws_s3_object" "collect_metrics" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/collect-metrics.sh"
  content = templatefile("${path.module}/steps/collect-metrics.sh",
    {
    }
  )
  tags = {
    Name = "collect_metrics"
  }
}

resource "aws_s3_object" "courtesy_flush" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/courtesy-flush.sh"
  content = templatefile("${path.module}/steps/courtesy-flush.sh",
    {
      pdm_metrics_path         = format("s3://%s/%s", data.terraform_remote_state.common.outputs.published_bucket.id, "metrics/pdm-metrics.json")
      pdm_pushgateway_hostname = local.pdm_pushgateway_hostname
    }
  )
  tags = {
    Name = "courtesy_flush"
  }
}

resource "aws_s3_object" "flush_gateway" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/flush-gateway.sh"
  content = templatefile("${path.module}/steps/flush-gateway.sh",
    {
      pdm_pushgateway_hostname = local.pdm_pushgateway_hostname
    }
  )
  tags = {
    Name = "flush_gateway"
  }
}

resource "aws_s3_object" "flush_s3" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/flush-s3.sh"
  content = templatefile("${path.module}/steps/flush-s3.sh",
    {
      pdm_metrics_path = format("s3://%s/%s", data.terraform_remote_state.common.outputs.published_bucket.id, "metrics/pdm-metrics.json")
    }
  )
  tags = {
    Name = "flush_s3"
  }
}

// Removed additional step as it is not working as per intended design
//resource "aws_s3_object" "additional_metrics" {
//  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
//  key    = "component/pdm-dataset-generation/additional-metrics.sh"
//  content = templatefile("${path.module}/steps/additional-metrics.sh",
//    {
//      uc_db                    = local.uc_db
//      metastore_secret_id      = data.aws_secretsmanager_secret.metastore_reader_secret.id
//      pdm_pushgateway_hostname = local.pdm_pushgateway_hostname
//    }
//  )
//  tags = {
//    Name = "additional_metrics"
//  }
//}
