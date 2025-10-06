variable "aws_region" {
  description = "The AWS region to deploy resources into."
  type        = string
}

variable "project_name" {
  description = "A unique name for the project, used as a prefix for resources."
  type        = string
}

variable "db_username" {
  description = "The master username for the RDS database."
  type        = string
}

variable "db_password" {
  description = "The master password for the RDS database."
  type        = string
  sensitive   = true # IMPORTANT: Never log this value
}

variable "container_port" {
  description = "The port the Node.js application listens on inside the container."
  type        = number
}

variable "ecr_repo_name" {
  description = "The name for the ECR repository."
  type        = string
}

variable "task_cpu" {
  description = "The number of CPU units for the Fargate Task (e.g., 256, 512, 1024)."
  type        = number
}

variable "task_memory" {
  description = "The amount of memory (in MiB) for the Fargate Task (e.g., 512, 1024, 2048)."
  type        = number
}

variable "azs" {
  description = "List of availability zones to use."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_instance_class" {
  description = "The instance class for the Aurora cluster."
  type        = string
  default     = "db.t3.small"
}

variable "db_name" {
  description = "The name of the database to create."
  type        = string
  default     = "crud_db"
}

