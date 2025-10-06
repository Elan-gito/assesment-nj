variable "project_name" {
  description = "The name of the project, used for resource tagging."
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "azs" {
  description = "List of availability zones to use for subnets."
  type        = list(string)
}
