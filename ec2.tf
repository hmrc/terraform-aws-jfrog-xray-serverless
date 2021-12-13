# TODO: Look at tightening the xray rules.

resource "aws_security_group" "ecs_task" {
  name        = "${var.environment_name}-ecs-task"
  description = "Security group for the Xray ECS task"
  vpc_id      = var.vpc_id

  ingress {
    description = "Xray ingress - allow all tcp from public subnets"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Xray egress - allow everything out to public subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
  tags = {
    Name = "Xray"
  }
}

resource "aws_security_group" "efs_file_system" {
  name        = "${var.environment_name}-efs-file system"
  description = "Security group for the Xray EFS file system"
  vpc_id      = var.vpc_id

  ingress {
    description = "Xray ingress - allow all tcp from public subnets"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Xray egress - allow everything out to public subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
  tags = {
    Name = "Xray"
  }
}

resource "aws_security_group" "rds_instance" {
  name        = "${var.environment_name}-rds-instance"
  description = "Security group for the Xray RDS instance"
  vpc_id      = var.vpc_id

  ingress {
    description = "Xray ingress - allow all tcp from public subnets"
    from_port   = 0
    to_port     = 65535
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Xray egress - allow everything out to public subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
}
  tags = {
    Name = "Xray"
  }
}
