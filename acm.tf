resource "aws_acm_certificate" "pdm-dataset-generator" {
  certificate_authority_arn = data.terraform_remote_state.aws_certificate_authority.outputs.root_ca.arn
  domain_name               = "pdm-dataset-generator.${local.env_prefix[local.environment]}${local.dataworks_domain_name}"

  options {
    certificate_transparency_logging_preference = "DISABLED"
  }

  tags = {
    Name = "pdm_dataset_generator"
  }
}

data "aws_iam_policy_document" "pdm_dataset_acm" {
  statement {
    effect = "Allow"

    actions = [
      "acm:ExportCertificate",
    ]

    resources = [
      aws_acm_certificate.pdm-dataset-generator.arn
    ]
  }
}

resource "aws_iam_policy" "pdm_dataset_acm" {
  name        = "ACMExportPDMDatasetGeneratorCert"
  description = "Allow export of PDM Dataset Generator certificate"
  policy      = data.aws_iam_policy_document.pdm_dataset_acm.json
  tags = {
    Name = "pdm_dataset_acm"
  }
}

data "aws_iam_policy_document" "pdm_certificates" {
  statement {
    effect = "Allow"

    actions = [
      "s3:Get*",
      "s3:List*",
    ]

    resources = [
      "arn:aws:s3:::${local.mgt_certificate_bucket}*",
      "arn:aws:s3:::${local.env_certificate_bucket}/*",
    ]
  }
}

resource "aws_iam_policy" "pdm_certificates" {
  name        = "PdmGetCertificates"
  description = "Allow read access to the Crown-specific subset of the pdm Dataset"
  policy      = data.aws_iam_policy_document.pdm_certificates.json
  tags = {
    Name = "pdm_certificates"
  }
}
