module "network" {
  source       = "./modules/network"
  project_name = var.project_name
  azs          = var.azs
}

module "rds" {
  source                = "./modules/rds"
  project_name          = var.project_name
  private_subnet_ids    = module.network.private_subnet_ids
  rds_security_group_id = module.network.rds_security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  db_password           = var.db_password
  db_instance_class     = var.db_instance_class
  db_engine_version     = var.db_engine_version
  multi_az_deployment   = var.multi_az_deployment
}

module "ecs_service" {
  source                = "./modules/ecs"
  project_name          = var.project_name
  aws_region            = var.aws_region
  ecr_repo_name         = var.ecr_repo_name
  container_port        = var.container_port
  task_cpu              = var.task_cpu
  task_memory           = var.task_memory
  vpc_id                = module.network.vpc_id
  public_subnet_ids     = module.network.public_subnet_ids
  private_subnet_ids    = module.network.private_subnet_ids
  app_security_group_id = module.network.app_security_group_id
  rds_security_group_id = module.network.rds_security_group_id
  db_endpoint           = module.rds.db_endpoint
  db_username           = var.db_username
  db_password           = var.db_password
  db_name               = var.db_name
  hosted_zone_id        = var.hosted_zone_id
  domain_name           = var.domain_name
  subdomain_name        = var.subdomain_name
  certificate_arn       = var.certificate_arn
}
