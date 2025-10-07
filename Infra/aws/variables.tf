variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  # Removed default value to make this required
}

variable "project_name" {
  description = "A unique name for the project to prefix resources"
  type        = string
  default     = "nodejs-crud-ecs"
}

variable "db_username" {
  description = "Master username for the RDS database"
  type        = string
  default     = "admin"
}

variable "db_password" {
  description = "Master password for the RDS database (MANDATORY: Use a secure value via CLI or TF Cloud)"
  type        = string
  sensitive   = true
}

variable "container_port" {
  description = "The port the Node.js application runs on inside the container (Must match Dockerfile)"
  type        = number
  # Removed default value to make this required
}

variable "ecr_repo_name" {
  description = "Name of the ECR repository"
  type        = string
  # Removed default value to make this required
}

variable "task_cpu" {
  description = "The CPU unit for the Fargate task (e.g., 256, 512, 1024)"
  type        = number
  # Removed default value to make this required
}

variable "task_memory" {
  description = "The memory (in MiB) for the Fargate task (e.g., 512, 1024, 2048)"
  type        = number
  # Removed default value to make this required
}

# --- High Availability and Modular Variables ---

variable "azs" {
  description = "List of availability zones to use for network subnets and RDS HA."
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "db_instance_class" {
  description = "The instance class for the Aurora cluster instances (e.g., db.t3.small)."
  type        = string
  default     = "db.t3.small"
}

variable "db_name" {
  description = "The database name to be created in the cluster."
  type        = string
  default     = "crud_db"
}

variable "db_instance_count" {
  description = "Number of RDS instances to deploy for High Availability (recommended >= 2)."
  type        = number
  default     = 2
}
