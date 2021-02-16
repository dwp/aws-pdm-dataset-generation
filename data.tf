data "aws_iam_role" "ci" {
  name = "ci"
}

data "aws_iam_role" "administrator" {
  name = "administrator"
}

data "aws_iam_role" "aws_config" {
  name = "aws_config"
}

data "aws_iam_policy_document" "pdm_dataset_generator_write_data" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.common.outputs.published_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
      "s3:DeleteObject*",
      "s3:Put*",
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/${local.hive_metastore_location}/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/metrics/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/common-model-inputs/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/analytical-dataset/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/e2e-test-pdm-dataset/*",
      "${data.terraform_remote_state.common.outputs.published_bucket.arn}/e2e-test-pdm-output/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [
      "${data.terraform_remote_state.common.outputs.published_bucket_cmk.arn}",
    ]
  }
}

resource "aws_iam_policy" "pdm_dataset_generator_write_data" {
  name        = "pdmDatasetGeneratorWriteData"
  description = "Allow writing of pdm Dataset files and metrics"
  policy      = data.aws_iam_policy_document.pdm_dataset_generator_write_data.json
}

