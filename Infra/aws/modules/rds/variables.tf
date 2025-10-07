variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where RDS should be placed."
  type        = list(string)
}

variable "rds_security_group_id" {
  description = "The Security Group ID allowing access to the RDS cluster."
  type        = string
}

variable "db_name" {
  description = "The name of the database to create."
  type        = string
}

variable "db_username" {
  description = "The master username for the database."
  type        = string
}

variable "db_password" {
  description = "The master password for the database."
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "The instance class for the Aurora cluster."
  type        = string
}

variable "azs" {
  description = "List of availability zones for RDS instances."
  type        = list(string)
}

variable "db_instance_count" {
  description = "Number of RDS instances to deploy for HA (should be >= 2)."
  type        = number
}
