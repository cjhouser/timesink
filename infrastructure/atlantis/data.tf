data "aws_region" "current" {}

data "aws_availability_zone" "a" {
  name = "${data.aws_region.current.name}a"
}