resource "aws_ssm_parameter" "rds_password" {
  name  = "/${var.environment_name}/rds/password"
  type  = "SecureString"
  value = local.rds_password
  tags = local.aws_tags
}