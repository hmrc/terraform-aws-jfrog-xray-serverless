resource "aws_iam_role" "ecs_execution" {
  name = "${var.environment_name}-xray-ecs-execution"
  tags = local.combined_aws_tags

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
}

resource "aws_iam_role_policy" "logging" {
  name   = "logging"
  role   = aws_iam_role.ecs_execution.id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "logs:CreateLogStream",
            "logs:PutLogEvents",
          ]
          Effect   = "Allow"
          Resource = "${aws_cloudwatch_log_group.main.arn}:*"
        },
      ]
    }
  )
}

resource "aws_iam_role_policy" "module_db_ssm" {
  name   = "db-ssm"
  role   = aws_iam_role.ecs_execution.id
  count  = var.db_endpoint == "" ? 1 : 0
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters"
          ]
          Effect = "Allow"
          Resource = [
            aws_ssm_parameter.rds_password[0].arn
          ]
        },
      ]
    }
  )
}

resource "aws_iam_role_policy" "byo_db_ssm" {
  name = "db-ssm"
  role = aws_iam_role.ecs_execution.id
  count  = var.db_endpoint == "" ? 0 : 1
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters"
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter${var.db_ssm_parameter}"
          ]
        },
      ]
    }
  )
}

resource "aws_iam_role_policy" "join_key_ssm" {
  name   = "join-key-ssm"
  role   = aws_iam_role.ecs_execution.id
  policy = jsonencode(
    {
      Version = "2012-10-17"
      Statement = [
        {
          Action = [
            "ssm:GetParameter",
            "ssm:GetParameters"
          ]
          Effect = "Allow"
          Resource = [
            "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/${var.environment_name}-artifactory/artifactory/join-key"
          ]
        },
      ]
    }
  )
}