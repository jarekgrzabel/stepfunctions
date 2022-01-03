terraform {
  required_version = ">= 1.1.2"
  required_providers {
    aws = {
      version = ">= 3.61.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}
