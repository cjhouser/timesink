data "aws_region" "current" {}

data "aws_availability_zone" "a" {
  name = "${data.aws_region.current.name}a"
}

data "aws_availability_zone" "c" {
  name = "${data.aws_region.current.name}c"
}

data "aws_caller_identity" "current" {}
