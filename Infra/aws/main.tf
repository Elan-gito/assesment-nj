# ----------------------------------------------------------------------
# 1. Network Module: Creates VPC, Subnets, and Core Security Groups
# ----------------------------------------------------------------------
module "network" {
  source       = "./Infra/aws/modules/network"
  project_name = var.project_name
  azs          = var.azs 
}

# ----------------------------------------------------------------------
# 2. RDS Module: Creates Aurora Cluster and Instances (High Availability)
# ----------------------------------------------------------------------
module "rds" {
  source                = "./Infra/aws/modules/rds"
  project_name          = var.project_name
  private_subnet_ids    = module.network.private_subnet_ids # Dependency on Network module
  rds_security_group_id = module.network.rds_security_group_id # Dependency on Network module
  db_username           = var.db_username
  db_password           = var.db_password # Used for Secrets Manager initialization
  db_name               = var.db_name
  db_instance_class     = var.db_instance_class
  azs                   = var.azs
  db_instance_count     = var.db_instance_count
}

# ----------------------------------------------------------------------
# 3. ECS Service Module: Creates Cluster, ECR, ALB, and Fargate Tasks
# ----------------------------------------------------------------------
module "ecs_service" {
  source                  = "./Infra/aws/modules/ecs"
  project_name            = var.project_name
  
  # Application-Specific Inputs (The variables you asked about)
  aws_region              = var.aws_region               # <-- Region is passed
  ecr_repo_name           = var.ecr_repo_name            # <-- Repository Name is passed
  container_port          = var.container_port           # <-- Container Port is passed
  task_cpu                = var.task_cpu                 # <-- CPU is passed
  task_memory             = var.task_memory              # <-- Memory is passed
  
  # Networking Inputs from Network Module
  vpc_id                  = module.network.vpc_id 
  public_subnet_ids       = module.network.public_subnet_ids 
  private_subnet_ids      = module.network.private_subnet_ids 
  app_security_group_id   = module.network.app_security_group_id 
  rds_security_group_id   = module.network.rds_security_group_id 
  
  # Database Inputs from RDS Module
  db_endpoint             = module.rds.db_endpoint 
  db_username             = var.db_username
  db_password             = var.db_password # Used for Secret initialization
  db_name                 = var.db_name
}
