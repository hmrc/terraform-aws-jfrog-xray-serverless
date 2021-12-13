module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.64.0"

  name = local.environment_name
  cidr = "10.0.0.0/16"

  # TODO: Variabalise region?
  azs              = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  public_subnets   = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  database_subnets = ["10.0.104.0/24", "10.0.105.0/24", "10.0.106.0/24"]

  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Terraform   = "true"
    Environment = "sandbox"
  }

}

resource "aws_security_group" "artifactory-lb-access" {
  name = "artifactory-lb"
  description = "Artifactory access to LB"
  vpc_id      = module.vpc.vpc_id
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
  tags = {
    Name = "Artifactory-lb"
  }
}

resource "aws_security_group" "artifactory-instance-sg" {
  name        = "artifactory"
  description = "Artifactory VPC access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Artifactory ingress - internal communication from public subnets (Xray)"
    from_port   = 8081
    to_port     = 8082
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }
  ingress {
    description = "Artifactory ingress - http from ELB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }
  egress {
    description = "Artifactory egress - port 443 outbound to anywhere for pulling container images"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Artifactory egress - DNS resolution"
    from_port   = 53
    to_port     = 53
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "Artifactory egress - anything to the public subnets"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = module.vpc.public_subnets_cidr_blocks
  }
  tags = {
    Name = "Artifactory"
  }
}
