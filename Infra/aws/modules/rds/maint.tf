# 1. DB Subnet Group (Required for RDS deployment)
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = {
    Name = "${var.project_name}-rds-subnet-group"
  }
}

# 2. Aurora MySQL Cluster
resource "aws_rds_cluster" "main" {
  cluster_identifier      = "${var.project_name}-db-cluster"
  engine                  = "aurora-mysql"
  engine_version          = "8.0.mysql_aurora.3.02.2"
  database_name           = var.db_name
  master_username         = var.db_username
  master_password         = var.db_password # Marked sensitive in root variables
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
  skip_final_snapshot     = true
  db_subnet_group_name    = aws_db_subnet_group.main.name
  vpc_security_group_ids  = [var.rds_security_group_id]
}

# 3. Cluster Instance (the actual node running the database)
resource "aws_rds_cluster_instance" "main" {
  count                = 1
  identifier           = "${var.project_name}-instance-${count.index}"
  cluster_identifier   = aws_rds_cluster.main.id
  engine               = aws_rds_cluster.main.engine
  engine_version       = aws_rds_cluster.main.engine_version
  instance_class       = var.db_instance_class
  db_subnet_group_name = aws_db_subnet_group.main.name
  publicly_accessible  = false
  availability_zone    = element(var.azs, count.index)
}
