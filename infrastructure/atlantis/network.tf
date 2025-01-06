resource "aws_vpc" "platform" {
  cidr_block = "10.0.0.0/21"

  tags = {
    Name       = "platform"
  }
}
