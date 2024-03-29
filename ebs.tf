data "aws_iam_policy_document" "pdm_ebs_cmk" {
  statement {
    sid    = "EnableIAMPermissionsCI"
    effect = "Allow"

    principals {
      identifiers = [data.aws_iam_role.ci.arn]
      type        = "AWS"
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "DenyCIEncryptDecrypt"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.ci.arn]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ImportKeyMaterial",
      "kms:ReEncryptFrom",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EnableIAMPermissionsAdministrator"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.administrator.arn]
    }

    actions = [
      "kms:Describe*",
      "kms:List*",
      "kms:Get*"
    ]
    resources = ["*"]
  }

  statement {
    sid    = "EnableAWSConfigManagerScanForSecurityHub"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_role.aws_config.arn]
    }

    actions = [
      "kms:Describe*",
      "kms:Get*",
      "kms:List*"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "EnableIAMPermissionsAnalyticDatasetGen"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.pdm_emr_service.arn, aws_iam_role.pdm_dataset_generator.arn]
    }

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]

    resources = ["*"]

  }

  statement {
    sid    = "AllowPDMServiceGrant"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_iam_role.pdm_emr_service.arn, aws_iam_role.pdm_dataset_generator.arn]
    }

    actions = ["kms:CreateGrant"]

    resources = ["*"]

    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_kms_key" "pdm_ebs_cmk" {
  description             = "Encrypts PDM EBS volumes"
  deletion_window_in_days = 7
  is_enabled              = true
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.pdm_ebs_cmk.json


  # ProtectsSensitiveData = "True" - the PDM cluster decrypts sensitive data
  # that it reads from S3. It can potentially spill this to disk if it can't
  # hold it all in memory, which is likely given the size of the dataset.
  tags = {
    Name                  = "pdm_dataset_generator_metadata_change",
    ProtectsSensitiveData = "True"
  }
}

resource "aws_kms_alias" "pdm_ebs_cmk" {
  name          = "alias/pdm_ebs_cmk"
  target_key_id = aws_kms_key.pdm_ebs_cmk.key_id
}

data "aws_iam_policy_document" "pdm_dataset_ebs_cmk_encrypt" {
  statement {
    effect = "Allow"

    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey",
    ]

    resources = [aws_kms_key.pdm_ebs_cmk.arn]
  }

  statement {
    effect = "Allow"

    actions = ["kms:CreateGrant"]

    resources = [aws_kms_key.pdm_ebs_cmk.arn]
    condition {
      test     = "Bool"
      variable = "kms:GrantIsForAWSResource"
      values   = ["true"]
    }
  }
}

resource "aws_iam_policy" "pdm_dataset_ebs_cmk_encrypt" {
  name        = "PDMDatasetGeneratorEbsCmkEncrypt"
  description = "Allow encryption and decryption using the PDM Dataset Generator EBS CMK"
  policy      = data.aws_iam_policy_document.pdm_dataset_ebs_cmk_encrypt.json
  tags = {
    Name = "pdm_dataset_ebs_cmk_encrypt"
  }
}
