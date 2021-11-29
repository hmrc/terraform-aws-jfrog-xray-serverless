resource "aws_cloudwatch_log_group" "artifactory" {
  name              = "${local.environment_name}-artifactory"
  retention_in_days = 3
}
