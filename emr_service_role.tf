data "aws_iam_policy_document" "emr_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["elasticmapreduce.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "emr_capacity_reservations" {
  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateLaunchTemplateVersion"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:DescribeCapacityReservations"
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "resource-groups:ListGroupResources"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role" "pdm_emr_service" {
  name               = "pdm_emr_service"
  assume_role_policy = data.aws_iam_policy_document.emr_assume_role.json
  tags = {
    Name = "pdm_emr_service"
  }
}

resource "aws_iam_role_policy_attachment" "emr_attachment" {
  role       = aws_iam_role.pdm_emr_service.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonElasticMapReduceRole"
}

resource "aws_iam_policy" "emr_capacity_reservations" {
  name        = "PDMCapacityReservations"
  description = "Allow usage of capacity reservations"
  policy      = data.aws_iam_policy_document.emr_capacity_reservations.json
  tags = {
    Name = "emr_capacity_reservations"
  }
}

resource "aws_iam_role_policy_attachment" "emr_capacity_reservations" {
  role       = aws_iam_role.pdm_emr_service.name
  policy_arn = aws_iam_policy.emr_capacity_reservations.arn
}

resource "aws_iam_role_policy_attachment" "pdm_emr_service_ebs_cmk" {
  role       = aws_iam_role.pdm_emr_service.name
  policy_arn = aws_iam_policy.pdm_dataset_ebs_cmk_encrypt.arn
}
