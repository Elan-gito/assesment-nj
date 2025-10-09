output "db_endpoint" {
  description = "The DNS address of the RDS cluster writer endpoint."
  value       = aws_rds_cluster.main.endpoint
}

output "db_port" {
  description = "The port of the RDS cluster."
  value       = aws_rds_cluster.main.port
}