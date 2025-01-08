resource "aws_vpc" "platform" {
  cidr_block = "10.0.0.0/21"

  tags = {
    Name       = "platform"
  }
}

resource "aws_default_network_acl" "platform_default" {
  default_network_acl_id = aws_vpc.platform.default_network_acl_id

  subnet_ids = [
    aws_subnet.platform_private_a.id,
    aws_subnet.platform_public_a.id,
    aws_subnet.platform_private_c.id,
    aws_subnet.platform_public_c.id
  ]
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

resource "aws_default_route_table" "platform_default" {
  default_route_table_id = aws_vpc.platform.default_route_table_id
  route = []

  tags = {
    Name = "platform_default"
  }
}

resource "aws_subnet" "platform_public_a" {
  vpc_id            = aws_vpc.platform.id
  availability_zone = data.aws_availability_zone.a.name
  cidr_block        = "10.0.0.0/24"
  tags = {
    Name       = "platform_public_a"
  }
}

resource "aws_subnet" "platform_private_a" {
  vpc_id            = aws_vpc.platform.id
  availability_zone = data.aws_availability_zone.a.name
  cidr_block        = "10.0.4.0/24"
  tags = {
    Name       = "platform_private_a"
  }
}

resource "aws_subnet" "platform_public_c" {
  vpc_id            = aws_vpc.platform.id
  availability_zone = data.aws_availability_zone.c.name
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name       = "platform_public_c"
  }
}

resource "aws_subnet" "platform_private_c" {
  vpc_id            = aws_vpc.platform.id
  availability_zone = data.aws_availability_zone.c.name
  cidr_block        = "10.0.5.0/24"
  tags = {
    Name       = "platform_private_c"
  }
}
