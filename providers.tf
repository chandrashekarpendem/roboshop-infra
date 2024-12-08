terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.54.0"
    }
  }
  required_version = ">= 1.0.0" # Adjust based on your Terraform version requirement
}

provider "aws" {
  region = "us-east-1"  # Set your desired region
}