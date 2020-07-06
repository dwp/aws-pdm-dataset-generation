data "aws_iam_role" "ci" {
  name = "ci"
}

data "aws_iam_role" "administrator" {
  name = "administrator"
}

data "aws_iam_role" "aws_config" {
  name = "aws_config"
}

data "aws_iam_policy_document" "pdm_dataset_generator_write_parquet" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.adg.outputs.published_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject*",
      "s3:DeleteObject*",
      "s3:PutObject*",
    ]

    resources = [
      "${data.terraform_remote_state.adg.outputs.published_bucket.arn}/pdm-dataset/*",
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
      "${data.terraform_remote_state.adg.outputs.published_bucket.arn}",
    ]
  }
}

resource "aws_iam_policy" "pdm_dataset_generator_write_parquet" {
  name        = "pdmDatasetGeneratorWriteParquet"
  description = "Allow writing of pdm Dataset parquet files"
  policy      = data.aws_iam_policy_document.pdm_dataset_generator_write_parquet.json
}

data "aws_iam_policy_document" "pdm_dataset_read_only" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.adg.outputs.published_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${data.terraform_remote_state.adg.outputs.published_bucket.arn}/pdm-dataset/*",
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      "${data.terraform_remote_state.adg.outputs.published_bucket.arn}",
    ]
  }
}

resource "aws_iam_policy" "pdm_dataset_read_only" {
  name        = "pdmDatasetReadOnly"
  description = "Allow read access to the pdm Dataset"
  policy      = data.aws_iam_policy_document.pdm_dataset_read_only.json
}

data "aws_iam_policy_document" "pdm_dataset_crown_read_only" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
    ]

    resources = [
      data.terraform_remote_state.adg.outputs.published_bucket.arn,
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "${data.terraform_remote_state.adg.outputs.published_bucket.arn}/pdm-dataset/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:ExistingObjectTag/collection_tag"

      values = [
        "crown"
      ]
    }
  }

  statement {
    effect = "Allow"

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
    ]

    resources = [
      "${data.terraform_remote_state.adg.outputs.published_bucket.arn}",
    ]
  }
}

resource "aws_iam_policy" "pdm_dataset_crown_read_only" {
  name        = "pdmDatasetCrownReadOnly"
  description = "Allow read access to the Crown-specific subset of the pdm Dataset"
  policy      = data.aws_iam_policy_document.pdm_dataset_read_only.json
}
