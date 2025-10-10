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
  description = "The instance class for the RDS instance (e.g., db.t3.medium)."
  type        = string
}

variable "db_engine_version" {
  description = "The MySQL engine version (e.g., 8.0.35)."
  type        = string
  default     = "8.0.35" 
}

variable "multi_az_deployment" {
  description = "If true, creates a Multi-AZ standby replica for high availability."
  type        = bool
  default     = false
}