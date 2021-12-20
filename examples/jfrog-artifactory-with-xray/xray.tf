module "jfrog_xray" {
  source = "../../"

  environment_name              = local.environment_name
  artifactory_url               = "http://${aws_lb.artifactory.dns_name}"
  artifactory_join_key          = local.artifactory_join_key
  subnet_ids                    = module.vpc.public_subnets
  assign_public_ip              = true
  database_subnet_group         = module.vpc.database_subnet_group
  vpc_id                        = module.vpc.vpc_id
  artifactory_security_group_id = aws_security_group.artifactory_instance.id
}

# TODO: Waiters need to timeout

resource "null_resource" "wait_for_artifactory" {
  depends_on = [
    module.jfrog_xray
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
counter=0 
until curl --silent --fail http://${aws_lb.artifactory.dns_name}/artifactory/api/system/ping
do
  if [ "$counter" -gt 60 ] 
  then
    exit 1
  fi
  sleep 10s
  ((counter++))
done
EOT
  }
}

resource "null_resource" "wait_for_xray" {
  depends_on = [
    null_resource.wait_for_artifactory
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
counter=0
until curl --silent --fail http://${aws_lb.artifactory.dns_name}/xray/api/v1/system/ping
do
  if [ "$counter" -gt 60 ] 
  then
    exit 1
  fi
  sleep 10s
  ((counter++))
done
EOT
  }
}
