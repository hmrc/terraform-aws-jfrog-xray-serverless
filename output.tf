output "xray_ecs_sg_id" {
  value = aws_security_group.ecs_task.id
}

output "xray_rds_sg_id" {
  value = aws_security_group.rds_instance[0].id
}