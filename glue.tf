resource "aws_glue_catalog_database" "uc_pdm_source" {
  name         = "uc_pdm_source"
  description  = "Database for the PDM source data"
  location_uri = format("s3://%s/%s", data.terraform_remote_state.adg.outputs.published_bucket.id, "pdm-dataset/hive/source")
}

resource "aws_glue_catalog_database" "uc_pdm_transform" {
  name         = "uc_pdm_transform"
  description  = "Database for the PDM transform data"
  location_uri = format("s3://%s/%s", data.terraform_remote_state.adg.outputs.published_bucket.id, "pdm-dataset/hive/transform")
}

resource "aws_glue_catalog_database" "uc_pdm_transactional" {
  name         = "uc_pdm_transactional"
  description  = "Database for the PDM transactional data"
  location_uri = format("s3://%s/%s", data.terraform_remote_state.adg.outputs.published_bucket.id, "pdm-dataset/hive/transactional")
}

resource "aws_glue_catalog_database" "uc_pdm_model" {
  name         = "uc_pdm_model"
  description  = "Database for the PDM model data"
  location_uri = format("s3://%s/%s", data.terraform_remote_state.adg.outputs.published_bucket.id, "pdm-dataset/hive/model")
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
