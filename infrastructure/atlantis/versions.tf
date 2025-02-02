terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.82.2"
    }
    github = {
      source  = "integrations/github"
      version = "= 6.5.0"
    }
  }
}

provider "aws" {
  region = "us-west-1"

  default_tags {
    tags = {
      Managed-by = "terraform"
    }
  }
}

provider "github" {}