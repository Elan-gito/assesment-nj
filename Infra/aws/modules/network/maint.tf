# 1. VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

# 2. Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 3. Public Subnets (for ALB and NAT Gateway)
resource "aws_subnet" "public" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index) # E.g., 10.0.0.0/24, 10.0.1.0/24
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-subnet-${var.azs[count.index]}"
    Tier    = "Public"
  }
}

# 4. Private Subnets (for ECS Fargate Tasks and RDS)
resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.azs)) # E.g., 10.0.2.0/24, 10.0.3.0/24
  availability_zone = var.azs[count.index]

  tags = {
    Name    = "${var.project_name}-private-subnet-${var.azs[count.index]}"
    Tier    = "Private"
  }
}

# 5. Core Security Group for Application (ECS Tasks)
# Allows ingress traffic from ALB, and all egress.
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Allows traffic from the Load Balancer to the ECS tasks"
  vpc_id      = aws_vpc.main.id

  # Egress rule: Allow all outbound traffic (needed for tasks to reach RDS and internet)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-app-sg"
  }
}

# 6. RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Controls access to the Aurora MySQL cluster"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}