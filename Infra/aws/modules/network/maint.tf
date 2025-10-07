# VPC, Subnets, IGW, NAT Gateway, Route Tables, and Core Security Group Configuration

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

# 2. Internet Gateway (IGW)
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
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone = var.azs[count.index]
  map_public_ip_on_launch = true # Public subnets need public IPs

  tags = {
    Name    = "${var.project_name}-public-subnet-${var.azs[count.index]}"
    Tier    = "Public"
  }
}

# 4. Private Subnets (for ECS Fargate Tasks and RDS)
resource "aws_subnet" "private" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + length(var.azs))
  availability_zone = var.azs[count.index]

  tags = {
    Name    = "${var.project_name}-private-subnet-${var.azs[count.index]}"
    Tier    = "Private"
  }
}

# --- NAT GATEWAY CONFIGURATION ---

# 5. Elastic IP (EIP) for NAT Gateway
# We create one NAT Gateway (and one EIP) per public subnet for high availability, 
# but for simplicity and cost saving in this setup, we'll use just one in the first AZ.
resource "aws_eip" "nat_gateway_eip" {
  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# 6. NAT Gateway
# The NAT Gateway MUST be placed in a Public Subnet (e.g., the first one created).
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public[0].id 
  depends_on    = [aws_internet_gateway.main]

  tags = {
    Name = "${var.project_name}-nat-gateway"
  }
}

# --- ROUTE TABLES ---

# 7. Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Route: Internet-bound traffic (0.0.0.0/0) goes to the Internet Gateway
resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main.id
}

# 8. Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Route: Internet-bound traffic (0.0.0.0/0) goes to the NAT Gateway
resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}

# --- ROUTE TABLE ASSOCIATIONS ---

# 9. Public Subnet Associations
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# 10. Private Subnet Associations
resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# --- SECURITY GROUPS (AS BEFORE) ---

# 11. Core Security Group for Application (ECS Tasks)
resource "aws_security_group" "app_sg" {
  name        = "${var.project_name}-app-sg"
  description = "Allows traffic from the Load Balancer to the ECS tasks"
  vpc_id      = aws_vpc.main.id

  # Egress rule: Allow all outbound traffic (via NAT Gateway)
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

# 12. RDS Security Group
resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg"
  description = "Controls access to the Aurora MySQL cluster"
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-rds-sg"
  }
}
