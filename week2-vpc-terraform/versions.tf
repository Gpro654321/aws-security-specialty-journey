terraform {
  required_version = ">= 1.16.1" # installed version of Terraform

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.63.0"
    }
  }
}
