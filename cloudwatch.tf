resource "aws_cloudwatch_log_group" "main" {
  name              = "${var.environment_name}-xray"
  retention_in_days = 3
  tags              = local.aws_tags
}
