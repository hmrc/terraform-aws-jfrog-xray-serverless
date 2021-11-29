terraform {
  required_version = ">= 1.0.11"

  required_providers {
    artifactory = {
      source  = "registry.terraform.io/jfrog/artifactory"
      version = "~> 2.6.20"
    }
  }
}
