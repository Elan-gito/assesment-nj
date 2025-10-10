resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

resource "aws_db_instance" "main" {
  identifier                          = "${var.project_name}-db-instance"
  engine                              = "mysql"
  engine_version                      = var.db_engine_version
  instance_class                      = var.db_instance_class
  allocated_storage                   = 20
  db_name                             = var.db_name
  username                            = var.db_username
  password                            = var.db_password
  backup_retention_period             = 5
  skip_final_snapshot                 = true
  db_subnet_group_name                = aws_db_subnet_group.main.name
  vpc_security_group_ids              = [var.rds_security_group_id]
  publicly_accessible                 = false
  multi_az                            = var.multi_az_deployment
  storage_type                        = "gp2"
  storage_encrypted                   = true
  deletion_protection                 = true
  iam_database_authentication_enabled = true
}