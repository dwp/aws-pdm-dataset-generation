resource "aws_glue_catalog_database" "pdm_dataset_generation" {
  name        = "pdm_dataset_generation"
  description = "Database for the Manifest comparision ETL"
}

output "pdm_dataset_generation" {
  value = {
    job_name = aws_glue_catalog_database.pdm_dataset_generation.name
  }
}

data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "pdm_dataset_write_s3" {
  statement {
    effect = "Allow"

    actions = [
      "s3:ListBucket",
    ]

    resources = [
      "arn:aws:s3:::*",
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
      "arn:aws:s3:::*",
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
      "arn:aws:kms:::*",
    ]
  }

  statement {
    sid    = "AllowUseDefaultEbsCmk"
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [
      "arn:aws:kms:::*",
    ]
  }
}

resource "aws_iam_policy" "pdm_dataset_write_s3" {
  name        = "DatasetGeneratorWriteS3"
  description = "Allow Dataset Generator clusters to write to S3 buckets"
  policy      = data.aws_iam_policy_document.pdm_dataset_write_s3.json
}

resource "aws_iam_role" "pdm_dataset_generator" {
  name               = "pdm_dataset_generator"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json
  tags               = local.tags
}

resource "aws_iam_instance_profile" "pdm_dataset_generator" {
  name = "pdm_dataset_generator"
  role = aws_iam_role.pdm_dataset_generator.id
}

resource "aws_iam_role_policy_attachment" "emr_for_ec2_attachment" {
  role       = aws_iam_role.pdm_dataset_generator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "emr_pdm_dataset_write_s3" {
  role       = aws_iam_role.pdm_dataset_generator.name
  policy_arn = aws_iam_policy.pdm_dataset_write_s3.arn
}

resource "aws_iam_role_policy_attachment" "ec2_for_ssm_attachment" {
  role       = aws_iam_role.pdm_dataset_generator.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}
