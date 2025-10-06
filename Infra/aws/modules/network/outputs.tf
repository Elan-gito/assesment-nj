output "vpc_id" {
  description = "The ID of the created VPC."
  value       = aws_vpc.main.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = aws_subnet.private[*].id
}

output "app_security_group_id" {
  description = "The Security Group ID for the ECS Tasks."
  value       = aws_security_group.app_sg.id
}

output "rds_security_group_id" {
  description = "The Security Group ID for the RDS database."
  value       = aws_security_group.rds_sg.id
}