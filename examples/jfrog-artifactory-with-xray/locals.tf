resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

locals {
  environment_name = "jfrog-xray-${random_string.resource_code.result}"
  aws_tags = {
    environment_name = local.environment_name
    terraform_module = "terraform-aws-jfrog-xray-serverless"
  }
  public_subnet_cidrs          = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24", "10.0.104.0/24", "10.0.105.0/24", "10.0.106.0/24"]
  artifactory_version          = "7.29.8"
  artifactory_join_key         = "134eb13cfd3ec1fcb7e53219e7f5ee4e"
  artifactory_bootstrap_script = <<EOT
apk add yq
mkdir -p /mnt/config/bootstrap/access/etc/security
echo '${local.artifactory_join_key}' > /mnt/config/bootstrap/access/etc/security/join.key
mkdir -p /mnt/config/etc/artifactory
touch /mnt/config/etc/artifactory/artifactory.config.import.yml
yq eval -i '.version = 1' /mnt/config/etc/artifactory/artifactory.config.import.yml
yq eval -i '.GeneralConfiguration.baseUrl = "http://${aws_lb.artifactory.dns_name}"' /mnt/config/etc/artifactory/artifactory.config.import.yml
yq eval -i '.GeneralConfiguration.licenseKey = "'"$(echo $${ARTIFACTORY_LICENCE_KEY} | base64 -d)"'"' /mnt/config/etc/artifactory/artifactory.config.import.yml
yq eval -i '.OnboardingConfiguration.repoTypes[0] = "pypi"' /mnt/config/etc/artifactory/artifactory.config.import.yml
chown -R 1030:1030 /mnt/config
EOT
}

# TODO: Do we want the licence key to be extractable from the task definition like this?
