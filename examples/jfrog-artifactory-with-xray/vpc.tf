module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  name = local.environment_name
  cidr = "10.0.0.0/16"

  azs            = data.aws_availability_zones.available.zone_ids
  public_subnets = slice(local.public_subnet_cidrs, 0, length(data.aws_availability_zones.available.zone_ids))

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = local.aws_tags
}

resource "aws_security_group" "artifactory_load_balancer" {
  name        = "artifactory-lb"
  description = "Artifactory access to LB"
  vpc_id      = module.vpc.vpc_id
  tags        = local.aws_tags

  ingress {
    description = "Artifactory ingress - allow http to ELB from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Artifactory egress - allow anything out from public subnets to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }
}

resource "aws_security_group" "artifactory_instance" {
  name        = "artifactory"
  description = "Artifactory VPC access"
  vpc_id      = module.vpc.vpc_id
  tags        = local.aws_tags
}

resource "aws_security_group_rule" "artifactory_allow_http_from_lb" {
  type                     = "ingress"
  description              = "Allow http from load balancer to artifactory_instance"
  from_port                = 8081
  to_port                  = 8082
  protocol                 = "tcp"
  security_group_id        = aws_security_group.artifactory_instance.id
  source_security_group_id = aws_security_group.artifactory_load_balancer.id
}

resource "aws_security_group_rule" "artifactory_allow_http_from_public_subnets" {
  type              = "ingress"
  description       = "Allow http from public_subnets to artifactory_instance"
  from_port         = 8081
  to_port           = 8082
  protocol          = "tcp"
  security_group_id = aws_security_group.artifactory_instance.id
  cidr_blocks       = module.vpc.public_subnets_cidr_blocks
}

resource "aws_security_group_rule" "artifactory_allow_https_to_anywhere" {
  type              = "egress"
  description       = "Artifactory allow https port to anywhere"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.artifactory_instance.id
}

resource "aws_security_group_rule" "artifactory_allow_dns_to_anywhere" {
  type              = "egress"
  description       = "Artifactory allow DNS to anywhere"
  from_port         = 53
  to_port           = 53
  protocol          = "udp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.artifactory_instance.id
}

resource "aws_security_group_rule" "artifactory_allow_all_to_vpc_public_subnets" {
  type              = "egress"
  description       = "Artifactory allow all traffic to the public subnets"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = module.vpc.public_subnets_cidr_blocks
  security_group_id = aws_security_group.artifactory_instance.id
}
