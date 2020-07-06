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
  handler       = "emr_launcher.handler"
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
}

resource "aws_cloudwatch_event_rule" "pdm_emr_launcher_schedule" {
  name                = "pdm_emr_launcher_schedule"
  description         = "Triggers PDM EMR Launcher"
  schedule_expression = format("cron(%s)", local.pdm_emr_lambda_schedule[local.environment])
}

resource "aws_cloudwatch_event_target" "pdm_emr_launcher_target" {
  rule      = aws_cloudwatch_event_rule.pdm_emr_launcher_schedule.name
  target_id = "pdm_emr_launcher_target"
  arn       = aws_lambda_function.pdm_emr_launcher.arn
}

resource "aws_iam_role" "pdm_emr_launcher_lambda_role" {
  name               = "pdm_emr_launcher_lambda_role"
  assume_role_policy = data.aws_iam_policy_document.pdm_emr_launcher_assume_policy.json
}

resource "aws_lambda_permission" "pdm_emr_launcher_invoke_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.pdm_emr_launcher.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.pdm_emr_launcher_schedule.arn
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
}

resource "aws_iam_policy" "pdm_emr_launcher_runjobflow_policy" {
  name        = "PDMRunJobFlow"
  description = "Allow PDM to run job flow"
  policy      = data.aws_iam_policy_document.pdm_emr_launcher_runjobflow_policy.json
}

resource "aws_iam_policy" "pdm_emr_launcher_pass_role_policy" {
  name        = "PDMPassRole"
  description = "Allow PDM to pass role"
  policy      = data.aws_iam_policy_document.pdm_emr_launcher_pass_role_document.json
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