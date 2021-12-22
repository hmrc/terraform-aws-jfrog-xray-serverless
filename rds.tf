resource "aws_db_instance" "main" {
  allocated_storage      = 20
  db_subnet_group_name   = var.database_subnet_group
  storage_type           = "gp2"
  engine                 = "postgres"
  engine_version         = "12.7"
  identifier             = var.environment_name
  instance_class         = "db.t3.micro"
  name                   = "jfrogxray"
  username               = "jfrogxray"
  password               = "password"
  apply_immediately      = true
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_instance.id]
  tags = local.aws_tags
}
