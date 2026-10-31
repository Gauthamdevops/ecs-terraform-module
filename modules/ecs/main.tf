# ECS Cluster - Single cluster hosting both Frontend and Backend services
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-${var.environment}-cluster"

  setting {
    name  = "containerInsights"
    value = var.enable_container_insights ? "enabled" : "disabled"
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-cluster"
      Environment = var.environment
    }
  )
}

# Capacity Providers for Fargate
resource "aws_ecs_cluster_capacity_providers" "main" {
  cluster_name = aws_ecs_cluster.main.name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

# CloudWatch Log Group for ECS tasks
resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-logs"
      Environment = var.environment
    }
  )
}

# IAM Trust Policy Document for ECS Tasks
data "aws_iam_policy_document" "ecs_tasks_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

# IAM Role: Task Execution Role (used by ECS agent to pull images and push logs)
resource "aws_iam_role" "execution" {
  name               = "${var.project_name}-${var.environment}-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-ecs-execution-role"
      Environment = var.environment
    }
  )
}

# Attach standard AWS Task Execution policy
resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM Role: Task Role (used by the application containers themselves)
resource "aws_iam_role" "task" {
  name               = "${var.project_name}-${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_tasks_assume_role.json

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-ecs-task-role"
      Environment = var.environment
    }
  )
}

# Security Group for ECS Tasks (Allows traffic from ALB to container ports)
resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-${var.environment}-ecs-tasks-sg"
  description = "Allows inbound traffic from the ALB on frontend and backend container ports"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = toset([var.frontend_app_port, var.backend_app_port])
    content {
      description     = "Allow traffic from ALB on port ${ingress.value}"
      from_port       = ingress.value
      to_port         = ingress.value
      protocol        = "tcp"
      security_groups = [var.alb_security_group_id]
    }
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-ecs-tasks-sg"
      Environment = var.environment
    }
  )
}

# 1. FRONTEND: Task Definition & ECS Service

resource "aws_ecs_task_definition" "frontend" {
  count                    = var.create_frontend_service ? 1 : 0
  family                   = "${var.project_name}-${var.environment}-frontend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.frontend_container_cpu)
  memory                   = tostring(var.frontend_container_memory)
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-${var.environment}-frontend"
      image     = var.frontend_container_image
      essential = true
      portMappings = [
        {
          containerPort = var.frontend_app_port
          hostPort      = var.frontend_app_port
          protocol      = "tcp"
        }
      ]
      environment = var.frontend_environment_variables
      secrets     = var.frontend_secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "frontend"
        }
      }
    }
  ])

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-frontend-task"
      Environment = var.environment
      Service     = "frontend"
    }
  )
}

resource "aws_ecs_service" "frontend" {
  count           = var.create_frontend_service ? 1 : 0
  name            = "${var.project_name}-${var.environment}-frontend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend[0].arn
  desired_count   = var.frontend_desired_count
  launch_type     = "FARGATE"
  propagate_tags  = "SERVICE"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.frontend_target_group_arn
    container_name   = "${var.project_name}-${var.environment}-frontend"
    container_port   = var.frontend_app_port
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-frontend-service"
      Environment = var.environment
      Service     = "frontend"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.execution
  ]
}

# 2. BACKEND (API): Task Definition & ECS Service

resource "aws_ecs_task_definition" "backend" {
  count                    = var.create_backend_service ? 1 : 0
  family                   = "${var.project_name}-${var.environment}-backend"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = tostring(var.backend_container_cpu)
  memory                   = tostring(var.backend_container_memory)
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-${var.environment}-backend"
      image     = var.backend_container_image
      essential = true
      portMappings = [
        {
          containerPort = var.backend_app_port
          hostPort      = var.backend_app_port
          protocol      = "tcp"
        }
      ]
      environment = var.backend_environment_variables
      secrets     = var.backend_secrets
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backend"
        }
      }
    }
  ])

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-backend-task"
      Environment = var.environment
      Service     = "backend"
    }
  )
}

resource "aws_ecs_service" "backend" {
  count           = var.create_backend_service ? 1 : 0
  name            = "${var.project_name}-${var.environment}-backend"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend[0].arn
  desired_count   = var.backend_desired_count
  launch_type     = "FARGATE"
  propagate_tags  = "SERVICE"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200

  network_configuration {
    subnets          = var.private_subnet_ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.backend_target_group_arn
    container_name   = "${var.project_name}-${var.environment}-backend"
    container_port   = var.backend_app_port
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.project_name}-${var.environment}-backend-service"
      Environment = var.environment
      Service     = "backend"
    }
  )

  depends_on = [
    aws_iam_role_policy_attachment.execution
  ]
}
