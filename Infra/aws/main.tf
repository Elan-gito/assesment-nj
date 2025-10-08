# 1. Network Module: Creates VPC, Subnets, and Core Security Groups
module "network" {
  source       = "./modules/network"
  project_name = var.project_name
  azs          = var.azs 
}

# 2. RDS Module: Creates Aurora Cluster and Instances (High Availability)
module "rds" {
  source                = "./modules/rds"
  project_name          = var.project_name
  private_subnet_ids    = module.network.private_subnet_ids # Dependency on Network module
  rds_security_group_id = module.network.rds_security_group_id # Dependency on Network module
  db_username           = var.db_username
  db_password           = var.db_password
  db_name               = var.db_name
  db_instance_class     = var.db_instance_class
  azs                   = var.azs
  db_instance_count     = var.db_instance_count
}

# 3. ECS Service Module: Creates Cluster, ECR, ALB, and Fargate Tasks
module "ecs_service" {
  source                  = "./modules/ecs"
  project_name            = var.project_name
  aws_region              = var.aws_region
  ecr_repo_name           = var.ecr_repo_name
  container_port          = var.container_port
  task_cpu                = var.task_cpu
  task_memory             = var.task_memory
  # Networking Inputs from Network Module
  vpc_id                  = module.network.vpc_id 
  public_subnet_ids       = module.network.public_subnet_ids 
  private_subnet_ids      = module.network.private_subnet_ids 
  app_security_group_id   = module.network.app_security_group_id 
  rds_security_group_id   = module.network.rds_security_group_id 
  
  # Database Inputs from RDS Module
  db_endpoint             = module.rds.db_endpoint 
  db_username             = var.db_username
  db_password             = var.db_password
  db_name                 = var.db_name
}
