resource "aws_db_instance" "main" {
  count                  = var.db_endpoint == "" ? 1 : 0
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.main.name
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "12.7"
  identifier             = var.environment_name
  instance_class         = "db.t3.micro"
  name                   = "jfrogxray"
  username               = "artifactory"
  password               = local.rds_password
  apply_immediately      = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_instance[0].id]
  tags                   = local.combined_aws_tags
}

resource "aws_db_subnet_group" "main" {
  count      = var.db_endpoint == "" ? 1 : 0
  name       = var.environment_name
  subnet_ids = var.subnet_ids
  tags       = local.combined_aws_tags
}


