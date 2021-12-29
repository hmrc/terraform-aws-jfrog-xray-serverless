terraform {
  required_version = "~> 1.0.6"

  backend "s3" {
    key            = "terraform-aws-jfrog-xray-serverless-pipeline-state/v1/state"
    region         = "eu-west-2"
    dynamodb_table = "terraform-aws-jfrog-xray-serverless-pipeline-lock"
  }
}
