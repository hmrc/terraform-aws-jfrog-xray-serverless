resource "aws_iam_role" "artifactory_ecs_execution" {
  name = "${local.environment_name}-artifactory-ecs-execution"
  tags = local.aws_tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

  inline_policy {
    name = "logging"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents"
          ]
          Effect   = "Allow"
          Resource = "${aws_cloudwatch_log_group.artifactory.arn}:*"
        },
      ]
    })
  }

  inline_policy {
    name = "ssm"

    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters"
          ]
          Effect   = "Allow"
          Resource = "arn:aws:ssm:eu-west-2:${data.aws_caller_identity.current.account_id}:parameter/terraform-aws-jfrog-xray-serverless/artifactory/licence-key-base64"
        },
      ]
    })
  }
}
