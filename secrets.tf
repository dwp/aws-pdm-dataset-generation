data "aws_secretsmanager_secret" "pdm_secret" {
  name = local.secret_name
}

data "aws_iam_policy_document" "pdm_dataset_secretsmanager" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      data.aws_secretsmanager_secret.pdm_secret.arn
    ]
  }
}

resource "aws_iam_policy" "pdm_dataset_secretsmanager" {
  name        = "PDMDatasetGeneratorSecretsManager"
  description = "Allow reading of PDM config values"
  policy      = data.aws_iam_policy_document.pdm_dataset_secretsmanager.json
}
