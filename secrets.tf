data "aws_secretsmanager_secret" "pdm_secret" {
  name = local.secret_name
}

data "aws_secretsmanager_secret" "metastore_reader_secret" {
  name = local.metastore_reader_secret_name
}
// TODO: determine wether to get the secret using CLI, or pass into script using jsonencode(data.aws_secretsmanager_secret_version.metastore_secret.secret_string)["password"]
//data "aws_secretsmanager_secret_version" "metastore_secret"{
//  secret_id = data.aws_secretsmanager_secret.metastore_secret.id
//}

data "aws_iam_policy_document" "pdm_dataset_secretsmanager" {
  statement {
    effect = "Allow"

    actions = [
      "secretsmanager:GetSecretValue",
    ]

    resources = [
      data.aws_secretsmanager_secret.pdm_secret.arn,
      data.aws_secretsmanager_secret.metastore_secret.arn
    ]
  }
}

resource "aws_iam_policy" "pdm_dataset_secretsmanager" {
  name        = "PDMDatasetGeneratorSecretsManager"
  description = "Allow reading of PDM config values"
  policy      = data.aws_iam_policy_document.pdm_dataset_secretsmanager.json
}
