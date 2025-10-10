terraform {
  #   backend "s3" {
  #   # The bucket must be created manually before running terraform init -reconfigure
  #   bucket         = "tf-state-nodejs-crud-${var.project_name}"
  #   key            = "state/${var.project_name}.tfstate"
  #   encrypt        = true
  #   dynamodb_table = "terraform-locks" # Must be created manually with Partition Key 'LockID' (String)
  # }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
