output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer to access the Node.js app."
  value       = module.ecs_service.alb_dns_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster (needed for CI/CD pipeline)."
  value       = module.ecs_service.ecs_cluster_name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository (needed for CI/CD pipeline)."
  value       = module.ecs_service.ecr_repository_url
}

output "rds_endpoint" {
  description = "The RDS cluster writer endpoint."
  value       = module.rds.db_endpoint
  sensitive   = true
}

output "vpc_id" {
  description = "The ID of the VPC created."
  value       = module.network.vpc_id
}