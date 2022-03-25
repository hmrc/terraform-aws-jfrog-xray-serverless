resource "aws_efs_file_system" "main" {
  creation_token = var.environment_name
  tags           = merge(local.combined_aws_tags, { Name = "${var.environment_name}-xray" })
}

resource "aws_efs_mount_target" "main" {
  count           = length(var.subnet_ids)
  file_system_id  = aws_efs_file_system.main.id
  subnet_id       = var.subnet_ids[count.index]
  security_groups = [aws_security_group.efs_file_system.id]
}

resource "aws_efs_access_point" "xray" {
  file_system_id = aws_efs_file_system.main.id
  tags           = local.combined_aws_tags

  posix_user {
    uid = local.xray_uid
    gid = local.xray_uid
  }

  root_directory {
    path = "/xray"

    creation_info {
      owner_gid   = local.xray_uid
      owner_uid   = local.xray_uid
      permissions = 755
    }
  }
}

resource "aws_efs_access_point" "rabbitmq" {
  file_system_id = aws_efs_file_system.main.id
  tags           = local.combined_aws_tags

  posix_user {
    uid = local.rabbitmq_uid
    gid = local.rabbitmq_uid
  }

  root_directory {
    path = "/rabbitmq"

    creation_info {
      owner_gid   = local.rabbitmq_uid
      owner_uid   = local.rabbitmq_uid
      permissions = 755
    }
  }
}
