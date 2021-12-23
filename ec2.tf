resource "aws_security_group" "ecs_task" {
  name        = "${var.environment_name}-ecs-task"
  description = "Security group for the Xray ECS task"
  vpc_id      = var.vpc_id
  tags        = local.aws_tags
}

resource "aws_security_group_rule" "ecs_task_allow_http_from_artifactory" {
  type                     = "ingress"
  description              = "Allow all traffic into ecs_task"
  from_port                = 8082
  to_port                  = 8082
  protocol                 = "tcp"
  source_security_group_id = var.artifactory_security_group_id
  security_group_id        = aws_security_group.ecs_task.id
}

resource "aws_security_group_rule" "ecs_task_allow_http_to_artifactory" {
  type                     = "egress"
  description              = "Allow http out from ecs_task to artifactory"
  from_port                = 8082
  to_port                  = 8082
  protocol                 = "tcp"
  source_security_group_id = var.artifactory_security_group_id
  security_group_id        = aws_security_group.ecs_task.id
}

#TO DO - make this optional (only needed for the tests)
resource "aws_security_group_rule" "ecs_task_allow_http_to_anywhere" {
  type              = "egress"
  description       = "Allow http out from ecs_task to anywhere"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_task.id
}

resource "aws_security_group_rule" "ecs_task_allow_https_to_anywhere" {
  type              = "egress"
  description       = "Allow https out from ecs_task to anywhere"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_task.id
}

resource "aws_security_group_rule" "ecs_task_allow_dns_to_anywhere" {
  type              = "egress"
  description       = "Allow DNS out from ecs_task to anywhere"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ecs_task.id
}

resource "aws_security_group" "efs_file_system" {
  name        = "${var.environment_name}-efs-file system"
  description = "Security group for the Xray EFS file system"
  vpc_id      = var.vpc_id
  tags        = local.aws_tags
}

resource "aws_security_group_rule" "ecs_task_allow_nfs_to_efs" {
  type                     = "egress"
  description              = "ECS Task allow NFS to EFS"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.efs_file_system.id
  security_group_id        = aws_security_group.ecs_task.id
}

resource "aws_security_group_rule" "efs_allow_nfs_from_ecs_task" {
  type                     = "ingress"
  description              = "EFS allow NFS from ECS Task"
  from_port                = 2049
  to_port                  = 2049
  protocol                 = "tcp"
  security_group_id        = aws_security_group.efs_file_system.id
  source_security_group_id = aws_security_group.ecs_task.id
}

resource "aws_security_group" "rds_instance" {
  name        = "${var.environment_name}-rds-instance"
  description = "Security group for the Xray RDS instance"
  vpc_id      = var.vpc_id
  tags        = local.aws_tags
}

resource "aws_security_group_rule" "ecs_task_allow_postgres_to_rds" {
  type                     = "egress"
  description              = "ECS Task allow Postgres to RDS"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.rds_instance.id
  security_group_id        = aws_security_group.ecs_task.id
}

resource "aws_security_group_rule" "rds_allow_postgres_from_ecs_task" {
  type                     = "ingress"
  description              = "RDS allow Postgres from ECS Task"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds_instance.id
  source_security_group_id = aws_security_group.ecs_task.id
}
