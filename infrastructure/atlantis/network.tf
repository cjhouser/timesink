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
    aws_subnet.platform_private_c.id
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

resource "aws_network_acl" "https" {
  vpc_id = aws_vpc.platform.id

  egress {
    protocol   = "tcp"
    rule_no    = 200
    action     = "allow"
    cidr_block = "10.0.0.0/21"
    from_port  = 32768
    to_port    = 61000
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  tags = {
    Name = "https"
  }
}

resource "aws_network_acl_association" "platform_public_a_https" {
  network_acl_id = aws_network_acl.https.id
  subnet_id = aws_subnet.platform_public_a.id
}

resource "aws_network_acl_association" "platform_public_c_https" {
  network_acl_id = aws_network_acl.https.id
  subnet_id = aws_subnet.platform_public_c.id
}

resource "aws_security_group" "ingress_https" {
  name        = "ingress_https"
  description = "Allow inbound HTTPS traffic"
  vpc_id      = aws_vpc.platform.id
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.ingress_https.id
  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_internet_gateway" "platform" {
  vpc_id = aws_vpc.platform.id
  tags = {
    Name = "platform"
  }
}

resource "aws_lb" "platform" {
  name               = "platform"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ingress_https.id]
  subnets            = [
    aws_subnet.platform_public_a.id,
    aws_subnet.platform_public_c.id
  ]

  enable_deletion_protection = true

  depends_on = [
    aws_internet_gateway.platform
  ]
}