locals {
  data_classification = {
    config_bucket = data.terraform_remote_state.common.outputs.config_bucket
    config_prefix = data.terraform_remote_state.aws_s3_object_tagger.outputs.pdm_object_tagger_data_classification.config_prefix
  }
}

# AWS IAM for Cloudwatch event triggers
data "aws_iam_policy_document" "cloudwatch_events_assume_role" {
  statement {
    sid    = "CloudwatchEventsAssumeRolePolicy"
    effect = "Allow"

    actions = ["sts:AssumeRole"]

    principals {
      identifiers = ["events.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role" "allow_batch_job_submission" {
  name               = "AllowBatchJobSubmission"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_events_assume_role.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "allow_batch_job_submission" {
  statement {
    sid    = "AllowBatchJobSubmission"
    effect = "Allow"

    actions = [
      "batch:SubmitJob",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "allow_batch_job_submission" {
  name   = "AllowBatchJobSubmission"
  policy = data.aws_iam_policy_document.allow_batch_job_submission.json
}

resource "aws_iam_role_policy_attachment" "allow_batch_job_submission" {
  role       = aws_iam_role.allow_batch_job_submission.name
  policy_arn = aws_iam_policy.allow_batch_job_submission.arn
}

resource "aws_cloudwatch_event_rule" "pdm_terminated_with_errors_rule" {
  name          = "pdm_terminated_with_errors_rule"
  description   = "Sends failed message to slack when pdm cluster terminates with errors"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED_WITH_ERRORS"
    ],
    "name": [
      "pdm-dataset-generator"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_metric_alarm" "pdm_failed_with_errors" {
  alarm_name                = "pdm_failed_with_errors"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "This metric monitors cluster termination with errors"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.pdm_terminated_with_errors_rule.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "pdm_failed_with_errors",
      notification_type = "Error",
      severity          = "Critical"
    },
  )
}

resource "aws_cloudwatch_event_rule" "pdm_success" {
  name          = "pdm_success"
  description   = "checks that all steps complete"
  event_pattern = <<EOF
{
  "source": [
    "aws.emr"
  ],
  "detail-type": [
    "EMR Cluster State Change"
  ],
  "detail": {
    "state": [
      "TERMINATED"
    ],
    "name": [
      "pdm-dataset-generator"
    ],
    "stateChangeReason": [
      "{\"code\":\"ALL_STEPS_COMPLETED\",\"message\":\"Steps completed\"}"
    ]
  }
}
EOF
}

resource "aws_cloudwatch_event_target" "pdm_success_start_object_tagger" {
  target_id = "pdm_success"
  rule = aws_cloudwatch_event_rule.pdm_success.name
  arn = data.terraform_remote_state.aws_s3_object_tagger.outputs.pdm_object_tagger_batch.job_queue.arn
  role_arn = aws_iam_role.allow_batch_job_submission.arn

  batch_target {
    job_definition = data.terraform_remote_state.aws_s3_object_tagger.outputs.pdm_object_tagger_batch.job_definition.id
    job_name = "pdm_success_cloudwatch_event"
  }

  input = "{\"Parameters\": {\"data-s3-prefix\": \"data/uc\", \"csv-location\": \"s3://${local.data_classification.config_bucket.id}/${local.data_classification.config_prefix}/data_classification.csv\"}}"
}

resource "aws_cloudwatch_metric_alarm" "pdm_success" {
  alarm_name                = "pdm_completed_all_steps"
  comparison_operator       = "GreaterThanOrEqualToThreshold"
  evaluation_periods        = "1"
  metric_name               = "TriggeredRules"
  namespace                 = "AWS/Events"
  period                    = "60"
  statistic                 = "Sum"
  threshold                 = "1"
  alarm_description         = "Monitoring pdm completion"
  insufficient_data_actions = []
  alarm_actions             = [data.terraform_remote_state.security-tools.outputs.sns_topic_london_monitoring.arn]
  dimensions = {
    RuleName = aws_cloudwatch_event_rule.pdm_success.name
  }
  tags = merge(
    local.common_tags,
    {
      Name              = "pdm_completed_all_steps",
      notification_type = "Information",
      severity          = "Critical"
    },
  )
}
