resource "aws_security_group_rule" "ingress_pdm_metastore_v2" {
  description              = "Allow mysql traffic to Aurora RDS from PDM"
  from_port                = 3306
  protocol                 = "tcp"
  security_group_id        = data.terraform_remote_state.internal_compute.outputs.hive_metastore_v2.security_group.id
  to_port                  = 3306
  type                     = "ingress"
  source_security_group_id = aws_security_group.pdm_common.id
}

resource "aws_security_group_rule" "egress_pdm_metastore_v2" {
  description              = "Allow mysql traffic to Aurora RDS from PDM"
  from_port                = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.pdm_common.id
  to_port                  = 3306
  type                     = "egress"
  source_security_group_id = data.terraform_remote_state.internal_compute.outputs.hive_metastore_v2.security_group.id
}
