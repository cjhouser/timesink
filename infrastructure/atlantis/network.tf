resource "aws_vpc" "platform" {
  cidr_block = "10.0.0.0/21"

  tags = {
    Name       = "platform"
  }
}

resource "aws_default_network_acl" "platform_default" {
  default_network_acl_id = aws_vpc.platform.default_network_acl_id

  tags = {
    Name = "platform_default"
  }
}

resource "aws_default_security_group" "platform_default" {
  vpc_id = aws_vpc.platform.id

  tags = {
    Name = "platform_default"
  }
}
