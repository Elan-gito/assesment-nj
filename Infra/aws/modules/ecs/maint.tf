# 1. AWS Secrets Manager (Mock/Demonstration Resource)
resource "aws_secretsmanager_secret" "db_password" {
  name_prefix = "${var.project_name}-db-password-"
  description = "RDS cluster password for ECS tasks."
}

# Sets the initial secret value from the variable (Terraform must be run)
resource "aws_secretsmanager_secret_version" "db_password_version" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

# 2. ECR Repository
resource "aws_ecr_repository" "main" {
  name                 = var.ecr_repo_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# 3. ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
}

# 4. IAM Roles for ECS
resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-ecs-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Task Role (for application-level AWS interaction, like Secrets Manager access)
resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

# NEW: Policy allowing the Task Role to read the DB password secret
resource "aws_iam_role_policy" "secrets_access" {
  name = "${var.project_name}-secret-reader-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "secretsmanager:GetSecretValue"
        Resource = aws_secretsmanager_secret.db_password.arn
      },
      {
        Effect = "Allow"
        Action = "kms:Decrypt"
        # Grant permissions to decrypt the secret, assuming AWS default KMS key
        # In production, use the specific KMS key ARN
        Resource = "*" 
      }
    ]
  })
}

# 5. CloudWatch Log Group
resource "aws_cloudwatch_log_group" "main" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7
}

# 6. ECS Task Definition (Fargate)
resource "aws_ecs_task_definition" "main" {
  family                   = "${var.project_name}-task"
  requires_compatibilities = ["FARGATE" ]
  network_mode             = "awsvpc"
  cpu                      = var.task_cpu
  memory                   = var.task_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = var.project_name
      image     = "${aws_ecr_repository.main.repository_url}:latest"
      cpu       = var.task_cpu
      memory    = var.task_memory
      essential = true
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      environment = [
        # DB_PASSWORD IS REMOVED FROM HERE
        { name = "DB_HOST", value = var.db_endpoint },
        { name = "DB_USER", value = var.db_username },
        { name = "DB_NAME", value = var.db_name }
      ]
      # NEW: Secrets block references the secret ARN
      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = aws_secretsmanager_secret.db_password.arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.main.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

# 7. Application Load Balancer (ALB)
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "${var.project_name}-alb"
  }
}

# ALB Security Group
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Allows HTTP/HTTPS access to the ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# 8. ALB Target Group (Health Checks)
resource "aws_lb_target_group" "main" {
  name        = "${var.project_name}-tg"
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/" 
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

# 9. ALB Listener 
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}

# 10. ECS Service 
resource "aws_ecs_service" "main" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.main.arn
  desired_count   = 2 
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = var.private_subnet_ids 
    security_groups = [var.app_security_group_id]
    assign_public_ip = false
  }
  
  load_balancer {
    target_group_arn = aws_lb_target_group.main.arn
    container_name   = var.project_name
    container_port   = var.container_port
  }

  depends_on = [
    aws_lb_listener.http
  ]
}

# 11. Security Group Ingress Rule 

resource "aws_security_group_rule" "alb_to_app" {
  type                     = "ingress"
  from_port                = var.container_port
  to_port                  = var.container_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb_sg.id
  security_group_id        = var.app_security_group_id
}

resource "aws_security_group_rule" "app_to_rds" {
  type                     = "ingress"
  from_port                = 3306 
  to_port                  = 3306
  protocol                 = "tcp"
  source_security_group_id = var.app_security_group_id
  security_group_id        = var.rds_security_group_id
}
