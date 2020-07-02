resource "aws_glue_catalog_database" "pdm_dataset_generation" {
  name        = "pdm_dataset_generation"
  description = "Database for the PDM Dataset"
}

output "pdm_dataset_generation" {
  value = {
    job_name = aws_glue_catalog_database.pdm_dataset_generation.name
  }
}

resource "aws_glue_catalog_database" "pdm_dataset_generation_staging" {
  name        = "pdm_dataset_generation_staging"
  description = "Staging Database for PDM dataset generation"
}

output "pdm_dataset_generation_staging" {
  value = {
    job_name = aws_glue_catalog_database.pdm_dataset_generation_staging.name
  }
}

data "aws_iam_policy_document" "pdm_dataset_generator_gluetables_write" {
  statement {
    effect = "Allow"

    actions = [
      "glue:CreateTable",
      "glue:DeleteTable",
      "glue:GetDatabase*",
      "glue:GetUserDefinedFunctions",
      "glue:GetTable*",
    ]

    resources = [
      "arn:aws:glue:${var.region}:${local.account[local.environment]}:database/${aws_glue_catalog_database.pdm_dataset_generation_staging.name}",
      "arn:aws:glue:${var.region}:${local.account[local.environment]}:table/${aws_glue_catalog_database.pdm_dataset_generation_staging.name}/*",
      "arn:aws:glue:${var.region}:${local.account[local.environment]}:database/${aws_glue_catalog_database.pdm_dataset_generation.name}",
      "arn:aws:glue:${var.region}:${local.account[local.environment]}:table/${aws_glue_catalog_database.pdm_dataset_generation.name}/*",
      "arn:aws:glue:${var.region}:${local.account[local.environment]}:catalog",
      "arn:aws:glue:${var.region}:${local.account[local.environment]}:default",
    ]
  }
}

resource "aws_iam_policy" "pdm_dataset_generator_gluetables_write" {
  name        = "PDMDatasetGeneratorGlueTablesWrite"
  description = "Allow creation and deletion of PDM Glue tables"
  policy      = data.aws_iam_policy_document.pdm_dataset_generator_gluetables_write.json
}
