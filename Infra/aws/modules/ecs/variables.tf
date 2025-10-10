variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "aws_region" {
  description = "The AWS region."
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC."
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ALB."
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the ECS tasks."
  type        = list(string)
}

variable "app_security_group_id" {
  description = "The Security Group ID for the ECS Tasks."
  type        = string
}

variable "rds_security_group_id" {
  description = "The Security Group ID for the RDS."
  type        = string
}

variable "ecr_repo_name" {
  description = "The name of the ECR repository."
  type        = string
}

variable "container_port" {
  description = "The application port exposed by the container."
  type        = number
}

variable "task_cpu" {
  description = "Fargate task CPU units (e.g., 256, 512)."
  type        = number
}

variable "task_memory" {
  description = "Fargate task memory in MiB (e.g., 512, 1024)."
  type        = number
}

variable "db_endpoint" {
  description = "The RDS cluster endpoint."
  type        = string
}

variable "db_username" {
  description = "The database username."
  type        = string
}

variable "db_password" {
  description = "The master password for the database. Used to initialize the secret."
  type        = string
  sensitive   = true
}

variable "db_name" {
  description = "The database name."
  type        = string
}
