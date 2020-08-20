resource "aws_glue_catalog_database" "uc_pdm_source" {
  name         = local.source_db
  description  = "Database for the PDM source data"
  location_uri = format("s3://%s/%s", data.terraform_remote_state.internal_compute.outputs.compaction_bucket.id, "pdm-dataset/hive/source")
}

resource "aws_glue_catalog_database" "uc_pdm_transform" {
  name         = local.transform_db
  description  = "Database for the PDM transform data"
  location_uri = format("s3://%s/%s", data.terraform_remote_state.internal_compute.outputs.compaction_bucket.id, "pdm-dataset/hive/transform")
}

resource "aws_glue_catalog_database" "uc_pdm_transactional" {
  name         = local.transactional_db
  description  = "Database for the PDM transactional data"
  location_uri = format("s3://%s/%s", data.terraform_remote_state.internal_compute.outputs.compaction_bucket.id, "pdm-dataset/hive/transactional")
}

resource "aws_glue_catalog_database" "uc_pdm_model" {
  name         = local.model_db
  description  = "Database for the PDM model data"
  location_uri = format("s3://%s/%s", data.terraform_remote_state.internal_compute.outputs.compaction_bucket.id, "pdm-dataset/hive/model")
}

resource "aws_glue_catalog_database" "uc" {
  name         = local.uc_db
  description  = "Database for the PDM views data"
  location_uri = format("s3://%s/%s", data.terraform_remote_state.adg.outputs.published_bucket.id, "pdm-dataset/hive/uc_views")
}

resource "aws_glue_catalog_database" "uc_materialised" {
  name         = local.materialised_views_db
  description  = "Database for the materialised PDM views data"
  location_uri = format("s3://%s/%s", data.terraform_remote_state.adg.outputs.published_bucket.id, "pdm-dataset/hive/uc_materialised_views")
}

data "aws_iam_policy_document" "pdm_dataset_generator_gluetables_write" {
  statement {
    effect = "Allow"

    actions = [
      "glue:*",
    ]

    resources = [
      "arn:aws:glue:${var.region}:${local.account[local.environment]}:*",
    ]
  }
}

resource "aws_iam_policy" "pdm_dataset_generator_gluetables_write" {
  name        = "PDMDatasetGeneratorGlueTablesWrite"
  description = "Allow creation and deletion of PDM Glue tables"
  policy      = data.aws_iam_policy_document.pdm_dataset_generator_gluetables_write.json
}
