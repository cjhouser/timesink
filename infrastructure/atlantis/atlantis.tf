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
  container_definitions    = jsonencode([
    {
      name: "atlantis"
      image: "ghcr.io/runatlantis/atlantis:dev-alpine-1c4f688"
      command: [
        "server",
        "--gh-user=fake",
        "--gh-token=fake",
        "--repo-allowlist 'github.com/cjhouser/thoughtlyify.io'",
        "--atlantis-url https://$ATLANTIS_HOST"
      ]
      cpu: 256
      memory: 512
      essential: true
      portMappings = [
        {
          containerPort = 4141
        }
      ]
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }
}
