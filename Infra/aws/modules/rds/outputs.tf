output "db_endpoint" {
  description = "The DNS address of the standard RDS instance endpoint."
  value       = aws_db_instance.main.address
}

output "db_port" {
  description = "The port of the RDS instance."
  value       = aws_db_instance.main.port
}