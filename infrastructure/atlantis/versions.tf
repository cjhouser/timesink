terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 5.82.2"
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
