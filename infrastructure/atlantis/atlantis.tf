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

resource "aws_ecs_service" "atlantis" {
  name                               = "atlantis"
  cluster                            = aws_ecs_cluster.platform.id
  task_definition                    = aws_ecs_task_definition.atlantis.arn
  desired_count                      = 1
  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 50
  launch_type                        = "FARGATE"

  network_configuration {
    subnets = [
      aws_subnet.platform_private_a.id,
      aws_subnet.platform_private_c.id
    ]
    assign_public_ip = false
    security_groups = [
      aws_security_group.https_from_public_subnets.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.atlantis.arn
    container_name   = "atlantis"
    container_port   = 4141
  }
}
