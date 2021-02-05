resource "aws_s3_bucket_object" "metrics_setup_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/metrics/metrics-setup.sh"
  content = templatefile("${path.module}/steps/metrics-setup.sh",
    {
      metrics_export_to_s3 = format("s3://%s/%s", data.terraform_remote_state.common.outputs.config_bucket.id, aws_s3_bucket_object.export_to_s3_sh.key)
    }
  )
}

resource "aws_s3_bucket_object" "export_to_s3_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/metrics/export-to-s3.sh"
  content = templatefile("${path.module}/steps/export-to-s3.sh",
    {
      pdm_metrics_path = format("s3://%s/%s", data.terraform_remote_state.common.outputs.published_bucket.id, "metrics/pdm-metrics.json")
    }
  )
}

resource "aws_s3_bucket_object" "source_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/source.sh"
  content = templatefile("${path.module}/steps/source.sh",
    {
      source_db           = local.source_db
      data_location       = local.data_location
      dictionary_location = local.dictionary_location
      serde               = local.serde
    }
  )
}

resource "aws_s3_bucket_object" "transform_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/transform.sh"
  content = templatefile("${path.module}/steps/transform.sh",
    {
      source_db           = local.source_db
      transform_db        = local.transform_db
      dictionary_location = local.dictionary_location
    }
  )
}

resource "aws_s3_bucket_object" "model_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/model.sh"
  content = templatefile("${path.module}/steps/model.sh",
    {
      transform_db     = local.transform_db
      transactional_db = local.transactional_db
      model_db         = local.model_db
    }
  )
}

resource "aws_s3_bucket_object" "views_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/views.sh"
  content = templatefile("${path.module}/steps/views.sh",
    {
      transform_db     = local.transform_db
      transactional_db = local.transactional_db
      model_db         = local.model_db
      views_db         = local.views_db
    }
  )
}

resource "aws_s3_bucket_object" "transactional_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/transactional.sh"
  content = templatefile("${path.module}/steps/transactional.sh",
    {
      transactional_db = local.transactional_db
    }
  )
}

resource "aws_s3_bucket_object" "clean_dictionary_data_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/clean_dictionary_data.sh"
  content = templatefile("${path.module}/steps/clean_dictionary_data.sh",
    {
      dictionary_location = local.dictionary_location
    }
  )
}

resource "aws_s3_bucket_object" "create_db_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/create_db.sh"
  content = templatefile("${path.module}/steps/create_db.sh",
    {
    }
  )
}

resource "aws_s3_bucket_object" "create_hive_dynamo_table" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/create-hive-dynamo-table.sh"
  content = templatefile("${path.module}/steps/create-hive-dynamo-table.sh",
    {
      dynamodb_table_name = local.data_pipeline_metadata
    }
  )
}

resource "aws_s3_bucket_object" "create_views_tables" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/create-views-tables.sh"
  content = templatefile("${path.module}/steps/create-views-tables.sh",
    {
      views_db        = local.views_db
      views_tables_db = local.views_tables_db
    }
  )
}

resource "aws_s3_bucket_object" "intial_transactional_load_sh" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/intial_transactional_load.sh"
  content = templatefile("${path.module}/steps/intial_transactional_load.sh",
    {
      transactional_db          = local.transactional_db
      dictionary_location       = local.dictionary_location
      intial_transactioanl_load = local.intial_transactioanl_load[local.environment]
    }
  )
}

resource "aws_s3_bucket_object" "row_count" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/row-count.sh"
  content = templatefile("${path.module}/steps/row-count.sh",
    {
      transform_db     = local.transform_db
      transactional_db = local.transactional_db
      model_db         = local.model_db
      views_db         = local.views_db
      data_location    = local.data_location
      views_tables_db  = local.views_tables_db
    }
  )
}

resource "aws_s3_bucket_object" "collect_metrics" {
  bucket = data.terraform_remote_state.common.outputs.config_bucket.id
  key    = "component/pdm-dataset-generation/collect-metrics.sh"
  content = templatefile("${path.module}/steps/collect-metrics.sh",
    {
    }
  )
}
