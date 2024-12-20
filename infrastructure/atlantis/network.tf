resource "aws_vpc" "platform" {
    cidr_block = "10.0.0.0/21"
    tags = {
        management = "terraform"
        Name = "platform"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.platform.id
    availability_zone = data.aws_availability_zone.a.name
    cidr_block = "10.0.0.0/24"
    tags = {
        management = "terraform"
        Name = "public"
    }
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.platform.id
    availability_zone = data.aws_availability_zone.a.name
    cidr_block = "10.0.4.0/24"
    tags = {
        management = "terraform"
        Name = "private"
    }
}

resource "aws_security_group" "public" {
    name        = "public"
    description = "Assign to public subnet"
    vpc_id      = aws_vpc.platform.id
    tags = {
        management = "terraform"
        Name = "public"
    }
}

resource "aws_security_group" "private" {
    name        = "private"
    description = "Assign to private subnet"
    vpc_id      = aws_vpc.platform.id
    tags = {
        management = "terraform"
        Name = "private"
    }
}

resource "aws_vpc_security_group_ingress_rule" "https_public_inbound" {
  security_group_id = aws_security_group.public.id
  description = "Allow inbound HTTPS traffic"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol       = "tcp"
  from_port = 443
  to_port = 443
}

resource "aws_vpc_security_group_ingress_rule" "https_public_to_private" {
  security_group_id = aws_security_group.private.id
  cidr_ipv4   = aws_subnet.public.cidr_block
  description = "Allow inbound HTTPS traffic"
  ip_protocol       = "tcp"
  from_port = 443
  to_port = 443
}

resource "aws_vpc_security_group_egress_rule" "all_public_outbound" {
  security_group_id = aws_security_group.public.id
  description = "Allow all outbound traffic"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_vpc_security_group_egress_rule" "all_private_outbound" {
  security_group_id = aws_security_group.private.id
  description = "Allow all outbound traffic"
  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol       = "-1"
}

resource "aws_route_table" "public" {
    vpc_id = aws_vpc.platform.id
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.gateway.id
    }
    tags = {
        management = "terraform"
        Name = "public"
    }
}

resource "aws_default_route_table" "private" {
    default_route_table_id = aws_vpc.platform.default_route_table_id
    route = []
    tags = {
        management = "terraform"
        Name = "private"
    }
}

resource "aws_internet_gateway" "gateway" {
    vpc_id = aws_vpc.platform.id
    tags = {
        management = "terraform"
        Name = "gateway"
    }
}