terraform {
  required_version = "~> 1"

  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
    random = {
      source = "hashicorp/random"
    }
    template = {
      source = "hashicorp/template"
    }
    null = {
      source = "hashicorp/null"
    }
  }

  backend "s3" {
    key    = "terraform.tfstate"
    bucket = "nginx-development-environment"
    region = "us-west-2"
  }
}

provider "aws" {
}
