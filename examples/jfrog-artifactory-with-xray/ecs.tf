resource "aws_ecs_cluster" "main" {
  name = "${local.environment_name}-artifactory"
}

resource "aws_ecs_task_definition" "artifactory" {
  family                   = "${local.environment_name}-artifactory"
  requires_compatibilities = ["FARGATE"]
  cpu                = 1024
  memory             = 2048
  execution_role_arn = aws_iam_role.artifactory_ecs_execution.arn
  network_mode       = "awsvpc"
  container_definitions = jsonencode(
    [
      {
        name      = "bootstrap-helper"
        image     = "docker.io/alpine:3.15.0"
        essential = false
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group = aws_cloudwatch_log_group.artifactory.name
            # TODO: current region
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "bootstrap-helper"
          }
        }
        mountPoints = [
          {
            containerPath = "/mnt/config/"
            sourceVolume  = "bootstrap-volume"
          }
        ]
        command = [
          "/bin/sh", "-c", replace(local.artifactory_bootstrap_script, "\n", "; ")
        ]
      },
      {
        name = "artifactory"
        # TODO: pin/variablise
        image     = "releases-docker.jfrog.io/jfrog/artifactory-pro:latest"
        essential = true
        dependsOn = [{
          condition     = "COMPLETE"
          containerName = "bootstrap-helper"
        }]
        logConfiguration = {
          logDriver = "awslogs"
          options = {
            awslogs-group = aws_cloudwatch_log_group.artifactory.name
            # TODO: current region
            awslogs-region        = "eu-west-2"
            awslogs-stream-prefix = "artifactory"
          }
        }
        portMappings = [
          {
            containerPort = 8082
            hostPort      = 8082
          },
          {
            containerPort = 8081
            hostPort      = 8081
          }
        ]
        mountPoints = [
          {
            containerPath = "/opt/jfrog/artifactory/var"
            sourceVolume  = "bootstrap-volume"
          }
        ]
      }
  ])

  volume {
    name = "bootstrap-volume"
  }



}

resource "aws_ecs_service" "jfrog_artifactory_service" {
  name                               = "artifactory"
  depends_on                         = [aws_lb.artifactory]
  cluster                            = aws_ecs_cluster.main.arn
  task_definition                    = aws_ecs_task_definition.artifactory.arn
  desired_count                      = 1
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  launch_type                        = "FARGATE"

  network_configuration {
    assign_public_ip = true
    subnets          = module.vpc.public_subnets
    security_groups  = [aws_security_group.xray-instance-sg.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.artifactory.arn
    container_name   = "artifactory"
    container_port   = 8082
  }
}
