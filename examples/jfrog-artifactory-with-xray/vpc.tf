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

# TODO: Split into separate groups and tighten

resource "aws_security_group" "xray-instance-sg" {
  name        = "xray"
  description = "Xray VPC access"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "Xray ingress from VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Xray egress to VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Xray"
  }
}
