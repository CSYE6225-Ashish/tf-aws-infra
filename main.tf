terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.87.0, < 7.0.0"
    }
  }

  required_version = ">= 1.2.0"
}


provider "aws" {
  profile = var.profile
  region  = var.region
}


data "aws_availability_zones" "available" {}




