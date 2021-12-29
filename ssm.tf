resource "aws_ssm_parameter" "artifactory_join_key" {
  name  = "/${var.environment_name}/artifactory-join-key"
  type  = "SecureString"
  value = var.artifactory_join_key
  tags  = local.combined_aws_tags
}

resource "aws_ssm_parameter" "rds_password" {
  name  = "/${var.environment_name}/rds/password"
  type  = "SecureString"
  value = local.rds_password
  tags  = local.combined_aws_tags
}
