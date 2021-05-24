variable "pdm_emr_launcher_zip" {
  type = map(string)

  default = {
    base_path = ""
    version   = ""
  }
}

resource "aws_lambda_function" "pdm_emr_launcher" {
  filename      = "${var.pdm_emr_launcher_zip["base_path"]}/emr-launcher-${var.pdm_emr_launcher_zip["version"]}.zip"
  function_name = "pdm_emr_launcher"
  role          = aws_iam_role.pdm_emr_launcher_lambda_role.arn
  handler       = "emr_launcher.handler.handler"
  runtime       = "python3.7"
  source_code_hash = filebase64sha256(
    format(
      "%s/emr-launcher-%s.zip",
      var.pdm_emr_launcher_zip["base_path"],
      var.pdm_emr_launcher_zip["version"]
    )
  )
  publish = false
  timeout = 60

  environment {
    variables = {
      EMR_LAUNCHER_CONFIG_S3_BUCKET = data.terraform_remote_state.common.outputs.config_bucket.id
      EMR_LAUNCHER_CONFIG_S3_FOLDER = "emr/pdm"
      EMR_LAUNCHER_LOG_LEVEL        = "debug"
    }
  }

  tags = {
    Name = "pdm_emr_launcher"
  }
}

resource "aws_iam_role" "pdm_emr_launcher_lambda_role" {
  name               = "pdm_emr_launcher_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.pdm_emr_launcher_assume_policy.json
  tags = {
    Name = "pdm_emr_launcher_lambda_role"
  }
}

data "aws_iam_policy_document" "pdm_emr_launcher_assume_policy" {
  statement {
    sid     = "PDMEMRLauncherLambdaAssumeRolePolicy"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "pdm_emr_launcher_read_s3_policy" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
    ]
    resources = [
      format("arn:aws:s3:::%s/emr/pdm/*", data.terraform_remote_state.common.outputs.config_bucket.id)
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
    ]
    resources = [
      data.terraform_remote_state.common.outputs.config_bucket_cmk.arn
    ]
  }
}

data "aws_iam_policy_document" "pdm_emr_launcher_runjobflow_policy" {
  statement {
    effect = "Allow"
    actions = [
      "elasticmapreduce:RunJobFlow",
      "elasticmapreduce:AddTags",
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "pdm_emr_launcher_pass_role_document" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "arn:aws:iam::*:role/*"
    ]
  }
}

resource "aws_iam_policy" "pdm_emr_launcher_read_s3_policy" {
  name        = "PDMReadS3"
  description = "Allow PDM to read from S3 bucket"
  policy      = data.aws_iam_policy_document.pdm_emr_launcher_read_s3_policy.json
  tags = {
    Name = "pdm_emr_launcher_read_s3_policy"
  }
}

resource "aws_iam_policy" "pdm_emr_launcher_runjobflow_policy" {
  name        = "PDMRunJobFlow"
  description = "Allow PDM to run job flow"
  policy      = data.aws_iam_policy_document.pdm_emr_launcher_runjobflow_policy.json
  tags = {
    Name = "pdm_emr_launcher_runjobflow_policy"
  }
}

resource "aws_iam_policy" "pdm_emr_launcher_pass_role_policy" {
  name        = "PDMPassRole"
  description = "Allow PDM to pass role"
  policy      = data.aws_iam_policy_document.pdm_emr_launcher_pass_role_document.json
  tags = {
    Name = "pdm_emr_launcher_pass_role_policy"
  }
}

resource "aws_iam_role_policy_attachment" "pdm_emr_launcher_read_s3_attachment" {
  role       = aws_iam_role.pdm_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.pdm_emr_launcher_read_s3_policy.arn
}

resource "aws_iam_role_policy_attachment" "pdm_emr_launcher_runjobflow_attachment" {
  role       = aws_iam_role.pdm_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.pdm_emr_launcher_runjobflow_policy.arn
}

resource "aws_iam_role_policy_attachment" "pdm_emr_launcher_pass_role_attachment" {
  role       = aws_iam_role.pdm_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.pdm_emr_launcher_pass_role_policy.arn
}

resource "aws_iam_role_policy_attachment" "pdm_emr_launcher_policy_execution" {
  role       = aws_iam_role.pdm_emr_launcher_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

resource "aws_iam_policy" "pdm_emr_launcher_getsecrets" {
  name        = "PDMGetSecrets"
  description = "Allow PDM Lambda function to get secrets"
  policy      = data.aws_iam_policy_document.pdm_emr_launcher_getsecrets.json
  tags = {
    Name = "pdm_emr_launcher_getsecrets"
  }
}

data "aws_iam_policy_document" "pdm_emr_launcher_getsecrets" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      data.aws_secretsmanager_secret.rds_aurora_secrets.arn,
      data.terraform_remote_state.internal_compute.outputs.metadata_store_users.pdm_writer.secret_arn,
    ]
  }
}

resource "aws_iam_role_policy_attachment" "pdm_emr_launcher_getsecrets" {
  role       = aws_iam_role.pdm_emr_launcher_lambda_role.name
  policy_arn = aws_iam_policy.pdm_emr_launcher_getsecrets.arn
}

resource "aws_sns_topic_subscription" "pdm_completion_status_sns" {
  topic_arn = data.terraform_remote_state.aws_analytical_dataset_generation.outputs.pdm_cw_trigger_sns_topic.arn
  protocol  = "lambda"
  endpoint  = aws_lambda_function.pdm_emr_launcher.arn
}

resource "aws_lambda_permission" "pdm_emr_launcher_subscription" {
  statement_id  = "CWTriggerPDMSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pdm_emr_launcher.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = data.terraform_remote_state.aws_analytical_dataset_generation.outputs.pdm_cw_trigger_sns_topic.arn
}
