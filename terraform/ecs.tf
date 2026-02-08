# ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.service}-cluster"

  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "main" {
  family                   = var.service
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.container_cpu
  memory                   = var.container_memory
  execution_role_arn       = data.aws_iam_role.task_execution.arn
  task_role_arn            = data.aws_iam_role.task_execution.arn

  container_definitions = jsonencode([
    {
      name  = var.service
      image = "nginx:latest" # bootstrap task def for deployment

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "FLASK_APP"
          value = "hello"
        },
        {
          name  = "FLASK_ENV"
          value = "production"
        }
      ]

      essential = true
    }
  ])

  lifecycle {
    ignore_changes = [
      container_definitions
    ]
  }
}

# ECS Service
resource "aws_ecs_service" "main" {
  name            = "${var.service}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn # only for bootstrap
  desired_count   = var.desired_count
  launch_type     = "FARGATE"

  network_configuration {
    # Use private subnets for ECS tasks
    subnets = aws_subnet.private[*].id

    assign_public_ip = false

    security_groups = [
      aws_security_group.ecs_tasks.id
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = var.service
    container_port   = var.container_port
  }

  # Wait for ALB to be ready before creating service
  depends_on = [
    aws_lb_listener.http
  ]

  # Ignore changes to the task definition as the deployment is managed by cicd
  lifecycle {
    ignore_changes = [
      task_definition
    ]
  }
}
