terraform {
  required_version = "1.2.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.6.0"
    }
  }

  backend "s3" {
    key    = "nginx-terraform.tfstate"
    bucket = "jenkins-development-environment"
    region = "us-west-2"
  }
}

provider "aws" {
}
