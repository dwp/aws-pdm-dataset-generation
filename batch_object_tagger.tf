locals {
  pdm_object_tagger_image = "${local.account.management}.${data.terraform_remote_state.aws_ingestion.outputs.vpc.vpc.ecr_dkr_domain_name}/dataworks-s3-object-tagger:${var.image_version.s3-object-tagger}"
}

# AWS Batch Job IAM role
data "aws_iam_policy_document" "batch_assume_policy" {
  statement {
    sid    = "BatchAssumeRolePolicy"
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]

      type = "Service"
    }
  }
}

resource "aws_iam_role" "pdm_object_tagger" {
  name               = "pdm_object_tagger"
  assume_role_policy = data.aws_iam_policy_document.batch_assume_policy.json
  tags               = local.common_tags
}

data "aws_iam_policy_document" "pdm_object_tagger" {
  statement {
    sid    = "AllowS3Tagging"
    effect = "Allow"

    actions = [
      "s3:ListObjects",
      "s3:GetObject",
      "s3:*Tagging"
    ]

    resources = [
      data.terraform_remote_state.adg.outputs.published_bucket.arn,
    ]
  }
}

resource "aws_iam_policy" "pdm_object_tagger" {
  name   = "pdm_object_tagger"
  policy = data.aws_iam_policy_document.pdm_object_tagger.json
}

resource "aws_iam_role_policy_attachment" "pdm_object_tagger" {
  role       = aws_iam_role.pdm_object_tagger.name
  policy_arn = aws_iam_policy.pdm_object_tagger.arn
}

resource "aws_iam_role_policy_attachment" "pdm_object_tagger_ecs" {
  role       = aws_iam_role.pdm_object_tagger.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "pdm_object_tagger_batch_ecr" {
  role       = aws_iam_role.pdm_object_tagger.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_batch_job_queue" "pdm_object_tagger" {
  //  TODO: Move compute environment to fargate once Terraform supports it.
  compute_environments = [data.terraform_remote_state.aws_ingestion.outputs.k2hb_reconciliation_trimmer_batch.arn]
  name                 = "pdm_object_tagger"
  priority             = 10
  state                = "ENABLED"
}

resource "aws_batch_job_definition" "pdm_object_tagger" {
  name = "pdm_object_tagger_job"
  type = "container"

  container_properties = <<CONTAINER_PROPERTIES
  {
      "image": "${local.pdm_object_tagger_image}",
      "jobRoleArn" : "${aws_iam_role.pdm_object_tagger.arn}",
      "memory": 1024,
      "vcpus": 2,
      "environment": [
          {"name": "LOG_LEVEL", "value": "INFO"},
          {"name": "AWS_DEFAULT_REGION", "value": "eu-west-2"},
          {"name": "S3_BUCKET", "value": "${data.terraform_remote_state.adg.outputs.published_bucket.id}"},
          {"name": "ENVIRONMENT", "value": "${local.environment}"}

      ],
      "ulimits": [
        {
          "hardLimit": 1024,
          "name": "nofile",
          "softLimit": 1024
        }
      ]
  }
  CONTAINER_PROPERTIES
}
