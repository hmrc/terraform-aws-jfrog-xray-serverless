resource "aws_cloudwatch_log_group" "main" {
  name              = "/aws/codebuild/${local.name}"
  retention_in_days = 14
}
