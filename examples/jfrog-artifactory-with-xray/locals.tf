resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

locals {
  environment_name     = "jfrog-xray-${random_string.resource_code.result}"
  // environment_name = "jfrog-xray-pzbv1"
  artifactory_join_key = "134eb13cfd3ec1fcb7e53219e7f5ee4e"

  artifactory_bootstrap_script = <<EOT
apk add yq
mkdir -p /mnt/config/bootstrap/access/etc/security
echo '${local.artifactory_join_key}' > /mnt/config/bootstrap/access/etc/security/join.key
mkdir -p /mnt/config/etc/artifactory
touch /mnt/config/etc/artifactory/artifactory.config.import.yml
echo ${base64encode(var.artifactory_licence_key)} > licence.txt
yq eval -i '.version = 1' /mnt/config/etc/artifactory/artifactory.config.import.yml
yq eval -i '.GeneralConfiguration.baseUrl = "http://${aws_lb.artifactory.dns_name}"' /mnt/config/etc/artifactory/artifactory.config.import.yml
yq eval -i '.GeneralConfiguration.licenseKey = "'"$(cat licence.txt | base64 -d)"'"' /mnt/config/etc/artifactory/artifactory.config.import.yml
yq eval -i '.OnboardingConfiguration.repoTypes[0] = "pypi"' /mnt/config/etc/artifactory/artifactory.config.import.yml
chown -R 1030:1030 /mnt/config
yq eval /mnt/config/etc/artifactory/artifactory.config.import.yml
EOT
}

# TODO: Do we want the licence key to be extractable from the task definition like this?
# TODO: Remove debug yq eval at end of script
