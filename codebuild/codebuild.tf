resource "aws_codebuild_project" "xray_test_codebuild" {
# TODO - variablise name
  name          = "jfrog-xray-test-pipeline"
  service_role  = aws_iam_role.codebuild-xray-test-execution.arn
  build_timeout = "60"
  artifacts {
    type = "NO_ARTIFACTS"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:5.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
  }
  logs_config {
    cloudwatch_logs {}
  }
  source {
    # TODO - add github auth
    type            = "GITHUB"
    location        = "https://github.com/hmrc/terraform-aws-jfrog-xray-serverless.git"
    git_clone_depth = 1
    buildspec = yamlencode({
      version = 0.2

      phases = {
        install = {
          commands = [
            "curl -Lo go1.17.5.linux-amd64.tar.gz https://go.dev/dl/go1.17.5.linux-amd64.tar.gz",
            "tar -C /usr/local -zxf go1.17.5.linux-amd64.tar.gz",
            "curl -Lo terraform_1.1.0_linux_amd64.zip https://releases.hashicorp.com/terraform/1.1.0/terraform_1.1.0_linux_amd64.zip",
            "unzip terraform_1.1.0_linux_amd64.zip",
            "mv terraform /usr/local/bin/",
            "export PATH=$PATH:/usr/local/go/bin"
          ]
        }
        build = {
          commands = [
            "cd test",
            "go test -v -timeout 30m"
          ]
        }
      }
    })
  }
  # TODO - variablise branch
  source_version = "PBD-2401-initial"
}