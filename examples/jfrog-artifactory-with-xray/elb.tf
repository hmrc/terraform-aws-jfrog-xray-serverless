resource "aws_lb" "artifactory" {
  name               = "${local.environment_name}-artifactory"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.xray-instance-sg.id]
  subnets            = module.vpc.public_subnets
}

resource "aws_lb_target_group" "artifactory" {
  name                 = "${local.environment_name}-artifactory"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = module.vpc.vpc_id
  target_type          = "ip"
  deregistration_delay = 0

  # TODO: Tweak health check configuration
  health_check {
    healthy_threshold   = 5
    unhealthy_threshold = 10
  }
}

resource "aws_lb_listener" "artifactory" {
  load_balancer_arn = aws_lb.artifactory.arn
  port              = "80"
  protocol          = "HTTP"
  # TODO: Use HTTPS on ALB

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.artifactory.arn
  }
}
