module "jfrog_xray" {
  source = "../../"

  environment_name      = local.environment_name
  artifactory_url       = "http://${aws_lb.artifactory.dns_name}"
  artifactory_join_key  = local.artifactory_join_key
  security_group_id     = aws_security_group.xray-instance-sg.id
  subnet_ids            = module.vpc.public_subnets
  assign_public_ip      = true
  database_subnet_group = module.vpc.database_subnet_group
}

resource "null_resource" "wait_for_xray" {
  depends_on = [
    module.jfrog_xray
  ]

  triggers = {
    "xray_task_definition_revision" = "module.jfrog_xray.aws_ecs_task_definition.main.revision"
  }

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "until curl --silent --fail http://${aws_lb.artifactory.dns_name}/xray/api/v1/system/ping; do sleep 10s; done"
  }
}
