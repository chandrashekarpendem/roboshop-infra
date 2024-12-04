module "network_vpc" {
  source = "github.com/chandrashekarpendem/Terraform-module-vpc.git"

  for_each    = var.vpc
  env         = var.env
  cidr_block  = each.value.cidr_block
  public_cidr_block= each.value.public_cidr_block
  private_cidr_block= each.value.private_cidr_block

}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"  # Or the version you need
    }
  }

  required_version = ">= 1.0.0"
}

provider "aws" {
  region = "us-east-1"  # Set your desired region
}