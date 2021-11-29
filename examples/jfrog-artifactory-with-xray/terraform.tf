terraform {
  required_version = ">= 1.0.11"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
