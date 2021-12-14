
resource "aws_ecs_cluster" "main" {
  name = var.environment_name
}

resource "aws_ecs_service" "main" {
  name                               = "xray"
  cluster                            = aws_ecs_cluster.main.arn
  task_definition                    = aws_ecs_task_definition.main.arn
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  launch_type                        = "FARGATE"

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = var.assign_public_ip
    security_groups  = [aws_security_group.ecs_task.id]
  }
}

# TODO: It takes about three goes to start a task, apparantly due to fs permissions. This delays the creation of a new stack considerably.
resource "aws_ecs_task_definition" "main" {
  family                   = var.environment_name
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.xray_task_cpu
  memory                   = var.xray_task_memory
  execution_role_arn       = aws_iam_role.ecs_execution.arn
  network_mode             = "awsvpc"

  volume {
    name = "xray-persistent-volume"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.main.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.xray.id
      }
    }
  }

  volume {
    name = "rabbitmq-persistent-volume"

    efs_volume_configuration {
      file_system_id     = aws_efs_file_system.main.id
      transit_encryption = "ENABLED"

      authorization_config {
        access_point_id = aws_efs_access_point.rabbitmq.id
      }
    }
  }

  container_definitions = jsonencode(
    [
      {
        name      = "bootstrap-helper"
        image     = "docker.io/alpine:3.15.0"
        essential = false
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group = aws_cloudwatch_log_group.main.name
            # TODO: current region
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "bootstrap-helper"
          }
        }
        mountPoints = [
          {
            containerPath = "/mnt/xray-persistent-volume/"
            sourceVolume  = "xray-persistent-volume"
          },
          {
            containerPath = "/mnt/rabbitmq-persistent-volume/"
            sourceVolume  = "rabbitmq-persistent-volume"
          }
        ]
        command = [
          "/bin/sh", "-c", replace(replace(local.bootstrap_script, "\n\n", "\n"), "\n", "; ")
        ]
      },
      {
        name  = "xray_router"
        image = "releases-docker.jfrog.io/jfrog/router:7.28.1"
        user  = "1035:1035"
        environment = [
          {
            name  = "JF_ROUTER_TOPOLOGY_LOCAL_REQUIREDSERVICETYPES"
            value = "jfxr,jfxidx,jfxana,jfxpst"
          },
          {
            name  = "JF_ROUTER_ENTRYPOINTS_EXTERNALPORT"
            value = "8082"
          },
        ]
        dependsOn = [{
          condition     = "COMPLETE"
          containerName = "bootstrap-helper"
        }]
        essential = true
        portMappings = [
          {
            containerPort = 8082
            hostPort      = 8082
          }
        ]
        mountPoints = [
          {
            containerPath = "/var/opt/jfrog/router"
            sourceVolume  = "xray-persistent-volume"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.main.name
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "router"
          }
        }
      },
      {
        name  = "xray_observability"
        image = "releases-docker.jfrog.io/jfrog/observability:1.1.3"
        user  = "1035:1035"
        dependsOn = [{
          condition     = "COMPLETE"
          containerName = "bootstrap-helper"
        }]
        essential = true
        mountPoints = [
          {
            containerPath = "/var/opt/jfrog/observability"
            sourceVolume  = "xray-persistent-volume"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.main.name
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "observability"
          }
        }
      },
      {
        name      = "xray_server"
        image     = "releases-docker.jfrog.io/jfrog/xray-server:${var.xray_version}"
        user      = "1035:1035"
        essential = true
        dependsOn = [{
          condition     = "COMPLETE"
          containerName = "bootstrap-helper"
        }]
        ulimits = [
          {
            name      = "nproc"
            hardLimit = 65535
            softLimit = 65535
          },
          {
            name      = "nofile"
            hardLimit = 40000
            softLimit = 32000
          }
        ]
        mountPoints = [
          {
            containerPath = "/var/opt/jfrog/xray"
            sourceVolume  = "xray-persistent-volume"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.main.name
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "server"
          }
        }
      },
      {
        name      = "xray_indexer"
        image     = "releases-docker.jfrog.io/jfrog/xray-indexer:${var.xray_version}"
        user      = "1035:1035"
        essential = true
        dependsOn = [{
          condition     = "COMPLETE"
          containerName = "bootstrap-helper"
        }]
        ulimits = [
          {
            name      = "nproc"
            hardLimit = 65535
            softLimit = 65535
          },
          {
            name      = "nofile"
            hardLimit = 40000
            softLimit = 32000
          }
        ]
        mountPoints = [
          {
            containerPath = "/var/opt/jfrog/xray"
            sourceVolume  = "xray-persistent-volume"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.main.name
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "indexer"
          }
        }
      },
      {
        name      = "xray_analysis"
        image     = "releases-docker.jfrog.io/jfrog/xray-analysis:${var.xray_version}"
        user      = "1035:1035"
        essential = true
        dependsOn = [{
          condition     = "COMPLETE"
          containerName = "bootstrap-helper"
        }]
        ulimits = [
          {
            name      = "nproc"
            hardLimit = 65535
            softLimit = 65535
          },
          {
            name      = "nofile"
            hardLimit = 40000
            softLimit = 32000
          }
        ]
        mountPoints = [
          {
            containerPath = "/var/opt/jfrog/xray"
            sourceVolume  = "xray-persistent-volume"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.main.name
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "analysis"
          }
        }
      },
      {
        name      = "xray_persist"
        image     = "releases-docker.jfrog.io/jfrog/xray-persist:${var.xray_version}"
        user      = "1035:1035"
        essential = true
        dependsOn = [{
          condition     = "COMPLETE"
          containerName = "bootstrap-helper"
        }]
        ulimits = [
          {
            name      = "nproc"
            hardLimit = 65535
            softLimit = 65535
          },
          {
            name      = "nofile"
            hardLimit = 40000
            softLimit = 32000
        }]
        mountPoints = [
          {
            containerPath = "/var/opt/jfrog/xray"
            sourceVolume  = "xray-persistent-volume"
          }
        ]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.main.name
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "persist"
          }
        }
      },
      {
        name  = "xray_rabbitmq"
        image = "releases-docker.jfrog.io/jfrog/xray-rabbitmq:3.8.14-management"
        user  = "rabbitmq"
        dependsOn = [{
          condition     = "COMPLETE"
          containerName = "bootstrap-helper"
        }]
        environment = [
          {
            name  = "JF_SHARED_RABBITMQ_ACTIVE_NODE_NAME"
            value = "None"
          },
          {
            name  = "JF_SHARED_RABBITMQ_CLEAN"
            value = "N"
          },
        ]
        essential  = true
        entrypoint = [""]
        command    = ["bash", "-c", "(/etc/rabbitmq/setRabbitCluster.sh &) && docker-entrypoint.sh 'rabbitmq-server'"]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group         = aws_cloudwatch_log_group.main.name
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "rabbitmq"
          }
        }

        mountPoints = [
          {
            containerPath = "/etc/rabbitmq"
            sourceVolume  = "rabbitmq-persistent-volume"
          }
        ]
      },
    ]
  )
}
