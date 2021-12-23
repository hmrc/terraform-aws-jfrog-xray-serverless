data "aws_caller_identity" "current" {}

data "aws_ssm_parameter" "rds_password" {
    name = "/terraform-aws-jfrog-xray-serverless/rds/password"
}