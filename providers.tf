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