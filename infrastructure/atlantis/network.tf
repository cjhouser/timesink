resource "aws_vpc" "platform" {
  cidr_block = "10.0.0.0/21"

  tags = {
    Name = "platform"
  }
}

resource "aws_default_network_acl" "platform_default" {
  default_network_acl_id = aws_vpc.platform.default_network_acl_id

  subnet_ids = []
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
  route                  = []

  tags = {
    Name = "platform_default"
  }
}

resource "aws_route_table" "platform_public" {
  vpc_id = aws_vpc.platform.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.platform.id
  }

  route {
    cidr_block = aws_vpc.platform.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "platform_public"
  }
}

resource "aws_route_table" "platform_private" {
  vpc_id = aws_vpc.platform.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.platform_public_a.id
  }

  route {
    cidr_block = aws_vpc.platform.cidr_block
    gateway_id = "local"
  }

  tags = {
    Name = "platform_private"
  }
}

resource "aws_route_table_association" "platform_public_a" {
  subnet_id      = aws_subnet.platform_public_a.id
  route_table_id = aws_route_table.platform_public.id
}

resource "aws_route_table_association" "platform_public_c" {
  subnet_id      = aws_subnet.platform_public_c.id
  route_table_id = aws_route_table.platform_public.id
}

resource "aws_route_table_association" "platform_private_a" {
  subnet_id      = aws_subnet.platform_private_a.id
  route_table_id = aws_route_table.platform_private.id
}

resource "aws_route_table_association" "platform_private_c" {
  subnet_id      = aws_subnet.platform_private_c.id
  route_table_id = aws_route_table.platform_private.id
}

resource "aws_subnet" "platform_public_a" {
  vpc_id                  = aws_vpc.platform.id
  availability_zone       = data.aws_availability_zone.a.name
  map_public_ip_on_launch = true
  cidr_block              = "10.0.0.0/24"
  tags = {
    Name = "platform_public_a"
  }
}

resource "aws_subnet" "platform_private_a" {
  vpc_id            = aws_vpc.platform.id
  availability_zone = data.aws_availability_zone.a.name
  cidr_block        = "10.0.4.0/24"
  tags = {
    Name = "platform_private_a"
  }
}

resource "aws_subnet" "platform_public_c" {
  vpc_id                  = aws_vpc.platform.id
  availability_zone       = data.aws_availability_zone.c.name
  map_public_ip_on_launch = true
  cidr_block              = "10.0.1.0/24"
  tags = {
    Name = "platform_public_c"
  }
}

resource "aws_subnet" "platform_private_c" {
  vpc_id            = aws_vpc.platform.id
  availability_zone = data.aws_availability_zone.c.name
  cidr_block        = "10.0.5.0/24"
  tags = {
    Name = "platform_private_c"
  }
}

resource "aws_network_acl" "https" {
  vpc_id = aws_vpc.platform.id

  egress {
    protocol   = -1
    rule_no    = 200
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 99
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 1024
    to_port    = 65535
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 443
    to_port    = 443
  }

  ingress {
    protocol   = "tcp"
    rule_no    = 98
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 4141
    to_port    = 4141
  }

  tags = {
    Name = "https"
  }
}

resource "aws_network_acl_association" "platform_public_a_https" {
  network_acl_id = aws_network_acl.https.id
  subnet_id      = aws_subnet.platform_public_a.id
}

resource "aws_network_acl_association" "platform_public_c_https" {
  network_acl_id = aws_network_acl.https.id
  subnet_id      = aws_subnet.platform_public_c.id
}

resource "aws_network_acl_association" "platform_private_a_https" {
  network_acl_id = aws_network_acl.https.id
  subnet_id      = aws_subnet.platform_private_a.id
}

resource "aws_network_acl_association" "platform_private_c_https" {
  network_acl_id = aws_network_acl.https.id
  subnet_id      = aws_subnet.platform_private_c.id
}

resource "aws_security_group" "ingress_https" {
  name        = "ingress_https"
  description = "Allow inbound HTTPS traffic"
  vpc_id      = aws_vpc.platform.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_from_internet" {
  security_group_id = aws_security_group.ingress_https.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_egress_rule" "ingress_https_egress" {
  security_group_id = aws_security_group.ingress_https.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_security_group" "https_from_public_subnets" {
  name        = "https_from_public_subnets"
  description = "Allow HTTPS traffic to flow to the private subnet from the public subnet"
  vpc_id      = aws_vpc.platform.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_https_from_public_subnets" {
  security_group_id            = aws_security_group.https_from_public_subnets.id
  referenced_security_group_id = aws_security_group.ingress_https.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

resource "aws_vpc_security_group_ingress_rule" "allow_atlantis_from_public_subnet" {
  security_group_id            = aws_security_group.https_from_public_subnets.id
  referenced_security_group_id = aws_security_group.ingress_https.id
  from_port                    = 4141
  ip_protocol                  = "tcp"
  to_port                      = 4141
}

resource "aws_vpc_security_group_egress_rule" "https_from_public_subnets_egress" {
  security_group_id = aws_security_group.https_from_public_subnets.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_internet_gateway" "platform" {
  vpc_id = aws_vpc.platform.id
  tags = {
    Name = "platform"
  }
}

resource "aws_eip" "platform_public_a_nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "platform_public_a" {
  connectivity_type = "public"
  allocation_id     = aws_eip.platform_public_a_nat.allocation_id
  subnet_id         = aws_subnet.platform_public_a.id

  depends_on = [aws_internet_gateway.platform]
}

resource "aws_lb" "platform" {
  name               = "platform"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ingress_https.id]
  subnets = [
    aws_subnet.platform_public_a.id,
    aws_subnet.platform_public_c.id
  ]

  enable_deletion_protection = true

  depends_on = [
    aws_internet_gateway.platform
  ]
}