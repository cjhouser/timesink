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
