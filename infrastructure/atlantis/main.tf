###########
### VPC ###
###########

resource "aws_vpc" "platform" {
  cidr_block = "10.0.0.0/21"
  tags = {
    Name = "platform"
  }
}

resource "aws_default_route_table" "platform_default" {
  default_route_table_id = aws_vpc.platform.default_route_table_id
  route                  = []
  tags = {
    Name = "platform_default"
  }
}

resource "aws_default_network_acl" "platform_default" {
  default_network_acl_id = aws_vpc.platform.default_network_acl_id
  subnet_ids             = []
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

resource "aws_internet_gateway" "platform" {
  vpc_id = aws_vpc.platform.id
  tags = {
    Name = "platform"
  }
}

####################
### ROUTE TABLES ###
####################

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

######################
### PUBLIC SUBNETS ###
######################

resource "aws_subnet" "platform_public_a" {
  vpc_id                  = aws_vpc.platform.id
  availability_zone       = data.aws_availability_zone.a.name
  map_public_ip_on_launch = true
  cidr_block              = "10.0.0.0/24"
  tags = {
    Name = "platform_public_a"
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

#######################
### PRIVATE SUBNETS ###
#######################

resource "aws_subnet" "platform_private_a" {
  vpc_id            = aws_vpc.platform.id
  availability_zone = data.aws_availability_zone.a.name
  cidr_block        = "10.0.4.0/24"
  tags = {
    Name = "platform_private_a"
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

###################
### NETWORK ACL ###
###################

resource "aws_network_acl" "platform" {
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
    Name = "platform"
  }
}

resource "aws_network_acl_association" "platform_public_a" {
  network_acl_id = aws_network_acl.platform.id
  subnet_id      = aws_subnet.platform_public_a.id
}

resource "aws_network_acl_association" "platform_public_c" {
  network_acl_id = aws_network_acl.platform.id
  subnet_id      = aws_subnet.platform_public_c.id
}

resource "aws_network_acl_association" "platform_private_a" {
  network_acl_id = aws_network_acl.platform.id
  subnet_id      = aws_subnet.platform_private_a.id
}

resource "aws_network_acl_association" "platform_private_c" {
  network_acl_id = aws_network_acl.platform.id
  subnet_id      = aws_subnet.platform_private_c.id
}

#######################
### SECURITY GROUPS ###
#######################

resource "aws_security_group" "alb" {
  name        = "alb"
  description = "Allow ALB to get HTTPS traffic from the internet"
  vpc_id      = aws_vpc.platform.id
  tags = {
    Name = "alb"
  }
}

resource "aws_security_group" "atlantis" {
  name        = "atlantis"
  description = "Allow Atlantis to receive HTTP traffic from the ALB"
  vpc_id      = aws_vpc.platform.id
  tags = {
    Name = "atlantis"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}

resource "aws_vpc_security_group_ingress_rule" "atlantis_https" {
  security_group_id            = aws_security_group.atlantis.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443
}

resource "aws_vpc_security_group_ingress_rule" "atlantis_http" {
  security_group_id            = aws_security_group.atlantis.id
  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 4141
  ip_protocol                  = "tcp"
  to_port                      = 4141
}

resource "aws_vpc_security_group_egress_rule" "alb_egress" {
  security_group_id = aws_security_group.alb.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

resource "aws_vpc_security_group_egress_rule" "atlantis_egress" {
  security_group_id = aws_security_group.atlantis.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = -1
}

###########
### NAT ###
###########

resource "aws_eip" "platform_public_a_nat" {
  domain = "vpc"
  tags = {
    Name = "platform_public_a_nat"
  }
}

resource "aws_nat_gateway" "platform_public_a" {
  connectivity_type = "public"
  allocation_id     = aws_eip.platform_public_a_nat.allocation_id
  subnet_id         = aws_subnet.platform_public_a.id
  tags = {
    Name = "platform_public_a"
  }

  depends_on = [
    aws_internet_gateway.platform
  ]
}

######################
### LOAD BALANCERS ###
######################

resource "aws_lb" "platform" {
  name                       = "platform"
  internal                   = false
  load_balancer_type         = "application"
  enable_deletion_protection = true
  security_groups = [
    aws_security_group.alb.id
  ]
  subnets = [
    aws_subnet.platform_public_a.id,
    aws_subnet.platform_public_c.id
  ]

  depends_on = [
    aws_internet_gateway.platform
  ]
}

resource "aws_lb_listener" "atlantis" {
  load_balancer_arn = aws_lb.platform.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = aws_acm_certificate.atlantis.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.atlantis.arn
  }
}


resource "aws_lb_target_group" "atlantis" {
  name_prefix     = "atlant"
  port            = 4141
  protocol        = "HTTP"
  target_type     = "ip"
  ip_address_type = "ipv4"
  vpc_id          = aws_vpc.platform.id
  health_check {
    path                = "/healthz"
    protocol            = "HTTP"
    matcher             = "200"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 10
    interval            = 30
  }
  lifecycle {
    create_before_destroy = true
  }
}

###########
### DNS ###
###########
resource "aws_route53_zone" "thoughtlyifyio" {
  name = "thoughtlyify.io"
}

resource "aws_route53_record" "atlantis" {
  zone_id = aws_route53_zone.thoughtlyifyio.zone_id
  name    = "atlantis.thoughtlyify.io"
  type    = "CNAME"
  ttl     = 300
  records = [
    aws_lb.platform.dns_name
  ]
}

resource "aws_route53_record" "atlantis_cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.atlantis.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.thoughtlyifyio.zone_id
}

####################
### CERTIFICATES ###
####################
resource "aws_acm_certificate" "atlantis" {
  domain_name       = aws_route53_record.atlantis.name
  validation_method = "DNS"
  key_algorithm     = "RSA_2048"
  validation_option {
    domain_name       = aws_route53_record.atlantis.fqdn
    validation_domain = "thoughtlyify.io"
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "atlantis" {
  certificate_arn         = aws_acm_certificate.atlantis.arn
  validation_record_fqdns = [for record in aws_route53_record.atlantis_cert_validation : record.fqdn]
}

###########
### ECS ###
###########

resource "aws_ecs_cluster" "platform" {
  name = "platform"
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
  configuration {
    execute_command_configuration {
      logging = "NONE"
    }
  }
}

resource "aws_ecs_task_definition" "atlantis" {
  family                   = "atlantis"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  execution_role_arn = aws_iam_role.atlantis_execution.arn
  container_definitions = jsonencode([
    {
      name : "atlantis"
      image : "ghcr.io/runatlantis/atlantis:dev-alpine-7b4576a@sha256:feef1f0f9b4d8f3dfa3779109e42119ba2a3d0f887c5c3104d0f81f85e8c7fcc"
      command : [
        "server",
        "--gh-user=fake",
        "--gh-token=fake",
        "--repo-allowlist='github.com/cjhouser/thoughtlyify.io'",
        "--atlantis-url=http://atlantis.thoughtlyify.io",
        "--port=4141",
        "--web-basic-auth=true",
        "--autodiscover-mode=disabled"
      ]
      secrets: [
        {
          "name": "ATLANTIS_WEB_USERNAME",
          "valueFrom": "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/thoughtlyify.io/infrastructure/atlantis/ATLANTIS_WEB_USERNAME"
        },
        {
          "name": "ATLANTIS_WEB_PASSWORD",
          "valueFrom": "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/thoughtlyify.io/infrastructure/atlantis/ATLANTIS_WEB_PASSWORD"
        }
      ]
      cpu : 256
      memory : 512
      essential : true
      portMappings = [
        {
          containerPort = 4141
        }
      ]
      healthCheck = {
        command = [
          "CMD-SHELL",
          "curl -f http://127.0.0.1:4141 || exit 1"
        ],
        interval    = 30,
        timeout     = 5,
        startPeriod = 10,
        retries     = 3
      }
    }
  ])
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}

resource "aws_ecs_service" "atlantis" {
  name                               = "atlantis"
  cluster                            = aws_ecs_cluster.platform.id
  task_definition                    = aws_ecs_task_definition.atlantis.arn
  desired_count                      = 1
  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  launch_type                        = "FARGATE"
  network_configuration {
    subnets = [
      aws_subnet.platform_private_a.id,
      aws_subnet.platform_private_c.id
    ]
    assign_public_ip = false
    security_groups = [
      aws_security_group.atlantis.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.atlantis.arn
    container_name   = "atlantis"
    container_port   = 4141
  }
}

###########
### KMS ###
###########

resource "aws_kms_key" "atlantis" {
  description = "Key for encrypting sensitive Atlantis configuration"
  key_usage = "ENCRYPT_DECRYPT"
}

##################
### PARAMETERS ###
##################

resource "aws_ssm_parameter" "atlantis_web_username" {
  name        = "/thoughtlyify.io/infrastructure/atlantis/ATLANTIS_WEB_USERNAME"
  description = "ATLANTIS_WEB_USERNAME"
  type        = "SecureString"
  value       = var.atlantis_web_username
  key_id = aws_kms_key.atlantis.id
  tier = "Standard"
}

resource "aws_ssm_parameter" "atlantis_web_password" {
  name        = "/thoughtlyify.io/infrastructure/atlantis/ATLANTIS_WEB_PASSWORD"
  description = "ATLANTIS_WEB_PASSWORD"
  type        = "SecureString"
  value       = var.atlantis_web_password
  key_id = aws_kms_key.atlantis.id
  tier = "Standard"
}

###########
### IAM ###
###########
resource "aws_iam_policy" "atlantis_execution" {
  name        = "atlantis_execution"
  path        = "/"
  description = "Allow Atlantis to get parameters from Parameter Store"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement: [
      {
        Effect: "Allow"
        Action: [
          "ssm:GetParameters",
          "kms:Decrypt"
        ]
        Resource: [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/thoughtlyify.io/infrastructure/atlantis/*",
          "arn:aws:kms:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:key/${aws_kms_key.atlantis.id}"
        ]
      }
    ]
  })
}
resource "aws_iam_role" "atlantis_execution" {
  name = "atlantis_execution"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "atlantis_execution" {
  role       = aws_iam_role.atlantis_execution.name
  policy_arn = aws_iam_policy.atlantis_execution.arn
}